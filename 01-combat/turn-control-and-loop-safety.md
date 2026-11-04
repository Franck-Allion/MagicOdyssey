# Changement de contrôle, capacités de tour et sécurité FIFO — Q105–Q114

**Statut : VALIDÉ Q105–Q114**. Ce module est normatif pour l'attaque après changement de contrôleur, les capacités de tour, les expirations tardives et la sécurité du moteur. Les règles plus anciennes restent applicables sauf précision explicite ci-dessous.

Références : [transferts de contrôle](control-transfers.md), [séquence de tour](turn-sequence.md), [effets temporaires](temporary-effects.md), [file FIFO](event-queue.md), [identité des instances](instance-identity.md), [sources et contrôle](source-control.md), [résolution atomique](effect-resolution.md), [tests](../09-technical/acceptance-tests.md).

## Q105 — Mal d'invocation après un contrôle réussi
- **ATK-105-01** : tout transfert de contrôle réussi et effectif déclenche une restriction d'attaque sous le nouveau contrôleur, sans compter comme une invocation ni générer `ON_SUMMON`/`ON_RESURRECT`.
- **ATK-105-02** : la restriction empêche l'attaque automatique durant le premier tour personnel du nouveau contrôleur, sans retirer les capacités ni les mouvements légaux.
- **ATK-105-03** : un effet autorisant explicitement à ignorer le mal d'invocation peut déroger à l'interdiction ; les autres conditions d'attaque subsistent.
- **ATK-105-04** : l'`instanceId`, PV, statuts, bonus, malus et capacités sont conservés, conformément à Q94.

## Q106 — Tour adverse et retour
- **ATK-106-01** : le premier tour personnel du nouveau contrôleur est bloqué pour les attaques, **même si le transfert est survenu pendant le tour adverse**. Exemple : transfert durant le tour ennemi T1, premier tour joueur T2 bloqué, deuxième tour joueur T4 autorisé si autres conditions réunies.
- **ATK-106-02** : chaque nouveau transfert effectif, y compris le retour au contrôleur précédent, recommence cette restriction ; aucune exemption fondée sur un contrôle antérieur.
- **ATK-106-03** : ne pas confondre compteur de restriction d'attaque et durée de l'effet de contrôle ; les durées continuent de suivre Q81–Q83.

## Q107 — Capacités de début et fin de tour
- **TURN-107-01** : `ON_TURN_START` et `ON_TURN_END` se déclenchent si la créature est contrôlée par le camp du tour **au moment de l'événement** ; jamais rétroactivement.
- **TURN-107-02** : le mal d'invocation n'empêche pas ces capacités.
- **TURN-107-03** : source, cibles et références de camp d'une capacité mise en FIFO sont capturées au déclenchement, subsistent après changement de contrôleur ou décès selon Q89–Q93 ; les caractéristiques variables se lisent normalement à la résolution selon Q90.

## Q108 — Sous-phases obligatoires de fin de tour
1. Attaques automatiques C1→C6 et toutes leurs réactions FIFO.
2. Émission de `ON_TURN_END` pour les créatures éligibles, puis **résolution intégrale** de ces capacités et de leurs réactions.
3. Expiration **atomique** des effets dont l'échéance est la fin du tour courant, après les éventuelles prolongations.
4. Résolution FIFO des réactions à l'expiration.
5. Passage au camp suivant, sauf fin immédiate du combat.

**TURN-108-01** : un bonus « jusqu'à la fin du tour » reste actif pendant `ON_TURN_END`, incluant la lecture de caractéristiques à la résolution. Une victoire/défaite immédiate stoppe la suite.

## Q109 — Création en `ON_TURN_END` et prolongation
- **TIME-109-01** : pas de durée minimale implicite. Un effet créé pendant `ON_TURN_END` avec échéance « fin de ce tour » expire à l'étape d'expiration directement suivante, même s'il a existé très brièvement ; un `ON_EFFECT_EXPIRED` par effet réellement expiré.
- **TIME-109-02** : prolonger avant l'échéance modifie la date d'expiration de **la même** `effectInstanceId`, sans retrait, recréation ni `ON_EFFECT_EXPIRED` ; ancienneté, capacités et charges/protections encore présentes restent inchangées.
- **TIME-109-03** : la date d'expiration nouvelle reste définie par le texte ; pas de conversion implicite de « ce tour » en « tour suivant ».

## Q110 — Effets créés après leur échéance
- **TIME-110-01** : si une création se produit **après** le point normal d'expiration correspondant et donne une échéance déjà atteinte, l'effet existe puis est retiré à un **point de contrôle immédiat après l'opération atomique en cours**, par une nouvelle opération atomique.
- **TIME-110-02** : le retrait génère `ON_EFFECT_EXPIRED` ; ses réactions sont ajoutées en **queue de FIFO**, sans dépasser les entrées préexistantes.
- **TIME-110-03** : un effet expiré ne peut pas survivre artificiellement jusqu'au prochain tour, ni faire échouer automatiquement sa création. Le contrôle de victoire immédiate reste prioritaire.
- Exemple : FIFO `[A, B]`, A crée un effet immédiatement périmé, il expire après A, réaction C ajoutée en fin : `[B, C]` ; B résout avant C.

## Q111 — Interruption ciblée des cycles non progressifs
- **LOOP-111-01** : lorsqu'un cycle non progressif est confirmé, le moteur empêche uniquement **le prochain déclenchement responsable de la répétition**, sans annuler les opérations déjà commises ni purger les autres éléments de FIFO.
- **LOOP-111-02** : un garde-fou technique indépendant s'applique même aux chaînes sans signature répétée.
- **LOOP-111-03** : interruption journalisée, comportement déterministe identique pour le joueur et l'IA ; les longues chaînes finies restent autorisées.

## Q112 — Signature fonctionnelle des cycles
- **LOOP-112-01** : comparer l'état fonctionnel du combat **et la FIFO ordonnée**, dont événements et capacités en cours, camp actif, phase, états des créatures, héros, cartes et ressources, effets, durées, charges, protections et toutes propriétés influençant le comportement.
- **LOOP-112-02** : normaliser uniquement les identifiants et horodatages de traçabilité sans influence sur les règles. Préserver les distinctions causales, l'ancienneté et les identités lorsqu'elles ont un effet, notamment sur le ciblage et le FIFO.
- **LOOP-112-03** : une configuration fonctionnellement équivalente réapparue sans intervention externe ni progression permet d'identifier un cycle ; une répétition de capacité seule, ou des PV identiques seuls, ne suffit pas.
- **LOOP-112-04** : la stratégie de canonicalisation exacte et l'absence de fausse équivalence doivent être démontrées par tests.

## Q113 — Budget de sécurité par chaîne
- **LOOP-113-01** : un budget technique configurable limite les résolutions de capacités d'une chaîne ; **1 000** est un *exemple de valeur initiale à éprouver*, pas une valeur d'équilibrage définitive.
- **LOOP-113-02** : au dépassement du budget, la **branche responsable** est marquée bloquée et ne peut plus **générer de nouveaux descendants**. Les autres branches de la même FIFO peuvent continuer sous leurs propres protections.
- **LOOP-113-03** : ni rollback des opérations atomiques, ni défaite technique, ni purge générale de la FIFO.
- **LOOP-113-04** : tracer chainId, branchId, trigger/eventId, limite, compteur, motif, état fonctionnel, événements conservés/supprimés.
- **Précision d'implémentation non arrêtée** : stratégie de comptabilité et d'héritage des budgets quand un événement a plusieurs causes ; à traiter Q115.

## Q114 — Événements déjà présents et descendants nouveaux
- **LOOP-114-01** : **option A** : toutes les entrées effectivement enregistrées en FIFO **avant l'interruption** restent valides, même si elles proviennent de la branche bloquée. Préserver leur ordre relatif et leur contexte de déclenchement.
- **LOOP-114-02** : ces événements déjà admis peuvent se résoudre normalement (y compris leurs effets directs) ; **seule la création de nouveaux événements descendants de la branche bloquée est empêchée**, au point de génération.
- **LOOP-114-03** : les entrées de branches indépendantes restent valides. Ne pas retirer rétroactivement d'entrées déjà en file.
- **LOOP-114-04** : les événements supprimés/empêchés sont journalisés avec motif `CYCLE_DETECTED` ou `BUDGET_EXCEEDED` et relations causales. Une branche bloquée ne peut se réamorcer par ses événements conservés.
- **LOOP-114-05** : respect de FIFO, atomicité, victoire immédiate, règles de sources et cibles et journalisation ; mêmes règles joueur/IA.

### Exemple normatif de reprise après interruption
- FIFO au moment du blocage de A : `[A.27 (bouclier déjà en file), B.1 (soin indépendant)]`.
- A.27 et B.1 **restent tous deux dans la FIFO** ; A.27 peut apporter son bouclier, mais n'enfile aucune nouvelle réaction **descendante de A**. B.1 soigne normalement et peut produire ses propres descendants soumis à ses propres gardes-fous.
- Un événement descendant potentiel A.28 déclenché par A.27 est **écarté avant insertion** et loggué. Les effets directs de A.27 déjà résolus ne sont pas annulés.

## Traçabilité et assertions de tests
Les champs `chainId`, `branchId`, `eventId`, `parentEventId`, `triggerId`, `resolutionCount`, `suppressionReason`, `combatStateHash` sont des **propositions de schéma**, non des API figées. Voir [scénarios Q105–Q114](../09-technical/acceptance-tests.md) pour les comportements à vérifier.

## Points ouverts après Q114
- Q115 : portée exacte du budget, comptabilité des résolutions, causalité multi-parent et branches réentrantes ; définition d'un garde-fou global si les branches indépendantes se multiplient ; configuration et télémétrie.
- Autres points non encore arbitrés : variantes d'événement `ON_TURN_END` sur cartes, effets de duration textuellement spécifiques et bornes des caractéristiques.
