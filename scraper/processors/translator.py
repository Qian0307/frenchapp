"""
Translator: English → 繁體中文 (Traditional Chinese)
─────────────────────────────────────────────────────
Uses deep-translator (Google Translate backend) which requires no API key.
Falls back to a cached manual dictionary for the 500 most common words.

Strategy:
  1. Check manual dictionary (instant, high quality)
  2. Check file cache (avoid re-translating)
  3. Call Google Translate with zh-TW target
  4. If Google fails, return empty string (word still inserted without zh_tw)
"""

import json
import logging
import asyncio
import time
from pathlib import Path
from typing import Optional

from deep_translator import GoogleTranslator
from tenacity import retry, wait_exponential, stop_after_attempt, retry_if_exception_type
from tqdm.asyncio import tqdm as async_tqdm

from config import CACHE_DIR, TRANSLATE_DELAY_SEC, TRANSLATE_WORKERS

logger = logging.getLogger(__name__)

TRANS_CACHE_FILE = CACHE_DIR / "translations_zh_tw.json"

# ── Manual dictionary (top ~300 words, curated for accuracy) ──
# Format: { "english_word_or_phrase": "繁體中文" }
MANUAL_ZH_TW: dict[str, str] = {
    # Greetings & basics
    "hello": "你好",
    "goodbye": "再見",
    "please": "請",
    "thank you": "謝謝",
    "sorry": "對不起",
    "yes": "是",
    "no": "否",
    # Articles & determiners (French concepts often need specific TW translation)
    "the": "（定冠詞）",
    "a / an": "一（不定冠詞）",
    "some": "一些",
    "this": "這個",
    "that": "那個",
    # Common nouns
    "house / home": "房子／家",
    "water": "水",
    "man": "男人",
    "woman": "女人",
    "child": "孩子",
    "day": "天",
    "year": "年",
    "time": "時間",
    "hand": "手",
    "head": "頭",
    "eye": "眼睛",
    "door": "門",
    "country": "國家",
    "city": "城市",
    "town": "城鎮",
    "world": "世界",
    "life": "生命／生活",
    "way": "方式／道路",
    "work": "工作",
    "thing": "事情",
    "place": "地方",
    "body": "身體",
    "food": "食物",
    "book": "書",
    "friend": "朋友",
    "family": "家人",
    "money": "錢",
    "car": "汽車",
    "face": "臉",
    "night": "夜晚",
    "morning": "早晨",
    "afternoon": "下午",
    "evening": "傍晚",
    "school": "學校",
    "table": "桌子",
    "chair": "椅子",
    "window": "窗戶",
    "street": "街道",
    "road": "道路",
    "sky": "天空",
    "sun": "太陽",
    "moon": "月亮",
    "rain": "雨",
    "tree": "樹",
    "flower": "花",
    "fish": "魚",
    "bread": "麵包",
    "wine": "葡萄酒",
    "coffee": "咖啡",
    "tea": "茶",
    "milk": "牛奶",
    "apple": "蘋果",
    "cat": "貓",
    "dog": "狗",
    "bird": "鳥",
    # Common verbs
    "to be": "是／存在",
    "to have": "有",
    "to do / to make": "做",
    "to say": "說",
    "to go": "去",
    "to want": "想要",
    "to see": "看",
    "to come": "來",
    "to know": "知道",
    "to think": "思考／認為",
    "to take": "拿取",
    "to look": "看",
    "to give": "給",
    "to use": "使用",
    "to find": "找到",
    "to speak": "說話",
    "to eat": "吃",
    "to drink": "喝",
    "to work": "工作",
    "to live": "居住／生活",
    "to love": "愛",
    "to like": "喜歡",
    "to read": "閱讀",
    "to write": "寫",
    "to listen": "聆聽",
    "to hear": "聽到",
    "to put": "放置",
    "to play": "玩",
    "to leave": "離開",
    "to arrive": "到達",
    "to return": "返回",
    "to ask": "問",
    "to answer": "回答",
    "to open": "打開",
    "to close": "關閉",
    "to buy": "購買",
    "to sell": "賣",
    "to learn": "學習",
    "to understand": "理解",
    "to remember": "記得",
    "to forget": "忘記",
    "to begin / to start": "開始",
    "to finish / to end": "結束",
    "to wait": "等待",
    "to help": "幫助",
    "to need": "需要",
    "to try": "嘗試",
    "to seem": "似乎",
    "to become": "成為",
    "to call": "呼喚／稱呼",
    "to hold": "握住",
    "to keep": "保持",
    "to show": "展示",
    "to feel": "感覺",
    "to meet": "遇見",
    # Adjectives
    "good": "好的",
    "great / big": "大的",
    "small / little": "小的",
    "new": "新的",
    "old": "舊的／老的",
    "young": "年輕的",
    "beautiful": "美麗的",
    "handsome": "英俊的",
    "beautiful / handsome": "美麗的",
    "long": "長的",
    "short": "短的",
    "high / tall": "高的",
    "low": "低的",
    "first": "第一的",
    "last": "最後的",
    "important": "重要的",
    "possible": "可能的",
    "impossible": "不可能的",
    "happy": "快樂的",
    "sad": "悲傷的",
    "difficult / hard": "困難的",
    "easy": "容易的",
    "fast": "快速的",
    "slow": "緩慢的",
    "open": "開放的",
    "closed": "關閉的",
    "different": "不同的",
    "same": "相同的",
    "true": "真實的",
    "false": "錯誤的",
    "certain / sure": "確定的",
    "free": "自由的／免費的",
    "right / correct": "正確的",
    "wrong": "錯誤的",
    "ready": "準備好的",
    "alone": "孤單的",
    "together": "一起的",
    # Adverbs / connectors
    "very": "非常",
    "also / too": "也",
    "however / nevertheless": "然而",
    "yet / even so / nonetheless": "然而／儘管如此",
    "notwithstanding / despite": "儘管",
    "today": "今天",
    "yesterday": "昨天",
    "tomorrow": "明天",
    "always": "總是",
    "never": "從不",
    "often": "經常",
    "sometimes": "有時",
    "already": "已經",
    "still / yet": "仍然",
    "more": "更多",
    "less": "更少",
    "too much": "太多",
    "enough": "足夠",
    "here": "這裡",
    "there": "那裡",
    "why": "為什麼",
    "because": "因為",
    "therefore": "因此",
    # Numbers
    "zero": "零",
    "one": "一",
    "two": "二",
    "three": "三",
    "four": "四",
    "five": "五",
    "ten": "十",
    "hundred": "百",
    "thousand": "千",
    "million": "百萬",
    # Phrases
    "hello / good morning": "你好／早安",
    "good evening": "晚安",
    "good night": "晚安",
    "how are you": "你好嗎",
    "subsidy / grant": "補貼／補助金",
    "neighbourhood / district": "街區／地區",
    "blossoming / fulfilment / self-actualization": "自我實現／開花結果",
    "fulfilment / self-actualization / blossoming": "自我實現",
    "stake / issue / challenge": "賭注／議題／挑戰",
    "however / despite": "然而／儘管",
    "to blossom / to flourish / to thrive": "開花／茁壯",
}


# ── Cache management ─────────────────────────────────────────

_trans_cache: dict[str, str] = {}

def _load_trans_cache() -> None:
    global _trans_cache
    if TRANS_CACHE_FILE.exists():
        try:
            with open(TRANS_CACHE_FILE, "r", encoding="utf-8") as f:
                _trans_cache = json.load(f)
            logger.info("Loaded %d translation cache entries", len(_trans_cache))
        except Exception:
            _trans_cache = {}

def save_trans_cache() -> None:
    TRANS_CACHE_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(TRANS_CACHE_FILE, "w", encoding="utf-8") as f:
        json.dump(_trans_cache, f, ensure_ascii=False, indent=2)
    logger.info("Saved %d translation cache entries", len(_trans_cache))

_load_trans_cache()


# ── Translator ───────────────────────────────────────────────

class TraditionalChineseTranslator:
    """
    Translate English text to Traditional Chinese (zh-TW).
    Prioritises manual dict → file cache → Google Translate.
    """

    def __init__(self):
        self._translator = GoogleTranslator(source="en", target="zh-TW")
        self._lock       = asyncio.Lock()

    async def translate_many(
        self,
        texts: list[str],
        desc: str = "Translating",
    ) -> dict[str, str]:
        """Translate a list of strings. Returns {text: zh_tw_translation}."""
        results: dict[str, str] = {}
        pending: list[str]      = []

        for text in texts:
            if not text:
                results[text] = ""
                continue
            # 1. Manual dict (normalise key)
            key = text.lower().strip()
            if key in MANUAL_ZH_TW:
                results[text] = MANUAL_ZH_TW[key]
                continue
            # 2. File cache
            if text in _trans_cache:
                results[text] = _trans_cache[text]
                continue
            pending.append(text)

        if pending:
            # Batch translate with concurrency limit
            sem     = asyncio.Semaphore(TRANSLATE_WORKERS)
            tasks   = [self._translate_one(t, sem) for t in pending]
            trans   = await asyncio.gather(*tasks)
            for text, zh in zip(pending, trans):
                results[text]     = zh
                _trans_cache[text] = zh

        return results

    @retry(
        wait=wait_exponential(min=2, max=30),
        stop=stop_after_attempt(4),
        retry=retry_if_exception_type(Exception),
    )
    async def _translate_one(self, text: str, sem: asyncio.Semaphore) -> str:
        async with sem:
            await asyncio.sleep(TRANSLATE_DELAY_SEC)
            try:
                # Run blocking call in thread pool
                loop = asyncio.get_event_loop()
                result = await loop.run_in_executor(
                    None,
                    lambda: GoogleTranslator(source="en", target="zh-TW").translate(text)
                )
                return result or ""
            except Exception as e:
                logger.warning("Translation failed for '%s': %s", text[:40], e)
                return ""

    async def translate_word_list(
        self, entries: list[dict]
    ) -> list[dict]:
        """
        Given a list of word entry dicts (with 'definitions' list),
        translate the first definition to zh-TW and store as 'zh_tw'.
        """
        # Collect unique texts to translate
        texts_to_translate: list[str] = []
        for e in entries:
            defs = e.get("definitions", [])
            first_def = defs[0] if defs else e.get("english_trans", "")
            texts_to_translate.append(first_def)

        # Translate in bulk
        logger.info("Translating %d definitions to 繁體中文…", len(texts_to_translate))
        trans_map = await self.translate_many(texts_to_translate)

        # Attach to entries
        for entry, text in zip(entries, texts_to_translate):
            entry["zh_tw"] = trans_map.get(text, "")

        return entries


# ── Convenience function ──────────────────────────────────────

async def translate_batch_to_zhtw(texts: list[str]) -> list[str]:
    """Translate a list of English strings to Traditional Chinese."""
    translator = TraditionalChineseTranslator()
    result_map = await translator.translate_many(texts)
    return [result_map.get(t, "") for t in texts]
