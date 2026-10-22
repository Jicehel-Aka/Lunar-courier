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
