# Budgets causaux, réservations FIFO, journal, sauvegardes et compatibilité — Q115–Q124

**Statut : VALIDÉ Q115–Q124 (toutes options A).** Document propriétaire du modèle de comptabilisation causal, de la réservation budgétaire, des journaux, des instantanés et de la compatibilité. Les nombres de plafonds et le schéma JSON sont **PROPOSÉS** et ne sont pas des règles quantitatives définitives.

**Références normatives :** [anti-boucles et FIFO Q105–Q114](../01-combat/turn-control-and-loop-safety.md), [file d'événements](../01-combat/event-queue.md), [opérations atomiques](../01-combat/effect-resolution.md), [instances](../01-combat/instance-identity.md), [contrôles](../01-combat/control-transfers.md), [tours](../01-combat/turn-sequence.md), [tests d'acceptation](../09-technical/acceptance-tests.md), [décisions](../DECISIONS.md).

## Portée, glossaire de comptabilité

- **Opération initiale** : origine de causalité prise en compte pour le garde-fou de niveau supérieur. **Chaîne** : ensemble de résolutions descendantes d'une cause commune. **Branche** : provenance causale particulière, même si plusieurs branches contribuent à une résolution unique. Une opération peut engendrer plusieurs chaînes ; une chaîne plusieurs branches.
- **Admission FIFO** : tentative de création d'une entrée de résolution déclenchée. **Réservation** : consommation temporaire de capacité budgétaire, sans exécution du gameplay. **Consommation** : conversion de la réservation lors de l'exécution effective. **Libération** : restitution après annulation avant exécution. **Refus** : aucune entrée FIFO ni réservation créée.
- Une capacité **réellement résolue une fois** n'est pas dupliquée lorsque plusieurs événements causaux la font converger sur une unique admission. Cette règle ne fusionne **pas arbitrairement** deux déclenchements indépendants qui, selon leur définition, doivent normalement être deux entrées distinctes (notamment les expirations Q84). Le regroupement multicausal suppose une **seule admission sémantique** ; les critères généraux de regroupement restent propres aux capacités / événements correspondants.

## Q115 — Résolution multicausale, parenté et propagation

- **LOOP-115-01** : une admission multicausale représente **une seule résolution effective**, avec tous les `parentEventIds` et `contributingBranchIds` conservés ; la résolution consomme une seule unité du budget commun de chaîne (et, cf. Q117, d'opération).
- **LOOP-115-02** : chaque branche contributrice conserve son budget indépendant ; une branche déjà bloquée ne se réactive pas par une convergence avec une branche autorisée.
- **LOOP-115-03** : les descendants nouveaux ne peuvent être imputés à une branche interrompue. Une branche indépendante non bloquée peut produire ses descendants selon ses crédits et les plafonds communs.
- **LOOP-115-04** : garder toutes les arêtes causales plutôt que fusionner définitivement les branches ; appliquer les règles identiques joueur/IA.

## Q116 — Trois plafonds hiérarchiques

- **LOOP-116-01** : garde-fou individuel **par branche** ; son épuisement bloque uniquement ses nouveaux descendants (Q113–Q114).
- **LOOP-116-02** : plafond **global par chaîne** couvrant les résolutions communes de toutes ses branches ; son épuisement bloque les nouvelles admissions descendantes de cette chaîne, mais ne révoque pas les réservations déjà acquises (Q118).
- **LOOP-116-03** : plafond supérieur **par opération initiale**, bornant l'accumulation des chaînes de cette origine ; pas de nouvelles admissions dépendantes si épuisé.
- **LOOP-116-04** : plafonds configurables, versionnés, exprimés en **nombre de résolutions et non en durée murale**. Valeurs « 1 000 » et ratios illustratifs : **NON VALIDÉS**. Le même jeu de règles doit produire les mêmes interruptions sur toute plateforme.

## Q117 — Coût d'une admission/résolution multicausale

- **LOOP-117-01** : coût **1** pour le budget global de chaîne et **1** pour le budget de l'opération initiale, quelle que soit la quantité de causes rattachées à **une résolution unique**.
- **LOOP-117-02** : coût **1 pour chacune des branches contributrices encore autorisées**, sans fraction ni attribution seulement à la première cause ; les branches déjà bloquées ne reçoivent pas une nouvelle imputation et ne sont pas réactivées.
- **LOOP-117-03** : comptabiliser d'abord les budgets applicables pour la même admission, suivant l'ordre déterministe FIFO ; leur mutation est transactionnelle (Q118–Q119).
- Exemple : A 799→800, B 200→201, chaîne 999→1000, opération 1499→1500 ; **une seule capacité exécutée**. Les chiffres sont des exemples, pas des seuils fixés.

## Q118 — Réservation obligatoire à l'admission FIFO

- **LOOP-118-01** : **avant** insertion d'une capacité déclenchée en FIFO, vérifier la disponibilité de **tous** les budgets applicables ; réserver les crédits associés **atomiquement**, ou refuser entièrement l'admission si un plafond ne peut être respecté.
- **LOOP-118-02** : capacité admise = droit acquis de résolution ; les plafonds devenus pleins entre admission et exécution ne révoquent pas la réservation. Ce droit ne rend pas la cible automatiquement valide : les règles ordinaires de ciblage/revalidation restent applicables.
- **LOOP-118-03** : à la résolution effective, chaque crédit `RESERVED` passe à `CONSUMED`, **sans second débit**. La file garde son ordre strict.
- **LOOP-118-04** : `consumed + reserved <= limit` à tous les instants pour tous les périmètres, et compteurs non négatifs ; les admissions successives d'un même lot respectent la priorité canonique des événements (Q13/Q84), puis FIFO.
- **LOOP-118-05** : **événements** (faits de jeu) et **entrées de capacités déclenchées** ne sont pas identiques : le refus de réserver une capacité n'efface pas l'événement historique sous-jacent ; ses déclenchements refusés ne rejoignent pas la FIFO.

## Q119 — Réservations immuables et libération atomique

- **LOOP-119-01** : ensemble des compteurs réservés, coût et relations causales figés au moment de l'admission. Une interruption future d'une branche ne retire ni sa réservation, ni l'entrée FIFO déjà admise (Q114).
- **LOOP-119-02** : si une capacité est explicitement annulée **avant** sa résolution, restituer **tous** ses crédits réservés dans **une seule transaction** ; aucun crédit déjà consommé n'est rendu ni aucune opération de gameplay passée annulée.
- **LOOP-119-03** : la libération ne modifie pas les positions relatives dans la FIFO ; ne rouvre **jamais** une branche déjà interrompue. Ne pas transférer des crédits d'une branche à l'autre.
- **LOOP-119-04** : une réservation a exactement un aboutissement terminal : consommation OU libération ; toute seconde conversion est interdite.

## Q120 — Refus définitifs, réemploi prospectif

- **LOOP-120-01** : si une réservation est refusée faute de crédit/branche autorisée, cette **tentative de déclenchement** est définitivement refusée ; aucune file d'attente secondaire, aucune réadmission rétroactive.
- **LOOP-120-02** : une libération ultérieure peut servir à une **nouvelle** tentative d'admission à partir de cet instant, seulement si chaque périmètre et chaque branche concernés restent ouverts.
- **LOOP-120-03** : un refus n'altère pas les compteurs ; le refus et son motif sont journalisés ; une branche interrompue demeure interdite malgré de nouveaux crédits disponibles.

## Invariants comptables — obligations de test

Pour chaque périmètre `p` (branche, chaîne, opération initiale), `0 <= consumed[p] + reserved[p] <= limit[p]`, avec `consumed[p] >= 0`, `reserved[p] >= 0` ; la même admission ne réserve qu'une fois par périmètre.

| Transition | Consommés | Réservés | Obligations |
|---|---:|---:|---|
| Admission | 0 | +1 par périmètre applicable | Contrôle global atomique préalable ; refus sans changement si insuffisant |
| Résolution effective | +1 | −1 | Une fois par `resolutionId`, sans double exécution |
| Annulation pré-résolution | 0 | −1 | Libérer atomiquement tous les périmètres, jamais un crédit consommé |
| Refus | 0 | 0 | `reasonCode` et événement source conservés ; pas d'entrée FIFO |
| Interruption | 0 | 0 | Enregistre un verrou de branche/chaîne/opération selon portée ; réservations intactes |

**Ordonnancement** : tous les tests d'admission ont lieu à un point de commit atomique, avec ordre de génération canonique ; la journalisation n'altère jamais l'ordre FIFO. Les anomalies de compteur sont des **erreurs du moteur**, pas des effets de carte.

## Q121 — Journal déterministe exhaustif et instantanés périodiques

- **REPLAY-121-01** : journal chronologique des mutations fonctionnelles (commit d'opération atomique, événements et déclenchements, changements de zones, résultats, choix joueur/IA, réservations, consommations, libérations, refus, interruptions), avec ordre stable.
- **REPLAY-121-02** : inclure la version des règles, des définitions des cartes et de la configuration des plafonds, et les paramètres nécessaires à la reproduction de l'aléatoire.
- **REPLAY-121-03** : instantanés cohérents périodiques pour restaurer sans rejouer depuis le début. Journal + instantané = reprise/rejeu possible, sans supposer que le rendu ou les animations commandent les règles.
- **REPLAY-121-04** : le rejeu contrôle **également les décisions intermédiaires** ; un état final égal ne suffit pas à prouver une exécution identique.

### Schéma de traçabilité — proposition technique, non API figée

`sequenceNumber`, `eventId`, `resolutionId`, `chainId`, `branchIds`, `parentEventIds`, `abilityInstanceId`, `budgetsBefore`, `budgetsAfter`, `reservationStatus`, `reasonCode`, `rulesVersion`, `stateHash`. Codes indicatifs : `ABILITY_BUDGET_RESERVED`, `ABILITY_BUDGET_CONSUMED`, `ABILITY_BUDGET_RELEASED`, `ABILITY_BUDGET_REJECTED`, `TRIGGER_SUPPRESSED`, `BRANCH_INTERRUPTED`, `NON_PROGRESS_CYCLE`, `BRANCH_BUDGET_EXCEEDED`, `CHAIN_BUDGET_EXCEEDED`, `OPERATION_BUDGET_EXCEEDED`. Choisir une nomenclature stable lors de l'implémentation ; les **faits et leurs causes** sont normatifs, pas ces chaînes de caractères.

## Q122 — Contrôle d'intégrité après chaque commit atomique

- **REPLAY-122-01** : calculer et journaliser une empreinte d'état après **chaque opération atomique entièrement validée**, jamais à partir d'un état partiel.
- **REPLAY-122-02** : inclure toutes les données pouvant affecter la simulation future : héros, créatures avec identités pertinentes, zones ordonnées, tour/phase, FIFO et payloads, causes, effets, derniers états connus, compteurs/réservations/verrous, configuration de règles et état de générateur aléatoire.
- **REPLAY-122-03** : format de sérialisation **canonique, indépendant de la plateforme** ; trier seulement les collections dont l'ordre n'a aucun sens de jeu ; préserver ordre réel de FIFO, pioche, priorités et effets classés par ancienneté.
- **REPLAY-122-04** : une empreinte de rejeu différente entraîne **arrêt au premier point divergent** et rapport avec numéro d'opération, état attendu/observé et premières différences ; pas d'autocorrection silencieuse.
- **REPLAY-122-05** : l'empreinte de rejeu n'est **pas** la signature normalisée anti-cycle Q112 : elle doit conserver les identités qui peuvent servir au rejeu exact, même si certaines seraient neutralisées pour reconnaître un cycle équivalent.
- **REPLAY-122-06** : conserver **graine et version de PRNG**, état/position courant, et **tirages effectifs ordonnés** avec contexte pour détecter un appel aléatoire supplémentaire ou modifié. Algorithme de hachage, encodage précis et format binaire restent à spécifier techniquement.

## Q123 — Frontières atomiques des sauvegardes

- **SAVE-123-01** : instantané uniquement **après commit complet** d'une opération atomique et à un point de contrôle de moteur cohérent ; il peut rester des capacités dans la FIFO.
- **SAVE-123-02** : capturer positions et charges de FIFO, toutes réservations immuables, compteurs, branches bloquées, contextes/identités/derniers états connus, camp, phase, choix sérialisables, aléatoire, dernière séquence et dernière empreinte.
- **SAVE-123-03** : jamais de sauvegarde d'une opération partiellement effectuée. Au chargement, vérifier l'intégrité du snapshot et reprendre au **prochain point de résolution**, sans répéter un commit ni une consommation antérieurs.
- **SAVE-123-04** : une demande de sauvegarde en cours d'opération est différée jusqu'au premier point sûr ; les choix non finalisés doivent soit être terminés, soit représentés explicitement de manière restaurable.

## Q124 — Version de règles figée par combat

- **COMPAT-124-01** : chaque combat lie une version exacte et immuable de **règles de combat, définitions de cartes, algorithme et état de PRNG, configuration de plafonds et autres paramètres fonctionnels** jusqu'à sa conclusion ; les mises à jour s'appliquent aux **nouveaux** combats.
- **COMPAT-124-02** : sauvegardes/replays utilisent ce jeu de versions pour reproduire le combat. Si une dépendance exécutable ou une définition nécessaire manque, annoncer **incompatibilité explicite**, ne jamais utiliser silencieusement une nouvelle version susceptible de changer l'issue.
- **COMPAT-124-03** : la **progression RPG persistante** et les collections peuvent être migrées séparément **entre les combats** ; leurs règles de migration restent à spécifier dans la future section progression.
- **COMPAT-124-04** : distinguer version de **documentation** (`v1.3`) et version effective du **moteur/des cartes** (à définir à l'implémentation). Un changement visuel sans impact de règles n'impose pas une nouvelle version fonctionnelle.
- **COMPAT-124-05** : valider le manifeste et la disponibilité des versions **avant** reprise. Aucun combat engagé ne doit muter vers un moteur différent en cours de résolution.

### Exemple de manifeste (PROPOSÉ, non contrat figé)

```json
{
  "saveFormatVersion": "1",
  "combatRulesVersion": "rules-example-1",
  "cardDefinitionsVersion": "cards-example-1",
  "rngAlgorithmVersion": "rng-example-1",
  "budgetConfigurationVersion": "budget-example-1",
  "snapshotSequenceNumber": 842,
  "snapshotStateHash": "example-hash"
}
```

## Règles de priorité en cas de doute

1. **Victoire/défaite immédiate** et frontières atomiques conservent priorité sur les réactions différées : [victoire](../01-combat/victory-and-defeat.md), [résolution atomique](../01-combat/effect-resolution.md).
2. L'admission/réservation doit précéder l'insertion de capacités déclenchées dans [la FIFO](../01-combat/event-queue.md) ; les événements déjà émis demeurent des faits tracés.
3. Une branche interrompue ne crée aucun **nouveau descendant** ; ses capacités **déjà admises** conservent leurs effets directs et réservations selon [Q114](../01-combat/turn-control-and-loop-safety.md), sans rouvrir la branche.
4. Un jeu de versions figé par combat s'applique à **tout** nouvel événement, sauvegarde et rejeu.

## Points ouverts après Q124

- Q125 : stratégie de conservation des anciennes versions du moteur et des packs de cartes ; politique de support et migration éventuelle de progression RPG **hors combat**.
- Valeurs chiffrées des plafonds Q113/Q116, schéma de causalité pour les événements à multiples origines, sérialisation canonique exacte, standard de hachage, fréquence d'instantanés et stockage/compression restent des **paramètres d'implémentation ou décisions futures**, et ne sont pas validés par Q115–Q124.


## Q125 — Conservation des versions historiques encore supportées

- **COMPAT-125-01** : aussi longtemps qu’une sauvegarde ou un replay est **officiellement supporté**, la version historique de règles nécessaire doit rester disponible, éventuellement dans une archive chargée à la demande.
- **COMPAT-125-02** : un combat ancien est restauré avec ses composants historiques compatibles (règles, cartes, RNG, budgets) ; si l’environnement supporté requis est indisponible, annoncer l’incompatibilité, jamais substituer silencieusement des règles plus récentes (Q124).
- **COMPAT-125-03** : conserver la capacité de reproduction des tests de non-régression d’anciennes règles supportées. La durée exacte du support officiel n’est **pas encore définie**.
- **COMPAT-125-04** : les migrations de progression RPG persistante sont séparées des combats en cours. Une mise à jour purement graphique ne change pas le déterminisme des règles : [UI et cartes](../02-art-direction/card-and-board-ui.md).
