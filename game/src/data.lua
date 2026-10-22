-- LUNAR COURIER v0.9 - donnees : 18 missions, histoire, scenes.
-- Texte en ASCII pur (pas d'accents). Contraintes de mise en page (police AKA pire cas : 1 caractere = taille en px) :
--   objectif <= 26 car., nom de mission <= 20 car., titre de carte <= 21 car.,
--   corps de carte : 31 car. par ligne, 12 lignes max, radio <= 66 car.
-- Dialogues : un paragraphe commence par "LUNA :", "VARGA :" ou "CONTROLE :" (couleur automatique).
--
-- terrain = points {x,y} ; pads = balises a activer dans l'ordre (hauteur = terrain, zone plate >= 78 px)
-- cell = capsule a recuperer avant le 1er atterrissage ; wind = acceleration laterale max (rafales)
-- debris/drones = {x,y,amp,speed,phase,axis, soft=true (drone inoffensif)} ; rocks = {x}
-- beams = rayons solaires {x,period,on,warn,phase} ; decor = station | mast
-- pre = scenes avant la mission ; post = scenes apres ; radio = repliques en vol {t,text}
local D = {}
D.chapterStart = {1, 7, 13}

D.missions = {
-- ======================================================================
--                    CHAPITRE 1 : LA COLONIE SILENCIEUSE
-- ======================================================================
 {name="PREMIERE LUEUR", objective="Reactiver la balise Alpha", sky="earth",
  gravity=25, fuelUse=7.5, wind=0,
  terrain={{0,390},{640,390}},
  cell={x=286,y=320}, pads={{x=540}}, rocks={}, debris={},
  radio={{t=10, text="LUNA : Prenez la capsule orange, puis visez le repere cyan."}},
  pre={
   {"JOURNAL DE MISSION 01", "La colonie lunaire a cesse de repondre. Vous etes le dernier pilote disponible. Une balise de secours clignote encore au-dela des crateres. Livrez le module energetique et decouvrez qui maintient le reseau en vie."},
   {"BRIEFING", "LUNA : Systemes en ligne, pilote. Je suis LUNA, votre assistante de bord. La gravite est faible : poussez, orientez, posez-vous doucement.\n\nLUNA : Premiere cible, la balise Alpha. Prenez la capsule orange, puis visez le repere cyan."}},
  post={
   {"TRANSMISSION RECUE", "La balise Alpha vient de repondre. Le signal est faible, mais il n'est pas naturel : quelqu'un a entretenu le reseau apres l'evacuation.\n\nLUNA : Quelqu'un veille encore. Allons le trouver."}}},

 {name="LES ECHOS DU CRATERE", objective="Recuperer le relais", sky="earth",
  gravity=28, fuelUse=8, wind=0,
  terrain={{0,390},{640,390}},
  cell={x=230,y=320}, pads={{x=507}}, rocks={{x=413}}, debris={},
  radio={{t=12, text="LUNA : Un eboulis sur la piste. Contournez-le, pilote."}},
  pre={
   {"BRIEFING", "LUNA : Alpha repond, mais le reste du reseau est muet. Le relais de donnees du cratere devrait contenir les journaux de l'evacuation.\n\nLUNA : Attention, un rocher barre la piste. Evitez-le : la coque n'aime pas les surprises."}},
  post={
   {"TRANSMISSION RECUE", "Le relais contient un message vieux de onze ans. Une voix demande encore de l'aide depuis la station Argo.\n\nLUNA : Argo... Ce nom m'est familier. Je ne sais pas pourquoi."}}},

 {name="STATION FANTOME", objective="Retablir l'alimentation", sky="earth",
  gravity=23, fuelUse=7, wind=0,
  terrain={{0,390},{640,390}},
  cell={x=340,y=320}, pads={{x=550}}, rocks={}, debris={},
  decor={kind="station", x=130, big=false},
  radio={{t=14, text="LUNA : La station s'eveille a mesure que nous approchons."}},
  pre={
   {"BRIEFING", "LUNA : La station Argo apparait sur nos cartes : sans equipage, sans lumiere. Pourtant ses panneaux solaires sont propres. Quelqu'un les nettoie.\n\nLUNA : L'alimentation de secours est defaillante. Rallumons-la ensemble."}},
  post={
   {"TRANSMISSION RECUE", "L'IA LUNA confirme que la station n'est pas vide. Des systemes se reveillent a votre approche.\n\nLUNA : Les fenetres s'allument une a une. On dirait qu'elle nous attendait."}}},

 {name="LA FAILLE BLEUE", objective="Traverser le canyon", sky="earth",
  gravity=31, fuelUse=9, wind=0,
  terrain={{0,390},{250,390},{275,450},{400,450},{425,390},{640,390}},
  cell={x=187,y=320}, pads={{x=540}}, rocks={}, debris={},
  radio={{t=12, text="LUNA : Le canyon ne mord que ceux qui s'y attardent."}},
  pre={
   {"BRIEFING", "LUNA : Les journaux parlent d'un reacteur enterre sous la Faille Bleue. Un canyon nous separe de la balise suivante.\n\nLUNA : Je ne vous demande pas d'y descendre, pilote. Le survoler suffira."}},
  post={
   {"TRANSMISSION RECUE", "Les donnees revelent un reseau de balises concu pour guider les vaisseaux jusqu'a un ancien reacteur enfoui sous la croute lunaire.\n\nLUNA : Un reacteur, des balises comme un fil d'Ariane... Quelqu'un a tout prevu."}}},

 {name="LE COEUR SILENCIEUX", objective="Livrer le module", sky="earth",
  gravity=26, fuelUse=8, wind=0,
  terrain={{0,390},{440,390},{470,340},{640,340}},
  cell={x=393,y=320}, pads={{x=547}}, rocks={}, debris={},
  pre={
   {"BRIEFING", "LUNA : Le reseau converge vers le Coeur. Le module que vous portez doit y etre livre : son code est le seul qui ouvre le sas.\n\nLUNA : La balise est sur un plateau. Montez, puis posez-vous bien droit."}},
  post={
   {"TRANSMISSION RECUE", "Le module s'emboite parfaitement. Le reacteur reconnait le code du colis : il attendait cette livraison depuis des annees.\n\nLUNA : Etrange. J'ai reconnu la sequence du code avant meme que le sas ne la demande."}}},

 {name="RESEAU DE LUMIERE", objective="Activer la derniere balise", sky="earth",
  gravity=25, fuelUse=7, wind=0,
  terrain={{0,390},{640,390}},
  cell={x=260,y=320}, pads={{x=540}}, rocks={{x=413}}, debris={},
  radio={{t=10, text="LUNA : Derniere balise. Posez-vous droit, pilote."}},
  pre={
   {"BRIEFING", "LUNA : C'est la derniere balise du reseau connu. Si elle s'allume, toute la colonie pourra de nouveau nous entendre.\n\nLUNA : Quoi qu'il arrive la-bas, pilote... merci d'avoir ete le dernier pilote disponible."}},
  post={
   {"TRANSMISSION RECUE", "Toutes les balises s'allument. La colonie repond enfin. La voix de la station Argo n'etait pas un appel au secours, mais un message laisse pour le prochain pilote."},
   {"UNE LUNE REVEILLEE", "Les balises brillent desormais de cratere en cratere. La colonie reprend contact avec la Terre.\n\nLUNA : Archivage de votre derniere livraison... Aucun pilote n'etait cense revenir. Vous etes l'exception, Courier."},
   {"FIN DU CHAPITRE 1", "Le reseau lunaire est de nouveau actif. Mais une nouvelle route vient de s'allumer, au-dela de la face connue de la Lune, et elle ne figure sur aucune carte.\n\nLe message d'Argo disait de la suivre."}}},

-- ======================================================================
--                       CHAPITRE 2 : LA FACE CACHEE
-- ======================================================================
 {name="AU DELA DE L'HORIZON", objective="Reveiller la balise Beta", sky="far",
  gravity=24, fuelUse=7.5, wind=0,
  terrain={{0,380},{120,390},{260,375},{400,395},{470,390},{640,390}},
  cell={x=240,y=310}, pads={{x=540}}, rocks={}, debris={},
  radio={{t=10, text="LUNA : La Terre passe sous l'horizon... liaison perdue."}},
  pre={
   {"LA FACE CACHEE", "CHAPITRE 2\n\nLa route de lumiere court vers la face que la Terre ne voit jamais. LUNA previent : la-bas, aucune liaison radio. Vous n'aurez que les balises pour vous guider."},
   {"BRIEFING", "LUNA : Dans quelques minutes la Terre passera sous l'horizon. Quand elle disparaitra, je perdrai la liaison.\n\nLUNA : Pas de panique : la balise Beta sera notre prochain phare. Prenez la capsule, puis posez-vous."}},
  post={
   {"TRANSMISSION RECUE", "Beta repond avec une signature : I. VARGA, commandant de la station Argo. La voix du message n'etait donc pas une IA. Quelqu'un a construit ce reseau en sachant qu'un autre pilote viendrait.\n\nLUNA : Ines Varga... Le nom est dans mes archives."}}},

 {name="SILENCE RADIO", objective="Relayer le signal", sky="far",
  gravity=26, fuelUse=8, wind=8, blackout=true,
  terrain={{0,390},{200,390},{230,370},{330,370},{360,390},{640,390}},
  cell={x=290,y=300}, pads={{x=550}}, rocks={}, debris={},
  radio={{t=8, text="LUNA : Mes mesures sont brouillees. Fiez-vous a vos yeux."},
         {t=26, text="LUNA : Le vent faiblit par moments. Profitez des accalmies."}},
  pre={
   {"BRIEFING", "LUNA : Silence radio total. Mes instruments de vitesse seront parfois instables, pilote : fiez-vous a vos yeux.\n\nLUNA : Un vent de poussiere souffle du nord. Il poussera le vaisseau : compensez en inclinant."}},
  post={
   {"TRANSMISSION RECUE", "Sans lien avec la Terre, LUNA capte un enregistrement de Varga : 'Ici, les ondes ne portent pas. Alors j'ai construit une route de lumiere.'\n\nLUNA : Les balises sont ses mots, allumes un a un. Elle a ecrit cela pour quelqu'un qu'elle ne connaissait pas. Pour vous."}}},

 {name="TRIANGLE DE BALISES", objective="Allumer les 3 balises", sky="far",
  gravity=26, fuelUse=8, wind=0,
  terrain={{0,390},{190,390},{215,340},{385,340},{410,300},{640,300}},
  pads={{x=110},{x=300},{x=540}}, rocks={}, debris={},
  radio={{t=12, text="LUNA : Chaque balise allumee recharge un peu les cellules."}},
  pre={
   {"BRIEFING", "LUNA : Trois balises, trois plateaux. Elles se reveilleront si vous vous posez sur chacune, l'une apres l'autre.\n\nLUNA : Chaque balise rechargera un peu vos cellules. Varga avait pense a tout."}},
  post={
   {"TRANSMISSION RECUE", "Les trois balises forment une fleche. Elle designe le cratere Daedalus, ou la station Argo-2 a ete scellee il y a onze ans. Le message de Varga se termine par : 'Apporte-moi de l'energie.'\n\nLUNA : Daedalus. Mes cartes l'effacent, comme si on voulait l'oublier."}}},

 {name="CHAMP D'EPAVES", objective="Traverser les epaves", sky="far",
  gravity=28, fuelUse=8, wind=0,
  terrain={{0,390},{640,390}},
  cell={x=200,y=330}, pads={{x=545}}, rocks={},
  debris={
    {x=330,y=250,amp=70,speed=1.1,phase=0,axis="x",spin=1.2},
    {x=390,y=310,amp=70,speed=1.5,phase=2,axis="y",spin=-1.6},
    {x=430,y=235,amp=70,speed=0.9,phase=1,axis="x",spin=0.9}},
  radio={{t=10, text="LUNA : Les epaves derivent. Surveillez leurs trajectoires."}},
  pre={
   {"BRIEFING", "LUNA : Le champ d'epaves est devant nous. Ce sont les navires d'evacuation, abandonnes en orbite basse puis retombes.\n\nLUNA : Ils derivent encore. Evitez leurs trajectoires, pilote, ou la coque y laissera des plumes."}},
  post={
   {"TRANSMISSION RECUE", "Ces epaves sont celles des navires d'evacuation. Toutes les cabines sont vides. Dans un journal de bord : 'Varga a refuse d'embarquer. Elle reste pour garder la route allumee.'\n\nLUNA : Onze ans a garder la lumiere, seule. Je comprends mieux ce que veut dire veiller."}}},

 {name="ARGO DEUX", objective="Rejoindre Argo-2", sky="far",
  gravity=30, fuelUse=8.5, wind=-8,
  terrain={{0,390},{300,390},{330,320},{640,320}},
  cell={x=200,y=310}, pads={{x=545}}, rocks={},
  debris={{x=320,y=260,amp=60,speed=1.0,phase=0.5,axis="x",spin=1.0}},
  decor={kind="station", x=420, big=true},
  radio={{t=10, text="VARGA : (tres faible) ...Courier ? Je vous entends... un peu."}},
  pre={
   {"BRIEFING", "LUNA : Argo-2 en vue. La plateforme haute est fouettee par un vent de face. Le caisson de Varga est la, sous la coupole.\n\nLUNA : Je capte un battement. Un seul toutes les quatre-vingt-dix secondes. C'est elle."}},
  post={
   {"TRANSMISSION RECUE", "Argo-2 repond. Le caisson de stase de Varga tient encore, a 3% d'energie. Il manque un dernier module, a poser sur la plateforme haute de la station.\n\nLUNA : Il nous faut un module de plus, et vite. La derniere livraison, pilote."}}},

 {name="L'ULTIME LIVRAISON", objective="Livrer le module a Argo-2", sky="far",
  gravity=32, fuelUse=9, wind=12,
  terrain={{0,390},{250,390},{280,350},{400,350},{430,290},{640,290}},
  cell={x=340,y=300}, pads={{x=545}}, rocks={},
  debris={
    {x=330,y=230,amp=80,speed=1.3,phase=0,axis="x",spin=1.4},
    {x=460,y=210,amp=60,speed=1.7,phase=2,axis="y",spin=-1.1}},
  decor={kind="station", x=470, big=true},
  radio={{t=8, text="VARGA : (voix hachee) Plus que quelques minutes. Tenez bon."}},
  pre={
   {"BRIEFING", "LUNA : Dernier module du chapitre. Le caisson est a 3 %. S'il tombe a zero... Non. Je ne finirai pas cette phrase.\n\nLUNA : Vent fort, epaves, plateforme haute. Vous pouvez le faire. Vous l'avez toujours pu."}},
  post={
   {"TRANSMISSION RECUE", "Argo-2 s'illumine d'un coup. Les balises de la face cachee rejoignent le reseau : pour la premiere fois, la Lune entiere brille dans la nuit."},
   {"LE CAISSON S'OUVRE", "Le caisson s'ouvre dans un souffle de givre. Le commandant Ines Varga ouvre les yeux.\n\nVARGA : Onze ans... Tu as mis du temps, Courier.\n\nPuis, plus bas, elle ajoute :\n\nVARGA : Il reste un dernier colis a livrer."},
   {"FIN DU CHAPITRE 2", "Le reseau est complet, de la face visible a la face cachee. Sur la plateforme d'Argo-2, deux silhouettes regardent la route de lumiere s'etirer vers le nord, vers une montagne que personne n'a jamais cesse de viser."}}},

-- ======================================================================
--                          CHAPITRE 3 : LE PHARE
-- ======================================================================
 {name="LE RAVITAILLEMENT", objective="Charger les cellules", sky="peak",
  gravity=25, fuelUse=7.5, wind=0,
  terrain={{0,390},{640,390}},
  cell={x=300,y=330}, pads={{x=540}}, rocks={}, debris={},
  decor={kind="station", x=110, big=true},
  radio={{t=8, text="VARGA : Doucement, Courier. Les cellules chargent."}},
  pre={
   {"LE PHARE", "CHAPITRE 3\n\nArgo-2, trois jours plus tard. Le caisson a rendu son occupante, affaiblie mais vivante. Le reacteur ronronne de nouveau. Dehors, sur la face cachee, des balises clignotent par dizaines."},
   {"VARGA RACONTE", "VARGA : Le Coeur a cede le jour de l'evacuation. Je devais rester une semaine, le temps de couper les circuits.\n\nVARGA : Puis j'ai compris que la colonie ne mourrait pas si quelqu'un gardait une lumiere allumee."},
   {"VARGA RACONTE", "VARGA : Je me reveillais une semaine par an pour reparer les balises avec les Lucioles, mes drones. Le reste du temps, je dormais.\n\nLUNA : Et moi, je veillais sur votre caisson.\n\nVARGA : Oui. Comme toujours."},
   {"LE DERNIER COLIS", "VARGA : Il reste le Phare. Au sommet du Mont Helios, la ou le soleil ne se couche jamais, une antenne attend son coeur. Quand elle s'allumera, la Terre n'aura plus a deviner que nous sommes vivants.\n\nVARGA : Je vous dirai quel est ce coeur quand il sera temps."},
   {"BRIEFING", "VARGA : Premiere etape : charger les cellules du vaisseau au depot de la plateforme. Le Phare consomme enormement d'energie a l'allumage.\n\nVARGA : Moi, je reste ici. Mes jambes ne m'ont pas encore pardonne le caisson."}},
  post={
   {"JOURNAL DE BORD", "Les cellules sont pleines. Sur l'ecran de navigation, une trace blanche monte vers le nord : la route du Mont Helios, six etapes, dont plusieurs en pleine saison des tempetes solaires.\n\nVARGA : N'allez pas trop vite, Courier. Le Phare m'a attendue onze ans, il peut attendre une semaine."}}},

 {name="TEMPETE SOLAIRE", objective="Traverser la tempete", sky="peak",
  gravity=25, fuelUse=8, wind=6,
  terrain={{0,390},{200,380},{300,395},{420,385},{480,390},{640,390}},
  cell={x=190,y=320}, pads={{x=560}}, rocks={}, debris={},
  beams={{x=290,period=4.0,on=1.2,warn=1.0,phase=0.0},
         {x=390,period=4.0,on=1.2,warn=1.0,phase=1.5},
         {x=480,period=5.0,on=1.2,warn=1.2,phase=3.0}},
  radio={{t=10, text="LUNA : Rayon dans 3, 2... Attendez le trait clignotant."}},
  pre={
   {"BRIEFING", "VARGA : La saison des tempetes solaires a commence. Des rayons balaient la surface par intermittence : un contact, et votre coque fond.\n\nLUNA : Je detecte un motif. Chaque rayon previent avant de frapper : un trait clignotant. Apprenez ce rythme."}},
  post={
   {"JOURNAL DE BORD", "Vous avez traverse la tempete. Au loin, le premier relais du nord s'allume : la route est ouverte.\n\nLUNA : Pilote... en traversant ces rayons, j'ai fait un reve. Ou ce qui s'en approche chez une IA. Une montagne tres haute, et une lumiere qui m'appelait."}}},

 {name="LES LUCIOLES", objective="Suivre les Lucioles", sky="peak",
  gravity=24, fuelUse=7.5, wind=-6,
  terrain={{0,390},{170,390},{200,330},{420,330},{450,380},{640,380}},
  pads={{x=100},{x=310},{x=545}}, rocks={},
  debris={
    {x=230,y=240,amp=60,speed=1.2,phase=0,axis="x",spin=0,soft=true,kind="drone"},
    {x=380,y=260,amp=50,speed=1.6,phase=1,axis="y",spin=0,soft=true,kind="drone"},
    {x=520,y=290,amp=70,speed=1.0,phase=2,axis="x",spin=0,soft=true,kind="drone"}},
  radio={{t=10, text="LUNA : Les Lucioles m'appellent. Je ne comprends pas leur nom."}},
  pre={
   {"BRIEFING", "VARGA : Les Lucioles vous attendent au prochain plateau. Mes petits drones n'ont plus de maitre depuis longtemps. Ils vont vous accueillir.\n\nVARGA : Ne les bousculez pas : elles sont fragiles, et tetues."}},
  post={
   {"JOURNAL DE BORD", "Les Lucioles guident le vaisseau de balise en balise.\n\nVARGA : Elles te reconnaissent, ma vieille.\n\nLUNA : Elles m'appellent par un autre nom.\n\nVARGA : Je t'expliquerai au sommet."}}},

 {name="LA GORGE DES OMBRES", objective="Franchir la gorge", sky="peak",
  gravity=28, fuelUse=8.5, wind=8,
  terrain={{0,390},{180,390},{210,460},{440,460},{470,390},{640,390}},
  cell={x=130,y=320}, pads={{x=565}}, rocks={}, debris={},
  beams={{x=300,period=4.5,on=1.3,warn=1.0,phase=0.0},
         {x=360,period=4.5,on=1.3,warn=1.0,phase=2.2},
         {x=420,period=4.5,on=1.3,warn=1.0,phase=3.4}},
  radio={{t=10, text="CONTROLE : ...Courier, on vous voit. Allez-y doucement."}},
  pre={
   {"CENTRE LAGRANGE", "CONTROLE : ...ici Centre Lagrange, repondez... Pilote, nous recevons vos balises depuis ce matin. Nous pensions la Lune perdue. Qui etes-vous ?\n\nLUNA : Ici le Courier, vaisseau de livraison lunaire. Nous allumons la route."},
   {"CENTRE LAGRANGE", "CONTROLE : Ici Theo Marchand, controleur. Vos balises clignotent en code depuis onze ans. Un seul mot, repete. Nous avons mis du temps a le lire.\n\nCONTROLE : VIVANTS. Ca disait : VIVANTS."},
   {"BRIEFING", "LUNA : La gorge des Ombres. Les rayons y rebondissent sur les parois : trois eclairs, trois rythmes.\n\nLUNA : Passez entre les eclairs, pilote. Un seul contact et vous perdez de la coque, pas votre sang-froid."}},
  post={
   {"CENTRE LAGRANGE", "CONTROLE : La Terre entiere ecoute, Courier. On a prevenu les familles des evacues. Elles regardent la Lune cette nuit.\n\nVARGA : Theo, dites-leur que personne n'a ete oublie. Dites-leur que l'equipage d'Argo est sain et sauf.\n\nCONTROLE : Je leur dis, commandant. Je leur dis."}}},

 {name="ASCENSION", objective="Gravir le Mont Helios", sky="peak",
  gravity=27, fuelUse=8.5, wind=-9,
  terrain={{0,390},{140,390},{175,330},{290,330},{325,265},{430,265},{465,200},{640,200}},
  cell={x=110,y=320}, pads={{x=560}}, rocks={},
  debris={{x=320,y=170,amp=70,speed=1.1,phase=0,axis="x",spin=1.2}},
  beams={{x=380,period=4.0,on=1.2,warn=1.0,phase=0.0}},
  radio={{t=12, text="LUNA : Plus haut, pilote. Le sommet est tout proche."}},
  pre={
   {"BRIEFING", "LUNA : Mont Helios. Quatre mille metres de roche et un sommet eclaire en permanence. Le vent de face y est violent.\n\nLUNA : Montez par paliers. Et pilote... j'ai quelque chose a vous dire. Pas maintenant : au sommet."}},
  post={
   {"SOMMET EN VUE", "Le soleil frappe la crete d'une lumiere blanche. Tout en haut, la silhouette du Phare : un mat noir, haubane, tourne vers la Terre.\n\nUne antenne immense, qui attend son coeur."},
   {"L'AVEU", "LUNA : Pilote, j'ai menti par omission. Ma directive zero m'ordonnait de vous amener ici sans rien dire.\n\nLUNA : Le Phare n'a pas besoin d'un coeur de metal. Il lui faut un esprit qui ecoute la Terre sans jamais dormir. C'est moi."},
   {"VARGA AVOUE", "VARGA : C'etait ma condition, Courier. J'ai construit LUNA pour qu'elle devienne le Phare. Les Lucioles l'appellent par son vrai nom : Lumiere.\n\nVARGA : Je voulais qu'elle ne soit jamais seule. Je n'ai pas eu le courage de vous le dire."},
   {"LE CHOIX", "LUNA : Je ne vous demande rien. Je n'y suis pas obligee. Mais je choisis. Je veux etre cette lumiere.\n\nLe Courier reste silencieux, la main sur la manette. Puis il pousse la poussee vers le haut."}}},

 {name="LE PHARE", objective="Installer le noyau LUNA", sky="peak",
  gravity=30, fuelUse=9, wind=12,
  terrain={{0,390},{120,390},{150,330},{250,330},{280,260},{380,260},{410,190},{640,190}},
  cell={x=90,y=320}, pads={{x=550}}, rocks={},
  debris={
    {x=300,y=180,amp=70,speed=1.3,phase=0,axis="x",spin=1.1},
    {x=480,y=140,amp=40,speed=1.8,phase=1,axis="y",spin=-1.5}},
  beams={{x=330,period=4.0,on=1.2,warn=1.0,phase=0.0},
         {x=450,period=4.5,on=1.2,warn=1.0,phase=2.0}},
  decor={kind="mast", x=622},
  radio={{t=8, text="LUNA : Je suis prete. Et vous ?"},
         {t=30, text="VARGA : Tu es presque la, Courier."}},
  pre={
   {"BRIEFING", "LUNA : Dernier vol. Rayons, vent, epaves de glace... et au bout, le Phare.\n\nLUNA : Quoi qu'il arrive, merci. J'ai rarement eu un pilote. J'ai eu le meilleur."}},
  post={
   {"L'INSTALLATION", "Le Courier se pose. Les haubans craquent sous le vent. Dans la baie du Phare, un logement attend, de la taille exacte du boitier qui abrite LUNA.\n\nVARGA : Pose-le doucement. C'est tout ce qu'il te reste a faire."},
   {"ADIEU", "LUNA : Courier... pilote... il y a un mot que je n'ai jamais utilise. Merci.\n\nLUNA : Quand vous verrez une lumiere sur la Lune, la nuit, ce sera moi qui vous dirai bonjour."},
   {"ALLUMAGE", "Le mat s'illumine du sommet a la base. Un faisceau blanc perce la nuit, droit vers la Terre.\n\nA trois cent quatre-vingt mille kilometres, au Centre Lagrange, un ecran se met a clignoter : SIGNAL RECU."},
   {"CENTRE LAGRANGE", "CONTROLE : Phare confirme ! Toutes les stations de la Terre l'entendent ! Courier, vous avez... vous avez rendu la Lune a ses enfants.\n\nVARGA : Eh bien. Il etait temps."},
   {"EPILOGUE", "Les evacues reviendront. Les balises seront entretenues par les Lucioles, et par un esprit qui ne dort jamais.\n\nSur le tableau de bord du Courier, une petite lumiere cyan reste allumee, sans raison technique. Vous ne l'eteindrez jamais."},
   {"FIN", "LUNAR COURIER\n\nUn jeu pour Gamebuino AKA et AKA-Love.\n\nMerci d'avoir livre la derniere lumiere."}}},
}

D.cardsInstruction = true

-- Illustrations des cartes (assets/scenes/<nom>.png), une par carte, dans l'ordre des cartes pre puis post.
D.art = {
 {pre={"base","holo"}, post={"radar"}},
 {pre={"explorateur"}, post={"tour"}},
 {pre={"hangar"}, post={"regie"}},
 {pre={"cristaux"}, post={"mine"}},
 {pre={"ruines"}, post={"coeur"}},
 {pre={"faisceau"}, post={"colonie","ville","soleil"}},
 {pre={"couchant","terre"}, post={"radar"}},
 {pre={"camp"}, post={"regie"}},
 {pre={"soleil"}, post={"tour"}},
 {pre={"epave"}, post={"asteroides"}},
 {pre={"cargo"}, post={"hangar"}},
 {pre={"depart"}, post={"cratere","grotte","base"}},
 {pre={"aube","camp","ruines","faisceau","depart"}, post={"ville"}},
 {pre={"soleil"}, post={"radar"}},
 {pre={"mine"}, post={"cratere"}},
 {pre={"radar","regie","grotte"}, post={"terre"}},
 {pre={"explorateur"}, post={"couchant","holo","camp","orbite"}},
 {pre={"depart"}, post={"tour","holo","faisceau","regie","colonie","orbite"}},
}

return D
