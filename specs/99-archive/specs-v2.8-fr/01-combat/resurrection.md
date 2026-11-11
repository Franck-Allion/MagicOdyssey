# Résurrection — v0.6

**Statut : VALIDÉ (Q46–Q52), détails de pile et multi-effets ouverts.** Dépend de [summoning](summoning.md), [turn-sequence](turn-sequence.md), [targeting](targeting.md), [event-queue](event-queue.md), [zone-events](zone-events.md), [banishment](banishment.md).

## Référence et bonus — VALIDÉ Q46
- **RES-001** : ressusciter déplace directement une créature éligible de la défausse au champ de bataille.
- **RES-002** : la créature revient dans son état de référence : caractéristiques et améliorations permanentes RPG applicables, PV restaurés, blessures/bonus et malus de sa vie précédente effacés.
- **RES-003** : l'effet qui ressuscite peut accorder de **nouveaux bonus** immédiatement ; les éventuels bonus de ses capacités intrinsèques suivent les déclenchements ordinaires.
- **RES-004 (Q49)** : ordre **restauration → application des bonus immédiats de résurrection → déclenchement des capacités**. L'opération de retour et d'application de ses bonus immédiats n'est pas interrompue par d'autres événements.

## Placement — VALIDÉ Q47
- **RES-005** : mêmes contraintes de placement qu'une invocation normale : priorité aux colonnes ennemies non contestées, case libre légale, choix de la ligne offensive ou défensive ([summoning](summoning.md)).
- Les cas limites de colonne prioritaire sans case légale restent ouverts dans [summoning](summoning.md) et s'appliquent aussi à la résurrection.

## Invocation et capacités — VALIDÉ Q48, Q50
- **RES-006** : la résurrection compte comme une nouvelle invocation ; mal d'invocation normal pendant le tour du propriétaire (sauf effet explicite contraire).
- **RES-007** : déclenche « Lors de l'invocation » **et** « Lors de la résurrection ».
- **RES-008 (Q50)** : à déclenchements simultanés pour une même créature, mise en file de toutes les capacités « Lors de l'invocation » avant « Lors de la résurrection », sans dépasser les événements déjà en file FIFO.
- La priorité entre plusieurs capacités d'une même famille reste ouverte.

## Validité et échecs — VALIDÉ Q51
- **RES-009** : si aucun emplacement légal n'est disponible **au lancement**, le sort de résurrection ne peut pas être lancé. Les autres prérequis de ciblage sont régis par [targeting](targeting.md).
- **RES-010** : à la résolution, vérifier de nouveau la validité de la cible et du placement. Si l'emplacement devient impossible, cette résurrection échoue ; mana déjà payé non remboursé, aucun déclenchement de succès.
- **RES-011** : cible explicitement désignée ayant quitté la défausse : effet ciblé échoue, sans reciblage ni remboursement ([targeting](targeting.md)).

## Résurrections multiples — VALIDÉ Q52
- **RES-012** : traiter les créatures successivement dans l'ordre choisi au lancement ; pour chacune, vérifier cible + case légale au moment de sa tentative.
- **RES-013** : chaque succès occupe immédiatement sa case, restaure l'état et applique les bonus initiaux ; un échec ultérieur ne révoque pas les succès précédents.
- **RES-014** : si aucune case légale ne reste, les tentatives restantes ne réussissent pas ; les créatures non revenues restent en défausse, sans re-ciblage automatique.
- **RES-015** : les déclenchements de chaque succès respectent Q50 et les règles FIFO.

## Ancienne proposition Q52 résolue
- Le report des déclenchements jusqu’à la fin des tentatives est désormais **VALIDÉ Q55**.

## OUVERT
- Mesure des caractéristiques : **VALIDÉ Q56** ; lire [instance-identity](instance-identity.md).
- Politique si plusieurs cibles sont désignées alors qu'une seule case est disponible au lancement : capacité légale de jouer « jusqu'à N », distinction entre exact N / jusqu'à N.
- Interaction exacte avec un événement qui libère une case pendant la résolution du sort.

## Extension v0.7 — VALIDÉ Q55
- **RES-016 (Q55)** — Pendant un même sort à résurrections multiples, finir les tentatives successives (y compris les échecs partiels) avant de résoudre les capacités déclenchées.
- **RES-017 (Q55)** — À chaque succès, enregistrer les déclenchements `ON_SUMMON` puis `ON_RESURRECT` dans la FIFO ; leur exécution attend la fin de l'effet complet, et respecte les événements antérieurs.
- Les capacités de la première créature ne peuvent donc pas libérer une case pour la dernière créature *au cours du même sort*.
- Voir [effets composés](effect-resolution.md) ; contrairement à la [pioche multiple Q42](draw-and-fatigue.md), les résurrections ne constituent pas des fenêtres de résolution intermédiaires.

## Extension VALIDÉE Q89 / Q94
Une résurrection crée un nouvel `instanceId` et ne modifie jamais une capacité en attente de l'instance antérieure. À l'inverse, une **prise de contrôle** conserve le même `instanceId` et n'est pas une résurrection. Voir [sources et contrôle](source-control.md).
