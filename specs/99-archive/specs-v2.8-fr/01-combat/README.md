# Combat — index

## Lecture par concept

| Concept | Fichier | Dépendances principales |
|---|---|---|
| Plateau et interception | [battlefield.md](battlefield.md) | [damage-resolution](damage-resolution.md) |
| Invocation | [summoning.md](summoning.md) | [battlefield](battlefield.md), [movement](movement.md) |
| Mobilité / permutation | [movement.md](movement.md) | [battlefield](battlefield.md), [summoning](summoning.md) |
| Tours et initiative | [turn-sequence.md](turn-sequence.md) | [damage-resolution](damage-resolution.md), [hero-deck-mana](hero-deck-mana.md) |
| Attaques / Piétinement | [damage-resolution.md](damage-resolution.md) | [damage-prevention](damage-prevention.md), [event-queue](event-queue.md) |
| Boucliers / armure | [damage-prevention.md](damage-prevention.md) | [damage-resolution](damage-resolution.md) |
| Déclenchements / FIFO | [event-queue.md](event-queue.md) | [abilities](abilities.md), [targeting](targeting.md) |
| Ciblage invalide | [targeting.md](targeting.md) | [event-queue](event-queue.md) |
| Capacités | [abilities.md](abilities.md) | [event-queue](event-queue.md) |
| Victoire et défaite | [victory-and-defeat.md](victory-and-defeat.md) | [damage-resolution](damage-resolution.md) |
| Héros, main, deck, mana | [hero-deck-mana.md](hero-deck-mana.md) | [turn-sequence](turn-sequence.md) |

**Règles encore ouvertes** : effets de remplacement non détaillés, prévention technique des boucles, événements spécialisés de modification de caractéristiques, priorité inter-familles des événements issus d’une expiration.

- [Pioche et fatigue](draw-and-fatigue.md) — Q36–Q38, Q41–Q42
- [Main, défausse, recyclage](hand-and-discard.md) — Q38–Q40, Q43–Q44


## Nouveaux modules v0.6
- [Bannissement](banishment.md) — Q45
- [Résurrection](resurrection.md) — Q46–Q52
- [Récupération et recyclage](recovery.md) — Q43, Q53
- [Transferts et événements de zones](zone-events.md) — Q44, Q54

## Nouveaux modules v0.7
- [Identité, instances et dernier état connu](instance-identity.md) — Q56–Q58
- [Effets composés, opérations atomiques et dégâts simultanés](effect-resolution.md) — Q55, Q60–Q64

**Arbitrages précédemment ouverts maintenant validés :** dernières caractéristiques Q56 ; identité Q57 ; cibles multiples Q60 ; fin des résurrections multiples Q55. Les autres cas ouverts restent tels quels dans les documents propriétaires.


## Ajout v0.8 — dégâts et protections

- [Attribution des dégâts, vol de vie et événements de protection](damage-attribution.md) (Q65–Q74)
- [Prévention des dégâts et protection létale](damage-prevention.md)
- [Tests d'acceptation](../09-technical/acceptance-tests.md)

## Modules v0.8 et v0.9
- [Attribution des dégâts, vol de vie et événements défensifs](damage-attribution.md) — Q65–Q74
- [Soins et attribution des soins simultanés](healing.md) — Q75–Q77
- [PV maximum, durées, expirations et événements](temporary-effects.md) — Q26, Q78–Q84

**Note :** le départage des protections létales de même catégorie a été validé en Q73 ; la mention ancienne de ce point comme « ouvert » ci-dessus est obsolète.

## Nouveau module v1.0
- [Sources, contrôle, instantanés et capacités différées](source-control.md) — Q85–Q94

## Transferts et contrôles — v1.1

- [Placement, retour, contrôles superposés, transferts croisés et ON_CONTROL_CHANGED (Q95–Q104)](control-transfers.md).

## Référence croisée v1.2

Voir [capacités de tour et protection anti-boucles](turn-control-and-loop-safety.md) — Q105–Q114, et [tests](../09-technical/acceptance-tests.md).


## Référence croisée v1.3

- [Budgets causaux, admissions FIFO, sauvegardes et replays](../09-technical/causal-budgets-and-replay.md) — Q115–Q124.
- [Tests d’acceptation](../09-technical/acceptance-tests.md) — T-115 à T-124.


## Interface — Référence croisée v1.4

- [Carte d’origine, jetons tactiques, inspection et états (Q126–Q134)](../02-art-direction/card-and-board-ui.md) ; les valeurs de combat restent produites par les règles de ce module, jamais recalculées par l’UI.

## Consolidation v2.2 — Q210–Q214
- [Fatigue croissante remplaçant la valeur fixe Q41 et recherches de cartes Q211–Q214](deck-search-and-fatigue-v22.md).
- [Pioche Q36–Q42](draw-and-fatigue.md), [absence de recyclage Q43](hand-and-discard.md), [récupération de défausse Q53–Q54](recovery.md) et [deck actif/réserve Q205–Q209](../03-progression/deck-reserve-and-capacity.md).

## v2.5 — Géométrie, peuples et effets continus

- [Peuples et stabilisation Q235–Q244](tribes-positioning-and-stabilization-v25.md), en complément des règles préexistantes (FIFO, budgets causaux et auras Q159–Q164).

## Cartes d’équipement (v2.6)

- [Taxonomie, conditions de deck et équipements Q245–Q254](equipment-and-card-classifications-v26.md) : 0–2 slots, Arme/Protection, restrictions, détachement, remplacement, charges facultatives. Réutiliser [FIFO](event-queue.md) et [stabilisation](tribes-positioning-and-stabilization-v25.md).
