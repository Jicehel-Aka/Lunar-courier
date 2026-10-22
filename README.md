# LUNAR COURIER - v0.9

Jeu narratif d'atterrissage lunaire en Lua : 18 missions, 3 chapitres, musique et effets sonores, sauvegarde.
Un seul code pour la **Gamebuino AKA** (runtime [AKA-Love](https://github.com/Jicehel-Aka/akalove)) et le **PC** (LOVE 11.x).

## Installer
- **AKA** : dezipper `lunar-courier-aka-sdcard-*.zip` a la racine de la carte SD (cree `AKA_Love/games/lunar_courier/`), puis choisir le jeu dans AKA-Love.
- **PC Windows** : dezipper `lunar-courier-pc-windows-x64-*.zip`, lancer `lunar-courier.exe`.
- **PC (tous systemes)** : installer LOVE 11.x puis `love lunar-courier-*.love` (ou `love game`).

## Commandes
| Action | Console AKA | PC |
|---|---|---|
| Tourner | D-pad gauche/droite | fleches (Q/D) |
| Propulseur | D-pad haut | fleche haut (Z/W) |
| Valider / passer une carte | A | Espace / Entree |
| Pause | C | C ou P |
| Recommencer la mission | D | V ou R |
| Titre | MENU | Echap |
| Musique on/off | B | X ou M |

Ecran titre : Continuer, Nouvelle partie, choix du chapitre (chapitres debloques par la progression, sauvegardee automatiquement).

## Histoire
- Ch.1 (M1-6) : la colonie silencieuse et le reseau de balises.
- Ch.2 (M7-12) : la face cachee, la voix d'Argo, le commandant Varga.
- Ch.3 (M13-18) : le Mont Helios, les tempetes solaires, les Lucioles, le Centre Lagrange... et la verite sur LUNA.
56 cartes narratives entre les missions, chacune illustree (panoramas pixel art dans `game/assets/scenes/`, balayage lent sur les plus larges).

## Verification automatique (GitHub Actions)
`tests/run_tests.py` charge le jeu avec un faux `love` strict (memes fonctions que AKA-Love, memes contraintes), joue les 18 missions avec un pilote automatique, dessine tous les ecrans, controle la longueur des textes (pire cas : 1 caractere = taille de police en px), l'absence de polygones concaves, de non-ASCII, et refait le parcours sans audio ni systeme de fichiers.
Chaque push sur `main` : verifs -> paquets AKA + PC -> Release (version mineure +1).

## Points non verifiables sans console
Sens de `newFont(n)` (px virtuels/physiques), taux d'echantillonnage et chemin des WAV (22050 Hz par defaut ; regenerer avec `python3 game/tools/make_audio.py 16000` si besoin), fluidite sur la console, difficulte reelle des chapitres 2 et 3.

## Reglages
Haut de `game/src/game.lua` (poussee, rotation, seuils d'atterrissage). Gravite, vent, carburant : par mission dans `game/src/data.lua`.
