# Direction artistique — Lunar Courier

## Regles communes

- **Lecture** : silhouettes et interactifs lisibles sur le petit ecran AKA ; contraste de luminance avant les details.
- **Palette de marque** : bleu nuit `#030816`, acier bleu `#20394D`, cyan signal `#4FD8D2`, ambre de securite `#FFB34D`, rouge alerte `#F45D55`, ivoire combinaison `#D7E2E5`.
- **Materiaux** : grandes masses sombres, bords metalliques froids, panneaux avec marquages repetes, traces d'usure localisees. Eviter les aplats monochromes et les objets formes uniquement de rectangles.
- **Eclairage** : source cyan pour les interfaces, ambre pour les actions et la securite, rouge seulement pour le danger. Une lueur est suggeree par des contours et des valeurs adjacentes, pas par une transparence couteuse.
- **Mouvement** : animations courtes et fonctionnelles (balises, ecrans, ventilateurs, particules de poussiere, panneaux sous tension), sans mouvement permanent qui nuit a la lisibilite.
- **Compatibilite** : art en pixel-art net, filtre nearest, silhouettes sans petits details indispensables. Toute scene doit rester comprehensible en 320x240 ; le PC peut afficher la meme scene en 640x480.
- **Interaction** : chaque objet utilisable a une forme reconnaissable, un etat inactif / actif distinct et un retour visuel immediat.

## Bibliotheque d'elements reutilisables

1. Cadres structurels, nervures, boulons, joints et conduits.
2. Sols avec rails, plaques, vis, bandes de securite et ombres de contact.
3. Panneaux de maintenance : ecran, connecteurs, voyants et capot ouvrable.
4. Terminaux : ecran de texte, lecteur de journal et indicateur de progression.
5. Portes et sas : montants, verrou, joint lumineux, etapes d'ouverture.
6. Modules de lumiere : plafonnier froid, lampe d'urgence rouge, lampe de travail ambre.
7. Silhouette du pilote : casque, visiere, sac dorsal, articulations, bottes et animation de marche/saut.
8. FX sobres : etincelles, poussiere en apesanteur, vapeur, court-circuit et scintillement.

## Variations de missions

| Mission / sequence | Identite visuelle | Nouveaute de jeu | Elements a produire |
| --- | --- | --- | --- |
| M3 — Station fantome | Acier bleu, cyan clinique, alarmes ambre/rouges ; grande baie lunaire | Traverser les cables, remettre trois relais en ordre, consulter le journal | Modules de relais, cable au sol, baie vitree, terminal et journal |
| M10 — Epave | Noir carbone, orange de balise, lumiere froide venant d'une coque dechiree | Fouiller la boite noire et reconstituer les donnees | Fuselage ouvert, debris flottants, balise, lecteur de boite noire |
| M11–12 — Reparation de capsule | Gris pale, ambre de soudure, cyan de diagnostic | Choisir l'ordre des reparations sous contrainte de temps/energie | Capsule en coupe, panneau de diagnostic, outil et jauges |
| M15 — Lucioles | Bleu profond, verts bioluminescents et silhouettes tres sombres | Observer les rythmes lumineux et resoudre une sequence calme | Essaims de particules, plantes/cristaux lumineux, marqueurs de rythme |
| M17 — Choix de LUNA | Palette de base, mais contraste reduit et signaux ambigus | Interagir avec l'interface et assumer un choix narratif | Portrait/interface de LUNA, etats d'interface, pictogrammes de decision |

## Critere de validation

Avant d'etendre une scene : capture a la resolution AKA, lecture des silhouettes a taille reelle, controles AZERTY PC et commandes AKA verifies, puis test de reprise/retour au menu. Les dessins en primitives sont un prototype de composition ; ils ne doivent pas etre confondus avec des sprites finaux. Remplacer progressivement les formes structurantes par des sprites/atlas coherents des que les captures de reference sont validees.
