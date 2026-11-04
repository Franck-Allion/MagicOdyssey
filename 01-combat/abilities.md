# Capacités et mots-clés

**Statut : principes validés, catalogue à concevoir.** Dépend de [event-queue.md](event-queue.md), [damage-resolution.md](damage-resolution.md), [movement.md](movement.md).

## VALIDÉ
- Les créatures peuvent avoir des **passifs** (exemple illustratif : bonus lorsqu'elles sont en défense) et des **actifs** nécessitant potentiellement du mana.
- Des sorts peuvent modifier le plateau, cibler unités/héros, et déplacer des créatures.
- Les capacités déclenchées par dégâts et morts se résolvent après l'attaque en cours (FIFO).
- Les préventions/remplacements interviennent avant dégâts effectifs ; à détailler.
- **Piétinement** : transmission du résiduel uniquement si la cible est éliminée, jusqu'à la cible suivante et éventuellement au héros.
- Une capacité déclenchée reste en attente même si sa source disparaît.

## À distinguer dans les données
1. Passif conditionnel (état courant, recalcul de bonus).
2. Actif à coût (paiement, ciblage, effet).
3. Déclencheur (événement, mise en file, résolution différée).
4. Remplacement/prévention (avant effet).
5. Mot-clé (Piétinement).

## OUVERT
- Fréquence des actifs ; collisions de bonus ; déclencheurs d'entrée en ligne ; limites « une fois par tour » ; texte normalisé ; ordre des préventions.

## Extension v0.6 — VALIDÉ Q48–Q50, Q54
- Le retour par résurrection est une nouvelle invocation et déclenche les deux familles `ON_SUMMON` et `ON_RESURRECT` ; ordre invocation puis résurrection.
- L'état de la créature est restauré puis les nouveaux bonus de résurrection immédiats appliqués **avant** le déclenchement ; voir [resurrection](resurrection.md).
- Les événements `ON_DISCARD`, `ON_DEATH`, `ON_SPELL_USED`, `ON_CARD_RECOVERED`, `ON_CARD_RECYCLED`, `ON_CARD_BANISHED` sont différenciés selon [zone-events](zone-events.md).

## Extension v0.7 — VALIDÉ Q56–Q62
- Valeurs source lues à résolution, avec dernier état connu si source hors du plateau : [instance-identity](instance-identity.md).
- Capacités multicibles : succès partiels par cible ; opérations composées indépendantes par défaut, dépendances et indivisibilité explicites : [effect-resolution](effect-resolution.md), [targeting](targeting.md).
- Déclenchements FIFO pendant effet composé : mise en file immédiate, résolution après fin de l'effet (exception de la pioche multiple Q42).


## Capacités de dégâts et vol de vie — v0.8 (Q65–Q74)

Les événements `ON_DAMAGE_DEALT`, `ON_DAMAGE_TAKEN`, `ON_ARMOR_ABSORBED`, `ON_SHIELD_ABSORBED` et `ON_LETHAL_PREVENTED`, leurs conditions, charges numériques et ordre sont définis dans [attribution des dégâts](damage-attribution.md). En particulier, une source peut déclencher `ON_DAMAGE_DEALT` avec un quantum attribué de zéro ; le vol de vie utilise ce quantum, non le total collectif. Les capacités déclenchées sont différées dans [FIFO](event-queue.md).

## Déclenchements Q76–Q84
`ON_HEAL` uniquement à partir de 1 PV **effectivement** restauré ; un seul événement par cible/opération atomique pour soins simultanés compatibles. `ON_EFFECT_EXPIRED` une fois **par effet individuel** expiré, même si retrait atomique collectif ; réactions différées dans la FIFO. Les variations de PV maximum ne déclenchent ni `ON_HEAL` ni les événements de dégâts. Voir [soins](healing.md) et [effets temporaires](temporary-effects.md).

## Extension VALIDÉE Q86–Q93
Les capacités actives avant une expiration peuvent réagir aux effets expirés, même si elles ont été accordées par ces mêmes effets, ou si leur porteur meurt. Une capacité accordée à une créature utilise cette créature comme source de gameplay (origine historique conservée). Lecture dynamique des caractéristiques à la résolution si l'instance existe ; dernier état connu sinon. La prise de contrôle ne re-cible pas les capacités déjà en file. Voir [sources et contrôle](source-control.md).

## Référence croisée v1.2

**Q107–Q114** : captures de contexte des capacités de tour au déclenchement ; pour reprises FIFO après protection anti-boucle, événements déjà enfilés conservés et seules les nouvelles descendances bloquées. Voir [capacités de tour et boucles](turn-control-and-loop-safety.md).
