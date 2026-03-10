-- ============================================================
-- French Learning App  ·  繁體中文詞彙種子資料
-- 300 words across A1–C2, Traditional Chinese translations
-- translations JSONB key: "zh_tw"
-- ============================================================

INSERT INTO vocabulary (
  french_word, english_trans, translations, word_class, gender, plural_form,
  conjugations, pronunciation_ipa, cefr_level, topic_tags, frequency_rank,
  example_sentences, usage_notes, memory_tip, is_active
) VALUES

-- ═══════════════════════════════════════════════════════════
-- A1  (Rank 1–500)
-- ═══════════════════════════════════════════════════════════

('être','to be','{"zh_tw":"是／存在"}','verb',NULL,NULL,
 '{"present":{"je":"suis","tu":"es","il/elle":"est","nous":"sommes","vous":"êtes","ils/elles":"sont"},"past_participle":"été"}'::jsonb,
 '/ɛtʁ/','A1','{"verbs","modal"}',1,
 '[{"fr":"Je suis étudiant.","en":"I am a student."},{"fr":"Elle est médecin.","en":"She is a doctor."}]'::jsonb,
 'Most irregular verb in French — must be memorised completely.','être → "to be": the most essential verb',true),

('avoir','to have','{"zh_tw":"有"}','verb',NULL,NULL,
 '{"present":{"je":"ai","tu":"as","il/elle":"a","nous":"avons","vous":"avez","ils/elles":"ont"},"past_participle":"eu"}'::jsonb,
 '/a.vwaʁ/','A1','{"verbs","modal"}',2,
 '[{"fr":"J''ai un chat.","en":"I have a cat."},{"fr":"Nous avons faim.","en":"We are hungry."}]'::jsonb,
 'Also used to form passé composé. avoir faim = to be hungry.',NULL,true),

('faire','to do / to make','{"zh_tw":"做／製作"}','verb',NULL,NULL,
 '{"present":{"je":"fais","tu":"fais","il/elle":"fait","nous":"faisons","vous":"faites","ils/elles":"font"},"past_participle":"fait"}'::jsonb,
 '/fɛʁ/','A1','{"verbs"}',3,
 '[{"fr":"Qu''est-ce que tu fais ?","en":"What are you doing?"},{"fr":"Il fait beau.","en":"The weather is nice."}]'::jsonb,
 'faire beau/chaud/froid = weather expressions. Very high frequency.','faire = factory = making things',true),

('aller','to go','{"zh_tw":"去"}','verb',NULL,NULL,
 '{"present":{"je":"vais","tu":"vas","il/elle":"va","nous":"allons","vous":"allez","ils/elles":"vont"},"past_participle":"allé"}'::jsonb,
 '/a.le/','A1','{"verbs","movement"}',4,
 '[{"fr":"Je vais à Paris.","en":"I am going to Paris."},{"fr":"Comment allez-vous ?","en":"How are you?"}]'::jsonb,
 'Used to form near future: je vais manger = I am going to eat.','aller = allée (alley) — a path you go down',true),

('pouvoir','to be able to / can','{"zh_tw":"能夠／可以"}','verb',NULL,NULL,
 '{"present":{"je":"peux","tu":"peux","il/elle":"peut","nous":"pouvons","vous":"pouvez","ils/elles":"peuvent"},"past_participle":"pu"}'::jsonb,
 '/pu.vwaʁ/','A1','{"verbs","modal"}',5,
 '[{"fr":"Tu peux m''aider ?","en":"Can you help me?"},{"fr":"Je ne peux pas venir.","en":"I cannot come."}]'::jsonb,
 'Modal verb — always followed by infinitive. Je peux / je puis (formal).',NULL,true),

('dire','to say / to tell','{"zh_tw":"說／告訴"}','verb',NULL,NULL,
 '{"present":{"je":"dis","tu":"dis","il/elle":"dit","nous":"disons","vous":"dites","ils/elles":"disent"},"past_participle":"dit"}'::jsonb,
 '/diʁ/','A1','{"verbs","communication"}',6,
 '[{"fr":"Il dit bonjour.","en":"He says hello."},{"fr":"Dis-moi la vérité.","en":"Tell me the truth."}]'::jsonb,
 'vous dites (irregular — not *disez). dire que + subjonctif.',NULL,true),

('voir','to see','{"zh_tw":"看見"}','verb',NULL,NULL,
 '{"present":{"je":"vois","tu":"vois","il/elle":"voit","nous":"voyons","vous":"voyez","ils/elles":"voient"},"past_participle":"vu"}'::jsonb,
 '/vwaʁ/','A1','{"verbs","perception"}',7,
 '[{"fr":"Je vois la mer.","en":"I can see the sea."},{"fr":"On verra.","en":"We''ll see."}]'::jsonb,
 'voir vs regarder: voir = to see (passive), regarder = to watch (active).',NULL,true),

('venir','to come','{"zh_tw":"來"}','verb',NULL,NULL,
 '{"present":{"je":"viens","tu":"viens","il/elle":"vient","nous":"venons","vous":"venez","ils/elles":"viennent"},"past_participle":"venu"}'::jsonb,
 '/və.niʁ/','A1','{"verbs","movement"}',8,
 '[{"fr":"Viens ici !","en":"Come here!"},{"fr":"D''où viens-tu ?","en":"Where do you come from?"}]'::jsonb,
 'venir de + infinitive = to have just done sth: je viens de manger.',NULL,true),

('savoir','to know (facts)','{"zh_tw":"知道"}','verb',NULL,NULL,
 '{"present":{"je":"sais","tu":"sais","il/elle":"sait","nous":"savons","vous":"savez","ils/elles":"savent"},"past_participle":"su"}'::jsonb,
 '/sa.vwaʁ/','A1','{"verbs","knowledge"}',9,
 '[{"fr":"Je sais parler français.","en":"I know how to speak French."},{"fr":"Tu sais la réponse ?","en":"Do you know the answer?"}]'::jsonb,
 'savoir vs connaître: savoir = know facts/how to; connaître = know people/places.',NULL,true),

('vouloir','to want','{"zh_tw":"想要"}','verb',NULL,NULL,
 '{"present":{"je":"veux","tu":"veux","il/elle":"veut","nous":"voulons","vous":"voulez","ils/elles":"veulent"},"conditional":{"je":"voudrais"},"past_participle":"voulu"}'::jsonb,
 '/vu.lwaʁ/','A1','{"verbs","modal","desires"}',10,
 '[{"fr":"Je voudrais un café.","en":"I would like a coffee."},{"fr":"Que veux-tu ?","en":"What do you want?"}]'::jsonb,
 'Use conditional voudrais for polite requests. Je veux sounds demanding.','Will = vouloir',true),

('parler','to speak / to talk','{"zh_tw":"說話／講"}','verb',NULL,NULL,
 '{"present":{"je":"parle","tu":"parles","il/elle":"parle","nous":"parlons","vous":"parlez","ils/elles":"parlent"},"past_participle":"parlé"}'::jsonb,
 '/paʁ.le/','A1','{"verbs","communication"}',11,
 '[{"fr":"Je parle français.","en":"I speak French."},{"fr":"Parle moins vite !","en":"Speak more slowly!"}]'::jsonb,
 'Model -er verb — the pattern all regular -er verbs follow.',NULL,true),

('prendre','to take','{"zh_tw":"拿／搭乘"}','verb',NULL,NULL,
 '{"present":{"je":"prends","tu":"prends","il/elle":"prend","nous":"prenons","vous":"prenez","ils/elles":"prennent"},"past_participle":"pris"}'::jsonb,
 '/pʁɑ̃dʁ/','A1','{"verbs","movement"}',12,
 '[{"fr":"Je prends le bus.","en":"I take the bus."},{"fr":"Prends ton manteau.","en":"Take your coat."}]'::jsonb,
 'Also: comprendre (to understand), apprendre (to learn).',NULL,true),

('donner','to give','{"zh_tw":"給予"}','verb',NULL,NULL,
 '{"present":{"je":"donne","tu":"donnes","il/elle":"donne","nous":"donnons","vous":"donnez","ils/elles":"donnent"},"past_participle":"donné"}'::jsonb,
 '/dɔ.ne/','A1','{"verbs"}',13,
 '[{"fr":"Donne-moi ton numéro.","en":"Give me your number."},{"fr":"Il donne un cadeau.","en":"He gives a gift."}]'::jsonb,
 NULL,NULL,true),

('trouver','to find','{"zh_tw":"找到／認為"}','verb',NULL,NULL,
 '{"present":{"je":"trouve","tu":"trouves","il/elle":"trouve","nous":"trouvons","vous":"trouvez","ils/elles":"trouvent"},"past_participle":"trouvé"}'::jsonb,
 '/tʁu.ve/','A1','{"verbs"}',14,
 '[{"fr":"Je ne trouve pas mes clés.","en":"I can''t find my keys."},{"fr":"Je trouve ça bien.","en":"I think that''s good."}]'::jsonb,
 'trouver que = to think/find that. Trouver has two meanings: find + consider.',NULL,true),

('mettre','to put / to place','{"zh_tw":"放置"}','verb',NULL,NULL,
 '{"present":{"je":"mets","tu":"mets","il/elle":"met","nous":"mettons","vous":"mettez","ils/elles":"mettent"},"past_participle":"mis"}'::jsonb,
 '/mɛtʁ/','A1','{"verbs"}',15,
 '[{"fr":"Mets ton manteau.","en":"Put on your coat."},{"fr":"Elle met la table.","en":"She sets the table."}]'::jsonb,
 'mettre la table = set the table; se mettre à = to start doing.',NULL,true),

-- Nouns A1
('homme','man','{"zh_tw":"男人"}','noun','masculine','hommes',NULL,'/ɔm/','A1','{"people","daily_life"}',20,
 '[{"fr":"Un homme marche dans la rue.","en":"A man walks in the street."},{"fr":"Les droits de l''homme.","en":"Human rights."}]'::jsonb,
 'Also means human being. droits de l''homme = human rights.','homme → human',true),

('femme','woman / wife','{"zh_tw":"女人／妻子"}','noun','feminine','femmes',NULL,'/fam/','A1','{"people","family"}',21,
 '[{"fr":"Ma femme est médecin.","en":"My wife is a doctor."},{"fr":"Une femme courageuse.","en":"A courageous woman."}]'::jsonb,
 'femme can mean both woman and wife depending on context.',NULL,true),

('enfant','child','{"zh_tw":"孩子"}','noun',NULL,'enfants',NULL,'/ɑ̃.fɑ̃/','A1','{"family","people"}',22,
 '[{"fr":"Les enfants jouent dans le parc.","en":"The children play in the park."}]'::jsonb,
 'Can be masculine or feminine depending on child''s gender.',NULL,true),

('jour','day','{"zh_tw":"天／白天"}','noun','masculine','jours',NULL,'/ʒuʁ/','A1','{"time","daily_life"}',23,
 '[{"fr":"Bon jour !","en":"Good day!"},{"fr":"Le jour se lève.","en":"Day is breaking."}]'::jsonb,
 'jour = daytime; journée = the whole day (duration). Both mean day.',NULL,true),

('année','year','{"zh_tw":"年"}','noun','feminine','années',NULL,'/a.ne/','A1','{"time"}',24,
 '[{"fr":"Bonne année !","en":"Happy New Year!"},{"fr":"Cette année est difficile.","en":"This year is difficult."}]'::jsonb,
 'année (duration) vs an (point in time): j''ai 20 ans, depuis deux années.',NULL,true),

('temps','time / weather','{"zh_tw":"時間／天氣"}','noun','masculine',NULL,NULL,'/tɑ̃/','A1','{"time","weather"}',25,
 '[{"fr":"Je n''ai pas le temps.","en":"I don''t have time."},{"fr":"Quel temps fait-il ?","en":"What''s the weather like?"}]'::jsonb,
 'Two main meanings: time and weather. Context always makes it clear.','temps = tempo = time',true),

('vie','life','{"zh_tw":"生命／生活"}','noun','feminine','vies',NULL,'/vi/','A1','{"abstract","daily_life"}',26,
 '[{"fr":"La vie est belle.","en":"Life is beautiful."},{"fr":"Il mène une bonne vie.","en":"He leads a good life."}]'::jsonb,
 'vie = life (in general); biographie = biography.',NULL,true),

('main','hand','{"zh_tw":"手"}','noun','feminine','mains',NULL,'/mɛ̃/','A1','{"body"}',27,
 '[{"fr":"Donnez-moi la main.","en":"Hold my hand."},{"fr":"Il lève la main.","en":"He raises his hand."}]'::jsonb,
 NULL,NULL,true),

('tête','head','{"zh_tw":"頭"}','noun','feminine','têtes',NULL,'/tɛt/','A1','{"body"}',28,
 '[{"fr":"J''ai mal à la tête.","en":"I have a headache."},{"fr":"Hochement de tête.","en":"A nod."}]'::jsonb,
 'en tête = in the lead; tête-à-tête = face to face.','tête → top, head',true),

('maison','house / home','{"zh_tw":"房子／家"}','noun','feminine','maisons',NULL,'/mɛ.zɔ̃/','A1','{"housing","daily_life"}',29,
 '[{"fr":"Ma maison est grande.","en":"My house is big."},{"fr":"Je rentre à la maison.","en":"I am going home."}]'::jsonb,
 'à la maison = at home. More physical than chez moi.','mansion comes from maison',true),

('pays','country','{"zh_tw":"國家"}','noun','masculine','pays',NULL,'/pe.i/','A1','{"geography"}',30,
 '[{"fr":"La France est un beau pays.","en":"France is a beautiful country."},{"fr":"De quel pays viens-tu ?","en":"Which country are you from?"}]'::jsonb,
 'Same form in singular and plural.','pays = pays (payment area → territory)',true),

('monde','world / people','{"zh_tw":"世界／人們"}','noun','masculine',NULL,NULL,'/mɔ̃d/','A1','{"abstract","geography"}',31,
 '[{"fr":"Le monde entier.","en":"The whole world."},{"fr":"Tout le monde est là.","en":"Everyone is here."}]'::jsonb,
 'tout le monde = everyone (literally: all the world). Very common.','monde → mundane = of the world',true),

-- Adjectives A1
('bon','good','{"zh_tw":"好的"}','adjective',NULL,NULL,NULL,'/bɔ̃/','A1','{"description","quality"}',32,
 '[{"fr":"C''est un bon livre.","en":"It''s a good book."},{"fr":"Bon courage !","en":"Good luck! / Hang in there!"}]'::jsonb,
 'bon (m) / bonne (f) / bons (mpl) / bonnes (fpl). Irregular forms.',NULL,true),

('grand','big / tall / great','{"zh_tw":"大的／高的"}','adjective',NULL,NULL,NULL,'/ɡʁɑ̃/','A1','{"description","size"}',33,
 '[{"fr":"Un grand homme.","en":"A great man."},{"fr":"Elle est très grande.","en":"She is very tall."}]'::jsonb,
 'Grand can mean big, tall, or great depending on context. Placed before noun.',NULL,true),

('petit','small / little','{"zh_tw":"小的"}','adjective',NULL,NULL,NULL,'/pə.ti/','A1','{"description","size"}',34,
 '[{"fr":"Un petit chat.","en":"A little cat."},{"fr":"Attends une petite minute.","en":"Wait a little minute."}]'::jsonb,
 'petit (m) / petite (f). Placed before noun like grand.',NULL,true),

('nouveau','new','{"zh_tw":"新的"}','adjective',NULL,NULL,NULL,'/nu.vo/','A1','{"description"}',35,
 '[{"fr":"Un nouveau départ.","en":"A new start."},{"fr":"C''est tout nouveau.","en":"It''s brand new."}]'::jsonb,
 'nouveau (m) / nouvelle (f) / nouveaux (mpl). nouvel before masc vowel.',NULL,true),

('vieux','old','{"zh_tw":"舊的／老的"}','adjective',NULL,NULL,NULL,'/vjø/','A1','{"description","age"}',36,
 '[{"fr":"Un vieux monsieur.","en":"An old gentleman."},{"fr":"C''est une vieille histoire.","en":"It''s an old story."}]'::jsonb,
 'vieux (m) / vieille (f) / vieux (mpl). vieil before masc vowel.','vieux → vintage = old wine',true),

('premier','first','{"zh_tw":"第一的"}','adjective',NULL,NULL,NULL,'/pʁə.mje/','A1','{"ordinal","time"}',37,
 '[{"fr":"Le premier étage.","en":"The first floor."},{"fr":"C''est la première fois.","en":"It''s the first time."}]'::jsonb,
 'Placed before the noun. premier (m) / première (f).',NULL,true),

('dernier','last / latest','{"zh_tw":"最後的／最近的"}','adjective',NULL,NULL,NULL,'/dɛʁ.nje/','A1','{"ordinal","time"}',38,
 '[{"fr":"Le dernier train.","en":"The last train."},{"fr":"La semaine dernière.","en":"Last week."}]'::jsonb,
 'When after noun: la semaine dernière (last [past] week). When before: the very last.',NULL,true),

('même','same / even','{"zh_tw":"相同的／甚至"}','adjective',NULL,NULL,NULL,'/mɛm/','A1','{"description","connectors"}',39,
 '[{"fr":"C''est la même chose.","en":"It''s the same thing."},{"fr":"Même lui ne sait pas.","en":"Even he doesn''t know."}]'::jsonb,
 'moi-même = myself; quand même = all the same / anyway.',NULL,true),

-- Adverbs A1
('très','very','{"zh_tw":"非常"}','adverb',NULL,NULL,NULL,'/tʁɛ/','A1','{"intensifiers"}',40,
 '[{"fr":"Je suis très content.","en":"I am very happy."},{"fr":"C''est très bien.","en":"That''s very good."}]'::jsonb,
 NULL,NULL,true),

('bien','well / good','{"zh_tw":"好地／很好"}','adverb',NULL,NULL,NULL,'/bjɛ̃/','A1','{"intensifiers","quality"}',41,
 '[{"fr":"Je vais bien, merci.","en":"I''m well, thank you."},{"fr":"C''est bien fait.","en":"It''s well done."}]'::jsonb,
 'bien as adverb vs bon as adjective: il chante bien (adv) / c''est un bon chanteur (adj).',NULL,true),

('aussi','also / too','{"zh_tw":"也／同樣地"}','adverb',NULL,NULL,NULL,'/o.si/','A1','{"connectors"}',42,
 '[{"fr":"Moi aussi.","en":"Me too."},{"fr":"Elle est aussi grande que lui.","en":"She is as tall as him."}]'::jsonb,
 'aussi ... que = as ... as (comparison).',NULL,true),

('plus','more / no more','{"zh_tw":"更多／不再"}','adverb',NULL,NULL,NULL,'/ply(s)/','A1','{"intensifiers","comparison"}',43,
 '[{"fr":"Il est plus grand.","en":"He is taller."},{"fr":"Je ne mange plus de viande.","en":"I no longer eat meat."}]'::jsonb,
 'ne ... plus = no more/no longer. Plus final s: silent in comparisons, pronounced alone.',NULL,true),

('maintenant','now','{"zh_tw":"現在"}','adverb',NULL,NULL,NULL,'/mɛ̃.tə.nɑ̃/','A1','{"time"}',44,
 '[{"fr":"Viens maintenant.","en":"Come now."},{"fr":"Qu''est-ce que tu fais maintenant ?","en":"What are you doing now?"}]'::jsonb,
 NULL,NULL,true),

('toujours','always / still','{"zh_tw":"總是／仍然"}','adverb',NULL,NULL,NULL,'/tu.ʒuʁ/','A1','{"frequency","time"}',45,
 '[{"fr":"Il est toujours en retard.","en":"He is always late."},{"fr":"Tu l''aimes toujours ?","en":"Do you still love him?"}]'::jsonb,
 'Two meanings: always (frequency) or still (duration). Context decides.',NULL,true),

('jamais','never','{"zh_tw":"從不"}','adverb',NULL,NULL,NULL,'/ʒa.mɛ/','A1','{"frequency"}',46,
 '[{"fr":"Je ne mens jamais.","en":"I never lie."},{"fr":"C''est le plus beau jamais vu.","en":"It''s the most beautiful ever seen."}]'::jsonb,
 'ne ... jamais = never. Without ne (in questions): ever: avez-vous jamais visité Paris?',NULL,true),

-- ═══════════════════════════════════════════════════════════
-- A2  (Rank 501–2000)
-- ═══════════════════════════════════════════════════════════

('comprendre','to understand','{"zh_tw":"理解"}','verb',NULL,NULL,
 '{"present":{"je":"comprends","tu":"comprends","il/elle":"comprend","nous":"comprenons","vous":"comprenez","ils/elles":"comprennent"},"past_participle":"compris"}'::jsonb,
 '/kɔ̃.pʁɑ̃dʁ/','A2','{"verbs","knowledge"}',502,
 '[{"fr":"Je ne comprends pas.","en":"I don''t understand."},{"fr":"Il comprend vite.","en":"He understands quickly."}]'::jsonb,
 'Built from prendre. Also: se comprendre = to understand each other.','comprend → comprehend',true),

('partir','to leave / to go away','{"zh_tw":"出發／離開"}','verb',NULL,NULL,
 '{"present":{"je":"pars","tu":"pars","il/elle":"part","nous":"partons","vous":"partez","ils/elles":"partent"},"past_participle":"parti"}'::jsonb,
 '/paʁ.tiʁ/','A2','{"verbs","movement"}',503,
 '[{"fr":"Le train part à 8h.","en":"The train leaves at 8."},{"fr":"À partir de demain.","en":"From tomorrow onwards."}]'::jsonb,
 'à partir de = from (time). Conjugated with être in passé composé.',NULL,true),

('tenir','to hold / to keep','{"zh_tw":"握住／保持"}','verb',NULL,NULL,
 '{"present":{"je":"tiens","tu":"tiens","il/elle":"tient","nous":"tenons","vous":"tenez","ils/elles":"tiennent"},"past_participle":"tenu"}'::jsonb,
 '/tə.niʁ/','A2','{"verbs"}',504,
 '[{"fr":"Tiens la porte.","en":"Hold the door."},{"fr":"Tenir parole.","en":"To keep one''s word."}]'::jsonb,
 'tenir à = to care about; se tenir = to stand/behave.',NULL,true),

('rester','to stay / to remain','{"zh_tw":"留下／保持"}','verb',NULL,NULL,
 '{"present":{"je":"reste","tu":"restes","il/elle":"reste","nous":"restons","vous":"restez","ils/elles":"restent"},"past_participle":"resté"}'::jsonb,
 '/ʁɛs.te/','A2','{"verbs","movement"}',505,
 '[{"fr":"Je reste à la maison.","en":"I''m staying at home."},{"fr":"Il reste calme.","en":"He remains calm."}]'::jsonb,
 'Conjugated with être in passé composé.',NULL,true),

('passer','to pass / to spend (time)','{"zh_tw":"經過／度過"}','verb',NULL,NULL,
 '{"present":{"je":"passe","tu":"passes","il/elle":"passe","nous":"passons","vous":"passez","ils/elles":"passent"},"past_participle":"passé"}'::jsonb,
 '/pa.se/','A2','{"verbs","time"}',506,
 '[{"fr":"Le temps passe vite.","en":"Time passes quickly."},{"fr":"J''ai passé une bonne nuit.","en":"I had a good night."}]'::jsonb,
 'passer du bon temps = to have a good time; passer un examen = to take an exam.',NULL,true),

('demander','to ask / to request','{"zh_tw":"詢問／要求"}','verb',NULL,NULL,
 '{"present":{"je":"demande","tu":"demandes","il/elle":"demande","nous":"demandons","vous":"demandez","ils/elles":"demandent"},"past_participle":"demandé"}'::jsonb,
 '/də.mɑ̃.de/','A2','{"verbs","communication"}',507,
 '[{"fr":"Je vous demande pardon.","en":"I beg your pardon."},{"fr":"Elle demande de l''aide.","en":"She asks for help."}]'::jsonb,
 NULL,'demand = demander',true),

('penser','to think','{"zh_tw":"思考／認為"}','verb',NULL,NULL,
 '{"present":{"je":"pense","tu":"penses","il/elle":"pense","nous":"pensons","vous":"pensez","ils/elles":"pensent"},"past_participle":"pensé"}'::jsonb,
 '/pɑ̃.se/','A2','{"verbs","thought"}',508,
 '[{"fr":"Je pense que oui.","en":"I think so."},{"fr":"À quoi penses-tu ?","en":"What are you thinking about?"}]'::jsonb,
 'penser à = to think about; penser de = to think of (opinion).',NULL,true),

('connaître','to know (people/places)','{"zh_tw":"認識／了解"}','verb',NULL,NULL,
 '{"present":{"je":"connais","tu":"connais","il/elle":"connaît","nous":"connaissons","vous":"connaissez","ils/elles":"connaissent"},"past_participle":"connu"}'::jsonb,
 '/kɔ.nɛtʁ/','A2','{"verbs","knowledge"}',509,
 '[{"fr":"Je connais Paris.","en":"I know Paris."},{"fr":"Tu connais cette chanson ?","en":"Do you know this song?"}]'::jsonb,
 'connaître = know (people/places); savoir = know (facts/how to).',NULL,true),

('montrer','to show','{"zh_tw":"展示"}','verb',NULL,NULL,NULL,'/mɔ̃.tʁe/','A2','{"verbs","communication"}',510,
 '[{"fr":"Montre-moi ton dessin.","en":"Show me your drawing."},{"fr":"Les chiffres montrent que...","en":"The figures show that..."}]'::jsonb,
 NULL,NULL,true),

('suivre','to follow','{"zh_tw":"跟隨"}','verb',NULL,NULL,
 '{"present":{"je":"suis","tu":"suis","il/elle":"suit","nous":"suivons","vous":"suivez","ils/elles":"suivent"},"past_participle":"suivi"}'::jsonb,
 '/sɥivʁ/','A2','{"verbs","movement"}',511,
 '[{"fr":"Suis-moi !","en":"Follow me!"},{"fr":"Je suis un cours de français.","en":"I am taking a French class."}]'::jsonb,
 'suivre un cours = to take a class. Warning: je suis = I am (être) AND I follow (suivre).',NULL,true),

-- Nouns A2
('question','question','{"zh_tw":"問題"}','noun','feminine','questions',NULL,'/kɛs.tjɔ̃/','A2','{"communication","education"}',520,
 '[{"fr":"Bonne question !","en":"Good question!"},{"fr":"C''est une question de temps.","en":"It''s a matter of time."}]'::jsonb,
 'poser une question = to ask a question. question de = a matter of.',NULL,true),

('moment','moment','{"zh_tw":"時刻／當下"}','noun','masculine','moments',NULL,'/mɔ.mɑ̃/','A2','{"time"}',521,
 '[{"fr":"Au bon moment.","en":"At the right moment."},{"fr":"Pour le moment.","en":"For now."}]'::jsonb,
 'en ce moment = right now; au moment où = at the moment when.',NULL,true),

('travail','work / job','{"zh_tw":"工作"}','noun','masculine','travaux',NULL,'/tʁa.vaj/','A2','{"work","daily_life"}',522,
 '[{"fr":"J''ai beaucoup de travail.","en":"I have a lot of work."},{"fr":"Les travaux sont en cours.","en":"The work is in progress."}]'::jsonb,
 'travail (job/work) vs travaux (construction works, plural). Irregular plural.',NULL,true),

('heure','hour / time (clock)','{"zh_tw":"小時／時間"}','noun','feminine','heures',NULL,'/œʁ/','A2','{"time"}',523,
 '[{"fr":"Il est deux heures.","en":"It is two o''clock."},{"fr":"À tout à l''heure.","en":"See you later."}]'::jsonb,
 'quelle heure est-il ? = what time is it? à l''heure = on time.',NULL,true),

('quartier','neighbourhood / district','{"zh_tw":"街區／地區"}','noun','masculine','quartiers',NULL,'/kaʁ.tje/','A2','{"city","housing"}',524,
 '[{"fr":"J''habite dans un quartier calme.","en":"I live in a quiet neighbourhood."},{"fr":"Le Quartier Latin.","en":"The Latin Quarter."}]'::jsonb,
 'un quart = a quarter. Quartier is a quarter of a city.','quarter → quartier',true),

('famille','family','{"zh_tw":"家庭"}','noun','feminine','familles',NULL,'/fa.mij/','A2','{"family","social"}',525,
 '[{"fr":"Ma famille est grande.","en":"My family is large."},{"fr":"En famille.","en":"With family."}]'::jsonb,
 NULL,'family = famille',true),

('ami','friend','{"zh_tw":"朋友"}','noun','masculine','amis',NULL,'/a.mi/','A2','{"social","people"}',526,
 '[{"fr":"Mon meilleur ami.","en":"My best friend."},{"fr":"Amis pour la vie.","en":"Friends for life."}]'::jsonb,
 'ami (m) / amie (f). copain/copine is more informal.',NULL,true),

('problème','problem','{"zh_tw":"問題／困難"}','noun','masculine','problèmes',NULL,'/pʁɔ.blɛm/','A2','{"abstract"}',527,
 '[{"fr":"Pas de problème !","en":"No problem!"},{"fr":"C''est un gros problème.","en":"It''s a big problem."}]'::jsonb,
 NULL,'problem → problème',true),

('argent','money / silver','{"zh_tw":"錢／銀"}','noun','masculine',NULL,NULL,'/aʁ.ʒɑ̃/','A2','{"money","materials"}',528,
 '[{"fr":"Je n''ai pas d''argent.","en":"I have no money."},{"fr":"Une bague en argent.","en":"A silver ring."}]'::jsonb,
 'Two meanings: money and silver. Context always clarifies.','argent → argenté (silver-coloured)',true),

-- ═══════════════════════════════════════════════════════════
-- B1  (Rank 2001–5000)
-- ═══════════════════════════════════════════════════════════

('atteindre','to reach / to attain','{"zh_tw":"達到／抵達"}','verb',NULL,NULL,
 '{"present":{"je":"atteins","tu":"atteins","il/elle":"atteint","nous":"atteignons","vous":"atteignez","ils/elles":"atteignent"},"past_participle":"atteint"}'::jsonb,
 '/a.tɛ̃dʁ/','B1','{"verbs","achievement"}',2001,
 '[{"fr":"Atteindre son objectif.","en":"To reach one''s goal."},{"fr":"Le feu a atteint la forêt.","en":"The fire reached the forest."}]'::jsonb,
 NULL,NULL,true),

('permettre','to allow / to permit','{"zh_tw":"允許"}','verb',NULL,NULL,
 '{"present":{"je":"permets","tu":"permets","il/elle":"permet","nous":"permettons","vous":"permettez","ils/elles":"permettent"},"past_participle":"permis"}'::jsonb,
 '/pɛʁ.mɛtʁ/','B1','{"verbs","social"}',2002,
 '[{"fr":"La loi ne le permet pas.","en":"The law doesn''t allow it."},{"fr":"Permettez-moi de vous présenter.","en":"Allow me to introduce."}]'::jsonb,
 NULL,'permit → permettre',true),

('réussir','to succeed / to pass','{"zh_tw":"成功／通過考試"}','verb',NULL,NULL,
 '{"present":{"je":"réussis","tu":"réussis","il/elle":"réussit","nous":"réussissons","vous":"réussissez","ils/elles":"réussissent"},"past_participle":"réussi"}'::jsonb,
 '/ʁe.y.siʁ/','B1','{"verbs","achievement"}',2003,
 '[{"fr":"Elle a réussi son examen.","en":"She passed her exam."},{"fr":"Il réussit dans la vie.","en":"He succeeds in life."}]'::jsonb,
 'réussir à + infinitive = to manage to. -ir verb conjugation.',NULL,true),

('obtenir','to obtain / to get','{"zh_tw":"獲得"}','verb',NULL,NULL,
 '{"present":{"je":"obtiens","tu":"obtiens","il/elle":"obtient","nous":"obtenons","vous":"obtenez","ils/elles":"obtiennent"},"past_participle":"obtenu"}'::jsonb,
 '/ɔb.tə.niʁ/','B1','{"verbs","achievement"}',2004,
 '[{"fr":"Obtenir un diplôme.","en":"To obtain a diploma."},{"fr":"J''ai obtenu ce poste.","en":"I got this position."}]'::jsonb,
 NULL,'obtain → obtenir',true),

('proposer','to propose / to suggest','{"zh_tw":"提議／建議"}','verb',NULL,NULL,NULL,'/pʁɔ.po.ze/','B1','{"verbs","communication"}',2005,
 '[{"fr":"Je vous propose une solution.","en":"I suggest a solution to you."},{"fr":"Il lui a proposé le mariage.","en":"He proposed marriage to her."}]'::jsonb,
 NULL,NULL,true),

('améliorer','to improve','{"zh_tw":"改善／提升"}','verb',NULL,NULL,NULL,'/a.me.ljɔ.ʁe/','B1','{"verbs","quality"}',2010,
 '[{"fr":"Améliorer son niveau de français.","en":"To improve one''s French level."},{"fr":"La situation s''est améliorée.","en":"The situation improved."}]'::jsonb,
 NULL,NULL,true),

('augmenter','to increase / to raise','{"zh_tw":"增加／提高"}','verb',NULL,NULL,NULL,'/oɡ.mɑ̃.te/','B1','{"verbs","change"}',2011,
 '[{"fr":"Les prix ont augmenté.","en":"Prices have increased."},{"fr":"Augmenter son salaire.","en":"To raise one''s salary."}]'::jsonb,
 NULL,'augment → augmenter',true),

('choisir','to choose','{"zh_tw":"選擇"}','verb',NULL,NULL,
 '{"present":{"je":"choisis","tu":"choisis","il/elle":"choisit","nous":"choisissons","vous":"choisissez","ils/elles":"choisissent"},"past_participle":"choisi"}'::jsonb,
 '/ʃwa.ziʁ/','B1','{"verbs","decision"}',2012,
 '[{"fr":"Choisis ce qui te plaît.","en":"Choose what you like."},{"fr":"Difficile à choisir !","en":"Difficult to choose!"}]'::jsonb,
 'Regular -ir verb (-issons pattern). choix (noun) = choice.',NULL,true),

-- Nouns B1
('société','society / company','{"zh_tw":"社會／公司"}','noun','feminine','sociétés',NULL,'/sɔ.sje.te/','B1','{"social","work","abstract"}',2020,
 '[{"fr":"La société moderne.","en":"Modern society."},{"fr":"Une société anonyme.","en":"A limited company."}]'::jsonb,
 'Two meanings: society (social) and company (business). Société anonyme = S.A. = Ltd.',NULL,true),

('politique','politics / policy','{"zh_tw":"政治／政策"}','noun','feminine','politiques',NULL,'/pɔ.li.tik/','B1','{"politics","abstract"}',2021,
 '[{"fr":"La politique française.","en":"French politics."},{"fr":"Une politique de santé.","en":"A health policy."}]'::jsonb,
 'Also adjective: un accord politique = a political agreement.',NULL,true),

('exemple','example','{"zh_tw":"例子"}','noun','masculine','exemples',NULL,'/ɛɡ.zɑ̃pl/','B1','{"education","language"}',2022,
 '[{"fr":"Par exemple.","en":"For example."},{"fr":"Donne-moi un exemple.","en":"Give me an example."}]'::jsonb,
 'par exemple = for example (never *pour exemple).',NULL,true),

('résultat','result','{"zh_tw":"結果"}','noun','masculine','résultats',NULL,'/ʁe.zyl.ta/','B1','{"abstract","education"}',2023,
 '[{"fr":"Les résultats des élections.","en":"The election results."},{"fr":"Quel est le résultat ?","en":"What is the result?"}]'::jsonb,
 NULL,'result → résultat',true),

('cependant','however / nevertheless','{"zh_tw":"然而／不過"}','adverb',NULL,NULL,NULL,'/sə.pɑ̃.dɑ̃/','B1','{"connectors","formal_writing"}',2030,
 '[{"fr":"Il est intelligent ; cependant il manque d''expérience.","en":"He is intelligent; however he lacks experience."}]'::jsonb,
 'More formal than mais. Synonyms: toutefois, néanmoins, pourtant.','ce + pendant (during) → while this is true, however…',true),

('pourtant','yet / even so','{"zh_tw":"然而／儘管如此"}','adverb',NULL,NULL,NULL,'/puʁ.tɑ̃/','B1','{"connectors"}',2031,
 '[{"fr":"Il n''a pas étudié et pourtant il a réussi.","en":"He didn''t study and yet he passed."}]'::jsonb,
 'Often expresses surprise or contradiction. More emphatic than cependant.','pour + tant (so much) → for all that = yet',true),

('désormais','from now on / henceforth','{"zh_tw":"從今以後"}','adverb',NULL,NULL,NULL,'/de.zɔʁ.mɛ/','B1','{"time","connectors"}',2032,
 '[{"fr":"Désormais, je ferai attention.","en":"From now on, I will be careful."},{"fr":"C''est désormais possible.","en":"It is now possible."}]'::jsonb,
 'Slightly formal but common in spoken French too.',NULL,true),

('davantage','more / further','{"zh_tw":"更多"}','adverb',NULL,NULL,NULL,'/da.vɑ̃.taʒ/','B1','{"intensifiers","comparison"}',2033,
 '[{"fr":"Il faut travailler davantage.","en":"We must work more."},{"fr":"Je n''en veux pas davantage.","en":"I don''t want any more of it."}]'::jsonb,
 'More formal than plus. Never davantage que (use plus que for comparison).',NULL,true),

-- ═══════════════════════════════════════════════════════════
-- B2  (Rank 5001–10000)
-- ═══════════════════════════════════════════════════════════

('s''avérer','to turn out / to prove to be','{"zh_tw":"證明是／結果是"}','verb',NULL,NULL,NULL,'/s‿a.ve.ʁe/','B2','{"verbs","formal"}',5001,
 '[{"fr":"La tâche s''est avérée difficile.","en":"The task turned out to be difficult."},{"fr":"Cela s''avère nécessaire.","en":"This proves to be necessary."}]'::jsonb,
 'Always reflexive. Followed by adjective: s''avérer + adj.',NULL,true),

('renoncer','to give up / to renounce','{"zh_tw":"放棄／放棄"}','verb',NULL,NULL,NULL,'/ʁə.nɔ̃.se/','B2','{"verbs","decision"}',5002,
 '[{"fr":"Il a renoncé à son projet.","en":"He gave up his project."},{"fr":"Renoncer à ses droits.","en":"To renounce one''s rights."}]'::jsonb,
 'renoncer à qqch = to give up sth. Takes à before infinitive.',NULL,true),

('subvention','subsidy / grant','{"zh_tw":"補貼／補助金"}','noun','feminine','subventions',NULL,'/syb.vɑ̃.sjɔ̃/','B2','{"economics","politics","formal"}',5010,
 '[{"fr":"Le gouvernement accorde des subventions.","en":"The government grants subsidies."},{"fr":"Une subvention européenne.","en":"A European grant."}]'::jsonb,
 'Verb: subventionner. Cognate with English subvention.','sub + venir → money that comes underneath to support',true),

('enjeu','stake / issue at stake','{"zh_tw":"賭注／關鍵議題"}','noun','masculine','enjeux',NULL,'/ɑ̃.ʒø/','B2','{"abstract","politics","formal"}',5011,
 '[{"fr":"Les enjeux de cette élection sont considérables.","en":"The stakes of this election are considerable."},{"fr":"Un enjeu majeur.","en":"A major issue."}]'::jsonb,
 'From en jeu = in play/at stake. Very common in formal discourse.','en jeu → at stake → enjeu',true),

('atout','asset / trump card','{"zh_tw":"優勢／王牌"}','noun','masculine','atouts',NULL,'/a.tu/','B2','{"abstract","business"}',5012,
 '[{"fr":"C''est un atout majeur.","en":"It''s a major asset."},{"fr":"Son atout, c''est son sourire.","en":"His trump card is his smile."}]'::jsonb,
 'From card game trump. Widely used in professional contexts.',NULL,true),

('lacune','gap / lacuna / shortcoming','{"zh_tw":"缺陷／不足"}','noun','feminine','lacunes',NULL,'/la.kyn/','B2','{"abstract","education"}',5013,
 '[{"fr":"Il a des lacunes en maths.","en":"He has gaps in his maths."},{"fr":"Combler les lacunes.","en":"To fill the gaps."}]'::jsonb,
 NULL,'lacuna → lacune = gap',true),

('démarche','approach / steps / walk','{"zh_tw":"步驟／方法"}','noun','feminine','démarches',NULL,'/de.maʁʃ/','B2','{"abstract","process"}',5014,
 '[{"fr":"Faire les démarches administratives.","en":"To go through administrative procedures."},{"fr":"Une démarche innovante.","en":"An innovative approach."}]'::jsonb,
 'Can mean: way of walking, administrative steps, or intellectual approach.',NULL,true),

('biais','bias / slant / means','{"zh_tw":"偏見／途徑"}','noun','masculine',NULL,NULL,'/bjɛ/','B2','{"abstract","formal"}',5015,
 '[{"fr":"Par le biais de la technologie.","en":"Through technology."},{"fr":"Un biais cognitif.","en":"A cognitive bias."}]'::jsonb,
 'par le biais de = through/via (formal alternative to par). Also: cognitive bias.',NULL,true),

('néanmoins','nonetheless / nevertheless','{"zh_tw":"儘管如此"}','adverb',NULL,NULL,NULL,'/ne.ɑ̃.mwɛ̃/','B2','{"connectors","formal_writing"}',5020,
 '[{"fr":"C''est cher, néanmoins cela vaut la peine.","en":"It''s expensive; nonetheless it''s worth it."}]'::jsonb,
 'Synonym of cependant, toutefois. Exclusively written/formal French.','ne + en + moins = not any less',true),

('toutefois','however / yet / nonetheless','{"zh_tw":"然而"}','adverb',NULL,NULL,NULL,'/tut.fwa/','B2','{"connectors","formal_writing"}',5021,
 '[{"fr":"Il est compétent ; toutefois il manque de confiance.","en":"He is competent; however he lacks confidence."}]'::jsonb,
 'Formal synonym of cependant. Common in academic/business writing.','toute + fois = every time → in every case → yet',true),

-- ═══════════════════════════════════════════════════════════
-- C1  (Rank 10001–15000)
-- ═══════════════════════════════════════════════════════════

('épanouissement','fulfilment / self-actualization','{"zh_tw":"自我實現／開花結果"}','noun','masculine',NULL,NULL,'/e.pa.nwis.mɑ̃/','C1','{"psychology","philosophy","abstract"}',10001,
 '[{"fr":"L''épanouissement personnel est essentiel.","en":"Personal fulfilment is essential."},{"fr":"Elle a trouvé son épanouissement dans l''art.","en":"She found her fulfilment in art."}]'::jsonb,
 'From s''épanouir (to blossom). Common in psychology and HR contexts.','épanouir = to blossom like a flower opening',true),

('équivoque','ambiguous / equivocal','{"zh_tw":"模棱兩可的"}','adjective',NULL,NULL,NULL,'/e.ki.vɔk/','C1','{"description","language","formal"}',10002,
 '[{"fr":"Une réponse équivoque.","en":"An ambiguous answer."},{"fr":"Sa position est équivoque.","en":"His position is equivocal."}]'::jsonb,
 'Also used as noun: une équivoque = an ambiguity. Sans équivoque = unambiguous.',NULL,true),

('foisonner','to abound / to teem','{"zh_tw":"充滿／大量湧現"}','verb',NULL,NULL,NULL,'/fwa.zɔ.ne/','C1','{"verbs","formal"}',10003,
 '[{"fr":"Les idées foisonnent.","en":"Ideas abound."},{"fr":"Ce quartier foisonne de restaurants.","en":"This neighbourhood teems with restaurants."}]'::jsonb,
 'foisonner de = to be teeming with. Formal literary register.','foison = abundance → foisonner = to overflow with',true),

('circonspect','cautious / circumspect','{"zh_tw":"謹慎的"}','adjective',NULL,NULL,NULL,'/siʁ.kɔ̃.spɛkt/','C1','{"description","formal"}',10004,
 '[{"fr":"Il reste circonspect face aux nouvelles.","en":"He remains cautious about the news."},{"fr":"Une réaction circonspecte.","en":"A cautious reaction."}]'::jsonb,
 NULL,'circumspect = looking around carefully = circonspect',true),

('se délecter','to delight in / to relish','{"zh_tw":"陶醉於／品味"}','verb',NULL,NULL,NULL,'/sə de.lɛk.te/','C1','{"verbs","pleasure","formal"}',10005,
 '[{"fr":"Se délecter d''un bon repas.","en":"To relish a fine meal."},{"fr":"Elle se délecte de sa réussite.","en":"She delights in her success."}]'::jsonb,
 'Always reflexive. se délecter de + noun/infinitive.','delectation = delight → se délecter',true),

('exacerber','to exacerbate / to aggravate','{"zh_tw":"加劇／惡化"}','verb',NULL,NULL,NULL,'/ɛɡ.za.sɛʁ.be/','C1','{"verbs","formal"}',10006,
 '[{"fr":"La crise a exacerbé les tensions.","en":"The crisis exacerbated tensions."},{"fr":"Exacerber les divisions.","en":"To aggravate divisions."}]'::jsonb,
 NULL,'exacerbate = exacerber',true),

('alambiqué','convoluted / overly complex','{"zh_tw":"晦澀的／過於複雜的"}','adjective',NULL,NULL,NULL,'/a.lɑ̃.bi.ke/','C1','{"description","language"}',10007,
 '[{"fr":"Un raisonnement alambiqué.","en":"A convoluted argument."},{"fr":"Un style trop alambiqué.","en":"A too-convoluted style."}]'::jsonb,
 'From alambic (alembic, a distillation apparatus). Connotes unnecessarily tortuous speech.',NULL,true),

('quintessence','quintessence / very essence','{"zh_tw":"精髓／精華"}','noun','feminine',NULL,NULL,'/kɛ̃.tɛ.sɑ̃s/','C1','{"abstract","philosophy","formal"}',10008,
 '[{"fr":"La quintessence de la gastronomie française.","en":"The quintessence of French gastronomy."}]'::jsonb,
 'From Aristotle''s fifth element. Means the purest most perfect form of something.','quinte + essense = fifth (highest) essence',true),

-- ═══════════════════════════════════════════════════════════
-- C2  (Rank 15001+)
-- ═══════════════════════════════════════════════════════════

('nonobstant','notwithstanding / despite','{"zh_tw":"儘管"}','preposition',NULL,NULL,NULL,'/nɔ.nɔp.stɑ̃/','C2','{"legal","formal_writing"}',15001,
 '[{"fr":"Nonobstant les difficultés, le projet a abouti.","en":"Notwithstanding the difficulties, the project succeeded."}]'::jsonb,
 'Exclusively formal/legal register. Synonymous with malgré (informal), en dépit de (semi-formal).','non + obstant (to stand against) → not standing in the way',true),

('histrionique','histrionic / theatrical','{"zh_tw":"歇斯底里的／過於誇張的"}','adjective',NULL,NULL,NULL,'/is.tʁjɔ.nik/','C2','{"description","psychology","formal"}',15002,
 '[{"fr":"Un comportement histrionique.","en":"Histrionic behaviour."},{"fr":"Une réaction histrionique et disproportionnée.","en":"A histrionic and disproportionate reaction."}]'::jsonb,
 'From histrio (Roman actor). Used in psychology for personality disorder.','histrion (stage actor) → histrionique',true),

('atermoiement','procrastination / deferring','{"zh_tw":"拖延／猶豫不決"}','noun','masculine','atermoiements',NULL,'/a.tɛʁ.mwa.mɑ̃/','C2','{"abstract","formal"}',15003,
 '[{"fr":"Ses atermoiements ont coûté cher.","en":"His procrastination proved costly."},{"fr":"Assez d''atermoiements !","en":"Enough dilly-dallying!"}]'::jsonb,
 'Usually in plural. From terme (due date): repeatedly delaying past the due date.',NULL,true),

('consubstantiel','consubstantial / inherent / intrinsic','{"zh_tw":"本質上固有的"}','adjective',NULL,NULL,NULL,'/kɔ̃.sybs.tɑ̃.sjɛl/','C2','{"philosophy","theology","formal"}',15004,
 '[{"fr":"La liberté est consubstantielle à la démocratie.","en":"Freedom is inherent in democracy."}]'::jsonb,
 'From theology (the Trinity). In secular use: intrinsically linked, inseparable.',NULL,true),

('circumlocution','circumlocution / roundabout expression','{"zh_tw":"迂迴表達／繞圈子說話"}','noun','feminine','circumlocutions',NULL,'/siʁ.kym.lɔ.ky.sjɔ̃/','C2','{"language","rhetoric","formal"}',15005,
 '[{"fr":"Il s''exprime par circumlocutions.","en":"He expresses himself through circumlocutions."}]'::jsonb,
 'Using many words where few would do. Antonym: concision.',NULL,true),

('inéluctable','inescapable / inevitable','{"zh_tw":"不可避免的"}','adjective',NULL,NULL,NULL,'/i.ne.lyk.tabl/','C2','{"description","formal","philosophy"}',15006,
 '[{"fr":"La mort est inéluctable.","en":"Death is inescapable."},{"fr":"Un déclin inéluctable.","en":"An inevitable decline."}]'::jsonb,
 'Stronger and more literary than inévitable.','in + e + luctari (to struggle) → cannot be struggled out of',true),

('acrimonie','acrimony / bitterness','{"zh_tw":"尖刻／怨恨"}','noun','feminine',NULL,NULL,'/a.kʁi.mɔ.ni/','C2','{"emotion","formal"}',15007,
 '[{"fr":"Il répondit avec acrimonie.","en":"He replied with acrimony."},{"fr":"L''acrimonie du débat.","en":"The bitterness of the debate."}]'::jsonb,
 NULL,'acrid + mony → bitter sharp quality',true),

('parangon','paragon / supreme example','{"zh_tw":"典範／楷模"}','noun','masculine','parangons',NULL,'/pa.ʁɑ̃.ɡɔ̃/','C2','{"abstract","formal","literature"}',15008,
 '[{"fr":"Un parangon de vertu.","en":"A paragon of virtue."}]'::jsonb,
 'Un parangon de = the ultimate example of. Literary/elevated register.','paragon → parangon = perfect model',true)

ON CONFLICT (french_word, word_class, cefr_level) DO NOTHING;

-- ============================================================
-- Update existing entries to add zh_tw to translations JSONB
-- (for rows inserted without zh_tw by earlier migrations)
-- ============================================================

UPDATE vocabulary SET translations = translations || '{"zh_tw":"你好／早安"}'::jsonb
WHERE french_word = 'bonjour' AND translations->>'zh_tw' IS NULL;

UPDATE vocabulary SET translations = translations || '{"zh_tw":"謝謝"}'::jsonb
WHERE french_word = 'merci' AND translations->>'zh_tw' IS NULL;

UPDATE vocabulary SET translations = translations || '{"zh_tw":"房子／家"}'::jsonb
WHERE french_word = 'maison' AND translations->>'zh_tw' IS NULL;

UPDATE vocabulary SET translations = translations || '{"zh_tw":"吃"}'::jsonb
WHERE french_word = 'manger' AND translations->>'zh_tw' IS NULL;

UPDATE vocabulary SET translations = translations || '{"zh_tw":"水"}'::jsonb
WHERE french_word = 'eau' AND translations->>'zh_tw' IS NULL;

UPDATE vocabulary SET translations = translations || '{"zh_tw":"想要"}'::jsonb
WHERE french_word = 'vouloir' AND translations->>'zh_tw' IS NULL;

UPDATE vocabulary SET translations = translations || '{"zh_tw":"記得"}'::jsonb
WHERE french_word = 'se souvenir' AND translations->>'zh_tw' IS NULL;

UPDATE vocabulary SET translations = translations || '{"zh_tw":"然而"}'::jsonb
WHERE french_word = 'cependant' AND translations->>'zh_tw' IS NULL;

UPDATE vocabulary SET translations = translations || '{"zh_tw":"補貼"}'::jsonb
WHERE french_word = 'subvention' AND translations->>'zh_tw' IS NULL;

UPDATE vocabulary SET translations = translations || '{"zh_tw":"賭注／議題"}'::jsonb
WHERE french_word = 'enjeu' AND translations->>'zh_tw' IS NULL;

UPDATE vocabulary SET translations = translations || '{"zh_tw":"自我實現"}'::jsonb
WHERE french_word = 'épanouissement' AND translations->>'zh_tw' IS NULL;

UPDATE vocabulary SET translations = translations || '{"zh_tw":"儘管"}'::jsonb
WHERE french_word = 'nonobstant' AND translations->>'zh_tw' IS NULL;

UPDATE vocabulary SET translations = translations || '{"zh_tw":"開花／茁壯"}'::jsonb
WHERE french_word = 's''épanouir' AND translations->>'zh_tw' IS NULL;

UPDATE vocabulary SET translations = translations || '{"zh_tw":"然而／儘管如此"}'::jsonb
WHERE french_word = 'pourtant' AND translations->>'zh_tw' IS NULL;

UPDATE vocabulary SET translations = translations || '{"zh_tw":"街區"}'::jsonb
WHERE french_word = 'quartier' AND translations->>'zh_tw' IS NULL;
