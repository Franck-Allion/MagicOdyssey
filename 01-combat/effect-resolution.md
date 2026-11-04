# Effets composés, opérations atomiques et dégâts simultanés

**VALIDÉ Q27, Q55, Q60–Q64.** Dépendances : [ciblage](targeting.md), [file FIFO](event-queue.md), [dégâts](damage-resolution.md), [prévention](damage-prevention.md), [victoire](victory-and-defeat.md).

## Effets composés — VALIDÉ Q61–Q62
- **EFF-001** — Exécuter les opérations dans l'ordre écrit par la carte. Par défaut elles sont **indépendantes** : l'échec de l'une ne supprime pas les suivantes.
- **EFF-002** — Une opération explicitement conditionnelle (ex. « si détruite ainsi ») dépend de la réussite constatée de sa condition.
- **EFF-003** — Une opération indivisible valide tous ses prérequis avant modification ; en cas d'échec, elle ne modifie rien (ex. permutation).
- **EFF-004** — Revalider les cibles de chaque opération au moment de la résolution ; poursuivre les autres opérations indépendantes si une cible manque.
- **EFF-005 (Q62)** — Enregistrer les capacités déclenchées dans la FIFO au cours de la résolution, mais ne résoudre **aucune capacité nouvelle** avant la fin de l'effet composé en cours. Ne pas devancer les événements antérieurs.
- **EFF-006 (Q55)** — Une résurrection multiple réalise toutes ses tentatives successives, avec succès partiels, avant résolution des capacités générées. **Exception existante :** la pioche multiple Q42 résout ses effets entre les tentatives.

## Opérations atomiques, victoire — VALIDÉ Q63
- **ATOM-001** — Calculer tous les résultats d'une opération atomique et ses préventions/remplacements autorisés avant un commit cohérent.
- **ATOM-002** — Appliquer ensemble les changements simultanés ; aucun test de victoire intermédiaire ne doit dépendre d'un ordre technique d'écriture.
- **ATOM-003** — Après le commit, vérifier immédiatement les conditions de victoire/défaite et, si terminales, abandonner les opérations restantes et file d'effets. Deux héros morts dans un même commit : défaite joueur (Q16).
- **ATOM-004** — Les préventions de létalité interviennent avant le commit ; les capacités ordinaires déclenchées ne peuvent pas sauver rétroactivement un héros déjà mort.

## Dégâts simultanés — VALIDÉ Q64
- **SIM-001** — Regrouper par cible les composantes de dégâts **compatibles** appartenant à une même opération simultanée.
- **SIM-002** — Appliquer **une fois** à chaque total compatible les protections pertinentes, suivant l'ordre Q22 armure → bouclier → PV → prévention létale.
- **SIM-003** — Maintenir distinctes les composantes que le texte des cartes soumet à des protections différentes ; ne jamais les fusionner en gommant une résistance spécifique.
- **SIM-004** — Commit simultané final, contrôle victoire immédiat, puis enregistrement ordonné des événements si le combat continue. Les déclenchements ordinaires attendent la fin de l'effet composé (Q62).

## Exemples validés par principe
- 4 et 3 dégâts simultanés compatibles sur la même cible => 7 dégâts à protéger comme un total (si aucune règle spéciale ne les sépare).
- Dégâts simultanés aux deux héros avec 3 PV chacun et perte de 5 PV non prévenue => défaite joueur, sans victoire transitoire.
- Sort « 3 dégâts à une créature ; soigne 2 ; pioche 1 » : la mort de la cible met `ON_DEATH` en file ; le soin et la pioche ont lieu avant l'exécution de ce déclenchement, sauf mort immédiate d'un héros.

## PROPOSÉ / OUVERT — ne pas déduire
- **OUVERT** : définir « compatible » en présence d'éléments, résistances, réductions par source, armures de nature distincte ou dégâts ignorant le bouclier. Les résistances élémentaires ne sont pas validées.
- **OUVERT** : granularité des déclenchements `ON_DAMAGE_TAKEN` / `ON_DAMAGE_DEALT` sur plusieurs composantes agrégées (par source ou par total), notamment pour les capacités « chaque fois ».
- **OUVERT** : départage de plusieurs protections de même classe et le calcul exact des protections létales, hormis les règles déjà validées Q23–Q24.
- **OUVERT** : politique complète de rollback en cas d'échec technique d'une opération atomique ; ne pas confondre cet échec technique avec les règles de jeu.

## Tests
[TEST-052 à TEST-064](../09-technical/acceptance-tests.md).


## Complément simultanéité — v0.8 (Q65–Q74)

Au terme de chaque opération atomique : appliquer les protections, la prévention létale éventuelle et calculer la perte nette de PV. Contrôler les conditions de victoire sans intercaler les réactions déclenchées ; établir ensuite le contexte d'attribution entière (plus grands restes) et les événements d'absorption et de dégâts. Voir [attribution détaillée](damage-attribution.md).

## Extensions Q77 et Q80–Q84
Soins simultanés compatibles : regrouper par cible, limiter aux PV manquants et répartir aux sources par plus grands restes ; unique `ON_HEAL` si soin effectif positif. Tous les effets expirant au même instant sont retirés dans une opération atomique et ne peuvent produire de létal intermédiaire ; ensuite **un `ON_EFFECT_EXPIRED` par effet** est mis en FIFO. Voir [soins](healing.md) et [effets temporaires](temporary-effects.md).

## Référence croisée v1.1

Voir [transferts de contrôle](control-transfers.md) pour transferts croisés et commit atomique Q101–Q103.

## Référence croisée v1.2

Expirations « après échéance » en opération atomique distincte (Q110) ; protections anti-boucles ne font aucun rollback (Q111–Q114). Voir [capacités de tour et boucles](turn-control-and-loop-safety.md).


## Référence croisée v1.3 — commits et empreintes

Après chaque commit atomique, une empreinte canonique est enregistrée pour le rejeu ; sauvegarde seulement aux points cohérents entre commits. Voir [Q121–Q124](../09-technical/causal-budgets-and-replay.md), [tests](../09-technical/acceptance-tests.md).


## Complément v1.7 — Cohérence atomique des caractéristiques

Voir [Q161–Q164](../02-art-direction/spells-auras-and-continuous-effects.md) : les effets continus dérivés sont cohérents avant toute lecture logique pertinente et à chaque commit atomique ; les transitions visuelles peuvent être groupées, mais les opérations logiques validées, événements et réactions FIFO restent inchangés.
