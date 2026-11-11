# Moteur d'événements (FIFO)

**Statut : ordre principal et garde-fous anti-boucle Q111–Q114 VALIDÉS ; portée détaillée des budgets Q115 OUVERTE.** Dépend de [abilities.md](abilities.md), [targeting.md](targeting.md), [damage-resolution.md](damage-resolution.md).

## Règles VALIDÉES
- **EVT-001** : une attaque achève ses dégâts, Piétinement inclus, avant la résolution des capacités déclenchées par morts ou dégâts.
- **EVT-002** : entre les colonnes, tous les effets en attente sont résolus.
- **EVT-003** : effets simultanés : **joueur actif d'abord**, puis inactif ; dans chaque camp **C1→C6**, **attaque avant défense**.
- **EVT-004** : file **FIFO** ; les événements nouvellement générés sont ajoutés en fin de file.
- **EVT-005** : effet déjà déclenché persiste si sa source meurt, change de position ou revient en main ; mémoriser son contexte.
- **EVT-006** : une cible devenue invalide fait échouer son effet sans reciblage ni remboursement de mana, voir [targeting.md](targeting.md).
- **EVT-007** : prévenir les boucles dès la conception, autoriser les longues chaînes finies.
- **EVT-008** : en cas de cycle infini détecté, neutraliser les répétitions responsables et préserver les autres événements légitimes ; stratégie algorithmique définie en Q111–Q114, détails multi-parents Q115 ouverts.
- **EVT-009** : mort du héros = interruption immédiate du combat et abandon de la file.

## Modèle technique PROPOSÉ
Événement : `id`, `type`, `sourceInstanceId`, `owner`, `triggerSnapshot`, `targets`, `createdAtSequence`, `effectPayload`. Le moteur garde un journal des événements pour le debug et les animations.

## OUVERT
- Départage de plusieurs capacités sur une même instance.
- Instant précis de mise en file d'événements générés au cours de Piétinement.
- Détection fiable des cycles et règle précise de neutralisation (ne pas coder une suppression arbitraire).
- Fin d'un événement à plusieurs effets ; priorités préventives.

## Extension v0.6 — VALIDÉ Q48, Q50, Q54
- Les événements de changement de zone sont typés selon leur motif : [zone-events](zone-events.md).
- À la résurrection, `ON_SUMMON` précède `ON_RESURRECT` dans l'ordre d'ajout FIFO, après restauration + nouveaux bonus initiaux : [resurrection](resurrection.md).
- Une récupération débordant de la main produit `ON_CARD_RECOVERED` puis `ON_DISCARD` en FIFO.
- **OUVERT** : moment de résolution des capacités générées pendant **un sort à résurrections multiples** ; ne pas copier sans validation la règle de pioche multiple Q42.

## Extension v0.7 — VALIDÉ Q55–Q63
- **EVT-V07-01 (Q55/Q62)** — Pendant une résurrection multiple ou un effet composé, les déclenchements sont ajoutés à la FIFO à mesure des opérations, mais exécutés seulement lorsque l'effet composé a terminé. **Exception préexistante** : pioches multiples Q42, effets entre tentatives.
- **EVT-V07-02 (Q56/Q57)** — Les caractéristiques variables sont lues à la résolution ; si source sortie du plateau, employer son dernier état connu de la bonne instance (voir [instance-identity](instance-identity.md)).
- **EVT-V07-03 (Q63)** — L'opération atomique commit entièrement avant tout contrôle de victoire ; à défaite, aucune capacité en file ne résout. Voir [effect-resolution](effect-resolution.md).


## Ordonnancement des événements défensifs — v0.8 (Q70–Q74)

Les réactions déclenchées n'interrompent jamais une opération atomique ou un effet composé. Pour une même cible, inscrire : absorption armure, absorption bouclier, dégâts subis si perte nette de PV, mort évitée si prévention réellement consommée, puis capacités additionnelles de la protection consommée. Respecter les événements plus anciens et l'ordre général entre cibles. Voir [attribution](damage-attribution.md) et [résolution des effets](effect-resolution.md).

## Extensions validées Q76–Q84
Les soins effectifs génèrent `ON_HEAL` en FIFO (une occurrence par cible/opération atomique). Plusieurs effets temporaires expirant ensemble produisent **un événement `ON_EFFECT_EXPIRED` par effet** après retrait et contrôle de victoire ; l'ordre entre événements d'expiration suit Q13, puis ancienneté/ID sur la même cible. Aucun de ces événements ne peut interrompre l'opération atomique. Voir [soins](healing.md), [effets temporaires](temporary-effects.md).

## Extension VALIDÉE Q85–Q93
`ON_DEATH`/`ON_LETHAL_PREVENTED` précèdent `ON_EFFECT_EXPIRED` pour la même cible d'expiration ; les déclenchements utilisent l'instantané initial et survivent à la disparition de leur source. Les capacités mémorisent source originale, contexte des cibles et références de camp ; leurs caractéristiques variables se lisent à la résolution depuis l'instance originale ou son dernier état connu. Le vol de vie est figé **à l'application des dégâts** avec son bénéficiaire contrôleur (Q91–Q93). Voir [sources et contrôle](source-control.md).

## Référence croisée v1.1

Voir [transferts de contrôle](control-transfers.md) pour ordre ON_DEATH / ON_CONTROL_CHANGED / ON_EFFECT_EXPIRED Q104.

## Référence croisée v1.2

**Q111–Q114 (remplace « anti-boucle à préciser » pour les mécanismes décidés)** : signature fonctionnelle combat + FIFO, interruption ciblée des cycles, budget technique par chaîne configurable, conservation des événements déjà enfilés même descendants d’une branche bloquée ; seuls les nouveaux descendants de cette branche sont empêchés. Journalisation et maintien de l’ordre FIFO. Source normative : [capacités de tour et boucles](turn-control-and-loop-safety.md). Portée des budgets multi-parents encore ouverte Q115.


## Référence croisée v1.3 — admissions budgétées

L’admission d’une capacité déclenchée en FIFO doit réserver atomiquement ses budgets **avant insertion** ; les capacités déjà admises restent valides et les refus ne sont pas réadmis rétroactivement. Voir [Q115–Q120](../09-technical/causal-budgets-and-replay.md), [Q111–Q114](turn-control-and-loop-safety.md), [tests](../09-technical/acceptance-tests.md).


## Orchestration visuelle v1.5

L’[orchestrateur d’animations Q140–Q144](../02-art-direction/tooltips-durations-and-vfx.md) ne modifie jamais l’ordre FIFO, les opérations atomiques ou le journal logique. Les événements peuvent être condensés **visuellement** seulement si les résultats et cibles restent identifiables.
