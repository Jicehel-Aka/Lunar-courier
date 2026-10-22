# LUNAR COURIER

Jeu narratif d'atterrissage lunaire en Lua : 18 missions, 3 chapitres, musique et effets sonores, sauvegarde.
Un seul code pour la **Gamebuino AKA** (runtime [AKA-Love](https://github.com/Jicehel-Aka/akalove)) et le **PC** (LOVE 11.x).

## Installer
- **AKA** : dezipper `lunar-courier-aka-sdcard-*.zip` a la racine de la carte SD (cree `AKA_Love/games/lunar_courier/`), puis choisir le jeu dans AKA-Love.
- **PC Windows** : dezipper `lunar-courier-pc-windows-x64-*.zip`, lancer `lunar-courier.exe`.
- **PC (tous systemes)** : installer LOVE 11.x puis `love lunar-courier-*.love` (ou `love game`).

## Langues et clavier
- **6 langues** : francais (par defaut), anglais, portugais, allemand, espagnol, italien. Textes d'histoire, aide, options et libelles de touches suivent la langue immediatement. Les textes sont dans `game/src/text_<code>.lua`, l'interface dans `game/src/i18n.lua` (ASCII pur : accents et umlauts sont translitteres, AKA-Love ne les dessine pas). Traductions de DE/ES/IT/PT : a faire relire par des locuteurs natifs.
- **Clavier PC** : AZERTY (FR), QWERTZ (DE) ou QWERTY (autres langues), choisi automatiquement avec la langue tant que vous ne le changez pas dans le menu. AZERTY : Q / D / Z en plus des fleches ; QWERTY et QWERTZ : A / D / W.
- Les libelles affichent la **vraie touche** : sur PC `ESPACE` / `SPACE` / `ESPACO` / `LEERTASTE` / `ESPACIO` / `SPAZIO`, `X`, `C`, `V`, `ECHAP` / `ESC` ; sur AKA `A`, `B`, `C`, `D`, `MENU` (les commandes de la console ne changent pas avec la langue). La detection se fait par `love.system.getOS()` ("Other" = AKA-Love).

## Commandes
| Action | Console AKA | PC |
|---|---|---|
| Tourner | D-pad gauche/droite | fleches (+ Q/D en AZERTY, A/D en QWERTY) |
| Propulseur | D-pad haut | fleche haut (+ Z en AZERTY, W en QWERTY) |
| Valider / passer une carte | A | Espace / Entree |
| Pause | C | C ou P |
| Recommencer la mission | D | V ou R |
| Menu systeme | MENU (appui court) | Echap |
| Capture d'ecran | MENU (appui long) ou menu | F12, appui long sur Echap, ou menu |
| Musique on/off | B | X ou M |

Menu systeme (toutes les ecrans, met le jeu en pause) : Reprendre, Commandes, Langue, Clavier, Musique, Capture d'ecran, Credits, Retour au titre, Quitter / Retour au lanceur.
Ecran titre : Continuer, Nouvelle partie, choix du chapitre (progression sauvegardee automatiquement avec la langue et le clavier).

**Captures** : `love.graphics.captureScreenshot` ; sur PC le fichier `lunar_NNNN.png` est ecrit dans le dossier de sauvegarde LOVE (`%APPDATA%\LOVE\lunar-courier` sous Windows). Le runtime AKA-Love n'a pas cette fonction pour l'instant : le jeu affiche alors "capture indisponible" (a ajouter cote akalove pour ecrire sur la carte SD).

## Finitions
Texte des cartes ecrit lettre a lettre (un appui l'affiche en entier), volets de transition entre ecrans, secousse a l'impact, jauge de carburant clignotante, rang de fin de mission (C/B/A/S d'apres carburant + coque) avec meilleur rang sauvegarde.

## Niveaux
Mondes de 1280 a 3200 px (2 a 5 ecrans) avec camera a defilement, reliefs lointains en parallaxe selon le decor (plaine, cratere, canyon, ruines, epaves, pics), 12 types de decors, fleche de rappel vers la cible hors champ et mini-carte. Les portraits de LUNA, Varga et du Controle s'affichent sur les cartes d'histoire.

## Histoire
- Ch.1 (M1-6) : la colonie silencieuse et le reseau de balises.
- Ch.2 (M7-12) : la face cachee, la voix d'Argo, le commandant Varga.
- Ch.3 (M13-18) : le Mont Helios, les tempetes solaires, les Lucioles, le Centre Lagrange... et la verite sur LUNA.
56 cartes narratives entre les missions, chacune illustree (panoramas pixel art dans `game/assets/scenes/`, balayage lent sur les plus larges).

## Verification automatique (GitHub Actions)
`tests/run_tests.py` charge le jeu avec un faux `love` strict (memes fonctions que AKA-Love, memes contraintes), joue les 18 missions avec un pilote automatique, dessine tous les ecrans, controle la longueur des textes (pire cas : 1 caractere = taille de police en px), l'absence de polygones concaves, de non-ASCII, et refait le parcours sans audio ni systeme de fichiers.
Chaque push sur `main` : verifs -> paquets AKA + PC -> Release (version mineure +1).

## Points non verifiables sans console
Cout d'affichage des grands mondes sur la console, dessin des images (echelle 2, panoramas decales), memoire, `captureScreenshot` sur AKA, sens de `newFont(n)` (px virtuels/physiques), taux d'echantillonnage et chemin des WAV (22050 Hz par defaut ; regenerer avec `python3 game/tools/make_audio.py 16000` si besoin), fluidite sur la console, difficulte reelle des chapitres 2 et 3.

## Reglages
Haut de `game/src/game.lua` (poussee, rotation, seuils d'atterrissage). Gravite, vent, carburant : par mission dans `game/src/data.lua`.
