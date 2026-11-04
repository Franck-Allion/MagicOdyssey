# Héros et mana — v0.5

**Statut : règles Q30–Q34 VALIDÉES ; chiffres initiaux OUVERTS.**

Dépendances : [turn-sequence](turn-sequence.md), [draw-and-fatigue](draw-and-fatigue.md), [hand-and-discard](hand-and-discard.md).

## VALIDÉ
- **MANA-001 — Q30** : système hybride comprenant mana initial, capacité actuelle, mana maximum (plafond) et mana disponible.
- **MANA-002 — Q31** : restauration intégrale du mana disponible au début du tour personnel ; mana inutilisé perdu en fin de tour.
- **MANA-003 — Q32** : croissance naturelle de capacité +1 par tour personnel ; améliorable par caractéristiques du héros, artefacts et sorts jusqu'à la fin du combat.
- **MANA-004 — Q33** : un bonus de croissance reçu pendant un tour ne change pas la capacité ni le mana disponibles immédiatement ; il prend effet à la croissance du prochain tour personnel.
- **MANA-005 — Q34** : une hausse du plafond ne donne ni capacité ni mana immédiatement. Un gain immédiat peut amener le mana disponible au-dessus de la capacité actuelle, mais pas au-dessus du plafond applicable ; le surplus disparaît en fin de tour.
- Les caractéristiques du héros peuvent être améliorées hors combat ; les coûts et valeurs de départ sont à définir dans la progression RPG.

## Exemple testable
Héros : capacité actuelle 5, plafond 8, mana disponible 2. Effet +3 au plafond : plafond 11, capacité 5, mana 2. Effet gagne 4 mana : mana disponible 6, capacité 5, plafond 11. Fin de tour : surplus et mana inutilisé perdus.

## OUVERT
Valeurs initiales et maximales des héros ; croissance lors du premier tour (proposition : pas de croissance) ; baisses de plafond et mana disponible ; ordre des modificateurs simultanés ; interaction entre bonus de début de tour et prochaine croissance ; seuil minimal du mana.


## Référence de progression v1.9

**Progression entre combats et ascensions :** voir [EXP et améliorations du héros Q179/Q184](../03-progression/rewards-rarity-and-ascension.md). Les seuils d’EXP restent ouverts.
