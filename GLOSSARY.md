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


## Vocabulaire de progression — Q175–Q184

- **Ascension / tentative** : progression de la tour en cours, conservant temporairement artefacts et améliorations du héros, et permettant de construire les synergies du deck.
- **Déblocage permanent** : permission persistante de voir de nouvelles cartes ou de nouveaux artefacts dans les pools de draft futurs ; n’accorde pas leur possession au démarrage.
- **Draft de carte** : choix d’une carte parmi trois propositions éligibles, ou refus contre ressources (Q177–Q178).
- **Récompense automatique** : monnaie et EXP dues pour toute victoire, indépendantes du draft (Q179).
- **Récompense exceptionnelle de boss** : proposition stratégique entre catégorie carte, artefact et amélioration du héros, en sus des gains renforcés (Q180).
- **Rareté** : Commun (blanc), Peu commun (bleu), Rare (rouge), Épique (violet), Légendaire (or) ; cinq niveaux, sans mythique (Q181).
- **Artefact de run** : objet conservé pendant une ascension, soumis aux emplacements évolutifs (Q182–Q183).
- **Amélioration du héros** : progression temporaire d’une caractéristique ou d’une capacité au cours de l’ascension (Q184).


## Termes de progression v2.0

- **Sphérier :** réseau de nœuds permanents de caractéristiques et capacités du héros, avec branches thématiques, passerelles et prérequis (Q185–Q189).
- **Point de compétence :** ressource permanente octroyée par les niveaux du héros, dépensable dans le sphérier (Q186–Q188).
- **Réinitialisation de sphérier :** remboursement intégral et gratuit des points investis, possible uniquement hors ascension (Q189).
- **Copie de tentative :** instance de carte/artefact possédée pendant l’ascension, perdue à la fin selon Q182.
- **Catalogue / pool de draft débloqué :** collection persistante d’identités de cartes pouvant être générées lors de futures récompenses. Débloqué ne signifie ni offert ni garanti (Q182, Q194).
- **Exclusivité marchande de tour :** carte initialement achetable seulement dans des commerces de tours désignées ; après achat, devient débloquée pour les drafts futurs (Q193–Q194).
- **Rendement décroissant :** récompense répétable de tour ancienne moins intéressante à mesure que le héros gagne en niveau, sans modification de la difficulté des ennemis (Q192).

## Vocabulaire v2.1

- **Exemplaire de deck** : copie d’une identité de carte acquise dans le deck de l’ascension, soumise au plafond de quatre ; ne compte pas les copies transitoires créées au combat.
- **Pool éligible** : cartes autorisées pour une récompense ou un commerce après restrictions de tour, rareté et plafond de copies, **avant tirage**.
- **Renouvellement** : opération payante tirant un nouveau stock pour une instance de marchand, avec compteur individuel et coût croissant.
- **Compensation automatique** : ressources de Q178 accordées quand le pool de récompense de carte est vide, sans UI de sélection.
