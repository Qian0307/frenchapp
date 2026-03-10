-- ============================================================
-- French Learning App  ·  Vocabulary Seed SQL
-- (15 representative entries across A1–C2)
-- ============================================================

INSERT INTO vocabulary
  (french_word, english_trans, translations, word_class, gender, plural_form,
   pronunciation_ipa, cefr_level, topic_tags, frequency_rank,
   example_sentences, usage_notes, memory_tip)
VALUES

-- A1 ─────────────────────────────────────────────────────────

('bonjour', 'hello / good morning',
 '{"zh":"你好","es":"buenos días","de":"guten Morgen"}',
 'interjection', NULL, NULL,
 '/bɔ̃.ʒuʁ/', 'A1', ARRAY['greetings','daily_life'], 18,
 '[
   {"fr":"Bonjour, comment allez-vous ?","en":"Hello, how are you?"},
   {"fr":"Il dit bonjour à ses collègues.","en":"He says good morning to his colleagues."}
 ]',
 'Used until roughly midday; after that use "bonsoir". Never use with close friends informally — "salut" is more natural.',
 'BON (good) + JOUR (day) = good day'),

('maison', 'house / home',
 '{"zh":"房子","es":"casa","de":"Haus"}',
 'noun', 'feminine', 'maisons',
 '/mɛ.zɔ̃/', 'A1', ARRAY['housing','daily_life'], 102,
 '[
   {"fr":"Ma maison est grande.","en":"My house is big."},
   {"fr":"Je rentre à la maison.","en":"I am going home."}
 ]',
 'À la maison = at home. Compare to chez moi which is more personal.',
 'Mansion comes from maison — both mean dwelling'),

('manger', 'to eat',
 '{"zh":"吃","es":"comer","de":"essen"}',
 'verb', NULL, NULL,
 '/mɑ̃.ʒe/', 'A1', ARRAY['food','daily_life','verbs'], 145,
 '[
   {"fr":"Je mange une pomme.","en":"I eat an apple."},
   {"fr":"Qu''est-ce que tu veux manger ce soir ?","en":"What do you want to eat tonight?"}
 ]',
 'Spelling change: nous mangeons (retain e before -ons to keep soft g sound).',
 'Manger sounds like munch + jer'),

('eau', 'water',
 '{"zh":"水","es":"agua","de":"Wasser"}',
 'noun', 'feminine', 'eaux',
 '/o/', 'A1', ARRAY['food','drinks','nature'], 180,
 '[
   {"fr":"Un verre d''eau, s''il vous plaît.","en":"A glass of water, please."},
   {"fr":"L''eau de cette rivière est froide.","en":"The water in this river is cold."}
 ]',
 'Plural eaux is silent — same sound /o/. Compounds: eau-de-vie, eau minérale.',
 'Eau = O (the letter), just the sound oh'),

('merci', 'thank you',
 '{"zh":"謝謝","es":"gracias","de":"danke"}',
 'interjection', NULL, NULL,
 '/mɛʁ.si/', 'A1', ARRAY['greetings','politeness'], 55,
 '[
   {"fr":"Merci beaucoup pour votre aide.","en":"Thank you very much for your help."},
   {"fr":"Non, merci.","en":"No, thank you."}
 ]',
 'Merci alone = yes thank you; Non, merci = no thank you.',
 'Sounds like mercy — show mercy with gratitude'),

-- A2 ─────────────────────────────────────────────────────────

('vouloir', 'to want',
 '{"zh":"想要","es":"querer","de":"wollen"}',
 'verb', NULL, NULL,
 '/vu.lwaʁ/', 'A2', ARRAY['verbs','modal','desires'], 78,
 '[
   {"fr":"Je voudrais un café, s''il vous plaît.","en":"I would like a coffee, please."},
   {"fr":"Qu''est-ce que tu veux faire ?","en":"What do you want to do?"}
 ]',
 'Use conditional voudrais for polite requests. Je veux sounds demanding.',
 'Will = vouloir: I will(want) to go'),

('quartier', 'neighbourhood / district',
 '{"zh":"街區","es":"barrio","de":"Viertel"}',
 'noun', 'masculine', 'quartiers',
 '/kaʁ.tje/', 'A2', ARRAY['city','housing','geography'], 420,
 '[
   {"fr":"J''habite dans un quartier calme.","en":"I live in a quiet neighbourhood."},
   {"fr":"Le Quartier Latin est célèbre pour ses librairies.","en":"The Latin Quarter is famous for its bookshops."}
 ]',
 'Un quart = a quarter. Quartier is literally a quarter of a city.',
 'Quarter → quartier: a quarter of the city'),

('se souvenir', 'to remember',
 '{"zh":"記得","es":"recordar","de":"sich erinnern"}',
 'verb', NULL, NULL,
 '/sə su.v(ə).niʁ/', 'A2', ARRAY['verbs','reflexive','memory'], 320,
 '[
   {"fr":"Je me souviens de mon premier jour d''école.","en":"I remember my first day of school."},
   {"fr":"Tu te souviens de son nom ?","en":"Do you remember his name?"}
 ]',
 'Always reflexive. Takes de: se souvenir de qqch/qqn. Contrast with se rappeler + direct object.',
 'souvenir = keepsake that makes you remember'),

-- B1 ─────────────────────────────────────────────────────────

('cependant', 'however / nevertheless',
 '{"zh":"然而","es":"sin embargo","de":"jedoch"}',
 'adverb', NULL, NULL,
 '/sə.pɑ̃.dɑ̃/', 'B1', ARRAY['connectors','formal_writing'], 380,
 '[
   {"fr":"Il est intelligent ; cependant, il manque d''expérience.","en":"He is intelligent; however, he lacks experience."},
   {"fr":"La solution est simple. Cependant, peu de gens la connaissent.","en":"The solution is simple. However, few people know it."}
 ]',
 'More formal than mais. Synonyms: toutefois, néanmoins, pourtant.',
 'Ce + pendant (during) → while this is true, however…'),

('pourtant', 'yet / even so / nonetheless',
 '{"zh":"然而/儘管如此","es":"sin embargo","de":"dennoch"}',
 'adverb', NULL, NULL,
 '/puʁ.tɑ̃/', 'B1', ARRAY['connectors','contrast'], 290,
 '[
   {"fr":"Il n''a pas étudié et pourtant il a réussi.","en":"He did not study and yet he passed."},
   {"fr":"C''est pourtant simple !","en":"And yet it is simple!"}
 ]',
 'Can appear mid-sentence or at the start. More emphatic than cependant. Often expresses surprise.',
 'Pour (for) + tant (so much) → for all that = yet'),

('s''épanouir', 'to blossom / to flourish / to thrive',
 '{"zh":"蓬勃发展","es":"florecer","de":"aufblühen"}',
 'verb', NULL, NULL,
 '/e.pa.nwiʁ/', 'B1', ARRAY['verbs','reflexive','psychology'], 4200,
 '[
   {"fr":"Les enfants s''épanouissent dans un environnement bienveillant.","en":"Children thrive in a caring environment."},
   {"fr":"Elle s''est épanouie grâce à ce nouveau poste.","en":"She flourished thanks to her new position."}
 ]',
 'Always reflexive. Related noun: épanouissement (m). Very common in HR, education, psychology.',
 'épanouir = to bloom like a flower opening up'),

-- B2 ─────────────────────────────────────────────────────────

('subvention', 'subsidy / grant',
 '{"zh":"补贴","es":"subvención","de":"Subvention"}',
 'noun', 'feminine', 'subventions',
 '/syb.vɑ̃.sjɔ̃/', 'B2', ARRAY['economics','politics','formal'], 1850,
 '[
   {"fr":"Le gouvernement accorde des subventions aux agriculteurs.","en":"The government grants subsidies to farmers."},
   {"fr":"Cette association reçoit une subvention de la mairie.","en":"This association receives a grant from the town hall."}
 ]',
 'Cognate with English subvention. Verb form: subventionner.',
 'Sub + venir → money that comes underneath to support'),

('enjeu', 'stake / issue / challenge',
 '{"zh":"赌注/关键问题","es":"apuesta/desafío","de":"Einsatz/Herausforderung"}',
 'noun', 'masculine', 'enjeux',
 '/ɑ̃.ʒø/', 'B2', ARRAY['abstract','politics','formal'], 980,
 '[
   {"fr":"Les enjeux de cette élection sont considérables.","en":"The stakes of this election are considerable."},
   {"fr":"Il faut comprendre les enjeux environnementaux.","en":"We must understand the environmental challenges."}
 ]',
 'From en jeu = in play/at stake. Very common in formal discourse, journalism, politics.',
 'En jeu → in play → what is at stake'),

-- C1 ─────────────────────────────────────────────────────────

('épanouissement', 'fulfilment / self-actualization / blossoming',
 '{"zh":"自我实现","es":"realización","de":"Entfaltung"}',
 'noun', 'masculine', NULL,
 '/e.pa.nwis.mɑ̃/', 'C1', ARRAY['psychology','philosophy','abstract'], 5200,
 '[
   {"fr":"L''épanouissement personnel est un objectif de vie pour beaucoup.","en":"Personal fulfilment is a life goal for many."},
   {"fr":"Ce travail lui permet un réel épanouissement professionnel.","en":"This job allows him true professional fulfilment."}
 ]',
 'From s''épanouir (to blossom). Common in psychology and self-help contexts.',
 'épanouir = to blossom → épanouissement = the blossoming/fulfilment'),

-- C2 ─────────────────────────────────────────────────────────

('nonobstant', 'notwithstanding / despite',
 '{"zh":"尽管","es":"no obstante","de":"ungeachtet"}',
 'preposition', NULL, NULL,
 '/nɔ.nɔp.stɑ̃/', 'C2', ARRAY['legal','formal_writing','connectors'], 12000,
 '[
   {"fr":"Nonobstant les difficultés, le projet a abouti.","en":"Notwithstanding the difficulties, the project succeeded."},
   {"fr":"Cette clause s''applique nonobstant toute disposition contraire.","en":"This clause applies notwithstanding any contrary provision."}
 ]',
 'Exclusively formal/legal register. Synonymous with malgré (informal), en dépit de (semi-formal).',
 'Non + obstant (to stand against) → not standing in the way of');
