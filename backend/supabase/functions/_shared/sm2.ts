// ============================================================
// Modified SM-2 Spaced Repetition Algorithm
// ============================================================
//
// Original SM-2 by Piotr Wozniak (SuperMemo).
// This implementation adds:
//   - A "again" grade (0) that resets repetitions to 0
//   - A "hard" grade (1) that keeps interval but reduces EF
//   - Minimum interval caps and maximum interval bounds
//   - Fuzz factor (±5%) to spread review load
//
// Grades:
//   0 = again  (completely wrong — reset)
//   1 = hard   (correct but with significant difficulty)
//   2 = good   (correct with some hesitation)
//   3 = easy   (correct instantly)
//
// EF (Ease Factor): controls how fast the interval grows.
//   Starts at 2.5, min 1.3, no upper bound.
// ============================================================

export interface SM2State {
  repetitions: number;   // n — number of consecutive correct reviews
  easeFactor: number;    // EF — multiplier for next interval
  intervalDays: number;  // I — days until next review
}

export interface SM2Result extends SM2State {
  isLeapDay: boolean;    // capped at 365d
}

const MIN_EF     = 1.3;
const MAX_INTERVAL = 365;   // cap at 1 year
const FUZZ       = 0.05;    // ±5% randomisation

/**
 * Compute next SM-2 state given current state and grade (0–3).
 */
export function sm2(state: SM2State, grade: 0 | 1 | 2 | 3): SM2Result {
  let { repetitions, easeFactor, intervalDays } = state;

  if (grade === 0) {
    // Again: reset streak, restart from day 1
    repetitions  = 0;
    intervalDays = 1;
    // EF penalty
    easeFactor = Math.max(MIN_EF, easeFactor - 0.20);

  } else if (grade === 1) {
    // Hard: keep repetition count but shrink interval
    intervalDays = Math.max(1, Math.round(intervalDays * 1.2));
    easeFactor   = Math.max(MIN_EF, easeFactor - 0.15);

  } else {
    // Good (2) or Easy (3)
    if (repetitions === 0) {
      intervalDays = 1;
    } else if (repetitions === 1) {
      intervalDays = 6;
    } else {
      intervalDays = Math.round(intervalDays * easeFactor);
    }

    // EF update: SM-2 formula
    // EF' = EF + (0.1 - (3-q)*(0.08 + (3-q)*0.02))
    const q  = grade;
    const delta = 0.1 - (3 - q) * (0.08 + (3 - q) * 0.02);
    easeFactor = Math.max(MIN_EF, easeFactor + delta);

    repetitions += 1;
  }

  // Apply fuzz to spread review load
  const fuzzDays  = Math.round(intervalDays * FUZZ);
  const fuzzDelta = Math.floor(Math.random() * (fuzzDays * 2 + 1)) - fuzzDays;
  intervalDays    = Math.max(1, intervalDays + fuzzDelta);

  const isLeapDay = intervalDays >= MAX_INTERVAL;
  intervalDays    = Math.min(intervalDays, MAX_INTERVAL);

  return {
    repetitions,
    easeFactor: Math.round(easeFactor * 100) / 100,  // 2 dp
    intervalDays,
    isLeapDay,
  };
}

/**
 * Calculate recall probability (0–1) for a card at review time.
 * Uses a simplified forgetting curve: R = e^(-t / (S * EF))
 * where t = days since last review, S = stability constant (1.0).
 */
export function recallProbability(daysSinceReview: number, easeFactor: number): number {
  const stability = easeFactor;   // treat EF as stability proxy
  return Math.exp(-daysSinceReview / stability);
}

/**
 * Estimate optimal review order within a batch.
 * Lower recall probability → review first.
 */
export function sortByPriority(
  cards: Array<{ daysSinceReview: number; easeFactor: number; repetitions: number }>
): typeof cards {
  return [...cards].sort((a, b) => {
    const ra = recallProbability(a.daysSinceReview, a.easeFactor);
    const rb = recallProbability(b.daysSinceReview, b.easeFactor);
    // Also boost new cards (repetitions === 0) to end of session
    if (a.repetitions === 0 && b.repetitions !== 0) return 1;
    if (a.repetitions !== 0 && b.repetitions === 0) return -1;
    return ra - rb;   // lower recall first
  });
}

// ─── Unit tests (run with: deno test sm2.ts) ───────────────

// Deno.test("grade=2 increases interval", () => {
//   const r1 = sm2({ repetitions: 0, easeFactor: 2.5, intervalDays: 1 }, 2);
//   assertEquals(r1.repetitions, 1);
//   assertEquals(r1.intervalDays, 1);

//   const r2 = sm2(r1, 2);
//   assertEquals(r2.repetitions, 2);
//   assertEquals(r2.intervalDays, 6);

//   const r3 = sm2(r2, 2);
//   assertEquals(r3.repetitions, 3);
//   // interval ≈ 6 * 2.5 = 15 (± fuzz)
//   assert(r3.intervalDays >= 13 && r3.intervalDays <= 17);
// });

// Deno.test("grade=0 resets repetitions", () => {
//   const s = { repetitions: 5, easeFactor: 2.5, intervalDays: 30 };
//   const r = sm2(s, 0);
//   assertEquals(r.repetitions, 0);
//   assertEquals(r.intervalDays, 1);
//   assert(r.easeFactor < 2.5);
// });
