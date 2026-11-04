# Glossaire

- **Camp** : plateau du joueur ou de l'adversaire.
- **Colonne** : un des six couloirs de combat alignés entre les deux camps, numérotés 1 à 6 de gauche à droite.
- **Ligne d'attaque** : ligne de chaque camp qui effectue normalement les attaques de fin de tour.
- **Ligne de défense** : ligne de soutien/protection, n'attaque normalement pas.
- **Colonne contestée** : colonne contenant au moins une créature de chaque camp.
- **Déplacement naturel** : changement de ligne dans la même colonne payé en mana.
- **Déplacement par effet** : mouvement causé par une carte/capacité, dérogatoire aux limites naturelles.
- **Piétinement** : capacité qui transmet les dégâts résiduels après élimination effective d'une cible vers la suivante, jusqu'au héros.
- **FIFO** : first in first out, résolution des capacités en attente dans l'ordre d'entrée.
- **Source** : carte/instance ayant généré un effet ; **cible** : entité explicitement désignée.


## Termes ajoutés en v0.8

- **Quantum attribué** : part entière de la perte nette de PV créditée à une source après la méthode des plus grands restes ; peut être zéro pour une source qui déclenche `ON_DAMAGE_DEALT`.
- **Participation collective** : reconnaissance de toutes les sources ayant contribué positivement au total de dégâts qui a fait perdre au moins 1 PV à une cible.
- **Vol de vie** : soin déclenché et différé d'une source, calculé sur le quantum attribué.
- **Prévention létale** : interception immédiate d'une mort potentielle ; événement `ON_LETHAL_PREVENTED` généré après le calcul, résolu ultérieurement.

## Termes v0.9
- **Soin demandé** : quantité brute de soin avant plafonnement ; **soin effectif** : PV réellement restaurés ; **surplus de soin** : quantité non appliquée.
- **`ON_HEAL`** : événement émis si ≥1 PV restauré ; une fois par cible/opération atomique de soin simultané.
- **Effet temporaire** : instance de bonus ou malus dont l'échéance, le camp applicateur, l'ordre d'application et l'ID sont mémorisés.
- **`ON_EFFECT_EXPIRED`** : événement individuel de disparition programmée d'un effet, après retrait atomique de tous les effets arrivés à échéance au même instant.

## Référence croisée v1.2

**Mal d’invocation après contrôle (Q105–Q106)** : restriction d’attaque pour le premier tour personnel du nouveau contrôleur, même transfert hors tour ou retour. **Chaîne/branche de déclenchements (Q111–Q114)** : causalité des événements FIFO ; interruption ciblée sans rollback et conservation des événements déjà enfilés. Voir [règles détaillées](01-combat/turn-control-and-loop-safety.md).



## Termes visuels (v1.4)

- **Carte d'origine** : recto de référence de la carte, conservant illustration, valeurs imprimées et capacités initiales dans la vue d'inspection ; distinct des modifications de combat.
- **Jeton de plateau** : représentation compacte d'une créature, sous forme de médaillon, avec ATQ effective et PV actuels.
- **Panneau latéral d'inspection** : vue de l'ensemble des états actifs et du calcul des valeurs finales. Pas une deuxième carte réécrite.
- **ATQ effective** : ATQ applicable calculée selon les modificateurs actifs.
- **État défensif effectif** : PV actuels/max effectifs, armure et bouclier distincts ; **aucune statistique DEF indépendante validée**.
