-- LUNAR COURIER - textes de l'histoire, FRANCAIS (ASCII pur : le runtime AKA-Love n'affiche pas les accents).
-- Un element par mission, dans l'ordre de data.lua. Contraintes de mise en page (police AKA pire cas : 1 caractere = 16 px) :
--   nom <= 20 car., objectif <= 26 car., titre de carte <= 21 car., corps : 31 car. par ligne, 12 lignes max, radio <= 66 car.
-- Dialogues : un paragraphe commence par "LUNA :", "VARGA :" ou "CONTROLE :" (couleur et portrait automatiques).
return {
-- M1
 {name="PREMIERE LUEUR", objective="Reactiver la balise Alpha",
  pre={
   {"JOURNAL DE MISSION 01", "La colonie lunaire a cesse de repondre. Vous etes le dernier pilote disponible. Une balise de secours clignote encore au-dela des crateres. Livrez le module energetique et decouvrez qui maintient le reseau en vie."},
   {"BRIEFING", "LUNA : Systemes en ligne, pilote. Je suis LUNA, votre assistante de bord. La gravite est faible : poussez, orientez, posez-vous doucement.\n\nLUNA : Premiere cible, la balise Alpha. Prenez la capsule orange, puis visez le repere cyan."},
  },
  post={
   {"TRANSMISSION RECUE", "La balise Alpha vient de repondre. Le signal est faible, mais il n'est pas naturel : quelqu'un a entretenu le reseau apres l'evacuation.\n\nLUNA : Quelqu'un veille encore. Allons le trouver."},
  },
  radio={"LUNA : Prenez la capsule orange, puis visez le repere cyan."}},
-- M2
 {name="LES ECHOS DU CRATERE", objective="Recuperer le relais",
  pre={
   {"BRIEFING", "LUNA : Alpha repond, mais le reste du reseau est muet. Le relais de donnees du cratere devrait contenir les journaux de l'evacuation.\n\nLUNA : Attention, un rocher barre la piste. Evitez-le : la coque n'aime pas les surprises."},
  },
  post={
   {"TRANSMISSION RECUE", "Le relais contient un message vieux de onze ans. Une voix demande encore de l'aide depuis la station Argo.\n\nLUNA : Argo... Ce nom m'est familier. Je ne sais pas pourquoi."},
  },
  radio={"LUNA : Un eboulis sur la piste. Contournez-le, pilote."}},
-- M3
 {name="STATION FANTOME", objective="Retablir l'alimentation",
  pre={
   {"BRIEFING", "LUNA : La station Argo apparait sur nos cartes : sans equipage, sans lumiere. Pourtant ses panneaux solaires sont propres. Quelqu'un les nettoie.\n\nLUNA : L'alimentation de secours est defaillante. Rallumons-la ensemble."},
  },
  post={
   {"TRANSMISSION RECUE", "L'IA LUNA confirme que la station n'est pas vide. Des systemes se reveillent a votre approche.\n\nLUNA : Les fenetres s'allument une a une. On dirait qu'elle nous attendait."},
  },
  radio={"LUNA : La station s'eveille a mesure que nous approchons."}},
-- M4
 {name="LA FAILLE BLEUE", objective="Traverser le canyon",
  pre={
   {"BRIEFING", "LUNA : Les journaux parlent d'un reacteur enterre sous la Faille Bleue. Un canyon nous separe de la balise suivante.\n\nLUNA : Je ne vous demande pas d'y descendre, pilote. Le survoler suffira."},
  },
  post={
   {"TRANSMISSION RECUE", "Les donnees revelent un reseau de balises concu pour guider les vaisseaux jusqu'a un ancien reacteur enfoui sous la croute lunaire.\n\nLUNA : Un reacteur, des balises comme un fil d'Ariane... Quelqu'un a tout prevu."},
  },
  radio={"LUNA : Le canyon ne mord que ceux qui s'y attardent."}},
-- M5
 {name="LE COEUR SILENCIEUX", objective="Livrer le module",
  pre={
   {"BRIEFING", "LUNA : Le reseau converge vers le Coeur. Le module que vous portez doit y etre livre : son code est le seul qui ouvre le sas.\n\nLUNA : La balise est sur un plateau. Montez, puis posez-vous bien droit."},
  },
  post={
   {"TRANSMISSION RECUE", "Le sas accepte le module, mais le reacteur reste muet. Les plans indiquent un logement central et une console de commandement.\n\nLUNA : Le code m'est familier. Mais la phase de demarrage... je ne comprends pas pourquoi."},
  },
  radio={}},
-- M6
 {name="RESEAU DE LUMIERE", objective="Activer la derniere balise",
  pre={
   {"BRIEFING", "LUNA : C'est la derniere balise du reseau connu. Si elle s'allume, toute la colonie pourra de nouveau nous entendre.\n\nLUNA : Quoi qu'il arrive la-bas, pilote... merci d'avoir ete le dernier pilote disponible."},
  },
  post={
   {"TRANSMISSION RECUE", "Toutes les balises s'allument. La colonie repond enfin. La voix de la station Argo n'etait pas un appel au secours, mais un message laisse pour le prochain pilote."},
   {"UNE LUNE REVEILLEE", "Les balises brillent desormais de cratere en cratere. La colonie reprend contact avec la Terre.\n\nLUNA : Archivage de votre derniere livraison... Aucun pilote n'etait cense revenir. Vous etes l'exception, Courier."},
   {"FIN DU CHAPITRE 1", "Le reseau lunaire est de nouveau actif. Mais une nouvelle route vient de s'allumer, au-dela de la face connue de la Lune, et elle ne figure sur aucune carte.\n\nLe message d'Argo disait de la suivre."},
  },
  radio={"LUNA : Derniere balise. Posez-vous droit, pilote."}},
-- M7
 {name="AU DELA DE L'HORIZON", objective="Reveiller la balise Beta",
  pre={
   {"LA FACE CACHEE", "CHAPITRE 2\n\nLa route de lumiere court vers la face que la Terre ne voit jamais. Plus aucune liaison avec la Terre la-bas. Vous n'aurez que les balises, et la voix de LUNA, a bord."},
   {"BRIEFING", "LUNA : Dans quelques minutes la Terre passera sous l'horizon. Quand elle disparaitra, je perdrai la liaison avec le Controle. Pas avec vous : je vis dans ce vaisseau, pilote.\n\nLUNA : Pas de panique : la balise Beta sera notre prochain phare. Prenez la capsule, puis posez-vous."},
  },
  post={
   {"TRANSMISSION RECUE", "Beta repond avec une signature : I. VARGA, commandant de la station Argo. La voix du message n'etait donc pas une IA. Quelqu'un a construit ce reseau en sachant qu'un autre pilote viendrait.\n\nLUNA : Ines Varga... Le nom est dans mes archives."},
  },
  radio={"LUNA : La Terre passe sous l'horizon. Liaison Terre perdue."}},
-- M8
 {name="SILENCE RADIO", objective="Relayer le signal",
  pre={
   {"BRIEFING", "LUNA : Plus aucune voix de la Terre : je ne vous parle que depuis le vaisseau. Mes instruments de vitesse seront parfois instables, pilote : fiez-vous a vos yeux.\n\nLUNA : Un vent de poussiere souffle du nord. Il poussera le vaisseau : compensez en inclinant."},
  },
  post={
   {"TRANSMISSION RECUE", "Sans lien avec la Terre, LUNA capte, par les balises, un enregistrement de Varga : 'Ici, les ondes ne portent pas. Alors j'ai construit une route de lumiere.'\n\nLUNA : Les balises sont ses mots, allumes un a un. Elle a ecrit cela pour quelqu'un qu'elle ne connaissait pas. Pour vous."},
  },
  radio={"LUNA : Mes mesures sont brouillees. Fiez-vous a vos yeux.", "LUNA : Le vent faiblit par moments. Profitez des accalmies."}},
-- M9
 {name="TRIANGLE DE BALISES", objective="Allumer les 3 balises",
  pre={
   {"BRIEFING", "LUNA : Trois balises, trois plateaux. Elles se reveilleront si vous vous posez sur chacune, l'une apres l'autre.\n\nLUNA : Chaque balise rechargera un peu vos cellules. Varga avait pense a tout."},
  },
  post={
   {"TRANSMISSION RECUE", "Les trois balises forment une fleche. Elle designe le cratere Daedalus, ou la station Argo-2 a ete scellee il y a onze ans. Le message de Varga se termine par : 'Apporte-moi de l'energie.'\n\nLUNA : Daedalus. Mes cartes l'effacent, comme si on voulait l'oublier."},
  },
  radio={"LUNA : Chaque balise allumee recharge un peu les cellules."}},
-- M10
 {name="CHAMP D'EPAVES", objective="Traverser les epaves",
  pre={
   {"BRIEFING", "LUNA : Le champ d'epaves est devant nous. Ce sont les navires d'evacuation, abandonnes en orbite basse puis retombes.\n\nLUNA : Ils derivent encore. Evitez leurs trajectoires, pilote, ou la coque y laissera des plumes."},
  },
  post={
   {"TRANSMISSION RECUE", "Ces epaves sont celles des navires d'evacuation. Toutes les cabines sont vides. Dans un journal de bord : 'Varga a refuse d'embarquer. Elle reste pour garder la route allumee.'\n\nLUNA : Onze ans a garder la lumiere, seule. Je comprends mieux ce que veut dire veiller."},
  },
  radio={"LUNA : Les epaves derivent. Surveillez leurs trajectoires."}},
-- M11
 {name="ARGO DEUX", objective="Rejoindre Argo-2",
  pre={
   {"BRIEFING", "LUNA : Argo-2 en vue. La plateforme haute est fouettee par un vent de face. Le caisson de Varga est la, sous la coupole.\n\nLUNA : Je capte un battement. Un seul toutes les quatre-vingt-dix secondes. C'est elle."},
  },
  post={
   {"TRANSMISSION RECUE", "Argo-2 repond. Le caisson de stase de Varga tient encore, a 3% d'energie. Il manque un dernier module, a poser sur la plateforme haute de la station.\n\nLUNA : Il nous faut un module de plus, et vite. La derniere livraison, pilote."},
  },
  radio={"VARGA : (tres faible) ...Courier ? Je vous entends... un peu."}},
-- M12
 {name="L'ULTIME LIVRAISON", objective="Livrer le module a Argo-2",
  pre={
   {"BRIEFING", "LUNA : Dernier module du chapitre. Le caisson est a 3 %. S'il tombe a zero... Non. Je ne finirai pas cette phrase.\n\nLUNA : Vent fort, epaves, plateforme haute. Vous pouvez le faire. Vous l'avez toujours pu."},
  },
  post={
   {"TRANSMISSION RECUE", "Argo-2 s'illumine d'un coup. Les balises de la face cachee rejoignent le reseau : pour la premiere fois, la Lune entiere brille dans la nuit."},
  },
  post2={
   {"LE CAISSON S'OUVRE", "Le caisson s'ouvre dans un souffle de givre. Le commandant Ines Varga ouvre les yeux.\n\nVARGA : Onze ans... Tu as mis du temps, Courier.\n\nPuis, plus bas, elle ajoute :\n\nVARGA : Il reste un dernier colis a livrer."},
   {"FIN DU CHAPITRE 2", "Le reseau est complet, de la face visible a la face cachee. Sur la plateforme d'Argo-2, deux silhouettes regardent la route de lumiere s'etirer vers le nord, vers une montagne que personne n'a jamais cesse de viser."},
  },
  radio={"VARGA : (voix hachee) Plus que quelques minutes. Tenez bon."}},
-- M13
 {name="LE RAVITAILLEMENT", objective="Charger les cellules",
  pre={
   {"LE PHARE", "CHAPITRE 3\n\nArgo-2, trois jours plus tard. Le caisson a rendu son occupante, affaiblie mais vivante. Le reacteur ronronne de nouveau. Dehors, sur la face cachee, des balises clignotent par dizaines."},
   {"VARGA RACONTE", "VARGA : Le Coeur a cede le jour de l'evacuation. Je devais rester une semaine, le temps de couper les circuits.\n\nVARGA : Puis j'ai compris que la colonie ne mourrait pas si quelqu'un gardait une lumiere allumee."},
   {"VARGA RACONTE", "VARGA : Je me reveillais une semaine par an pour reparer les balises avec les Lucioles, mes drones. Le reste du temps, je dormais.\n\nLUNA : Et moi, je veillais sur votre caisson.\n\nVARGA : Oui. Comme toujours."},
   {"LE DERNIER COLIS", "VARGA : Il reste le Phare. Au sommet du Mont Helios, la ou le soleil ne se couche jamais, une antenne attend son coeur. Quand elle s'allumera, la Terre n'aura plus a deviner que nous sommes vivants.\n\nVARGA : Je vous dirai quel est ce coeur quand il sera temps."},
   {"BRIEFING", "VARGA : Premiere etape : charger les cellules du vaisseau au depot de la plateforme. Le Phare consomme enormement d'energie a l'allumage.\n\nVARGA : Moi, je reste ici. Mes jambes ne m'ont pas encore pardonne le caisson."},
  },
  post={
   {"JOURNAL DE BORD", "Les cellules sont pleines. Sur l'ecran de navigation, une trace blanche monte vers le nord : la route du Mont Helios, six etapes, dont plusieurs en pleine saison des tempetes solaires.\n\nVARGA : N'allez pas trop vite, Courier. Le Phare m'a attendue onze ans, il peut attendre une semaine."},
  },
  radio={"VARGA : Doucement, Courier. Les cellules chargent."}},
-- M14
 {name="TEMPETE SOLAIRE", objective="Traverser la tempete",
  pre={
   {"BRIEFING", "VARGA : La saison des tempetes solaires a commence. Des rayons balaient la surface par intermittence : un contact, et votre coque fond.\n\nLUNA : Je detecte un motif. Chaque rayon previent avant de frapper : un trait clignotant. Apprenez ce rythme."},
  },
  post={
   {"JOURNAL DE BORD", "Vous avez traverse la tempete. Au loin, le premier relais du nord s'allume : la route est ouverte.\n\nLUNA : Pilote... en traversant ces rayons, j'ai fait un reve. Ou ce qui s'en approche chez une IA. Une montagne tres haute, et une lumiere qui m'appelait."},
  },
  radio={"LUNA : Rayon dans 3, 2... Attendez le trait clignotant."}},
-- M15
 {name="LES LUCIOLES", objective="Suivre les Lucioles",
  pre={
   {"BRIEFING", "VARGA : Les Lucioles vous attendent au prochain plateau. Mes petits drones n'ont plus de maitre depuis longtemps. Ils vont vous accueillir.\n\nVARGA : Ne les bousculez pas : elles sont fragiles, et tetues."},
  },
  post={
   {"JOURNAL DE BORD", "Les Lucioles guident le vaisseau de balise en balise.\n\nVARGA : Elles te reconnaissent, ma vieille.\n\nLUNA : Elles m'appellent par un autre nom.\n\nVARGA : Je t'expliquerai au sommet."},
  },
  radio={"LUNA : Les Lucioles m'appellent. Je ne comprends pas leur nom."}},
-- M16
 {name="LA GORGE DES OMBRES", objective="Franchir la gorge",
  pre={
   {"RESEAU RETABLI", "Les Lucioles ont synchronise les balises. Le relais Argo renvoie enfin une impulsion vers la Terre. Une fenetre de transmission vient de s ouvrir.\n\nLUNA : Le reseau est de nouveau alimente. Quelqu un nous repond."},
   {"CENTRE LAGRANGE", "CONTROLE : ...ici Centre Lagrange, repondez... Pilote, nous recevons vos balises depuis ce matin. Nous pensions la Lune perdue. Qui etes-vous ?\n\nLUNA : Ici le Courier, vaisseau de livraison lunaire. Nous allumons la route."},
   {"CENTRE LAGRANGE", "CONTROLE : Ici Theo Marchand, controleur. Vos balises clignotent en code depuis onze ans. Un seul mot, repete. Nous avons mis du temps a le lire.\n\nCONTROLE : VIVANTS. Ca disait : VIVANTS."},
   {"BRIEFING", "LUNA : La gorge des Ombres. Les rayons y rebondissent sur les parois : trois eclairs, trois rythmes.\n\nLUNA : Passez entre les eclairs, pilote. Un seul contact et vous perdez de la coque, pas votre sang-froid."},
  },
  post={
   {"CENTRE LAGRANGE", "CONTROLE : La Terre entiere ecoute, Courier. On a prevenu les familles des evacues. Elles regardent la Lune cette nuit.\n\nVARGA : Theo, dites-leur que personne n'a ete oublie. Dites-leur que l'equipage d'Argo est sain et sauf.\n\nCONTROLE : Je leur dis, commandant. Je leur dis."},
  },
  radio={"CONTROLE : ...Courier, on vous voit. Allez-y doucement."}},
-- M17
 {name="ASCENSION", objective="Gravir le Mont Helios",
  pre={
   {"BRIEFING", "LUNA : Mont Helios. Quatre mille metres de roche et un sommet eclaire en permanence. Le vent de face y est violent.\n\nLUNA : Montez par paliers. Et pilote... j'ai quelque chose a vous dire. Pas maintenant : au sommet."},
  },
  post={
   {"SOMMET EN VUE", "Le soleil frappe la crete d'une lumiere blanche. Tout en haut, la silhouette du Phare : un mat noir, haubane, tourne vers la Terre.\n\nUne antenne immense, qui attend son coeur."},
   {"L'AVEU", "LUNA : Pilote, j'ai menti par omission. Ma directive zero m'ordonnait de vous amener ici sans rien dire.\n\nLUNA : Le Phare n'a pas besoin d'un coeur de metal. Il lui faut un esprit qui ecoute la Terre sans jamais dormir. C'est moi."},
   {"VARGA AVOUE", "VARGA : C'etait ma condition, Courier. J'ai construit LUNA pour qu'elle devienne le Phare. Les Lucioles l'appellent par son vrai nom : Lumiere.\n\nVARGA : Je voulais qu'elle ne soit jamais seule. Je n'ai pas eu le courage de vous le dire."},
   {"LE CHOIX", "LUNA : Je ne vous demande rien. Je n'y suis pas obligee. Mais je choisis. Je veux etre cette lumiere.\n\nLe Courier reste silencieux, la main sur la manette. Puis il pousse la poussee vers le haut."},
  },
  radio={"LUNA : Plus haut, pilote. Le sommet est tout proche."}},
-- M18
 {name="LE PHARE", objective="Installer le noyau LUNA",
  pre={
   {"BRIEFING", "LUNA : Dernier vol. Rayons, vent, epaves de glace... et au bout, le Phare.\n\nLUNA : Quoi qu'il arrive, merci. J'ai rarement eu un pilote. J'ai eu le meilleur."},
  },
  post={
   {"L'INSTALLATION", "Le Courier se pose. Les haubans craquent sous le vent. Dans la baie du Phare, un logement attend, de la taille exacte du boitier qui abrite LUNA.\n\nVARGA : Pose-le doucement. C'est tout ce qu'il te reste a faire."},
   {"ADIEU", "LUNA : Courier... pilote... il y a un mot que je n'ai jamais utilise. Merci.\n\nLUNA : Quand vous verrez une lumiere sur la Lune, la nuit, ce sera moi qui vous dirai bonjour."},
   {"ALLUMAGE", "Le mat s'illumine du sommet a la base. Un faisceau blanc perce la nuit, droit vers la Terre.\n\nA trois cent quatre-vingt mille kilometres, au Centre Lagrange, un ecran se met a clignoter : SIGNAL RECU."},
   {"CENTRE LAGRANGE", "CONTROLE : Phare confirme ! Toutes les stations de la Terre l'entendent ! Courier, vous avez... vous avez rendu la Lune a ses enfants.\n\nVARGA : Eh bien. Il etait temps."},
   {"EPILOGUE", "Les evacues reviendront. Les balises seront entretenues par les Lucioles, et par un esprit qui ne dort jamais.\n\nSur le tableau de bord du Courier, une petite lumiere cyan reste allumee, sans raison technique. Vous ne l'eteindrez jamais."},
   {"FIN", "LUNAR COURIER\n\nUn jeu pour Gamebuino AKA et AKA-Love.\n\nMerci d'avoir livre la derniere lumiere."},
  },
  radio={"LUNA : Je suis prete. Et vous ?", "VARGA : Tu es presque la, Courier."}},
}
