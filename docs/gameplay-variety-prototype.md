# Prototype de variété de gameplay — Lunar Courier

## Objectif

Valider une séquence scénarisée qui rompt le rythme du pilotage sans transformer Lunar Courier en collection de mini-jeux indépendants. Le pilotage reste le mode principal ; les autres modes sont des séquences courtes déclenchées par les besoins du récit.

## Accès au prototype

Sur l'écran titre, appuyer sur `E` sur PC pour lancer la salle de démonstration. Cette entrée est volontairement optionnelle : elle ne modifie pas le déroulement normal des 18 missions pendant la phase de test. Sur AKA, la même salle se lance avec le bouton `D` ; l'écran titre l'indique.

## Première tranche verticale

1. **Approche et atterrissage** : réutiliser le gameplay existant, sans changer la physique.
2. **Transition cinématique 2D** : courte scène en pixel art qui présente une installation silencieuse. Une touche permet d'accélérer le texte, puis de continuer.
3. **Exploration à pied** : première salle de démonstration en vue de côté, accessible par `E` depuis le titre sur PC. Le personnage marche horizontalement et interagit avec le terminal orange. C'est un prototype visuel préliminaire, pas encore une séquence liée à une mission.
4. **Interaction terminal** : interaction contextuelle de réparation, déclenchée quand le personnage est proche du terminal. Le mini-jeu de réparation reste à implémenter.
5. **Retour au récit** : une révélation courte, puis reprise du flux de mission normal.

L'isométrie sera un second prototype distinct : elle demande davantage d'art, de collision et de navigation, et ne doit être engagée qu'après validation de la tranche verticale.

## Principes de conception

- Chaque mode doit servir une action précise du scénario.
- Une séquence secondaire dure idéalement de 20 secondes à 3 minutes.
- Les contrôles sont affichés à l'écran et adaptés au clavier PC français AZERTY comme aux boutons de l'AKA.
- Aucun texte essentiel ne doit dépendre de la couleur seule.
- Les écrans sont conçus pour 640×480 virtuels et vérifiés à 320×240 sur AKA.
- La sauvegarde de campagne et les 18 missions restent compatibles.
- Les séquences sont facultatives à rejouer lorsque cela ne nuit pas à la compréhension de l'histoire.
- Les assets existants sont réutilisés quand ils conviennent ; pas de dépendance à des téléchargements pendant l'exécution.

## Architecture proposée

Ajouter un petit contrôleur de séquence isolé du code de pilotage, avec les responsabilités suivantes :

- état local de la séquence (position, interaction courante, progression) ;
- fonctions d'entrée, mise à jour et dessin ;
- événement de fin explicite, afin que le moteur principal reprenne la main ;
- aucune modification de la physique du vaisseau ni du format des sauvegardes.

L'intégration se fera progressivement dans le gestionnaire d'états existant (`title`, `card`, `game`, `debrief`) plutôt que de remplacer le moteur actuel.

## Critères d'acceptation

- Parcours complet sans blocage clavier et sans perte de progression.
- Toutes les commandes essentielles visibles, avec AZERTY PC et boutons AKA.
- Dessin sans primitives incompatibles avec AKA-Love.
- Aucun débordement de texte aux tailles de police prévues par le projet.
- Tests automatisés avec les mocks LÖVE existants, y compris sans audio ni système de fichiers.
- Vérification visuelle et des commandes sur matériel AKA avant de déclarer la tranche validée.

## Ordre de travail

1. Repérer une mission existante dont le récit justifie l'exploration ; ne pas réécrire les 18 missions d'emblée.
2. Construire et tester la transition cinématique.
3. Ajouter la salle d'exploration et l'interaction.
4. Ajouter le terminal et le retour au récit.
5. Vérifier PC, tests CI et AKA, puis décider si l'isométrie est le prochain mode à développer.
