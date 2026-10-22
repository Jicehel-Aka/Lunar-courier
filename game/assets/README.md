# Lunar Courier — catalogue des ressources graphiques

Ce dossier accueille les ressources illustrées du jeu. Les images de référence produites pendant la conception sont des planches de travail : elles doivent être découpées en sprites individuels avant intégration, jamais réduites en une seule image pour l'écran 320×240.

## Organisation

- `portraits/crew/` — portraits de l'équipage : Capitaine, Léa, Dimitri, Sora, Kellen, Amara, Tomas.
- `portraits/expressions/` — variantes d'expressions pour les dialogues.
- `portraits/luna/` — portrait de LUNA et variantes veille, urgence, maintenance.
- `radio/` — portraits et panneaux de transmission.
- `ui/` — icônes de communication, bulles, accessoires et badges.

## Contraintes d'intégration

- PNG avec transparence réelle pour les portraits et icônes.
- Garder une version source lisible et une variante optimisée pour l'affichage 320×240.
- Les sprites doivent être chargés une fois, pas recréés à chaque frame.
- Le moteur doit rester jouable si une image manque : dessin Lua de secours et avertissement de diagnostic.
- Ne pas découper automatiquement cette planche à partir d'une capture compressée quand le fichier source individuel existe ; les bordures cyan et le fond magenta de la planche ne font pas partie des portraits.

## État

La planche de référence « 08 — Personnages et transmissions » a été fournie dans la conversation. Elle sert de guide visuel, mais le fichier original des sprites séparés n'est pas encore disponible dans le dépôt. Les fichiers finaux doivent être ajoutés ici avant de remplacer les dessins de secours dans les écrans du jeu.


## Illustrations des cartes d'histoire (integrees)

`scenes/*.png` : 27 panoramas (320x75 pixels, ou jusqu'a 400x75 pour un balayage lent) decoupes dans les planches
`Lunar-Assets-1.zip` (planche "10 - Panoramas narratifs"). Chaque carte d'histoire en affiche un en bandeau ; l'association
carte -> image est dans `src/data.lua` (`D.art`, une entree par carte, dans l'ordre pre puis post).
- 1 pixel d'image = 1 pixel de l'ecran AKA (dessin en echelle 2 dans le repere virtuel 640x480).
- Chargement a la demande, 3 images au plus en memoire (`src/art.lua`) ; si une image manque ou si `newImage` n'existe
  pas, le bandeau de secours dessine en Lua (portrait de LUNA) prend la place.
- `tests/run_tests.py` verifie que chaque carte a son image, que les fichiers existent et font 75 px de haut (>= 320 de large).
