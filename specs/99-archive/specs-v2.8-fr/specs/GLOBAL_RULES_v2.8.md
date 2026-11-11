# Tower TCG/RPG — Spécifications intégrales v2.8

**Consolidation Q01–Q274** · 2026-11-11 · Chaque section indique son chemin dans l’archive modulaire.

> Décisions VALIDÉES normatives ; exemples et règles OUVERTES non normatifs. Tests d’acceptation spécifiés, non exécutés.

---


## Fichier : `01-combat/README.md`

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

---

## Fichier : `01-combat/abilities.md`

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


## Complément v1.7 — Effets continus et auras (Q155–Q164)

Les règles de calcul des dépendances, de neutralisation des cycles et des points de cohérence sont dans [la spécification des effets continus](../02-art-direction/spells-auras-and-continuous-effects.md). Les itérations du solveur ne sont pas des déclenchements FIFO. Les capacités déclenchées conservent leurs règles d’admission et d’exécution.

---

## Fichier : `01-combat/banishment.md`

# Bannissement — v0.6

**Statut : VALIDÉ (Q45).** Dépend de [hand-and-discard](hand-and-discard.md), [zone-events](zone-events.md), [targeting](targeting.md).

## VALIDÉ
- **ZONE-005 (Q45)** : chaque camp dispose d'une zone de bannissement distincte de sa défausse.
- **ZONE-006** : une carte bannie est inaccessible pendant le combat à toute pioche, récupération, recyclage ou résurrection **ordinaire**.
- **ZONE-007** : le bannissement dure jusqu'à la fin du combat.
- **ZONE-008** : la carte reste acquise au joueur, et redevient disponible pour les combats ultérieurs, notamment si elle appartient à son deck persistant.
- **ZONE-009** : aucune réintégration automatique dans la défausse pendant le combat.

## Conséquences
- La zone de bannissement est la cinquième zone, avec deck, main, plateau, défausse.
- Un effet de résurrection ordinaire ne peut pas cibler une carte bannie ; les vérifications de ciblage s'appliquent ([targeting](targeting.md)).
- Les événements de transfert vers le bannissement suivent [zone-events](zone-events.md).

## OUVERT
- Existence future de rares effets qui ciblent **explicitement** les cartes bannies (l'interdiction ordinaire est validée, pas une exception future).
- Sort des jetons, cartes générées ou empruntées lorsque le combat se termine.

---

## Fichier : `01-combat/battlefield.md`

# Champ de bataille

**Statut : partiellement validé** · Décisions Q01–Q02. Voir [Invocation](summoning.md), [Déplacement](movement.md), [Dégâts](damage-resolution.md).

## Objectif
Deux rôles distincts par colonne : attaque et protection/soutien, sans règles de ciblage normales complexes.

## Règles VALIDÉES
- **BTL-001** : chaque camp possède 6 colonnes × 2 lignes = 12 emplacements.
- **BTL-002** : la ligne d'attaque effectue les attaques normales ; la ligne de défense ne les effectue pas normalement, sauf capacité spécifique.
- **BTL-003** : dans une colonne, une attaque normale cherche d'abord une créature ennemie sur la ligne d'attaque, ensuite sur celle de défense, ensuite le héros si les deux emplacements sont vides.
- **BTL-004** : la créature de défense intercepte donc automatiquement lorsque la ligne d'attaque est vide.
- **BTL-005** : des capacités passives/actives peuvent dépendre de la ligne occupée.

## EXEMPLES
1. Attaquant allié colonne 3 ; ennemi défense colonne 3 ; ennemi attaque absent → le défenseur reçoit l'attaque.
2. Deux lignes ennemies vides colonne 3 → dégâts directs au héros.
3. Ennemi dans les deux lignes colonne 3 → ligne d'attaque ciblée en premier.

## OUVERT
- Variantes d'attaques offertes par des capacités spéciales.
- Conventions techniques détaillées d'occupation et d'identification des emplacements.

## Référence croisée v1.1

Voir [transferts de contrôle](control-transfers.md) pour transfert entre plateaux et réservations de départ Q102.



## Affichage plateau — Q127–Q132 (v1.4)

L'interface représente chaque créature en [médaillon compact avec ATQ/PV et trois icônes tactiques maximum](../02-art-direction/card-and-board-ui.md). Clic = inspection. Il s'agit d'une projection de l'état fonctionnel, sans modifier le plateau 6×2 par camp.

---

## Fichier : `01-combat/control-transfers.md`

# Transferts de contrôle, placement et événements — Q95–Q104

**Statut : VALIDÉ (v1.1).** Ce module complète [sources et contrôle](source-control.md), [champ de bataille](battlefield.md), [invocation](summoning.md), [effets temporaires](temporary-effects.md), [résolution atomique](effect-resolution.md), [file FIFO](event-queue.md) et [tests](../09-technical/acceptance-tests.md).

## Invariants
- `cardId`, `instanceId`, `ownerId`, caractéristiques, blessures, protections et capacités déjà en attente restent inchangés lors d'un transfert réussi (Q94). Seuls `controllerId` et la position changent ; transfert ≠ invocation/résurrection : aucun `ON_SUMMON` / `ON_RESURRECT`.
- Le **placement** suit strictement les règles d'invocation : priorité aux colonnes ennemies non contestées si des cases légales y existent, puis autres cases libres légales ; choix de la ligne offensive ou défensive parmi les places permises ; aucun remplacement spontané d'un occupant ([invocation](summoning.md)).
- Les **durées** des contrôles utilisent les tours du camp ayant appliqué chaque effet (Q81–Q83) ; un événement d'expiration est émis pour chaque effet retiré (Q84), même si aucun transfert réel n'en découle.
- Les préventions létales ordinaires n'empêchent pas une **mort de placement** : absence de place ≠ perte de PV, et n'émet ni `ON_DAMAGE_TAKEN`, ni `ON_DAMAGE_DEALT`, ni `ON_LETHAL_PREVENTED` (Q98).

## Prises de contrôle nouvelles — Q95–Q96
- **CTRL-095-01 (Q95, option personnalisée E)** : après prise de contrôle, le **nouveau contrôleur choisit** une case libre en respectant entièrement les règles habituelles d'invocation, y compris la priorité de colonnes. La créature rejoint son plateau avec la même instance et tous ses états ; aucun événement d'invocation.
- **CTRL-096-01 (Q96 A)** : si aucune case légale n'est libre **au lancement**, une action exigeant un transfert est illégale et ne peut être lancée. Revérifier à la **résolution** ; si aucune case légale ne subsiste, le transfert échoue **sans remboursement du mana**, et la créature conserve ancien contrôleur, position et instance. Les autres conséquences d'un effet composé suivent [résolution des effets](effect-resolution.md).
- Une prise de contrôle qui réussit émet un `ON_CONTROL_CHANGED` selon Q104 ; une prise de contrôle échouée n'en émet aucun.

## Retour obligatoire et morts de placement — Q97–Q98
- **CTRL-097-01 (Q97 A)** : lorsqu'un contrôle temporaire expire et que le contrôleur effectif doit changer, le camp de destination accueille la créature en choisissant une place **légale d'invocation**. Le retour réussi conserve `instanceId` et états, sans déclencheur d'invocation ni résurrection.
- **CTRL-097-02** : si aucun emplacement légal n'est disponible à un **retour obligatoire**, la créature **meurt** et entre dans la défausse de son **propriétaire** ; générer `ON_DEATH`, pas d'événement de dégâts. Il ne s'agit pas d'un transfert réussi.
- **CTRL-098-01 (Q98 A)** : les protections létales ordinaires ne peuvent pas empêcher cette mort de placement et ne sont pas consommées. Un **remplacement explicitement prévu pour ce changement de zone** peut agir en amont, selon son texte (ex. renvoi en main) ; cela n'est pas une protection létale ordinaire.
- Les déclencheurs de la créature éligibles dans l'instantané préalable à l'opération persistent, même si elle meurt, selon Q85–Q87.

## Effets de contrôle concurrents — Q99–Q100
- **CTRL-099-01 (Q99 A)** : permettre plusieurs contrôles sur une même instance. Chaque effet garde sa source, son identifiant, son bénéficiaire, l'ordre d'application et son échéance. Le **plus récent effet de contrôle encore actif** impose `controllerId`. Sans effet actif, `controllerId = ownerId`.
- **CTRL-100-01 (Q100 A)** : à échéance simultanée, retirer **tous** les effets concernés dans une seule opération atomique ; **recalculer une fois** le contrôleur final après retraits. **Aucun déplacement** si le contrôleur final est inchangé ; **un seul transfert** si différent. Aucune étape de contrôleur intermédiaire ne provoque d'événement ou de mort.
- Conserver l'ordre des effets expirés pour générer un `ON_EFFECT_EXPIRED` **par effet** après l'opération (Q84), y compris pour des effets n'ayant pas changé le contrôle final.

## Retours concurrents et transferts croisés — Q101–Q103
- **CTRL-101-01 (Q101 A)** : si plusieurs retours obligatoires réclament un camp disposant d'une capacité insuffisante, **le contrôleur du camp de destination choisit** lesquelles sont accueillies et où ; chacune obéit aux priorités de placement habituelles. Les autres meurent par manque de place. L'IA applique une politique stratégique **déterministe** (précisions d'heuristique à définir ultérieurement).
- **CTRL-102-01 (Q102 A)** : calculer globalement tous les départs entre camps ; **les cases laissées libres par tous les départs de la même opération** sont disponibles pour les arrivées, même si les plateaux étaient pleins avant l'opération. Pas de déplacement séquentiel intermédiaire : réserver les départs, choisir les arrivées, puis **valider l'ensemble en une opération atomique**.
- **CTRL-103-01 (Q103 A)** : si les deux camps doivent choisir, le **camp actif choisit en premier**, puis le camp non actif **voit ce choix** et sélectionne ses propres arrivées. Aucun événement différé entre les deux choix. Un seul commit des transferts et morts.
- **Point d'implémentation :** si plusieurs permutations partagent des cases, les choix doivent être évalués sur l'**état final réservé**, avec positions de départ considérées vacantes pour cette opération. Les capacités déclenchées ne sont pas résolues pendant la préparation.

## Événements et ordre — Q104
- **CTRL-104-01 (Q104 A)** : émettre **un `ON_CONTROL_CHANGED` par instance et opération atomique uniquement si** le contrôleur effectif avant/après diffère **et** que le transfert aboutit à un emplacement légal. Aucun événement si contrôleur inchangé, contrôle tenté mais échoué, ou **mort de placement**.
- **CTRL-104-02** : pour une **même cible**, ordre d'enregistrement des événements applicables : `ON_DEATH` ou `ON_LETHAL_PREVENTED` → `ON_CONTROL_CHANGED` → un `ON_EFFECT_EXPIRED` par effet. Les événements incompatibles (ex. mort de placement / contrôle réussi) ne sont pas produits ensemble. Entre cibles : camp actif, colonnes C1–C6, offensive avant défensive ; FIFO ensuite ([file](event-queue.md)).
- **CTRL-104-03** : l'événement de changement contient au minimum l'**identité de l'instance**, `previousControllerId`, `newControllerId`, `previousPosition`, `newPosition` et une **référence causale** si identifiable. Les noms précis des champs et le cas d'une cause composite sont des détails d'implémentation, non une nouvelle décision.
- Les vérifications de victoire/défaite se font **après le commit atomique et avant les réactions**, conformément à [résolution atomique](effect-resolution.md). Les capacités pré-expiration des unités mortes restent éligibles selon [sources](source-control.md).

## Séquence normative d'une expiration simultanée de contrôles
1. Capturer l'état et les capacités éligibles avant l'opération (Q86–Q87).
2. Retirer atomiquement les effets arrivant à échéance ; sélectionner le contrôleur final selon l'effet le plus récent encore actif (Q99–Q100).
3. Réserver **ensemble** les cases libérées par tous les départs (Q102).
4. Pour chaque camp, déterminer les candidats au retour ; choisir les créatures et cases légales (camp actif puis adverse, Q101/Q103). Ne pas dépenser une case pour une créature déjà déterminée morte ou ne changeant pas de camp.
5. Appliquer dans un seul commit les transferts réussis et les morts de placement (Q97–Q98).
6. Vérifier la fin du combat (Q63), puis enregistrer les événements par cible dans l'ordre Q104/Q85, et résoudre ultérieurement les réactions FIFO.

## Exemples d'acceptation
- A appartient à l'ennemi ; contrôle joueur de 3 tours, puis contrôle ennemi de 1 tour. À expiration du second, le contrôle joueur reprend tant que son effet existe (Q99).
- Deux effets expirent simultanément mais un troisième maintient le même contrôleur : **deux `ON_EFFECT_EXPIRED`, zéro `ON_CONTROL_CHANGED`, zéro transfert** (Q100/Q104).
- Deux camps avec 12/12 cases chacun doivent chacun envoyer une créature à l'autre : les cases des départs peuvent accueillir les arrivées lors d'un seul commit (Q102).
- Deux unités doivent revenir dans un camp avec une seule case : choix du contrôleur de destination, puis `ON_DEATH` pour la créature non retenue ; sa protection létale reste sans effet (Q101/Q98).

## Sujets ouverts après Q104
- **Q105** : mal d'invocation et droit d'attaquer à la suite d'un transfert ; transfert n'est pas une invocation mais peut avoir un traitement d'attaque particulier.
- Effets spécifiques de changement de contrôle à début/fin de tour et leurs interactions avec les capacités ; placement en cas de conflits conditionnels spécifiques non couverts par les cas ordinaires.

## Référence croisée v1.2

**Q105–Q107** : chaque transfert effectif (y compris retour) réapplique le mal d’invocation pour le premier tour personnel du nouveau contrôleur ; pas d’`ON_SUMMON`. Les capacités de début/fin de tour appartiennent au contrôleur effectif au déclenchement. Voir [capacités de tour et boucles](turn-control-and-loop-safety.md).


## Référence croisée v1.3 — sauvegardes et compatibilité

Le contrôleur, les effets temporaires de contrôle et les événements en FIFO sont inclus dans l’état sérialisable et les empreintes déterministes. Voir [Q121–Q124](../09-technical/causal-budgets-and-replay.md).


## Référence de présentation v1.5

Une prise de contrôle réussie affiche un indicateur de **contrôleur changé** parmi les icônes prioritaires ; elle ne change **pas le propriétaire**, ni le calendrier d’expiration des autres effets : [Q139 — Iconographie de contrôle](../02-art-direction/tooltips-durations-and-vfx.md).

---

## Fichier : `01-combat/damage-attribution.md`

# Attribution des dégâts, vol de vie et réactions aux protections — v0.8

**Statut : VALIDÉ Q65–Q74.** Source normative pour les événements de dégâts. Voir [résolution des dégâts](damage-resolution.md), [prévention](damage-prevention.md), [résolution atomique](effect-resolution.md), [file FIFO](event-queue.md) et [tests](../09-technical/acceptance-tests.md).

## Agrégation et événements (Q65–Q67)

- Les composantes simultanées **compatibles** sont regroupées **par cible** pour l'application des protections, sans perdre l'identité des sources. Les effets requérant des règles particulières restent différenciés (Q64).
- Une cible ayant perdu au moins 1 PV à cause des dégâts produit **au maximum un** `ON_DAMAGE_TAKEN` **par opération atomique**, même pour plusieurs sources (Q65). Si les protections absorbent tout, aucun événement de dégâts subis n'est produit.
- Chaque source à contribution d'entrée positive participe collectivement si l'opération inflige au moins 1 PV de dégâts à la cible ; elle produit **au maximum un** `ON_DAMAGE_DEALT` **par cible et opération atomique** (Q66–Q67). Il n'existe pas de déclenchement `ON_DAMAGE_DEALT` si la perte de PV est nulle. Une source contributrice peut déclencher cet événement avec **quantité attribuée = 0**, sans contradiction : éligibilité collective et volume numérique sont deux données séparées.
- Les événements en attente utilisent les règles [FIFO](event-queue.md) ; ils ne s'intercalent pas dans une opération atomique ni à l'intérieur d'un [effet composé](effect-resolution.md).

## Attribution entière des dégâts effectifs (Q68–Q69)

Soit `d_i > 0` la contribution brute compatible de la source `i` et `L` la **perte effective finale** de PV attribuable à cette opération (non la valeur brute, et non une restauration ultérieure). On utilise `D = somme(d_i)`. Pour chaque source :

1. Part exacte `q_i = L × d_i / D`.
2. Attribution initiale `a_i = floor(q_i)`.
3. `R = L − somme(a_i)` points à distribuer, à raison d'un point aux `R` plus grands restes `q_i − floor(q_i)`.
4. En cas d'égalité des restes, départager par l'**ordre stable des sources** issu du contexte de l'opération, puis par identifiant technique stable.

**Invariants :** `a_i` est un entier positif ou nul ; `somme(a_i) = L` ; aucune création artificielle de PV perdus. L'ordre des sources doit être sérialisé dans le contexte pour rejouer un combat à l'identique. Exemple : contributions 5, 3, 2 ; perte finale de 4 PV ; attributions **2, 1, 1**. Exemple : contributions 3, 2 ; bouclier absorbant 4 ; perte finale 1 : attributions **1, 0** (sans modifier l'éligibilité collective des deux sources à `ON_DAMAGE_DEALT`).

La méthode suppose des dégâts compatibles à contributions positives. La répartition de dégâts hétérogènes, des immunités par type ou de dommages résultant d'effets particuliers reste à spécifier avant introduction de ces mécaniques. Le calcul de perte de PV et de prévention létale demeure prioritaire sur l'attribution.

## Vol de vie (Q70)

- Le vol de vie ordinaire est **une capacité déclenchée** de la source après `ON_DAMAGE_DEALT`, non une prévention ni un soin atomique.
- Sa quantité de soin est **l'attribution entière `a_i`** de sa source, éventuellement `0` ; le soin respecte les PV maximum du destinataire.
- Le soin rejoint la file FIFO et attend la fin de l'effet composé. Il ne sauve pas un héros dont la défaite a déjà été constatée (Q15, Q62–Q63).
- Une participation collective peut donc déclencher une capacité de vol de vie dont la quantité de soin est nulle ; aucune récupération de PV n'en résulte.

## Événements d'absorption (Q71–Q72)

Par cible et opération atomique, produire au maximum :

| Événement | Condition | Contexte |
|---|---|---|
| `ON_ARMOR_ABSORBED` | armure absorbe au moins 1 dégât | `armorAbsorbed` total |
| `ON_SHIELD_ABSORBED` | bouclier absorbe au moins 1 dégât | `shieldAbsorbed` total |
| `ON_DAMAGE_TAKEN` | perte effective finale d'au moins 1 PV due aux dégâts | `effectiveHpLost` |
| `ON_LETHAL_PREVENTED` | une protection létale a réellement empêché une mort | `lethalPreventionUsed` |

**Ordre d'enregistrement pour une même cible :** armure → bouclier → dégâts subis → mort évitée. Omettre les événements non applicables. Pour plusieurs cibles, appliquer aussi les priorités générales [Q13](event-queue.md), en conservant FIFO pour les événements préexistants. L'effet de prévention lui-même intervient **immédiatement** pendant le calcul ; `ON_LETHAL_PREVENTED` est une **réaction différée**.

## Choix de protection létale (Q73)

- Au plus **une protection létale consommée par événement létal** (Q23).
- Privilégier les **temporaires avant les permanentes** (Q24).
- Temporaires : expiration la plus proche, puis plus ancienne date d'acquisition/application.
- Permanentes : date d'acquisition/application la plus ancienne.
- Égalité résiduelle : identifiant technique stable.
- Les autres protections ne sont pas consommées et restent disponibles, sous réserve de leur propre expiration.

## Résultat final après prévention (Q74)

- Déclencher `ON_DAMAGE_TAKEN` **seulement lorsque la cible termine l'opération avec moins de PV qu'au début**, et que cette perte est due à des dégâts. `effectiveHpLost` = cette perte nette pertinente ; les soins produits plus tard ne la modifient pas rétroactivement.
- Déclencher `ON_LETHAL_PREVENTED` si une protection a réellement empêché la mort, **même lorsque les PV finaux ne sont pas inférieurs aux PV initiaux**.
- Les capacités additionnelles propres à la **protection consommée** sont ajoutées à la file FIFO **après `ON_LETHAL_PREVENTED`** ; elles ne sauvent pas rétroactivement de la mort.
- Aucun `ON_DEATH` lorsque la mort est effectivement empêchée.
- Avec une prévention « reste à 1 PV » : PV initiaux 3 → finaux 1 : `ON_DAMAGE_TAKEN` + `ON_LETHAL_PREVENTED` ; avec une prévention « restaure à 6/6 » depuis 3/6 : aucun `ON_DAMAGE_TAKEN`, mais `ON_LETHAL_PREVENTED`. Les sources ne reçoivent pas de quantité positive de dégâts effectifs dans le second cas : pas de vol de vie fondé sur ces dégâts.

## Explicitement ouvert / non déduit

- Le comportement d'effets élémentaires, des résistances spécifiques et des agrégations entre classes de dégâts incompatibles.
- L'attribution individuelle d'absorptions armure/bouclier aux sources pour de futurs effets qui l'exigeraient : seuls les totaux **par cible et type** sont validés.
- Les règles détaillées des soins et des effets temporaires (à partir de Q75).

## Mise à jour VALIDÉE Q89–Q93 — Vol de vie et bénéficiaire
**Rectificatif normatif de Q70 par Q92** : le héros soigné est celui du **contrôleur de la source lors de l'application des dégâts**, et non nécessairement celui du propriétaire permanent. Figer la propriété vol de vie et le destinataire lors de l'application des dégâts, dans `ON_DAMAGE_DEALT` (Q91–Q92). La quantité soignée reste la part de dégâts effectifs attribuée à la source (Q68–Q70). Si la source a quitté le plateau, consulter son dernier état connu ; une nouvelle instance ressuscitée est ignorée (Q89–Q90). Voir [sources et contrôle](source-control.md).

---

## Fichier : `01-combat/damage-prevention.md`

# Armure, boucliers et prévention létale

**Statut : règles Q21–Q23 VALIDÉES ; ordre de départage et détails de prévention létale encore OUVERTS.**  
**Dépendances :** [damage-resolution.md](damage-resolution.md), [abilities.md](abilities.md), [victory-and-defeat.md](victory-and-defeat.md).  
**Décisions :** Q21 option A ; Q22 option A ; Q23 option A.

## VALIDÉ

- **PREV-001** — L’armure et le bouclier diminuent les dégâts disponibles pour le Piétinement.
- **PREV-002** — Une créature qui survit grâce à une protection arrête le Piétinement.
- **PREV-003** — Chaque nouvelle cible traversée applique ses propres protections.
- **PREV-004** — Les effets préventifs / de remplacement interviennent avant que la mort devienne effective ; un soin différé n’est pas une prévention.
- **PREV-005 (Q22)** — L’ordre des protections est **Armure → Bouclier → PV → Protection létale**.
- **PREV-006 (Q22)** — L’armure réduit en premier les dégâts entrants ; le bouclier absorbe ensuite les dégâts restants ; les dégâts non absorbés affectent les PV ; une éventuelle protection létale intervient **en dernier**, si les dégâts feraient mourir la cible.

- **PREV-007 (Q23)** — Pour un même événement létal, **une seule** protection létale est consommée pour empêcher la mort.
- **PREV-008 (Q23)** — Les autres protections létales disponibles restent intactes et pourront servir lors d’un événement létal ultérieur.
- **PREV-009 (Q23)** — La protection consommée est sélectionnée selon une priorité **déterministe et automatique**. Le critère de priorité exact est **OUVERT**.

### Lecture opérationnelle de PREV-005

1. Évaluer les dégâts entrants sur cette cible.
2. Appliquer l’armure pertinente.
3. Déduire l’absorption du bouclier.
4. Déterminer l’impact résiduel sur les PV.
5. Si cet impact serait létal, évaluer les protections contre la mort **avant de rendre la mort effective**.
6. Vérifier si la créature a effectivement été éliminée avant de poursuivre un éventuel Piétinement.

**Important :** l’ordre est validé, mais le comportement exact d’une protection létale (PV fixés à 1, quantité absorbée), les règles de cumul d’armures/boucliers et certains calculs de Piétinement ne le sont pas encore. Ne pas déduire ces règles du seul ordre ci-dessus.

## Exemple d'ordre (sans protection létale)

Cible : **4 PV, armure 2, bouclier 3** ; dégâts entrants **7**. Armure : 7 − 2 = 5 ; bouclier : 5 − 3 = 2 ; la cible reçoit 2 dégâts sur ses PV et survit avec 2 PV. Le bouclier a consommé 3 points. Cet exemple illustre l'ordre validé, sous l'hypothèse de protections à réduction additive.

## PROPOSÉ — NON VALIDÉ

- **PREV-P02** — L'armure réduit les dégâts de chaque attaque ; le bouclier forme une réserve consommable.
- **PREV-P03** — Une protection létale à usage unique maintient la cible à 1 PV, bloque Piétinement et n'est consommée que lorsqu'elle est nécessaire.
- **PREV-P04** — Les dégâts nuls ne déclenchent pas « subit des dégâts ».

## OUVERT — décisions suivantes

1. **Q24** — Quelle priorité déterministe départage plusieurs protections létales (temporaire, artefact, carte ; date d’application, etc.) ?
2. Une protection létale absorbe-t-elle tout le reliquat et comment mesure-t-on la puissance restante d'une attaque avec Piétinement ?
3. Plusieurs boucliers, plusieurs armures et réductions diverses : ordre de départage.
4. Invulnérabilité et Piétinement ; dégâts de sorts hors combat ; dégâts nuls ; protections contre destruction directe.

## Tests

Voir [acceptance-tests.md](../09-technical/acceptance-tests.md) : TEST-015 à TEST-018.

## Extension v0.7 — VALIDÉ Q64
- Pour une même cible, agréger les composantes de dégâts simultanées **compatibles** avant application unique des protections, dans l'ordre Q22. Les types de dégâts nécessitant une protection spécifique demeurent séparés. Voir [effect-resolution](effect-resolution.md).
- **OUVERT** : détails de compatibilité (types/résistances), multiplicité de protections identiques et granularité des déclencheurs par source.


## Protections multiples et événements — v0.8 (Q71–Q74)

Ordre des réactions différées pour chaque cible : `ON_ARMOR_ABSORBED` → `ON_SHIELD_ABSORBED` → `ON_DAMAGE_TAKEN` (seulement avec perte nette de PV) → `ON_LETHAL_PREVENTED`. Au plus un événement par type de protection et opération. Les capacités supplémentaires de la protection consommée suivent `ON_LETHAL_PREVENTED` dans FIFO.

Pour choisir une protection létale, consommer au plus une protection par événement létal ; sélectionner temporaire avant permanente, échéance la plus proche entre temporaires, puis ancienneté, puis identifiant stable. Pour les permanentes, ancienneté puis identifiant. Voir [attribution des dégâts et vol de vie](damage-attribution.md), [file d'événements](event-queue.md), [tests](../09-technical/acceptance-tests.md).

## Interaction avec variations de caractéristiques — Q79–Q80
Le retrait d'un bonus de PV maximum peut créer un événement létal même sans dégât ; les protections létales générales fonctionnent normalement, sauf restriction expresse. Expirations simultanées évaluées en un seul résultat atomique (une seule protection consommable par cible et événement). Voir [effets temporaires](temporary-effects.md).

## Référence croisée v1.1

Voir [transferts de contrôle](control-transfers.md) pour mort de placement non prévenable par protection létale ordinaire Q98.



## Armure/bouclier dans l'interface — Q131–Q134

Les [protections restantes sont indiquées distinctement des PV et de l'ATQ](../02-art-direction/card-and-board-ui.md). Le terme « défense » dans l'UI n'ajoute pas de statistique autonome au moteur.

---

## Fichier : `01-combat/damage-resolution.md`

# Résolution des attaques et des dégâts

**Statut : principales décisions validées, calculs secondaires à préciser** · Q09–Q12, Q18, Q21. Dépend de [battlefield.md](battlefield.md), [damage-prevention.md](damage-prevention.md), [event-queue.md](event-queue.md), [victory-and-defeat.md](victory-and-defeat.md).

## Règles VALIDÉES
- **DMG-001** : à la fin du tour du joueur actif, ses créatures en attaque frappent C1→C6 ; pas de riposte normale.
- **DMG-002** : cible normale : créature ennemie attaque > créature ennemie défense > héros adverse.
- **DMG-003** : chaque attaque normale frappe une cible ; dégâts excédentaires **perdus**, sauf Piétinement.
- **DMG-004** : **Piétinement** transporte le résiduel vers la ligne suivante, puis éventuellement le héros ; nécessite l'élimination effective de la créature ciblée.
- **DMG-005** : armure et bouclier diminuent la quantité qui peut être transmise ; si la cible survit, la propagation s'arrête ; chaque cible suivante applique ses propres protections.
- **DMG-006** : l'attaque complète, Piétinement compris, précède la résolution des capacités de mort ou de dégâts déclenchées par cette attaque.
- **DMG-007** : une créature à 0 PV ou moins meurt et quitte le plateau. Ses capacités de mort peuvent être mises en attente.
- **DMG-008** : aucun effet différé ne peut annuler rétroactivement les dégâts déjà appliqués.
- **DMG-009** : effets d'une colonne entièrement résolus avant la suivante.
- **DMG-010** : exception prioritaire : mort immédiate d'un héros, voir [victory-and-defeat.md](victory-and-defeat.md).

## Exemples
- Attaquant 8 ATQ sans Piétinement contre ennemi 2 PV : ennemi meurt, 6 dégâts perdus.
- Même attaque avec Piétinement contre ennemi attaque 3 PV + ennemi défense 2 PV sans protections : 3 puis 2 absorbés, 3 atteignent le héros.
- Si une protection létale empêche la mort de la première cible, le Piétinement s'arrête.

## OUVERT
- Définition formelle du « résiduel » pour chaque type de réduction/prévention ; Q22 : ordre de protection validé ; calcul exact du reliquat avec protection létale encore ouvert.
- Statuts indestructible, dégâts égaux à zéro, dégâts au-delà du maximum, attaques spéciales, durées et soins, effets infligeant simultanément des dégâts à plusieurs cibles.

## Extension v0.7 — VALIDÉ Q63–Q64
- Dégâts simultanés : grouper par cible les composantes compatibles et appliquer les protections une fois au total ; préserver distinctement les composantes nécessitant des règles de protections différentes.
- Commit simultané des résultats d'une opération atomique ; vérifier victoire immédiatement après commit. Voir [effect-resolution](effect-resolution.md).


## Attribution, dégâts simultanés et déclenchements — v0.8 (Q65–Q69)

**Règles normatives :** voir [attribution des dégâts](damage-attribution.md) pour le regroupement des composantes compatibles, la participation collective des sources, la méthode des plus grands restes et la distinction entre quantum de dégât et déclenchement. La simultanéité et le contrôle de victoire restent définis par [la résolution des effets](effect-resolution.md).

## Extensions validées Q75–Q84
La variation concomitante de `currentHp` et `maxHp` n'est ni un soin ni un dégât (Q78). Si elle provoque une mort, appliquer les protections létales générales puis `ON_DEATH` ou `ON_LETHAL_PREVENTED` (Q79). Voir [effets temporaires](temporary-effects.md) et [soins](healing.md).


## Référence de présentation v1.5

Les nombres flottants représentent les pertes de PV **effectives**, les absorptions d’armure/bouclier et les soins sont visuellement distincts : [Q143 — Feedbacks de combat](../02-art-direction/tooltips-durations-and-vfx.md). La couche visuelle ne change ni l’attribution ni les événements du moteur.

---

## Fichier : `01-combat/deck-search-and-fatigue-v22.md`

# Recherche dans la pioche, visibilité et fatigue progressive — Q210–Q214 (v2.2)

> **Statut : VALIDÉ**. Ce document complète et corrige [Q41 / Q42](draw-and-fatigue.md), [Q43](hand-and-discard.md) et [Q53–Q54](recovery.md). La **fatigue fixe de Q41 est remplacée** par la progression Q210. Les valeurs des cartes concrètes de recherche restent **OUVERTES**.

## Invariants du moteur
1. La recherche opère sur des **instances de cartes de la pioche de combat**, pas sur la réserve hors combat ni sur le catalogue de drafts ([deck actif et réserve Q205–Q209](../03-progression/deck-reserve-and-capacity.md)). Les cartes en main, défausse ou plateau n’y sont éligibles que si un effet explicite étend la zone recherchée.
2. Le moteur résout toute recherche, sélection, déplacement et mélange via des transitions d’état et la file FIFO normatives ([résolution atomique](effect-resolution.md), [file](event-queue.md), [événements de zone](zone-events.md)). RNG déterministe et consignation nécessaires pour sauvegardes/replays ([replay](../09-technical/causal-budgets-and-replay.md)).
3. Une carte obtenue par transfert depuis la pioche n’est **pas automatiquement piochée** ni « nouvellement obtenue » pour le pool de collection ; un effet doit explicitement demander une véritable pioche pour en déclencher les événements.

## Q210 — Fatigue progressive (modification Q41)
- **DRAW-210-01** : compteur de fatigue `fatigueAttempts[heroId, combatId]` initialisé à 0 à chaque début de combat.
- **DRAW-210-02** : quand une vraie **tentative de pioche** échoue parce que la pioche est vide, incrémenter le compteur puis faire perdre **directement** `n` PV, où `n` est le nouveau compteur (1, 2, 3, ...).
- **DRAW-210-03** : les tentatives réussies, les recherches sans résultat et les récupérations depuis la défausse ne déclenchent pas la fatigue, et ne remettent pas le compteur à zéro. La fatigue passée demeure malgré toute réintégration ultérieure de cartes.
- **DRAW-210-04** : aucun recyclage automatique ([Q43](hand-and-discard.md)); les effets explicites peuvent recycler des cartes, sans effacer le compteur.
- **DRAW-210-05** : perte directe de PV, pas des dégâts ; ignore armure, boucliers et protections létales ordinaires ; seules les protections explicitement prévues contre la fatigue/perte létale directe sont applicables ([Q41](draw-and-fatigue.md)). Ne déclenche pas « subit des dégâts ».
- **DRAW-210-06** : multi-pioche résolue séquentiellement Q42 avec événements FIFO entre tentatives ; mort du héros annule la suite.

## Q211 — Deux sortes de recherche, choisies par l’effet
- **DRAW-211-01** : `targeted` : le joueur choisit une instance éligible ; `randomEligible` : le moteur choisit une instance au hasard parmi les instances éligibles, via RNG déterministe.
- **DRAW-211-02** : les critères (type, élément, coût, caractéristiques, etc.) appartiennent à la définition de l’effet et sont évalués sur l’état éligible au moment prévu par la résolution.
- **DRAW-211-03** : sans permission explicite d’accès à d’autres zones, uniquement cartes dans la pioche ; aucune visibilité du contenu non éligible.
- **DRAW-211-04** : coûts, limites et règles de ciblage propres aux cartes restent à équilibrer ; les recherches ciblées et aléatoires ne sont pas interchangeables.

## Q212 — Destination, mélange et échec définis par l’effet
- **DRAW-212-01** : chaque effet déclare la destination autorisée : main, dessus de pioche, défausse ou autre zone explicitement validée par l’effet.
- **DRAW-212-02** : chaque effet déclare **si et quand** mélanger la pioche ; sans instruction de mélange, ordre relatif des autres cartes préservé.
- **DRAW-212-03** : recherche sans carte éligible : pas de sélection ni de fatigue ; les composantes indépendantes du sort continuent si applicables. Si le texte prévoit un mélange même sans résultat, le moteur l’effectue ; sinon aucun mélange implicite.
- **DRAW-212-04** : transfert vers la main ≠ pioche (sauf instruction explicite) ; appliquer la limite de main Q38, et si une carte ne peut rester en main, suivre les règles de zone/effet, sans inventer un nouveau comportement.
- **DRAW-212-05** : RNG et résultat de la sélection/mélange inscrits dans les événements, permettant déterminisme et rejouabilité.

## Q213 — Visibilité restrictive et interface
- **DRAW-213-01** : lors d’une recherche ciblée, afficher **toutes et seulement** les instances éligibles, inspectables, sans ordre de pioche ni cartes non éligibles.
- **DRAW-213-02** : la recherche aléatoire n’ouvre pas de sélection ; présenter seulement le feedback/resultat effectivement visible.
- **DRAW-213-03** : toute donnée affichée respecte les permissions et le masquage d’information, y compris dans le [journal de combat](../02-art-direction/combat-journal-and-inspection.md).
- **DRAW-213-04** : Q213 envisageait un regroupement possible, mais **Q214-A tranche explicitement pour un affichage individuel**, même pour des copies identiques.

## Q214 — Affichage individuel de chaque exemplaire (option A)
- **DRAW-214-01** : afficher **chaque instance éligible séparément**, même si plusieurs cartes ont même nom, identité de modèle ou caractéristiques identiques. **Aucun regroupement de copies avec badge `×N`** pendant une recherche ciblée.
- **DRAW-214-02** : chaque entrée possède un identifiant d’instance stable interne, sans confondre l’identité de carte (modèle) et celle de la copie ; l’UI peut inspecter les modifications pertinentes à chaque instance.
- **DRAW-214-03** : le joueur choisit **une instance précise**, transférée selon Q212 ; aucune sélection automatique d’un autre exemplaire équivalent.
- **DRAW-214-04** : tri visuel autorisé pour lisibilité, à condition de **ne pas révéler l’ordre réel de la pioche** ; les cartes identiques restent des entrées séparées.
- **DRAW-214-05** : à la résolution, valider que l’instance choisie existe encore dans la zone et demeure éligible ; si elle ne l’est plus, respecter la politique existante de cible invalide ([Q20](targeting.md)), sans choisir silencieusement une autre copie. Aucun RNG de départage inutile.
- **DRAW-214-06** : recherches sans résultat : conserver la sémantique d’échec Q212, sans afficher de sélecteur vide ni déclencher la fatigue.

## Cas d’acceptation clés
- Pioche vide et demande de 3 cartes : fatigue 1/2/3 avec FIFO, interruption en cas de mort ; carte réinsérée n'efface pas le compteur déjà accumulé.
- Recherche ciblée dans une pioche contenant trois instances de « Boule de feu » : **trois entrées distinctes**, inspectables, choix d'une seule instance ; aucune indication d'ordre réel.
- Recherche aléatoire sans cible : pas d'interface de sélection, pas de fatigue, pas de changement d'ordre sans instruction de mélange.
- Recherche en main pleine : appliquer Q38/Q212 ; une recherche n’est pas artificiellement requalifiée en pioche pour déclencher des effets « on draw ».

## Références croisées et points ouverts
- [Deck actif/réserve et capacité Q205–Q209](../03-progression/deck-reserve-and-capacity.md), [filtres des marchands et récompenses Q201–Q204](../03-progression/merchant-stock-and-deck-limits.md).
- [Pioche Q36–Q42](draw-and-fatigue.md) · [Défausse Q43](hand-and-discard.md) · [Récupération Q53–Q54](recovery.md) · [Identité d’instance](instance-identity.md) · [Ciblage Q20](targeting.md) · [tests](../09-technical/acceptance-tests.md).
- **OUVERT** : cartes réelles et leurs coûts, filtres concrets, UX de pagination si liste très longue, libellés du feedback, éventuelles permissions de révélation exceptionnelles propres à des cartes futures. Ces points ne changent pas la règle validée d’affichage individuel Q214.

---

## Fichier : `01-combat/draw-and-fatigue.md`

# Pioche et fatigue — mise à jour v2.2 (Q210)

**Statut : Q36, Q37, Q38, Q41, Q42 VALIDÉES.**

Dépendances : [turn-sequence](turn-sequence.md), [hand-and-discard](hand-and-discard.md), [victory-and-defeat](victory-and-defeat.md), [event-queue](event-queue.md).

## VALIDÉ
- **DRAW-001 — Q36** : main de départ de 6 cartes ; pas de pioche normale au premier tour ; pioche normale au deuxième tour personnel.
- **DRAW-002 — Q37** : pioche normale initiale : 1 carte par tour, améliorable par progression RPG, artefacts et effets de cartes.
- **DRAW-003 — Q38** : toute nouvelle carte piochée au-delà de la limite de main est défaussée automatiquement ; elle quitte quand même le deck.
- **FAT-001 — Q41 modifiée par Q210** : chaque tentative de pioche avec deck vide fait perdre directement un nombre de PV progressif = rang de fatigue dans ce combat (1 PV, puis 2, puis 3, etc.). Ce n’est pas un dégât ; ignore armure, bouclier et protections létales ordinaires. Une protection indiquant explicitement couvrir la fatigue ou les pertes létales directes peut s’appliquer.
- **FAT-002 — Q41** : une perte de PV due à la fatigue ne déclenche pas « subit des dégâts » ; mort du héros à 0 PV termine immédiatement le combat.
- **DRAW-004 — Q42** : les pioches multiples se traitent une par une. Après chaque tentative (carte obtenue, carte défaussée si main pleine, ou perte de PV), les effets déclenchés sont résolus via la file FIFO avant la tentative suivante. La mort du héros annule les tentatives restantes.
- Une main pleine n'évite pas la fatigue si le deck est vide.

## Exemples / critères de test
- Deck 2 cartes, demander 5 pioches : 2 cartes retirées du deck, puis 3 pertes successives de **1, 2, 3 PV** (6 PV au total) si le héros survit ; résoudre les réactions FIFO après chacune.
- Main 7/7 et deck 1 carte, pioche : carte défaussée, pas de fatigue.
- Main 7/7 et deck 0, première pioche impossible : perte directe de 1 PV ; deuxième : 2 PV, même avec main pleine.

## OUVERT
Pioche initiale lorsque le deck contient moins de six cartes ; ordre des nouvelles cartes si même opération ; recherche, mélange et choix de cartes réglés en Q211–Q214 dans [recherche dans la pioche](deck-search-and-fatigue-v22.md).

## Précision normative Q210 — remplace la pénalité fixe Q41
- Compteur de fatigue **par héros et par combat**, initialisé à zéro au début de chaque combat ; incrémenté pour **chaque** tentative de pioche impossible, y compris à l’intérieur d’un effet multi-pioche.
- La tentative impossible numéro `n` du combat inflige une **perte directe de n PV**. Si l’état de la pioche change entre deux tentatives, une pioche réussie n’augmente **ni ne remet à zéro** ce compteur ; seules les tentatives impossibles le font évoluer.
- La fatigue ne produit pas d’événement « subit des dégâts ». Les protections explicitement applicables à la fatigue/perte directe gardent leurs règles Q41.
- Les effets FIFO se résolvent après chaque tentative de pioche Q42 ; mort du héros interrompt immédiatement les tentatives restantes.
- Voir [Q210 et recherches Q211–Q214](deck-search-and-fatigue-v22.md), [défausse et recyclage Q43](hand-and-discard.md), [tests](../09-technical/acceptance-tests.md).

---

## Fichier : `01-combat/effect-resolution.md`

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

---

## Fichier : `01-combat/equipment-and-card-classifications-v26.md`

# Classifications, construction de deck et équipements — Q245–Q254 (v2.6)

**Statut : VALIDÉ**, sauf mentions explicites **OUVERT**. Dernière mise à jour : 2026-11-10.

Ce module consigne uniquement les nouvelles décisions de Q245–Q254. Pour la file FIFO, la causalité, le graphe d’auras, les transferts et les déclenchements, les modules historiques restent normatifs : [événements](event-queue.md), [capacités](abilities.md), [zones](zone-events.md), [boucles et budget](turn-control-and-loop-safety.md), [stabilisation](tribes-positioning-and-stabilization-v25.md), [artefacts/progression](../03-progression/rewards-rarity-and-ascension.md), [deck et réserve](../03-progression/deck-reserve-and-capacity.md), [début d’ascension](../03-progression/ascension-start-boosters-and-autobuild.md).

## Journal synthétique

| Question | Choix | Synthèse |
|---|---|---|
| Q245 | C | Taxonomie peuple / faction / types secondaires : métadonnées distinctes, non obligatoires sauf origine pertinente, multiples types, inspectables et extensibles. |
| Q246 | C adaptée | Deck libre entre peuples/factions/types ; effets conditionnels de composition sans illégalité ; socle neutre de 20 copies, spécialisation émergente des deux boosters aléatoires. |
| Q247 | B | Conditions de composition évaluées avant la main initiale de chaque combat, sur le deck actif, figées durant ce combat. |
| Q248 | B | Alliances/rivalités narratives ; aucune règle de bonus/malus automatique, seuls effets explicites des cartes. |
| Q249 | B | Cartes Équipement attachables aux créatures, distinctes des artefacts d’ascension, sans case créature. |
| Q250 | B adaptée par Q253 | Une créature a au maximum une case Arme et une case Protection, et peut posséder 0, 1 ou 2 emplacements au total. |
| Q251 | B | Départ du porteur : détacher chaque équipement, puis défausse du propriétaire par défaut, exceptions explicites. |
| Q252 | B | Emplacement occupé : remplacement autorisé ; ancien objet détaché et envoyé en défausse, sauf effet explicite. |
| Q253 | C adaptée | Équipements utilisables par défaut si la créature possède la case adéquate ; restrictions de porteur explicites par carte ; certaines créatures (ex. Dragon) ont 0 emplacement. |
| Q254 | C | Aucune durabilité universelle ; cartes spécifiques avec charges, consommation et conséquence à zéro explicitement définies ; compteur seulement si pertinent. |

## Q245 — Classification multidimensionnelle des créatures

- **CARD-245-01 (VALIDÉ)** : une créature possède un peuple ou une classification d’origine applicable, une faction optionnelle et zéro ou plusieurs types secondaires. Les dimensions sont indépendantes ; un peuple peut appartenir à différentes factions.
- **CARD-245-02 (VALIDÉ)** : l’affiliation de faction est facultative ; plusieurs tags de type (Guerrier, Mage, Construct…) peuvent coexister.
- **CARD-245-03 (VALIDÉ)** : ciblage, inspection, filtres et sérialisation utilisent des identifiants extensibles, et non une liste fermée des quatre peuples MVP (Q234–Q235).
- **CARD-245-04 (VALIDÉ)** : les capacités peuvent filtrer une ou plusieurs dimensions, sans règles supplémentaires de priorité.

## Q246 — Construction libre et rôle des boosters

- **DECK-246-01 (VALIDÉ)** : aucune restriction générale interdisant de mélanger peuples, factions et types ; seules les conditions de capacités explicitement écrites activent d’éventuels bonus ; leur échec ne rend pas le deck illégal.
- **DECK-246-02 (VALIDÉ)** : les **20 cartes du socle initial** doivent rester neutres et polyvalentes. Les améliorations déterministes des copies fondamentales par le sphérier (Q224, Q226–Q229) demeurent légales, mais ne doivent pas imposer à elles seules un archétype dominant.
- **DECK-246-03 (VALIDÉ)** : la spécialisation initiale émerge prioritairement des **deux boosters aléatoires de 15 cartes** ; le joueur adapte son deck aux cartes réellement tirées, sous garanties du sphérier et contraintes Q207/Q218–Q225.
- **DECK-246-04 (VALIDÉ)** : le constructeur automatique Q216/Q222 favorise les synergies de la spécialisation du sphérier **présentes dans le pool réellement acquis**, sans créer, promettre ni imposer une famille de cartes absente.
- **DECK-246-05 (VALIDÉ)** : les conditions de composition comptent les cartes du deck actif, sauf exception explicite d’une capacité ; réserve et collection permanente sont exclues.

## Q247 — Instant d’évaluation des conditions de composition

- **DECK-247-01 (VALIDÉ)** : au début de **chaque combat**, figer les conditions de composition à partir des 40 cartes du deck actif standard (ou de la capacité actuelle Q209), **avant de distribuer la main initiale**.
- **DECK-247-02 (VALIDÉ)** : l’évaluation et ses résultats sont invariants pendant ce combat, malgré pioche, défausse, bannissement et déplacement de zone ; mise à jour au combat suivant après échanges deck/réserve Q206.
- **DECK-247-03 (VALIDÉ)** : l’interface de préparation expose les conditions satisfaites pour le prochain combat ; stocker le snapshot utile dans l’état du combat pour sauvegardes/replays.
- **DECK-247-04 (VALIDÉ)** : distinguer les conditions de **composition** figées des auras de **présence** recalculées dynamiquement par Q159–Q164 et Q240.

## Q248 — Relations narratives entre factions

- **FACTION-248-01 (VALIDÉ)** : alliances, rivalités, neutralités peuvent exister dans le lore mais **n’appliquent aucun modificateur de combat automatique**.
- **FACTION-248-02 (VALIDÉ)** : les seules interactions mécaniques entre factions sont celles **explicitement décrites sur les cartes** ; elles passent par le ciblage et les événements ordinaires.
- **FACTION-248-03 (VALIDÉ)** : deux factions adverses dans le lore peuvent cohabiter dans le même deck ou camp (Q246) ; pas de matrice de malus globale à maintenir.

## Q249–Q250 et Q253 — Équipements, emplacements et compatibilité

- **EQUIP-249-01 (VALIDÉ)** : catégorie de cartes de combat **Équipement** attachable à une créature en jeu, distincte des **artefacts d’ascension** Q182–Q183 ; aucun emplacement d’artefact consommé et aucune case du plateau occupée.
- **EQUIP-249-02 (VALIDÉ)** : équipement = instance et objet attaché distinct du porteur. Les statistiques/capacités accordées réutilisent les règles d’instance, source, effets continus, événements et stabilité existantes.
- **EQUIP-250-01-R (VALIDÉ ; Q253 précise Q250)** : **capacité variable par créature : zéro à deux emplacements**, au maximum **un Arme et un Protection**. Pas de troisième emplacement ni de double arme/protection.
- **EQUIP-250-02 (VALIDÉ)** : armes : épée, hache, arc, arbalète, bâton de combat… ; protections : bouclier, armure, amulette, anneau… Le nom « Protection » désigne un type d’emplacement, pas nécessairement un bonus défensif.
- **EQUIP-253-01 (VALIDÉ)** : les emplacements effectivement disponibles sont une propriété de la **définition de chaque créature**, indépendamment du seul peuple ; un Dragon peut avoir zéro emplacement et un autre Dragon pourrait en posséder un selon sa carte.
- **EQUIP-253-02 (VALIDÉ)** : si l’emplacement de catégorie existe, équipement **compatible par défaut**, sauf restriction **explicite sur la carte d’équipement**, ciblant peuple, faction, type secondaire ou caractéristiques pertinentes Q245.
- **EQUIP-253-03 (VALIDÉ)** : une restriction d’éligibilité (empêche l’attachement) est différente d’un bonus conditionnel (équipement autorisé mais bonus limité) ; UI affiche l’emplacement et le motif d’incompatibilité.
- **EQUIP-250-03 (VALIDÉ)** : les emplacements et équipements portés sont visibles via représentation compacte et inspection ; pas d’affichage de cases fictives sur les créatures sans slot.

## Q251–Q252 — Départ du porteur et remplacement

- **EQUIP-251-01 (VALIDÉ)** : si le porteur **quitte le plateau** (destruction, retour en main, bannissement, transfert de zone), ses équipements sont détachés et chacun rejoint **la défausse de son propriétaire**, quelle que soit la destination du porteur.
- **EQUIP-251-02 (VALIDÉ)** : un effet de carte peut **explicitement** récupérer, transférer, conserver ou rediriger un équipement ; aucune conservation implicite avec le porteur.
- **EQUIP-251-03 (VALIDÉ)** : le bonus du porteur cesse quand l’équipement n’est plus attaché ; changements d’état, déclenchements, ordre et logs suivent les moteurs normatifs Q13–Q14, Q159–Q164, Q240–Q244.
- **EQUIP-252-01 (VALIDÉ)** : attacher un nouvel objet à un emplacement **occupé** est permis si les restrictions de porteur et les conditions de jeu sont satisfaites ; l’ancien équipement est détaché et envoyé à la **défausse de son propriétaire**, sauf exception explicite Q251.
- **EQUIP-252-02 (VALIDÉ)** : le nouvel objet occupe le même emplacement ; les modifications de statistiques dues au retrait et au nouvel attachement sont traitées par le moteur normatif de stabilisation, sans nouvel ordre FIFO ad hoc.
- **EQUIP-252-03 (VALIDÉ)** : toute transition réelle d’équipement est enregistrée comme changement de zone/attachement pour les sauvegardes et replays, sans réémettre artificiellement les déclenchements sur de simples recalculs.

## Q254 — Charges particulières, absence de durabilité générale

- **EQUIP-254-01 (VALIDÉ)** : **aucun équipement n’a de durabilité universelle par défaut** : la majorité reste active tant que son état et son attachement le permettent.
- **EQUIP-254-02 (VALIDÉ)** : un équipement peut **explicitement** définir des charges, un nombre initial et les événements/actions qui en consomment une ou plusieurs.
- **EQUIP-254-03 (VALIDÉ)** : la conséquence à zéro charge est **définie par le texte de la carte** ; zéro n’est **pas** synonyme automatique de destruction. Exemples possibles : défausse, désactivation d’une capacité, maintien d’un bonus passif.
- **EQUIP-254-04 (VALIDÉ)** : les charges sont par **instance**, pas par définition ; modifications et état sont journalisés et sérialisés, respectant les budgets, l’ordre et les protections Q109/Q111–Q124 déjà validés.
- **EQUIP-254-05 (VALIDÉ)** : compteur de charges affiché uniquement sur les équipements concernés ; feedback expressif et lisible, sans compteur fantôme sur les équipements sans charges.

## Dépendances, exclusions et ouvertures

- **Sources canoniques** : [Q245–Q254 dans le journal](../DECISIONS.md), [tests](../09-technical/acceptance-tests.md), [plateau](battlefield.md), [zones](zone-events.md), [effets et auras](tribes-positioning-and-stabilization-v25.md), [FIFO](event-queue.md), [artefacts](../03-progression/rewards-rarity-and-ascension.md), [boosters](../03-progression/ascension-start-boosters-and-autobuild.md).
- **Invariants** : 0–2 slots par créature (pas 2 obligatoires), deux catégories, 4 copies deck+réserve et variantes par famille Q207/Q227, 40 cartes standard Q208/Q217, 20 socle + 2×15 boosters Q215, 100 cartes indépendantes sur ≈170 définitions MVP Q230 révisée.
- **OUVERT** : gestion d’un changement dynamique de capacité d’emplacement sur une créature déjà équipée ; cible et coût précis du jeu des équipements ; comportement d’une capacité à charges impossible à payer ; règles d’activation de capacités d’équipement ; éventuelle spécification des objets à charges consommables. Ne pas inférer de règle nouvelle.

---

## Fichier : `01-combat/event-queue.md`

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

---

## Fichier : `01-combat/hand-and-discard.md`

# Main, défausse et recyclage — v0.5

**Statut : Q38–Q40, Q43–Q44 VALIDÉES.**

Dépendances : [draw-and-fatigue](draw-and-fatigue.md), [targeting](targeting.md), [event-queue](event-queue.md).

## VALIDÉ
- **HAND-001 — Q39** : taille maximale initiale de main = 7 cartes ; améliorable par RPG, artefacts et capacités. Main initiale = 6 (voir [draw-and-fatigue](draw-and-fatigue.md)).
- **HAND-002 — Q38** : cartes nouvellement piochées excédant le maximum défaussées automatiquement, sans choix manuel ; elles quittent le deck.
- **HAND-003 — Q40** : toute diminution de taille maximale prend effet immédiatement. Si la main est trop pleine, défausser automatiquement les cartes arrivées le plus récemment, jusqu'au nouveau maximum. Conserver un ordre d'arrivée stable pour les départages.
- **DECK-001 — Q43** : aucun recyclage automatique lorsque le deck est vide. Seuls les effets explicites peuvent réintégrer des cartes dans le deck ; toute fatigue passée reste acquise.
- **ZONE-001 — Q44** : une unique défausse rassemble sorts joués, créatures détruites et cartes défaussées. Pour chaque carte, conserver le type, l'origine et la raison de mise en défausse ; les effets pourront filtrer selon ces informations.

## Parcours nominal PROPOSÉ (non encore validé)
Deck → main ; créature : main → plateau → défausse lors de destruction ; sort : main → défausse après résolution ; recyclage par effet : défausse → deck. La provenance exacte et les attributs historiques restent à formaliser.

## Exemple testable
Main 7/7 (cartes arrivées en ordre A, B, C, D, E, F, G). Nouvel effet main max −2 : défausser G puis F ; rester avec A à E.

## OUVERT
Q45 : bannissement et zone distincte ; sorts joués, créatures mortes, résurrection ; retour en main ; statut des améliorations permanentes ; devenir des cartes jetons ; conservation d'identité des cartes entre zones ; effets de défausse.

## Mises à jour v0.6 — Q45, Q53, Q54
- **VALIDÉ** : zone de bannissement séparée ; inaccessible aux effets ordinaires pendant le combat, sans perte persistante : [banishment](banishment.md).
- **VALIDÉ** : récupération depuis la défausse avec main pleine → retour immédiat à la défausse, sans fatigue : [recovery](recovery.md).
- **VALIDÉ** : les causes d'arrivée en défausse produisent des événements distincts, et récupération débordante déclenche récupération puis défausse : [zone-events](zone-events.md).
- Correction de statut : les anciennes mentions de Q45 « ouvert » ci-dessus sont **remplacées** par le document [banishment](banishment.md). Les dispositions détaillées de résurrection sont désormais [VALIDÉES Q46–Q52](resurrection.md).

## Référence croisée v2.2 — fatigue et recherche
- La perte initialement fixe de Q41 est **remplacée par le compteur progressif Q210** ([pioche et fatigue](draw-and-fatigue.md)) ; l’absence de recyclage automatique Q43 reste inchangée.
- Recherche en pioche Q211–Q214 : [contrat de recherche](deck-search-and-fatigue-v22.md). Rechercher et déplacer une carte directement vers la main ne constitue pas une pioche, sauf instruction expresse ; les règles de main pleine doivent néanmoins être respectées.

---

## Fichier : `01-combat/healing.md`

# Soins, événements de soin et attribution — Q75–Q77

**Statut : VALIDÉ.** Voir [l'attribution des dégâts](damage-attribution.md), [les effets atomiques](effect-resolution.md), [la file d'événements](event-queue.md), [les modifications des PV maximum](temporary-effects.md) et [les tests](../09-technical/acceptance-tests.md).

## Q75 — Soins excédentaires

- `requestedHeal` = quantité positive de soin demandée. `effectiveHeal = min(requestedHeal, max(0, maxHp-currentHp))` pour une cible vivante éligible, sauf effet spécial explicite.
- `effectiveHeal` est le seul montant ajouté aux PV de la cible. Tout surplus est perdu par défaut ; un effet de carte peut explicitement convertir ce surplus.
- Les soins ne dépassent jamais les PV maximum ordinaires. Conserver séparément `requestedHeal`, `effectiveHeal`, `overheal` (surplus).

## Q76 — Déclenchement ON_HEAL

- `ON_HEAL` est émis **uniquement si effectiveHeal ≥ 1**. Un soin tenté avec zéro PV restauré ne déclenche rien.
- L'événement conserve le montant effectivement restauré, non le montant demandé.
- Les réactions rejoignent la [file FIFO](event-queue.md), après l'achèvement de l'opération ou effet composé ; elles ne l'interrompent pas.
- Une augmentation des PV actuels accompagnant un gain de PV maximum **n'est pas un soin** : aucun `ON_HEAL` ([Q78](temporary-effects.md)).

## Q77 — Soins simultanés compatibles

- Les composantes simultanées compatibles visant la même cible dans la même opération atomique sont additionnées **avant** le plafonnement aux PV manquants.
- **Un seul** `ON_HEAL` est émis par cible et opération atomique lorsque le total restauré est ≥ 1 ; valeur = soin effectif total.
- Les parts de soin effectivement attribuées aux sources sont des entiers ; leur somme est égale au soin effectif total. Attribution proportionnelle aux contributions demandées positives par **méthode des plus grands restes**, exactement comme [Q68–Q69 pour les dégâts](damage-attribution.md). Départager les égalités par ordre stable des sources, puis ID stable.
- La contribution d'une source peut être créditée de **0**, même si elle a participé au soin global. Q77 **ne valide pas** un événement distinct de type `ON_HEAL_DONE` pour chaque source : une seule émission `ON_HEAL` par cible.
- Exemple : cible 4/10, soins A=4 et B=5 ; soin effectif 6, surplus 3 ; attribution A=3, B=3 ; `ON_HEAL(6)` une seule fois.

## Points ouverts

- La sémantique d'éventuelles capacités spécifiques aux *sources* de soins reste à définir ; ne pas les assimiler automatiquement à `ON_HEAL`.
- Interactions de soins et dégâts au sein de **composantes incompatibles**, effets de remplacement non spécifiés ou modificateurs spéciaux de soin : définir explicitement avant implémentation.

---

## Fichier : `01-combat/hero-deck-mana.md`

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

---

## Fichier : `01-combat/instance-identity.md`

# Identité des instances et dernier état connu

**VALIDÉ Q19, Q56–Q58.** Dépendances : [événements](event-queue.md), [ciblage](targeting.md), [résurrection](resurrection.md), [zones](zone-events.md).

## Règles validées
- **INST-001 (Q57)** — `cardId` désigne la même carte acquise, malgré les transferts.
- **INST-002 (Q57)** — `instanceId` désigne un séjour précis sur le champ de bataille ; chaque nouvelle entrée crée un identifiant neuf.
- **INST-003 (Q57)** — Mort, retour en main ou bannissement termine l'instance du plateau. Les mouvements entre cases du plateau préservent l'instance.
- **INST-004 (Q19/Q57)** — Une capacité déjà en file demeure attachée à l'instance qui l'a déclenchée ; une résurrection ne la rattache jamais à l'instance suivante.
- **INST-005 (Q56)** — Une capacité lisant une caractéristique variable de sa source utilise sa valeur **à la résolution** si cette source demeure sur le plateau.
- **INST-006 (Q56–Q57)** — Si la source a quitté le plateau, utiliser les valeurs de son **dernier état connu immédiatement avant son départ** ; ne pas consulter sa nouvelle instance.
- **INST-007 (Q58)** — Une cible explicitement associée à une ancienne instance demeure invalide même si la même carte réapparaît.

## Exemple vérifiable
Instance I1 avec ATQ 5 déclenche une capacité d'attaque dépendante de l'ATQ. I1 meurt avec ATQ 5, carte ressuscitée en I2 à ATQ 3 : la capacité de I1 utilise 5, I2 n'est pas la source. Si I1 avait perdu 2 ATQ avant sa mort, la capacité utiliserait 3.

## OUVERT
- Définir la structure sérialisée des instantanés (valeurs, effets actifs, propriétaire, position et contexte) ; ne pas stocker des liens vers des objets d'instance mutables.
- Cas des caractéristiques modifiées *dans une zone hors plateau* : non spécifié pour les capacités de source d'instance ancienne.

## Tests
[TEST-047 à TEST-051](../09-technical/acceptance-tests.md).

## Extension VALIDÉE Q88–Q94
La source d'une capacité accordée à une créature est la créature porteuse (`instanceId`) ; conserver séparément son origine historique. Les capacités déclenchées lisent les valeurs courantes à la résolution tant que la source existe, sinon son dernier état connu à la sortie. Une prise de contrôle conserve `cardId` et `instanceId`, tous les états et les capacités en file, en modifiant `controllerId` et éventuellement la case (placement ouvert Q95). Voir [sources et contrôle](source-control.md).

## Référence croisée v1.1

Voir [transferts de contrôle](control-transfers.md) pour instanceId préservé lors d’un transfert Q94–Q104.


## Référence croisée v1.3 — identité et empreintes

Les identifiants pertinents pour les futurs événements et le rejeu sont préservés dans la sérialisation canonique et les instantanés, distinctement de la normalisation anti-cycle Q112. Voir [Q122–Q123](../09-technical/causal-budgets-and-replay.md).



## Carte d'origine et vue d'inspection — Q133–Q134

Le [recto imprimé d'origine est présenté séparément de l'état effectif et des effets actifs](../02-art-direction/card-and-board-ui.md). `instanceId` et états fonctionnels persistent indépendamment de la vue d'interface.

---

## Fichier : `01-combat/movement.md`

# Déplacements et permutation

**Statut : cœur validé** · Q05–Q08. Dépend de [battlefield.md](battlefield.md) et [summoning.md](summoning.md).

## Règles VALIDÉES
- **MOV-001** : déplacement naturel = changement entre ligne d'attaque et ligne de défense, **dans la même colonne**.
- **MOV-002** : coût fixe de **1 mana**.
- **MOV-003** : chaque créature peut utiliser son déplacement naturel **une fois par tour**.
- **MOV-004** : une créature peut se déplacer pendant son tour d'invocation.
- **MOV-005** : un changement de colonne est possible uniquement par sort ou capacité.
- **MOV-006** : permutation entre deux créatures alliées d'une même colonne : **1 mana au total**.
- **MOV-007** : permutation consomme le droit de déplacement naturel des **deux** créatures ; chacune doit donc encore en disposer.
- **MOV-008** : les déplacements par sorts/capacités ne consomment pas le droit de déplacement naturel.
- **MOV-009** : les effets peuvent déplacer une créature plusieurs fois dans un tour, modifier ligne ou colonne, et contourner la priorité de contestation.
- **MOV-010** : emplacement d'arrivée libre obligatoire sauf texte explicite autorisant échange/remplacement.
- **MOV-011** : chaque effet indique s'il concerne les créatures alliées, adverses ou les deux.

## Exemples
- Une créature invoquée en défense peut rejoindre l'attaque immédiatement pour 1 mana si le slot est libre.
- Une colonne avec deux alliés peut permuter pour 1 mana ; chacun perd son déplacement naturel du tour.
- Un sort peut déplacer une créature qui s'est déjà déplacée naturellement ; le sort peut choisir une autre colonne.

## OUVERT
- Restrictions d'état « immobilisé », interactions entre plusieurs déplacements par effets, timing exact des bonus à l'entrée/sortie d'une ligne.
- Conditions particulières empêchant les mouvements involontaires.

---

## Fichier : `01-combat/recovery.md`

# Récupération et recyclage — v0.6

**Statut : VALIDÉ (Q43, Q53) ; autres propriétés ouvertes.** Dépend de [hand-and-discard](hand-and-discard.md), [draw-and-fatigue](draw-and-fatigue.md), [zone-events](zone-events.md), [targeting](targeting.md), [banishment](banishment.md).

## VALIDÉ
- **REC-001 (Q53)** : une récupération ordinaire tente de déplacer une carte depuis la défausse vers la main.
- **REC-002** : avec une place disponible, la carte rejoint la main.
- **REC-003** : si la main est pleine, la carte récupérée retourne immédiatement en défausse (elle ne remplace pas une carte choisie).
- **REC-004** : la récupération ne constitue jamais une pioche depuis le deck ; pas de fatigue.
- **REC-005 (Q54)** : même en cas de retour immédiat à la défausse, les événements de récupération puis de défausse sont produits, dans cet ordre, et suivent la file FIFO ([zone-events](zone-events.md)).
- **REC-006 (Q43)** : le recyclage depuis la défausse vers le deck n'existe que sous l'effet explicite d'une carte, capacité ou artefact ; jamais automatiquement quand le deck est vide.
- **REC-007 (Q45)** : les cartes bannies sont exclues de ces effets ordinaires pendant le combat.
- **REC-008 (Q20)** : cible explicitement désignée absente de la zone pertinente à la résolution : effet ciblé échoue, sans reciblage ni restitution du mana.

## Exemple
Main 7/7, sort « récupère un sort de défausse » : le sort ciblé est récupéré puis défaussé immédiatement ; événements `ON_CARD_RECOVERED` et `ON_DISCARD` sont produits, même si la main finit à 7/7. Ne pas traiter cela comme pioche ou fatigue.

## OUVERT
- Comportement exact du sort de récupération si la cible manque dès le lancement ; texte et ciblage des capacités avec plusieurs composantes.
- Effets déclenchés par la même carte après retour à la défausse, politique anti-boucle des interactions répétées.
- Carte récupérée alors que la main est temporairement réduite à zéro emplacement ; même principe, seuils à tester.

## Référence croisée Q210–Q214
La récupération depuis la défausse (Q53–Q54) n'est **pas** une recherche dans la pioche ni une pioche. La fatigue progressive (Q210) et la recherche dans la pioche ([Q211–Q214](deck-search-and-fatigue-v22.md)) n'altèrent pas les événements de récupération et de défausse définis ici.

---

## Fichier : `01-combat/resurrection.md`

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

---

## Fichier : `01-combat/source-control.md`

# Sources, contrôle et capacités différées — Q85–Q94

**Statut : VALIDÉ Q85–Q94.** Dépendances : [identités](instance-identity.md), [file FIFO](event-queue.md), [expiration](temporary-effects.md), [attribution des dégâts](damage-attribution.md), [prévention](damage-prevention.md), [résurrection](resurrection.md), [ciblage](targeting.md), [tests](../09-technical/acceptance-tests.md).

## Déclenchements après expiration — Q85–Q87

- **SRC-085-01 (Q85 A)** : pour une **même cible**, enregistrer `ON_DEATH` ou `ON_LETHAL_PREVENTED` **avant** les événements individuels `ON_EFFECT_EXPIRED`. Entre plusieurs cibles, respecter les priorités générales (camp actif ; colonnes 1→6 ; offensive avant défensive), puis FIFO. Il n'y a pas d'exécution intermédiaire au sein de l'expiration atomique (Q80/Q84).
- **SRC-086-01 (Q86 A)** : capturer **avant** l'opération atomique les capacités actives, y compris celles des créatures qui vont mourir. L'éligibilité au déclenchement d'expiration se détermine avec cet instantané ; une créature morte simultanément peut donc déclencher `ON_EFFECT_EXPIRED`.
- **SRC-087-01 (Q87 A)** : une capacité temporaire accordée par un effet peut réagir à **l'expiration de cet effet même**, car elle était active dans l'instantané initial. Une fois mise en file, sa disparition ne l'annule pas. Chaque effet expiré constitue un événement individuel (Q84).
- **SRC-087-02** : empêcher les cycles de déclenchements non terminants ; la protection technique exacte demeure ouverte.

## Sources et identités — Q88–Q90

- **SRC-088-01 (Q88 A)** : quand un sort, un artefact ou un effet accorde une capacité **à une créature**, la **créature porteuse** est la source de gameplay de cette capacité et des dégâts qui en résultent ; l'origine (sort/artefact) reste enregistrée pour l'historique.
- **SRC-088-02** : distinguer `cardId`, `instanceId`, `sourceInstanceId` et, dans le modèle conseillé, `effectInstanceId`, `abilityInstanceId`, `originCardId`. Les derniers noms sont des champs suggérés, pas un schéma de sérialisation imposé.
- **SRC-089-01 (Q89 A)** : une capacité mise en file conserve l'**ancienne instance** et, si elle quitte le plateau, ses propriétés pertinentes de **dernier état connu** : caractéristiques, vol de vie, identité et propriétaire. Une résurrection crée un autre `instanceId` sans réaffecter cette capacité (Q57–Q58).
- **SRC-090-01 (Q90 A)** : quand la capacité se résout, lire les caractéristiques variables **actuelles** si l'instance source est encore sur le plateau ; sinon lire son **dernier état connu au départ**. Les nouveaux bonus d'une instance ressuscitée ne modifient jamais l'ancienne capacité.

## Dégâts, vol de vie et contrôle — Q91–Q93

- **SRC-091-01 (Q91 A)** : vérifier la présence du **vol de vie lorsque les dégâts sont effectivement appliqués** (état courant si source présente, dernier état connu sinon). Enregistrer cette propriété avec la quantité de dégâts attribuée dans `ON_DAMAGE_DEALT`. Les évolutions ultérieures du vol de vie ne modifient pas l'événement déjà enregistré.
- **SRC-092-01 (Q92 A)** : `ownerId` demeure le propriétaire permanent de la carte ; `controllerId` désigne son camp contrôleur. **Évolution explicite de Q70** : le vol de vie soigne le héros du **contrôleur de la source au moment des dégâts**, non nécessairement son propriétaire. Fixer le destinataire du soin dans `ON_DAMAGE_DEALT`, même si le contrôle change avant la résolution de la FIFO. La quantité de soin est la quantité effective attribuée à la source (Q68–Q70).
- **SRC-093-01 (Q93 A)** : une capacité en attente conserve les cibles et références de camps déterminées à son déclenchement ; changer le contrôle de la source ne les inverse pas automatiquement. Valider de nouveau la légalité des cibles à la résolution (Q57–Q60). Pour les bénéfices comme le vol de vie, utiliser le contrôleur effectif de la source au moment **des dégâts** (Q92).
- **SRC-093-02** : la modification de contrôle n'annule pas une capacité déjà déclenchée. Quand une cible n'est plus légale, l'opération ciblée échoue sans re-ciblage et sans remboursement, selon les règles de [ciblage](targeting.md).

## Prise de contrôle et instance — Q94

- **SRC-094-01 (Q94 A)** : la prise de contrôle **conserve `instanceId` et `cardId`** ; seul `controllerId` change (et la position si nécessaire, selon les règles de [transfert](control-transfers.md) (Q95–Q104)). `ownerId` demeure constant.
- **SRC-094-02** : préserver PV actuels/max, blessures, bonus/malus, protections et capacités déjà déclenchées ; leurs durées continuent selon les tours du **camp ayant appliqué chaque effet** (Q81–Q83), indépendamment du nouveau contrôleur.
- **SRC-094-03** : la prise de contrôle n'est **ni une invocation, ni une mort, ni une résurrection** : aucun `ON_SUMMON`, `ON_DEATH`, `ON_RESURRECT` implicite. Le traitement du plateau (case occupée, transfert impossible, retour du contrôle) est défini dans [transferts](control-transfers.md) (Q95–Q104).

## Exemples normatifs

1. Deux bonus expirent, leur retrait tue leur créature, qui possède intrinsèquement « 2 dégâts lorsqu'un bonus expire » : snapshot préalable ; `ON_DEATH` précède les deux `ON_EFFECT_EXPIRED` ; deux réactions de 2 dégâts peuvent se résoudre si le combat continue (Q85–Q86).
2. Un bonus confère lui-même « 2 dégâts lorsqu'un bonus expire » : cette capacité se déclenche aussi à **sa propre** expiration (Q87).
3. Sort S confère à créature I1 une capacité de dégâts : source = I1, historique = S (Q88). I1 meurt avec vol de vie, est ressuscitée en I2 : l'ancien événement ne lit jamais I2 ; utilise le dernier état connu d'I1 (Q89–Q91).
4. I1 déclenche « dégâts = ATQ » à 3 ATQ, reçoit +2 avant résolution : 5 dégâts si I1 est encore sur plateau. Si I1 quitte le plateau, utiliser l'ATQ constatée à son départ (Q90).
5. Une créature initialement ennemie, contrôlée par le joueur au moment d'infliger 4 PV effectifs de dégâts avec vol de vie : le héros **joueur** reçoit une guérison différée de 4 PV (Q92), même si le contrôle revient à l'ennemi avant cette guérison.
6. Une capacité se déclenche sous contrôle ennemi en visant le héros joueur ; le joueur prend le contrôle avant sa résolution : cible héros joueur **conservée**, vol de vie joueur si les dégâts sont appliqués sous son contrôle (Q93).
7. Contrôle d'une créature I1 à 5/8 PV avec +2 ATQ, une protection létale et une capacité en FIFO : après transfert, I1 reste I1 et conserve tout son état ; seul `controllerId` change (Q94). Son placement est régi par Q95.

## Points ouverts après v1.1

- Droit d'attaque et mal d'invocation lors des transferts (Q105).
- Cas particuliers explicitement spécifiés par de futures cartes, sans modifier les invariants ci-dessus.

Voir [transferts de contrôle](control-transfers.md) pour toutes les décisions Q95–Q104 validées.

## Référence croisée v1.2

Les sources et références déjà capturées restent stables dans une FIFO conservée même après une interruption de branche (Q114). Voir [capacités de tour et boucles](turn-control-and-loop-safety.md).

---

## Fichier : `01-combat/summoning.md`

# Invocation des créatures

**Statut : règles fondamentales validées, cas limites ouverts** · Q03–Q04. Dépend de [battlefield.md](battlefield.md), [movement.md](movement.md) et [hero-deck-mana.md](hero-deck-mana.md).

## Règles VALIDÉES
- **SUM-001** : pour invoquer une créature, payer son coût en mana.
- **SUM-002** : toute créature peut être invoquée librement en ligne d'attaque ou de défense, dans un emplacement libre et légal.
- **SUM-003** : lorsqu'il existe des colonnes ennemies **non contestées** (présence d'ennemi et absence de créature alliée), l'invocation doit prioritairement se faire dans l'une de ces colonnes.
- **SUM-004** : si toutes les colonnes avec ennemis sont contestées, le joueur peut invoquer dans toute colonne admissible, y compris vide.
- **SUM-005** : une colonne est contestée dès qu'elle contient une créature de chaque camp, quelle que soit leur ligne.

## Scénarios de test
- Ennemi C2 et C5 ; aucun allié : invocation possible C2 ou C5 (sur ligne libre), pas C1.
- Ennemi C2/C5 ; allié C2 en défense : invocation prioritaire C5.
- Ennemi C2/C5 ; alliés C2/C5 : invocation libre dans les colonnes disposant d'un emplacement.
- Aucun ennemi : invocation libre.

## OUVERT / PROPOSÉ
- **SUM-P01** (proposé) : si les colonnes non contestées n'ont aucun emplacement légal, autoriser une invocation ailleurs plutôt que créer une impasse.
- Définir les cas avec restrictions de cartes, emplacements bloqués, invocations créées par effets et plateau plein.
- Recalculer les obligations à chaque invocation : proposé, cohérent mais non explicitement adopté.

## Extension v0.6 — VALIDÉ Q47
- Les retours par résurrection suivent les mêmes règles de placement et de priorité aux colonnes non contestées : [resurrection](resurrection.md).
- L'absence d'une case légale **au lancement** interdit le sort de résurrection ; une disparition ultérieure des places entraîne l'échec du retour.

## Référence croisée v1.1

Voir [transferts de contrôle](control-transfers.md) pour mêmes règles de placement pour transfert de contrôle Q95.

---

## Fichier : `01-combat/targeting.md`

# Ciblage et invalidation

**Statut : comportement principal validé** · Q20. Dépend de [event-queue.md](event-queue.md) et [abilities.md](abilities.md).

## Règles VALIDÉES
- **TGT-001** : lorsqu'un effet désigne explicitement une cible, celle-ci reste liée à l'effet durant son attente.
- **TGT-002** : si la cible devient invalide avant la résolution, l'effet qui la concerne échoue.
- **TGT-003** : aucun reciblage automatique.
- **TGT-004** : le mana déjà payé n'est **pas remboursé** lorsque l'effet échoue.
- **TGT-005** : les effets en file peuvent se résoudre même si leur **source** disparaît (distinct de la validité de la cible).

## Exemple
Un effet à 1 mana cible une créature ennemie ; celle-ci est détruite par une autre capacité avant résolution : l'effet ciblé échoue et 1 mana reste consommé.

## PROPOSÉ / OUVERT
- **VALIDÉ Q59** : les conditions sont vérifiées au lancement et à la résolution.
- **VALIDÉ Q60–Q61** : résolution partielle et opérations indépendantes par défaut.
- Texte « créature ennemie ayant le moins de PV » : sélection à la résolution plutôt qu'au lancement (proposé).
- **VALIDÉ Q57–Q58** : toute ré-entrée crée une nouvelle instance ; anciens ciblages invalides.

## Extension v0.6 — VALIDÉ Q51, Q52
- Les sorts de résurrection ne sont **pas jouables** sans emplacement légal dès le lancement ([resurrection](resurrection.md)).
- Au moment de chaque retour, la cible doit toujours être valide dans la défausse et un placement doit être légal ; sinon cette tentative échoue sans nouvelle cible ni remboursement du mana déjà payé.
- Les résurrections multiples préservent leurs réussites précédentes (Q52).

## Extension v0.7 — VALIDÉ Q58–Q60
- **TGT-006 (Q58)** — La cible de créature est identifiée par son `instanceId`. Après son départ du plateau, le ciblage devient définitivement invalide, même si le `cardId` revient dans une nouvelle instance.
- **TGT-007 (Q59)** — À la résolution, revérifier identité et **toutes** les conditions de ciblage : camp, ligne, colonne, type et autres restrictions explicites. Un mouvement sur le plateau conserve l'identité, pas forcément la légalité.
- **TGT-008 (Q60)** — Chaque cible d'un effet multicible est revérifiée individuellement : les cibles invalides échouent sans reciblage ; les cibles restantes sont affectées normalement.
- **TGT-009 (Q60–Q61)** — La partie ciblée échoue si toutes les cibles manquent, mais les opérations indépendantes continuent ; les opérations conditionnelles et indivisibles suivent leurs propres prérequis explicites.
- **TGT-010** — Aucun remboursement du mana lors d'une invalidation à résolution.
- Voir [instances](instance-identity.md) et [effets composés](effect-resolution.md).

## Extension VALIDÉE Q93
Le changement de contrôleur d'une source après le déclenchement ne réinterprète pas automatiquement « allié », « ennemi » ni les cibles/références de camp déjà fixées. Les restrictions de légalité du ciblage sont revérifiées à la résolution ; aucun re-ciblage automatique. Voir [sources et contrôle](source-control.md).

## Référence croisée v1.1

Voir [transferts de contrôle](control-transfers.md) pour échec transfert lorsque cases invalides à résolution Q96.

---

## Fichier : `01-combat/temporary-effects.md`

# PV maximum, effets temporaires, échéances et expiration — Q26, Q78–Q84

**Statut : VALIDÉ** pour les règles ci-dessous. Voir [soins](healing.md), [prévention létale](damage-prevention.md), [tour](turn-sequence.md), [résolution atomique](effect-resolution.md), [événements](event-queue.md) et [tests](../09-technical/acceptance-tests.md).

## Q26 et Q78 — Variation de PV maximum : ni soin ni dégât

- Gagner `+X maxHp` accorde également `+X currentHp` ; perdre ce bonus retire `X` aux **deux**. Les blessures sont préservées.
- Ces modifications sont des changements de caractéristiques, **pas** des soins ni des dégâts. Aucun `ON_HEAL`, `ON_DAMAGE_TAKEN` ou `ON_DAMAGE_DEALT` n'est généré du seul fait de ce changement.
- Exemple : 4/6 → (+3 maxHp) 7/9 → (−3 maxHp) 4/6.
- Des événements spécialisés pour le changement de caractéristiques ne sont **pas encore validés**.

## Q79 — Mort provoquée par modification de caractéristiques

- Un retrait de bonus peut amener `currentHp ≤ 0` et provoquer un événement létal.
- Les protections létales **générales** peuvent intervenir immédiatement, dans l'ordre déterministe de [Q73](damage-prevention.md), sauf restriction textuelle explicite. Une seule protection consommée par événement létal.
- Protection effective : `ON_LETHAL_PREVENTED`, pas `ON_DAMAGE_TAKEN` ; pas `ON_DEATH`.
- Pas de prévention : mort effective, `ON_DEATH` ; aucun déclencheur de dégât.
- Exemple : 2/6 avec bonus +3 expirant → résultat théorique −1/3 ; protection « survit à 1 PV » → 1/3 et `ON_LETHAL_PREVENTED`.

## Q80 — Expirations simultanées atomiques

- Tous les bonus et malus arrivés **au même instant** sont retirés dans **une seule opération atomique**. Calculer les effets combinés et leurs compensations **avant** de déterminer les morts et protections.
- Une cible ne traverse pas une succession fictive de morts liée à l'ordre technique de retrait ; un seul événement létal potentiel par cible pour ce retrait atomique.
- Préventions immédiates, commit, contrôle de victoire/défaite, puis mise en file des réactions ; ne pas résoudre de déclencheurs entre les retraits.
- Exemple : +3 PV maximum et −2 PV maximum expirent simultanément : appliquer l'effet **net** de leurs retraits, pas deux états intermédiaires.

## Q81 et Q83 — Décompte des durées

- Une durée numérique « pendant N tours » compte les tours **personnels du camp ayant appliqué l'effet**, et non les tours globaux ou ceux du bénéficiaire.
- Si l'effet est appliqué pendant **son propre tour**, ce tour en cours compte comme **tour personnel 1** ; il expire à la fin de son Nᵉ tour personnel compté, sauf échéance explicite.
- Si l'effet est appliqué pendant **le tour adverse**, le **prochain** tour personnel du camp qui l'applique compte comme tour 1 ; il expire à la fin de son Nᵉ tour personnel compté.
- « Jusqu'à la fin du tour » signifie **fin du tour actuellement actif**, sans attendre un tour personnel. Les échéances explicites (« début de ton prochain tour », « fin du combat », etc.) priment sur la convention de durée numérique.
- Exemple : malus appliqué par le joueur pendant T1 ennemi « 2 tours » → T2 joueur = 1/2, T3 ennemi = actif, T4 joueur = 2/2, expiration en fin de T4.
- `appliedByCamp`, moment d'application et type d'échéance doivent être conservés, sans changer le détenteur logique après disparition de la source (précisions sur contrôle transféré encore ouvertes).

## Q82 — Instants exacts d'expiration

- Échéance **début de tour** : retrait avant croissance de mana → restauration → capacités de début de tour → pioche.
- Échéance **fin du tour courant** : l'effet reste actif lors des attaques automatiques et de leurs réactions ; il expire **après résolution des attaques et réactions**, avant changement de camp.
- Tous les effets dont l'échéance coïncide sont retirés atomiquement. Les réactions générées par l'expiration sont résolues via FIFO avant progression de phase si le combat n'est pas terminé.
- Un bonus offensif « jusqu'à la fin du tour » s'applique donc encore à l'attaque automatique normale du tour.

## Q84 — Granularité des déclencheurs d'expiration

- **Un `ON_EFFECT_EXPIRED` par effet temporaire retiré**, même si l'ensemble est retiré en une seule opération atomique.
- Chaque événement conserve au minimum `effectInstanceId`, type (bonus/malus), source, cible et valeur/variation portée par l'effet, ainsi que l'échéance.
- Tous les événements sont ajoutés **après** commit du retrait atomique et contrôle de victoire. Ils n'interrompent pas le retrait.
- Ordre entre cibles : [Q13](event-queue.md) (camp actif, colonnes 1→6, offense avant défense) ; entre effets de la même cible : **ordre d'application**, puis ID technique stable.
- Exemple : `+2 ATQ`, `+3 maxHp`, `−1 ATQ` expirent ensemble sur une unité : **3 événements** ; une capacité « chaque fois qu'un bonus expire » voit **2 bonus** et se déclenche deux fois, si ses autres conditions sont satisfaites.
- **Pas d'événement global `ON_EFFECTS_EXPIRED` imposé** par Q84.
- Un événement d'expiration se distingue de la mort éventuelle liée au retrait et de la prévention létale ; `ON_DEATH`/`ON_LETHAL_PREVENTED` restent soumis aux règles existantes.

## Points ouverts

- Définition future des événements propres aux **augmentations de caractéristiques** ; ambiguïtés des valeurs maxHp extrêmes (plancher, écrêtage) ; perte de bonus sur unité déjà quittée du plateau et éventuels effets non liés à une cible vivante.
- Ordonnancement exact **inter-familles** de `ON_EFFECT_EXPIRED`, `ON_DEATH`, `ON_LETHAL_PREVENTED` lorsqu'un même retrait atomique provoque les trois reste à préciser : Q84 fixe la granularité et l'ordre **entre événements d'expiration**, pas une nouvelle priorité universelle entre types.
- Règles de transfert de contrôle d'un effet, suppression/dispel anticipé distinct de l'expiration naturelle, et durée de statut à échéance déclenchée demeurent ouvertes.

## Extension VALIDÉE Q85–Q87
À une expiration atomique, les capacités éligibles sont capturées **avant** le retrait, y compris celles de créatures mourant simultanément et celles **accordées par l'effet expirant lui-même** (Q86–Q87). Pour chaque cible, les événements de mort/prévention sont enregistrés **avant** les événements individuels d'expiration (Q85). Voir [sources et contrôle](source-control.md).

## Référence croisée v1.1

Voir [transferts de contrôle](control-transfers.md) pour expirations simultanées des contrôles Q99–Q100 et ON_EFFECT_EXPIRED Q104.

## Référence croisée v1.2

**Q109–Q110** : création durant `ON_TURN_END` n’accorde aucune durée minimale ; expiration à l’échéance suivante, même immédiate. La prolongation garde le même `effectInstanceId` et ne génère pas `ON_EFFECT_EXPIRED`. Après échéance passée : retrait atomique après l’opération courante, réactions en queue FIFO. Source : [capacités de tour et boucles](turn-control-and-loop-safety.md).



## Affichage des effets actifs — Q131–Q134

Les [valeurs finales d'ATQ et de PV max, états et durées actives](../02-art-direction/card-and-board-ui.md) sont affichées dans le panneau d'inspection. Ne jamais compter une expiration comme effet encore actif ; la conservation des blessures lors de modifications du maximum de PV reste normative ici.


## Référence de présentation v1.5

L’affichage en langage naturel des durées, l’échéance conservée après changement de contrôle, la modification de durée et son feedback sont décrits dans [UI des échéances Q135–Q144](../02-art-direction/tooltips-durations-and-vfx.md). Ces animations n’altèrent jamais les règles de Q81–Q84 ou Q109–Q110.

---

## Fichier : `01-combat/tribes-positioning-and-stabilization-v25.md`

# Peuples, positionnement et stabilisation — décisions Q235–Q244 (v2.5)

**Statut : VALIDÉ.** Ce module consigne surtout des **applications et rappels** des règles historiques, non un deuxième moteur de résolution.

## Sources normatives et règle de précédence

- [File FIFO et priorités Q13–Q14](event-queue.md) ; [résolution atomique et destructions simultanées](effect-resolution.md) ; [dégâts et PV max](damage-resolution.md).
- [Contrôle des boucles FIFO Q111–Q114](turn-control-and-loop-safety.md) et [budgets causaux, journal et replays Q115–Q124](../09-technical/causal-budgets-and-replay.md).
- [Auras, calculs de dépendances et résolution minimale des cycles Q159–Q164](../02-art-direction/spells-auras-and-continuous-effects.md).
- [Familles/peuples et catalogue](../03-progression/mvp-card-catalog-and-tribes.md) ; [sphérier](../03-progression/hero-sphere-and-skill-tree.md) ; [plateau](battlefield.md).

**Non-duplication :** Q242 ne remplace pas Q111–Q124 ; Q243 et Q244 **confirment** Q161–Q164. Les budgets techniques déjà validés demeurent applicables. L’algorithme détaillé de neutralisation minimale reste ouvert dans Q163.

## Registre de décisions

| Question | Choix | Portée |
|---|---|---|
| Q235 | A | Humains, Elfes, Nains et Dragons retenus pour le MVP ; taxonomie extensible, pas nécessairement des peuples de héros. |
| Q236 | C | Identités mécaniques fortes, synergies tribales ouvertes ; decks mixtes et combinaisons éléments/positions. |
| Q237 | C | Sphérier fondé sur mécaniques transversales avec nœuds complémentaires pouvant profiter à certains peuples ; pas de branches tribales obligatoires. |
| Q238 | C | Synergies de peuples globales et positionnelles : rangées, colonnes, voisinage et formations selon le texte. |
| Q239 | C | Adjacent = partage un côté (orthogonal), hors diagonales sauf indication explicite ; autres zones autorisées. |
| Q240 | C | Effets continus recalculés après changements pertinents, aux points de cohérence atomiques ; pas de triggers fabriqués par les itérations. |
| Q241 | C | Conserver les blessures/dégâts subis quand PV max change ; détecter les morts secondaires en lots et stabiliser. |
| Q242 | C | Stabilisation par lots, morts simultanées, puis réactions FIFO ; cycles et budgets causaux existants restent normatifs. |
| Q243 | C | Couches et graphe de dépendances pour effets continus ; confirme Q161 et Q164, sans inventer de nouveau solveur. |
| Q244 | B (confirmation) | Neutralisation minimale et canonique des dépendances cycliques contradictoires ; règle DÉJÀ validée Q162–Q163. |

## Règles complémentaires propres à Q235–Q241

- **RACE-235-01** — Peuples initiaux du catalogue : Humains, Elfes, Nains, Dragons ; types additionnels configurables sans code dur du moteur. Ce choix n’impose pas les peuples des héros.
- **RACE-236-01** — Chaque peuple présente des tendances mécaniques visibles ; certaines capacités ciblent le peuple, mais la majorité des cartes reste utile dans les decks mêlant peuples, éléments et rôles.
- **SPHERE-237-01** — Priorité aux nœuds génériques (armure, magie, formation, mobilité, commandement, éléments) ; bonus tribaux ponctuels et combinables, pas de branche unique obligatoire par peuple.
- **BOARD-238-01** — Les synergies peuvent être globales ou dépendre d’un motif géométrique, et requérir d’autres critères (peuple, élément, contrôleur, état).
- **BOARD-239-01** — `ADJACENT` signifie partage de côté dans la grille 6 × 2 d’un camp ; une diagonale, ligne, colonne, distance ou formation doit être explicitement nommée par la capacité. L’inspection visualise les cases ciblables.
- **BOARD-240-01** — Changement de position, apparition/disparition, contrôle, type, caractéristique ou durée relance les portions du graphe Q161 affectées ; stabilisation aux commits atomiques Q164. Les recalculs purs ne créent aucun événement FIFO.
- **COMBAT-241-01** — Conserver la quantité de dégâts subis lorsque changent les PV max. Une perte de PV max peut rendre une unité létale sans événement de dégâts ; voir règles préexistantes Q26 et Q80–Q86 sur les PV et les opérations simultanées.
- **COMBAT-241-02** — Identifier en lot les unités devenues létales après recalcul cohérent et les traiter comme mortes simultanément pour les déclenchements, dans l’ordre canonique historique des événements Q13/Q27 ; nouvelle stabilisation si disparition d’aura.

## Clarifications de compatibilité Q242–Q244

- **ENGINE-242-01 (rappel)** — Pour un événement atomique : calcul de l’état cohérent, identification par lots des morts, réévaluation si nécessaire ; enregistrement des capacités déclenchées et résolution FIFO sans avancer les réactions avant le commit. Les priorités préexistantes priment.
- **ENGINE-242-02 (rappel)** — Les cycles **de déclenchement** sont identifiés à partir de signatures fonctionnelles du combat et de la FIFO Q112. La neutralisation de la branche et la préservation des événements admis suivent Q111/Q114.
- **ENGINE-242-03 (rappel)** — Les **budgets techniques de sécurité** et les réservations causales par branche, chaîne et opération Q113–Q120 restent en vigueur. Éviter d’affirmer qu’aucune chaîne longue ne peut être interrompue : une limite technique peut bloquer la descendance problématique, sans rollback. Valeurs numériques définitives non fixées.
- **ENGINE-243-01 (rappel)** — Résolution des auras par graphe de dépendances Q161, couches de calcul et points de cohérence Q164 ; ne pas dépendre de l’ordre arbitraire d’apparition des cartes.
- **ENGINE-244-01 (confirmation)** — Cycles d’auras **sans solution stable non ambiguë** : neutralisation minimale ciblant les dépendances problématiques, selon priorité sémantique et départage canonique Q162–Q163. Réévaluation à changement de contexte causal.
- **ENGINE-244-02 (à préciser, non validé comme nouvel algorithme)** — Coût/minimalité exacts, canonicalisation et implémentation des dépendances Q163 restent ouverts ; ne pas inventer une règle supplémentaire ni une valeur numérique de budget.

## Exemples de non-régression

1. Deux Nains voisins reçoivent leur bonus orthogonal ; une case diagonale ne compte pas par défaut.
2. Une aura de commandement disparaît : les blessures restent, des unités peuvent mourir simultanément, puis leurs `ON_DEATH` rejoignent la FIFO selon Q13/Q27.
3. Une boucle `ON_DEATH` ↔ `ON_SUMMON` non progressive est bloquée selon Q111–Q120, sans purger les entrées déjà admises.
4. Deux auras dont les conditions oscillent relèvent de **Q161–Q164**, non des budgets de déclenchement ; elles utilisent la neutralisation ciblée canonique.
5. Une chaîne finie longue peut fonctionner ; les budgets de sûreté par branche/chaîne/opération restent néanmoins effectifs.

## Ouverts

- Identités et métriques exactes des dépendances minimales Q163 ; valeurs de budgets Q113–Q120.
- Identités/effets exacts des premières cartes Humain, Elfe, Nain et Dragon ; équilibre des archétypes.
- Politique détaillée pour situations de sauvegarde au milieu des cascades : utiliser frontières atomiques Q123.

---

## Fichier : `01-combat/turn-control-and-loop-safety.md`

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

## Points ouverts à la clôture de v1.2 (historique)
- **Résolu en v1.3 (Q115–Q124)** : causalité multicausale, plafonds par branche/chaîne/opération, réservation, reprise, journalisation et compatibilité. Voir le module v1.3 lié ci-dessous.
- Autres points non encore arbitrés : variantes d'événement `ON_TURN_END` sur cartes, effets de duration textuellement spécifiques et bornes des caractéristiques.


## Mise à jour validée v1.3

La portée des budgets, la causalité multicausale et les trois niveaux de plafonds ont **été arbitrés en Q115–Q124** : [règles normatives correspondantes](../09-technical/causal-budgets-and-replay.md). Les valeurs quantitatives de plafond restent ouvertes.

---

## Fichier : `01-combat/turn-sequence.md`

# Déroulement des tours — v0.5

**Statut : règles Q09, Q10, Q28, Q29, Q35, Q36 VALIDÉES ; autres phases OUVERTES.**

Dépendances : [hero-deck-mana](hero-deck-mana.md), [draw-and-fatigue](draw-and-fatigue.md), [damage-resolution](damage-resolution.md), [event-queue](event-queue.md).

## VALIDÉ
- **TURN-001 — Q28** : le joueur humain commence toujours le combat, puis alternance des tours.
- **TURN-002 — Q35** : début de tour = croissance de capacité de mana → restauration du mana disponible → résolution des capacités de début de tour → pioche normale.
- **TURN-003 — Q36** : avant le premier tour, pioche initiale de 6 cartes, qui **remplace** la pioche normale de ce premier tour ; première pioche normale au deuxième tour personnel.
- **TURN-004 — Q29** : mal d'invocation : une créature ne peut pas attaquer normalement au tour où elle est invoquée, mais protège sa colonne immédiatement, peut se déplacer et utiliser ses capacités actives selon leurs textes.
- **TURN-005 — Q09** : seules les créatures du joueur actif en attaque effectuent les attaques normales en fin de tour ; pas de riposte automatique de l'adversaire.
- **TURN-006 — Q10** : attaques de la colonne 1 à la colonne 6, en résolvant les événements d'une colonne avant la suivante.
- **TURN-007 — Q31** : mana non dépensé perdu en fin de tour.
- Pendant la phase d'action, le joueur peut invoquer, jouer des sorts et activer des capacités en payant les coûts requis ; voir [movement](movement.md).

## OUVERT / à ne pas inférer
- L'absence de croissance au tour 1 est une **proposition**, pas une validation explicite.
- Calendrier exact des effets de fin de tour ; ordre des effets « début de tour » ; réaction durant le tour adverse ; nombre et ordre d'actions ; effet d'une interruption de combat pendant la préparation.

## Extension v0.6 — VALIDÉ Q48
- Une créature ressuscitée pendant le tour de son propriétaire subit le même mal d'invocation qu'une créature invoquée ordinairement ; voir [resurrection](resurrection.md).

## Expiration des effets — Q81–Q83
- Expirations de **début de tour** avant croissance/restauration du mana, capacités de début de tour et pioche.
- Expirations de **fin de tour** après attaques automatiques et réactions, avant changement de camp.
- Tours numériques = tours personnels du camp qui a **appliqué** l'effet ; tour personnel d'application compte si déjà actif, sinon premier tour personnel suivant compte comme tour 1. Fin du tour courant = tour actif, quel que soit le camp. Voir [effets temporaires](temporary-effects.md).

## Extension VALIDÉE Q94
Lors d'une prise de contrôle, les effets temporaires continuent de compter leur durée selon le camp qui les avait appliqués (Q81–Q83), même si `controllerId` change. Les règles de placement au changement de camp ont été tranchées en Q95–Q104 ; voir [transferts](control-transfers.md). Voir [sources et contrôle](source-control.md).

## Référence croisée v1.1

Voir [transferts de contrôle](control-transfers.md) pour effets de contrôle expirant après combat et transferts Q97–Q104.

## Référence croisée v1.2

**Q105–Q108** : après un transfert effectif, première attaque du premier tour personnel du nouveau contrôleur bloquée (même si acquis hors tour ou retour), sauf exception explicite. Les capacités de début/fin de tour suivent le contrôleur effectif au déclenchement. **Fin de tour** : attaques et réactions → `ON_TURN_END` et réactions entièrement résolues → expiration atomique et réactions → changement de camp. Source normative : [capacités de tour et boucles](turn-control-and-loop-safety.md).


## Référence croisée v1.3 — continuité de combat

La version fonctionnelle des règles est figée pour toute la durée du combat ; l’état de tour/phase doit être sérialisé lors des instantanés sûrs, même avec FIFO non vide. Voir [Q123–Q124](../09-technical/causal-budgets-and-replay.md).

---

## Fichier : `01-combat/victory-and-defeat.md`

# Victoire, défaite et mort des héros

**Statut : cœur validé** · Q15–Q16. Dépend de [damage-resolution.md](damage-resolution.md), [damage-prevention.md](damage-prevention.md), [event-queue.md](event-queue.md).

## Règles VALIDÉES
- **VIC-001** : héros joueur à 0 PV ou moins → **défaite immédiate**.
- **VIC-002** : héros adverse à 0 PV ou moins, joueur survivant → **victoire immédiate**.
- **VIC-003** : décès simultané des deux héros au cours d'un même effet indivisible → **défaite du joueur**.
- **VIC-004** : arrêt immédiat de la résolution à mort d'un héros ; les effets FIFO restants ne s'exécutent pas.
- **VIC-005** : un soin déclenché après des dégâts létaux ne sauve pas un héros mort.
- **VIC-006** : une prévention ou un remplacement intervenant avant la perte de PV peut empêcher la mort.

## Cas de test
- Joueur 3 PV, ennemi 4 PV ; sort simultané 5 dégâts aux deux → défaite.
- Joueur 8 PV, ennemi 4 PV ; même sort → victoire, joueur 3 PV.
- Héros adverse tué par Piétinement → arrêt sans exécuter les morts en file déclenchées pendant l'attaque.

## OUVERT
- Définitions précises d'effet indivisible et d'ordonnancement des dégâts simultanés.
- Défaite par abandon, temporisation, autres conditions spéciales.

## Extension v0.7 — VALIDÉ Q63
- Pour une opération atomique, évaluer les préventions avant commit, valider toutes les modifications simultanément, puis tester victoire/défaite immédiatement avant toute autre opération ou événement FIFO. Mort simultanée des deux héros : défaite joueur. Voir [effect-resolution](effect-resolution.md).


## Vol de vie et prévention — v0.8

Le vol de vie est un soin déclenché **différé** : il ne peut annuler la mort d'un héros validée après une opération atomique. Seuls les effets immédiats de prévention/l'interception autorisés avant le contrôle de victoire peuvent intervenir. Les événements `ON_LETHAL_PREVENTED` sont différés. Voir [attribution des dégâts](damage-attribution.md).

## Mort due à un retrait temporaire — Q79–Q80
Un retrait de bonus qui amène des PV à zéro peut tuer, après application des protections létales générales ; un retrait collectif s'évalue atomiquement et le contrôle victoire/défaite intervient au commit avant les réactions. Voir [effets temporaires](temporary-effects.md).


## Référence de progression v1.9

**Transition victoire → récompenses :** voir [Q175–Q180](../03-progression/rewards-rarity-and-ascension.md). Les gains n’altèrent pas les règles de détermination de l’issue du combat.

---

## Fichier : `01-combat/zone-events.md`

# Transferts entre zones et événements — v0.6

**Statut : VALIDÉ (Q44, Q54), granularité et ordres particuliers ouverts.** Dépend de [hand-and-discard](hand-and-discard.md), [event-queue](event-queue.md), [recovery](recovery.md), [resurrection](resurrection.md), [banishment](banishment.md).

## VALIDÉ — Q44, Q54 (option A)
- **ZEV-001** : la défausse est unique par camp. Conserver les informations de carte, de type, de provenance et de **motif de transfert** afin de distinguer les effets.
- **ZEV-002** : les transferts possèdent des événements distincts par **motif** ; ne pas assimiler « sort utilisé », « créature morte » et « carte défaussée ».
- **ZEV-003 `ON_DISCARD`** : défausse depuis la main ; inclut une nouvelle carte piochée au-delà de la main maximum et la carte récupérée puis immédiatement rejetée par main pleine.
- **ZEV-004 `ON_DEATH`** : créature détruite ; **ne déclenche pas** `ON_DISCARD` simplement parce que la carte rejoint la défausse.
- **ZEV-005 `ON_SPELL_USED`** : sort utilisé, distinct de `ON_DISCARD`.
- **ZEV-006 `ON_CARD_RECOVERED`** : carte récupérée depuis la défausse, y compris si elle est immédiatement défaussée faute de place.
- **ZEV-007 `ON_CARD_RECYCLED`** : carte renvoyée de la défausse dans le deck via un effet.
- **ZEV-008 `ON_CARD_BANISHED`** : carte envoyée dans la zone de bannissement.
- **ZEV-009 `ON_SUMMON` / `ON_RESURRECT`** : les deux déclenchés à la résurrection réussie, invocation avant résurrection (Q48, Q50).
- **ZEV-010** : pour une récupération débordant de la main, générer `ON_CARD_RECOVERED` puis `ON_DISCARD` dans cet ordre de mise en file ; respecter la FIFO et les événements déjà en attente.
- **ZEV-011** : un transfert non réussi ne produit pas les événements de **succès** correspondants. Notamment, une résurrection échouée ne déclenche ni invocation ni résurrection.

## Scénarios
| Transition | Événement principal | `ON_DISCARD` ? |
|---|---|---|
| Main → défausse sur défausse volontaire | `ON_DISCARD` | Oui |
| Deck → défausse par pioche excédentaire | `ON_DISCARD` | Oui |
| Main → défausse à la fin d'un sort joué | `ON_SPELL_USED` | Non |
| Plateau → défausse lors de mort | `ON_DEATH` | Non |
| Défausse → main → défausse, main pleine | `ON_CARD_RECOVERED`, puis `ON_DISCARD` | Oui |
| Défausse → deck par effet | `ON_CARD_RECYCLED` | Non |
| Carte → bannissement | `ON_CARD_BANISHED` | Non |

## PROPOSÉ / OUVERT
- Exacte taxonomie des autres transferts (renvoi direct au deck, transformation, sacrifice, destruction hors combat).
- Les « cartes de pioche excédentaires » transitent-elles virtuellement par la main ou vont-elles directement en défausse ? Seul le résultat et `ON_DISCARD` sont validés, pas l'animation ou la séquence interne.
- Quand un événement écoute le retour d'une carte déjà déplacée, captures de données et identité de carte nécessaires ; prévention des boucles selon [event-queue](event-queue.md).
- Ordre entre plusieurs capacités déclenchées de la même famille, en l'absence de priorité spatiale.

## Référence croisée v1.1

Voir [transferts de contrôle](control-transfers.md) pour ON_DEATH en mort de placement et ON_CONTROL_CHANGED Q104.

---

## Fichier : `02-art-direction/README.md`

# Direction artistique / UI — index v1.8

- [Style fantasy illustré, cartes, jetons, états et inspection — Q126–Q134](card-and-board-ui.md).
- [Tooltips, durées et orchestrateur Juicy & Fast-Paced — Q135–Q144](tooltips-durations-and-vfx.md).
- [Plateau, décors, aides au placement, prévisualisation tactique, drag-and-drop, clic et tactile — Q145–Q154](board-and-tactical-preview.md).
- [Prévisualisation des sorts, effets multi-cibles, auras, cycles de dépendances et points de cohérence — Q155–Q164](spells-auras-and-continuous-effects.md).
- [Règles du plateau](../01-combat/battlefield.md), [invocation](../01-combat/summoning.md), [déplacement](../01-combat/movement.md), [protections](../01-combat/damage-prevention.md) et [effets temporaires](../01-combat/temporary-effects.md).
- [Tests d’acceptation](../09-technical/acceptance-tests.md) ; [journal des décisions](../DECISIONS.md).

**Q155–Q164 validées.** Les algorithmes internes exacts de départage canonique, les valeurs de budgets et les API restent à spécifier ; **Q165 ouverte**.

- [Journal à la demande, historique, navigation et visibilité — Q165–Q174](combat-journal-and-inspection.md).

**Q165–Q174 validées ; Q175 ouverte.**

---

## Fichier : `02-art-direction/board-and-tactical-preview.md`

# Plateau fantasy, aide tactique et interactions — Q145 à Q154

**Statut : VALIDÉ sur décisions explicites Q145–Q154.** Ce module définit l'interface et l'aide à la décision ; il ne remplace pas les règles d'invocation, déplacement, attaque, ciblage, coûts, prise de contrôle ou déclenchement du moteur. Les exemples de chiffres ne créent pas de nouvelles mécaniques. L'implémentation et les budgets de calcul concrets restent à mesurer.

## Références croisées et ordre d'autorité

- [Organisation réelle des 6 colonnes / deux lignes par camp, ciblage et interception](../01-combat/battlefield.md) ; [attaques et ordre de résolution](../01-combat/turn-sequence.md), [résolution des dégâts](../01-combat/damage-resolution.md).
- [Invocation, restrictions et priorités de placement](../01-combat/summoning.md) ; [déplacements naturels, permutations et déplacements par effets](../01-combat/movement.md) ; [ciblage](../01-combat/targeting.md).
- [Contrôle et maladie d'invocation](../01-combat/control-transfers.md) ; [décompte des durées](../01-combat/temporary-effects.md) ; [capacités et déclenchements](../01-combat/abilities.md).
- [File d'événements et opérations atomiques](../01-combat/event-queue.md), [résolution](../01-combat/effect-resolution.md), [budgets et reproductibilité](../09-technical/causal-budgets-and-replay.md).
- [Identité visuelle des cartes et jetons](card-and-board-ui.md) ; [Juicy & Fast-Paced, feedbacks et budget d'animation](tooltips-durations-and-vfx.md) ; [tests d'acceptation](../09-technical/acceptance-tests.md) ; [journal de décisions](../DECISIONS.md).

**Séparation des domaines :** le moteur est source de vérité pour légalité et résultats ; l'interface restitue des informations contextualisées ; le simulateur de prévision travaille sur un état hypothétique isolé ; l'orchestrateur VFX ne modifie pas le combat. Une prévision n'est ni un coup joué ni une garantie de résultat futur.

## Q145 — Plateau fantasy premium et architecture modulaire (B + précision)

- **BOARD-145-01** — Direction « fantasy premium », riche, colorée, immersive ; priorité constante aux cartes et aux états tactiques.
- **BOARD-145-02** — Surface de combat : **6 colonnes × 4 lignes au total** (deux lignes offensive/défensive par camp) ; grille subtile, suffisamment compréhensible lors des interactions.
- **BOARD-145-03** — Cases discrètes au repos ; affichage renforcé au survol, pendant la sélection, le ciblage et le déplacement.
- **BOARD-145-04** — Séparer dans l'architecture la **couche décor**, la **couche ambiance**, la **couche grille tactique**, la **couche unités et interactions**, et la **couche feedback gameplay**.
- **BOARD-145-05** — **V1 : un décor fantasy unique**, sans devoir produire plusieurs arènes.
- **BOARD-145-06** — Prévoir une interface de thème/de décor pour évolution ultérieure selon tour, étage, étape, biome ou boss, sans aucune dépendance des règles du moteur au visuel choisi.
- **BOARD-145-07** — Aucune variation décorative future ne doit diminuer la lisibilité des colonnes, camps, jetons et indicateurs ; les cas d'usage multi-décors restent futurs, non engagés en V1.

## Q146 — Décor majoritairement fixe, ambiance discrète (B)

- **BOARD-146-01** — Illustration principale fixe richement travaillée ; pas d'arrière-plan intensément animé.
- **BOARD-146-02** — Petites animations environnementales facultatives (torches, poussières, halos, runes, brume légère), limitées aux zones qui ne nuisent pas à la lecture.
- **BOARD-146-03** — Les animations décoratives sont de priorité inférieure aux jetons, aux statistiques, aux aides tactiques et aux VFX de gameplay.
- **BOARD-146-04** — Les animations ambiantes peuvent être réduites/désactivées sans désactiver les informations critiques ; préserver les préférences d'accessibilité Q141.
- **BOARD-146-05** — Les futures variantes de décor pourront échanger illustration et ambiance sans refaire le système de cases.

## Q147 — Identités de camps et marquages tactiques contextuels (B personnalisé)

- **BOARD-147-01** — Identité chromatique discrète pour chaque camp, sans dépendre exclusivement de la couleur.
- **BOARD-147-02** — Pas de répétition permanente de pictogrammes épée/bouclier ou de contours de cases qui encombreraient le décor.
- **BOARD-147-03** — État au repos : priorité à l'illustration et aux unités ; l'emplacement et le rôle des lignes restent compréhensibles.
- **BOARD-147-04** — Survol / focus : révéler uniquement l'information de case pertinente (camp, ligne, emplacement).
- **BOARD-147-05** — Sélection / glisser-déposer : rendre explicites les destinations et contraintes liées à l'action.
- **BOARD-147-06** — Les indicateurs utilisent symbole, contour ou texture en plus de leur couleur ; les animations de ciblage ne masquent pas le plateau.
- **BOARD-147-07** — Retirer les indications temporaires à la fin ou à l'annulation de l'interaction.

## Q148 — Cases valides et erreurs de placement (B)

- **BOARD-148-01** — Dès la sélection ou le début du geste, le jeu affiche les **cases légalement autorisées** selon l'état moteur courant et le type d'action.
- **BOARD-148-02** — Les cases valides sont indiquées de manière légère et multimodale (symbole/contour, pas seulement une teinte).
- **BOARD-148-03** — Cases interdites neutres par défaut ; en cas de tentative de ciblage illégal, feedback local et raison courte si le moteur fournit la cause.
- **BOARD-148-04** — Masquer les indications après dépôt, annulation ou fin de sélection.
- **BOARD-148-05** — Ne pas dupliquer les règles de légalité dans le rendu ; la liste des cases valides et le rejet proviennent d'une API moteur ou d'un service conforme aux règles moteur.

## Q149 — Prévisualisation de la prochaine phase de combat à la sélection (C)

- **BOARD-149-01** — Quand une créature est sélectionnée, évaluer les conséquences de la prochaine phase de combat **sur elle et sa cible pertinente** plutôt que tracer seulement sa trajectoire généralement évidente.
- **BOARD-149-02** — Intégrer les statistiques effectives, protections, ordre des attaques, maladie d'invocation, ciblage, capacités et réactions déterministes pertinentes ; distinguer l'impact direct de l'ensemble de la phase.
- **BOARD-149-03** — Montrer PV futurs, protections consommées, mort ou survie lorsque ces résultats sont prédictibles sous les hypothèses courantes.
- **BOARD-149-04** — Une prévision déterminée exige qu'aucune branche incertaine pertinente ne la contredise ; ne jamais présenter un avenir dépendant de futures actions ou de RNG inconnue comme garanti.
- **BOARD-149-05** — Exécuter l'analyse dans une copie/snapshot isolé ; aucune écriture dans l'état réel, aucun événement réel, aucune consommation du RNG de partie, aucune réservation FIFO durable.
- **BOARD-149-06** — Aucun replay des animations de dégâts durant la prévision ; résultat compact et quasi immédiat lorsque calculable.

## Q150 — Indicateurs de PV futurs et certitude (B)

- **BOARD-150-01** — Valeurs fantômes compactes `PV actuels → PV prévus` près de la créature sélectionnée et de sa cible ; ne pas remplacer ni masquer les vrais PV/ATQ.
- **BOARD-150-02** — Crâne pour mort prévue, symbole armure/bouclier pour protection absorbée ou consommée, `?` explicite pour résultat incertain ; indices visuels distincts au-delà des seules couleurs.
- **BOARD-150-03** — État « prévision » visuellement différent d'un dégât effectivement infligé : transparence, contour, absence de secousse et de chiffres d'impact réels.
- **BOARD-150-04** — Détails de calcul et capacité impliquée accessibles dans inspection ; affichage minimal autour des jetons.
- **BOARD-150-05** — Disparition à l'annulation, déselection et après engagement de l'action ; rafraîchissement lorsque l'état pertinent change.

## Q151 — Drag-and-drop et cache de simulation (C)

- **BOARD-151-01** — Au survol d'une **case valide**, simuler la position hypothétique et montrer les conséquences pour cette position ; changer de résultat quand la case cible change.
- **BOARD-151-02** — Préférer calcul au changement de case plutôt qu'à chaque pixel/cycle de rendu ; ne pas bloquer le pointeur ni le geste tactile pendant les calculs.
- **BOARD-151-03** — Cache autorisé, indexé sur la version/empreinte pertinente de l'état, la source, la destination, l'action et les hypothèses de prévision ; invalidation si l'état réel ou les hypothèses changent.
- **BOARD-151-04** — Ignorer les résultats asynchrones tardifs relatifs à une case qui n'est plus sélectionnée ; jamais afficher une prévision d'une ancienne position sur la nouvelle.
- **BOARD-151-05** — Simulation respecte les restrictions de placement, coût et déplacement ; une unité nouvellement invoquée n'attaque pas si les règles de maladie d'invocation l'interdisent.
- **BOARD-151-06** — Survol d'une case illégale : pas de prévision de déplacement exécuté ; explication d'illégalité conformément à Q148.
- **BOARD-151-07** — Le dépôt reste revalidé par le moteur actuel, indépendamment de tout résultat en cache.

## Q152 — Prévisions progressives et limites de calcul (C)

- **BOARD-152-01** — Différencier états **déterminé**, **conditionnel/aléatoire**, **en cours** et **indisponible** ; afficher immédiatement les parties certaines lorsque possible.
- **BOARD-152-02** — Si un résultat futur est incertain, afficher `?` ou une hypothèse clairement étiquetée ; fourchette ou scénarios seulement s'ils sont fiables, avec hypothèses explicites.
- **BOARD-152-03** — Calculs sous **budget technique indépendant**, limites et coût à calibrer en prototypes ; dépassement -> « indisponible » ou résultat partiel non trompeur.
- **BOARD-152-04** — La disponibilité du calcul n'est **pas** la légalité de l'action ; une prévision lente ou impossible n'empêche pas le dépôt sur une case valide.
- **BOARD-152-05** — Ni le budget de simulation, ni le cache, ni le RNG hypothétique n'influencent les budgets/états du moteur (Q113–Q120), le replay (Q121–Q125) ou les animations (Q144).
- **BOARD-152-06** — Révision explicite des prévisions quand une information certaine supplémentaire est calculée ; ne pas afficher des résultats temporaires comme définitifs.

## Q153 — Dépôt immédiat et revalidation (B)

- **BOARD-153-01** — Dépôt sur case légale : demande d'action immédiate, **sans confirmation systématique**, même si prévision incertaine/en cours/indisponible.
- **BOARD-153-02** — Au dépôt, le moteur **revalide** source, destination, coûts, restrictions et état courant ; un aperçu antérieur n'autorise aucune exception.
- **BOARD-153-03** — Action acceptée : exécution selon l'ordre moteur, feedback d'invocation/déplacement gradué, rapide, cohérent avec Q140–Q144.
- **BOARD-153-04** — Action refusée : **aucun changement de combat** ; retour visuel de carte/jeton vers sa position d'origine, explication courte si disponible.
- **BOARD-153-05** — Annuler/ignorer les simulations précédentes à l'engagement ou au refus ; pas d'application tardive de prévision.

## Q154 — Modalités multimodales et annulation avant validation (C)

- **BOARD-154-01** — **Glisser-déposer**, **sélection par clic puis clic sur case**, et **interactions tactiles** partagent les mêmes règles d'actions et destinations valides.
- **BOARD-154-02** — Les mêmes aides (cases valides, invalidité expliquée, prévisions, incertitudes) sont accessibles au survol, au focus/sélection et au toucher adapté ; le survol physique ne doit pas être obligatoire.
- **BOARD-154-03** — Annulation possible avant validation moteur : Échap sur clavier, clic hors de la cible ou commande explicite d'annulation ; geste tactile d'annulation à définir ergonomiquement sans provoquer de dépôt involontaire.
- **BOARD-154-04** — L'annulation remet la carte ou le jeton à son état/visuel initial et masque les aides sans coût, événement ni mutation de l'état moteur.
- **BOARD-154-05** — Après validation moteur, le simple bouton « annuler la sélection » ne constitue pas un mécanisme de retour en arrière sur l'action exécutée.
- **BOARD-154-06** — États d'interaction explicites : `idle → selected/dragging → previewing → submitted/committed` ou `cancelled/refused`. Tout résultat de prévision lié à un ancien état est ignoré.
- **BOARD-154-07** — Navigation clavier/focus visible, tailles de zones tactiles, gestes précis mobile et paramètres manette restent à prototyper ; pas de fonctionnalité manette implicitement validée.

## Contraintes transversales — Juicy & Fast-Paced, performance et accessibilité

1. Le décor et les aides contextuelles n'encombrent pas le plateau au repos ; les informations apparaissent au moment pertinent (Q145–Q148).
2. Aides de prévision **sans effets d'impact réels** ; feedback expressif réservé aux actions exécutées (Q140–Q144).
3. Isoler trois budgets distincts : **budget de résolution logique** (Q113–Q120), **budget d'animation** (Q144 ; objectif indicatif 3–5 s pour chaîne complexe), **budget de prévision** (Q152 ; valeur chiffrée ouverte).
4. Les deux interfaces d'entrée et le tactile utilisent une seule validation métier. Une simulation non terminée ne retarde jamais une action légale.
5. Les marqueurs de statut sont perceptibles sans couleur, avec option de réduire l'ambiance et les mouvements, et accès sans survol.

## Ouvert après Q154 — Ne pas implémenter comme décision validée

- **Q155** et suivantes : suite de l'ergonomie du plateau, retours, actions ciblées et navigation.
- Dimensions définitives des cases, mode paysage/mobile, densité des overlays, séquences sonores et rendu exact des thèmes.
- Algorithme et budget chiffré du simulateur de prévision (temps, nombres de branches, scénarios aléatoires), seuils de cache et éventuel rendu multi-cibles global.
- Définition graphique des gestes tactiles d'annulation, des raccourcis, de la compatibilité manette et des normes de confort visuel à tester.
- Les exemples visuels de créatures, dégâts et échanges ne sont pas des formules de combat supplémentaires ; conserver la maladie d'invocation et l'absence de riposte normale Q09.


## Extension v1.7

La prévisualisation des sorts ciblés, effets multi-cibles, buffs/debuffs, auras et cascades ainsi que le solveur d’effets continus Q155–Q164 sont spécifiés dans [le module dédié](spells-auras-and-continuous-effects.md). Ce module prolonge Q149–Q154 sans remplacer leurs conventions, y compris la séparation preview / commit et l’uniformité des résultats affichés.

---

## Fichier : `02-art-direction/card-and-board-ui.md`

# Direction artistique, cartes et interface des créatures — Q126–Q134

**Statut : décisions Q126–Q134 validées**, incluant les précisions personnalisées Q127, Q132 et Q133–Q134. Ces règles portent sur l'interface du jeu ; elles ne modifient pas la résolution fonctionnelle des combats. La gamme chromatique exacte, les dimensions et les icônes finales **restent à arbitrer sur maquette**.

**Documents connexes :** [plateau](../01-combat/battlefield.md), [identité des instances](../01-combat/instance-identity.md), [contrôle](../01-combat/control-transfers.md), [protections](../01-combat/damage-prevention.md), [dégâts](../01-combat/damage-resolution.md), [bonus et durées](../01-combat/temporary-effects.md), [capacités](../01-combat/abilities.md), [tests UI](../09-technical/acceptance-tests.md), [journal de décisions](../DECISIONS.md).

## Q125 — Versions historiques : disponibilité conditionnée au support officiel

Le propriétaire de Q125 est [compatibilité et rejeu](../09-technical/causal-budgets-and-replay.md) ; la direction artistique ne doit pas altérer le moteur historique ni modifier les signatures de gameplay par une simple évolution graphique.

## Q126 — Socle artistique : fantasy illustrée Hearthstone / Magic: The Gathering

- **ART-126-01** : direction **fantasy illustrée, riche et colorée**, avec plaisir de collection et illustrations détaillées, inspirée des qualités visuelles de *Hearthstone* et *Magic: The Gathering*, sans reproduire ni réutiliser leurs images, cadres ou identité protégée.
- **ART-126-02** : identité propre au jeu, cadres premium sans sacrifier lisibilité et ergonomie ; le style précis des peintures et palettes reste à définir par prototypes.
- **ART-126-03** : privilégier la compréhension tactique et la lecture rapide quand l'immersion visuelle risquerait de masquer une information.

## Q127 — Deux rendus de carte et trois profondeurs d'information

- **ART-127-01** : **carte complète premium** en main et en inspection : illustration fantasy riche, colorée et détaillée ; coût, type, caractéristiques, capacités lisibles et hiérarchisées.
- **ART-127-02** : **sur plateau**, ne PAS afficher la carte complète : utiliser un **jeton/portrait illustré** compact, adapté aux 24 emplacements (6 colonnes × 2 rangées × 2 camps).
- **ART-127-03** : trois niveaux de consultation : **jeton** (instantané), **tooltip** au survol (synthèse), **clic** (vue complète de la carte et détails de combat). Prévoir accès équivalent au focus/clavier et sur matériel sans survol ; modalités précises à spécifier en UX.
- **ART-127-04** : l'information temporaire de combat n'altère pas la définition imprimée de carte (cf. Q133).

## Q128 — Affichage adaptatif des informations critiques

- **UI-128-01** : toujours montrer portrait, ATQ effective et PV actuels sur les jetons.
- **UI-128-02** : ajouter uniquement des icônes pour états/capacités tactiquement pertinents selon une hiérarchie UI stable ; ne pas afficher coût de mana, texte complet ou historique sur jeton.
- **UI-128-03** : un effet non affiché sur jeton demeure consultable via tooltip/inspection ; sélection des icônes précisée par Q132.

## Q129 — Médaillon fantasy et socle tactique

- **UI-129-01** : créature matérialisée par un **médaillon portrait circulaire ou légèrement ovale**, avec **socle tactique** discret.
- **UI-129-02** : afficher l'appartenance au camp de manière perceptible (couleur et/ou forme, sans couleur seule) ; préserver visibilité des colonnes, positions offensive/défensive et états de déplacement.
- **UI-129-03** : le design doit rester lisible à occupation maximale de 24 unités ; dimensions exactes non fixées.

## Q130 — Statistiques latérales (option A choisie)

- **UI-130-01** : **ATQ en bas à gauche**, **PV en bas à droite** du médaillon ; icônes d'états prioritaires **sous le portrait**.
- **UI-130-02** : portrait reste élément visuel majeur, chiffres suffisamment contrastés, actualisation après commit fonctionnel ; pas de carte intégrale sur plateau.

## Q131 — Numériques et codes couleur non exclusifs

- **UI-131-01** : ATQ **effective** et PV **actuels** visibles en nombres sur chaque jeton ; PV maximum visibles dans tooltip et inspection.
- **UI-131-02** : bonus/améliorations vs malus/affaiblissements repérés par couleur **et** convention non chromatique (flèches, icônes, signe) ; accessibilité daltonisme.
- **UI-131-03** : **armure et bouclier distincts**, avec indicateurs chiffrés lorsque pertinents. Ne pas confondre armure/bouclier avec les PV ou une hypothétique statistique de défense.
- **UI-131-04** : palette indicative : vert bonus, rouge malus, bleu bouclier, métal armure, orange altération dangereuse, violet contrôle. **Couleurs exactes non validées**, à éprouver sur maquette.

## Q132 — Trois icônes, +N, inspection exhaustive

- **UI-132-01** : **au plus 3 icônes d'état** affichées directement sur jeton, choisies selon priorité tactique **stable** : protections, restriction d'action, menace immédiate, aptitude offensive ; l'ordre de priorité détaillé peut être précisé par la conception UX.
- **UI-132-02** : `+N` signale le nombre d'états supplémentaires masqués (les 3 affichés ne sont pas comptés dans N) ; pas d'icône ni de `+0` fictif si aucun effet restant.
- **UI-132-03** : survol = synthèse de tous les états ; **clic = carte complète + bonus/malus, capacités, protections et autres états exhaustifs**.
- **UI-132-04** : une variation d'état peut modifier le trio visible mais la priorité demeure stable, sans oscillation arbitraire.

## Q133 — Carte imprimée inchangée + panneau latéral conditionnel

- **UI-133-01** : au clic, afficher **la carte d'origine inchangée**, avec son illustration, coût, type, ATQ/PV imprimés et texte de capacités d'origine, dans une grande vue.
- **UI-133-02** : les effets qui modifient statistiques, capacités ou état de combat sont expliqués **dans un panneau latéral séparé**, sans réécrire numériquement ni textuellement le recto original.
- **UI-133-03** : panneau présent si la créature a des changements/effets pertinents ; si rien ne diffère et aucun état complémentaire, la carte originale peut s'afficher seule.
- **UI-133-04** : identifier les sources, types, échéances et capacités temporaires ajoutées, neutralisées ou supprimées ; ne jamais afficher un effet expiré comme encore actif.

## Q134 — Panneau exhaustif avec valeurs finales explicites (option B + précision)

- **UI-134-01** : panneau d'inspection = **référence complète de l'état courant** : statistiques effectives, toutes modifications, capacités temporaires/neutralisées, protections, restrictions, contrôles et états actifs, regroupés en catégories.
- **UI-134-02** : afficher en **tête de panneau et de façon très visible** les **VALEURS FINALES** : `ATQ effective`, `PV actuels / PV max effectifs`, `armure restante`, `boucliers restants` (si applicables). Les statistiques de la carte d'origine sont conservées dans la carte et peuvent être répétées à des fins de comparaison.
- **UI-134-03** : montrer **comment est obtenue l'ATQ finale** : ATQ imprimée + ajustements persistants applicables + bonus/malus actifs = ATQ effective. Même logique pour PV maximum / points de vie actuels, en respectant les règles fonctionnelles Q78–Q80 (le changement de PV max conserve les blessures, pas de soin/dégât automatique).
- **UI-134-04** : **« défense » n'est pas une statistique autonome validée** dans la spécification actuelle. Le panneau restitue l'état défensif réel par **PV, armure, bouclier et protections spécifiques**, sans inventer une valeur de défense totale ou les additionner arbitrairement. Une éventuelle stat DÉF distincte requerra une décision de conception ultérieure.
- **UI-134-05** : afficher chaque effet actif avec **nom/type, contribution chiffrée lorsque applicable, source, durée/échéance ou absence de durée**, et capacité affectée. Groupes recommandés : `Statistiques`, `Protections`, `Capacités`, `Contrôle`, `Restrictions/altérations` ; pas de limite arbitraire de lignes, autoriser défilement dans le panneau.
- **UI-134-06** : séparation des valeurs **imprimées**, **modifications**, **finales** ; les chiffres finaux doivent être cohérents avec ceux du jeton Q128/Q130/Q131 au même état de combat.
- **UI-134-07** : le panneau ne remplace pas le journal historique des événements : il reflète **l'état actif actuel**. Un historique complet peut être une fonctionnalité distincte non décidée.
- **UI-134-08** : si seules des blessures ou des consommations de protection demeurent, le panneau doit pouvoir présenter ces **états courants** sans prétendre qu'il s'agit de buffs temporaires ; la condition d'apparition porte sur les différences/états pertinents, pas uniquement les bonus/malus.

### Exemple d'inspection non ambigu

Carte d'origine `Gardien runique` : **3 ATQ / 8 PV maximum imprimés**. En combat, `+2 ATQ` actif, 6 PV actuels, 2 armure et 1 bouclier :

| En-tête du panneau : valeurs finales | Valeur affichée | Explication |
|---|---|---|
| **ATQ EFFECTIVE** | **5** | 3 imprimée + 2 bonus actif |
| **PV ACTUELS / MAX EFFECTIF** | **6 / 8** | Deux blessures encore présentes |
| **ARMURE** | **2** | Protection active |
| **BOUCLIER** | **1** | Protection active |

Le recto de carte continue d'afficher **3 ATQ / 8 PV**. Le jeton montre **5 ATQ et 6 PV**. Le panneau fournit le calcul complet. En présence de bonus de PV max (Q78), utiliser le PV max **effectif** au lieu de l'imprimé et ne jamais confondre bonus de max PV et soin.

## Dépendances et questions ouvertes

- La priorité exacte entre états de même catégorie, les dimensions, la palette finale, l'animation, le tooltip précis, la disposition smartphone/écran réduit et le design complet du plateau seront discutés après Q134.
- La différence entre caractéristique imprimée et amélioration **persistante RPG** doit rester explicite selon [carte et instances](../01-combat/instance-identity.md). Le terme « carte d'origine » renvoie au recto de référence pour le combat considéré ; les modalités de présentation des améliorations RPG persistantes restent ouvertes.
- **Q135–Q144 validées** : conventions de couleurs, tooltip, durées, états de contrôle, feedbacks et orchestrateur présentés dans [Tooltips, durées et VFX](tooltips-durations-and-vfx.md). **Q145–Q154 validées : consulter [Plateau et prévisualisations tactiques](board-and-tactical-preview.md).**


## Évolutions v1.5 — Q135–Q144

Les règles d’affichage d’ATQ effective, de PV, des icônes de contrôle, des échéances, des buffs/debuffs et des feedbacks visuels sont centralisées dans [Tooltips, échéances et feedbacks visuels](tooltips-durations-and-vfx.md). Ce module prévaut sur les propositions anciennes marquées ouvertes, sans modifier les choix Q126–Q134.

---

## Fichier : `02-art-direction/combat-journal-and-inspection.md`

# Journal de combat joueur, inspection historique et visibilité — Q165 à Q174

**Statut : VALIDÉ (Q165–Q174).** Ces exigences décrivent la cible fonctionnelle ; aucun moteur ou composant UI n’est attesté comme implémenté.

## Autorité et références croisées

- [Règles de plateau et inspection de cartes Q126–Q134](card-and-board-ui.md), [tooltips, durées et effets visuels Q135–Q144](tooltips-durations-and-vfx.md).
- [Plateau, sélection et prévisualisation Q145–Q154](board-and-tactical-preview.md) ; [auras et solveur déterministe Q155–Q164](spells-auras-and-continuous-effects.md).
- [File FIFO et ordre des événements](../01-combat/event-queue.md), [résolution des effets](../01-combat/effect-resolution.md), [capacités](../01-combat/abilities.md), [identité des instances](../01-combat/instance-identity.md), [contrôle](../01-combat/control-transfers.md).
- [Enregistrement déterministe, snapshots et replays Q115–Q125](../09-technical/causal-budgets-and-replay.md) et [tests d’acceptation](../09-technical/acceptance-tests.md).
- [Index artistique](README.md), [journal des décisions](../DECISIONS.md), [sommaire général](../README.md).

**Séparation des responsabilités :** le journal joueur est une projection lisible et filtrée des événements validés. Le journal technique est la source de vérité de la causalité, de l’ordre, des données déterministes et du replay. L’orchestrateur visuel contrôle *le moment* où un événement résolu peut être présenté au joueur, sans infléchir la résolution.

**Important :** les exemples de contenus, de compteurs et les libellés précis d’UI sont illustratifs ; ne pas prendre une proposition de mise en page pour une règle de combat.

## Q165 — Feedback temporaire lors de la neutralisation ou réactivation d’une aura (B)

- **UI-165-01** — À neutralisation d’une dépendance d’aura, feedback visuel bref sur source et bénéficiaires concernés ; aucune icône persistante obligatoire.
- **UI-165-02** — La réactivation génère un feedback distinct, lisible, sans concurrencer les trois icônes prioritaires de Q132.
- **UI-165-03** — Les caractéristiques effectives affichent les contributions réellement appliquées, et pas celles neutralisées.
- **UI-165-04** — Inspection : source, effet, contribution neutralisée et justification compréhensible, sans exposer de secret.
- **UI-165-05** — Prévisualisation et moteur réel utilisent exactement la même décision de neutralisation canonique Q161–Q164.
- **UI-165-06** — Les transitions et leurs motifs fonctionnels sont traçables par logs et replays Q121–Q124.

## Q166 — Journal hiérarchique, masqué par défaut, consultable à la demande (B + précision)

- **UI-166-01** — Journal de combat joueur distinct des logs techniques ; jamais ouvert par défaut sur le plateau.
- **UI-166-02** — Regroupement en séquences racines (attaque, sort, capacité ou autre action initiale), chacune avec résumé puis détails dépliables.
- **UI-166-03** — Au détail : déroulé chronologique effectif, sources, cibles, dégâts aux PV, absorptions, soins, états et effets déclenchés.
- **UI-166-04** — Le journal traduit les événements du moteur en langage naturel, en conservant l’ordre des opérations.
- **UI-166-05** — Les informations révélées respectent les droits de visibilité du joueur ; pas de divulgation rétroactive de secrets.
- **UI-166-06** — Le journal ne remplace pas les feedbacks VFX Q140–Q144, et sa consultation n’altère pas le combat.

## Q167 — Panneau latéral escamotable pour le journal (B)

- **UI-167-01** — Commande discrète pour ouvrir/fermer le journal ; panneau entièrement masqué au repos.
- **UI-167-02** — Vue latérale avec résumé et détails ; fermeture immédiate sans impact sur moteur et RNG.
- **UI-167-03** — Préserver la vue du plateau tant que l’espace disponible le permet ; sur petits écrans, superposition plutôt que compression illisible.
- **UI-167-04** — Le panneau n’impose pas de rejouer les animations ni de revenir à un snapshot antérieur.

## Q168 — Survol/sélection d’un événement : mise en évidence contextuelle des créatures (B)

- **UI-168-01** — Survol ou sélection dans le journal met en évidence temporairement les créatures concernées encore présentes.
- **UI-168-02** — Créatures détruites : identité historique, portrait, nom et position au moment de l’événement lorsque visibles au joueur.
- **UI-168-03** — Créatures déplacées ou contrôlées : liaison par identité d’instance, jamais uniquement nom ou case actuelle.
- **UI-168-04** — Aucun replay visuel des événements passés, ni déplacement du plateau vers un état antérieur.
- **UI-168-05** — L’information et les surbrillances disparaissent à la fin de l’interaction ; aucun effet sur la simulation.

## Q169 — Résumé compact des créatures et inspection historique détaillée à la demande (B)

- **UI-169-01** — Résumé : portrait, identité d’instance visible, nom, conséquences principales.
- **UI-169-02** — Inspection historique : valeurs effectives ATQ/PV actuels et maximaux, protections, états et effets pertinents au point d’événement.
- **UI-169-03** — Conserver sources pertinentes, position historique, propriétaire/contrôleur si utile, et identité d’instance.
- **UI-169-04** — Distinguer quand nécessaire les états avant/après l’opération pour éviter toute ambiguïté.
- **UI-169-05** — Ne jamais déduire l’état historique de statistiques actuelles ; utiliser les faits/snapshots d’événement autorisés.
- **UI-169-06** — Les unités disparues, ressuscitées ou déplacées restent correctement attribuées à leurs événements.

## Q170 — Historique par tour, recherche textuelle et filtres légers (B)

- **UI-170-01** — Séquences par tour et ordre effectif, les plus récentes facilement accessibles.
- **UI-170-02** — Recherche de noms visibles de créatures, sorts, capacités et descriptions d’événements.
- **UI-170-03** — Filtres simples : attaques, sorts, morts, changements d’état (extensible si utile).
- **UI-170-04** — Contrôles de recherche/filtres discrets ou condensés au repos ; détails dépliables.
- **UI-170-05** — Ni la recherche ni les filtres ne changent l’ordre de résolution dans une séquence.
- **UI-170-06** — Ne rechercher/indexer que les informations visibles pour le joueur, pas des secrets techniques.

## Q171 — Résumé tactique et détail exhaustif à la demande (B)

- **UI-171-01** — Chaque séquence résume les résultats effectivement appliqués : PV perdus, soins, absorption, morts et changements majeurs.
- **UI-171-02** — Événements tactiquement significatifs mis en valeur discrètement, y compris sans forte valeur numérique.
- **UI-171-03** — Les événements secondaires restent accessibles et ordonnés ; aucune suppression de détail lors de l’agrégation UI.
- **UI-171-04** — Calculer le résumé à partir des événements historiques validés, jamais de l’état courant ou d’une nouvelle simulation.
- **UI-171-05** — Les données masquées restent masquées dans le résumé comme dans le détail.

## Q172 — Explications textuelles, sans navigation causale avancée en V1 (A + contrainte de coût)

- **UI-172-01** — Une description claire de chaque événement indique, si visible, la source et le déclencheur pertinent.
- **UI-172-02** — Pas de graphe de causalité, d’arbre interactif ni de liens spéciaux cause→conséquence requis pour V1.
- **UI-172-03** — Les détails restent chronologiques ; le joueur parcourt manuellement la séquence pour approfondir.
- **UI-172-04** — Exploiter les faits d’événement existants ; aucune simulation rétroactive ni moteur d’explication indépendant.
- **UI-172-05** — Privilégier le coût de développement bas : le journal est secondaire face au gameplay.

## Q173 — Conservation de l’historique complet du combat en cours (B)

- **UI-173-01** — Conserver tous les événements visibles pertinents depuis le début du combat courant, y compris événements secondaires.
- **UI-173-02** — Aucune purge arbitraire par nombre de tours en cours de combat.
- **UI-173-03** — Libération possible en fin de combat ; aucune obligation de galerie de combats précédents.
- **UI-173-04** — Reprise de combat sauvegardé : journal cohérent avec l’historique déjà produit, éventuellement reconstruit depuis les faits persistés.
- **UI-173-05** — Ne jamais raccourcir les traces techniques/snapshots nécessaires aux garanties Q121–Q125 ; cycle de vie distinct.
- **UI-173-06** — Affichage léger, liste virtualisable ou chargement progressif des détails si nécessaire, sans perte de données.

## Q174 — Journal consultable pendant les animations sans pause ni fuite anticipée (B)

- **UI-174-01** — Ouverture à tout instant, même en pleine séquence VFX ; l’animation et le moteur continuent normalement.
- **UI-174-02** — Ne montrer que les événements déjà présentés au joueur, ou dont la révélation est déjà autorisée par l’ordonnanceur visuel.
- **UI-174-03** — Ajouter progressivement les nouveaux événements dans l’ordre de présentation ; conserver l’ordre effectif dans le détail historique.
- **UI-174-04** — Aucune fuite de résultats futurs calculés avant leur révélation visuelle (mort, effet surprise, choix secret).
- **UI-174-05** — Pas de pause, de replay automatique ni de blocage de la FIFO à l’ouverture du journal.
- **UI-174-06** — À la fin de la présentation, la totalité des événements visibles de la séquence est accessible, avec résumé définitif.

## Contrats de données et séquencement — spécification d’interface, pas API imposée

- **Fait canonique :** événement de combat et opération atomique déterministe, avec ordre stable, identités d’instances, sources et contexte de résolution ; aucune mutation par l’UI.
- **Projection historique :** chaque fait visible conserve au besoin des valeurs *avant/après*, identités, positions et contrôleurs au point de l’événement. Préférer la persistance des données nécessaires dans la trace déjà requise plutôt qu’une seconde infrastructure de replay.
- **Projection joueur :** filtrage des données cachées AVANT indexation de recherche, génération de résumés et mise en évidence des créatures. Ne pas exposer les causes cachées par effets de bord, intitulés ou comptages.
- **Séquence :** groupement par action initiale avec enfants en ordre de résolution. L’agrégation des résultats doit empêcher les doubles comptages (ex. dégâts annoncés ≠ PV réellement perdus ; armure ≠ bouclier ≠ PV).
- **Autorisation de présentation :** journal joueur peut être alimenté après le calcul logique, mais une entrée ne devient visible qu’après sa révélation dans l’ordonnancement VFX. Pour les animations condensées, établir un point explicite de révélation simultanée des événements groupés. Ne jamais réordonner la trace source.
- **Ouverture/fermeture :** purement UI, sans effet sur FIFO, contrôles de tour, RNG, budgets techniques ou snapshots. Une ouverture pendant une animation n’autorise pas une lecture anticipée.
- **Reprise sur sauvegarde :** restaurer le journal cohérent du combat repris selon les événements effectivement révélés, sans exposer prématurément le suffixe déjà calculé mais non présenté ; sinon rejouer la chronologie de présentation sans rejouer le moteur.
- **Contrainte de coût :** implémenter les résumés, détails, recherche et surbrillances comme vues légères sur la trace existante ; ne pas développer d’analyse causale interactive, frise ou rejeu graphique en V1.

## Parcours UX minimal

1. Combat normal : panneau journal fermé, aucune emprise visuelle permanente.
2. Clic sur commande discrète : panneau latéral ouvert, plateau encore lisible ; adaptation superposée sur affichage étroit.
3. Parcours par tour et séquence ; résumé des résultats réels ; déploiement facultatif de tous les événements visibles.
4. Recherche/filtre : noms et événements déjà visibles uniquement ; la chronologie des événements conservés ne change pas.
5. Survol d’un événement : surbrillance discrète des instances encore présentes. Unité détruite ou déplacée : carte d’identité/position historique sans falsifier le plateau actuel.
6. Clic sur une unité historique : inspection des états avant/après et des contributions pertinentes à l’époque, sans recalcul depuis l’état présent.
7. Une chaîne est encore animée : le journal est accessible, n’affiche que le préfixe autorisé à la présentation et reçoit le reste au fil de la révélation, sans arrêter la séquence.

## Limites de la V1 et questions ouvertes

- **Hors périmètre validé V1 :** arbre de causalité interactif, navigation cliquable causes/conséquences, rejeu graphique des séquences, vues de tous les combats antérieurs.
- **À calibrer :** position droite/gauche du panneau selon mise en page ; taille minimale responsive ; granularité des catégories de filtre ; formulation accessible des erreurs de neutralisation d’aura ; stratégie de mémoire/virtualisation ; schéma précis d’événement et de statut de révélation.
- **Invariants :** journal utilisateur ≠ trace technique ; la consultation ne modifie pas le combat ; visibilité historique et chronologie priment sur la richesse des outils.

## Vérification et couverture

Les tests `T-165-*` à `T-174-*` sont ajoutés à [acceptance-tests.md](../09-technical/acceptance-tests.md). Ce sont des scénarios à exécuter lors de l’implémentation, pas des preuves de conformité actuelle.



## Référence de progression v1.9

**Fin de combat :** la révélation de l’issue et l’entrée dans l’écran de [récompenses Q175–Q180](../03-progression/rewards-rarity-and-ascension.md) ne peuvent anticiper les faits non encore présentés visuellement (Q174).

---

## Fichier : `02-art-direction/spells-auras-and-continuous-effects.md`

# Prévisualisation des sorts, auras et résolution déterministe des effets continus — Q155 à Q164

**Statut : VALIDÉ — Q155–Q164.** Décisions de conception issues des réponses explicites du concepteur. Ces règles décrivent un comportement cible ; aucune conformité d’un moteur implémenté n’est affirmée. Les algorithmes précis, les seuils de performance et les valeurs numériques d’exemple restent **PROPOSÉS / À CALIBRER**, sauf lorsqu’une règle identifiée les impose.

## Autorité et références croisées

- [Plateau, interactions, preview isolé et états de certitude Q145–Q154](board-and-tactical-preview.md) : Q149–Q152 définissent la sémantique des prévisions ; Q153–Q154 le commit et l’annulation.
- [Identité des cartes et inspection Q126–Q134](card-and-board-ui.md) ; [statistiques, effets, durées et VFX Q135–Q144](tooltips-durations-and-vfx.md) : Q133/Q134 maintiennent la carte imprimée inchangée ; Q137/Q157 garantissent une lecture stable, sans encombrement.
- [Capacités et déclenchements](../01-combat/abilities.md), [effets temporaires](../01-combat/temporary-effects.md), [ciblage et revalidation](../01-combat/targeting.md), [zone et opérations atomiques](../01-combat/effect-resolution.md), [FIFO et ordre de résolution](../01-combat/event-queue.md).
- [Attaques](../01-combat/turn-sequence.md), [dégâts](../01-combat/damage-resolution.md), [prévention des dégâts](../01-combat/damage-prevention.md), [contrôle](../01-combat/control-transfers.md), [identités d'instances](../01-combat/instance-identity.md).
- [Sécurité des boucles, checkpoints de tour et Q108–Q114](../01-combat/turn-control-and-loop-safety.md), [budgets causaux, journaux, snapshots et replays Q115–Q124](../09-technical/causal-budgets-and-replay.md), [tests d'acceptation](../09-technical/acceptance-tests.md) et [journal des décisions](../DECISIONS.md).

**Principe d'autorité :** le moteur est la source de vérité des transitions et de la légalité, le simulateur utilise les **mêmes règles versionnées** sur une copie isolée ; l'interface ne doit ni réimplémenter des calculs simplifiés ni confondre l'état prévu avec l'état réellement validé.

## Q155 — Prévisualisation des sorts et capacités ciblés (C)

- **UI-155-01** — Étendre aux sorts et capacités ciblés le moteur de prévisualisation défini pour les créatures, les déplacements et les invocations (Q149–Q152).
- **UI-155-02** — Pour la cible hypothétique, prévoir dégâts effectivement reçus, soins effectivement reçus, protections consommées, morts et modifications de caractéristiques **qui découleraient de l'action**, selon les règles du moteur ; inclure les réactions déterministes pertinentes.
- **UI-155-03** — Recalculer à chaque changement de cible ; cache autorisé seulement pour une identité d'état/action/cible/hypothèses inchangée (Q151).
- **UI-155-04** — Ne pas déduire de certitude sur des effets conditionnels, des choix futurs ou des événements aléatoires inconnus ; appliquer Q152.
- **UI-155-05** — Préserver les informations cachées : aucune prévision ne doit révéler un fait que le joueur ne serait pas autorisé à connaître. Un affichage « incertain » peut être nécessaire même si le moteur interne connaît la cause.
- **UI-155-06** — Aucun effet réel, aucune mutation de FIFO, de réservations, de ressources ou de RNG de partie pendant une preview ; coût plafonné par un budget **distinct** de celui du combat ou des animations.

## Q156 — Affichage uniforme pour une et plusieurs cibles (B, précision du concepteur)

- **UI-156-01** — **Mêmes conventions de présentation sur chaque créature**, quel que soit le nombre de cibles. Interdit : changer de langage graphique au seul motif que la zone touche de nombreuses unités.
- **UI-156-02** — Montrer individuellement les conséquences prévisibles sur toutes les unités directement affectées : PV, protections, modifications de caractéristiques, morts, et `?` si incertain, sans supprimer les valeurs réelles.
- **UI-156-03** — La zone directement affectée est soulignée discrètement ; distinguer clairement les unités touchées **directement** et celles impactées seulement par des réactions secondaires.
- **UI-156-04** — Éviter les chevauchements par placement et gestion des couches, sans remplacer le sens des symboles ni masquer arbitrairement les informations de certaines cibles.
- **UI-156-05** — Maintenir les règles des opérations simultanées/atomiques et du ciblage multiple : la représentation n'implique ni ordre nouveau ni addition de dégâts incorrecte.

## Q157 — Modifications de caractéristiques : valeurs finales sur plateau (A personnalisée)

- **UI-157-01** — Pour buffs, debuffs et transformations : afficher sur le plateau les **caractéristiques finales prévisibles**, avec un rendu de prévision identifiable, sans systématiser `avant → après` près de chaque jeton.
- **UI-157-02** — L'inspection détaillée donne, à la demande, **avant → après**, contribution de chaque effet, source, durée/condition, protection et capacités ajoutées ou retirées.
- **UI-157-03** — La carte imprimée ne change jamais (Q133) ; distinguer état réel, état hypothétique et présentation visuelle.
- **UI-157-04** — Conserver le contrat historique Q150 pour les **PV futurs après dégâts/soins** (`PV actuels → PV futurs`) : la simplification Q157 vise surtout les buffs/debuffs de caractéristiques, sans annuler Q150.
- **UI-157-05** — La convention vaut pour les effets mono- et multicibles (Q156) et leurs cumuls (Q137).

## Q158 — Effets conditionnels : plateau limité aux conséquences immédiates (A)

- **UI-158-01** — Lors d'une preview, les valeurs du plateau intègrent uniquement les conséquences **immédiatement actives après la résolution hypothétique**, pas les bonus futurs qui dépendent encore d'un déclencheur ou d'une condition non remplie.
- **UI-158-02** — Ne pas ajouter à chaque effet conditionnel prévisualisé un indicateur permanent ou un nouveau bloc sur la surface de combat ; le détail complet est disponible dans l'inspection dédiée.
- **UI-158-03** — L'inspection décrit condition d'activation, source, conséquence potentielle et durée, en différenciant « actif maintenant », « en attente » et « seulement éventuel ».
- **UI-158-04** — Après application réelle, les états tactiques actifs restent visibles selon les règles Q132/Q136 : Q158 porte sur la **sobriété de la prévisualisation**, pas sur la dissimulation d'un état actif.
- **UI-158-05** — Si la condition est **déjà vraie et le résultat immédiat déterministe**, son effet est inclus dans l'état final prévu ; il ne faut pas le traiter comme un événement futur fictif.

## Q159 — Auras : influence révélée au choix de la source (B)

- **UI-159-01** — Au repos, les unités montrent leurs caractéristiques **effectives** ; aucun halo d'influence permanent ni trait reliant toutes les créatures.
- **UI-159-02** — Sur sélection/focus d'une créature, d'un artefact ou d'une autre source d'aura, surligner discrètement les bénéficiaires **actuels** de son influence, en utilisant des repères autres que la couleur seule.
- **UI-159-03** — L'inspection indique zone/condition de l'aura, source, valeurs et effets bénéficiaires, indépendamment du nombre de cibles ; effets distincts non fusionnés (Q137).
- **UI-159-04** — Si invocation, déplacement, changement de contrôleur ou disparition de source modifie la portée/condition, les bénéficiaires et leurs valeurs sont recalculés selon le moteur.
- **UI-159-05** — La sélection/focus sur périphérique sans hover donne la même information (Q154).

## Q160 — Cascades d'aura : afficher l'état final déterminé (B)

- **UI-160-01** — Une action hypothétique peut entraîner des effets continus indirects : recalculer les conséquences **immédiates déterministes**, y compris lorsqu'une première modification active/désactive les conditions d'une autre aura.
- **UI-160-02** — Sur chaque créature concernée, montrer les **valeurs finales cohérentes** prévues (Q157), pas une succession de nombres intermédiaires à l'écran.
- **UI-160-03** — L'inspection décrit les variations intermédiaires et leurs sources, sans insérer des étapes artificielles dans la séquence de jeu.
- **UI-160-04** — Respecter Q152 pour les branches incertaines, indisponibles ou trop coûteuses ; ne pas prédire comme acquis un déclenchement futur conditionnel (Q158).
- **UI-160-05** — Le nombre de bénéficiaires ne modifie pas les conventions visuelles (Q156).

## Q161 — Recalcul selon le graphe de dépendances (B)

- **ENGINE-161-01** — Construire les dépendances **fonctionnelles** entre caractéristiques, conditions d'activation, auras et effets continus ; ne pas fonder la logique sur la seule chronologie d'application ou sur l'ordre du tableau de l'interface.
- **ENGINE-161-02** — Réévaluer les nœuds concernés lorsqu'une entrée du graphe change : source, présence, position, camp, état, durée, capacité, caractéristique ou contrôle si pertinent.
- **ENGINE-161-03** — Pour une portion sans cycle, appliquer un ordre de calcul topologique canonique ; pour les portions cycliques, appliquer Q162–Q163.
- **ENGINE-161-04** — Rechercher un état cohérent stable lorsque les règles admettent une telle résolution ; ne pas supposer qu'une itération naïve converge.
- **ENGINE-161-05** — Les mêmes règles, données, tie-breakers et versions sont utilisés par combat réel, preview, sauvegarde et replay.
- **ENGINE-161-06** — Les évaluations d'effets continus et les événements de capacités déclenchées sont des concepts distincts ; une itération de solveur ne crée pas automatiquement un événement FIFO.

## Q162 — Cycles : neutralisation ciblée et réévaluation (B)

- **ENGINE-162-01** — Détecter les composantes cycliques ; classifier l'absence de point fixe, l'ambiguïté de multiples points fixes ou la présence d'un point fixe retenu par les règles.
- **ENGINE-162-02** — Si aucune solution stable non ambiguë ne peut être retenue, appliquer la **résolution canonique** de Q163 ; ne neutraliser que les **dépendances problématiques** nécessaires, pas toutes les cartes/auras de la composante par défaut.
- **ENGINE-162-03** — Les effets indépendants, même portés par les mêmes cartes, restent actifs s'ils ne dépendent pas des arêtes neutralisées.
- **ENGINE-162-04** — La neutralisation est un état de résolution **temporaire et réévaluable** quand changent les conditions causales ; elle n'est pas une suppression définitive de la carte ou de la capacité.
- **ENGINE-162-05** — Journaliser le graphe/empreinte pertinente, les arêtes écartées, la justification, le résultat retenu et le point de cohérence ; assurer reproduction déterministe.
- **ENGINE-162-06** — Les budgets contre boucles de triggers Q111–Q120 ne remplacent pas le solveur des dépendances et ne sont pas consommés par ses itérations internes.

## Q163 — Priorité sémantique et tie-breaker canonique (B)

- **ENGINE-163-01** — Les contraintes fondamentales de règle ont priorité absolue ; elles ne deviennent pas neutralisables à cause d'un conflit de deux auras.
- **ENGINE-163-02** — Si les règles d'une capacité définissent une priorité explicite valide, la respecter. **Aucune nouvelle capacité prioritaire particulière n'est créée ici.**
- **ENGINE-163-03** — À priorité sémantique égale, départager selon une identité fonctionnelle canonique stable et le contexte versionné pertinent ; ne jamais dépendre de l'ordre de parcours mémoire, de l'horloge ou d'un identifiant instable sans normalisation.
- **ENGINE-163-04** — Chercher une **neutralisation minimale** des dépendances incompatibles ; si plusieurs candidats minimaux satisfont les contraintes, sélectionner un unique candidat par départage canonique documenté.
- **ENGINE-163-05** — Ne pas neutraliser des effets indépendants ; maintenir une trace explicable pour les outils de debug, l'inspection si nécessaire et le replay.
- **ENGINE-163-06** — Distinction entre **principes validés** et **algorithme encore à spécifier** : métrique exacte de minimalité (nombre d'arêtes, poids sémantiques, etc.), schéma concret des priorités, ordre de canonicalisation et format de trace restent **OUVERTS / À DÉFINIR** ; leur implémentation devra être versionnée et ne doit pas être improvisée sans validation.

## Q164 — Points de cohérence atomiques et présentation regroupée (B)

- **ENGINE-164-01** — Avant toute étape logique qui doit lire une caractéristique ou condition touchée par une modification, le moteur garantit que le solveur a fourni un **état cohérent** selon les règles Q161–Q163.
- **ENGINE-164-02** — Une opération atomique validée produit un état fonctionnel cohérent ; l'opération suivante et les réactions FIFO ne doivent pas lire des valeurs périmées. Ne pas exposer de caractéristiques intermédiaires incohérentes comme un état validé.
- **ENGINE-164-03** — Le recalcul à l'intérieur d'une opération est un traitement fonctionnel interne ; les capacités déclenchées conservent les frontières atomiques et l'ordonnancement FIFO préexistants (Q61–Q64, Q108–Q110).
- **ENGINE-164-04** — Conserver dans le journal/trace les transitions **logiquement validées** dans l'ordre réel. L'orchestrateur visuel peut **regrouper, accélérer ou superposer** les rendus secondaires, mais pas modifier événements, causalité, valeurs, morts ou chronologie logique.
- **ENGINE-164-05** — La preview hypothétique exécute les mêmes points de cohérence et le même solveur sur un état isolé ; aucune influence sur l'état réel, le RNG, les budgets FIFO ou les empreintes de replay.
- **ENGINE-164-06** — Les animations n'attendent pas des itérations internes du solveur. La présentation peut privilégier l'état final pertinent tout en conservant les événements majeurs lisibles (Q141–Q144).
- **ENGINE-164-07** — Le cache de prévisions doit tenir compte de la version du solveur, de la canonicalisation et de la signature fonctionnelle pertinente ; invalider les résultats après toute variation susceptible de modifier le graphe ou la solution.

## Architecture de référence proposée (non normative quant aux noms d'API)

1. **Moteur / transaction** : reçoit une action ; vérifie sa légalité ; construit les mutations de l'opération atomique ; calcule les caractéristiques dérivées au point de cohérence ; valide le commit ; émet événements logiques, trace et hash versionnés.
2. **Résolveur d'effets continus** : graphe de dépendances, détection des composantes cycliques, sélection canonique d'une solution / neutralisation ciblée selon Q161–Q163 ; ne produit pas de nouvelles résolutions FIFO par simple recalcul.
3. **Prévisualisation** : état cloné ou immuable ; mêmes règles et solveur ; masque de visibilité des informations cachées ; budget distinct ; états déterminé/incertain/en cours/indisponible ; clé de cache versionnée ; aucune modification du RNG de la partie.
4. **Interface** : affiche les valeurs finales et les statuts sur les unités, identiques pour mono/multi-cibles ; révèle détails et sources dans l'inspection ; n'affiche pas de résultats futurs conditionnels comme actifs.
5. **Orchestrateur VFX** : consomme les commits/événements validés ; hiérarchise et regroupe les animations secondaires ; respecte l'objectif indicatif de 3 à 5 secondes des chaînes complexes (Q144) sans affecter les états.

## Invariants et erreurs à éviter

- `preview(state,action,target)` ne modifie ni `state`, ni RNG, ni FIFO, ni journal réel ; les infos cachées restent cachées.
- `commit` est seul à changer l'état réel ; la preview peut expirer, être partielle ou diverger d'un futur non déterministe, **sans changer la légalité**.
- Même snapshot + même action + même version de règles/solveur + même hypothèse = même résultat et même résolution canonique, sur toutes plateformes.
- Identité de l'effet et de la dépendance persistante : ne pas confondre une nouvelle instance avec un changement d'échéance (Q109), ni les IDs techniques avec une priorité sémantique (Q112/Q163).
- Un état stable candidat qui satisfait les conditions ne suffit pas à prouver qu'il est **unique** ; traiter explicitement la multiplicité de points fixes (Q162).
- Ne jamais confondre le cycle d'un **graphe d'effets continus** avec la boucle d'une **FIFO de déclenchements** (Q111–Q120).
- Préférer ne pas afficher une valeur à une estimation faussement certaine ; les conséquences connues restent visibles.

## Points ouverts à préciser pendant implémentation/prototypage

- Métrique exacte et algorithme de neutralisation minimale ; ordre total canonique des dépendances et gestion de plusieurs points fixes ; schéma de trace/version de solveur.
- Budget de temps/calcul du simulateur, cache et invalidations fines ; stratégie de parallélisation et seuil « en cours » / « indisponible ».
- Densité de présentation pour 24 unités et le tactile : placement automatique des annotations sans changement des conventions.
- Contenu et profondeur des explications d'inspection pour les cycles neutralisés, sans exposer d'informations adverses cachées.

## Conditions d'acceptation

Les scénarios Q155–Q164 sont détaillés sous les identifiants `T-155-*` à `T-164-*` dans [les tests d'acceptation](../09-technical/acceptance-tests.md). Ils constituent **des spécifications de tests à exécuter ultérieurement** ; aucune implémentation n'est attestée.

---

## Fichier : `02-art-direction/tooltips-durations-and-vfx.md`

# Tooltips, échéances et feedbacks visuels — Q135 à Q144

**Statut : Q135–Q144 validées, avec les précisions personnalisées du concepteur en Q139, Q140, Q141 et Q143.** Ce document décrit la **présentation** ; les valeurs, la causalité et la résolution sont déterminées exclusivement par le moteur. Aucun budget temporel ne doit modifier les règles de combat ou le résultat des opérations atomiques.

## Références croisées

- [Cartes, jetons, carte originale et panneau latéral Q126–Q134](card-and-board-ui.md)
- [Couche d'interface / direction artistique](README.md)
- [Effets temporaires et décompte des échéances Q81–Q84](../01-combat/temporary-effects.md)
- [Expirations tardives, fin de tour et cycles Q105–Q114](../01-combat/turn-control-and-loop-safety.md)
- [Attribution des dégâts effectifs et vol de vie Q64–Q74](../01-combat/damage-attribution.md)
- [Préventions, armure et bouclier](../01-combat/damage-prevention.md)
- [Transferts de contrôle Q95–Q104](../01-combat/control-transfers.md)
- [File FIFO / causalité](../01-combat/event-queue.md)
- [Budgets de résolution du moteur, distincts du budget d'animation](../09-technical/causal-budgets-and-replay.md)
- [Tests d'acceptation](../09-technical/acceptance-tests.md) · [Décisions](../DECISIONS.md)

## Q135 — Codes visuels des valeurs finales (A)

- **UI-135-01** : sur jeton et dans le panneau d'inspection, afficher la **valeur finale effective** d'ATQ et les PV actuels ; couleurs et symboles reflètent la variation de la caractéristique par rapport à sa référence applicable.
- **UI-135-02** : hausse = chiffre vert + flèche montante ; baisse = chiffre rouge + flèche descendante ; pas de modification = style neutre. Les symboles/valeurs restent identifiables sans reconnaissance chromatique.
- **UI-135-03** : l'inspection présente le calcul de la caractéristique finale et l'origine des ajustements ; voir [Q134](card-and-board-ui.md).
- **UI-135-04** : **PV blessés vs PV maximum réduits sont deux concepts distincts** : `6/8 PV` indique les blessures, sans impliquer automatiquement un malus sur PV max. Respecter [Q78–Q80](../01-combat/temporary-effects.md).

## Q136 — Tooltip tactique condensé (C)

- **UI-136-01** : survol/focus de jeton = nom, contrôleur si utile, **ATQ effective, PV actuels/max**, protections, restrictions significatives et **tous les effets actifs** en version condensée avec leurs valeurs/échéances.
- **UI-136-02** : descriptions longues, sources détaillées et capacités en texte intégral sont réservées à l'inspection au clic ; le tooltip ne remplace pas le panneau exhaustif et ne modifie jamais le recto de la carte imprimée.
- **UI-136-03** : tooltip placé pour ne pas masquer durablement le jeton/cible ni les actions du plateau ; alternative accessible sur entrée sans survol (focus clavier, tactile), modalités détaillées ouvertes.

## Q137 — Ordre fixe des états et aucune fusion visuelle (A)

- **UI-137-01** : dans le tooltip et le panneau, catégories dans cet ordre **caractéristiques modifiées → protections → restrictions d'action → capacités temporaires → autres états**.
- **UI-137-02** : au sein de chaque catégorie, ordre stable **d'application** ; égalités départagées par identifiant stable conformément à la logique de tri. Chaque `effectInstanceId` actif possède sa **propre ligne**, même pour plusieurs bonus identiques ou de même valeur.
- **UI-137-03** : échéance affichée **par effet** ; le classement visuel **n'influence pas** les priorités d'expiration, de consommation de protections ou la FIFO.

## Q138 — Durées en langage naturel, sans ambiguïté (A)

- **UI-138-01** : employer des libellés du type « Fin de ce tour », « Encore 2 tours de l'ennemi », « Fin du prochain tour adverse », « Permanent », « Jusqu'à la disparition de la source » ; préciser l'échéance exacte dans l'inspection si nécessaire.
- **UI-138-02** : respecter les calendriers propres aux effets (durées généralement calculées par tours personnels du **créateur de l'effet**, Q81–Q83, sauf texte contraire) et les conditions explicites ; ne pas confondre tour du créateur, propriétaire et contrôleur de la créature.
- **UI-138-03** : réactualiser l'affichage si le temps pertinent avance ou si l'échéance change (Q109/Q140) ; un effet permanent ou conditionnel ne reçoit pas un compteur fictif.

## Q139 — Icône de contrôle et libellé d'échéance invariant (variante personnalisée)

- **UI-139-01** : le **changement de contrôleur** est représenté par un **état « contrôle » / icône dédiée** ; lorsque pertinent, il entre dans les **trois icônes prioritaires** du jeton Q132 ; les autres sont consultables au survol/clic.
- **UI-139-02** : **aucune icône de camp créateur obligatoire sur chaque effet**. Le libellé de durée reste celui de l'effet : p. ex. « Encore 2 tours de l'ennemi », qu'il soit porté par une unité alliée ou ennemie.
- **UI-139-03** : l'inspection peut exposer origine/source et contrôleur actuel ; **le propriétaire de la carte ne change pas** en cas de prise de contrôle (Q94–Q99). Ne jamais écrire « changement de propriétaire » comme si c'était une règle de transfert.

## Q140 — Changement de durée avec feedback éphémère (B)

- **UI-140-01** : une prolongation ou réduction d'effet modifie **immédiatement son échéance affichée**, dans tooltip et inspection ; conservation de `effectInstanceId` et **absence d'ON_EFFECT_EXPIRED** pour la seule prolongation (Q109).
- **UI-140-02** : signal éphémère sur le jeton (`+2 tours`, `−1 tour`, icône d'horloge animée) ; **aucune icône permanente supplémentaire** ne consomme les trois emplacements Q132.
- **VFX-140-01** : **toute action ou effet de gameplay** produit un feedback visuel expressif et agréable (*juicy*), proportionné à sa valeur tactique, tout en préservant lisibilité, accessibilité et rythme. Le visuel ne modifie jamais la logique déterministe.

## Q141 — Intensité hiérarchisée et cadence adaptative (C)

- **VFX-141-01** : trois **niveaux de présentation** — mineur/rapide, important/renforcé, exceptionnel/spectaculaire. Les niveaux **ne représentent pas des valeurs numériques de dégâts ou des seuils déjà fixés**.
- **VFX-141-02** : graduer en fonction de la puissance du sort, de la modification, de la capacité, de l'importance tactique et parfois du résultat (p. ex. boss vaincu). Une animation épique ne doit pas devenir la norme pour des effets mineurs.
- **VFX-141-03** : accélérer/regrouper effets secondaires en longues séquences ; prévoir option de **réduction des animations** pour accessibilité, sans perte d'information.
- **VFX-141-04** : ne pas faire attendre le joueur excessivement : cadence rapide, sensations fortes, envie de rejouer ; mêmes commits/faits de combat quel que soit le mode d'animation.

## Q142 — Orchestrateur visuel adaptatif (C)

- **VFX-142-01** : orchestrateur séparé du moteur ; consomme **les événements de combat déjà décidés** pour planifier la visualisation, sans gérer leur causalité fonctionnelle.
- **VFX-142-02** : regrouper uniquement des effets **visuellement compatibles et sans ambiguïté**, accélérer répétitions et superposer les animations indépendantes ; ne jamais confondre les cibles, armure, boucliers, PV perdus ni masquer les morts majeures.
- **VFX-142-03** : permettre un impact d'ouverture, une section médiane cadencée et une conclusion montrant clairement le plateau et les valeurs finales ; historique détaillé toujours disponible dans le journal.
- **VFX-142-04** : les rendus ne doivent **ni retarder l'exécution fonctionnelle**, ni modifier la FIFO, ni changer les événements de la simulation. Une attente d'interaction UI due à une animation peut être gérée au niveau présentation mais les résultats logiques restent identiques.

## Q143 — Nombres flottants par type + spectacle si puissance élevée (A personnalisée)

- **VFX-143-01** : **dégâts effectivement perdus aux PV** : nombre flottant rouge, réaction d'impact et léger recul ; **soin effectif** : nombre positif vert ascendant et particules positives.
- **VFX-143-02** : **armure absorbée** : impact métallique / nombre distinct ; **bouclier consommé** : effet magique bleu, fissure ou éclatement et indication propre. Ne pas additionner indistinctement `dégâts absorbés` et `PV perdus`.
- **VFX-143-03** : valeurs visibles = résultat **effectif et attribué** selon moteur ; ne pas afficher « −8 PV » pour 8 dégâts bruts avec seulement 5 PV effectivement perdus. Les annulations, protections et événements sans perte de PV possèdent leurs propres réactions, pas un nombre de PV fictif.
- **VFX-143-04** : pour un sort/effet **puissant**, autoriser des **éclairs, halos, secousses, ondes de choc, explosions, particules** et son synchronisé ; gradation et cadrage lisibles. Les chiffres flottants ne doivent pas se masquer.

## Q144 — Budget temporel global de présentation (B)

- **VFX-144-01** : établir un **objectif de présentation initial de 3 à 5 secondes pour une chaîne complexe**, hors éventuel moment exceptionnel à calibrer spécifiquement ; ce n'est **pas un timeout fonctionnel** ni une garantie rigide déjà testée. L'objectif est qu'aucune longue chaîne ne retienne le joueur inutilement.
- **VFX-144-02** : animations ordinaires courtes ; les durées individuelles telles que `0,15–0,35 s` mineures, `0,3–0,7 s` actions courantes, `0,7–1,5 s` puissantes, `1,5–2,5 s` exceptionnelles sont **propositions initiales de prototypage**, non valeurs finales validées.
- **VFX-144-03** : l'orchestrateur utilise accélération, regroupement et superposition pour viser le budget global, en préservant **morts, chiffres effectifs, états finaux et moments décisifs**. Une chaîne n'accumule pas naïvement toutes les durées individuelles.
- **VFX-144-04** : le budget d'animation n'est **pas** un compteur de résolutions ni un seuil anti-boucle Q111–Q120 ; la simulation déterministe ne dépend jamais du nombre d'images, de FPS ou de la vitesse graphique.
- **VFX-144-05** : le mode d'accessibilité réduit les mouvements/flashs sans supprimer les informations ; les effets majeurs restent identifiables par icône, texte/nombre et état final.

## Principes de tests et spécifications encore ouvertes

1. Tests : jeton/tooltip/inspection cohérents au même état atomique ; différence entre blessures et PV max ; libellés des effets non changés par contrôle ; retours de contrôle ; feedback court de durée ; absorption distinguée de perte PV ; deux animations indépendantes sans collision ; accélération sans divergence logique.
2. Ouverts : valeurs finales et profils de durée validés sur prototype ; seuils chiffrés d'intensité, design du plateau complet, accessibilité tactile/manette précise, sound design détaillé et éventuel bouton d'accélération manuelle distinct (l'option C de Q144 n'a **pas** été retenue).
3. **Q145–Q154 validées** : plateau et interactions dans [Plateau et prévisualisations tactiques](board-and-tactical-preview.md). **Q155 ouverte.**


## Référence de progression v1.9

**Célébration et révélation :** voir [Q175–Q176](../03-progression/rewards-rarity-and-ascension.md). L’animation de victoire et des récompenses suit l’issue canonique et respecte la rareté.

---

## Fichier : `03-progression/README.md`

# Progression et récompenses — index v2.0

- [Récompenses, raretés, artefacts et améliorations temporaires — Q175–Q184](rewards-rarity-and-ascension.md)
- [Sphérier permanent : EXP, niveaux, points, branches, réinitialisation — Q185–Q189](hero-sphere-and-skill-tree.md)
- [Tours, difficulté fixe, objectifs, marchands, collection de draft — Q190–Q194](towers-merchants-and-unlocks.md)

**Primauté des règles récentes :** Q185–Q189 établissent le sphérier permanent, tout en préservant la nature temporaire des améliorations de récompense Q184 ; Q194 élargit l’accès permanent au draft à **toute carte effectivement acquise ou achetée**, pas seulement aux contenus récompensant une première victoire.

Voir [tests](../09-technical/acceptance-tests.md), [journal des décisions](../DECISIONS.md) et [combat](../01-combat/README.md).

## Consolidation v2.1 — Q195–Q204

- [Boutiques, prix, monnaie, renouvellements, stocks, quatre exemplaires et compensation automatique](merchant-stock-and-deck-limits.md) — **source normative des Q195–Q204**.
- [Tours et déblocages Q190–Q194](towers-merchants-and-unlocks.md) ; [récompenses Q175–Q184](rewards-rarity-and-ascension.md).
- [Tests d’acceptation](../09-technical/acceptance-tests.md) — T-195-01 à T-204-04 (**non exécutés**).

## Consolidation v2.2 — Q205–Q209
- [Deck actif, réserve, plafond global de quatre et limites initiales 40/40 évolutives](deck-reserve-and-capacity.md) — **source normative Q205–Q209**.
- [Boutiques et filtres Q195–Q204](merchant-stock-and-deck-limits.md) : désormais compter deck actif **et réserve**.
- [Pioche, fatigue progressive Q210 et recherche Q211–Q214](../01-combat/deck-search-and-fatigue-v22.md).
- [Tests de conformité T-205 à T-214](../09-technical/acceptance-tests.md) — documentés, non exécutés.

## Extension v2.3 — Q215–Q224

- [Préparation, boosters, assistant de deck et socle évolutif](ascension-start-boosters-and-autobuild.md) — **source normative** de Q215–Q224.

## Extension v2.4 — Q225–Q234

- [Catalogue MVP, familles et variantes du sphérier, Heroic Fantasy et peuples extensibles](mvp-card-catalog-and-tribes.md) — source normative Q225–Q234.
- **Cible révisée : ≈170 définitions** = 40 fondamentales + ≈30 variantes + 100 indépendantes ; 20 exemplaires seulement dans le socle d'ascension. Quatre peuples au MVP, autres peuples extensibles.

- [Catalogue indépendant Q255–Q264 : équipements maudits, répartition 50/30/20, peuples, profils passerelles/hybrides/évolutifs et contreparties](independent-card-catalog-and-synergies-v27.md) — v2.7.

## Consolidation v2.8 — Q265–Q274

- [Rencontres ennemies et missions spéciales](enemy-encounters-and-special-missions-v28.md) : IA adaptative, archétypes, progression, prévisualisation, deux familles spéciales et variantes contrôlées.
- [Tests T-265 à T-274](../09-technical/acceptance-tests.md) : spécifiés, non exécutés.

---

## Fichier : `03-progression/ascension-start-boosters-and-autobuild.md`

# Préparation d’ascension, boosters et deck automatique — Q215–Q224 (v2.3)

> **Statut : VALIDÉ** pour les décisions explicites Q215–Q224. Ce module constitue la source normative pour la **préparation avant l’ascension** ; voir les règles connexes du [deck et de la réserve](deck-reserve-and-capacity.md), du [sphérier permanent](hero-sphere-and-skill-tree.md), des [déblocages Q194](towers-merchants-and-unlocks.md) et des [raretés Q181](rewards-rarity-and-ascension.md). Les probabilités chiffrées restent **OUVERTES** ; le catalogue fondamental et le secours déterministe sont précisés en [v2.4](mvp-card-catalog-and-tribes.md).

## Modèle canonique et phases de préparation

- **DECK-215-01 — Q215 D adaptée :** avant une ascension, attribuer **20 copies de cartes de base** et générer **deux boosters de 15 cartes**, soit **50 exemplaires** dans le pool de préparation standard. Les cartes des boosters proviennent **uniquement des identités déjà débloquées définitivement** dans le catalogue permanent de cartes éligibles. L’acquisition d'une copie pendant la tentative reste temporaire ; ne pas assimiler déblocage permanent et possession d’exemplaires (Q194, Q205).
- **DECK-215-02 :** dans la configuration standard de Q208 et Q217, constituer **40 exemplaires actifs** et **10 en réserve**. Pour des limites de taille modifiées par le sphérier (Q209), vérifier la conformité aux bornes effectives ; **les règles exactes d’adaptation du partage 40/10 sont ouvertes** et ne doivent pas être inventées.
- **DECK-215-03 :** la construction initiale est restreinte aux **50 copies effectivement attribuées** et **non à toutes les cartes du catalogue permanent**. Les futurs drafts et marchands doivent rester utiles ; aucune pioche gratuite depuis le catalogue.
- **DECK-215-04 :** processus conçu pour un démarrage rapide sans inspection manuelle ni composition individuelle obligatoires.
- **DECK-217-01 — Q217 A :** confirmer explicitement **minDeckSize=40** et **maxDeckSize=40** comme base de référence (Q208) ; les deux bornes demeurent évolutives (Q209), sans modifier la composition standard de 50 copies.

## Composition automatique — Q216 C, Q222 B et Q223 C

- **DECK-216-01 :** après les deux ouvertures, le moteur propose **immédiatement** un deck initial valide et sa réserve, sans sélection manuelle obligatoire ; le joueur peut accepter la proposition ou l’éditer avant le premier combat.
- **DECK-216-02 :** les modifications manuelles sont gratuites et n’altèrent pas les exemplaires : chaque transfert garde l’identité d’instance et applique Q205–Q207. Une composition intermédiaire invalide peut être éditée mais interdit le lancement du combat (Q206).
- **DECK-222-01 — Q222 B :** la **spécialisation active du héros dans le sphérier** est le critère **principal** de classement des copies disponibles. Favoriser les types/éléments/effets valorisés par les nœuds acquis. La courbe de coûts, les synergies secondaires et l’équilibre fonctionnel du deck servent de critères subsidiaires ; **la rareté n’est pas une priorité automatique**.
- **DECK-222-02 :** en absence de spécialisation dominante ou de cartes correspondantes, départager à l’aide de critères secondaires cohérents. La proposition est déterministe pour une même collection de copies et un même état de sphérier ; les poids, scores et arbitrages précis sont **ouverts**, ainsi que les métriques d’équilibre.
- **DECK-223-01 — Q223 C :** **aucune** des 20 cartes de base n’est obligatoirement conservée dans le deck actif. L’assistant peut les placer en réserve au profit de cartes des boosters ; le joueur peut effectuer les mêmes substitutions. Seules les copies obtenues durant la préparation sont sélectionnables.
- **DECK-223-02 :** la contrainte de **quatre copies maximum d’une identité de carte** s’applique à **l’ensemble des 50 exemplaires actifs + réserve** en incluant les 20 cartes de base et **tous les boosters** (Q201/Q207) ; on ne contourne jamais ce plafond en déplaçant une carte vers la réserve.

## Raretés, garanties et générations contraintes — Q218 B adaptée et Q219 B

- **BOOST-218-01 :** chaque booster de 15 cartes est tiré au hasard avec probabilités **pondérées par rareté** selon les cinq catégories officielles Q181 : **Commun (blanc)**, **Peu commun (bleu)**, **Rare (rouge)**, **Épique (violet)**, **Légendaire (or)** ; aucune catégorie mythique.
- **BOOST-218-02 :** sans capacité spécifique du sphérier, **aucune rareté élevée n’est garantie**. Les pondérations numériques, les chances individuelles et la répartition réelle sont **ouvertes** ; tout exemple de pourcentages n'est pas normatif.
- **BOOST-218-03 :** des **nœuds permanents du sphérier** peuvent modifier les probabilités ou accorder une **garantie par booster** (exemple de compétence future : ≥1 carte Rare ou supérieure dans **chacun** des deux boosters) ; ces compétences ne sont pas automatiquement possédées et leurs noms/coûts/effets exacts restent à définir.
- **BOOST-219-01 :** tirer uniquement parmi les cartes **débloquées** et **éligibles**. Avant chaque ajout, prendre en compte la totalité des copies déjà attribuées **cartes de base + boosters précédents + booster en cours**, de manière à ne jamais dépasser quatre copies par `cardId` (Q207). Génération reproductible par RNG déterministe (graine, état et ordre des choix sauvegardables).
- **BOOST-219-02 :** prioriser les garanties actives de rareté dans la mesure du possible ; lorsqu’elles sont impossibles, les **assouplir seulement autant que nécessaire**, en privilégiant la meilleure rareté encore éligible, sans carte verrouillée ou cinquième copie. Une garantie insatisfaisable ne bloque pas la progression.
- **BOOST-219-03 — secours :** prévoir un mécanisme pour les **pools structurellement insuffisants**, afin de permettre le démarrage avec un deck légal sans violer déblocages et plafond. **Le mécanisme précis n’a PAS été choisi** : ne pas générer arbitrairement une carte verrouillée, dupliquer une cinquième copie ou attribuer silencieusement une nouvelle carte. La conception du catalogue initial de cartes fondamentales doit garantir la faisabilité ou un futur arbitrage explicite doit définir le secours.
- **BOOST-219-04 :** éviter boucles de rejet infinies ; détecter l’absence d’options éligibles et exposer un résultat de génération contrôlé à l’interface. Les tentatives de garantie ne doivent pas changer un tirage déjà sauvegardé.

## Ouverture rapide et interface — Q220 B, Q221 B

- **BOOST-220-01 — Q220 B :** ouvrir les deux boosters **séquentiellement** : animation courte du **booster 1** puis révélation de ses **15 cartes ensemble**, ensuite animation courte du **booster 2** puis révélation de ses **15 cartes ensemble**. Aucune révélation individuelle obligatoire.
- **BOOST-220-02 :** les deux animations sont **passables**, sans modifier cartes, raretés, identités, garantie ni ordre des résultats ; feedback expressif à forte rareté et VFX lisibles, sans ralentir la préparation.
- **UI-221-01 — Q221 B :** présenter cartes et raretés sous forme compacte avec couleurs Q181, indicateurs de **synergie avec le héros** et filtres **facultatifs** par type, rareté, synergie. Le joueur peut inspecter la carte sans quitter le flux, et transférer rapidement des instances entre deck et réserve.
- **UI-221-02 :** après la seconde ouverture, afficher immédiatement le **deck automatiquement proposé**, avec bouton de démarrage actif si et seulement si le deck est valide (min/max effectifs et plafond de copies). Aucun filtre ni inspection obligatoires.
- **UI-221-03 :** distinguer sans confusion « exemplaire obtenu dans cette ascension » et « identité débloquée définitivement » ; le fait d’afficher un nouveau tirage ne signifie pas qu'une carte est nouvelle dans la collection.

## Composition et évolution du socle fixe — Q224 D

- **BASE-224-01 — Q224 D :** à l’origine de la progression, les **20 cartes de base** forment un **socle initial fixe**. Il ne dépend pas automatiquement d’un classement global de la collection de cartes.
- **BASE-224-02 :** des **nœuds permanents explicitement acquis dans le sphérier** peuvent progressivement permettre le **remplacement de certaines cartes de ce socle** par des variantes plus puissantes ou spécialisées. Les substitutions et variantes autorisées sont définies par les compétences, et **non par une sélection illimitée dans la collection**.
- **BASE-224-03 :** la composition autorisée du socle est **déterminée en début de tentative** à partir de l’état permanent du sphérier ; le reset gratuit entre ascensions (Q189) modifie les capacités disponibles pour les ascensions suivantes. Le socle reste de **20 copies**, sauf décision ultérieure explicite.
- **BASE-224-04 :** les remplacements de socle sont **distincts** de la possibilité Q223 de déplacer n'importe quelle carte de base vers la réserve après réception des deux boosters. Ainsi « socle fixe évolutif » ≠ « cartes de base obligatoires dans le deck actif ».
- **BASE-224-05 :** les versions substituées doivent respecter les mêmes invariants de génération que le socle original : **plafond global quatre copies** et validité du deck de départ. La question de leur rapport au catalogue de déblocages permanents, le nombre de substitutions, les listes de variantes, les prérequis et coûts des nœuds ainsi que l’algorithme de choix lorsqu’il existe plusieurs variantes **restent ouverts**. Ne pas les assimiler tacitement à un droit d’acquisition libre.

## Invariants transverses et ordre des opérations

1. Préparer le socle de 20 cartes en appliquant **uniquement les remplacements de socle autorisés par Q224** ; prendre en compte ses copies pour le plafond.
2. Générer **booster 1**, puis **booster 2**, chacun avec 15 exemplaires éligibles, pondérations Q218 et assouplissements Q219 ; conserver résultat et seed pour rejouer et reprendre.
3. Révéler les boosters **séquentiellement** et de façon passable (Q220) ; la révélation ne change pas les tirages.
4. Classer les 50 copies selon **la spécialisation du sphérier** (Q222), proposer deck/réserve de taille valable (Q216/Q217) ; les 20 copies de base ne sont pas verrouillées dans le deck (Q223).
5. Permettre les transferts facultatifs entre deck et réserve (Q205/Q206), inspection/filtres (Q221), puis vérifier les contraintes avant combat. Les cartes trouvées/recherchées **pendant le combat** obéissent à [Q211–Q214](../01-combat/deck-search-and-fatigue-v22.md), et non au moteur de composition initiale.

## Points de conception restant ouverts

- Probabilités exactes par rareté, pools des cartes débloquées, distribution de doublons et gestion de leurs poids ; conditions précises et coûts des compétences de garantie.
- **Faisabilité 50 exemplaires** avec plafond quatre : nécessite au moins **13 identités distinctes éligibles** au total, compte tenu du socle de base (car 12×4=48), sauf évolution formelle du mécanisme ; l’existence de 13 identités ne suffit pas toujours si la génération ou les règles de substitution restreignent les pools.
- Mécanisme exact de secours Q219 lorsqu'une génération de 30 cartes est réellement impossible ; pas de solution implicite validée.
- Ajustement de la composition deck/réserve lorsque les bornes du sphérier diffèrent de 40/40 (Q209).
- Définition du catalogue des cartes de base, des variantes autorisées Q224 et de leur statut de déblocage.
- Score et départages de l'assistant de composition ; conditions d'accessibilité, animations, durée et accélération, sauvegarde de préparation intermédiaire.

## Références et tests

- [Deck actif et réserve Q205–Q209, Q217](deck-reserve-and-capacity.md).
- [Sphérier Q185–Q189, Q209, Q218, Q222, Q224](hero-sphere-and-skill-tree.md).
- [Déblocages de cartes Q193–Q194](towers-merchants-and-unlocks.md).
- [Raretés Q181](rewards-rarity-and-ascension.md).
- [Marchands et filtrage Q201–Q204](merchant-stock-and-deck-limits.md).
- [Fatigue et recherches Q210–Q214](../01-combat/deck-search-and-fatigue-v22.md).
- [Tests d’acceptation](../09-technical/acceptance-tests.md) — scénarios Q215–Q224, non exécutés.

## Complément normatif v2.4 — Q225–Q234

La version v2.4 apporte les règles [catalogue, variantes et peuples](mvp-card-catalog-and-tribes.md). **Supersède** toute mention indiquant que le secours concret Q219 est entièrement indécidé : Q225 retient un **catalogue initial garanti** et une **sélection de secours déterministe d'identités fondamentales déjà débloquées**. Sa garantie de faisabilité doit être démontrée pour tous les sphériers admissibles.

Les **20 copies du socle** sont remplacées de façon déterministe selon le sphérier (Q226), les variantes partageant un plafond **par famille** de quatre (Q227). Seules les copies d'origine socle changent de variante (Q228), et les boosters **excluent** les variantes du sphérier (Q229). Le budget **≈170 définitions** Q230 n'affecte ni les 50 copies initiales ni le ratio standard deck 40/réserve 10.

---

## Fichier : `03-progression/deck-reserve-and-capacity.md`

# Deck actif, réserve d’ascension et capacités — Q205–Q209 (v2.2)

> **Statut : VALIDÉ**, décisions Q205–Q209. Ce document est la **source normative** des règles de réserve, des transferts, du plafond de quatre possédés et des tailles de deck. Les nombres d’améliorations, limites d’équilibrage et valeurs d’améliorations sont **OUVERTS** ; la préparation initiale Q215–Q224 est documentée séparément, sauf la base **40 minimum / 40 maximum** retenue en Q208–Q209.

## Zones et invariants
- **Deck actif (hors combat)** : ensemble des copies acquises constituant la pioche d’entrée du prochain combat ; ne pas confondre avec les zones « pioche », « main », « défausse » et « plateau » *dans* un combat. Voir [zones](../01-combat/hand-and-discard.md) et [transferts](../01-combat/zone-events.md).
- **Réserve d'ascension** : copies acquises, retirées du deck actif mais **non détruites**, réintégrables plus tard. À la fin de l’ascension, deck actif et réserve sont réinitialisés ; le déblocage permanent de chaque identité de carte acquise reste préservé ([Q194](towers-merchants-and-unlocks.md)).
- **Collection permanente de draft** : simple ensemble d'identités débloquées, pas un inventaire d'exemplaires transportables ; ne pas alimenter automatiquement le deck de départ.
- **Plafond global** : pour toute identité canonique `cardId`, `activeDeckCopies(cardId) + reserveCopies(cardId) <= 4`, quelle que soit la rareté ([Q201](merchant-stock-and-deck-limits.md), Q207). Ne comptent pas : copies/jetons générés exclusivement en combat ; instances déplacées entre zones du combat n’ajoutent pas de possession.

## Q205 — Retrait réversible, pas destruction
- **DECK-205-01** : retirer une carte du deck actif = déplacer **une instance acquise** vers la réserve de l’ascension, sans la détruire et sans perdre le déblocage permanent.
- **DECK-205-02** : réintégration possible depuis la réserve à condition de respecter les contraintes effectives du deck actif.
- **DECK-205-03** : transfert conserve l’identité de la copie et tout état persistant autorisé de l’instance ; pas de clone ni de déblocage supplémentaire.
- **DECK-205-04** : réserve de run et deck actif disparaissent à la clôture de run, sans toucher à la collection permanente.

## Q206 — Réorganisation gratuite hors combat
- **DECK-206-01** : déplacer librement et gratuitement des copies entre deck actif et réserve **entre les combats**, sans passer par un marchand.
- **DECK-206-02** : verrouiller les transferts manuels au lancement du combat, jusqu’à sa résolution ; les effets de gameplay en combat restent gérés par le moteur et ses zones.
- **DECK-206-03** : sauvegarder la composition, les instances et la réserve pour reprendre une ascension sans gain/perte de copies.
- **DECK-206-04** : valider les contraintes de préparation avant le démarrage d’un combat. Une composition intermédiaire non conforme peut être éditée hors combat, sans permettre de lancer le combat.

## Q207 — Limite de quatre copies sur deck + réserve
- **DECK-207-01** : somme des instances acquises actives et en réserve ≤ 4 pour chaque `cardId`.
- **DECK-207-02** : déplacer une copie en réserve ne libère **aucun** droit d'acquisition ; achats et propositions de récompense filtrent sur la somme, avant tirage et lors du commit ([Q202–Q203](merchant-stock-and-deck-limits.md)).
- **DECK-207-03** : les règles de rareté Q181 n’introduisent pas d’exceptions au plafond ; les copies temporaires de combat ne sont pas comptées.

## Q208 — Taille minimum et maximum évolutifs, départ 40/40
- **DECK-208-01** : taille du deck actif pour lancer un combat comprise entre un **minimum effectif** et un **maximum effectif**.
- **DECK-208-02** : paramètres de départ `minDeckSize=40`, `maxDeckSize=40` ; la progression peut abaisser le minimum et relever le maximum.
- **DECK-208-03** : on ne présume pas qu’un deck compact est meilleur : il favorise la répétition, mais s’expose à la fatigue progressive [Q210](../01-combat/deck-search-and-fatigue-v22.md). Un deck plus volumineux peut exploiter des [recherches Q211](../01-combat/deck-search-and-fatigue-v22.md) pour retrouver ses réponses tactiques.
- **DECK-208-04** : les copies excédentaires restent dans la réserve ; un manque de cartes actives ou un surplus ne permet pas de lancer un combat.

## Q209 — Sources permanentes et temporaires
- **DECK-209-01** : nœuds du [sphérier permanent](hero-sphere-and-skill-tree.md) peuvent diminuer le minimum ou augmenter le maximum du deck ; restent acquis entre les ascensions sauf redistribution entre deux tentatives (Q189).
- **DECK-209-02** : récompenses/effets temporaires de la tentative peuvent aussi ajuster ces limites ; cumuls autorisés, sous bornes d’équilibrage à fixer.
- **DECK-209-03** : une expiration peut invalider la composition, mais **ne détruit jamais automatiquement des cartes** ; correction manuelle gratuite avant le prochain combat.
- **DECK-209-04** : les valeurs initiales et modificateurs effectifs doivent être exposés clairement, avec revalidation moteur des conditions d’entrée en combat.

## Cohérence et points ouverts
- [Commerces, acquisitions et quatre copies Q195–Q204](merchant-stock-and-deck-limits.md) ; [méta-progression Q182/Q194](towers-merchants-and-unlocks.md) ; [fatigue Q41/Q210, recherches Q211–Q214](../01-combat/deck-search-and-fatigue-v22.md) ; [tests](../09-technical/acceptance-tests.md).
- **OUVERT** : tailles définitives de départ si équilibrage ultérieur, bornes globales, paliers d’amélioration, contenu initial des 40 cartes, procédure de création du deck de départ, traitement de pertes de cartes par d’autres mécaniques hors combat. Aucun minimum de taille pour une **édition en cours** hors combat n’est imposé ; c’est le lancement de combat qui exige conformité.

## Mise à jour v2.3 — Q215–Q224

- **Q215/Q217** : le deck de départ conserve les bornes standard **40/40**, assemblé à partir de **20 cartes de base + 2 boosters de 15** ; proposition standard de **40 actives + 10 en réserve**, sous réserve des modificateurs effectifs Q209. Voir [préparation initiale](ascension-start-boosters-and-autobuild.md).
- **Q223** : les cartes de base ne sont **jamais obligatoires dans la composition active** ; leur répartition est libre parmi les exemplaires attribués, dans le respect du plafond Q207.
- **Q224** : le socle attribué de 20 cartes est initialement fixe, puis ses variantes autorisées dépendent des compétences permanentes du sphérier ; **cette évolution du pool de cartes de base ne rend pas leur présence active obligatoire**.
- Le paragraphe « contenu initial des 40 cartes / procédure de création » ci-dessus est **historique** et désormais précisé par Q215–Q224 ; seuls restent ouverts les paramètres listés dans le nouveau module.

## Précision v2.4 — familles de variantes Q227

Le plafond Q207 de quatre copies s'entend **sur la famille entière** pour une carte fondamentale à variantes (Q227), en additionnant toutes ses versions et toutes les zones de possession pertinentes (deck actif + réserve). Référence normative : [catalogue et variantes Q225–Q234](mvp-card-catalog-and-tribes.md).

---

## Fichier : `03-progression/enemy-encounters-and-special-missions-v28.md`

# Rencontres ennemies et missions spéciales — Q265–Q274 (v2.8)

**Statut : DÉCISIONS VALIDÉES.** Ce module définit le **contenu des rencontres** et leurs contraintes de génération. Il n'introduit **aucune nouvelle politique** de ciblage, file FIFO, priorité des événements, recalcul d'auras ou résolution de victoire. Les exemples sont non normatifs.

## Dépendances normatives et frontières

- [Victoire et défaite VIC-001–VIC-006](../01-combat/victory-and-defeat.md) : priorité immédiate du décès du héros, mort simultanée des héros = défaite joueur, arrêt avant traitement d'événements restants. **Ces règles ne sont pas implicitement abrogées par un objectif spécial.**
- [Événements et résolution](../01-combat/event-queue.md) ; [effets atomiques](../01-combat/effect-resolution.md) : les déclencheurs et conditions existants restent la seule base technique.
- [Tours et niveaux de difficulté Q190–Q194](towers-merchants-and-unlocks.md) : les niveaux de difficulté fixés ne s'adaptent pas secrètement à la puissance ou au deck du joueur (Q192).
- [Préparation et réserve Q205–Q209](deck-reserve-and-capacity.md) et [boosters Q215–Q224](ascension-start-boosters-and-autobuild.md) : le joueur peut réagencer son deck entre les rencontres, mais les choix adverses ne doivent pas lui garantir des cartes indisponibles.
- [Catalogue indépendant Q255–Q264](independent-card-catalog-and-synergies-v27.md) : les cartes de rencontres ne modifient pas les quotas de définitions du catalogue collectionnable.
- [Tests d’acceptation](../09-technical/acceptance-tests.md) : T-265-01 à T-274-04.

## Q265 — Profils tactiques distincts avec adaptation (C)

- **AI-265-01 :** chaque adversaire possède un profil dominant configurable : agression, défense, contrôle, combinaison de cartes, développement ou autre identité explicite.
- **AI-265-02 :** l'évaluation tactique tient compte de la configuration courante du plateau, des ressources, des menaces et des cartes que l'adversaire peut légalement utiliser.
- **AI-265-03 :** le profil **oriente** les choix, sans imposer de décision inefficace quand une alternative tactiquement supérieure est disponible.
- **AI-265-04 :** les boss peuvent disposer de priorités spécifiques ; celles-ci utilisent toujours les règles de combat existantes.
- **AI-265-05 :** aucune capacité cachée ou dérogation implicite au moteur n'est attribuée à l'IA. Les choix nécessaires aux replays demeurent enregistrés selon les règles techniques établies.
- **AI-265-06 :** la décision ne fixe ni algorithme IA, ni coefficients heuristiques, ni comportement aléatoire obligatoire.

## Q266 — Archétypes conçus et variantes contrôlées (C)

- **ENCOUNTER-266-01 :** chaque rencontre repose sur un **archétype éditorial** : identité, peuple dominant éventuel, stratégie et synergies fondamentales.
- **ENCOUNTER-266-02 :** une partie du deck ennemi peut être **fixe / signature** ; l'autre est sélectionnée parmi un ensemble de cartes compatibles, soumis à des contraintes de cohérence et d'équilibrage.
- **ENCOUNTER-266-03 :** les boss peuvent réserver davantage de cartes signatures et de variantes propres.
- **ENCOUNTER-266-04 :** le pool ennemi est indépendant des déblocages du joueur : aucune carte hostile n'est automatiquement ajoutée à sa collection.
- **ENCOUNTER-266-05 :** la variante effectivement retenue est conservée pour la reprise d'ascension et les replays ; pas de régénération lors d'un chargement.
- **ENCOUNTER-266-06 :** le nombre exact de cartes fixes et variables reste une décision de contenu par archétype.

## Q267 — Progression hybride de la difficulté (C)

- **ENCOUNTER-267-01 :** la progression de difficulté combine **puissance** et **complexité des synergies/choix tactiques**, et ne se réduit pas à une hausse brute des statistiques.
- **ENCOUNTER-267-02 :** les débuts d'ascension privilégient des rencontres lisibles ; la phase médiane développe des interactions ; les dernières rencontres présentent des compositions plus abouties.
- **ENCOUNTER-267-03 :** chaque segment conserve des archétypes variés et des possibilités de réponse avec les cartes accessibles au joueur ; aucun ajustement caché du niveau à son deck.
- **ENCOUNTER-267-04 :** les seuils numériques exacts, le nombre d'étages et les courbes de puissance restent à équilibrer séparément.

## Q268 — Aperçu précombat de l'identité et de la stratégie (B)

- **ENCOUNTER-268-01 :** avant le combat, révéler **nom / identité**, **peuple dominant si pertinent** et **principales orientations tactiques**.
- **ENCOUNTER-268-02 :** cacher la composition exacte du deck, ses cartes variables et, par défaut, les cartes signatures précises du boss.
- **ENCOUNTER-268-03 :** permettre au joueur de préparer légalement son deck et sa réserve avant lancement, conformément à Q206.
- **ENCOUNTER-268-04 :** les informations présentées doivent correspondre aux véritables tendances de la rencontre ; les indices ne sont pas volontairement trompeurs.
- **ENCOUNTER-268-05 :** une introduction narrative enrichie pour les boss est possible sans divulgation forcée de leur liste de cartes.

## Q269 — Rencontres spéciales minoritaires, objectifs alternatifs (B)

- **ENCOUNTER-269-01 :** la majorité des rencontres conserve la victoire classique. Une **minorité** correspond à des missions à objectifs spéciaux, annoncés avant le combat.
- **ENCOUNTER-269-02 :** les missions peuvent valoriser des decks défensifs, offensifs ou de contrôle, sans imposer une construction de deck unique.
- **ENCOUNTER-269-03 :** les objectifs spéciaux réutilisent autant que possible unités, capacités, zones, déclencheurs et événements existants.
- **ENCOUNTER-269-04 :** les règles spéciales de réussite et d'échec **doivent être explicitement décrites** pour chaque type de scénario ; l'inclusion des missions ne constitue pas à elle seule une nouvelle priorité de victoire.
- **ENCOUNTER-269-05 :** jamais de réussite implicite après décès du héros : appliquer VIC-001–VIC-006 tant qu'une exception formelle distincte n'a pas été validée. L'ordre d'évaluation entre objectif et issue normale lorsqu'ils deviennent vrais au même instant **reste à préciser** avant implémentation ; ne pas l'inventer.

## Q270 — Placement semi-aléatoire contraint (C)

- **ENCOUNTER-270-01 :** les opportunités de missions spéciales sont **semi-aléatoires** selon la tour/segment ; la fréquence reste minoritaire.
- **ENCOUNTER-270-02 :** appliquer des contraintes **d'espacement**, **de diversité** et **de progression de difficulté** ; ne pas enchaîner un nombre excessif de missions spéciales.
- **ENCOUNTER-270-03 :** les scénarios complexes sont réservés aux étapes où leur difficulté est pertinente ; aucune adaptation dynamique secrète à la collection ou au deck du joueur.
- **ENCOUNTER-270-04 :** sélection et emplacement sont persistés dans les données d'ascension et fidèlement restaurés au chargement.
- **ENCOUNTER-270-05 :** les quotas numériques de fréquence et de séparation ne sont pas encore fixés ; des exemples de 12 rencontres ne sont pas normatifs.

## Q271 — Deux familles au MVP (A)

- **ENCOUNTER-271-01 :** seules deux **familles de missions spéciales** sont retenues pour le MVP : **Protection** et **Survie**.
- **ENCOUNTER-271-02 :** Protection : préserver une **unité alliée désignée** ; Survie : **résister jusqu'à une échéance annoncée**.
- **ENCOUNTER-271-03 :** élimination ciblée, interruption de rituel, escorte, capture etc. **ne sont pas des familles de missions autonomes du MVP**. Ne pas réintroduire par défaut les quatre familles évoquées parmi les options non retenues.
- **ENCOUNTER-271-04 :** chaque scénario annonce clairement ses critères de réussite/échec, sans changer implicitement les priorités VIC-001–VIC-006.

## Q272 — Variété des cibles de Protection (C)

- **ENCOUNTER-272-01 :** l'unité à protéger peut être **passive**, ou **active** avec capacités de soutien, défense ou attaque, selon le scénario.
- **ENCOUNTER-272-02 :** profils de robustesse, vulnérabilité, rôle et utilité en combat variables pour différencier les scénarios.
- **ENCOUNTER-272-03 :** les capacités des unités actives utilisent le moteur existant ; ne pas inventer de tour, de commande ou de contrôle supplémentaire pour l'escorté.
- **ENCOUNTER-272-04 :** rôle et capacités de l'unité protégée sont expliqués avant la mission, en cohérence avec l'aperçu Q268.
- **ENCOUNTER-272-05 :** une unité de mission peut être **non collectionnable** et ne décompte pas automatiquement les 50 créatures indépendantes du joueur ; préciser dans la fiche scénario le statut de l'unité, sans débloquer une carte par simple apparition.

## Q273 — Divers profils de pression en Survie (C)

- **ENCOUNTER-273-01 :** les scénarios de Survie peuvent être à pression **constante**, **croissante** ou en **pics** ; profils de conception, non nouveaux modes du moteur.
- **ENCOUNTER-273-02 :** chaque scénario possède un profil cohérent, décliné au besoin en variantes contrôlées via adversaires, formations, cartes et effets existants.
- **ENCOUNTER-273-03 :** le **profil général de pression** est indiqué avant la mission, sans révéler obligatoirement le calendrier détaillé ni les cartes exactes.
- **ENCOUNTER-273-04 :** les profils de pression et leur exécution ne s'ajustent pas secrètement à la puissance ou au deck du héros (Q192).
- **ENCOUNTER-273-05 :** valeurs, durée et cadencement précis sont des paramètres de scénario à équilibrer.

## Q274 — Scénarios conçus avec variantes contrôlées (C)

- **ENCOUNTER-274-01 :** chaque famille Protection / Survie possède **plusieurs scénarios de base conçus manuellement**.
- **ENCOUNTER-274-02 :** les scénarios possèdent identité, objectif, adversaires et difficulté de référence ; une sélection limitée de composantes varie entre les ascensions.
- **ENCOUNTER-274-03 :** variations permises lorsque cohérentes : formations / adversaires compatibles ; pour Protection, identité et capacités de l'unité à protéger ; pour Survie, profils de pression compatibles avec le scénario et sa difficulté.
- **ENCOUNTER-274-04 :** les contraintes de variantes préservent **cohérence narrative**, **identité tactique** et **équilibrage** de la rencontre ; pas de génération procédurale libre par défaut.
- **ENCOUNTER-274-05 :** variante finale persistée pour chargement et replay. Les variantes ne modifient ni les deux familles Q271, ni la fréquence minoritaire Q269, ni la présentation Q268.
- **ENCOUNTER-274-06 :** les nombres de scénarios par famille, taux de variantes et détails des missions restent ouverts tant que le catalogue concret de rencontres n'est pas conçu.

## Contrats éditoriaux attendus pour chaque rencontre

Fiche de contenu suggérée (les champs ne sont pas nécessairement des composants runtime déjà validés) : `encounter_id`, `family = classic|protection|survival`, `archetype_id`, `dominant_people?`, `tactical_profile`, `difficulty_segment`, `fixed_cards`, `variation_pool`, `variation_constraints`, `prebattle_reveal`, `objective_description`, `success_condition`, `failure_condition`, `mission_unit?`, `pressure_profile?`, `selected_variant_seed_or_snapshot`.

**Règles ouvertes à documenter séparément avant toute implémentation des missions spéciales** : ordre de priorité exact entre achèvement d'objectif et issue classique à une même frontière atomique ; modalités de clôture d'une mission de Survie à son échéance ; échec quand la cible de Protection disparaît par transformation ou changement de zone ; participation et contrôle d'une unité protégée active. Ces questions **ne doivent pas être déduites silencieusement de Q269–Q274**. La défaite immédiate lorsque le héros joueur meurt reste normative.

## Invariants de non-régression

1. La **Q271=A (deux familles)** prime sur les exemples antérieurs mentionnant quatre familles.
2. La **Q192 (difficulté fixe)** demeure compatible avec Q265 (IA adaptative aux situations) : l'IA choisit dans une bataille, mais ne recalcule pas le niveau de la rencontre selon le joueur.
3. L'information précombat Q268 annonce honnêtement le **profil** sans donner la **liste complète** des cartes.
4. Q266 et Q274 autorisent des variantes éditorialement contraintes, sans génération non bornée ni manipulation des déblocages du joueur.
5. La victoire/défaite de base VIC-001–VIC-006 reste applicable ; les objectifs spéciaux non spécifiés sont signalés comme **ouverts**, jamais inventés.
6. Les tests d'acceptation sont des **spécifications**, pas une exécution de moteur actuellement inexistante.

---

## Fichier : `03-progression/hero-sphere-and-skill-tree.md`

# Sphérier permanent du héros — décisions Q185–Q189

> **VALIDÉ :** principes explicitement décidés, sans valeurs d’équilibrage. **Source de vérité** pour l’EXP, les niveaux, les points, les chemins et la réinitialisation. Documentation de conception, non implémentée.

## Modèle canonique et séparation des persistances

- **Q185 personnalisée :** le héros possède un **arbre/sphérier de compétences permanent**, inspiré du principe de sphérier de RPG, apportant des caractéristiques (+PV par exemple), améliorations élémentaires (dégâts de feu) et capacités. L’objectif est la montée en puissance vers des tours plus difficiles. Il ne s’agit **pas** d’une simple offre de trois améliorations par niveau. Les compétences acquises demeurent entre les ascensions.
- **Q186 B :** l’**EXP de combat est permanente** (Q179), contribue au **niveau permanent** du héros ; chaque niveau accorde des points de compétence (quantité ouverte). Points gagnés et non dépensés persistent. Les tours difficiles peuvent rapporter davantage d’EXP, sous réserve du rendement Q192.
- **Q187 C :** départ central, branches thématiques interconnectées, progression de proche en proche et passerelles entre spécialisations. Les nœuds avancés ont des prérequis explicitement affichés. Un nœud verrouillé ne peut être acquis même avec assez de points.
- **Q188 C :** coûts de nœuds **prédéfinis individuellement**, variables avec la valeur mécanique et le type de compétence, pas nécessairement proportionnels à la distance. Le chemin et les points suffisants sont exigés.
- **Q189 B :** **réinitialisation totale gratuite** depuis la préparation **hors ascension**, avec confirmation explicite ; restitue l’intégralité des points investis, conserve niveau/EXP/capital total acquis, permet une nouvelle répartition légale. Aucune réinitialisation en cours d’ascension.

## Contrats fonctionnels

| ID | Invariant |
|---|---|
| RPG-185-01 | Les bonus permanents du sphérier modifient les caractéristiques/capacités du héros conformément au moteur, y compris les spécialisations élémentaires. |
| RPG-185-02 | Les effets déjà achetés dans l’arbre sont actifs pour les ascensions suivantes ; aucune remise à zéro implicite à la défaite. |
| RPG-186-01 | L’EXP de Q179 et le niveau permanent sont conservés en cas d’échec, victoire, fermeture ou nouvelle tentative. |
| RPG-186-02 | À chaque niveau, attribuer le nombre paramétré de points sans duplication ; les points restants sont persistants. |
| RPG-187-01 | L’accès à un nœud respecte la topologie de dépendances, les passerelles et les prérequis explicitement configurés. |
| RPG-187-02 | L’UI distingue acquis, accessible, verrouillé et explique le verrouillage. |
| RPG-188-01 | Dépenser le coût configuré une seule fois après validation atomique ; fonds négatifs interdits. |
| RPG-189-01 | Reset intégral gratuit, uniquement hors tentative active ; pas de retrait individuel validé. |
| RPG-189-02 | Le reset rembourse les points effectivement investis et maintient exactement le capital total mérité. |

## Articulation avec Q184, Q180 et Q182

Deux sources de bonus au héros **coexistent sans être confondues** :

1. **Sphérier permanent Q185–Q189** : développement par points issus des niveaux/EXP ; conservé entre les ascensions.
2. **Améliorations temporaires de récompenses Q180/Q184** : sélection de bonus de caractéristiques ou capacités durant l’ascension ; supprimées en fin de tentative.

Le deck constitué et les artefacts ramassés pendant l’ascension sont temporaires (Q182). Le catalogue de cartes/artefacts éligibles au futur draft est permanent : voir [tours, déblocages, commerces](towers-merchants-and-unlocks.md). Le moteur de combat doit lire un instantané cohérent des bonus permanents et temporaires, voir [résolution atomique](../01-combat/effect-resolution.md) et [effets continus](../02-art-direction/spells-auras-and-continuous-effects.md).

## Ouvert / non validé

Seuils d’EXP par niveau ; nombre de points par niveau ; coûts chiffrés ; contenu et topologie réels ; caps de statistiques ; nombre et rôles de branches ; répartition initiale. Les exemples de +2 PV / bonus feu sont des **types d’améliorations**, pas des valeurs d’équilibrage imposées.

## Extension v2.3 — compétences influençant la préparation

- **Q209** : nœuds permanents peuvent ajuster les bornes de taille du deck (source : [deck et réserve](deck-reserve-and-capacity.md)).
- **Q218 B adaptée** : certains nœuds peuvent augmenter les probabilités des boosters ou garantir une rareté minimale **par booster** (exemple ≥1 Rare+ lorsque éligible), sous [règles de secours Q219](ascension-start-boosters-and-autobuild.md). Nœuds précis non définis.
- **Q222 B** : les compétences réellement acquises orientent prioritairement la composition automatique de deck ; une spécialisation feu favorise les cartes en synergie lorsqu'elles sont présentes, sans en créer.
- **Q224 D** : des nœuds permanents peuvent autoriser des substitutions d'instances dans le **socle fixe de 20 cartes**, par variantes prédéfinies. Il s’agit d’une progression du socle, différente du retrait libre de cartes de base vers la réserve (Q223). Conditions exactes ouvertes.
- Le reset gratuit **entre ascensions** Q189 permet de changer les effets de préparation **pour une nouvelle tentative**, pas rétroactivement au milieu d'une ascension en cours.

## Précision v2.4 — portée des variantes (Q226–Q229)

Le sphérier remplace de façon déterministe des versions **dans les 20 emplacements du socle** avant l'ascension, **pas dans les boosters** ni dans les exemplaires acquis lors de l'ascension. Les versions partagent le plafond de leur famille. Voir [catalogue v2.4](mvp-card-catalog-and-tribes.md).

---

## Fichier : `03-progression/independent-card-catalog-and-synergies-v27.md`

# Catalogue indépendant du MVP — Q255 à Q264 (v2.7)

**Statut : VALIDÉ pour les décisions ci-dessous.** Les exemples d'effets ne sont pas des cartes définitives. Ce module porte sur les **règles d'usage des équipements** et sur les **objectifs de conception du catalogue**, sans créer de moteur de résolution concurrent. Les plages quantitatives « cibles » constituent des objectifs de conception et ne sont pas des garanties de boosters.

## Dépendances normatives

- [Classification, équipements, zéro à deux emplacements, détachement et charges — Q245 à Q254](../01-combat/equipment-and-card-classifications-v26.md).
- [Catalogue MVP initial — Q225 à Q234](mvp-card-catalog-and-tribes.md) ; [socle de vingt cartes et boosters — Q215 à Q224](ascension-start-boosters-and-autobuild.md) ; [raretés et déblocages](rewards-rarity-and-ascension.md).
- [Ciblage](../01-combat/targeting.md), [changements de zone](../01-combat/zone-events.md), [identités d'instance](../01-combat/instance-identity.md), [résolution des effets](../01-combat/effect-resolution.md), [effets continus](../02-art-direction/spells-auras-and-continuous-effects.md), [sécurité FIFO](../01-combat/turn-control-and-loop-safety.md) et [budgets / replay](../09-technical/causal-budgets-and-replay.md) : restent les seules sources de vérité pour leurs mécanismes.

## Q255 — Équiper une créature ennemie (B)

- **EQUIP-255-01 :** par défaut, un équipement est attachable à une créature **alliée** de son joueur.
- **EQUIP-255-02 :** le texte de la carte peut **autoriser** un porteur ennemi, ou **imposer** une cible ennemie.
- **EQUIP-255-03 :** les conditions habituelles demeurent : présence de l'emplacement **Arme** ou **Protection** sur le porteur (Q250 révisée par Q253), compatibilité du porteur avec la carte et validation ordinaire des cibles.
- **EQUIP-255-04 :** l'équipement ennemi peut occuper un emplacement déjà équipé, en appliquant la règle de remplacement **Q252**, y compris la destination de l'ancien équipement et ses éventuelles exceptions explicites.
- **EQUIP-255-05 :** la propriété de la carte reste distincte du camp du porteur. La sortie du porteur fait rejoindre l'équipement, par défaut, la **défausse de son propriétaire** (Q251), pas automatiquement celle du contrôleur du porteur.
- **EQUIP-255-06 :** les cartes maudites sont une **possibilité de design** et n'imposent ni sous-type technique obligatoire, ni pénalité automatique de faction, ni moteur de contrôle supplémentaire.
- **EQUIP-255-07 :** l'interface indique si la carte cible les alliés, les ennemis ou exclusivement ces derniers ; un ciblage impossible n'entraîne pas un attachement implicite.

**Non décidé par Q255 :** la résolution détaillée d'un éventuel changement de contrôle du porteur **pendant que l'équipement reste attaché**, ou d'une prise de contrôle de l'équipement, conserve les règles générales déjà spécifiées et requiert clarification uniquement si elles ne couvrent pas le cas. Ne pas ajouter ici de nouvelle règle.

## Q256 — Synergies transversales des équipements (C)

- **MVP-256-01 :** plusieurs stratégies peuvent exploiter les équipements ; **aucun archétype d'équipement n'est imposé** au début de l'ascension.
- **MVP-256-02 :** conception de synergies possibles avec créatures équipées, objets joués, remplacés, récupérés et objets attachés à des ennemis ; règles événementielles inchangées.
- **MVP-256-03 :** les synergies peuvent se combiner avec les peuples, factions, types secondaires et éléments (Q245–Q248).
- **MVP-256-04 :** le deck se spécialise en fonction **des cartes effectivement obtenues** dans les deux boosters aléatoires puis durant l'ascension (Q215/Q246), sans ajout ni génération garantie de cartes adaptées.
- **MVP-256-05 :** le catalogue prévoit des cartes créatures/sorts capables de profiter des équipements, sans quota ou puissance précise déterminés à ce stade.

## Q257 — Quota d'équipements indépendants (B)

- **MVP-257-01 :** sur les **100 définitions indépendantes** du MVP, **20 sont des équipements** (20 %).
- **MVP-257-02 :** cible indicative **10 Armes / 10 Protections**, ajustable lors de l'équilibrage, sans modifier le total 20 sans nouveau choix.
- **MVP-257-03 :** ces 20 cartes participent à plusieurs fonctions offensives, défensives, magiques, utilitaires et maudites ; aucune catégorie ne déduit ses effets de son seul emplacement.
- **MVP-257-04 :** les cartes fondamentales (40 définitions) et variantes du sphérier (~30) sont **hors** de ces 100 cartes indépendantes (Q230).

## Q258 — Répartition complète du catalogue indépendant (B)

| Type de carte | Nombre de définitions | Pourcentage des indépendantes |
|---|---:|---:|
| Créatures | **50** | 50 % |
| Sorts | **30** | 30 % |
| Équipements | **20** | 20 % |
| **TOTAL** | **100** | **100 %** |

- **MVP-258-01 :** 50 créatures, 30 sorts, 20 équipements constituent des **définitions de cartes indépendantes**, non des copies physiques dans une ascension.
- **MVP-258-02 :** les fonctions dégâts/défense/contrôle/soutien/pioche/recherche demeurent des **rôles transversaux**, non six autres catégories disjointes ; les anciennes répartitions indicatives de Q232 ne s'additionnent pas aux quotas définitifs Q258.
- **MVP-258-03 :** aucun quota de type de carte n'est garanti dans un booster de 15 ; seuls les cartes **débloquées et éligibles** participent au tirage, conformément à Q218–Q219 et Q246.
- **MVP-258-04 :** le socle de **20 exemplaires neutres**, les deux boosters de **15 exemplaires** et le deck de **40 actives / 10 en réserve** demeurent inchangés (Q215–Q224 et Q246).

## Q259 — Répartition des peuples parmi les 50 créatures indépendantes (C)

| Peuple | Nombre cible de définitions |
|---|---:|
| Humains | **15** |
| Elfes | **14** |
| Nains | **13** |
| Dragons | **8** |
| **TOTAL** | **50** |

- **MVP-259-01 :** la répartition 15/14/13/8 est un **objectif de conception souple**, pouvant subir de petits ajustements pour améliorer l'équilibrage, le total restant 50.
- **MVP-259-02 :** les Dragons sont moins nombreux en **définitions distinctes** ; ils ne sont **pas automatiquement** de rareté Rare/Épique/Légendaire dans les boosters.
- **MVP-259-03 :** aucun peuple n'est synonyme d'un élément, d'une faction unique ou d'un rôle unique ; les 20 exemplaires fondamentaux restent neutres et polyvalents au démarrage.
- **MVP-259-04 :** ces cibles n'imposent ni fréquence de peuple par booster, ni déblocage anticipé, ni garantie de synergies.

## Q260 — Identité tactique et polyvalence des peuples (C)

- **MVP-260-01 :** environ **50–60 %** des créatures de chaque peuple servent directement ses axes dominants ; les autres explorent des rôles alternatifs ou complémentaires.
- **MVP-260-02 :** Humains : commandement/cooperation ; Elfes : mobilité/magie/précision ; Nains : défense/fortifications/artisanat ; Dragons : puissance/éléments ; ces axes sont des **orientations de design**, pas des pouvoirs automatiques ni des interdictions.
- **MVP-260-03 :** cohérence narrative et visuelle conservée même pour les cartes atypiques ; possibilité d'utilisation dans des decks mixtes.
- **MVP-260-04 :** éviter les doublons fonctionnels parmi les **8 Dragons**. Les proportions sont indicatives, pas des contraintes du générateur de booster.

Exemple indicatif **non normatif** : 8 Humains, 8 Elfes, 7 Nains et 4 Dragons dominants (= 27 cartes sur 50), autres 23 profils complémentaires. L'arrondi exact se décide lors de la création du catalogue.

## Q261 — Créatures passerelles entre peuples (B)

- **MVP-261-01 :** **6 à 10** des **50 créatures indépendantes** seront conçues pour encourager explicitement les synergies entre plusieurs peuples.
- **MVP-261-02 :** elles restent incluses dans les quotas Q259, sans cartes supplémentaires, et réparties sur plusieurs peuples et fonctions.
- **MVP-261-03 :** elles peuvent récompenser ou faciliter la composition mixte et les interactions entre peuples, sans imposer un deck multipeuple ni interdire un deck homogène.
- **MVP-261-04 :** concevoir une utilité raisonnable même sans déclenchement optimal de leur synergie ; compatibilité avec les classifications Q245 et la règle d'évaluation de composition Q247 si pertinente.

## Q262 — Profils de créatures hybrides (B)

- **MVP-262-01 :** **25 à 35 %** des 50 créatures indépendantes, soit environ **13 à 18**, remplissent au moins **deux rôles tactiques significatifs**.
- **MVP-262-02 :** le reste du catalogue conserve des rôles principaux clairement lisibles ; hybrider ne signifie ni statistiques supérieures à tous les spécialistes ni carte automatiquement plus rare.
- **MVP-262-03 :** distribution sur plusieurs peuples ; recoupement possible avec les **créatures passerelles** Q261 et évolutives Q263.
- **MVP-262-04 :** proportion de **conception** et non quota de pioche, de génération ou de placement sur le champ de bataille.

## Q263 — Créatures évolutives au cours d'un combat (B)

- **MVP-263-01 :** **5 à 8** des 50 créatures indépendantes sont volontairement conçues autour d'une progression pendant le combat.
- **MVP-263-02 :** les **conditions précises** figurent dans la carte : actions offensives, défensives, sorts, équipements ou événements ; pas de mécanique d'évolution universelle imposée.
- **MVP-263-03 :** la progression peut modifier des caractéristiques, renforcer des effets ou débloquer des capacités par les mécanismes de déclenchement, compteurs et stabilisation existants.
- **MVP-263-04 :** aucune progression permanente **entre les combats** par défaut ; un mécanisme distinct explicitement validé peut prévoir une exception.
- **MVP-263-05 :** les évolutions sont inspectables, visibles et accompagnées d'un feedback clair/expressif sans surcharge visuelle ni modification de la logique moteur.
- **MVP-263-06 :** réparties sur plusieurs peuples ; recoupement permis avec hybride/passerelle ; **aucune nouvelle définition** au-delà des 50.

## Q264 — Cartes à contrepartie : risque/récompense (B)

- **MVP-264-01 :** **8 à 12** des **100 cartes indépendantes** présentent une contrepartie significative, soit un coût supplémentaire ou un désavantage en échange d'un bénéfice plus élevé.
- **MVP-264-02 :** ces cartes peuvent être des **créatures, sorts ou équipements** ; elles sont incluses dans leurs quotas Q258, et non ajoutées à l'effectif.
- **MVP-264-03 :** les contreparties peuvent notamment prendre la forme de perte de PV, sacrifice de créature, défausse, réduction d'une caractéristique ou avantage offert à l'adversaire, selon des effets **explicitement écrits**.
- **MVP-264-04 :** si la contrepartie fait partie d'une **capacité activable facultative**, le joueur choisit de l'activer ou non. Une carte à contrepartie automatique doit l'indiquer explicitement ; la carte n'est pas automatiquement facultative.
- **MVP-264-05 :** les contreparties doivent constituer un arbitrage intéressant et intelligible, pas une pénalité arbitraire ; coûts, cibles, compatibilité et ordre des événements suivent les règles déjà définies.
- **MVP-264-06 :** les cartes à contrepartie peuvent être hybrides, passerelles, évolutives ou équipements maudits ; **ces attributs ne partitionnent pas le catalogue**.

## Invariants transversaux et données attendues du catalogue

1. Budget total approximatif **40 fondamentales + ~30 variantes du sphérier + 100 indépendantes = ~170 définitions** (Q230) ; les variantes sont réservées aux exemplaires du socle. Parmi les **100 indépendantes**, total strict **50 créatures / 30 sorts / 20 équipements**.
2. Les 50 créatures sont réparties selon **15 Humains / 14 Elfes / 13 Nains / 8 Dragons** comme cibles souples ; cette taxonomie concerne les définitions, pas les exemplaires de boosters. Types secondaires et faction restent indépendants du peuple (Q245).
3. Attributs de catalogue **non exclusifs** : 6–10 *passerelles*, 13–18 *hybrides*, 5–8 *évolutives* ; 8–12 *à contrepartie* parmi les **100** cartes et non seulement les créatures. Les groupes peuvent se recouper ; ne **jamais additionner** ces nombres pour calculer un nouveau nombre de cartes.
4. Débloquages, raretés, plafond par famille, répartition des boosters et sphérier **inchangés** (Q181, Q194, Q201, Q207, Q215–Q229, Q246). Aucun nouveau quota de peuple/type/rôle dans les boosters n'est validé.
5. Les cartes « passerelles », « hybrides », « évolutives » et « à contrepartie » sont des **labels éditoriaux de conception**, pas nécessairement de nouveaux types techniques de cartes ou de nouvelles mécaniques automatiques.
6. **OUVERT** : liste finale des cent cartes ; affectation exacte des raretés, des types et des peuples ; coûts et chiffres des capacités ; critères et poids des cartes spécialisées dans le pool effectivement débloqué ; effets et données particuliers de certaines cartes d'équipement maudites. Ne pas promouvoir des exemples en règles.

## Recette

Voir [tests d'acceptation v2.7 : T-255 à T-264](../09-technical/acceptance-tests.md). **Tous sont spécifiés, aucun n'a été exécuté sur un moteur.**

---

## Fichier : `03-progression/merchant-stock-and-deck-limits.md`

# Boutiques, renouvellements et limites d'acquisition — Q195 à Q204

> **Statut : VALIDÉ** (décisions explicites du concepteur, version documentaire v2.1). Ce module est la **source normative** des Q195–Q204. Les quantités de monnaie, poids RNG, tailles de stocks, taux de rareté et prix de base restent **OUVERTS**. Les illustrations d'interface antérieures ne constituent pas des valeurs validées.

## Invariants transversaux

1. **Cinq raretés, sans Mythique** : Commun (blanc), Peu commun (bleu), Rare (rouge), Épique (violet), Légendaire (or), conformément à [Q181](rewards-rarity-and-ascension.md).
2. **Quatre exemplaires identiques maximum possédés dans l’ascension (deck actif + réserve)**, quelle que soit la rareté (Q201). Le contrôle porte sur l'**identité de carte canonique** et les copies réellement acquises dans le deck actif **et dans la réserve d'ascension** (Q207), pas sur les invocations/copies temporaires de combat. Les exemplaires d'une même identité partagent le plafond, indépendamment de leur source d'achat ou de récompense.
3. **Une acquisition effective débloque définitivement la carte pour les drafts futurs** [Q194](towers-merchants-and-unlocks.md), mais ni la simple apparition ni l'inspection ne la débloquent. Possibilité de draft ≠ apparition garantie ≠ carte de départ. Un achat répété ne duplique pas le déblocage permanent.
4. **Monnaie temporaire à chaque ascension** : aucun solde de la tentative précédente n'est reconduit (Q197). EXP, niveaux, compétences du sphérier et déblocages permanents restent conservés, voir [sphérier](hero-sphere-and-skill-tree.md).
5. Tirages RNG, résolution d'achat, mise à jour du deck et des déblocages sont transactionnels, déterministes par les entrées de run et **idempotents**, selon les mécanismes de [résolution atomique](../01-combat/effect-resolution.md) et [rejeu/sauvegarde](../09-technical/causal-budgets-and-replay.md). Les générateurs n'exposent pas les offres cachées au joueur.

## Q195 — Stock aléatoire, cartes et sorts exclusifs à certaines tours : C personnalisée

- **SHOP-195-01** : chaque commerce génère aléatoirement son inventaire à partir d'un pool éligible, propre au contexte de la tour.
- **SHOP-195-02** : une partie des cartes/sorts n'appartient qu'au pool d'achat de commerces de tours identifiées ; ces **exclusivités ne sont pas garanties** lors d'une visite.
- **SHOP-195-03** : les offres peuvent combiner éléments génériques et éléments exclusifs propres à la tour ; les tirages tiennent compte des raretés et autres critères d'éligibilité.
- **SHOP-195-04** : après acquisition, une carte initialement exclusive à un marchand peut être **draftée lors des futures ascensions** conformément à Q194. Son exclusivité ne signifie pas interdiction de draft post-déblocage.
- **SHOP-195-05** : poids de tirage, taille de stock, variantes de marchands et détails des pools restent ouverts ; ne pas supposer un socle d'exclusivités garanti et fixe.

## Q196 — Prix de référence selon rareté et ajustements individuels : B

- **SHOP-196-01** : chaque rareté possède une référence tarifaire ; prix final par carte ajustable selon intérêt, effets, exclusivité.
- **SHOP-196-02** : prix visible avant achat ; politique cohérente d'une visite à l'autre, sans génération arbitraire de prix aléatoires par visite.
- **SHOP-196-03** : afficher l'état « déjà débloquée » de la carte dans le catalogue permanent de drafts.
- **SHOP-196-04** : tarifs, écarts et éventuels plafonds numériques **OUVERTS** ; toute table de 50/100/200/350/600 or dans une maquette est fictive.

## Q197 — Monnaie non persistante entre ascensions : A

- **SHOP-197-01** : la monnaie de run est gagnée et dépensée pendant l'ascension en cours ; elle est effacée à la fin (victoire ou défaite).
- **SHOP-197-02** : une nouvelle tentative dispose de son solde de départ défini par les règles économiques (montant ouvert), sans transfert de monnaie précédente.
- **SHOP-197-03** : une perte de monnaie ne supprime ni les cartes débloquées, ni l'EXP/les niveaux/les points du sphérier permanents.

## Q198 — Renouvellement payant illimité à coût croissant : B adaptée

- **SHOP-198-01** : le joueur peut renouveler un inventaire tant qu'il a les fonds ; **pas de nombre maximal arbitraire** de renouvellements.
- **SHOP-198-02** : le prix du **prochain** renouvellement augmente strictement après chaque renouvellement effectivement confirmé pour ce marchand ; montant affiché avant confirmation.
- **SHOP-198-03** : un renouvellement tire de nouveaux articles selon la rareté, le pool de la tour, les exclusivités et le filtre des quatre exemplaires ; une exclusivité n'est jamais garantie.
- **SHOP-198-04** : coût de base et formule de hausse (linéaire/exponentielle/other) **OUVERTS** ; aucune valeur illustrative n'est normative.
- **SHOP-198-05** : un renouvellement validé est atomique (débit du prix affiché, changement d'inventaire, incrément du compteur) ; si le solde est insuffisant, aucune des trois composantes n'est modifiée.

## Q199 — Compteur indépendant pour chaque instance de marchand : A

- **SHOP-199-01** : chaque instance de marchand possède un compteur de renouvellements propre. Les nouveaux marchands commencent au tarif de base de leur instance.
- **SHOP-199-02** : quitter et rouvrir le même commerce pendant la même ascension conserve le compteur et le stock ; pas de contournement par réouverture.
- **SHOP-199-03** : les compteurs des autres marchands restent inchangés lorsqu'un marchand est renouvelé.
- **SHOP-199-04** : sauvegarde/reprise d'une tentative conserve compteurs et stocks ; **nouvelle ascension** les réinitialise.

## Q200 — Un exemplaire par offre, carte achetée pouvant réapparaître : B

- **SHOP-200-01** : chaque emplacement d'offre comporte **une unité achetable** ; l'achat vide cet emplacement, sans modifier les autres.
- **SHOP-200-02** : le renouvellement remplace les offres encore affichées et peut à nouveau tirer une carte achetée précédemment, **si sa limite de quatre exemplaires n'est pas atteinte**.
- **SHOP-200-03** : la seconde acquisition d'une même carte ajoute une nouvelle copie dans le deck d'ascension, mais ne crée pas un second déblocage dans le catalogue permanent.
- **SHOP-200-04** : achats et état d'inventaire conservés lors de la sauvegarde/reprise ; aucune double attribution après clic répété ou rechargement.

## Q201 — Quatre copies identiques maximum, rareté indifférente : B adaptée

- **DECK-201-01** : **4** copies de la même identité canonique maximum **dans le deck actif et la réserve réunis** (Q207), Commun à Légendaire ; **pas de rareté Mythique** (Q181).
- **DECK-201-02** : aucune règle de copie unique propre aux cartes légendaires ; leur faible probabilité peut limiter leur accumulation naturellement, sans garantie mathématique chiffrée à ce stade.
- **DECK-201-03** : achats et récompenses ordinaires respectent le plafond ; au commit, un cinquième exemplaire est refusé sans débit ni acquisition.
- **DECK-201-04** : le nombre de copies de deck n'est pas celui des copies temporaires créées pendant les combats ; ne pas compter ces dernières dans les limites de stock/draft.
- **DECK-201-05** : le déblocage permanent d'une identité de carte est **unique**, indépendamment des copies temporairement détenues.

## Q202 — Filtrer les cartes plafonnées dans les commerces : B

- **SHOP-202-01** : exclure du pool de génération initial et de renouvellement les cartes déjà possédées à 4 exemplaires **entre deck actif et réserve** (Q207).
- **SHOP-202-02** : avant confirmation d'un achat, revérifier le nombre de copies de deck et les fonds ; une offre affichée mais devenue non achetable ne peut être débitée.
- **SHOP-202-03** : si le pool éligible manque de cartes, le commerce propose moins d'articles plutôt que des cartes impossibles à acheter ; le tirage ne contourne jamais les exclusivités de tour.

## Q203 — Filtrer les cartes plafonnées dans les récompenses : B

- **REWARD-203-01** : avant tirage des **trois propositions standard** [Q177](rewards-rarity-and-ascension.md), retirer les identités déjà à 4 exemplaires **entre deck actif et réserve** (Q207).
- **REWARD-203-02** : si seulement 1 ou 2 cartes éligibles existent, les proposer sans remplir les places manquantes avec des offres invalides ; ne jamais présenter de choix impossible.
- **REWARD-203-03** : la possibilité de **refuser les cartes contre des ressources** [Q178](rewards-rarity-and-ascension.md) reste applicable.
- **REWARD-203-04** : revalider l'éligibilité lors de l'attribution transactionnelle ; pas de cinquième copie, y compris après reprise de sauvegarde.

## Q204 — Pool entièrement épuisé : B

- **REWARD-204-01** : lorsque le nombre de cartes éligibles est **0**, remplacer **automatiquement** le choix de carte par la **compensation en ressources de Q178** ; **aucun écran de sélection de cartes vide**.
- **REWARD-204-02** : conserver **en plus** les gains automatiques de monnaie et d'EXP [Q179](rewards-rarity-and-ascension.md).
- **REWARD-204-03** : compensation enregistrée une **seule fois**, sans tirage ni acquisition de carte, sans déblocage de carte permanente et sans double paiement en cas de rechargement/retry.
- **REWARD-204-04** : ne pas ouvrir implicitement les pools d'autres tours ou inventer une amélioration de héros/artefact comme alternative ; montants et type précis des ressources de Q178 restent ouverts.

## Algorithme de sélection proposé (contrat métier, pas d'API imposée)

1. Identifier le contexte de tirage (tour, marchand, récompense standard), la version du catalogue et la graine déterministe de tentative.
2. Appliquer les restrictions de contenu et d'exclusivité **avant** le tirage (en boutique, la tour détermine les exclusivités ; en récompense, respecter le pool configuré).
3. Filtrer les identités `ownedRunCopies(cardId) = activeDeckCopies(cardId) + reserveCopies(cardId) >= 4` sans compter les copies temporaires générées pendant les combats.
4. Tirer dans le pool restant selon les **poids configurables non encore fixés**. Une offre représente une unité. Aucun résultat caché n'est révélé hors des offres présentées.
5. Pour les récompenses standard : proposer jusqu'à trois identités éligibles, ou si pool vide, accorder directement la compensation Q178 ; l'absence d'une troisième proposition ne crée pas une autre compensation automatique.
6. Au commit, vérifier soldes, seuil de quatre, disponibilité du stock ou identité de l'offre, puis attribuer exactement une fois la copie et, si nouvelle, son déblocage permanent [Q194](towers-merchants-and-unlocks.md).
7. Pour le renouvellement du marchand, débiter exactement une fois, générer le nouveau stock et incrémenter **son** compteur ; l'affichage doit refléter le prochain coût, pas le précédent.

## Compatibilité et références croisées

- [Récompenses Q175–Q184](rewards-rarity-and-ascension.md) : sélection parmi trois, refus contre compensation, EXP automatique, code couleur des cinq raretés.
- [Tours et déblocages Q190–Q194](towers-merchants-and-unlocks.md) : exclusivités territoriales, meta-progression et première acquisition de chaque carte.
- [Sphérier Q185–Q189](hero-sphere-and-skill-tree.md) : EXP permanente malgré monnaie de tentative temporaire.
- [RNG, journal et compatibilité des sauvegardes](../09-technical/causal-budgets-and-replay.md) ; [effets atomiques](../01-combat/effect-resolution.md) ; [identité des instances](../01-combat/instance-identity.md).
- [Tests Q195–Q204](../09-technical/acceptance-tests.md) ; [journal de décisions](../DECISIONS.md).

## Points restant ouverts

Montants par rareté et ajustements prix ; taux de drop et tirage des exclusivités ; stock initial, nombre de marchands par tour, politique des offres identiques entre emplacements ; montant/formule de hausse du renouvellement ; ressources exactes de compensation Q178 ; éventuels outils de manipulation du RNG ; règles particulières de cartes acquises autrement que par draft/boutique ; limites spécifiques aux artefacts. **Ne pas ériger des illustrations chiffrées en exigences.**

## Addendum normatif v2.2 — Q205–Q214
Les mentions plus anciennes du seul « deck » comme compteur de copies sont **interprétées désormais comme deck actif + réserve** (Q207), sans changer la limite de quatre. Une carte transférée vers la réserve demeure possédée et ne réentre pas dans le pool marchand/récompense ; une copie créée uniquement en combat reste hors compteur. Voir [préparation du deck et réserve Q205–Q209](deck-reserve-and-capacity.md).
Les cartes obtenues lors de recherches en pioche (Q211–Q214) sont des **instances déjà acquises**, déplacées entre zones de combat : elles ne créent pas une nouvelle copie de collection, ni un nouveau déblocage permanent. Voir [recherche en combat](../01-combat/deck-search-and-fatigue-v22.md).

---

## Fichier : `03-progression/mvp-card-catalog-and-tribes.md`

# Familles évolutives, catalogue MVP et peuples — Q225–Q234 (v2.4)

> **Source normative** pour Q225–Q234. Décisions validées et éléments restant ouverts explicitement séparés. Références : [préparation d'ascension Q215–Q224](ascension-start-boosters-and-autobuild.md), [deck et réserve Q205–Q209](deck-reserve-and-capacity.md), [sphérier Q185–Q189](hero-sphere-and-skill-tree.md), [raretés Q181](rewards-rarity-and-ascension.md), [déblocages Q194](towers-merchants-and-unlocks.md), [boutiques Q195–Q204](merchant-stock-and-deck-limits.md), [tests](../09-technical/acceptance-tests.md).

## Q225 — Catalogue fondamental et secours déterministe

- **CARD-225-01 :** dès la création du profil, des **identités fondamentales** sont débloquées pour que le jeu puisse constituer le socle attribué et les deux boosters de 15 cartes, sans carte verrouillée.
- **CARD-225-02 :** générer normalement les boosters avec les pondérations Q218 et les garanties du sphérier ; si une garantie devient impossible, l'assouplir conformément à Q219 avant de recourir au mécanisme de secours.
- **CARD-225-03 :** si la génération se trouve à court d'options éligibles, compléter de façon **déterministe** à partir des cartes fondamentales **déjà débloquées** et non plafonnées. Le secours ne fabrique jamais un déblocage, une copie au-delà de quatre, ni une carte hors catalogue.
- **CARD-225-04 :** valider l'éligibilité à l'échelle de l'ensemble **20 socle + 15 booster 1 + 15 booster 2**, incluant les limites par famille définies en Q227 ; tenir compte des versions du socle issues du sphérier Q226.
- **CARD-225-05 :** la composition effective du catalogue débloqué par défaut constitue un invariant de contenu : il doit exister une génération légale de 50 copies pour **chaque état de sphérier admissible**, faute de quoi la configuration de contenu ou de compétences doit être corrigée avant livraison. La règle de secours seule ne peut pas résoudre une insuffisance mathématique de cartes éligibles.
- **CARD-225-06 :** hypothèse de faisabilité : **au moins 13 familles indépendantes de plafond** sont nécessaires pour produire 50 copies sous une limite de quatre par famille (⌈50/4⌉=13) ; en pratique, composition du socle, raretés, restrictions, variantes et disponibilités peuvent exiger davantage. « 13 » n'est **pas** une cible ludique ni une garantie de faisabilité.
- **CARD-225-07 :** sauvegarder l'état et les résultats de tirage pour reproductibilité ; le mécanisme ne boucle jamais indéfiniment.

## Q226–Q229 — Variantes du sphérier réservées au socle

- **CARD-226-01 — Q226 personnalisé :** les variantes de cartes fondamentales remplacent **automatiquement, de manière déterministe**, les versions précédentes **dans les seuls 20 emplacements du socle initial**. Aucune sélection manuelle obligatoire, ni changement du nombre d'emplacements.
- **CARD-226-02 :** même sphérier permanent actif et même règle de remplacement ⇒ mêmes variantes du socle. Les changements de sphérier entre ascensions recalculent le socle (Q189). Les conflits entre branches qui modifieraient le même emplacement doivent être prévenus par les prérequis ou résolus selon une priorité explicite **encore ouverte** ; ne pas inventer un arbitrage.
- **CARD-227-01 — Q227 B :** chaque carte fondamentale évolutive possède une `familyId` commune à ses variantes et des `variantId` distincts. Les copies physiques possèdent chacune un identifiant d'instance.
- **CARD-227-02 :** le maximum est de **quatre copies par famille**, toutes variantes confondues, en sommant deck actif et réserve (Q207). Cette limite familiale prévaut sur le simple regroupement par `cardId` lorsque des variantes existent ; toutes les autres familles ou cartes indépendantes conservent leur plafond normal Q207.
- **CARD-228-01 — Q228 A :** seule une copie **provenant d'un emplacement du socle fondamental** reçoit la variante du sphérier. Les copies de la même famille acquises par des voies normales ne changent pas de version en raison du sphérier.
- **CARD-228-02 :** déplacer une carte de base modifiée vers la réserve puis la réintégrer ne change ni sa variante ni son origine. Pas de transformation rétroactive en plein combat ou milieu d'ascension.
- **CARD-229-01 — Q229 précision utilisateur :** les **variantes du sphérier ne figurent jamais dans les deux boosters de départ**. Les cartes du booster restent leurs versions ordinaires et ne sont pas améliorées par le sphérier.
- **CARD-229-02 :** le principe « variantes réservées au socle » s'applique également au **catalogue de variantes du sphérier** : ce n'est pas un pool normal d'acquisition. Les effets particuliers de transformation de carte en cours de partie, s'ils sont conçus ultérieurement, nécessitent des règles dédiées ; ne pas les inférer des compétences de socle.
- **CARD-229-03 :** les filtres de tirage des boosters, marchands et récompenses excluent les `variantId` réservés au socle ; les plafonds par famille incluent néanmoins les copies améliorées effectivement attribuées dans le socle.

### Distinction de trois identités

- **Identité de famille (`familyId`) :** utilisée pour le plafond de quatre, qui peut couvrir plusieurs versions.
- **Identité de définition (`variantId`/`cardId`) :** coût, effets, statistiques, texte et illustration propres à une version.
- **Identité d'instance (`instanceId`) :** copie effectivement attribuée, position, origine (socle, booster, récompense), état ; les règles d'instances sur le plateau conservent leurs particularités ([Q57](../01-combat/instance-identity.md)).

## Q230 — Budget de contenu MVP révisé

**La précédente cible globale de 100 définitions a été explicitement remplacée** par une cible de **≈170 définitions de cartes** :

| Composante | Définitions cibles | Sens |
|---|---:|---|
| Fondamentales | **40** | Identités fondamentales disponibles pour définir le socle et le catalogue fondamental ; **20 exemplaires seulement** sont attribués au début d'une ascension. |
| Variantes du sphérier | **≈30** | Hypothèse de **≈10 familles évolutives × 3 variantes additionnelles** chacune ; ne figurent pas dans les boosters Q229. |
| Indépendantes | **100** | Cartes utilisables par les boosters, récompenses et marchands sous réserve des déblocages et conditions de tour. |
| **Total** | **≈170** | Définitions, **pas** exemplaires physiques ni cartes toutes débloquées d'emblée. |

- **MVP-230-01 :** ≈170 est un budget de production MVP et non un nombre imposé de copies du deck.
- **MVP-230-02 :** le passage à 40 définitions fondamentales **ne modifie pas** le socle fixe de **20 exemplaires** de Q215/Q224 ; le choix exact des 20 emplacements à partir de ces définitions reste à formaliser. Un socle initial stable et déterministe est requis ; aucun tirage supplémentaire n'est impliqué.
- **MVP-230-03 :** des variantes supplémentaires requièrent des définitions, une validation d'effets, parfois des illustrations et tests ; compter les familles séparément des définitions.
- **MVP-230-04 :** les 100 cartes indépendantes ne sont **pas toutes débloquées** au commencement d'un profil ; Q194/Q225 restent les seules autorités pour la progression du catalogue permanent.
- **MVP-230-05 :** les quatre exemplaires maximum s'appliquent aux **copies obtenues**, sans limiter le nombre de définitions existantes.

## Q231–Q232 — Taxonomie et couverture tactique des 100 indépendantes

- **MVP-231-01 — Q231 C adaptée :** répartir les 100 cartes indépendantes en trois grandes catégories : **neutres/polyvalentes**, **élémentaires**, **hybrides/avancées**. Une allocation **illustrative** 33 / 50 / 17 est proposée, **non validée comme quota exact**.
- **MVP-231-02 :** les synergies élémentaires peuvent utiliser plusieurs rôles ; chaque spécialisation conserve une identité de jeu ; les cartes hybrides rendent possibles des combinaisons originales.
- **MVP-232-01 — Q232 C :** utiliser des **quotas indicatifs souples** par rôle tactique, et non des quotas obligatoires. Chaque carte possède un rôle principal d'inventaire et peut avoir plusieurs rôles secondaires.
- **MVP-232-02 :** rôles principaux suivis : **offensif**, **défensif**, **invocation**, **contrôle/altérations**, **soutien/ressources**, **pioche/recherche**. Répartition **indicative** 25/15/20/15/15/10, ajustable selon la conception réelle.
- **MVP-232-03 :** les decks doivent avoir des moyens raisonnables de gagner, survivre et développer leur stratégie ; le nombre de mécaniques et les synergies significatives priment sur des quotas artificiels.

## Q233–Q234 — Heroic Fantasy, éléments, peuples et extensibilité

- **MVP-233-01 — Q233 C adaptée :** les **éléments** ont des identités mécaniques fortes ; les **archétypes tactiques** sont transversaux et peuvent associer plusieurs éléments ou peuples.
- **MVP-233-02 :** les cartes de créatures peuvent porter des métadonnées de **peuple/type** (ex. Nain, Elfe, Humain, Dragon) et exploiter des synergies de peuple, type, faction, élément et rôle tactique. Plusieurs axes peuvent coexister sur une même définition de carte.
- **MVP-233-03 :** esthétique et mécaniques **Heroic Fantasy** inspirées des genres de fantasy classique et RPG sur table ; créer des noms, illustrations et effets originaux, sans nécessité de reprendre des contenus protégés d'une franchise.
- **MVP-234-01 — Q234 personnalisé :** représenter **quatre peuples** dans le **catalogue MVP**. Humains, Elfes, Nains et Dragons sont des **exemples**, **pas quatre choix nominativement validés**.
- **MVP-234-02 :** la présence d'un peuple ne garantit pas automatiquement un deck tribal autonome ou un quota de cartes propres à ce peuple ; développer les synergies en fonction de leur valeur de gameplay.
- **MVP-234-03 :** prévoir l'extension future avec d'autres peuples/types, dont **Gobelins et Morts-vivants**, ainsi qu'éventuellement Orcs, Démons, Élémentaires, etc. Aucun de ces ajouts ultérieurs ne doit exiger une refonte structurelle du moteur.
- **MVP-234-04 :** fournir des identifiants stables de peuple/type et des critères de ciblage de données (`tribeIds`, `creatureTypeIds`, `factionIds`, `elementIds` comme exemples techniques, **noms de champs non imposés**). Ne pas coder en dur les peuples connus lors du MVP ; compatibilité avec sauvegardes, génération déterministe, UI d'inspection, filtres et interactions.
- **MVP-234-05 :** ne pas confondre **quatre peuples du MVP** avec **quatre archétypes obligatoires** ou **quatre éléments obligatoires**. Nombre et noms d'éléments/archétypes complets restent **OUVERTS**.

## Invariants, conflits et questions encore ouvertes

1. **50 exemplaires de préparation** (Q215) = 20 copies de socle déterministe (Q224/Q226) + 30 copies de boosters débloquées (Q218/Q219/Q225), avec **4 copies maximum par famille** (Q227) sur deck+réserve (Q207).
2. Les **variantes du sphérier** modifient les seules copies **d'origine socle** et ne se mélangent jamais aux pools de booster (Q228/Q229). Elles peuvent être placées en réserve (Q223).
3. Le calcul de **composition automatique** (Q216/Q222) intervient après ouverture des boosters (Q220), favorise la spécialisation du héros mais **n'ajoute aucune carte du catalogue**.
4. Le contenu MVP reste un budget approximatif **40 + 30 + 100 ≈ 170**, sans modifier la base 40/40 (Q208/Q217), sans imposer 40 cartes fondamentales simultanément dans le socle.
5. **OUVERT :** identité exacte des quatre peuples MVP ; nombre et dénomination des éléments ; nombre de vrais archétypes tribaux ; répartition exacte par rareté ; coûts/effets des compétences de variante ; affectation des 20 emplacements de base aux 40 définitions fondamentales ; faisabilité des 50 copies légales dans toutes les configurations autorisées ; effets de carte spéciaux capables de transformer des copies pendant l'ascension ; extension de l'indexation faction/peuple.

> **Mise à jour normative v2.7 :** les anciennes mentions « quatre peuples exacts ouverts » de Q234 sont remplacées par Q235 (Humains, Elfes, Nains, Dragons). La répartition des **50 créatures indépendantes** et les cibles de conception sont désormais décrites dans [Q255–Q264](independent-card-catalog-and-synergies-v27.md). Les anciens quotas de rôle Q232 sont indicatifs et ne s’ajoutent pas aux 50 créatures, 30 sorts et 20 équipements de Q258.

---

## Fichier : `03-progression/rewards-rarity-and-ascension.md`

# Récompenses, raretés, artefacts et progression d’ascension — Q175–Q184

> **Statut : VALIDÉ** pour les décisions explicites Q175–Q184. Document propriétaire de la consolidation v1.9 (2026-11-04). **Aucun code implémenté ; scénarios d’acceptation non exécutés.** Les exemples ne valent ni valeurs d’équilibrage ni contenu de cartes officiel.

## Architecture de la progression et dépendances

- Le [moteur de combat](../01-combat/README.md) produit l’issue canonique du combat et ses événements. Le [journal utilisateur et ses règles de révélation](../02-art-direction/combat-journal-and-inspection.md) restent indépendants de la distribution des gains.
- La [direction artistique / orchestrateur VFX](../02-art-direction/tooltips-durations-and-vfx.md) anime l’issue, sans modifier les faits calculés par le [moteur d’événements](../01-combat/event-queue.md) ou les [règles de victoire/défaite](../01-combat/victory-and-defeat.md).
- Pour les changements d’état, consulter les [transactions atomiques](../01-combat/effect-resolution.md), [identifiants d’instances](../01-combat/instance-identity.md) et [replays/snapshots](../09-technical/causal-budgets-and-replay.md). Le choix de récompense doit être persisté de manière idempotente, sans réattribuer plusieurs fois les gains.
- Les récompenses sont des objets du système de progression, non des événements qui autorisent à rejouer une attaque ni des cartes déjà ajoutées au deck tant que le choix n’est pas validé.

## Q175 — Mise en scène de la victoire : B

- **UX-175-01** : Le coup final reçoit un feedback audiovisuel marqué et lisible.
- **UX-175-02** : Victoire ordinaire : courte célébration, puis accès rapide aux récompenses.
- **UX-175-03** : Boss/affrontement majeur : célébration plus spectaculaire, proportionnée à l’enjeu.
- **UX-175-04** : L’intensité varie sans imposer une animation longue à chaque combat.
- **UX-175-05** : Le joueur peut passer rapidement à l’écran des gains.
- **UX-175-06** : Transitions fluides, cohérentes avec le décor fantasy.
- **UX-175-07** : Les VFX ne changent jamais l’issue, les gains ni l’état canonique du moteur.

## Q176 — Écran de récompenses : B

- **UX-176-01** : Écran fantasy dédié après une victoire.
- **UX-176-02** : Inspection complète des cartes, artefacts et objets avant sélection.
- **UX-176-03** : Distinction explicite entre gains automatiques et gains à choisir.
- **UX-176-04** : Révélation brève, expressive, graduée à la rareté réelle.
- **UX-176-05** : Comparaison des offres en conservant le contexte de progression dans la tour.
- **UX-176-06** : Les choix obligatoires sont validés avant de passer à l’étape suivante ; le détail du parcours est à calibrer.
- **UX-176-07** : Support de plusieurs catégories de gains et offres particulières de boss.

## Q177 — Choix de carte standard : B

- **REWARD-177-01** : Une offre standard de carte présente **trois cartes éligibles**.
- **REWARD-177-02** : Chaque carte peut être inspectée complètement avant décision.
- **REWARD-177-03** : Le joueur n’en choisit **qu’une seule**, ou emprunte l’alternative Q178.
- **REWARD-177-04** : Confirmation explicite avant ajout de carte au deck.
- **REWARD-177-05** : Les propositions respectent les règles de pool éligible et de rareté ; aucun taux n’est fixé.
- **REWARD-177-06** : Feedback de sélection/rejet bref et satisfaisant.
- **REWARD-177-07** : Ne pas interpréter Q177 comme refus interdit : Q178 autorise une compensation.

## Q178 — Refus de trois cartes contre ressources : C

- **REWARD-178-01** : Choisir une carte **ou** refuser les trois.
- **REWARD-178-02** : Refuser donne une **compensation en ressources** ; type et montant ouverts.
- **REWARD-178-03** : La compensation remplace seulement le choix de carte, pas les gains automatiques Q179.
- **REWARD-178-04** : Afficher le montant/la nature avant confirmation.
- **REWARD-178-05** : Aucun ajout de carte si compensation sélectionnée.
- **REWARD-178-06** : Montant à équilibrer contre la valeur du draft pour éviter un refus toujours optimal.
- **REWARD-178-07** : Choix final après confirmation ; engagement idempotent, aucun double octroi après relance/chargement.

## Q179 — Gains automatiques : B

- **REWARD-179-01** : Chaque victoire attribue de la **monnaie**.
- **REWARD-179-02** : Chaque victoire attribue de l’**expérience du héros (EXP)**.
- **REWARD-179-03** : Ces deux gains sont indépendants du choix Q177 et de la compensation Q178.
- **REWARD-179-04** : Les montants peuvent varier selon type de combat, étage et difficulté ; barème ouvert.
- **REWARD-179-05** : Boss/combats spéciaux : gains additionnels possibles, voir Q180.
- **REWARD-179-06** : La présentation distingue gains attribués et gains optionnels.
- **REWARD-179-07** : Pas de nécessité de multiplier les monnaies ou matériaux dès la V1.

## Q180 — Boss : C

- **REWARD-180-01** : Boss vaincu : monnaie et EXP **renforcées**.
- **REWARD-180-02** : Offre **une récompense exceptionnelle à choisir**.
- **REWARD-180-03** : Catégories admissibles : **carte rare**, **artefact**, **amélioration du héros**.
- **REWARD-180-04** : Le joueur choisit une récompense exceptionnelle parmi les propositions disponibles ; nombre exact et composition sont ouverts.
- **REWARD-180-05** : Chaque catégorie doit présenter une vraie valeur stratégique, équilibrée pour le parcours.
- **REWARD-180-06** : Les joueurs à deck compact peuvent choisir sans nouvelle carte.
- **REWARD-180-07** : La présentation distingue visuellement récompenses de boss et ordinaires.
- **REWARD-180-08** : Barèmes, pools, puissance et détails de sélection restent ouverts.
- **Règle d’articulation** : Ne pas présumer que le boss attribue automatiquement en plus un draft standard Q177 : il possède une offre exceptionnelle Q180. L’éventuel cumul dépendra d’une décision future.

## Q181 — Cinq niveaux de rareté : option C personnalisée (sans mythique)

**Ordre validé, croissant :**

| Rang | Niveau | Couleur canonique | Rôle indicatif, non valeur de puissance |
|---|---|---|---|
| 1 | **Commun** | **Blanc** | Fondamentaux, synergies accessibles |
| 2 | **Peu commun** | **Bleu** | Outils spécialisés |
| 3 | **Rare** | **Rouge** | Effets moins fréquents/distinctifs |
| 4 | **Épique** | **Violet** | Capacités et synergies particulières |
| 5 | **Légendaire** | **Or** | Identité exceptionnelle |

- **RARITY-181-01** : Exactement cinq rangs ci-dessus ; **aucun rang Mythique**.
- **RARITY-181-02..06** : Codes couleur obligatoires : Commun/blanc, Peu commun/bleu, Rare/rouge, Épique/violet, Légendaire/or ; ne jamais confondre rare/bleu.
- **RARITY-181-07** : Conventions cohérentes sur cartes et présentation des récompenses ; pour les artefacts, la convention commune s’applique **lorsqu’une rareté leur est attribuée** (détails du pool encore ouverts).
- **RARITY-181-08** : Rareté et puissance ne sont pas équivalentes ; une commune peut rester utile et supérieure dans une synergie.
- **RARITY-181-09** : Teintes exactes, distribution/probabilités et contraintes d’offre non fixées.
- **Accessibilité** : compléter les couleurs par cadres, symboles, motifs et libellés ; distinction indépendante de la perception chromatique.
- **Cohérence de la récompense de boss** : « carte rare » au sens générique de meilleure qualité ne fixe **pas** automatiquement le rang minimum ou garanti de chaque proposition. Éligibilité et garanties à préciser ; éviter de transformer Q180 en carte légendaire obligatoire.

## Q182 — Artefacts de l’ascension et déblocages persistants : B, enrichie

- **PROG-182-01** : Les artefacts obtenus sont conservés **jusqu’à la fin de la tentative d’ascension en cours**.
- **PROG-182-02** : Aucun artefact obtenu n’est transféré automatiquement à la tentative suivante.
- **PROG-182-03** : **Terminer une tour** peut débloquer **de nouvelles cartes et de nouveaux artefacts**.
- **PROG-182-04** : Le contenu débloqué devient **éligible au draft** lors des ascensions suivantes, selon ses contraintes de pool.
- **PROG-182-05** : Déblocage ≠ obtention automatique au début d’une nouvelle ascension.
- **PROG-182-06** : L’état de déblocage de contenu est persistant entre tentatives.
- **PROG-182-07** : Le méta-progrès élargit la **diversité des possibilités de stratégie**, sans octroyer automatiquement des statistiques accrues à chaque nouvelle tentative.
- **Ouvert** : critères de fin de tour/défi, carte/artefact concernés, niveaux de difficulté, tables de déblocage, sauvegarde exacte de la méta-progression.

## Q183 — Capacité d’artefacts évolutive : C

- **ART-183-01** : Capacité d’artefacts **limitée** par des emplacements.
- **ART-183-02** : Possibilité de débloquer des emplacements **pendant l’ascension** grâce à récompenses/améliorations prévues.
- **ART-183-03** : Les augmentations sont propres à la tentative en cours.
- **ART-183-04** : Nouvelle ascension : retour à la capacité initiale, hors exception future explicitement validée.
- **ART-183-05** : Par défaut, un artefact occupe un emplacement ; exceptions explicites possibles.
- **ART-183-06** : À capacité atteinte, acquisition nouvelle requiert de libérer/remplacer un emplacement ; les détails du flux de remplacement et du refus restent ouverts.
- **ART-183-07** : Nombre initial, plafond, coût et moyens précis de déverrouillage restent **OUVERTS**. **Ni « 3 au départ », ni « 5 au maximum » ne sont validés.**

## Q184 — Améliorations du héros : C

- **HERO-184-01** : Les récompenses « amélioration du héros » peuvent concerner **ses caractéristiques** ou **ses capacités**.
- **HERO-184-02** : La catégorie « caractéristiques » peut inclure PV, statistiques ou ressources pertinentes, **sans liste de caractéristiques ni valeurs adoptées à ce stade**.
- **HERO-184-03** : La catégorie « capacités » permet l’ajout ou l’évolution de capacités du héros, sous réserve des règles existantes du moteur.
- **HERO-184-04** : Le joueur peut arbitrer entre améliorations disponibles selon sa stratégie ; les règles exactes d’offre et de choix restent ouvertes.
- **HERO-184-05** : Les améliorations obtenues pendant une ascension disparaissent à la fin de cette tentative ; elles ne produisent aucun gain de puissance automatique lors de la suivante.
- **HERO-184-06** : Progression persistante de **déblocage de contenu** Q182 séparée des caractéristiques/capacités temporaires Q184.
- **HERO-184-07** : Une augmentation de capacité d’artefacts Q183 pourra être offerte comme amélioration du héros **si un futur arbitrage la rend éligible** ; ne pas l’imposer comme acquis.
- **EXP** : la monnaie et l’EXP sont accordées automatiquement Q179, mais **le mécanisme de montée de niveau, la persistance éventuelle de l’EXP, les seuils et la conversion en améliorations sont encore OUVERTS (Q185 à examiner)**. Ne pas supposer que chaque combat donne directement une amélioration de héros.

## Ordre de traitement recommandé pour la future implémentation (contrat, pas nouvelle mécanique)

1. Combat terminé de façon canonique par le moteur ; émission d’un identifiant stable d’issue.
2. Affichage de la célébration Q175 avec révélation conforme au [journal Q174](../02-art-direction/combat-journal-and-inspection.md).
3. Préparation d’une offre immuable de récompenses éligibles, dérivée de l’issue et de l’état de progression (aléatoire déterministe si applicable).
4. Présentation Q176 : gains automatiques Q179, puis choix Q177/178 ou choix exceptionnel Q180 selon type de combat.
5. Confirmation explicite et **engagement unique** des gains. En sauvegarde/reprise, une offre déjà présentée reste identique et une offre déjà validée ne peut plus réattribuer des gains.
6. Transition vers la prochaine étape de la tour. Les détails précis de navigation/écran restent à définir.

## Visibilité, confidentialité et états de l’interface

- Révéler seulement les cartes, artefacts, effets et quantités **proposés au joueur**. Ne pas afficher les RNG, pools cachés, cartes non proposées ou événements de combat non révélés.
- La révélation de la victoire doit suivre les événements Q174 ; ne pas anticiper un boss mort par le journal ou l’écran des gains tant que le combat visuel n’a pas présenté cette issue.
- Les trois cartes proposées sont inspectables avant engagement. Pour les récompenses de boss, inspecter chaque catégorie disponible de manière équivalente.
- Afficher séparément et clairement **monnaie/EXP garanties**, **choix de carte** et **compensation** ; l’option de refus ne doit jamais être déguisée en gain automatique.
- Indiquer explicitement les emplacements d’artefacts libres et les conséquences d’un remplacement ; ne pas consommer une récompense de manière silencieuse.
- Les codes couleur Q181 doivent être doublés de marqueurs non chromatiques. Les animations ne peuvent pas exagérer la rareté réelle.

## Invariants et questions non tranchées

- V1 : ascensions réinitialisant le deck construit en cours, les artefacts de run et les améliorations du héros **dans la mesure où le design du deck l’impose** ; conserver seulement les déblocages persistants explicitement validés, ne pas inventer d’autres ressources persistantes.
- **Ouvert** : taux de drop, poids de rareté, seuils d’EXP, durée de l’EXP, prix de remplacement/commerce, taille initiale et maximale d’inventaire, mode de refus/remplacement d’artefact, fréquence des récompenses de cartes, nombre exact d’options de boss et contenu des talents.
- **À décider** : question Q185 — modalités EXP / niveau et interaction avec la progression temporaire et les gains de boss.

## Vérification

Voir [tests d’acceptation T-175-01 à T-184-04](../09-technical/acceptance-tests.md) : quarante scénarios écrits, **non exécutés**. Source des arbitrages : [DECISIONS](../DECISIONS.md).


## Complément normatif v2.0 — Q185–Q194

- Q184 régit **les améliorations temporaires de récompense** (dont boss), distinctes du [sphérier permanent Q185–Q189](hero-sphere-and-skill-tree.md).
- Q179 reste la source des gains d’EXP ; Q186 précise que cette **EXP est persistante** et alimente les niveaux et points de compétence permanents.
- Q182 reste la source de temporalité des copies de cartes et artefacts de tentative. **Q194 précise que toute carte effectivement obtenue ou achetée déverrouille aussi son identité dans le catalogue de draft permanent** (sans être offerte dans les futures tentatives). Voir [tours, boutiques, déblocages](towers-merchants-and-unlocks.md).
- La rareté Q181 reste strictement **Commun/blanc ; Peu commun/bleu ; Rare/rouge ; Épique/violet ; Légendaire/or**, sans Mythique.

## Mise à jour v2.1 — Éligibilité des cartes Q201–Q204

La règle Q177 des trois cartes est désormais sous réserve des filtres d’éligibilité : au plus quatre exemplaires par identité de carte ; si le pool contient moins de trois cartes valides, afficher moins de propositions ; s’il est vide, attribuer **automatiquement** la compensation Q178, en plus de la monnaie et de l’EXP Q179, sans écran de sélection. Consulter [boutiques et limites Q195–Q204](merchant-stock-and-deck-limits.md).

---

## Fichier : `03-progression/towers-merchants-and-unlocks.md`

# Tours, difficulté, succès, marchands et déblocages — décisions Q190–Q194

> **VALIDÉ :** principes de progression. Ce module prévaut sur toute ancienne formulation selon laquelle seules les premières victoires déverrouillent les cartes. Les barèmes et inventaires restent ouverts.

## Q190 — Accès aux tours : D personnalisée

- **TOWER-190-01** : plusieurs tours de difficultés différentes sont ouvertes dès le départ.
- **TOWER-190-02** : certaines tours spéciales sont verrouillées initialement et se déverrouillent après achèvement d’une ou plusieurs tours prérequises.
- **TOWER-190-03** : ces déblocages sont persistants entre les ascensions.
- **TOWER-190-04** : ni niveau minimum du héros ni nœud précis du sphérier ne conditionnent l’accès à une tour déjà déverrouillée.
- **TOWER-190-05** : une difficulté / un niveau conseillé peut être affiché sans être bloquant.

## Q191 — Première victoire et rejouabilité : B

- **TOWER-191-01** : chaque tour peut accorder des déblocages permanents **uniques** à la première victoire : cartes, artefacts, accès à des tours spéciales.
- **TOWER-191-02** : les victoires suivantes accordent des récompenses répétables, par exemple monnaie et EXP, mais n’attribuent pas une seconde fois le déblocage unique.
- **TOWER-191-03** : présenter les déblocages acquis et les récompenses encore accessibles.
- **TOWER-191-04** : un déblocage de carte/artefact rend l’élément **éligible**, sans l’ajouter automatiquement au deck de départ ni à l’inventaire des tentatives futures.

## Q192 — Difficulté fixe et diminution de l’intérêt des récompenses : A personnalisée

- **TOWER-192-01** : chaque tour a une difficulté fixe ; pas de niveaux supplémentaires obligatoires, pas de mise à l’échelle dynamique des ennemis selon le héros.
- **TOWER-192-02** : toutes les tours déverrouillées restent rejouables.
- **TOWER-192-03** : à mesure que le niveau du héros augmente, les récompenses répétables des anciennes tours deviennent **moins intéressantes** ; notamment rendement de l’EXP, et éventuellement gains économiques selon future décision.
- **TOWER-192-04** : la première récompense de déblocage unique ne subit **aucune pénalité** de niveau.
- **TOWER-192-05** : ne fixer **aucune** formule de décote, plancher, pourcentage ou multiplicateur à ce stade ; les chiffres de maquette étaient fictifs.

## Q193 — Accomplissements multiples et commerces de tour : D personnalisée

- **PROG-193-01** : le catalogue permanent peut s’élargir par les premières victoires, objectifs globaux, exploits, activités de combat et défis particuliers.
- **PROG-193-02** : les ascensions contiennent des commerces ; les achats peuvent inclure des cartes et d’autres éléments selon l’offre.
- **PROG-193-03** : **certaines cartes ne sont achetables que dans des commerces de certaines tours**. Cette exclusivité qualifie le **lieu/mode d’acquisition initiale** ; une carte ensuite débloquée reste éligible aux futurs drafts selon Q194. Ne pas déduire qu’elle doit rester éternellement exclue de toute autre source de draft.
- **PROG-193-04** : offres de marchands et cartes respectent les cinq raretés Q181 : Commun blanc, Peu commun bleu, Rare rouge, Épique violet, Légendaire or.
- **PROG-193-05** : les règles de stock (fixe/aléatoire/mixte), rotation, coûts, assortiment et autres articles restent ouvertes.

## Q194 — Toute carte obtenue ou achetée déverrouille le draft : réponse personnalisée

**Règle fondamentale :** **toute carte effectivement obtenue ou achetée pendant une ascension est immédiatement ajoutée, de manière persistante, à la collection des cartes éligibles aux drafts des prochaines ascensions**.

- **CARD-194-01** : acquisition effective via récompense, choix de carte, achat marchand ou autre gain de carte ⇒ déblocage permanent de l’identité de la carte dans le catalogue de draft.
- **CARD-194-02** : la carte obtenue ou achetée rejoint le deck / la zone prévue pour la **tentative actuelle**, selon les règles du mode d’acquisition ; sa **copie de tentative est perdue à la fin de l’ascension** (Q182). Le déblocage du catalogue demeure.
- **CARD-194-03** : le déblocage rend la carte **possible** dans les futurs drafts ; il **ne** garantit **pas** son apparition, son achat gratuit, ni sa présence dans le deck de départ.
- **CARD-194-04** : acquisition ou achat d’un exemplaire déjà débloqué ne duplique pas le déblocage permanent et n’accorde pas automatiquement de compensation supplémentaire ; les doublons de cartes dans le deck de tentative sont une règle distincte encore ouverte.
- **CARD-194-05** : consulter/inspecter une carte, voir une offre non choisie, refuser trois cartes contre ressources (Q178) ou regarder le stock d’un marchand **ne compte pas** comme acquisition.
- **CARD-194-06** : une carte de marchand exclusive à une tour devient, après achat, éligible aux drafts suivants. Son acquisition initiale reste conditionnée à la visite du commerce concerné ; les conditions de génération des futurs drafts peuvent appliquer d’autres restrictions d’éligibilité **à définir**, sans nier le déblocage.
- **CARD-194-07** : le déblocage est enregistré **au moment de l’acquisition confirmée**, pas conditionné à la victoire finale de la tour, y compris si le joueur perd ensuite l’ascension.
- **CARD-194-08** : confirmation, persistance, rejouage, rechargement et retry du même événement ne doivent pas réattribuer l’achat/la carte ni créer de double déblocage.
- **CARD-194-09** : la règle générale vise **les cartes** ; pour les artefacts, les déblocages permanents prévus par Q182/Q191/Q193 restent applicables, mais **tout artefact ramassé n’est pas automatiquement débloqué** sans décision supplémentaire.

### Exemple de cohérence

1. Le joueur entre dans la Tour du Givre, achète une carte exclusive chez son marchand.
2. La carte est utilisable pendant la tentative actuelle, et son identité rejoint immédiatement le **catalogue permanent**.
3. Le joueur échoue ensuite : le deck de cette tentative disparaît, mais la carte achetée reste **débloquée** dans la collection.
4. Lors d’une nouvelle ascension, cette carte peut faire partie des propositions de draft si les critères de génération l’autorisent ; elle n’est ni garantie ni offerte automatiquement.

## Liens de conception

- [Récompenses, écran de choix, refus et boss](rewards-rarity-and-ascension.md) — Q175–Q184.
- [Sphérier permanent, niveau et EXP](hero-sphere-and-skill-tree.md) — Q185–Q189.
- [Tests d’acceptation](../09-technical/acceptance-tests.md).
- [Identité / transactions atomiques](../01-combat/effect-resolution.md) et [replay/snapshots](../09-technical/causal-budgets-and-replay.md) : l’idempotence des récompenses demeure essentielle.

## Ouvert / non décidé

Probabilités des drafts, distribution et exclusions ; tarifs marchands ; fixation ou génération aléatoire des boutiques ; persistance de la monnaie ; nombre de cartes achetables ; achat d’artefact et effet sur catalogue permanent ; gestion de doublons du deck ; gain d’une carte hors d’une ascension ; stocks exclusifs et rotation ; récompenses de déblocage de première victoire exactes.

## Mise à jour v2.1 — Q195–Q204

Les questions de stock, de prix, de monnaie, de limite de copies, de rotation et de récompense lorsque le pool est vide ont été arbitrées : consulter [la source normative Q195–Q204](merchant-stock-and-deck-limits.md). Les mentions « ouvert » ci-dessus sur ces thèmes décrivent **l’état historique v2.0**, et ne prévalent pas sur v2.1. Restent ouverts les paramètres numériques précis, les tailles de stocks et les probabilités.

---

## Fichier : `09-technical/acceptance-tests.md`

# Tests d'acceptation du moteur de combat

> Scénarios à transformer en tests unitaires ; les cas dépendant de règles ouvertes sont marqués **À CONFIRMER**.

| ID | Règles | État initial et action | Résultat attendu |
|---|---|---|---|
| TEST-001 | BTL-003/004 | Attaquant C1, ennemi seulement en défense C1 | Défenseur ciblé |
| TEST-002 | SUM-003 | Ennemis C2/C5, aucun allié ; tenter invocation C4 | Interdite |
| TEST-003 | SUM-004 | Ennemis C2/C5, alliés C2/C5 ; invocation C4 libre | Autorisée si emplacement libre |
| TEST-004 | MOV-002/003 | Déplacer une créature verticalement deux fois dans le même tour | Premier possible pour 1 mana ; second interdit naturellement |
| TEST-005 | MOV-006/007 | Permuter deux alliés n'ayant pas bougé | Possible pour 1 mana ; deux droits consommés |
| TEST-006 | MOV-008/009 | Sort déplace créature après son mouvement naturel | Mouvement par effet encore possible |
| TEST-007 | DMG-003 | 8 ATQ sans Piétinement contre créature 2 PV | Créature détruite, 6 dégâts perdus |
| TEST-008 | DMG-004 | 8 ATQ avec Piétinement contre 3 PV ATQ + 2 PV DEF | 3 dégâts au héros sans protections |
| TEST-009 | EVT-003/004 | Deux effets simultanés des deux camps, puis réaction nouvelle | Actif avant inactif, ordre spatial ; réaction en fin de file |
| TEST-010 | EVT-005 | Source détruite alors que capacité en file | Capacité conservée |
| TEST-011 | TGT-002/004 | Cible détruite avant résolution d'un sort payé | Effet ciblé échoue, mana non remboursé |
| TEST-012 | VIC-003 | Deux héros à 3 PV ; effet simultané 5 dégâts chacun | Défaite joueur |
| TEST-013 | VIC-004 | Piétinement létal au héros avec effets de mort en attente | Combat terminé sans jouer la file |
| TEST-014 | PREV-002 | Piétinement contre créature survivant grâce à protection létale | Propagation stoppée |
| TEST-015 | PREV-005/006 | Armure 2, bouclier 3, PV 4, attaque 10 | Le moteur traite dans cet ordre : armure, bouclier, impact sur PV, puis protection létale si nécessaire ; issue finale de la protection à confirmer |
| TEST-016 | PREV-005/006 | PV 4, armure 2, bouclier 3 ; 7 dégâts entrants, aucune protection létale | 2 dégâts sur PV ; PV restants 2 ; bouclier consomme 3 |

| TEST-017 | PREV-007/008 | Deux protections létales valides ; un événement létal ; aucune autre protection | Exactement une protection consommée, la seconde conservée ; priorité temporaire avant permanente (Q24) ; départage dans la même classe à confirmer |
| TEST-018 | PREV-007/008 | Une protection a déjà été consommée lors d'un premier événement létal ; nouvel événement létal ultérieur | La protection restante peut être utilisée sur le second événement si ses conditions sont réunies ; détails de retour à 1 PV **À CONFIRMER** |

## Risques nécessitant spécification
- Cibles multiples et ciblage dynamique ; cas où aucune colonne non contestée n'a de place ; ripostes spéciales ; événements identiques ; cycle infini ; effets létaux simultanés et prévention.

## Tests ajoutés après Q34
| Test | Décision | Entrée | Résultat attendu |
|---|---|---|---|
| TEST-019 | Q35 | Début de tour | Croissance puis restauration, capacités puis pioche |
| TEST-020 | Q36 | Premier tour, deck 20 | Main 6 ; aucune pioche normale additionnelle |
| TEST-021 | Q37 | Deuxième tour, sans bonus | Une carte piochée |
| TEST-022 | Q38 | Main 7/7 et deck 1, pioche 1 | Carte va en défausse et deck −1 ; pas de fatigue |
| TEST-023 | Q39 | Héros débutant | Main maximum 7 |
| TEST-024 | Q40 | Main A–G dans ordre d'arrivée, maximum passe de 7 à 5 | G puis F défaussées |
| TEST-025 | Q41/Q210 | Deck vide, héros 2 PV, 2 tentatives | Perte directe 1 PV puis 2 PV si le héros survit ; dans cet exemple défaite à la deuxième tentative, bouclier ignoré |
| TEST-026 | Q42/Q210 | Deck 1, piocher 3 | Pioche 1 ; résoudre effets ; fatigue 1 PV ; résoudre effets ; fatigue 2 PV |
| TEST-027 | Q43 | Deck vide, défausse non vide, tentative pioche | Aucune réintégration automatique ; fatigue |
| TEST-028 | Q44 | Sort joué, créature détruite, carte défaussée | Même défausse, métadonnées de raison et origine distinctes |

## Tests ajoutés en v0.6 — décisions Q45–Q54

| Test | Décisions | Situation | Résultat attendu |
|---|---|---|---|
| TEST-029 | Q45 | Carte bannie ; tenter récupération/recyclage/résurrection ordinaire pendant combat | Carte inaccessible ; reste bannie |
| TEST-030 | Q45 | Terminer le combat avec carte de deck bannie | Carte préservée pour futurs combats ; non supprimée de la collection |
| TEST-031 | Q46 | Créature de base 3/4 morte avec bonus provisoire +2 ATQ ; résurrection +1 ATQ, +2 PV max | Revient 4 ATQ / 6 PV max et actuels, sans bonus ancien |
| TEST-032 | Q47 | Ennemi en C2 non contestée, case C2 légale, sort ressuscite en C4 | Placement C4 interdit ; résurrection C2 admissible |
| TEST-033 | Q48 | Créature avec `ON_SUMMON` et `ON_RESURRECT`, ressuscitée pendant son tour | Deux déclenchements ; elle ne peut attaquer normalement ce tour |
| TEST-034 | Q49 | Base 3 ATQ, résurrection +2 ATQ, capacité `ON_SUMMON` dépendant d'ATQ | 5 ATQ déjà appliqués au déclenchement ; valeur lue à la résolution selon Q56 ; dernier état connu si la source a quitté le plateau |
| TEST-035 | Q50 | File contient événement X ; résurrection déclenche S et R | Ordre de file X, S (`ON_SUMMON`), R (`ON_RESURRECT`) |
| TEST-036 | Q51 | Toutes cases occupées avant lancer sort de résurrection | Lancement interdit ; aucun mana dépensé |
| TEST-037 | Q51 | Sort légal au lancement ; case devient indisponible avant résolution | Tentative échoue, mana déjà dépensé non remboursé, aucun `ON_SUMMON` / `ON_RESURRECT` |
| TEST-038 | Q51 | Créature ciblée quitte défausse avant résolution | Pas de reciblage, effet ciblé échoue, mana non remboursé |
| TEST-039 | Q52 | 3 créatures choisies dans ordre A-B-C, seulement deux placements possibles successifs | A et B placées ; C reste en défausse ; aucun rollback des placements réussis |
| TEST-040 | Q53–Q54 | Main 7/7, récupérer 1 carte depuis défausse | Carte revient en défausse, aucune fatigue ; produire récupération puis défausse FIFO |
| TEST-041 | Q54 | Sort joué puis rejoint défausse | `ON_SPELL_USED`, pas `ON_DISCARD` |
| TEST-042 | Q54 | Créature meurt puis rejoint défausse | `ON_DEATH`, pas `ON_DISCARD` simplement à cause du changement de zone |
| TEST-043 | Q54 | Pioche carte au-delà du maximum de main | Carte va en défausse, `ON_DISCARD` généré ; aucun effet de fatigue si deck contient carte |
| TEST-044 | Q54 | Défausser une carte depuis main | `ON_DISCARD`, non `ON_SPELL_USED` |
| TEST-045 | Q54 | Recycler défausse→deck, puis bannir autre carte | `ON_CARD_RECYCLED`, puis `ON_CARD_BANISHED`, avec métadonnées distinctes |

**VALIDÉ Q55 (TEST-046)** : les capacités déclenchées par les résurrections attendent la fin du sort. Voir [resurrection](../01-combat/resurrection.md).

## Tests v0.7 — décisions Q55–Q64

| ID | Décision | État / action | Attendu |
|---|---|---|---|
| TEST-046 | Q55 | Sort ressuscite A, B, C ; A a `ON_SUMMON` qui détruit B | Toutes les tentatives sont terminées avant résolution des `ON_SUMMON` ; la destruction ne change pas les places pendant le sort |
| TEST-047 | Q56 | Créature ATQ 5 déclenche dégâts=ATQ ; ATQ tombe à 2 avant résolution sans quitter le plateau | La capacité inflige 2 dégâts avant protections |
| TEST-048 | Q56 | Source ATQ 5 puis subit −2 ATQ puis meurt avant sa capacité | La capacité utilise dernier état connu 3 ATQ |
| TEST-049 | Q57 | Carte `cardId=C1` meurt en instance I1, puis ressuscite | Nouvel `instanceId=I2` ; `cardId=C1` conservé ; bonus anciens effacés |
| TEST-050 | Q57 | I1 déclenche dégâts=ATQ 5, meurt, revient en I2 avec ATQ 3 | Capacité ancienne = 5, aucune lecture des stats I2 |
| TEST-051 | Q58 | Sort cible I1 ; I1 meurt ; `cardId` revient comme I2 | Cible invalide ; pas de dégâts sur I2, pas de remboursement |
| TEST-052 | Q59 | Sort « cible ennemie » ; I1 passe offense→défense avant résolution | Reste valide si autre condition inchangée |
| TEST-053 | Q59 | Sort « cible ennemie offensive » ; I1 passe offense→défense | Devient invalide ; pas de reciblage |
| TEST-054 | Q60 | Sort dégâts à A et B ; A quitte plateau ; B reste légale | Dégâts seulement sur B ; mana non remboursé |
| TEST-055 | Q60 | Sort cible trois ennemis ; deux invalides | Troisième résout normalement |
| TEST-056 | Q61 | Effet « dégâts cible ; soigne héros » ; cible invalide | Dégâts échouent, soin indépendant tenté |
| TEST-057 | Q61 | « Détruis allié ; si détruit ainsi, soigne » ; destruction impossible | Aucun soin |
| TEST-058 | Q61 | Permutation indivisible : une condition échoue | Aucune des deux positions ne change |
| TEST-059 | Q62 | Sort 3 dégâts tuant cible, puis soin +2, puis pioche ; `ON_DEATH` déclenché | `ON_DEATH` ajouté en file ; soin et pioche tentés avant son exécution |
| TEST-060 | Q62/Q63 | Le héros meurt de fatigue à l'étape pioche d'un sort ; `ON_DEATH` antérieur en file | Combat terminé immédiatement ; aucune capacité en file ne s'exécute |
| TEST-061 | Q63 | Deux héros à 3 PV ; une opération simultanée retire 5 à chacun | Un commit commun, puis défaite du joueur (pas victoire transitoire) |
| TEST-062 | Q63 | Prévention applicable empêche le létal d'un héros lors d'un commit simultané | Prévention calculée avant commit ; résultat victoire évalué après commit |
| TEST-063 | Q64 | Même cible : composantes simultanées compatibles 4 + 3, protection générique absorbant 3, PV initiaux 5 | 7 dégâts groupés, 3 absorbés, 4 PV perdus, survie 1 PV |
| TEST-064 | Q64 | Même cible : dégâts soumis à protections spécifiques distinctes | Ne pas fusionner les composantes qui nécessitent traitements différents ; calculs spécifiques **À CONFIRMER** si mécanique non spécifiée |

**Statut** : scénarios rédigés pour implémentation future ; non exécutés. TEST-064 valide seulement la séparation des composantes incompatibles, pas une formule de résistance élémentaire.


## Tests de conformité supplémentaires — v0.8 (Q65–Q74)

| ID | Préconditions et action | Attendu | Décisions |
|---|---|---|---|
| T-065-01 | Une cible sans protection subit simultanément 3+2 dégâts de deux sources | Perte 5 PV ; exactement **un** `ON_DAMAGE_TAKEN` | Q65 |
| T-065-02 | Même opération entièrement absorbée | Aucun `ON_DAMAGE_TAKEN` ni `ON_DAMAGE_DEALT` | Q65–Q67 |
| T-066-01 | Deux sources de dégâts simultanés causent une perte réelle de PV | Exactement un `ON_DAMAGE_DEALT` par source contributrice et par cible | Q66 |
| T-067-01 | Sources 3+2 ; bouclier 4 ; perte 1 PV | Les **deux** sources déclenchent, une seule fois la cible ; pas de duplication du PV perdu | Q67 |
| T-068-01 | Sources 3+2 ; perte 1 PV ; attribution entière | Quantum `[1,0]`, somme = 1 ; source créditée 0 déclenche tout de même | Q68–Q69 |
| T-069-01 | Sources 5+3+2 ; perte effective 4 PV | Parts `[2,1.2,0.8]`, attribution `[2,1,1]` | Q69 |
| T-069-02 | Sources de contribution égale, points résiduels limités | Départage stable (ordre des sources, identifiant), résultat identique à chaque exécution | Q69 |
| T-070-01 | Source avec vol de vie, quantum 2, héros blessé | Soin de 2 PV **après** effet composé, limité au max du héros | Q70 |
| T-070-02 | Source avec vol de vie, déclenchement collectif mais quantum 0 | Capacité mise en file ; aucun PV soigné | Q67–Q70 |
| T-070-03 | Héros atteint 0 PV pendant opération malgré vol de vie encore en file | Défaite immédiate ; soin jamais appliqué | Q15/Q63/Q70 |
| T-071-01 | 9 dégâts ; armure 2, bouclier 3, PV 8 | Un `ON_ARMOR_ABSORBED(2)`, un `ON_SHIELD_ABSORBED(3)`, un `ON_DAMAGE_TAKEN(4)` | Q71 |
| T-071-02 | Plusieurs sources épuisent des couches de bouclier | Un seul `ON_SHIELD_ABSORBED` par cible/opération ; quantité totale correcte | Q71 |
| T-072-01 | Une cible subit armure, bouclier, perte de PV et prévention létale | Ordre de mise en file armure → bouclier → dégâts subis → prévention létale ; aucun callback intercalé | Q72 |
| T-073-01 | Protection temporaire expire ce tour, autre temporaire expire dans 3 tours, une permanente | Consommer celle qui expire ce tour, conserver les autres | Q73 |
| T-073-02 | Deux temporaires expirent au même instant, dates d'application différentes | Consommer la plus ancienne ; égalité par ID stable | Q73 |
| T-073-03 | Deux protections permanentes | Consommer plus ancienne, puis ID si nécessaire | Q73 |
| T-074-01 | Créature passe de 3 PV à 1 PV par prévention « reste à 1 » | `ON_DAMAGE_TAKEN(2)` + `ON_LETHAL_PREVENTED` ; aucun `ON_DEATH` | Q74 |
| T-074-02 | Créature 3/6, prévention restaure à 6/6 pendant l'opération | Aucun `ON_DAMAGE_TAKEN`, aucun `ON_DAMAGE_DEALT` positif ; `ON_LETHAL_PREVENTED` | Q74 |
| T-074-03 | Prévention consommée avec effet secondaire déclenché | `ON_LETHAL_PREVENTED` mis en file avant effet secondaire ; la prévention intervient avant contrôle de victoire | Q74 |
| T-074-04 | Plusieurs cibles simultanées, chacune avec absorptions | Evénements par cible suivant ordre Q72 ; priorités inter-cibles Q13 et FIFO respectées | Q13/Q71–Q74 |

Ces tests constituent des **cas d'acceptation spécifiés**, pas des tests logiciels déjà exécutés.

## Tests d’acceptation supplémentaires — v0.9 (Q75–Q84)

| ID | Décision | Situation / action | Attendu |
|---|---|---|---|
| T-075-01 | Q75 | Unité 4/6 reçoit soin +5 | 6/6 ; soin effectif 2 ; surplus 3 perdu |
| T-075-02 | Q75 | Héros 10/10 reçoit soin +3 | PV 10/10 ; soin effectif 0 ; surplus 3 |
| T-076-01 | Q76 | Unité 4/6 reçoit soin +5 | Un `ON_HEAL(2)` mis en file, pas `ON_HEAL(5)` |
| T-076-02 | Q76 | Unité 6/6 reçoit soin +3 | Aucun `ON_HEAL` |
| T-077-01 | Q77 | Cible 4/10, soins simultanés A=4, B=5 | 10/10 ; soin effectif 6 ; un `ON_HEAL(6)` ; parts A=3, B=3 |
| T-077-02 | Q77 | Cible manque 1 PV ; soins A=3, B=2 | Attribution `[1,0]` ; somme=1 ; un `ON_HEAL(1)` |
| T-077-03 | Q77 | Cible pleine vie ; 2 sources guérissent simultanément | Aucun `ON_HEAL`, aucun PV crédité |
| T-078-01 | Q78 | Unité 4/6 reçoit +3 PV maximum | 7/9 ; aucun `ON_HEAL` |
| T-078-02 | Q78 | Bonus +3 PV max expire sur unité 7/9 | 4/6 ; ni `ON_DAMAGE_TAKEN` ni `ON_HEAL` |
| T-079-01 | Q79 | Unité 2/6 perd bonus +3, protection « reste à 1 » | Résultat théorique −1/3, puis 1/3 ; `ON_LETHAL_PREVENTED`, pas `ON_DEATH` ni `ON_DAMAGE_TAKEN` |
| T-079-02 | Q79 | Même état sans protection | Mort ; `ON_DEATH` ; aucun événement de dégâts |
| T-080-01 | Q80 | Unité 3/9, deux bonus +3 et +2 PV max expirent ensemble ; deux protections létales | Retrait atomique −5/−5, un seul événement létal potentiel, au plus une protection consommée |
| T-080-02 | Q80 | Bonus +3 et malus −2 PV max expirent ensemble | Calcul net de retrait (−1 max et −1 actuel) sans contrôles létaux intermédiaires |
| T-081-01 | Q81 | Effet « jusqu'à fin du tour » appliqué pendant le tour adverse | Expire à la fin de **ce tour adverse**, pas au prochain tour du créateur |
| T-082-01 | Q82 | +3 ATQ « jusqu'à fin du tour » sur une unité qui attaque automatiquement | Bonus actif durant attaque et réactions, expire après |
| T-082-02 | Q82 | Effet « jusqu'au début de ton prochain tour » | Expire avant croissance/restauration mana et capacités de début de tour |
| T-083-01 | Q83 | Effet « pendant 2 tours » appliqué par le joueur pendant T1 ennemi | T2 joueur = 1/2 ; T4 joueur = 2/2 ; expire fin T4 |
| T-083-02 | Q83 | Effet « pendant 2 tours » appliqué pendant T1 joueur | T1 joueur = 1/2 ; T3 joueur = 2/2 ; expire fin T3 |
| T-084-01 | Q84 | 2 bonus + 1 malus expirent ensemble sur une cible | Une opération atomique ; trois `ON_EFFECT_EXPIRED` après commit ; capacité « lorsqu'un bonus expire » déclenchée deux fois |
| T-084-02 | Q84 | Trois effets sur même cible appliqués à des instants distincts, expirant ensemble | Événements dans l'ordre d'application, puis ID technique ; pas de callback entre retraits |
| T-084-03 | Q84 | Expiration simultanée cause défaite immédiate du héros | État commité, défaite immédiate ; événements en attente non exécutés |

**Statut :** cas rédigés et vérifiables par une implémentation ultérieure ; tests de moteur non exécutés. Les priorités entre familles d'événements issus de la même expiration restent ouvertes (voir [module](../01-combat/temporary-effects.md)).

## Scénarios ajoutés v1.0 — Q85 à Q94

| ID | Règles | État initial et action | Résultat attendu |
|---|---|---|---|
| T-085-01 | Q85 | Deux bonus expirent et créature meurt | `ON_DEATH` de la créature est en file avant ses deux `ON_EFFECT_EXPIRED` |
| T-085-02 | Q85 | Une prévention sauve créature pendant expiration | `ON_LETHAL_PREVENTED` précède `ON_EFFECT_EXPIRED` pour la même cible |
| T-086-01 | Q86 | Deux bonus expirent et tuent la source qui possède « 2 dégâts par bonus expiré » | Deux déclenchements de 2 dégâts sont produits depuis l’instantané, s’ils peuvent se résoudre |
| T-086-02 | Q86 | Source meurt pendant expiration, capacité déjà déclenchée | Événement non annulé ; utilise instance originale/dernier état connu |
| T-087-01 | Q87 | Effet confère capacité « réagit à expiration bonus », puis expire lui-même | Capacité se déclenche sur sa propre expiration |
| T-087-02 | Q87 | Deux effets confèrent des capacités identiques et expirent ensemble | Chaque capacité éligible conserve son identité, reçoit les expirations correspondantes |
| T-088-01 | Q88 | Sort S donne capacité dégâts à créature I1 | Source de gameplay I1 ; S reste origine historique |
| T-088-02 | Q88 | Artefact confère capacité à créature puis disparaît | La capacité déjà déclenchée reste attribuée à la créature, pas à l’artefact |
| T-089-01 | Q89 | I1 avec vol de vie déclenche dégâts, meurt puis renaît I2 | Source et vol de vie de I1 conservés ; I2 ne remplace pas I1 |
| T-090-01 | Q90 | I1 déclenche « dégâts=ATQ » à 3, reçoit +2 ATQ avant résolution | 5 dégâts avant protections si I1 encore active |
| T-090-02 | Q90 | I1 déclenche à ATQ 3, reçoit +2, quitte plateau, renaît I2 à ATQ 9 | 5 dégâts depuis dernier état connu de I1, jamais 9 de I2 |
| T-091-01 | Q91 | I1 acquiert vol de vie après déclenchement avant ses 4 dégâts | `ON_DAMAGE_DEALT` retient vol de vie, soin différé de 4 si attribués |
| T-091-02 | Q91 | I1 perd vol de vie avant dégâts, ou le gagne après dégâts | Pas de soin dans les deux cas si absent au moment des dégâts |
| T-091-03 | Q91 | I1 avec vol de vie inflige dégâts, perd vol de vie avant réaction | Vol de vie enregistré reste applicable |
| T-092-01 | Q92 | Propriétaire ennemi, contrôleur joueur ; 4 PV infligés avec vol de vie | Héros joueur soigné de 4, pas héros ennemi |
| T-092-02 | Q92 | Contrôle retourne à ennemi après dégâts mais avant soin | Bénéficiaire fixé = joueur |
| T-092-03 | Q92 | Deux sources A/B avec contrôle distinct et attribution respective 2/3 | Chaque soin bénéficie au contrôleur de sa source lors de dégâts, montants 2/3 |
| T-093-01 | Q93 | Capacité cible héros joueur sous contrôle ennemi ; contrôleur devient joueur | Cible initiale reste héros joueur ; si légal dégâts appliqués, vol de vie joueur |
| T-093-02 | Q93 | Cible unité ennemie devient alliée avant résolution ; contrainte interdit allié | Effet ciblé échoue, sans retarget ni remboursement |
| T-094-01 | Q94 | I1 à 5/8, +2 ATQ et protection, est contrôlée par nouveau camp | `instanceId` I1 conservé, caractéristiques/protections conservées, seul contrôleur change |
| T-094-02 | Q94 | I1 a capacité en FIFO et effet temporaire appliqué par adversaire ; contrôle change | Même instance, capacité en FIFO conservée, durée dépend du camp ayant appliqué effet |
| T-094-03 | Q94 | Prise de contrôle sans autre effet de zone | Aucun `ON_SUMMON`, `ON_DEATH` ni `ON_RESURRECT` généré |

**État** : cas spécifiés mais non exécutés dans un moteur. Le placement au changement de contrôleur est couvert par les tests v1.1 (Q95–Q104). Voir [sources et contrôle](../01-combat/source-control.md).

## Scénarios ajoutés v1.1 — Q95 à Q104

| ID | Précondition / action | Résultat attendu | Décision |
|---|---|---|---|
| T-095-01 | Prise de contrôle avec colonnes ennemies non contestées | Placement uniquement en cases libres légales de ces colonnes ; choix ligne autorisée ; instance et PV conservés. | Q095 |
| T-095-02 | Prise de contrôle réussie | Aucun ON_SUMMON ni ON_RESURRECT ; même instanceId. | Q095 |
| T-096-01 | Nouveau camp sans aucun emplacement légal au lancement | Sort illégal ; pas de dépense de mana. | Q096 |
| T-096-02 | Case légale à l’annonce, aucune à la résolution | Transfert échoue ; mana non remboursé, ancien contrôle/position conservés. | Q096 |
| T-097-01 | Contrôle temporaire expire, destination dispose de place | Retour légal choisi par camp destination ; même instance et états, pas ON_SUMMON. | Q097 |
| T-097-02 | Contrôle expire, camp destination 12/12 sans départ | Mort de placement ; carte défausse de son propriétaire ; ON_DEATH. | Q097 |
| T-098-01 | Créature protégée, retour impossible | Protection létale non consommée ; ni ON_LETHAL_PREVENTED ni ON_DAMAGE_TAKEN. | Q098 |
| T-098-02 | Effet explicite remplace sortie du plateau pour manque de place | Remplacement consulté avant mort et appliqué selon son texte ; pas de fausse prévention générique. | Q098 |
| T-099-01 | Effets A joueur ancien, B ennemi récent ; B expire seul | Joueur redevient contrôleur si A actif ; instance préservée. | Q099 |
| T-099-02 | Plus aucun effet de contrôle actif | ownerId détermine controllerId final. | Q099 |
| T-100-01 | Deux effets expirent ; troisième conserve le même contrôleur | Aucun transfert, deux ON_EFFECT_EXPIRED, zéro ON_CONTROL_CHANGED. | Q100 |
| T-100-02 | Plusieurs effets expirent au même instant avec contrôleurs intermédiaires différents | Un seul contrôleur final et au plus un transfert physique. | Q100 |
| T-101-01 | Deux retours obligatoires, une case libre | Destination choisit une créature ; autre meurt de placement ; un ON_DEATH. | Q101 |
| T-101-02 | IA avec même état et même seed stratégique | Même choix de placement et même créature survivante à chaque exécution. | Q101 |
| T-102-01 | Chaque camp 12/12, un départ dans chaque sens | Réservation des départs ouvre une case de chaque côté ; deux transferts réussissent. | Q102 |
| T-102-02 | Deux retours croisés + priorités d’invocation | Réservation des cases puis choix respecte colonnes non contestées sur état préparé. | Q102 |
| T-103-01 | Deux camps font des choix dans un même commit | Camp actif décide d’abord ; adversaire connaît le choix ; aucune capacité intermédiaire. | Q103 |
| T-103-02 | L’IA est camp actif et le joueur non actif | L’IA prend un choix déterministe puis joueur choisit avec visibilité, commit commun. | Q103 |
| T-104-01 | Nouveau contrôle appliqué et transfert réussi | Exactement un ON_CONTROL_CHANGED contenant anciens/nouveaux camps et cases. | Q104 |
| T-104-02 | Un contrôle expire mais contrôleur final inchangé | Zéro ON_CONTROL_CHANGED ; ON_EFFECT_EXPIRED émis. | Q104 |
| T-104-03 | Retour impossible et mort de placement | ON_DEATH puis ON_EFFECT_EXPIRED ; aucun ON_CONTROL_CHANGED. | Q104 |
| T-104-04 | Deux contrôles expirent ensemble et un transfert réel unique | Un ON_CONTROL_CHANGED et deux ON_EFFECT_EXPIRED ; ordre contrôle puis expirations. | Q104 |
| T-104-05 | Opération provoque mort par PV et expirations sur même cible | ON_DEATH ou ON_LETHAL_PREVENTED avant événements contrôle/expiration pertinents. | Q104 |
| T-104-06 | Héros atteint zéro PV au commit du transfert composé | Défaite immédiate ; aucune réaction FIFO ne renverse le résultat. | Q104 |

**Statut** : scénarios documentés, non exécutés sur un moteur. Voir [transferts de contrôle](../01-combat/control-transfers.md).

## v1.2 — Tests d’acceptation VALIDÉS Q105–Q114 (spécifiés, **non exécutés**)

Source normative : [capacités de tour et protection anti-boucle](../01-combat/turn-control-and-loop-safety.md).

| ID | Précondition et action | Attendu | Décision |
|---|---|---|---|
| T-105-01 | Contrôle réussi d’une créature déjà active durant le tour joueur | Même instance, aucune invocation ; attaque automatique de ce tour interdite, mouvement/capacités légaux. | Q105 |
| T-105-02 | Une créature transférée possède « ignore le mal d’invocation » | Attaque possible si position offensive et autres conditions satisfaites. | Q105 |
| T-105-03 | Contrôle tenté mais aucun emplacement légal | Aucun transfert, aucune nouvelle restriction d’attaque provenant du transfert raté. | Q105 |
| T-106-01 | Transfert de l’ennemi vers le joueur pendant le tour ennemi T1 | Premier tour joueur T2 : attaque interdite ; second tour joueur T4 : attaque permise si autres critères. | Q106 |
| T-106-02 | Retour au contrôleur d’origine après expiration du contrôle temporaire | Le premier tour personnel du contrôleur revenu est à nouveau bloqué. | Q106 |
| T-106-03 | Deux transferts effectifs successifs vers des camps différents | Chaque nouveau contrôleur reçoit sa propre restriction, sans réutiliser une ancienne autorisation. | Q106 |
| T-107-01 | Prise de contrôle après événement ON_TURN_START mais avant ON_TURN_END | Aucune capacité de début de tour rétroactive ; capacité de fin de tour éligible sous nouveau contrôleur. | Q107 |
| T-107-02 | Capacité ON_TURN_END en FIFO puis la source change de contrôleur | Source, cibles et références de camp figées au déclenchement ; résolution selon Q89–Q93. | Q107 |
| T-107-03 | Créature sous mal d’invocation avec capacité de fin de tour | Capacité ON_TURN_END se déclenche normalement si conditions réunies. | Q107 |
| T-108-01 | Créature ATQ base 3, buff +3 jusqu’à fin de tour, capacité ON_TURN_END = dégâts ATQ | À la résolution ON_TURN_END, attaque automatique déjà passée ; valeur ATQ 6 avant protections, buff expire après. | Q108 |
| T-108-02 | Réaction à ON_TURN_END crée une autre réaction | Toutes les réactions de ON_TURN_END finissent avant l’expiration globale de fin de tour. | Q108 |
| T-108-03 | Une capacité ON_TURN_END tue le héros | Combat terminé immédiatement, aucune expiration ultérieure n’est exécutée. | Q108 |
| T-109-01 | ON_TURN_END crée +2 ATQ jusqu’à fin de ce tour | Le bonus est appliqué puis expire pendant l’étape d’expiration qui suit, génère ON_EFFECT_EXPIRED. | Q109 |
| T-109-02 | ON_TURN_END prolonge effet E42 à échéance plus lointaine | E42 conserve instance, charges et ancienneté ; aucun ON_EFFECT_EXPIRED avant nouvelle échéance. | Q109 |
| T-109-03 | Bonus de fin de tour créé très tard | Aucune durée minimale d’un tour implicite ; texte de carte respecté. | Q109 |
| T-110-01 | FIFO A puis B ; A crée effet dont échéance déjà passée | Après A : création, expiration atomique distincte ; C = réaction en queue ; B résolue avant C. | Q110 |
| T-110-02 | Effet immédiatement périmé déclenche plusieurs réactions | Un ON_EFFECT_EXPIRED par effet ; réactions ordonnées FIFO après événements préexistants. | Q110 |
| T-110-03 | Création d’un effet déjà périmé et héros atteint 0 PV dans l’opération | Victoire/défaite immédiate au contrôle atomique, pas de réaction ultérieure qui inverse le résultat. | Q110 |
| T-111-01 | Capacité ON_EFFECT_EXPIRED recrée sans fin le même bonus périmé | Répétition non progressive confirmée ; seul prochain déclenchement responsable supprimé ; autres événements préservés. | Q111 |
| T-111-02 | Cinq effets distincts expirent et déclenchent la même capacité | Cinq capacités restent autorisées : répétition ne suffit pas à qualifier une boucle. | Q111 |
| T-111-03 | Boucle stoppée alors qu’un événement de soin indépendant attend | Le soin est conservé, aucune opération déjà validée annulée, interruption tracée. | Q111 |
| T-112-01 | Effets identiques successifs portent E42, E43, E44 sans différence fonctionnelle | Signature normalise les identifiants purement techniques et détecte répétition identique. | Q112 |
| T-112-02 | Même plateau mais FIFO A→B puis B→A | Signatures distinctes : ordre FIFO significatif. | Q112 |
| T-112-03 | À chaque tour de boucle la créature perd 1 PV | Signatures différentes tant que les PV progressent ; pas de faux cycle sur seul type de capacité. | Q112 |
| T-112-04 | Effets identiques mais ancienneté différente décide la protection consommée | Ancienneté préservée dans la signature ; pas de fusion abusive. | Q112 |
| T-113-01 | Chaîne augmente bouclier indéfiniment sans état identique | Budget configurable atteint ; branche responsable bloquée, pas de rollback ni défaite technique. | Q113 |
| T-113-02 | Budget atteint avec une branche indépendante | La branche indépendante peut continuer, sous ses propres contrôles de sécurité. | Q113 |
| T-113-03 | Interruption d’une branche par budget | Journal conserve chaîne, branche, compteur, limite, cause et état ; même comportement pour IA/joueur. | Q113 |
| T-114-01 | FIFO = A.27 issu branche bloquée, puis B.1 soin indépendant | A.27 et B.1 restent dans cet ordre et résolvent leurs effets directs normaux. | Q114 |
| T-114-02 | A.27 conservé tente d’insérer A.28 nouveau descendant branche bloquée | A.28 refusé avant insertion, motif journalisé ; les effets directs de A.27 restent validés. | Q114 |
| T-114-03 | B.1 indépendant déclenche un nouvel événement B.2 | B.2 peut être ajouté normalement sous protection de son propre budget/anti-cycle. | Q114 |
| T-114-04 | Branche bloquée avait déjà enregistré trois événements descendants | Les trois événements déjà enregistrés ne sont pas purgés ; ordre FIFO initial préservé. | Q114 |


## Consolidation v1.3 — Q115–Q124 (scénarios documentés, non exécutés)

Les scénarios ci-dessous sont des critères d’acceptation à automatiser après implémentation du moteur. Références : [budgets causaux et rejeu](causal-budgets-and-replay.md), [FIFO](../01-combat/event-queue.md), [anti-cycles Q105–Q114](../01-combat/turn-control-and-loop-safety.md). Les seuils numériques sont des **fixtures de test**, pas des valeurs d’équilibrage adoptées.

| ID | Mise en situation | Résultat attendu | Décision |
|---|---|---|---|
| T-115-01 | Deux événements parentaux A/B déclenchent une unique admission sémantique C | C entre une fois en FIFO ; tous parents/branches conservés, une seule résolution. | Q115 |
| T-115-02 | Branche A bloquée ; B autorisée contribue à C | La convergence ne réactive pas A ; descendants seulement pour B autorisée. | Q115 |
| T-115-03 | Deux expirations distinctes Q84 déclenchent chacune la même capacité | Deux déclenchements séparés demeurent si la sémantique prévoit deux événements, sans fusion artificielle. | Q115 |
| T-115-04 | Joueur et IA exécutent mêmes causes et même état | Même arbre causal, mêmes admissions, mêmes interruptions. | Q115 |
| T-116-01 | Branche A atteint plafond individuel avec B encore libre | A cesse d’engendrer de nouveaux descendants ; B reste autorisée si plafonds supérieurs disponibles. | Q116 |
| T-116-02 | Branches individuellement sous leur plafond mais chaîne globale épuisée | Toute nouvelle admission descendante de cette chaîne est refusée ; réservations existantes préservées. | Q116 |
| T-116-03 | Plusieurs chaînes créées par une opération atteignent plafond supérieur | Nouvelles admissions de cette origine refusées sans annulation des effets déjà validés. | Q116 |
| T-116-04 | Rejeu sur machine différente avec mêmes règles et budgets versionnés | Même ordre et mêmes décisions, indépendamment du temps CPU. | Q116 |
| T-117-01 | C unique avec deux branches A/B autorisées | Une seule exécution ; +1 branche A, +1 B, +1 chaîne, +1 opération. | Q117 |
| T-117-02 | C unique avec trois causes dont deux de branche A | Une seule imputation +1 pour A, non +2, et +1 pour chaque autre branche distincte autorisée. | Q117 |
| T-117-03 | C atteint exactement plafond A | C autorisée si réservation préalable valide ; nouveaux descendants imputables à A bloqués ensuite. | Q117 |
| T-117-04 | Une des deux branches est déjà bloquée à nouvelle admission C | Aucun coût/nouveau descendant attribuable à branche bloquée ; seul apport autorisé suit les règles de causalité. | Q117 |
| T-118-01 | 998 consommés sur limite 1000, trois admissions successives A,B,C | A et B réservent chacune 1 ; C refusée sans entrée FIFO, ordre canonique conservé. | Q118 |
| T-118-02 | 997 consommés, 3 réservés ; plafond atteint avant résolution | Les trois capacités réservées se résolvent en FIFO ; zéro dépassement du plafond. | Q118 |
| T-118-03 | Une admission requiert branche disponible mais chaîne globale pleine | Aucune réservation partielle : refus atomique et compteurs inchangés. | Q118 |
| T-118-04 | Événement de jeu survient mais capacité réactive est refusée pour budget | Événement source reste dans le journal ; seule la capacité non admise est absente de FIFO. | Q118 |
| T-119-01 | C multicausale réservée A/B puis branche A bloquée avant résolution | Réservations A et B inchangées ; C se résout ; aucun nouveau descendant de A. | Q119 |
| T-119-02 | Capacité réservée A/B/chaîne/opération explicitement annulée avant résolution | Libération atomique des quatre crédits réservés ; aucun crédit consommé retiré. | Q119 |
| T-119-03 | Annulation libère crédit sur branche déjà interrompue | Compteur disponible augmente mais branche demeure bloquée. | Q119 |
| T-119-04 | Même reservationId reçoit une deuxième demande de libération | Deuxième transition refusée comme anomalie, aucun compteur négatif/double crédit. | Q119 |
| T-120-01 | C refusée à budget plein ; B libère ensuite 1 | C reste refusée, aucune file d’attente secondaire. | Q120 |
| T-120-02 | Après libération, nouveau déclenchement D sous branche autorisée | D peut réserver le crédit nouvellement disponible selon FIFO. | Q120 |
| T-120-03 | Branche bloquée récupère des crédits et génère nouveau déclenchement | Déclenchement refusé malgré crédit disponible. | Q120 |
| T-120-04 | Admission refusée puis revue du journal | Aucune mutation des compteurs au refus, motif conservé. | Q120 |
| T-121-01 | Exécution avec deux capacités causales, réservation, interruption, résolution | Journal ordonné enregistre décisions intermédiaires et causes, en plus du résultat. | Q121 |
| T-121-02 | Snapshot périodique puis reprise | Reconstruction avec version des règles, budgets, choix et état RNG identiques. | Q121 |
| T-121-03 | Combat avec choix de joueur et décision IA | Choix explicitement journalisés en ordre canonique. | Q121 |
| T-121-04 | Combat avec tirage aléatoire | Graine, version/état RNG et tirage effectif permettent reproduction du résultat. | Q121 |
| T-122-01 | Deux replays identiques après cinq commits atomiques | Empreintes canoniques identiques après chacun des cinq commits. | Q122 |
| T-122-02 | Écart introduit après troisième commit | Arrêt immédiat au troisième point ; diagnostic identifie commit et différences. | Q122 |
| T-122-03 | Signature anti-cycle Q112 normalise des IDs mais identités différant en rejeu | L’empreinte exacte signale divergence si identité pertinente diffère, sans confusion des deux signatures. | Q122 |
| T-122-04 | FIFO/PRNG diffèrent mais PV finaux identiques | Empreintes différentes : identité d’état futur non garantie malgré PV identiques. | Q122 |
| T-123-01 | FIFO A terminée, B et C réservées ; création snapshot | Snapshot valide avec FIFO B,C et budgets, reprise commence par B sans réexécuter A. | Q123 |
| T-123-02 | Demande snapshot au milieu d’un commit atomique | Snapshot différé au point stable suivant ; jamais de demi-commit sérialisé. | Q123 |
| T-123-03 | Charger snapshot ayant état RNG/counters/FIFO complets | Reprise produit même empreinte après prochaine opération que exécution continue. | Q123 |
| T-123-04 | Choix encore en attente au point de sauvegarde | Choix représenté explicitement et restaurable, ou sauvegarde différée jusqu’à finalisation. | Q123 |
| T-124-01 | Combat commencé avec règles R1 puis installation de R2 | Combat sauvegardé reprend sous R1, cartes/configuration/PRNG liés à R1. | Q124 |
| T-124-02 | Rejeu historique R1 alors que R2 est version par défaut | Rejeu R1 reproduit exactement les empreintes historiques. | Q124 |
| T-124-03 | Dépendance R1 indisponible au chargement | Incompatibilité signalée ; pas de migration silencieuse en R2. | Q124 |
| T-124-04 | Progression RPG entre combats R1 et R2 | Migration RPG possible hors combat ; prochain combat utilise R2, combat R1 inchangé. | Q124 |


## Consolidation v1.4 — Q125–Q134 : scénarios UI et compatibilité (documentés, non exécutés)

Références : [direction artistique et inspection](../02-art-direction/card-and-board-ui.md), [versions historiques](causal-budgets-and-replay.md), [statistiques PV](../01-combat/temporary-effects.md). Tests UI vérifiables par maquettes et tests d’interface ; règles de combat exécutées uniquement après développement du moteur.

| ID | Mise en situation | Critère d’acceptation | Décision |
|---|---|---|---|
| T-125-01 | Règles R1 restent officiellement supportées après sortie R2 | R1 disponible/chargeable à la demande ; combat/replay original reproductible. | Q125 |
| T-125-02 | Version R1 archivée dans dépôt historique compatible | Chargement R1 utilise le manifeste R1 et non les règles R2. | Q125 |
| T-125-03 | Version R1 manquante malgré sauvegarde R1 | Incompatibilité explicite, aucune substitution R2. | Q125 |
| T-125-04 | Mise à jour purement graphique avec règles R1 | Même empreinte fonctionnelle et mêmes résultats. | Q125 |
| T-126-01 | Prototype de carte fantasy avec portrait détaillé | Illustration riche et colorée, texte et stats faciles à lire. | Q126 |
| T-126-02 | Collection de cartes avec créatures et sorts | Direction fantasy cohérente, familles reconnaissables. | Q126 |
| T-126-03 | Revue des sources visuelles | Pas de réutilisation d’assets ou cadres protégés Hearthstone/Magic. | Q126 |
| T-126-04 | Affichage dense du plateau | Lisibilité tactique conservée malgré style illustré. | Q126 |
| T-127-01 | Carte en main puis même créature posée | Carte complète en main ; jeton compact sur plateau. | Q127 |
| T-127-02 | Survol du jeton | Tooltip de synthèse des stats et états. | Q127 |
| T-127-03 | Clic sur jeton | Vue de la carte complète et état de combat. | Q127 |
| T-127-04 | Plateau 24 créatures | Ni chevauchement de cartes complètes ni blocage de lecture. | Q127 |
| T-128-01 | Créature ordinaire sans état | Portrait, ATQ finale et PV actuels visibles. | Q128 |
| T-128-02 | Créature avec effet critique | Icône d’état pertinent ajoutée sans modifier les chiffres. | Q128 |
| T-128-03 | Créature avec capacité secondaire seulement | Jeton reste sobre ; capacité accessible au survol. | Q128 |
| T-128-04 | État absent du jeton | État présent dans le tooltip et l’inspection. | Q128 |
| T-129-01 | Jeton d’une créature alliée | Médaillon rond/ovale et socle tactique visibles. | Q129 |
| T-129-02 | Jeton adverse de même type | Camp discernable sans s’appuyer uniquement sur couleur. | Q129 |
| T-129-03 | Colonne offense/défense remplie | Portrait et socle n’empêchent pas lecture de la position. | Q129 |
| T-129-04 | Affichage avec 24 unités | Forme compacte et emplacements restent reconnaissables. | Q129 |
| T-130-01 | Jeton ATQ 5 PV 6 | 5 en bas à gauche, 6 en bas à droite. | Q130 |
| T-130-02 | Créature avec deux états | Icônes sous le portrait et pas sur les valeurs. | Q130 |
| T-130-03 | PV réduits par opération atomique | Valeur à droite synchronisée après commit. | Q130 |
| T-130-04 | Clic du jeton | Structure de la carte originale distincte du rendu compact. | Q130 |
| T-131-01 | ATQ de base 3, bonus +2 | ATQ effective 5, signe positif visible en plus de la couleur. | Q131 |
| T-131-02 | ATQ de base 5, malus -2 | ATQ effective 3, signe négatif sans seul code couleur. | Q131 |
| T-131-03 | 6 PV actuels, 8 PV max | Jeton montre 6, tooltip/inspection montrent 6/8. | Q131 |
| T-131-04 | 2 armures et 1 bouclier | Symboles distincts et quantités identifiables, aucune DEF inventée. | Q131 |
| T-132-01 | Deux effets actifs | Deux icônes, pas de +N. | Q132 |
| T-132-02 | Six états actifs distincts | Trois icônes prioritaires et +3. | Q132 |
| T-132-03 | Clic jeton avec six états | Vue complète présente les six, y compris ceux masqués. | Q132 |
| T-132-04 | Changement de priorité après effet expiré | Trio recalculé selon règles stables, +N exact. | Q132 |
| T-133-01 | Carte imprimée 3 ATQ/8 PV, bonus +2 | Carte d’origine reste 3/8 ; panneau explique +2 ATQ. | Q133 |
| T-133-02 | Capacité initiale neutralisée | Texte imprimé intact ; panneau explique la neutralisation. | Q133 |
| T-133-03 | Aucun effet ni différence à l’original | Carte seule possible, aucun panneau vide imposé. | Q133 |
| T-133-04 | Carte avec capacité temporaire | Capacité temporaire présentée hors recto et avec durée/source. | Q133 |
| T-134-01 | Base 3 ATQ, +4, -2 simultanés | **ATQ FINALE 5** visible en tête de panneau et détail 3+4-2. | Q134 |
| T-134-02 | 6/8 PV et +2 PV max temporaire | **PV actuels/max effectifs** reflètent Q78 ; blessure conservée, aucune guérison fictive. | Q134 |
| T-134-03 | Armure 2 et bouclier 1 | Valeurs défensives distinctes visibles ; pas de DEF unique fabriquée. | Q134 |
| T-134-04 | Créature avec sept buffs/debuffs et contrôle temporaire | Tous les effets actifs, sources, durées et restrictions accessibles, panneau défilable. | Q134 |


## Consolidation v1.5 — Q135–Q144 : tests de tooltip, durée et feedbacks (spécifiés, non exécutés)

Références : [spécification UI/VFX Q135–Q144](../02-art-direction/tooltips-durations-and-vfx.md), [cartes et inspections Q126–Q134](../02-art-direction/card-and-board-ui.md), [règles d’effets](../01-combat/temporary-effects.md), [règles de la FIFO](../01-combat/event-queue.md). Les objectifs de 3–5 secondes sont **indicatifs**, à mesurer sur prototypes et plateformes cibles ; les critères logiques demeurent stricts.

| Test | Mise en situation | Critère d’acceptation | Décision |
|---|---|---|---|
| T-135-01 | ATQ 5 +2 et ATQ 5 −2 | 7 vert/flèche haute et 3 rouge/flèche basse, lisibles sans couleur | Q135 |
| T-135-02 | 6/8 PV sans modificateur max | Blessure visible distincte du malus PV max | Q135 |
| T-135-03 | Bonus +3 et malus −3 | Valeur finale neutre, calcul des deux effets conservé dans panneau | Q135 |
| T-135-04 | Source en dehors du plateau | Actualisation des valeurs finales après commit sans changer la carte imprimée | Q135 |
| T-136-01 | Survol avec six effets | Les six apparaissent sous forme condensée, pas seulement les trois icônes | Q136 |
| T-136-02 | Créature à 6 PV sur 8 max | Tooltip 6/8, jeton 6 | Q136 |
| T-136-03 | Effet très long / plusieurs textes de capacités | Tooltip condensé et inspection au clic pour descriptions détaillées | Q136 |
| T-136-04 | Tooltip près du bord de plateau | Position adaptée sans masquer la cible ou les commandes | Q136 |
| T-137-01 | Deux effets +2 ATQ identiques | Deux lignes distinctes avec durées propres | Q137 |
| T-137-02 | Effets caractéristiques/protection/restriction/capacité | Ordre de catégorie stable quelle que soit la phase | Q137 |
| T-137-03 | Deux effets catégorie identique, âges différents | Ordre d’application stable et déterministe | Q137 |
| T-137-04 | Réordonnancement UI après expiration | Aucune modification de priorité logique FIFO/expiration | Q137 |
| T-138-01 | Buff créé par joueur, portée par unité ennemie | Libellé de durée basé sur tour du joueur créateur | Q138 |
| T-138-02 | Effet permanent | Affichage Permanent sans compteur inventé | Q138 |
| T-138-03 | Effet conditionnel lié à artefact | Condition de disparition indiquée, pas fausse durée | Q138 |
| T-138-04 | Expiration prochain tour adverse | Texte naturel explicitant le camp et la phase sans confusion | Q138 |
| T-139-01 | Contrôle ennemi réussi | Icône contrôle incluse parmi états tactiques prioritaires | Q139 |
| T-139-02 | Buff « Encore 2 tours ennemi » change de contrôleur | Texte « Encore 2 tours ennemi » invariant | Q139 |
| T-139-03 | Créature volée | Owner reste propriétaire original, controller nouveau | Q139 |
| T-139-04 | Plus de trois états dont contrôle | Trois icônes prioritaires +N ; source et contrôle détaillés au clic | Q139 |
| T-140-01 | Bonus prolongé de deux tours | Durée mise à jour + bref +2 tours / horloge sur jeton | Q140 |
| T-140-02 | Bonus raccourci d’un tour | Durée mise à jour + feedback négatif distinct | Q140 |
| T-140-03 | Prolongation sans expiration | Aucun événement ON_EFFECT_EXPIRED ou nouvelle instance | Q140 |
| T-140-04 | Feedback de durée fini | Aucune quatrième icône permanente ajoutée au jeton | Q140 |
| T-141-01 | Action mineure répétée dix fois | Feedback perceptible mais bref sans attente excessive | Q141 |
| T-141-02 | Sort puissant et boss tué | Animation graduée intense, résultat perceptible | Q141 |
| T-141-03 | Mode animations réduites | Même information et état final, mouvement/flash réduits | Q141 |
| T-141-04 | Mêmes actions avec différents FPS | Mêmes transitions logiques, aucun effet sur résolution | Q141 |
| T-142-01 | Dix réactions secondaires compatibles | Accélération ou regroupement visuel sans changement des effets | Q142 |
| T-142-02 | Deux cibles frappées simultanément | Rendus indépendants sans nombres confondus | Q142 |
| T-142-03 | Fin de chaîne avec mort et soin | Mort et PV final restent visibles avant reprise | Q142 |
| T-142-04 | Replay avec animations désactivées | Journal logique et empreintes identiques | Q142 |
| T-143-01 | 8 dégâts bruts et 3 absorbés armure | −3 armure représenté séparément de −5 PV | Q143 |
| T-143-02 | Soin demandé 6, réalisé 2 | Nombre flottant +2 et non +6 | Q143 |
| T-143-03 | Bouclier consommé sans perte PV | Éclat/rupture magique sans nombre −PV | Q143 |
| T-143-04 | Sort exceptionnel | Éclairs, halo ou secousse si pertinent, chiffres restent lisibles | Q143 |
| T-144-01 | Chaîne de 20 effets mineurs | Objectif initial de 3–5 s visé par orchestrateur, mesures de prototype | Q144 |
| T-144-02 | Chaîne avec ultime et mort de boss | Moment spectaculaire préservé malgré accélération du reste | Q144 |
| T-144-03 | Effets indépendants et réactions secondaires | Superposition et regroupement compatibles sans pertes d’information | Q144 |
| T-144-04 | Chaîne calculée en 1 ms, présentation ralentie par GPU | Moteur logique, budgets et résultats indépendants du temps visuel | Q144 |


## Tests UI / plateau et prévisualisations — v1.6, Q145 à Q154

> **40 scénarios supplémentaires documentés, non exécutés** : les résultats attendus sont des exigences d’acceptation et non des affirmations de conformité d’un prototype. Les valeurs temporelles et les seuils de performance restent à mesurer. Source : [spécification Q145–Q154](../02-art-direction/board-and-tactical-preview.md).

| ID | Situation / action | Résultat attendu | Référence |
|---|---|---|---|
| T-145-01 | Décor unique V1 et changement de thème simulé | Mêmes positions, règles, états et cibles ; seul habillage varie | [Q145](../02-art-direction/board-and-tactical-preview.md) |
| T-145-02 | Grille 6x4 et deux camps | 24 emplacements fonctionnels alignés et identifiables pendant interaction | [Q145](../02-art-direction/board-and-tactical-preview.md) |
| T-145-03 | Thème fantaisie visuellement chargé | Cases, chiffres et jetons lisibles sans recouvrement | [Q145](../02-art-direction/board-and-tactical-preview.md) |
| T-145-04 | Données de combat rechargées après changement de décor | Aucune différence de hash fonctionnel ni événement moteur | [Q145](../02-art-direction/board-and-tactical-preview.md) |
| T-146-01 | Torche animée derrière une créature | PV et ATQ lisibles ; ambiance visuellement secondaire | [Q146](../02-art-direction/board-and-tactical-preview.md) |
| T-146-02 | Animations d’ambiance désactivées | Aucune perte de capacité à jouer, cibler ou comprendre | [Q146](../02-art-direction/board-and-tactical-preview.md) |
| T-146-03 | Sort puissant sur case avec rune de décor | Feedback du sort reste prioritaire | [Q146](../02-art-direction/board-and-tactical-preview.md) |
| T-146-04 | Changement de profil de mouvement réduit | Ambiance réduite, données tactiques intactes | [Q146](../02-art-direction/board-and-tactical-preview.md) |
| T-147-01 | Plateau au repos | Absence de pictogrammes répétitifs encombrants | [Q147](../02-art-direction/board-and-tactical-preview.md) |
| T-147-02 | Survol case offensive | Indication contextuelle de rôle/camp visible puis masquée | [Q147](../02-art-direction/board-and-tactical-preview.md) |
| T-147-03 | Sélection puis annulation | Highlights et étiquettes temporaires supprimés | [Q147](../02-art-direction/board-and-tactical-preview.md) |
| T-147-04 | Thème dénué de bleu/rouge | Symboles/contours permettent toujours de différencier les camps | [Q147](../02-art-direction/board-and-tactical-preview.md) |
| T-148-01 | Carte sélectionnée avec 3 destinations légales | Seules 3 cases légales identifiées | [Q148](../02-art-direction/board-and-tactical-preview.md) |
| T-148-02 | Tentative sur case non autorisée | Feedback local et motif court ; pas de dépôt exécuté | [Q148](../02-art-direction/board-and-tactical-preview.md) |
| T-148-03 | Début du geste de déplacement | Destinations légales du mouvement effectif affichées | [Q148](../02-art-direction/board-and-tactical-preview.md) |
| T-148-04 | Fin de geste/annulation | Cases éclairées effacées sans persistance | [Q148](../02-art-direction/board-and-tactical-preview.md) |
| T-149-01 | Créature sélectionnée, attaque déterministe létale | La cible et la créature affichent leurs conséquences de phase pertinentes | [Q149](../02-art-direction/board-and-tactical-preview.md) |
| T-149-02 | Unité fraîchement invoquée et malade | Aucune attaque supposée pendant phase non autorisée | [Q149](../02-art-direction/board-and-tactical-preview.md) |
| T-149-03 | Capacité de dégâts en réaction déterministe | Ordre de résolution pris en compte ; pas de calcul naïf de riposte | [Q149](../02-art-direction/board-and-tactical-preview.md) |
| T-149-04 | Prévision sans commit et RNG isolé | État réel, FIFO, seed et hash identiques avant/après consultation | [Q149](../02-art-direction/board-and-tactical-preview.md) |
| T-150-01 | Cible à 8 PV finissant à 3 | Indicateur temporaire 8 → 3 sans masquer 8 PV réels | [Q150](../02-art-direction/board-and-tactical-preview.md) |
| T-150-02 | Mort prévue après protections | Crâne et zéro PV visibles, sans animation de mort réelle | [Q150](../02-art-direction/board-and-tactical-preview.md) |
| T-150-03 | Issue pouvant dépendre d’une réaction | ? explicite, pas de faux résultat garanti | [Q150](../02-art-direction/board-and-tactical-preview.md) |
| T-150-04 | Fin de sélection | Overlays disparaissent, caractéristiques réelles inchangées | [Q150](../02-art-direction/board-and-tactical-preview.md) |
| T-151-01 | Glissement entre deux cases valides | Aperçu et valeurs changent selon la case, non selon pixels | [Q151](../02-art-direction/board-and-tactical-preview.md) |
| T-151-02 | Retour vers case déjà consultée sans modification d’état | Cache réutilisable ; résultat identique | [Q151](../02-art-direction/board-and-tactical-preview.md) |
| T-151-03 | État réel changé après mise en cache | Invalidation et nouveau calcul, pas de chiffres périmés | [Q151](../02-art-direction/board-and-tactical-preview.md) |
| T-151-04 | Calcul tardif pour ancienne case | Résultat rejeté si la case cible a changé | [Q151](../02-art-direction/board-and-tactical-preview.md) |
| T-152-01 | Résultat déterministe rapide | Montre valeurs certaines sans attendre branches non pertinentes | [Q152](../02-art-direction/board-and-tactical-preview.md) |
| T-152-02 | Aléa ou choix futur peut inverser décès | Statut incertain et hypothèses explicites | [Q152](../02-art-direction/board-and-tactical-preview.md) |
| T-152-03 | Budget de prévision épuisé | Indisponible ou partiel explicitement, sans bloquer case légale | [Q152](../02-art-direction/board-and-tactical-preview.md) |
| T-152-04 | Mode preview sur partie rejouée | Aucune influence sur RNG, budget logique, log ni issue | [Q152](../02-art-direction/board-and-tactical-preview.md) |
| T-153-01 | Dépôt sur case légale avec prévision en cours | Action traitée immédiatement après vérification moteur | [Q153](../02-art-direction/board-and-tactical-preview.md) |
| T-153-02 | Dépôt sur case devenue interdite | Rejet sans mutation, carte retourne à l’origine | [Q153](../02-art-direction/board-and-tactical-preview.md) |
| T-153-03 | Dépôt légal d’invocation forte | Feedback juicy gradué ; action logique indépendante animation | [Q153](../02-art-direction/board-and-tactical-preview.md) |
| T-153-04 | Réponse de preview tardive après dépôt | Ignorée ; ne modifie ni nouveaux chiffres ni partie | [Q153](../02-art-direction/board-and-tactical-preview.md) |
| T-154-01 | Placement au drag et clic-clic sur même case | Action identique, mêmes règles/couts et informations de placement | [Q154](../02-art-direction/board-and-tactical-preview.md) |
| T-154-02 | Tactile sans survol | Accès par sélection/focus aux cases et prévisions | [Q154](../02-art-direction/board-and-tactical-preview.md) |
| T-154-03 | Échap ou annulation avant commit | Retour initial sans dépense ni événement | [Q154](../02-art-direction/board-and-tactical-preview.md) |
| T-154-04 | Commande d’annulation après commit | Aucun undo implicite de l’action effective | [Q154](../02-art-direction/board-and-tactical-preview.md) |


## Tests de conformité v1.7 — Q155 à Q164

> **40 nouveaux scénarios définis, non exécutés.** Le tableau ci-dessous décrit les critères de réception du futur moteur et de l’interface, et non des résultats de test d’un logiciel existant. Les tie-breakers canoniques précis et seuils techniques doivent être finalisés et versionnés avant automatisation de leurs valeurs attendues. Source : [sorts, auras et effets continus](../02-art-direction/spells-auras-and-continuous-effects.md).

| ID | Scénario | Résultat attendu | Source |
|---|---|---|---|
| T-155-01 | Sort ciblé sur une créature protégée | Dégâts et consommations estimés selon résolution moteur ; statistiques réelles intactes | [Q155](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-155-02 | Même sort vers deux cibles successives | Preview mise à jour ; aucun résultat tardif de la cible précédente | [Q155](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-155-03 | Capacité adverse cachée | Aucune révélation d’information secrète ou de mort garantie trompeuse | [Q155](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-155-04 | Prévision d’un sort suivie d’un commit | Aucune mutation RNG/FIFO/ressources avant le commit réel | [Q155](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-156-01 | Sort ne touche qu’une unité puis plusieurs | Même graphisme, symboles et convention de chiffres par créature | [Q156](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-156-02 | Zone touche 6 créatures de caractéristiques distinctes | Six résultats individuels lisibles, sans chevauchement ni omission | [Q156](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-156-03 | Créature hors zone touchée par réaction | Cible indirecte distinguée de la zone directement visée | [Q156](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-156-04 | Dégâts de zone atomiques avec protections | Prévision identique aux règles de dégâts simultanés, sans faux ordre | [Q156](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-157-01 | Buff +3 ATQ sur une cible | Plateau montre ATQ finale prévisionnelle, sans imposer la flèche avant/après | [Q157](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-157-02 | Inspection du buff | Valeurs avant/après, source et durée explicitement consultables | [Q157](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-157-03 | Sort modifie PV maximum et actuels | PV prévus cohérents avec Q26 ; chiffre réel non écrasé | [Q157](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-157-04 | Cible et zone avec même buff | Conventions identiques quel que soit le nombre de cibles | [Q157](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-158-01 | Enchantement donne bonus immédiat et armure au prochain coup | Bonus immédiatement actif présent, armure future absente du total | [Q158](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-158-02 | Inspection de condition non déclenchée | Condition, durée, source et conséquence future visibles | [Q158](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-158-03 | Condition déjà satisfaite après le sort | Effet immédiatement effectif intégré à la valeur finale prévue | [Q158](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-158-04 | Capacité conditionnelle réellement appliquée | Icône tactique prioritaire reste disponible selon Q132/Q136 | [Q158](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-159-01 | Plateau avec plusieurs auras au repos | Absence de rayons/halos permanents entre toutes les unités | [Q159](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-159-02 | Source d’aura sélectionnée | Tous les bénéficiaires actuels surlignés sans ambiguïté | [Q159](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-159-03 | Source retirée ou contrôleur changé | Bénéficiaires et caractéristiques actualisés selon règles | [Q159](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-159-04 | Interaction tactile sur source | Même liste de bénéficiaires disponible sans hover | [Q159](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-160-01 | Aura ATQ ouvre condition armure | Preview montre ATQ et armure finales après cascade | [Q160](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-160-02 | Déplacer source sur autre colonne | Tous bénéficiaires pertinents recalculés sans étapes intermédiaires visibles | [Q160](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-160-03 | Réaction future dépend du prochain tour | Elle reste non comptée comme bonus immédiat | [Q160](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-160-04 | Une cascade devient incertaine | Marqueur incertitude et détails, aucun faux état final certain | [Q160](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-161-01 | Chaîne d’auras A vers B vers C acyclique | Ordre topologique canonique, mêmes résultats quel que soit parcours interne | [Q161](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-161-02 | Deux états d’entrée identiques historiques différents | Même état final sauf règles explicitement historiques | [Q161](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-161-03 | Modification de condition dans la même opération | Dépendances concernées recomputées avant lecture pertinente | [Q161](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-161-04 | Prévisualisation puis moteur sur mêmes paramètres déterministes | Même solveur, mêmes valeurs, aucune FIFO issue des itérations internes | [Q161](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-162-01 | Cycle sans point fixe | Détecté, sortie déterministe sans oscillation infinie | [Q162](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-162-02 | Deux points fixes possibles sans priorité | Ambiguïté détectée et règle canonique appliquée | [Q162](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-162-03 | Cycle avec branche indépendante | Branche indépendante reste active après neutralisation ciblée | [Q162](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-162-04 | Modification casse le cycle | Dépendances neutralisées réévaluées, trace de décision reproductible | [Q162](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-163-01 | Cycle oppose une contrainte fondamentale et un bonus | Contrainte fondamentale préservée, seule dépendance neutralisable écartée | [Q163](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-163-02 | Deux dépendances de même priorité peuvent être écartées | Tie-break canonique stable, identique entre exécutions | [Q163](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-163-03 | Même état sous autre ordre mémoire ou plateforme | Même dépendance neutralisée et même résultat final | [Q163](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-163-04 | Conflit local et bonus indépendant sur une même source | Bonus indépendant reste actif ; neutralisation minimale vérifiable | [Q163](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-164-01 | Source détruite, aura ATQ et armure conditionnelle perdues | Valeurs cohérentes avant l’opération suivante et ses réactions FIFO | [Q164](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-164-02 | Cascades de 8 modifications dans une opération atomique | Pas d’état intermédiaire incohérent exposé comme commit | [Q164](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-164-03 | UI regroupe plusieurs transitions rapides | Journal logique et empreintes identiques avec VFX détaillés ou regroupés | [Q164](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-164-04 | Preview en cache sous version antérieure du solveur | Cache invalidé, aucun résultat périmé ; RNG et FIFO réels inchangés | [Q164](../02-art-direction/spells-auras-and-continuous-effects.md) |


## Scénarios d’acceptation v1.8 — Q165–Q174 (spécifiés, non exécutés)

| ID | Scénario | Résultat attendu | Référence |
|---|---|---|---|
| T-165-01 | Conflit neutralise une dépendance d’aura | Feedback bref source + bénéficiaires, valeurs effectives exactes, aucun pictogramme permanent ajouté | [Q165](../02-art-direction/combat-journal-and-inspection.md) |
| T-165-02 | Cycle résolu et condition extérieure change | Feedback distinct de réactivation et retour du bonus, sans double application | [Q165](../02-art-direction/combat-journal-and-inspection.md) |
| T-165-03 | Inspection d’un bonus neutralisé | Source, contribution non appliquée et raison visible sans divulguer de secret | [Q165](../02-art-direction/combat-journal-and-inspection.md) |
| T-165-04 | Même conflit en preview et en combat | Même contribution neutralisée et logs/replay déterministes | [Q165](../02-art-direction/combat-journal-and-inspection.md) |
| T-166-01 | Combat sans consultation | Journal masqué par défaut, VFX et résolution non affectés | [Q166](../02-art-direction/combat-journal-and-inspection.md) |
| T-166-02 | Attaque avec huit réactions | Résumé par séquence ; détail complet des huit réactions dans leur ordre | [Q166](../02-art-direction/combat-journal-and-inspection.md) |
| T-166-03 | Événement masqué par règle de visibilité | Ni résumé ni détail joueur ne révèle le secret | [Q166](../02-art-direction/combat-journal-and-inspection.md) |
| T-166-04 | Ouverture puis fermeture du journal | Aucune variation du moteur, du RNG ou de la FIFO | [Q166](../02-art-direction/combat-journal-and-inspection.md) |
| T-167-01 | Large écran, ouverture sur demande | Panneau latéral ; plateau encore visible et lisible | [Q167](../02-art-direction/combat-journal-and-inspection.md) |
| T-167-02 | Petit écran, ouverture sur demande | Panneau se superpose ou s’adapte, sans écraser les 24 cases | [Q167](../02-art-direction/combat-journal-and-inspection.md) |
| T-167-03 | Fermeture immédiate | Panneau disparaît, aucun changement de combat | [Q167](../02-art-direction/combat-journal-and-inspection.md) |
| T-167-04 | Journal avec séquences nombreuses | Dépliage et défilement fonctionnels dans le panneau | [Q167](../02-art-direction/combat-journal-and-inspection.md) |
| T-168-01 | Survol événement, créature encore présente | Mise en évidence de la bonne instance et retour visuel à la normale | [Q168](../02-art-direction/combat-journal-and-inspection.md) |
| T-168-02 | Deux créatures au même nom | Seule instance historiquement liée est sélectionnée | [Q168](../02-art-direction/combat-journal-and-inspection.md) |
| T-168-03 | Créature détruite ou déplacée depuis événement | Identité/portrait/position d’époque dans journal ; plateau actuel inchangé | [Q168](../02-art-direction/combat-journal-and-inspection.md) |
| T-168-04 | Événement historique de contrôle | Pas de déplacement ni changement de camp en direct durant consultation | [Q168](../02-art-direction/combat-journal-and-inspection.md) |
| T-169-01 | Créature perd 7 PV et meurt | Inspection distingue avant 7 PV et après 0 PV | [Q169](../02-art-direction/combat-journal-and-inspection.md) |
| T-169-02 | Créature détruite puis ressuscitée | Événements historiques restent attribués à leur instance correcte | [Q169](../02-art-direction/combat-journal-and-inspection.md) |
| T-169-03 | Aura active à T puis disparue à T+1 | Inspection de T montre état et source pertinents à T | [Q169](../02-art-direction/combat-journal-and-inspection.md) |
| T-169-04 | Créature a changé de colonne et contrôleur | Position et contrôle historiques corrects, sans reconstruction depuis état courant | [Q169](../02-art-direction/combat-journal-and-inspection.md) |
| T-170-01 | Recherche par nom de sort connu | Seules séquences concernées et visibles retournées | [Q170](../02-art-direction/combat-journal-and-inspection.md) |
| T-170-02 | Filtre morts puis remise à zéro | Événements filtrés adéquats, retour au journal complet | [Q170](../02-art-direction/combat-journal-and-inspection.md) |
| T-170-03 | Filtre d’une chaîne multi-événements | Ordre des enfants conservé après filtrage | [Q170](../02-art-direction/combat-journal-and-inspection.md) |
| T-170-04 | Recherche d’information cachée | Aucun secret affiché, indexé ou suggéré | [Q170](../02-art-direction/combat-journal-and-inspection.md) |
| T-171-01 | Attaque annonce 8, 3 absorbés, 5 PV perdus | Résumé : 5 PV perdus et 3 absorbés, sans double compte | [Q171](../02-art-direction/combat-journal-and-inspection.md) |
| T-171-02 | Chaîne de 20 événements dont deux morts | Résumé identifie deux morts ; détail conserve les 20 événements | [Q171](../02-art-direction/combat-journal-and-inspection.md) |
| T-171-03 | Changement de contrôle sans dégâts | Événement majeur mis en avant malgré zéro dégât | [Q171](../02-art-direction/combat-journal-and-inspection.md) |
| T-171-04 | Consultation d’une vieille séquence après changements du plateau | Résumé historique stable, jamais recalculé depuis état actuel | [Q171](../02-art-direction/combat-journal-and-inspection.md) |
| T-172-01 | Capacité déclenchée après mort | Texte décrit capacité, source et déclencheur visibles | [Q172](../02-art-direction/combat-journal-and-inspection.md) |
| T-172-02 | Longue chaîne multi-causale | Aucun lien de navigation causale ni graphe requis ; événements lisibles en ordre | [Q172](../02-art-direction/combat-journal-and-inspection.md) |
| T-172-03 | Panneau ouvert pendant séquence | Descriptions calculées depuis événements existants, pas de simulation rétroactive | [Q172](../02-art-direction/combat-journal-and-inspection.md) |
| T-172-04 | Effet venant d’une source cachée | Texte ne révèle pas source secrète | [Q172](../02-art-direction/combat-journal-and-inspection.md) |
| T-173-01 | Combat de trente tours avec nombreuses réactions | Début et fin du combat consultables, aucune purge par tour | [Q173](../02-art-direction/combat-journal-and-inspection.md) |
| T-173-02 | Événements secondaires multiples | Tous les événements visibles pertinents retrouvables dans les détails | [Q173](../02-art-direction/combat-journal-and-inspection.md) |
| T-173-03 | Fin de combat normal | Historique joueur peut être libéré sans supprimer logs techniques nécessaires | [Q173](../02-art-direction/combat-journal-and-inspection.md) |
| T-173-04 | Sauvegarde puis reprise pendant combat | Journal cohérent et complet pour la partie déjà révélée | [Q173](../02-art-direction/combat-journal-and-inspection.md) |
| T-174-01 | Ouverture pendant longue animation | Panneau consultable, VFX continuent, aucune pause moteur | [Q174](../02-art-direction/combat-journal-and-inspection.md) |
| T-174-02 | Moteur a résolu mort mais animation non présentée | Mort pas encore révélée dans journal joueur | [Q174](../02-art-direction/combat-journal-and-inspection.md) |
| T-174-03 | Événements visuels groupés | Révélation progressive cohérente avec groupes, sans inversion chronologique | [Q174](../02-art-direction/combat-journal-and-inspection.md) |
| T-174-04 | Fin des animations, journal encore ouvert | Historique visible complet et résumé définitif, combat inchangé | [Q174](../02-art-direction/combat-journal-and-inspection.md) |


## V1.9 — Tests Q175–Q184 : récompenses et progression (40 scénarios non exécutés)

| ID | Scénario | Résultat attendu | Référence |
|---|---|---|---|
| T-175-01 | Victoire normale | Célébration courte, feedback final identifiable et accès rapide aux gains | [Q175](../03-progression/rewards-rarity-and-ascension.md) |
| T-175-02 | Victoire de boss | Mise en scène enrichie mais non obligatoire pour combat ordinaire | [Q175](../03-progression/rewards-rarity-and-ascension.md) |
| T-175-03 | Animation écourtée par joueur | Issue, trace et gains inchangés | [Q175](../03-progression/rewards-rarity-and-ascension.md) |
| T-175-04 | Attaque létale + événements de fin | Aucune célébration ne change le verdict canonique | [Q175](../03-progression/rewards-rarity-and-ascension.md) |
| T-176-01 | Récompense avec gains automatiques et choix | Zones distinctes, sélection explicite | [Q176](../03-progression/rewards-rarity-and-ascension.md) |
| T-176-02 | Trois cartes à inspecter | Inspection sans acquisition ni perte de contexte | [Q176](../03-progression/rewards-rarity-and-ascension.md) |
| T-176-03 | Révélation d’une carte commune | Effet et couleur cohérents avec la rareté réelle | [Q176](../03-progression/rewards-rarity-and-ascension.md) |
| T-176-04 | Reprise pendant écran de gains | Offre identique, aucune duplication | [Q176](../03-progression/rewards-rarity-and-ascension.md) |
| T-177-01 | Offre standard | Exactement trois cartes éligibles affichées | [Q177](../03-progression/rewards-rarity-and-ascension.md) |
| T-177-02 | Inspection des trois cartes | Toutes consultables avant confirmation | [Q177](../03-progression/rewards-rarity-and-ascension.md) |
| T-177-03 | Choisir une proposition | Une seule carte ajoutée, autres non acquises | [Q177](../03-progression/rewards-rarity-and-ascension.md) |
| T-177-04 | Double clic sur validation | Un seul ajout par décision | [Q177](../03-progression/rewards-rarity-and-ascension.md) |
| T-178-01 | Refuser toutes les cartes | Aucune carte ajoutée, compensation attribuée | [Q178](../03-progression/rewards-rarity-and-ascension.md) |
| T-178-02 | Refus avec gains automatiques | Monnaie et EXP normales conservées + compensation | [Q178](../03-progression/rewards-rarity-and-ascension.md) |
| T-178-03 | Prévisualiser compensation | Type et quantité visibles avant validation | [Q178](../03-progression/rewards-rarity-and-ascension.md) |
| T-178-04 | Recharger après confirmation | Pas de compensation distribuée deux fois | [Q178](../03-progression/rewards-rarity-and-ascension.md) |
| T-179-01 | Combat ordinaire gagné | Monnaie et EXP reçues | [Q179](../03-progression/rewards-rarity-and-ascension.md) |
| T-179-02 | Refus du draft | Gains monnaie/EXP préservés indépendamment | [Q179](../03-progression/rewards-rarity-and-ascension.md) |
| T-179-03 | Étage et difficulté différents | Paramètres de calcul pris en compte selon barème disponible | [Q179](../03-progression/rewards-rarity-and-ascension.md) |
| T-179-04 | Affichage de gains | Distingue gains garantis des options | [Q179](../03-progression/rewards-rarity-and-ascension.md) |
| T-180-01 | Boss vaincu | Monnaie et EXP renforcées, offre exceptionnelle | [Q180](../03-progression/rewards-rarity-and-ascension.md) |
| T-180-02 | Joueur préfère deck compact | Possibilité de choisir artefact ou amélioration, sans carte | [Q180](../03-progression/rewards-rarity-and-ascension.md) |
| T-180-03 | Offres intercatégories | Inspection et confirmation de la catégorie choisie | [Q180](../03-progression/rewards-rarity-and-ascension.md) |
| T-180-04 | Reprise avant validation | Une seule récompense exceptionnelle au maximum validée | [Q180](../03-progression/rewards-rarity-and-ascension.md) |
| T-181-01 | Affichage des cinq rangs | Blanc/bleu/rouge/violet/or associés aux bons noms | [Q181](../03-progression/rewards-rarity-and-ascension.md) |
| T-181-02 | Carte peu commune | Bleu, non rare ; carte rare rouge | [Q181](../03-progression/rewards-rarity-and-ascension.md) |
| T-181-03 | Pool de rareté | Aucun niveau Mythique | [Q181](../03-progression/rewards-rarity-and-ascension.md) |
| T-181-04 | Affichage daltonisme | Libellé/motif distinct au-delà du code couleur | [Q181](../03-progression/rewards-rarity-and-ascension.md) |
| T-182-01 | Fin ascension avec artefacts | Artefacts de tentative non conservés à la prochaine | [Q182](../03-progression/rewards-rarity-and-ascension.md) |
| T-182-02 | Tour terminée et déblocage | Nouvel élément éligible au draft des ascensions suivantes | [Q182](../03-progression/rewards-rarity-and-ascension.md) |
| T-182-03 | Nouvelle ascension après déblocage | Nouvel élément pas attribué automatiquement | [Q182](../03-progression/rewards-rarity-and-ascension.md) |
| T-182-04 | Sauvegarde des déblocages | Déblocages persistants à travers tentatives | [Q182](../03-progression/rewards-rarity-and-ascension.md) |
| T-183-01 | Inventaire rempli | Acquisition supplémentaire impose libération/remplacement | [Q183](../03-progression/rewards-rarity-and-ascension.md) |
| T-183-02 | Récompense augmentant capacité | Emplacement supplémentaire disponible pendant ascension | [Q183](../03-progression/rewards-rarity-and-ascension.md) |
| T-183-03 | Recommencer après hausse capacité | Capacité de départ rétablie | [Q183](../03-progression/rewards-rarity-and-ascension.md) |
| T-183-04 | UI montre capacité | Occupés/disponibles exacts sans présumer valeur initiale | [Q183](../03-progression/rewards-rarity-and-ascension.md) |
| T-184-01 | Offre caractéristique | Bonus choisi appliqué durant tentative | [Q184](../03-progression/rewards-rarity-and-ascension.md) |
| T-184-02 | Offre capacité | Nouvelle capacité ou évolution appliquée selon moteur | [Q184](../03-progression/rewards-rarity-and-ascension.md) |
| T-184-03 | Fin tentative | Améliorations temporaires réinitialisées | [Q184](../03-progression/rewards-rarity-and-ascension.md) |
| T-184-04 | Déblocages permanents existants | Déblocages Q182 restent, mais bonus Q184 disparaissent | [Q184](../03-progression/rewards-rarity-and-ascension.md) |

**État** : tous les tests v1.9 ci-dessus sont **documentaires, non exécutés** ; ne pas les annoncer comme réussis. Les tests de probabilités, des seuils numériques d’EXP et des capacités initiales ne sont pas spécifiés tant que ces paramètres restent ouverts.


## Consolidation v2.0 — Tests d’acceptation Q185–Q194 (spécifiés, NON exécutés)

| ID | Scénario | Résultat attendu | Référence |
|---|---|---|---|
| T-185-01 | Acquisition d’un bonus de PV via arbre | Les PV du héros augmentent selon le nœud et le bonus subsiste à la prochaine ascension. | [Q185](../03-progression/hero-sphere-and-skill-tree.md) |
| T-185-02 | Échec après investissement dans le sphérier | Le nœud permanent reste acquis ; le deck et les artefacts de tentative sont perdus. | [Q185](../03-progression/hero-sphere-and-skill-tree.md) |
| T-185-03 | Bonus feu permanent et amélioration temporaire de boss | Les deux bonus suivent leurs sources ; seul celui du sphérier persiste. | [Q185](../03-progression/hero-sphere-and-skill-tree.md) |
| T-185-04 | Début d’une nouvelle ascension | Aucun bonus du sphérier n’est perdu ni doublé. | [Q185](../03-progression/hero-sphere-and-skill-tree.md) |
| T-186-01 | Gain d’EXP sur victoire | Le cumul permanent augmente exactement une fois. | [Q186](../03-progression/hero-sphere-and-skill-tree.md) |
| T-186-02 | Montée de niveau | Le nombre paramétré de points est crédité une fois. | [Q186](../03-progression/hero-sphere-and-skill-tree.md) |
| T-186-03 | Défaite avec points non dépensés | EXP, niveau et points non dépensés persistent. | [Q186](../03-progression/hero-sphere-and-skill-tree.md) |
| T-186-04 | Reprise après sauvegarde au seuil de niveau | Aucun second crédit de points de niveau. | [Q186](../03-progression/hero-sphere-and-skill-tree.md) |
| T-187-01 | Tentative sur nœud non connecté | Déblocage refusé avec prérequis explicite. | [Q187](../03-progression/hero-sphere-and-skill-tree.md) |
| T-187-02 | Déblocage d’un nœud accessible adjacent | Nœud acquis et successeurs accessibles selon leurs prérequis. | [Q187](../03-progression/hero-sphere-and-skill-tree.md) |
| T-187-03 | Passerelle interbranche activée | Nouvel itinéraire de progression disponible sans contourner les prérequis. | [Q187](../03-progression/hero-sphere-and-skill-tree.md) |
| T-187-04 | Affichage de trois états de nœuds | Acquis, accessible et verrouillé distincts et corrects. | [Q187](../03-progression/hero-sphere-and-skill-tree.md) |
| T-188-01 | Nœuds de coûts distincts | Chaque nœud débite son coût configuré. | [Q188](../03-progression/hero-sphere-and-skill-tree.md) |
| T-188-02 | Fonds insuffisants | Aucune acquisition ni solde négatif. | [Q188](../03-progression/hero-sphere-and-skill-tree.md) |
| T-188-03 | Compétence avancée sans prérequis | Coût disponible ne suffit pas à contourner le prérequis. | [Q188](../03-progression/hero-sphere-and-skill-tree.md) |
| T-188-04 | Double confirmation du même nœud | Déblocage et débit effectués une seule fois. | [Q188](../03-progression/hero-sphere-and-skill-tree.md) |
| T-189-01 | Reset hors ascension confirmé | Nœuds libérés, total des points restitué sans coût. | [Q189](../03-progression/hero-sphere-and-skill-tree.md) |
| T-189-02 | Reset pendant ascension | Action impossible. | [Q189](../03-progression/hero-sphere-and-skill-tree.md) |
| T-189-03 | Réallocation après reset | Nœuds acquis selon nouveaux chemins et coûts ; capital total constant. | [Q189](../03-progression/hero-sphere-and-skill-tree.md) |
| T-189-04 | Reset puis rechargement | Niveau, EXP et points comptabilisés sans création ou perte. | [Q189](../03-progression/hero-sphere-and-skill-tree.md) |
| T-190-01 | Nouveau profil de joueur | Plusieurs tours de difficultés distinctes immédiatement accessibles. | [Q190](../03-progression/towers-merchants-and-unlocks.md) |
| T-190-02 | Tour spéciale non déverrouillée | Accès refusé, prérequis de tour explicite. | [Q190](../03-progression/towers-merchants-and-unlocks.md) |
| T-190-03 | Fin des tours requises | Tour spéciale débloquée de manière persistante. | [Q190](../03-progression/towers-merchants-and-unlocks.md) |
| T-190-04 | Héros sous niveau conseillé | Une tour accessible autorise l’entrée quand même. | [Q190](../03-progression/towers-merchants-and-unlocks.md) |
| T-191-01 | Première victoire sur une tour | Déblocages uniques et récompenses répétables prévus crédités. | [Q191](../03-progression/towers-merchants-and-unlocks.md) |
| T-191-02 | Seconde victoire même tour | Aucun duplicata de déblocage unique ; récompenses répétables accordées. | [Q191](../03-progression/towers-merchants-and-unlocks.md) |
| T-191-03 | Rechargement après première victoire | Flag de première victoire préservé, pas de double gain. | [Q191](../03-progression/towers-merchants-and-unlocks.md) |
| T-191-04 | Déblocage de carte par fin de tour | Carte devient éligible au draft, pas ajoutée automatiquement au deck initial. | [Q191](../03-progression/towers-merchants-and-unlocks.md) |
| T-192-01 | Héros niveau faible entre dans une tour | Ennemis ont la difficulté canonique de la tour. | [Q192](../03-progression/towers-merchants-and-unlocks.md) |
| T-192-02 | Héros niveau élevé entre dans la même tour | Ennemis gardent exactement les mêmes caractéristiques de difficulté. | [Q192](../03-progression/towers-merchants-and-unlocks.md) |
| T-192-03 | Répétition d’une tour facile à haut niveau | Récompenses répétables deviennent moins intéressantes selon barème configurable. | [Q192](../03-progression/towers-merchants-and-unlocks.md) |
| T-192-04 | Première victoire à haut niveau | Déblocage unique inchangé, pas soumis à la décote d’EXP. | [Q192](../03-progression/towers-merchants-and-unlocks.md) |
| T-193-01 | Accomplissement global débloqué | Contenu correspondant devient éligible aux futures propositions. | [Q193](../03-progression/towers-merchants-and-unlocks.md) |
| T-193-02 | Visite d’un marchand de tour exclusive | Carte exclusive est disponible à l’achat dans la tour prévue selon les règles de stock. | [Q193](../03-progression/towers-merchants-and-unlocks.md) |
| T-193-03 | Visite d’un marchand d’une autre tour | Exclusivité non offerte à l’achat par ce marchand avant déblocage selon règles d’offre. | [Q193](../03-progression/towers-merchants-and-unlocks.md) |
| T-193-04 | Offre d’une carte rare | Rare est rouge, peu commune bleue ; code couleur respecté. | [Q193](../03-progression/towers-merchants-and-unlocks.md) |
| T-194-01 | Carte choisie parmi trois | Carte obtenue et son identité enregistrée immédiatement dans le catalogue permanent ; cartes refusées non débloquées. | [Q194](../03-progression/towers-merchants-and-unlocks.md) |
| T-194-02 | Carte exclusive achetée puis ascension perdue | Copie de tentative perdue ; identité reste débloquée et éligible aux futurs drafts. | [Q194](../03-progression/towers-merchants-and-unlocks.md) |
| T-194-03 | Carte seulement inspectée ou proposée | Aucun déblocage de cette carte. | [Q194](../03-progression/towers-merchants-and-unlocks.md) |
| T-194-04 | Achat répété / rechargement / double clic | Une seule attribution d’achat et un seul déblocage idempotent ; carte non garantie au prochain draft. | [Q194](../03-progression/towers-merchants-and-unlocks.md) |

**Statut :** 40 scénarios ajoutés à v2.0 ; **non exécutés**. Les barèmes EXP, tailles de stocks, coût des compétences et taux de draft restent ouverts.


## Consolidation v2.1 — Tests d’acceptation Q195–Q204 (SPÉCIFIÉS, NON EXÉCUTÉS)

| ID | Scénario | Résultat attendu | Référence |
|---|---|---|---|
| T-195-01 | Tirage marchand dans une tour donnée | Stock généré dans le pool de la tour, mélange génériques/exclusives éligibles. | [Q195](../03-progression/merchant-stock-and-deck-limits.md) |
| T-195-02 | Exclusivité absente d’un tirage | Aucune obligation de présenter une carte exclusive à chaque visite. | [Q195](../03-progression/merchant-stock-and-deck-limits.md) |
| T-195-03 | Exclusivité autre tour | Impossible de trouver dans ce commerce une carte exclusive d’une autre tour non éligible. | [Q195](../03-progression/merchant-stock-and-deck-limits.md) |
| T-195-04 | Carte exclusive achetée | Carte utilisable pendant le run et débloquée pour les drafts futurs (Q194). | [Q195](../03-progression/merchant-stock-and-deck-limits.md) |
| T-196-01 | Cartes de raretés différentes | Références tarifaires correspondantes, cinq couleurs Q181 et prix affichés. | [Q196](../03-progression/merchant-stock-and-deck-limits.md) |
| T-196-02 | Ajustement individuel | Une carte peut différer de sa référence selon son paramétrage sans prix RNG arbitraire. | [Q196](../03-progression/merchant-stock-and-deck-limits.md) |
| T-196-03 | État de collection | UI distingue clairement carte débloquée ou non. | [Q196](../03-progression/merchant-stock-and-deck-limits.md) |
| T-196-04 | Confirmation achat | Débit exact du prix affiché, aucune acquisition en cas de fonds insuffisants. | [Q196](../03-progression/merchant-stock-and-deck-limits.md) |
| T-197-01 | Défaite avec monnaie restante | Solde de run supprimé ; aucun transfert au run suivant. | [Q197](../03-progression/merchant-stock-and-deck-limits.md) |
| T-197-02 | Victoire avec monnaie restante | Solde de run supprimé également. | [Q197](../03-progression/merchant-stock-and-deck-limits.md) |
| T-197-03 | Achat carte puis défaite | Monnaie effacée mais identité de carte débloquée pour drafts futurs. | [Q197](../03-progression/merchant-stock-and-deck-limits.md) |
| T-197-04 | Nouvelle ascension | Solde initial configuré et progression permanente EXP/sphérier intacte. | [Q197](../03-progression/merchant-stock-and-deck-limits.md) |
| T-198-01 | Renouvellements successifs | Prochain coût strictement croissant pour ce marchand. | [Q198](../03-progression/merchant-stock-and-deck-limits.md) |
| T-198-02 | Fonds insuffisants | Aucun débit, nouveau stock ni incrément de compteur. | [Q198](../03-progression/merchant-stock-and-deck-limits.md) |
| T-198-03 | Renouvellement conforme au pool | Tirage respecte les exclusivités et raretés ; rien n’est garanti. | [Q198](../03-progression/merchant-stock-and-deck-limits.md) |
| T-198-04 | Renouvellement rejoué après sauvegarde | Stock, compteur et débit appliqués une seule fois. | [Q198](../03-progression/merchant-stock-and-deck-limits.md) |
| T-199-01 | Deux marchands différents | Renouvellement A ne modifie pas le compteur ni le coût du marchand B. | [Q199](../03-progression/merchant-stock-and-deck-limits.md) |
| T-199-02 | Quitter/rentrer même commerce | Même stock et même coût progressif. | [Q199](../03-progression/merchant-stock-and-deck-limits.md) |
| T-199-03 | Sauvegarde/reprise même tentative | Stocks et compteurs identiques avant et après reprise. | [Q199](../03-progression/merchant-stock-and-deck-limits.md) |
| T-199-04 | Nouvelle tentative | Compteurs réinitialisés pour les nouvelles instances de marchands. | [Q199](../03-progression/merchant-stock-and-deck-limits.md) |
| T-200-01 | Achat dans emplacement | Une seule carte attribuée, emplacement vidé, autres offres inchangées. | [Q200](../03-progression/merchant-stock-and-deck-limits.md) |
| T-200-02 | Renouvellement après achat | Carte achetée peut réapparaître si elle reste éligible et sous plafond. | [Q200](../03-progression/merchant-stock-and-deck-limits.md) |
| T-200-03 | Second achat même carte | Deux exemplaires dans le deck, une seule identité débloquée durablement. | [Q200](../03-progression/merchant-stock-and-deck-limits.md) |
| T-200-04 | Double clic achat | Un achat, un débit et un exemplaire attribués une fois. | [Q200](../03-progression/merchant-stock-and-deck-limits.md) |
| T-201-01 | Quatre copies Commune | Quatre autorisées, cinquième refusée. | [Q201](../03-progression/merchant-stock-and-deck-limits.md) |
| T-201-02 | Quatre copies Légendaire | Même plafond de quatre, pas de règle unique légendaire. | [Q201](../03-progression/merchant-stock-and-deck-limits.md) |
| T-201-03 | Copie temporaire en combat | Ne modifie pas le compteur de copies du deck d’ascension. | [Q201](../03-progression/merchant-stock-and-deck-limits.md) |
| T-201-04 | Carte déjà débloquée achetée de nouveau | Pas de duplicata dans le catalogue permanent ; plafond du deck respecté. | [Q201](../03-progression/merchant-stock-and-deck-limits.md) |
| T-202-01 | Génération magasin avec carte à 4 | Carte exclue avant tirage. | [Q202](../03-progression/merchant-stock-and-deck-limits.md) |
| T-202-02 | Renouvellement magasin à 4 | Carte exclue également au renouvellement. | [Q202](../03-progression/merchant-stock-and-deck-limits.md) |
| T-202-03 | Pool magasin trop petit | Moins d’offres, aucune offre impossible ou hors-tour. | [Q202](../03-progression/merchant-stock-and-deck-limits.md) |
| T-202-04 | Offre affichée devenue plafonnée | Validation rejette sans débit ni nouvelle copie. | [Q202](../03-progression/merchant-stock-and-deck-limits.md) |
| T-203-01 | Trois cartes éligibles ou plus | Trois propositions valides selon Q177. | [Q203](../03-progression/merchant-stock-and-deck-limits.md) |
| T-203-02 | Une ou deux cartes éligibles | Seulement une ou deux propositions, aucune carte invalidée. | [Q203](../03-progression/merchant-stock-and-deck-limits.md) |
| T-203-03 | Refus de propositions | Compensation Q178 disponible même avec moins de trois cartes. | [Q203](../03-progression/merchant-stock-and-deck-limits.md) |
| T-203-04 | Réévaluation à l’engagement | Aucune cinquième copie admise après changements ou reprise. | [Q203](../03-progression/merchant-stock-and-deck-limits.md) |
| T-204-01 | Zéro carte éligible | Compensation Q178 automatique sans écran de sélection vide. | [Q204](../03-progression/merchant-stock-and-deck-limits.md) |
| T-204-02 | Récompense automatique parallèle | Monnaie et EXP Q179 accordées en plus de la compensation. | [Q204](../03-progression/merchant-stock-and-deck-limits.md) |
| T-204-03 | Reprise et retry au point de récompense | Compensation enregistrée exactement une fois. | [Q204](../03-progression/merchant-stock-and-deck-limits.md) |
| T-204-04 | Aucun pool éligible | Pas d’extension cachée de pools ni de carte débloquée par la compensation. | [Q204](../03-progression/merchant-stock-and-deck-limits.md) |

**Statut :** 40 scénarios nouveaux documentés et **non exécutés** sur un jeu. Les paramètres numériques restent à arbitrer.

## Consolidation v2.2 — tests d’acceptation Q205–Q214

> **40 scénarios nouveaux, spécifiés et NON EXÉCUTÉS.** Les tests ci-dessous s’ajoutent aux tests précédents. Ils respectent les prérequis ouverts, et emploient les valeurs initiales 40/40 validées en Q208.

| ID | Cas | Résultat attendu | Référence |
|---|---|---|---|
| T-205-01 | Retrait réversible | Une copie acquise est déplacée du deck actif à la réserve, sans destruction ni perte de déblocage. | [Q205](../03-progression/deck-reserve-and-capacity.md) |
| T-205-02 | Réintégration | La même instance peut revenir de réserve au deck actif sans nouvelle acquisition. | [Q205](../03-progression/deck-reserve-and-capacity.md) |
| T-205-03 | Fin de run | Deck actif et réserve réinitialisés ; identité de carte reste déverrouillée pour le draft futur. | [Q205](../03-progression/deck-reserve-and-capacity.md) |
| T-205-04 | Copies multiples | Transfert de deux copies conserve le total possédé et les identifiants des instances. | [Q205](../03-progression/deck-reserve-and-capacity.md) |
| T-206-01 | Entre combats | Transfert gratuit sans marchand, sauvegarde et affichage de la répartition à jour. | [Q206](../03-progression/deck-reserve-and-capacity.md) |
| T-206-02 | Combat démarré | Action manuelle de transfert refusée sans modification d’état. | [Q206](../03-progression/deck-reserve-and-capacity.md) |
| T-206-03 | Sauvegarde/reprise | Deck et réserve reconstruits exactement après reprise pendant une ascension. | [Q206](../03-progression/deck-reserve-and-capacity.md) |
| T-206-04 | Composition invalide avant combat | Préparation éditable, mais lancement de combat bloqué tant que taille hors bornes. | [Q206](../03-progression/deck-reserve-and-capacity.md) |
| T-207-01 | Plafond réparti 2+2 | Deux copies actives et deux en réserve : achat d’une cinquième refusé. | [Q207](../03-progression/deck-reserve-and-capacity.md) |
| T-207-02 | Déplacer en réserve | Déplacer 2 copies du deck à la réserve ne rend pas la carte éligible à un nouveau draft/achat. | [Q207](../03-progression/deck-reserve-and-capacity.md) |
| T-207-03 | Quatre légendaires | Même plafond de quatre pour une identité légendaire, sans unique par rareté. | [Q207](../03-progression/deck-reserve-and-capacity.md) |
| T-207-04 | Copy temporaire | Une copie créée exclusivement en combat ne change pas le compteur d’acquisition deck+réserve. | [Q207](../03-progression/deck-reserve-and-capacity.md) |
| T-208-01 | Départ 40/40 | Un deck actif de 40 cartes respecte la taille initiale ; 39 et 41 ne peuvent commencer un combat sans bonus. | [Q208](../03-progression/deck-reserve-and-capacity.md) |
| T-208-02 | Minimum abaissé | Minimum effectif à 35, deck 35 : lancement autorisé ; fatigue ordinaire inchangée. | [Q208](../03-progression/deck-reserve-and-capacity.md) |
| T-208-03 | Maximum augmenté | Maximum effectif à 45, deck 45 : lancement autorisé, aucun transfert auto. | [Q208](../03-progression/deck-reserve-and-capacity.md) |
| T-208-04 | Transfert hors bornes | Cartes non détruites ; deck invalide ne peut pas lancer de combat avant correction. | [Q208](../03-progression/deck-reserve-and-capacity.md) |
| T-209-01 | Sphérier permanent | Réduction du minimum par nœud de sphérier persiste entre ascensions et apparaît dans les bornes. | [Q209](../03-progression/deck-reserve-and-capacity.md) |
| T-209-02 | Bonus temporaire | Bonus de maximum en run s’ajoute au sphérier selon les bornes effectives. | [Q209](../03-progression/deck-reserve-and-capacity.md) |
| T-209-03 | Expiration bonus | Une expiration rend le deck potentiellement invalide, sans supprimer silencieusement d’exemplaire. | [Q209](../03-progression/deck-reserve-and-capacity.md) |
| T-209-04 | Nouvelle ascension | Bonus temporaire perdu, bonus du sphérier conservé ; capacité revalidée. | [Q209](../03-progression/deck-reserve-and-capacity.md) |
| T-210-01 | Multi-pioche 2/5 | Deux cartes disponibles, cinq pioches : fatigue 1, 2, 3 PV après les deux pioches, réactions FIFO entre. | [Q210](../01-combat/deck-search-and-fatigue-v22.md) |
| T-210-02 | Pas de recyclage | Pioche vide avec cartes en défausse : fatigue, pas de remélange automatique Q43. | [Q210](../01-combat/deck-search-and-fatigue-v22.md) |
| T-210-03 | Réinsertion | Après fatigue 1, une carte est réinsérée puis piochée : prochaine pioche impossible inflige 2 PV. | [Q210](../01-combat/deck-search-and-fatigue-v22.md) |
| T-210-04 | Nature et interruption | Fatigue directe ignore bouclier et ne déclenche pas ON_DAMAGE_TAKEN ; mort interrompt les pioches suivantes. | [Q210](../01-combat/deck-search-and-fatigue-v22.md) |
| T-211-01 | Recherche ciblée | Choix manuel d’une instance valide selon critères type/élément/coût et zone pioche. | [Q211](../01-combat/deck-search-and-fatigue-v22.md) |
| T-211-02 | Recherche aléatoire | Une instance éligible sélectionnée via RNG déterministe sans ouverture de sélecteur. | [Q211](../01-combat/deck-search-and-fatigue-v22.md) |
| T-211-03 | Zones exclues | Copie dans main/défausse/réserve non trouvée par recherche limitée à la pioche. | [Q211](../01-combat/deck-search-and-fatigue-v22.md) |
| T-211-04 | Aucune carte éligible | Résolution sans résultat ni fatigue et sans sélection artificielle. | [Q211](../01-combat/deck-search-and-fatigue-v22.md) |
| T-212-01 | Destination main | Carte recherchée déplacée en main, sans événement de pioche sauf texte explicite ; limite main respectée. | [Q212](../01-combat/deck-search-and-fatigue-v22.md) |
| T-212-02 | Destination sommet | Carte ciblée placée au sommet, ordre relatif des autres copies conservé sans instruction de mélange. | [Q212](../01-combat/deck-search-and-fatigue-v22.md) |
| T-212-03 | Mélange demandé | Mélange RNG déterministe conforme à l’instruction et reproductible après replay. | [Q212](../01-combat/deck-search-and-fatigue-v22.md) |
| T-212-04 | Recherche manquée multi-effet | Aucune fatigue ; composante indépendante se résout ; pas de mélange si non ordonné. | [Q212](../01-combat/deck-search-and-fatigue-v22.md) |
| T-213-01 | Filtre visibilité | Recherche ciblée montre toutes et seulement les instances éligibles, inspectables. | [Q213](../01-combat/deck-search-and-fatigue-v22.md) |
| T-213-02 | Ordre masqué | Affichage des cartes éligibles ne permet pas de reconstruire l’ordre réel de la pioche. | [Q213](../01-combat/deck-search-and-fatigue-v22.md) |
| T-213-03 | Recherche aléatoire | Pas de fenêtre de choix, résultat exposé seulement selon règles de visibilité. | [Q213](../01-combat/deck-search-and-fatigue-v22.md) |
| T-213-04 | Journal confidentialité | Journal et historique ne révèlent ni cartes non éligibles ni ordre caché. | [Q213](../01-combat/deck-search-and-fatigue-v22.md) |
| T-214-01 | Trois copies identiques | Trois instances éligibles de même carte affichées dans trois entrées séparées, jamais ×3. | [Q214](../01-combat/deck-search-and-fatigue-v22.md) |
| T-214-02 | Choix instance | Le joueur clique une instance précise ; exactement cette instance est transférée. | [Q214](../01-combat/deck-search-and-fatigue-v22.md) |
| T-214-03 | Copies modifiées | Copies d’état différent restent séparées et inspectables, identités stables. | [Q214](../01-combat/deck-search-and-fatigue-v22.md) |
| T-214-04 | Instance devenue invalide | Validation rejette la cible disparue sans sélectionner un autre exemplaire et sans RNG de départage. | [Q214](../01-combat/deck-search-and-fatigue-v22.md) |

**Non-régression obligatoire :** remplacer dans la suite Q41 les assertions de « −1 PV à chaque pioche impossible » par `−1, −2, −3… PV` dans un même combat. Pour Q201–Q203, filtrer sur **deck actif + réserve** ; pour Q213, ne jamais fusionner les exemplaires identiques (Q214-A).

## Tests de conformité Q215–Q224 — v2.3 (40 scénarios, **spécifiés et non exécutés**)

| Test | Décision | Entrée | Résultat attendu | Source |
|---|---|---|---|---|
| T-215-01 | Allocation standard | Débuter ascension sans bonus de taille. | 20 cartes de base + deux boosters de 15, soit 50 instances ; 40 actives/10 réserve après constitution. | [Q215](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-215-02 | Collection non directement utilisable | Une carte est débloquée mais absente du socle et des deux boosters. | Impossible de l’ajouter directement au deck initial, malgré son déblocage. | [Q215](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-215-03 | Copies non permanentes | Achever une ascension, puis en commencer une nouvelle. | Les 50 instances de run ne persistent pas ; les déblocages permanents demeurent. | [Q215](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-215-04 | Bornes améliorées | Sphérier modifie le minimum et/ou maximum avant ascension. | Validation avec bornes effectives ; aucune répartition 40/10 inventée si elle est incompatible. | [Q215](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-216-01 | Proposition immédiate | Deux boosters ouverts ; déclencher l’assistant. | Proposition de deck/réserve légale sans choisir manuellement 40 cartes. | [Q216](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-216-02 | Ajustement facultatif | Modifier librement la proposition avant le combat. | Instances conservées et transfert gratuit ; taille vérifiée au démarrage. | [Q216](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-216-03 | Aucune inspection obligatoire | Joueur passe animations et n’ouvre aucun inspecteur. | Peut commencer dès que la composition automatique est légale. | [Q216](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-216-04 | Proposition invalide | Un état partiellement modifié ne satisfait pas minDeckSize. | Démarrage du combat bloqué, édition de préparation autorisée. | [Q216](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-217-01 | Bornes de base | Héros sans bonus de capacité. | minDeckSize=maxDeckSize=40, pas 30 ni 35. | [Q217](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-217-02 | Répartition standard | 20 + 15 + 15 exemplaires attribués. | 40 deck actif et 10 réserve après composition. | [Q217](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-217-03 | Réduction min sphérier | Compétence permanente abaisse minDeckSize. | Valeur effective appliquée, sans changer la base enregistrée 40. | [Q217](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-217-04 | Hausse max run | Bonus temporaire augmente maxDeckSize. | Max effectif augmenté, retour à la base après fin run ; aucune destruction de copies. | [Q217](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-218-01 | Pool de rareté | Génération de booster avec plusieurs raretés débloquées. | Tirage pondéré par rareté, et non sélection égale ou quota fixe. | [Q218](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-218-02 | Aucune garantie passive | Aucun nœud de garantie actif. | Pas de carte Rare+ systématiquement imposée. | [Q218](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-218-03 | Garantie par booster | Compétence garantissant Rare+ et ≥1 carte éligible Rare+. | Booster 1 et booster 2 contiennent chacun au moins une Rare+, si faisable selon les plafonds. | [Q218](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-218-04 | Rareté inaccessible | Garantie Rare+ mais aucun exemplaire Rare+ déverrouillé/éligible. | Aucune carte verrouillée créée ; renvoi vers assouplissement Q219. | [Q218](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-219-01 | Plafond trans-packs | Socle contient trois copies X ; booster 1 ajoute X. | Booster 2 ne peut plus contenir X ; total X=4. | [Q219](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-219-02 | Assouplir garantie | Garantie Rare+, seules cartes Peu communes éligibles. | Dégradation vers meilleure rareté éligible, sans ajout de carte verrouillée. | [Q219](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-219-03 | Pool structurellement impossible | Moins de capacité totale de 50 copies sous cap de quatre. | Détection explicite ; pas de boucle infinie ni violation ; secours **À DÉFINIR** avant implémentation complète. | [Q219](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-219-04 | RNG reproductible | Même seed, pool éligible, socle et état sphérier. | Mêmes exemplaires générés dans le même ordre, sauvegarde/reprise cohérente. | [Q219](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-220-01 | Ordre des boosters | Démarrer le flux de révélation. | Booster 1 avant booster 2, jamais simultanés. | [Q220](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-220-02 | Révélation groupée | Ouvrir un booster de 15 cartes. | Affichage des 15 cartes en une seule révélation, pas 15 clics obligatoires. | [Q220](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-220-03 | Passer animation | Passer l’animation du booster 1 et poursuivre. | Booster 2 est accessible ; résultats tirés invariants. | [Q220](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-220-04 | Rare feedback | Carte de rareté élevée tirée dans un booster. | Feedback visuel distinctif et lisible sans obligation de visionner l’animation. | [Q220](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-221-01 | Rareté lisible | Afficher les cartes des boosters. | Couleurs conformes Q181 pour les cinq niveaux ; pas de mythique. | [Q221](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-221-02 | Filtres optionnels | Filtrer type puis rareté puis synergie. | Visibilité filtrée ; sélection/possession des cartes inchangées. | [Q221](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-221-03 | Transfert rapide | Déplacer une carte de deck vers réserve puis inversement. | Conserve identité de copie ; plafonds et taille revalidés. | [Q221](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-221-04 | Libellé de découverte | Carte déjà débloquée présente dans booster. | Identifiée comme tirage du run, sans faux statut de nouveau déblocage permanent. | [Q221](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-222-01 | Spécialisation dominante | Héros feu ; boosters avec cartes feu et cartes hors élément. | Assistant privilégie feu parmi cartes disponibles selon compatibilité du sphérier. | [Q222](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-222-02 | Rareté non dominante | Légendaire hors synergie et commune utile au héros. | La légendaire n’est pas obligatoirement sélectionnée pour sa seule rareté. | [Q222](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-222-03 | Aucune synergie | Héros polyvalent sans orientation dominante. | Assistant utilise critères subsidiaires de cohérence, sans inventer de cartes. | [Q222](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-222-04 | Déterminisme | Même sphérier, pool d’instances et paramètres. | Même composition et même répartition deck/réserve. | [Q222](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-223-01 | Base non obligatoire | 30 cartes de boosters et 20 de base disponibles. | Un deck actif de 40 peut contenir moins de 20 cartes de base. | [Q223](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-223-02 | Remplacer base | Déplacer une base vers réserve et booster vers deck. | Transfert permis si composition finale valide. | [Q223](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-223-03 | Conserver identités | Une carte de base entre et sort du deck actif. | Même instance et même décompte global ; aucune duplication. | [Q223](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-223-04 | Limiter au pool | Une carte débloquée n’a pas été attribuée parmi les 50. | Elle ne peut pas être insérée manuellement avant le combat. | [Q223](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-224-01 | Socle fixe débutant | Aucun nœud de variante acquis. | 20 exemplaires de base selon liste fixe de départ. | [Q224](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-224-02 | Substitution autorisée | Nœud de variante du sphérier acquis avant ascension. | Remplacement(s) permis dans le socle attribué selon configuration du nœud. | [Q224](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-224-03 | Pas de catalogue libre | Nœud de variante acquis ; carte non autorisée par le nœud. | Le joueur ne peut pas l’utiliser comme remplacement arbitraire du socle. | [Q224](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-224-04 | Socle et réserve distincts | Variante de base attribuée puis envoyée en réserve. | La réserve l’accepte (Q223) ; aucune base obligatoire dans le deck actif. | [Q224](../03-progression/ascension-start-boosters-and-autobuild.md) |

**Non-régression v2.3** : Q207 plafond de **quatre copies** deck+réserve incluant le socle et les deux boosters ; Q208/Q217 min/max standard 40/40 ; Q209 compétences permanentes et temporaires ; Q211–Q214 recherches pendant combat indépendantes de la préparation ; Q218 garantie Rare+ **seulement si compétence active et éligibilité**, sinon assouplissement Q219 ; Q220 ouverture **séquentielle** ; Q222 spécialisation du héros **prioritaire**, et non optimisation multicritère dominante ; Q223 **aucune base imposée dans le deck** ; Q224 variantes du socle **uniquement via compétences permanentes autorisées**.

**Blocage de conception ouvert** : le mécanisme exact Q219 de secours pour un pool incapable de fournir 50 copies légales ne peut pas avoir de test de résultat positif définitif avant arbitrage. `T-219-03` porte uniquement sur la détection et l'absence de violation.


## Tests de conformité v2.4 — Q225 à Q234

> **40 scénarios nouveaux spécifiés, non exécutés.** Les tests de disponibilité de contenus exigent un jeu de données MVP réel ; ne pas interpréter leur rédaction comme une preuve de faisabilité. Référence normative : [catalogue et peuples v2.4](../03-progression/mvp-card-catalog-and-tribes.md).

| ID | Sujet | État initial / action | Résultat attendu |
|---|---|---|---|
| T-225-01 | Départ nouveau profil | Profil neuf avec catalogue fondamental configuré | Le pool débloqué rend possible 20+15+15 copies légales. |
| T-225-02 | Secours sans carte verrouillée | Pool pondéré épuisé, alternatives fondamentales débloquées | Les slots restants utilisent des copies fondamentales éligibles selon une règle déterministe. |
| T-225-03 | Plafond familial sous secours | Famille déjà à quatre copies dans socle et boosters | Aucune cinquième copie n’est tirée ou attribuée. |
| T-225-04 | Pool mathématiquement impossible | Moins de capacités légales que 50 exemplaires | Erreur de validation de contenu/configuration détectée sans boucle infinie ni déblocage artificiel. |
| T-226-01 | Substitution fixe | Même nœud actif et même socle sur deux ascensions | Les mêmes emplacements reçoivent les mêmes variantes. |
| T-226-02 | Sans nœud | Sphérier ne débloque aucune variante | Socle original inchangé, 20 copies. |
| T-226-03 | Réinitialisation sphérier | Réinitialiser le sphérier entre deux ascensions | Le socle de l’ascension suivante reflète les nœuds actifs, sans modifier l’ascension antérieure. |
| T-226-04 | Conflit non défini | Deux nœuds tentent de modifier le même emplacement sans priorité | Validation de contenu refuse l’ambiguïté ou requiert règle explicite ; pas de choix aléatoire silencieux. |
| T-227-01 | Quatre versions mélangées | 2 originales + 1 Feu + 1 Glace d’une même famille | Plafond familial atteint ; une cinquième variante est inéligible. |
| T-227-02 | Deck et réserve | 2 copies actives et 2 en réserve de même famille | Le compteur familial vaut 4. |
| T-227-03 | Familles différentes | Deux familles indépendantes avec copies respectives | Les plafonds sont appliqués séparément. |
| T-227-04 | Identifiants d’instance | Deux copies de la même variante | Chaque copie conserve son identité distincte lors des transferts. |
| T-228-01 | Socle amélioré | Nœud actif, exemplaire d’origine socle | La variante améliorée est attribuée. |
| T-228-02 | Booster non amélioré | Même famille tirée dans booster, nœud actif | La copie du booster conserve sa définition non améliorée. |
| T-228-03 | Déplacement vers réserve | Déplacer copie de socle améliorée du deck à la réserve | La version améliorée et l’origine sont conservées. |
| T-228-04 | Acquisition après combat | Récompense d’une famille améliorée dans le socle | La copie acquise ne change pas de version en raison du sphérier. |
| T-229-01 | Filtre de booster | Variante du sphérier existante et carte ordinaire de même famille débloquée | La variante n’est jamais candidate dans les boosters. |
| T-229-02 | Catalogue limité | Seules variantes du sphérier existent dans une famille du socle | Le booster ne tire pas ces variantes comme cartes indépendantes. |
| T-229-03 | Compte familial | Socle contient deux variantes et booster propose deux copies ordinaires | Quatre copies au total acceptées ; aucune cinquième. |
| T-229-04 | Secours strict | Pool de booster insuffisant avec variantes du sphérier non éligibles | Le secours n’introduit aucune variante réservée au socle. |
| T-230-01 | Budget calculé | 40 fondamentales, 30 variantes, 100 indépendantes | Le nombre de définitions est 170, distinct des copies de préparation. |
| T-230-02 | Socle de 20 | Catalogue fondamental contient 40 définitions | Une ascension n’attribue que 20 copies de socle selon ses règles. |
| T-230-03 | Cartes non débloquées | Catalogue indépendant de 100, profil au début | Toutes les 100 définitions ne sont pas automatiquement dans le pool débloqué. |
| T-230-04 | Famille et variante | Une famille possède trois variantes additionnelles | Quatre définitions peuvent partager une famille et un plafond commun de quatre copies. |
| T-231-01 | Trois groupes | Inventaire de 100 cartes indépendantes | Les cartes se classent en neutre, élémentaire ou hybride/avancé. |
| T-231-02 | Quotas non forcés | Répartition différente de 33/50/17, mais catalogue équilibré | La validation ne rejette pas seulement pour différence aux proportions illustratives. |
| T-231-03 | Carte hybride | Carte avec deux éléments/stratégies | La catégorie avancée/hybride peut porter plusieurs interactions. |
| T-231-04 | Compatibilité rareté | Cartes de toutes les catégories avec raretés Q181 | Catégorie de design et rareté sont deux axes distincts. |
| T-232-01 | Rôle principal | Carte attaque+pioche | Un rôle principal et des rôles secondaires peuvent être indexés. |
| T-232-02 | Quotas souples | Répartition différente de 25/15/20/15/15/10 | Le suivi signale l’écart sans le traiter comme violation normative. |
| T-232-03 | Couverture utilitaire | Catalogue comprend recherche/pioche | La catégorie fonctionnelle est prise en compte en conception. |
| T-232-04 | Diversité tactique | Cartes d’un même élément avec défense et attaque | Les rôles ne sont pas conditionnés exclusivement par l’élément. |
| T-233-01 | Synergie de peuple | Créature de peuple Nain, effet ciblant les Nains | L’effet filtre selon le peuple et non uniquement selon l’élément. |
| T-233-02 | Élément transversal | Deux créatures de peuples différents avec élément Feu | Un effet Feu peut s’appliquer aux deux selon ses critères. |
| T-233-03 | Archétype multiaxe | Deck mélange peuple, élément et rôle | Les axes de classification coexistent sans exclusion arbitraire. |
| T-233-04 | Créature sans peuple majeur | Créature de type Bête/Élémentaire suivant catalogue | Le moteur n’oblige pas à appartenir à l’un des quatre peuples principaux. |
| T-234-01 | Quatre peuples MVP | Catalogue MVP validé avec quatre peuples définis | L’inventaire signale exactement quatre peuples représentés. |
| T-234-02 | Ajout futur Gobelin | Charger une définition d’extension avec peuple Gobelin | Indexation, ciblage et inspection fonctionnent sans modification du moteur. |
| T-234-03 | Ajout futur Mort-vivant | Charger une définition d’extension de type Mort-vivant | Aucune règle de combat existante n’est cassée ; cible et sauvegarde restent compatibles. |
| T-234-04 | Aucun archétype forcé | Un peuple n’a que quelques cartes dans le MVP | L’existence du peuple ne requiert pas un deck tribal complet. |

**Non-régression :** Q207 limite de quatre copies sur deck+réserve, **par famille** si variantes Q227 ; Q208/Q217 deck standard 40/40 ; Q215 20 copies de base et 30 de boosters ; Q218–Q219 raretés et garanties conditionnelles ; Q220 boosters séquentiels ; Q222 proposition spécialisée ; Q223 cartes du socle non obligatoires dans deck ; Q224–Q229 variantes **du seul socle**, boosters sans variantes du sphérier. Le budget Q230 **≈170 définitions** ne modifie pas les 50 copies de préparation.

## Tests v2.5 — Q235–Q244 (spécifiés, non exécutés)

Les tests ci-dessous réutilisent les invariants Q13–Q14, Q26–Q27, Q111–Q124 et Q159–Q164. Ils ne créent pas un nouveau solveur concurrent.

| ID | Scénario | Attendu |
|---|---|---|
| T-235-01 | Indexation des quatre peuples MVP | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-235-02 | Charge d’un type Gobelin en extension | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-235-03 | Typage Humain distinct de classe de héros | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-235-04 | Sauvegarde avec nouveau type extensible | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-236-01 | Effet ciblant un Nain allié | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-236-02 | Deck mixte Humains-Elfes fonctionne | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-236-03 | Combinaison tribale et élémentaire | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-236-04 | Carte hors tribu reste jouable | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-237-01 | Nœud générique armure fonctionne pour Nain et Humain | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-237-02 | Bonus tribal ponctuel se combine à élément | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-237-03 | Pas de branche peuple obligatoire | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-237-04 | Réinitialisation hors ascension recalcule bonus | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-238-01 | Aura globale affecte cibles éligibles | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-238-02 | Bonus de rangée seulement pour bonnes cases | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-238-03 | Critère tribu filtre zone géométrique | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-238-04 | Inspection révèle les unités ciblées | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-239-01 | Voisins orthogonaux sur deux rangées | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-239-02 | Diagonale exclue de adjacent | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-239-03 | Carte mentionnant diagonale l’inclut | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-239-04 | Effet colonne et bord de plateau corrects | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-240-01 | Déplacement brise une aura | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-240-02 | Invocation active une aura | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-240-03 | Transformation de peuple retire un bonus | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-240-04 | Aucune activation FIFO par simple itération | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-241-01 | Perte PV max conserve blessures | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-241-02 | Deux unités létales identifiées dans même lot | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-241-03 | Destruction secondaire réévalue aura | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-241-04 | Perte de PV max ne déclenche pas ON_DAMAGE_TAKEN | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-242-01 | Morts simultanées en ordre canonique Q13/Q27 | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-242-02 | Réactions FIFO conservées après stabilisation | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-242-03 | Boucle de triggers bloquée par Q111/Q112 | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-242-04 | Budget causal Q113–Q120 bloque seulement descendance non admise | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-243-01 | Graphe acyclique donne résultat canonique Q161 | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-243-02 | Auras indépendantes recalculées localement | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-243-03 | Même état donne même replay Q164 | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-243-04 | Pas de consommation budget FIFO durant solveur aura Q162 | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-244-01 | Cycle sans point fixe neutralisé minimalement Q162 | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-244-02 | Tie-break sémantique canonique Q163 | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-244-03 | Effet indépendant reste actif | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-244-04 | Recalcul sur changement externe sans boucle infinie | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |

**État des tests : 40 cas spécifiés, non exécutés.** Q244 est testé comme régression de Q162–Q163.

## Tests v2.6 — Q245–Q254 (spécifiés, non exécutés)

Ces scénarios respectent les systèmes normatifs de FIFO, stabilisation, changements de zone, budgets causaux et sauvegardes existants.

| ID | Scénario | Mise en situation | Résultat attendu |
|---|---|---|---|
| T-245-01 | Peuple et faction indépendants | Créer un Humain de deux factions différentes | Même peuple, factions différentes ; filtres exacts indépendants. |
| T-245-02 | Types secondaires multiples | Une créature Mage et Guerrier | Les deux filtres de type la reconnaissent. |
| T-245-03 | Faction facultative | Créature sans faction | Validation, inspection et capacités ne requièrent aucune faction. |
| T-245-04 | Extension sans migration moteur | Ajouter un peuple Gobelin | Ciblage et sauvegarde acceptent le nouvel identifiant. |
| T-246-01 | Deck factions rivales | Mettre deux factions opposées dans le même deck | Deck légal si toutes les autres limites sont respectées. |
| T-246-02 | Bonus conditionnel insuffisant | Seulement 5 Nains pour seuil fictif de 8 | Carte jouable, bonus conditionnel inactif. |
| T-246-03 | Pool booster sans élément spécialisé | Sphérier feu, boosters sans cartes feu | Composition auto légale sans générer de carte feu. |
| T-246-04 | Socle neutre | Initialiser 20 cartes fondamentales | Aucun archétype imposé par la composition du socle. |
| T-247-01 | Instant avant main initiale | Deck avec 8 Nains puis distribuer 6 cartes | Condition de composition reste vraie après distribution. |
| T-247-02 | Réserve exclue | 7 Nains deck actif et 2 en réserve | Seuls les 7 du deck actif comptent. |
| T-247-03 | Deck change entre combats | Passer 1 Nain de réserve au deck | Condition réévaluée au combat suivant. |
| T-247-04 | Défausse durant combat | 8 Nains initialement, 4 défaussés | Condition reste figée ; snapshot replay identique. |
| T-248-01 | Rivalité seule | Deux factions rivales sans capacité spécifique | Aucun modificateur implicite. |
| T-248-02 | Effet contre faction | Carte ciblant faction ennemie explicitement | Bonus seulement selon texte de carte. |
| T-248-03 | Allié narratif sans effet | Deux factions alliées sans capacités | Aucun bonus automatique. |
| T-248-04 | Nouvelle faction | Charger une faction d’extension | Aucune table de rivalités obligatoire. |
| T-249-01 | Équipement vs artefact | Équiper une épée pendant une ascension | Aucun emplacement d’artefact consommé. |
| T-249-02 | Case plateau | Attacher un bouclier à une unité | Aucune case de créature occupée. |
| T-249-03 | Bonus standard | Équipement +2 attaque | Le calcul des statistiques existant l’intègre. |
| T-249-04 | Instance distincte | Deux objets identiques dans deux zones | Identités d’instance et snapshots distincts. |
| T-250-01 | Deux catégories | Un slot Arme et un Protection | Une arme et un bouclier coexistent. |
| T-250-02 | Deux armes | Créature avec Arme déjà occupé | Ne peut porter simultanément deux armes ; remplacement Q252. |
| T-250-03 | Catégorie Protection utilitaire | Équiper une amulette accordant pioche | Admissible dans Protection malgré effet non défensif. |
| T-250-04 | Pas de troisième slot | Créature avec deux équipements | Pas d’accessoire supplémentaire indépendant. |
| T-251-01 | Mort du porteur | Créature équipée détruite | Chaque objet est détaché et défaussé au bon propriétaire. |
| T-251-02 | Retour en main | Porteur équipé renvoyé en main | Équipements en défausse ; ne suivent pas le porteur. |
| T-251-03 | Bannissement | Porteur équipé banni | Équipements en défausse par défaut. |
| T-251-04 | Exception retour objet | Carte équipement indique retour en main | La destination explicite prime sur défaut. |
| T-252-01 | Remplacer arme | Épée remplace hache | Hache en défausse, épée en slot Arme. |
| T-252-02 | Remplacer protection | Anneau remplace bouclier | Bouclier en défausse, anneau en slot Protection. |
| T-252-03 | Refus restriction | Nouvelle arme non compatible avec créature | Attachement invalide ; ancienne arme conservée. |
| T-252-04 | Retrait bonus PV maximum | Ancienne protection accorde +3 PV max | Stabilisation Q240–Q244, aucun moteur parallèle. |
| T-253-01 | Créature sans slot | Dragon à zéro emplacement | Aucun équipement attachable. |
| T-253-02 | Créature un seul slot | Elfe avec Arme uniquement | Arme permise ; Protection refusée. |
| T-253-03 | Restrictions explicites | Épée réservée aux Guerriers | Mage sans type Guerrier refusé malgré slot Arme. |
| T-253-04 | Bonus conditionnel | Bouclier universel +1 si Nain | Autres peuples peuvent porter sans bonus nain. |
| T-254-01 | Sans durabilité | Équipement ordinaire après dix activations de combat | Pas d’usure ni destruction implicite. |
| T-254-02 | Charges consommées | Objet à 3 charges effectue une activation coûtant 1 | Instance passe à 2 charges, journal et replay cohérents. |
| T-254-03 | Zéro charges sans destruction | Carte désactive seulement une capacité à zéro | Carte reste équipée, capacité indisponible. |
| T-254-04 | Zéro charges avec défausse | Carte stipule défausse à zéro | Détachement et défausse ordinaires, stabilisation conforme. |

**État : 40 nouveaux tests d’acceptation spécifiés ; exécution non réalisée.** Non-régression obligatoire Q183 artefacts, Q207/Q227 quatre copies par famille, Q215/Q246 pool neutre + boosters, Q250/Q253 zéro à deux slots, Q251/Q252 transferts, Q254 charges sans durabilité globale.

## Tests v2.7 — Q255–Q264 (spécifiés, non exécutés)

Les tests suivants couvrent les décisions nouvelles de ciblage d’équipements et les **invariants de contenu du catalogue**. Ils ne réimplémentent pas la FIFO, les durées, la stabilisation ou les transferts de zone des versions antérieures. Les scénarios à décomptes indicatifs sont des contrôles **éditoriaux de conception**, pas des assertions bloquantes du moteur ou du générateur de boosters.

| ID | Scénario | Mise en situation | Résultat attendu |
|---|---|---|---|
| T-255-01 | Cible alliée par défaut | Une épée sans texte de ciblage spécial ; créature ennemie compatible | Cible ennemie refusée, alliée compatible acceptée. |
| T-255-02 | Cible ennemie explicite | Anneau maudit avec « ciblez un ennemi » | Créature ennemie admissible si emplacement Protection présent. |
| T-255-03 | Ennemi sans emplacement | Dragon ennemi avec zéro slot ; anneau maudit | Attachement refusé ; pas de contournement de Q253. |
| T-255-04 | Remplacement sur ennemi et propriétaire | Ennemi avec ancienne protection du joueur adverse ; nouvelle protection maudite | Ancien équipement défaussé chez SON propriétaire ; nouveau remplace ; départ du porteur => défausse du propriétaire de la malédiction. |
| T-256-01 | Synergie artisanat sur tirage valide | Boosters contiennent créature artisane et équipement éligibles | Les deux cartes peuvent interagir sans qu’un archétype soit imposé. |
| T-256-02 | Tirage sans équipement | Boosters du pool débloqué ne contiennent aucun équipement | Deck légal sans ajout artificiel d’objet. |
| T-256-03 | Synergie maudite explicite | Créature réagit aux équipements sur ennemis | Interaction possible seulement si les textes la prévoient. |
| T-256-04 | Synergie croisée | Équipement affecte une créature d’un autre peuple | Règles de peuple, faction, cible et effet réutilisées. |
| T-257-01 | Quota catalogue | Inventaire des 100 définitions indépendantes | Exactement 20 définitions de type Équipement. |
| T-257-02 | Quotas Arme / Protection souples | Répartition 11 Armes / 9 Protections proposée pour équilibrage | Total 20 respecté ; ajustement admis car cible 10/10 indicative. |
| T-257-03 | Non addition aux fondamentales | Inventaire contient 40 fondamentales et ~30 variantes | Les 20 équipements se trouvent dans les 100 indépendantes, non ajoutées au total ~170. |
| T-257-04 | Type et fonction indépendants | Amulette dans Protection avec effet offensif | Type Protection légitime malgré fonction offensive. |
| T-258-01 | Total exact | Compter types des 100 indépendantes | 50 Créatures + 30 Sorts + 20 Équipements = 100. |
| T-258-02 | Fonctions transversales | Sort de pioche également classé soutien | Une seule définition dans 30 Sorts ; pas de double comptage. |
| T-258-03 | Pas de quota booster | Pack de 15 avec proportions différentes de 50/30/20 | Pack valide si toutes règles de tirage, déblocage et plafonds respectées. |
| T-258-04 | Socle et ouverture inchangés | Démarrer ascension standard | 20 base + 2 × 15 booster ; 40 actives et 10 réserve ; proportions catalogue ne changent pas cela. |
| T-259-01 | Répartition cible | Inventorier 50 créatures indépendantes proposées | Cible 15/14/13/8 (total 50), déviations justifiées comme ajustements de conception. |
| T-259-02 | Rareté non déduite | Définir un jeune Dragon Commun et un Humain Rare | Deux raretés acceptées sans contrainte raciale automatique. |
| T-259-03 | Booster sans quota de peuple | Boosters proposés avec aucun Dragon | Pas de rejet du seul fait du quota catalogue. |
| T-259-04 | Taxonomie distincte | Elfe et Nain partageant une faction | La faction ne remplace pas le peuple dans les comptages. |
| T-260-01 | Identité dominante indicative | Comptage des 15 Humains dont 8 commandement/cooperation | Atteint environ 50–60 % comme cible de conception, sans erreur de validation runtime. |
| T-260-02 | Rôle alternatif | Nain offensif plutôt que défensif | Carte admissible, cohérente avec son peuple. |
| T-260-03 | Dragon soutien | Un des 8 Dragons spécialisé en soutien élémentaire | Profil accepté ; identité narrative maintenue. |
| T-260-04 | Unité mixte | Un Elfe soutien utilisé avec Humains | Deck autorisé ; pas de verrouillage par identité dominante. |
| T-261-01 | Quota passerelles | Marquer 8 créatures passerelles dans catalogue de 50 | Quota cible 6–10 atteint sans créer 8 cartes supplémentaires. |
| T-261-02 | Recouvrement hybride | Une créature passerelle est également hybride | Comptage des deux labels permis sur la même définition. |
| T-261-03 | Utilité hors synergie | Carte passerelle sans autre peuple sur plateau | Carte a un effet de base raisonnable, sans exiger de générer le peuple manquant. |
| T-261-04 | Booster sans passerelles | Pack valide ne contient aucune passerelle | Pas de reroll ou de garantie non prévue. |
| T-262-01 | Quota hybride | Marquer 15 créatures ayant au moins deux fonctions significatives | Entre 13 et 18 sur 50, sans dépasser 50 définitions. |
| T-262-02 | Fonctions non décoratives | Carte attaque mais ajoute un effet de protection situationnel substantiel | Profil hybride justifié par deux fonctions effectives. |
| T-262-03 | Double attribution | Créature hybride et évolutive appartenant à un peuple dominant | Une seule définition malgré plusieurs labels. |
| T-262-04 | Booster mono-rôle | Pack ne contient que créatures spécialisées | Aucune obligation de tirage d’hybrides. |
| T-263-01 | Population évolutive | Marquer 6 créatures évolutives sur 50 | Cible 5–8 atteinte, cartes non ajoutées au total. |
| T-263-02 | Condition propre à carte | Dragon avec progression à l’usage de sorts feu | Seule la condition écrite incrémente le compteur, pas un niveau global automatique. |
| T-263-03 | Fin du combat | Progression acquise pendant un combat puis combat suivant | Pas de conservation par défaut de progression de combat. |
| T-263-04 | Lisibilité et replay | Progression d’une carte par événement et franchissement de seuil | Indicateur et journal conformes, mêmes résultats en replay déterministe. |
| T-264-01 | Nombre de cartes | Marquer 10 définitions indépendantes à contrepartie | Cible 8–12 atteinte ; toutes déjà comprises parmi les 100. |
| T-264-02 | Répartition entre types | 4 créatures, 4 sorts et 2 équipements à contrepartie | Aucune nouvelle catégorie ni augmentation des quotas Q258. |
| T-264-03 | Capacité facultative | Carte propose « activer : sacrifiez allié pour... » | Sans activation, aucun sacrifice ; avec activation, contrepartie selon texte et règles de coût. |
| T-264-04 | Contrepartie automatique explicite | Équipement donnant +ATQ et -PV max de manière continue | Malus appliqué selon texte, sans option universelle de refus ; règles de PV max existantes. |

**État : 40 scénarios supplémentaires spécifiés, 0 exécuté.** Vérifications de non-régression : propriété de l’équipement Q251, remplacement Q252, emplacements Q253, charges Q254, classification Q245, composition neutre et tirages Q215/Q246, 4 copies par famille Q207/Q227, risques de cycles Q111–Q124 et Q159–Q164.

## Tests v2.8 — Q265–Q274 (spécifiés, non exécutés)

**40 tests de comportement et de conformité du contenu**, sans exécution contre un moteur. Les attentes concernant des paramètres numériques encore ouverts vérifient les **contraintes éditoriales**, pas des valeurs seuils inventées. Les cas explicitement ouverts sont marqués « À SPÉCIFIER ».

| ID | Sujet | Situation / action | Attendu |
|---|---|---|---|
| T-265-01 | Profil dominant | Défenseur avec deux actions valides | Préférence défensive à intérêt tactique comparable. |
| T-265-02 | Opportunité décisive | Défenseur dispose d’une attaque létale légale | IA peut choisir l’attaque décisive plutôt que maintenir aveuglément sa défense. |
| T-265-03 | Règles communes | IA envisage action interdite faute de ressources | Action invalide exclue au même titre que pour le joueur. |
| T-265-04 | Boss spécifique | Boss avec priorités éditoriales particulières | Priorités appliquées sans contourner l’état ou les règles du moteur. |
| T-266-01 | Noyau fixe | Deux tirages du même archétype | Cartes signatures conservées ; cartes variables issues du pool compatible. |
| T-266-02 | Incompatibilité de pool | Variante candidate détruit la synergie requise | Candidat rejeté selon contraintes de composition. |
| T-266-03 | Indépendance joueur | Carte ennemie non débloquée par le joueur | L’ennemi peut l’utiliser ; elle n’est pas déverrouillée chez le joueur. |
| T-266-04 | Reprise déterministe | Rencontre générée puis partie sauvegardée/chargée | La même composition est restaurée, sans nouveau tirage. |
| T-267-01 | Progression double | Comparer début et fin d’ascension | Puissance et complexité tactique augmentent sans simple inflation brute. |
| T-267-02 | Début lisible | Rencontre des premières étapes | Archétype et menace pédagogiques, cohérents avec le palier. |
| T-267-03 | Diversité avancée | Deux rencontres tardives consécutives | Archétypes distincts malgré forte difficulté. |
| T-267-04 | Difficulté fixe | Même rencontre face à deux decks joueurs de force différente | Aucune augmentation/atténuation secrète du palier adversaire liée au deck. |
| T-268-01 | Aperçu honnête | Archétype nain défensif / équipement | Peuple et stratégie décrits conformément au contenu réellement généré. |
| T-268-02 | Cartes cachées | Variante ennemie retenue | Liste exacte et cartes variables restent non révélées. |
| T-268-03 | Préparation | Joueur édite le deck après l’aperçu | Échanges deck/réserve permis selon Q206. |
| T-268-04 | Boss narratif | Boss présenté avant combat | Identité narrative visible sans obligation de dévoiler les signatures. |
| T-269-01 | Minorité spéciale | Construire une série de rencontres | La majorité demeure classique, selon les contraintes de contenu validées. |
| T-269-02 | Annonce objectif | Entrer dans une rencontre spéciale | L’objectif est présenté avant lancement. |
| T-269-03 | Priorité héros | Héros joueur meurt avant achèvement de mission | Défaite immédiate Q VIC-001, aucune réussite différée implicite. |
| T-269-04 | Concurrence ouverte | Objectif complété et mort de héros au même commit atomique | À SPÉCIFIER avant implémentation : pas de priorité inventée ; VIC-001–006 restent normatifs. |
| T-270-01 | Espacement | Générer segment avec plusieurs créneaux spéciaux | Contraintes de séparation respectées. |
| T-270-02 | Progression | Scénario de fin avancée candidat pour premier étage | Scénario exclu par contraintes de progression. |
| T-270-03 | Diversité | Plusieurs missions spéciales d’une même ascension | La sélection respecte les contraintes de diversité configurées. |
| T-270-04 | Sauvegarde génération | Charger une ascension après placement | Identité et positions des missions inchangées. |
| T-271-01 | Deux familles | Lister les missions du MVP | Seules les familles Protection et Survie sont présentes. |
| T-271-02 | Refus famille hors périmètre | Scénario « interruption » marqué famille autonome MVP | Signalé comme hors périmètre MVP. |
| T-271-03 | Protection | Scénario définissant une unité à préserver | Objectif de protection explicitement décrit et annoncé. |
| T-271-04 | Survie | Scénario avec échéance | Échéance et objectif de résistance explicitement décrits et annoncés. |
| T-272-01 | Protection passive | Mission avec érudit qui ne combat pas | Mission admissible ; comportement passif documenté. |
| T-272-02 | Protection active | Mission avec guérisseur capable de soutenir | Capacité existante utilisable dans les règles ordinaires. |
| T-272-03 | Visibilité cible | Avant combat avec gardien à protéger | Rôle, capacités et vulnérabilités affichés. |
| T-272-04 | Hors collection | PNJ de mission créé pour rencontre | Aucun ajout implicite aux 50 créatures collectionnables ni déblocage. |
| T-273-01 | Profil constant | Mission Survie à pression constante | Séquence de scénario respecte un niveau de menace relativement stable. |
| T-273-02 | Profil croissant | Mission Survie à pression croissante | Menace augmente selon programmation, non selon force du joueur. |
| T-273-03 | Profil en pics | Mission Survie avec phases alternées | Périodes de pression annoncées comme profil général, détails cachés. |
| T-273-04 | Non adaptation | Joueur change ses équipements avant mission | Pression programmée inchangée à difficulté identique. |
| T-274-01 | Plusieurs scénarios | Inventaire des missions Protection/Survie | Chaque famille dispose de plusieurs scénarios éditorialement conçus. |
| T-274-02 | Variante compatible | Changer adversaires dans pool du scénario | Identité, objectif et niveau de difficulté restent cohérents. |
| T-274-03 | Variante impossible | Cible de Protection non conforme au scénario | Variante écartée ; pas de génération libre au mépris des contraintes. |
| T-274-04 | Reprise variante | Sauvegarder puis charger une mission choisie | Même mission, même unité et mêmes cartes/variantes restituées. |

**Non-régression attendue :** VIC-001 à VIC-006, Q192 (difficulté fixe), Q206 (deck/réserve), Q215/Q246 (boosters débloqués), Q266/Q274 (variantes persistées), Q271=A (deux familles et non quatre), sauvegarde et replay. **Bilan : 40 cas spécifiés, 0 exécuté ; les critères de victoire des missions spéciales non encore décidés ne sont pas considérés comme implémentés.**

---

## Fichier : `09-technical/causal-budgets-and-replay.md`

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


## Budget technique vs budget temporel de présentation (v1.5)

Ne pas confondre les plafonds d’**exécution fonctionnelle** Q111–Q120 avec l’**objectif d’affichage** de 3–5 s par longue chaîne Q144. Voir [orchestrateur visuel Q135–Q144](../02-art-direction/tooltips-durations-and-vfx.md) ; celui-ci ne participe ni à l’empreinte fonctionnelle du rejeu ni au calcul des capacités.


## Extension v1.7 — Reproductibilité du solveur des auras

Les règles [Q161–Q164](../02-art-direction/spells-auras-and-continuous-effects.md) imposent un ordre canonique et une trace de neutralisation des dépendances cycliques ; versionner cette convention avec les règles gelées du combat. Les opérations atomiques validées continuent de produire les empreintes de Q122 et les checkpoints de Q123. Le solveur d’effets continus ne consomme pas les budgets de déclenchements causaux Q115–Q120.


## Référence de progression v1.9

**Choix de récompenses :** la [progression Q175–Q184](../03-progression/rewards-rarity-and-ascension.md) impose la persistance idempotente des offres et décisions, sans confondre avec journal de combat ou replay moteur.

---

## Fichier : `AGENTS.md`

# Instructions pour agents d'implémentation

1. Lire [README.md](README.md), puis le README du domaine et les fichiers associés au concept demandé.
2. Implémenter uniquement les règles portant le statut **VALIDÉ**. Une règle **OUVERTE** ou **PROPOSÉE** exige une décision explicite, ou une hypothèse isolée/paramétrable clairement documentée pour un prototype.
3. Conserver les IDs de règles dans les tests et les commentaires utiles.
4. Moteur de combat indépendant du rendu Phaser. État et actions déterministes ; animations consomment le journal d'événements, ne pilotent pas les règles.
5. Préserver l'identité des créatures et des cibles (ID d'instance), même après disparition de la source. Ne pas reciblER implicitement.
6. Vérifier les dépendances et les scénarios [acceptance-tests.md](09-technical/acceptance-tests.md).
7. Phaser/HTML/JS : une interface polished n'autorise pas à inventer des mécaniques.


## Extension v0.8 : dégâts effectifs et événements

Pour implémenter `ON_DAMAGE_DEALT`, `ON_DAMAGE_TAKEN`, le vol de vie, les protections multiples et `ON_LETHAL_PREVENTED`, lire en priorité [damage-attribution.md](01-combat/damage-attribution.md), puis [damage-prevention.md](01-combat/damage-prevention.md), [effect-resolution.md](01-combat/effect-resolution.md) et [acceptance-tests.md](09-technical/acceptance-tests.md). Ne pas confondre déclenchement collectif et valeur quantitative attribuée. Aucune capacité déclenchée n'interrompt une opération atomique.

## Référence croisée v1.2

**Mise à jour v1.2 :** lire [règles de tour et de sécurité FIFO](01-combat/turn-control-and-loop-safety.md) pour Q105–Q114. Les arbitrages de causalité Q115 ont été validés en v1.3 (voir ci-dessous).


## Référence croisée v1.3

Pour les règles **VALIDÉES Q115–Q124**, lire [budgets, réservations, journal et compatibilité](09-technical/causal-budgets-and-replay.md) et [scénarios de tests](09-technical/acceptance-tests.md). Les budgets chiffrés et noms d’API restent **PROPOSÉS**. Q115 n’est plus ouverte.



## Interface — Q125–Q134 (v1.4)

Pour les créatures, lire [le module d'identité visuelle et d'inspection](02-art-direction/card-and-board-ui.md). La carte d'origine reste inchangée ; le panneau doit présenter ATQ finale, PV actuels/max effectifs, protections et **tous les effets actifs**. Les changements visuels ne modifient pas les règles de combat ou de replay.


## Interface — Q135–Q154 (v1.5–v1.6)

La présentation des effets/échéances/VFX est spécifiée dans [tooltips et durées](02-art-direction/tooltips-durations-and-vfx.md) et les nouveaux comportements de décor, grille contextuelle, simulation prévisionnelle isolée, calcul asynchrone non bloquant, validation moteur et modes d'entrée dans [plateau et prévisualisations](02-art-direction/board-and-tactical-preview.md).

**Ne jamais** confondre prévisualisation et engagement ; ne pas consommer le RNG réel, ne pas modifier la FIFO ou les réservations logiques en prévision. Le bouton/drag de placement est revalidé par le moteur au commit. Les 40 [tests Q145–Q154](09-technical/acceptance-tests.md) sont seulement des critères d'acceptation, non des tests exécutés. Q155–Q164 sont validées ; Q165 est ouverte.


## Extension v1.7 — Effets continus et previews

Lire [Q155–Q164](02-art-direction/spells-auras-and-continuous-effects.md) avant d’implémenter des zones, buffs, auras ou cycles. Même solveur déterministe/versionné pour partie et prévision, mais preview isolée sans fuite d’information cachée ; rendus et VFX ne sont pas la source de vérité. Voir [tests d’acceptation](09-technical/acceptance-tests.md). Les détails de l’algorithme canonique de neutralisation et les valeurs concrètes de budgets restent ouverts.

## Règles UI journal Q165–Q174 — v1.8

Lire [le journal de combat et l'inspection historique](02-art-direction/combat-journal-and-inspection.md) pour toute fonction d'historique. Ne jamais révéler une entrée avant son point de présentation VFX ni exposer les données cachées dans la recherche ou les résumés. Le journal V1 est secondaire : pas de graphe causal interactif, de replay graphique ni de simulations supplémentaires pour le produire. Tests documentés : [T-165-* à T-174-*](09-technical/acceptance-tests.md).

## Règles normatives Q195–Q204 — v2.1

Avant d’implémenter boutiques, tirage, achat ou récompense de carte, lire [boutiques, rotation et limites](03-progression/merchant-stock-and-deck-limits.md), puis [récompenses](03-progression/rewards-rarity-and-ascension.md) et [tours](03-progression/towers-merchants-and-unlocks.md). Quatre copies par identité dans le deck ; filtrer avant tirage et revalider au commit. Une compensation automatique Q178 s’applique si **zéro** carte est éligible ; monnaie et EXP Q179 restent acquises. RNG de run déterministe, actions idempotentes et sauvegarde des stocks/compteurs. Les 40 tests nouveaux sont **non exécutés**.

## Règles normatives v2.2 — Q205–Q214
Pour tout transfert entre deck actif et réserve, taille évolutive, recherche dans la pioche ou fatigue : lire [deck et réserve Q205–Q209](03-progression/deck-reserve-and-capacity.md) et [recherches/fatigue Q210–Q214](01-combat/deck-search-and-fatigue-v22.md). **Attention :** Q210 **remplace** les dégâts fixes de fatigue Q41 par 1,2,3… PV perdus directement ; Q207 impose quatre copies **deck+réserve** ; Q214-A impose l’affichage de **chaque exemplaire séparément**, même identique (contrairement à la suggestion non retenue de regroupement en Q213). Respecter les invariants RNG/FIFO et les tests [T-205 à T-214](09-technical/acceptance-tests.md).

## Consolidation v2.7

Pour la conception ou validation des 100 cartes indépendantes, lire [module catalogue Q255–Q264](03-progression/independent-card-catalog-and-synergies-v27.md) et [tests T-255–T-264](09-technical/acceptance-tests.md). **Ne pas interpréter les sous-populations passerelles/hybrides/évolutives comme des cartes additionnelles ; ne pas transformer les quotas éditoriaux de conception en quotas de boosters.**

---

## Fichier : `DECISIONS.md`

# Journal des décisions Q01–Q254

Toutes les décisions ci-dessous ont été exprimées par le concepteur. Q124 est validée ; les règles non décidées restent explicitement ouvertes.

| Question | Choix | Résumé | Fichier propriétaire |
|---|---|---|---|
| Q01 | B | Défense = soutien, protection, pas d'attaque normale | [battlefield](01-combat/battlefield.md) |
| Q02 | A | Défenseur intercepte si ligne d'attaque absente | [battlefield](01-combat/battlefield.md) |
| Q03 | A | Contester les colonnes ennemies non contestées avant déploiement libre | [summoning](01-combat/summoning.md) |
| Q04 | A | Invocation libre dans les deux lignes | [summoning](01-combat/summoning.md) |
| Q05 | C | Déplacement naturel vertical seulement ; horizontal par effet | [movement](01-combat/movement.md) |
| Q06 | B / A / A | 1 mana ; une fois par créature/tour ; possible dès l'invocation | [movement](01-combat/movement.md) |
| Q07 | B | Permutation de deux alliés d'une colonne pour 1 mana, consomme leurs déplacements | [movement](01-combat/movement.md) |
| Q08 | B | Déplacements par effets ignorent les limites naturelles ; arrivée libre sauf mention | [movement](01-combat/movement.md) |
| Q09 | A | Seul le camp actif attaque à la fin de son tour ; pas de riposte normale | [turn-sequence](01-combat/turn-sequence.md) |
| Q10 | B | Attaques colonne 1 vers 6 ; événements résolus entre colonnes | [damage-resolution](01-combat/damage-resolution.md) |
| Q11 | A + Piétinement | Dégâts résiduels perdus sauf Piétinement jusqu'au héros | [damage-resolution](01-combat/damage-resolution.md) |
| Q12 | B | Fin de l'attaque avant effets de mort | [event-queue](01-combat/event-queue.md) |
| Q13 | A | Simultanés : actif puis inactif, gauche→droite, attaque avant défense | [event-queue](01-combat/event-queue.md) |
| Q14 | A | File FIFO pour les réactions en chaîne | [event-queue](01-combat/event-queue.md) |
| Q15 | A | Mort du héros immédiate à 0 PV, arrêt du combat | [victory](01-combat/victory-and-defeat.md) |
| Q16 | B | Mort simultanée des deux héros = défaite du joueur | [victory](01-combat/victory-and-defeat.md) |
| Q17 | B + prévention | Empêcher les boucles dès la conception ; neutraliser répétitions en dernier recours | [event-queue](01-combat/event-queue.md) |
| Q18 | B | Déclenchements suite aux dégâts différés jusqu'à fin d'attaque | [event-queue](01-combat/event-queue.md) |
| Q19 | A | Effet en attente survit à la disparition de sa source | [event-queue](01-combat/event-queue.md) |
| Q20 | A + mana perdu | Cible devenue invalide : effet échoue, sans remboursement | [targeting](01-combat/targeting.md) |
| Q21 | A | Piétinement traverse uniquement une cible effectivement éliminée ; protections diminuent le résiduel | [damage-prevention](01-combat/damage-prevention.md) |
| Q22 | A | Ordre fixe : armure → bouclier → PV → protection létale | [damage-prevention](01-combat/damage-prevention.md) |
| Q23 | A | Une seule protection létale consommée par événement létal ; les autres conservées ; départage déterministe encore ouvert | [damage-prevention](01-combat/damage-prevention.md) |
| Q24 | A | Protections létales temporaires prioritaires sur permanentes | [damage-prevention](01-combat/damage-prevention.md) |
| Q25 | A | Une attaque à zéro dégât déclenche ON_ATTACK, pas les déclencheurs de perte effective de PV | [damage-resolution](01-combat/damage-resolution.md) |
| Q26 | A | Bonus PV max et PV actuels évoluent ensemble ; perte du bonus potentiellement mortelle | [damage-resolution](01-combat/damage-resolution.md) |
| Q27 | A | Dégâts de zone simultanés ; morts groupées, déclenchements différés | [damage-resolution](01-combat/damage-resolution.md) |
| Q28 | A | Le joueur commence toujours le combat | [turn-sequence](01-combat/turn-sequence.md) |
| Q29 | B | Mal d'invocation : attaque normale seulement à partir du prochain tour personnel | [turn-sequence](01-combat/turn-sequence.md) |
| Q30 | C | Mana hybride : initial, capacité actuelle et plafond | [hero-deck-mana](01-combat/hero-deck-mana.md) |
| Q31 | A/A | Restauration complète en début de tour ; mana non dépensé perdu en fin de tour | [hero-deck-mana](01-combat/hero-deck-mana.md) |
| Q32 | D + base +1 | Croissance +1 par défaut, modifiable par héros/artefacts/sorts | [hero-deck-mana](01-combat/hero-deck-mana.md) |
| Q33 | A | Bonus de croissance appliqué aux prochains tours, pas immédiatement | [hero-deck-mana](01-combat/hero-deck-mana.md) |
| Q34 | B | Bonus plafond sans gain immédiat de capacité ; gain immédiat possible au-delà capacité, limité au plafond | [hero-deck-mana](01-combat/hero-deck-mana.md) |

## Décisions nouvelles — v0.5

| Question | Choix | Décision | Document |
|---|---|---|---|
| Q35 | A | Début de tour : croissance → restauration → capacités → pioche | [document](01-combat/turn-sequence.md) |
| Q36 | A | 6 cartes initiales remplacent pioche normale du premier tour | [document](01-combat/draw-and-fatigue.md) |
| Q37 | A | Pioche normale de 1 carte par tour à partir du second tour, améliorable | [document](01-combat/draw-and-fatigue.md) |
| Q38 | A | Cartes piochées excédentaires envoyées automatiquement en défausse | [document](01-combat/hand-and-discard.md) |
| Q39 | B | Main max initiale 7, améliorable | [document](01-combat/hand-and-discard.md) |
| Q40 | B | Réduction main max : défausse des arrivées les plus récentes | [document](01-combat/hand-and-discard.md) |
| Q41 | B | Fatigue : perte directe de 1 PV par pioche impossible, ignore protections ordinaires | [document](01-combat/draw-and-fatigue.md) |
| Q42 | A | Pioche multiple séquentielle ; effets résolus entre chaque tentative | [document](01-combat/draw-and-fatigue.md) |
| Q43 | A | Aucun recyclage automatique du deck | [document](01-combat/hand-and-discard.md) |
| Q44 | A | Défausse unique conservant type, origine, raison | [document](01-combat/hand-and-discard.md) |

## Décisions nouvelles — v0.6 (Q45–Q54)

| Question | Choix | Décision | Document propriétaire |
|---|---|---|---|
| Q45 | A | Bannissement inaccessible durant le combat, sans perte permanente du deck/collection | [banishment](01-combat/banishment.md) |
| Q46 | A, précision | Résurrection à l'état de référence, blessures et bonus anciens effacés ; **nouveaux bonus possibles par la résurrection** | [resurrection](01-combat/resurrection.md) |
| Q47 | A | Résurrection soumise à la même priorité de placement qu'une invocation normale | [resurrection](01-combat/resurrection.md) |
| Q48 | A | Résurrection = nouvelle invocation ; mal d'invocation et capacités d'invocation + résurrection | [resurrection](01-combat/resurrection.md) |
| Q49 | A | Restaurer → appliquer nouveaux bonus → déclencher capacités | [resurrection](01-combat/resurrection.md) |
| Q50 | A | En file, capacités d'invocation avant capacités de résurrection | [resurrection](01-combat/resurrection.md) |
| Q51 | D | Interdire lancement sans emplacement légal ; si devenu illégal à résolution : échec sans remboursement | [resurrection](01-combat/resurrection.md) |
| Q52 | A | Résurrections multiples séquentielles, succès partiels conservés, ordre choisi au lancement | [resurrection](01-combat/resurrection.md) |
| Q53 | B | Récupération avec main pleine : carte immédiatement remise en défausse ; jamais de fatigue | [recovery](01-combat/recovery.md) |
| Q54 | A | Événements de transfert distincts selon motifs ; récupération débordante déclenche récupération puis défausse | [zone-events](01-combat/zone-events.md) |

**Mise à jour Q55 :** toutes les tentatives de résurrection terminent avant le traitement de leurs capacités : **VALIDÉ**.

## Décisions nouvelles — v0.7 (Q55–Q64)

| Question | Choix | Décision validée | Document propriétaire |
|---|---|---|---|
| Q55 | B | Finir toutes les tentatives de résurrection avant de résoudre les capacités ; chaque succès enregistre ses déclenchements dans l’ordre | [resurrection](01-combat/resurrection.md) |
| Q56 | B | Lire les caractéristiques à la résolution ; utiliser le dernier état connu de l’instance si elle a quitté le plateau | [instance-identity](01-combat/instance-identity.md) |
| Q57 | A | `cardId` persistant ; chaque arrivée sur le plateau crée un nouvel `instanceId`, distinct des vies précédentes | [instance-identity](01-combat/instance-identity.md) |
| Q58 | A | Quitter le plateau invalide définitivement le ciblage de l’ancienne instance ; retour sans reciblage | [targeting](01-combat/targeting.md) |
| Q59 | A | Conditions complètes de ciblage revérifiées à la résolution, y compris camp, ligne, colonne et type | [targeting](01-combat/targeting.md) |
| Q60 | A | Effets multicibles résolus partiellement sur chaque cible encore valide | [targeting](01-combat/targeting.md) |
| Q61 | A | Effets composés : opérations indépendantes par défaut ; conditions et indivisibilité explicites | [effect-resolution](01-combat/effect-resolution.md) |
| Q62 | B | Terminer toutes les opérations de l’effet composé avant de résoudre les capacités déclenchées, en les mettant en file au fil de l’effet | [effect-resolution](01-combat/effect-resolution.md) |
| Q63 | A | Tester victoire/défaite après commit simultané de chaque opération atomique, avant de continuer | [effect-resolution](01-combat/effect-resolution.md) |
| Q64 | A | Agréger par cible les dégâts simultanés compatibles avant application unique des protections ; séparer les composantes nécessitant des règles distinctes | [effect-resolution](01-combat/effect-resolution.md) |


## Décisions nouvelles — v0.8 (Q65–Q74)

| Question | Choix | Règle confirmée | Document |
|---|---|---|---|
| Q65 | A | `ON_DAMAGE_TAKEN` une fois par cible et opération atomique si PV réellement perdus | [Attribution](01-combat/damage-attribution.md) |
| Q66 | A | `ON_DAMAGE_DEALT` une fois par source effectivement contributrice, cible et opération | [Attribution](01-combat/damage-attribution.md) |
| Q67 | C | Attribution collective de l'éligibilité offensive après pertes de PV, indépendamment du quantum | [Attribution](01-combat/damage-attribution.md) |
| Q68 | B | Quantum attribué proportionnel, entier, somme égale aux PV perdus, zéro possible malgré déclenchement | [Attribution](01-combat/damage-attribution.md) |
| Q69 | A | Plus grands restes, égalités départagées de façon stable | [Attribution](01-combat/damage-attribution.md) |
| Q70 | A | Vol de vie différé dans FIFO, égal à la quantité attribuée, sans sauvetage rétroactif | [Attribution](01-combat/damage-attribution.md) |
| Q71 | A | Au maximum un événement d'absorption par type et cible pour chaque opération | [Attribution](01-combat/damage-attribution.md) |
| Q72 | A | Événements : armure, bouclier, perte de PV, prévention létale | [Attribution](01-combat/damage-attribution.md) |
| Q73 | A | Prévention létale : temporaire puis permanente ; expiration proche puis ancienneté puis ID | [Prévention](01-combat/damage-prevention.md) |
| Q74 | A | Réactions aux dégâts selon perte nette de PV ; prévention et capacités consommées distinctes et différées | [Attribution](01-combat/damage-attribution.md) |

## Décisions nouvelles — v0.9 (Q75–Q84)

| Question | Choix | Décision validée | Document propriétaire |
|---|---|---|---|
| Q75 | A | Soin plafonné aux PV maximum, surplus perdu sauf exception explicite | [Soins](01-combat/healing.md) |
| Q76 | A | `ON_HEAL` seulement si au moins 1 PV effectivement restauré ; valeur effective | [Soins](01-combat/healing.md) |
| Q77 | A | Soins simultanés regroupés par cible ; unique `ON_HEAL` ; attribution aux sources par plus grands restes | [Soins](01-combat/healing.md) |
| Q78 | A | Variations de PV max/current ne sont ni des soins ni des dégâts ; aucun déclencheur associé | [Effets temporaires](01-combat/temporary-effects.md) |
| Q79 | A | Mort par retrait de bonus : protections létales générales applicables ; `ON_DEATH` ou `ON_LETHAL_PREVENTED` | [Effets temporaires](01-combat/temporary-effects.md) |
| Q80 | A | Tous les effets expirant au même instant retirés atomiquement ; protections sur le résultat global | [Effets temporaires](01-combat/temporary-effects.md) |
| Q81 | A | Durée en tours personnels du camp ayant appliqué l'effet ; « fin du tour » = tour courant | [Effets temporaires](01-combat/temporary-effects.md) |
| Q82 | A | Début : expiration avant mana ; fin : après attaques et réactions, avant changement de camp | [Effets temporaires](01-combat/temporary-effects.md) |
| Q83 | A | Effet pendant tour adverse : prochain tour personnel = tour 1 ; propre tour en cours = tour 1 | [Effets temporaires](01-combat/temporary-effects.md) |
| Q84 | A | Un `ON_EFFECT_EXPIRED` par effet expiré après retrait atomique ; ordre déterministe | [Effets temporaires](01-combat/temporary-effects.md) |

| Q85 | A | Mort ou prévention avant événements individuels d’expiration, pour chaque cible | [Sources et contrôle](01-combat/source-control.md) |
| Q86 | A | Capacités pré-expiration d’une créature mourant dans la même opération éligibles | [Sources et contrôle](01-combat/source-control.md) |
| Q87 | A | Capacité accordée temporairement pouvant déclencher sur sa propre expiration | [Sources et contrôle](01-combat/source-control.md) |
| Q88 | A | Source de gameplay de capacité accordée = créature porteuse ; origine historique conservée | [Sources et contrôle](01-combat/source-control.md) |
| Q89 | A | Capacité différée conserve dernier état connu de l’instance disparue, vol de vie inclus | [Sources et contrôle](01-combat/source-control.md) |
| Q90 | A | Caractéristiques lues à la résolution ou dans dernier état connu si source absente | [Sources et contrôle](01-combat/source-control.md) |
| Q91 | A | Vol de vie vérifié lors des dégâts ; état figé dans ON_DAMAGE_DEALT | [Sources et contrôle](01-combat/source-control.md) |
| Q92 | A | Vol de vie bénéficie au contrôleur lors des dégâts, remplace destinataire propriétaire Q70 | [Sources et contrôle](01-combat/source-control.md) |
| Q93 | A | Cibles/références de camp fixées au déclenchement ; bénéfices selon contrôleur aux dégâts | [Sources et contrôle](01-combat/source-control.md) |
| Q94 | A | Prise de contrôle conserve instanceId, cardId, états et capacités ; change controllerId | [Sources et contrôle](01-combat/source-control.md) |

## Décisions nouvelles — v1.1 (Q95–Q104)

| Question | Option | Décision validée | Document propriétaire |
|---|---|---|---|
| Q95 | E personnalisée | Placement choisi par nouveau contrôleur selon toutes les règles ordinaires d’invocation. | [Transferts et contrôle](01-combat/control-transfers.md) |
| Q96 | A | Sans case au lancement : action illégale ; devenue impossible à la résolution : échec sans remboursement. | [Transferts et contrôle](01-combat/control-transfers.md) |
| Q97 | A | Retour obligatoire au camp précédent ; si aucune case légale : mort de placement et défausse du propriétaire. | [Transferts et contrôle](01-combat/control-transfers.md) |
| Q98 | A | Protection létale ordinaire inapplicable à une mort de placement ; ON_DEATH sans dégâts. | [Transferts et contrôle](01-combat/control-transfers.md) |
| Q99 | A | Contrôles superposés indépendants ; le plus récent encore actif détermine le contrôleur. | [Transferts et contrôle](01-combat/control-transfers.md) |
| Q100 | A | Expirations simultanées : recalcul global et au plus un transfert, aucun mouvement si contrôleur final identique. | [Transferts et contrôle](01-combat/control-transfers.md) |
| Q101 | A | Retours concurrents : camp de destination choisit les unités accueillies et leurs emplacements. | [Transferts et contrôle](01-combat/control-transfers.md) |
| Q102 | A | Transferts croisés : les cases libérées par les départs simultanés servent aux arrivées. | [Transferts et contrôle](01-combat/control-transfers.md) |
| Q103 | A | Camp actif choisit les placements en premier, puis camp adverse informé ; commit atomique. | [Transferts et contrôle](01-combat/control-transfers.md) |
| Q104 | A | ON_CONTROL_CHANGED une fois par changement effectif réussi ; ordre mort/prévention → contrôle → expiration. | [Transferts et contrôle](01-combat/control-transfers.md) |

## Consolidation v1.2 — décisions VALIDÉES Q105 à Q114

| Question | Choix | Résumé | Fichier propriétaire |
|---|---|---|---|
| Q105 | A | Mal d’invocation sur prise de contrôle effective, sans ON_SUMMON ; exception explicite possible. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |
| Q106 | A | Premier tour personnel du nouveau contrôleur bloqué, même transfert hors tour et retour. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |
| Q107 | A | Capacités ON_TURN_START/ON_TURN_END selon le contrôleur au déclenchement, sans rétroactivité. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |
| Q108 | A | Attaques + réactions → ON_TURN_END complet → expirations atomiques + réactions → changement de camp. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |
| Q109 | A | Échéances strictes, pas de durée minimale ; prolongation même effectInstanceId, sans expiration. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |
| Q110 | A | Effet créé après échéance expire après opération atomique ; réaction ajoutée en fin de FIFO. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |
| Q111 | A | Cycle non progressif : interruption ciblée du prochain déclenchement répétitif ; garde-fou indépendant. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |
| Q112 | A | Détection par signature fonctionnelle du combat et FIFO ordonnée, identifiants neutres normalisés. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |
| Q113 | A | Budget configurable par chaîne, interruption de branche ; exemple 1 000 non définitif. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |
| Q114 | A | Conserver tous les événements déjà en FIFO ; empêcher seulement nouveaux descendants branche bloquée. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |


## Consolidation v1.3 — décisions Q115 à Q124

| Question | Choix | Résumé | Fichier propriétaire |
|---|---|---|---|
| Q115 | A | Résolution multicausale unique ; causes et branches préservées ; branche bloquée non réactivable. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |
| Q116 | A | Triple plafond configurable et versionné : branche, chaîne globale, opération initiale. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |
| Q117 | A | Une unité par branche contributrice active, une seule unité par chaîne et opération. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |
| Q118 | A | Réservation atomique à l’admission FIFO ; capacités admises garanties ; pas de dépassement. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |
| Q119 | A | Réservations multicausales immuables ; libération atomique à l’annulation ; blocage de branche permanent. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |
| Q120 | A | Déclenchement refusé définitivement ; crédits libérés réservés aux admissions futures. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |
| Q121 | A | Journal déterministe complet + instantanés périodiques ; états, causes, budgets, RNG et choix traçables. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |
| Q122 | A | Empreinte canonique après chaque commit atomique ; arrêt et diagnostic à première divergence. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |
| Q123 | A | Sauvegarde entre commits atomiques, FIFO non vide admise ; restauration sans double exécution. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |
| Q124 | A | Versions de règles/cartes/PRNG/budgets figées par combat ; incompatibilité explicite si dépendance manquante ; RPG migrable entre combats. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |

**Q125 validée** : voir le lot v1.4 ci-dessous.


## Consolidation v1.4 — décisions Q125 à Q134

| Question | Choix | Résumé | Document propriétaire |
|---|---|---|---|
| Q125 | A | Moteurs/règles historiques archivés et chargés à la demande tant que sauvegardes/replays restent officiellement pris en charge. | [Spécification](09-technical/causal-budgets-and-replay.md) |
| Q126 | Hearthstone / Magic | Fantasy illustrée riche et colorée, identité originale et forte lisibilité des cartes. | [Spécification](02-art-direction/card-and-board-ui.md) |
| Q127 | D personnalisée | Carte premium riche dans la main/inspection ; jeton compact portrait sur plateau ; tooltip et clic pour détails. | [Spécification](02-art-direction/card-and-board-ui.md) |
| Q128 | D | Jeton adaptatif avec portrait, ATQ et PV toujours visibles, états tactiques importants uniquement. | [Spécification](02-art-direction/card-and-board-ui.md) |
| Q129 | D | Médaillon circulaire/ovale à socle tactique, camp reconnaissable. | [Spécification](02-art-direction/card-and-board-ui.md) |
| Q130 | A | ATQ en bas à gauche, PV en bas à droite, états sous le portrait. | [Spécification](02-art-direction/card-and-board-ui.md) |
| Q131 | A | Valeurs numériques et couleurs avec symboles ; armure et bouclier distincts, PV actuels sur jeton. | [Spécification](02-art-direction/card-and-board-ui.md) |
| Q132 | A personnalisée | Maximum 3 icônes prioritaires et +N ; clic ouvre carte complète avec tous bonus/malus. | [Spécification](02-art-direction/card-and-board-ui.md) |
| Q133 | A personnalisée | Inspection de la carte d’origine inchangée, panneau latéral séparé pour modifications. | [Spécification](02-art-direction/card-and-board-ui.md) |
| Q134 | B personnalisée | Panneau exhaustif avec ATQ finale et PV/défense effective clairement visibles, protections et calcul des effets. | [Spécification](02-art-direction/card-and-board-ui.md) |

**Q135 validée** : voir lot v1.5 ci-dessous.


## Consolidation v1.5 — Q135 à Q144

| Question | Choix | Décision | Module propriétaire |
|---|---|---|---|
| Q135 | A | ATQ/PV effectifs codés par couleur et flèche ; blessure différente de réduction de PV max. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |
| Q136 | C | Tooltip tactique condensé : stats finales, tous effets, protections et échéances ; clic pour sources/texte détaillés. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |
| Q137 | A | Ordre fixe par catégorie, ancienneté dans la catégorie ; une ligne et une durée par effectInstanceId, aucune fusion. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |
| Q138 | A | Échéances naturelles explicites, temporaires/permanentes/conditionnelles ; calendrier du créateur. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |
| Q139 | Personnalisée | Symbole de prise de contrôle parmi états prioritaires ; durée des autres effets inchangée, propriétaire conservé. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |
| Q140 | B + principe global | Changement de durée signalé par bref feedback ; chaque action/effet donne un retour expressif et lisible. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |
| Q141 | C | Animations juicy hiérarchisées, rythme adaptatif, accessibilité, spectacle proportionné sans ralentissement. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |
| Q142 | C | Orchestrateur de VFX indépendant, regroupement/accélération/superposition sans changer FIFO et résultats. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |
| Q143 | A + précision | Nombres flottants dégâts/soins et protections distincts ; effets puissants : éclairs, halos, secousses. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |
| Q144 | B | Objectif indicatif global de 3–5 s pour chaîne complexe, avec rythme adaptatif et moments décisifs préservés. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |




## Consolidation v1.6 — Décisions Q145–Q154

| Question | Choix | Décision | Fichier propriétaire |
|---|---|---|---|
| Q145 | B + précision | Plateau fantasy premium, grille subtile ; V1 un seul décor riche, architecture prévue pour variantes futures par étape/tour/biome/boss. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |
| Q146 | B | Illustration principalement fixe, quelques animations d'ambiance discrètes, réductibles ; priorité au gameplay. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |
| Q147 | B personnalisé | Camps distingués subtilement ; épée/bouclier et marquages contextuels seulement au survol, focus ou drag-and-drop, pas de surcharge permanente. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |
| Q148 | B | Cases valides révélées ; interdites neutres sauf tentative ciblée avec retour et explication. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |
| Q149 | C | Sélection créature → simulation des conséquences pertinentes de la prochaine phase de combat plutôt que simple cible/trajectoire. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |
| Q150 | B | PV futurs temporaires `actuel → prévu`, crâne/protections/`?` contextuels ; détail en inspection. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |
| Q151 | C | Prévisions mises à jour sur case valide durant drag-and-drop, cache lié à l'état, calcul non bloquant. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |
| Q152 | C | Résultats certains, incertains, en calcul, indisponibles explicites ; budget de prévision indépendant, non bloquant. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |
| Q153 | B | Dépôt immédiat sans confirmation, revalidation moteur, animation si succès, retour visuel si refus. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |
| Q154 | C | Drag-and-drop, clic-clic et tactile cohérents ; prévisions accessibles sans hover ; annulation sans effet tant qu'aucune validation n'a eu lieu. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |

**Q155–Q164 validées en v1.7. Q165 ouverte.**


## Consolidation v1.7 — Décisions Q155–Q164

| Question | Choix | Décision | Fichier propriétaire |
|---|---|---|---|
| Q155 | C | Prévisualisation des sorts/capacités ciblés via moteur commun isolé, sans fuite d’information cachée. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |
| Q156 | B + précision | Même langage visuel pour une ou plusieurs cibles ; informations individuelles conservées, zone discrète. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |
| Q157 | A + précision | Sur plateau, valeurs finales prévues pour buffs/debuffs ; avant/après dans inspection. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |
| Q158 | A | Conditions futures expliquées en inspection, pas ajoutées aux caractéristiques immédiates du plateau. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |
| Q159 | B | Aura discrète au repos ; sélection de source révèle les bénéficiaires. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |
| Q160 | B | Cascades d'auras : état final immédiatement prévisible de chaque créature, détails au clic. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |
| Q161 | B | Graphe de dépendances, ordre stable, détection des cycles et solveur commun combat/preview. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |
| Q162 | B | Cycles ambigus / insolubles : neutralisation ciblée, temporaire, traçable des dépendances problématiques. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |
| Q163 | B | Priorités sémantiques, contraintes fondamentales préservées, neutralisation minimale, départage canonique stable. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |
| Q164 | B | Cohérence recalculée aux frontières atomiques nécessaires ; rendu VFX peut regrouper sans changer la logique. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |

**Q165 ouverte.** Les paramètres numériques, l’algorithme exact de départage canonique et les noms d’API ne sont pas encore validés.


## Décisions validées Q165–Q174 — v1.8

| Question | Choix | Résumé | Fichier propriétaire |
|---|---|---|---|
| Q165 | B | Feedback temporaire lors de la neutralisation ou réactivation d’une aura. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |
| Q166 | B + précision | Journal hiérarchique, masqué par défaut, consultable à la demande. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |
| Q167 | B | Panneau latéral escamotable pour le journal. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |
| Q168 | B | Survol/sélection d’un événement : mise en évidence contextuelle des créatures. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |
| Q169 | B | Résumé compact des créatures et inspection historique détaillée à la demande. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |
| Q170 | B | Historique par tour, recherche textuelle et filtres légers. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |
| Q171 | B | Résumé tactique et détail exhaustif à la demande. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |
| Q172 | A + contrainte de coût | Explications textuelles, sans navigation causale avancée en V1. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |
| Q173 | B | Conservation de l’historique complet du combat en cours. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |
| Q174 | B | Journal consultable pendant les animations sans pause ni fuite anticipée. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |

**Q175–Q184 validées en v1.9.** Le journal V1 reste volontairement léger et non central.


## Décisions validées Q175–Q184 — v1.9

| Question | Choix | Résumé | Fichier propriétaire |
|---|---|---|---|
| Q175 | B | Victoire expressive graduée : rapide en combat courant, plus spectaculaire contre boss ; VFX sans impact moteur. | [Progression](03-progression/rewards-rarity-and-ascension.md) |
| Q176 | B | Écran de récompenses fantasy dédié ; inspection, choix distingués des gains automatiques, animations brèves. | [Progression](03-progression/rewards-rarity-and-ascension.md) |
| Q177 | B | Trois cartes éligibles proposées ; inspection puis choix d’une seule ou alternative Q178. | [Progression](03-progression/rewards-rarity-and-ascension.md) |
| Q178 | C | Refuser les trois cartes contre compensation en ressources visible avant confirmation. | [Progression](03-progression/rewards-rarity-and-ascension.md) |
| Q179 | B | Gains automatiques après chaque victoire : monnaie et EXP du héros. | [Progression](03-progression/rewards-rarity-and-ascension.md) |
| Q180 | C | Boss : gains renforcés + choix exceptionnel entre carte, artefact ou amélioration du héros. | [Progression](03-progression/rewards-rarity-and-ascension.md) |
| Q181 | C modifiée | Cinq rangs SANS mythique : Commun blanc, Peu commun bleu, Rare rouge, Épique violet, Légendaire or. | [Progression](03-progression/rewards-rarity-and-ascension.md) |
| Q182 | B + précision | Artefacts conservés pendant l’ascension ; finir la tour peut débloquer cartes et artefacts draftables lors des suivantes. | [Progression](03-progression/rewards-rarity-and-ascension.md) |
| Q183 | C | Nombre limité d’emplacements d’artefacts, capacité augmentable pendant une ascension, réinitialisée ensuite. | [Progression](03-progression/rewards-rarity-and-ascension.md) |
| Q184 | C | Améliorations temporaires du héros : caractéristiques ou capacités, au choix parmi propositions éligibles. | [Progression](03-progression/rewards-rarity-and-ascension.md) |

**Q185 ouverte :** usage de l’EXP, niveaux du héros et acquisition d’améliorations. Aucun seuil ni mode de persistance de l’EXP n’est encore fixé.


## Décisions validées Q185–Q194 — v2.0

| Question | Choix | Résumé | Fichier propriétaire |
|---|---|---|---|
| Q185 | B profondément personnalisée | Sphérier permanent de compétences/caractéristiques (PV, feu, etc.), conservé entre ascensions ; remplace le modèle simple de trois choix par niveau. | [Sphérier](03-progression/hero-sphere-and-skill-tree.md) |
| Q186 | B | EXP permanente, niveau permanent, points acquis à chaque niveau et conservés. | [Sphérier](03-progression/hero-sphere-and-skill-tree.md) |
| Q187 | C | Branches interconnectées, progression de proche en proche, passerelles et prérequis. | [Sphérier](03-progression/hero-sphere-and-skill-tree.md) |
| Q188 | C | Coût variable de chaque nœud selon sa valeur, avec respect des prérequis. | [Sphérier](03-progression/hero-sphere-and-skill-tree.md) |
| Q189 | B | Réinitialisation intégrale gratuite du sphérier uniquement hors ascension ; points restitués, niveau/EXP préservés. | [Sphérier](03-progression/hero-sphere-and-skill-tree.md) |
| Q190 | D personnalisée | Plusieurs tours ouvertes d’emblée ; quelques tours spéciales conditionnées par l’achèvement d’autres tours ; pas de niveau minimum imposé. | [Tours et boutiques](03-progression/towers-merchants-and-unlocks.md) |
| Q191 | B | Première victoire : déblocages permanents uniques ; victoires suivantes : récompenses répétables. | [Tours et boutiques](03-progression/towers-merchants-and-unlocks.md) |
| Q192 | A personnalisée | Difficulté des tours fixe ; les récompenses répétables de tours faciles perdent de l’intérêt à haut niveau. | [Tours et boutiques](03-progression/towers-merchants-and-unlocks.md) |
| Q193 | D personnalisée | Déblocages par succès, défis et combats, plus achats chez les marchands présents dans les tours ; certaines cartes exclusives à des marchands de tours données. | [Tours et boutiques](03-progression/towers-merchants-and-unlocks.md) |
| Q194 | Règle personnalisée | **Toute carte effectivement obtenue ou achetée est ajoutée définitivement au pool potentiel de draft futur** ; la copie de tentative disparaît en fin d’ascension ; ne pas confondre vu/acheté, ni déblocage/obtention garantie. | [Tours et boutiques](03-progression/towers-merchants-and-unlocks.md) |

**Q195 ouverte :** structure des inventaires des commerces (fixes, variables ou mixtes) et garantie d’accès aux exclusivités.


## Décisions validées Q195–Q204 — v2.1

| Question | Choix | Résumé | Fichier propriétaire |
|---|---|---|---|
| Q195 | C personnalisée | Inventaire marchand aléatoire ; certains sorts/cartes uniquement dans les pools de commerces de tours précises, jamais garantis. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |
| Q196 | B | Prix de référence par rareté et ajustements par carte, stables et affichés. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |
| Q197 | A | Monnaie temporaire perdue à la fin de chaque ascension, progression permanente conservée. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |
| Q198 | B personnalisée | Renouvellements payants sans plafond fixe ; chaque renouvellement successif coûte davantage. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |
| Q199 | A | Compteur de renouvellement indépendant par instance de marchand, persistant jusqu’à fin du run. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |
| Q200 | B | Un exemplaire par offre ; achat vide la place ; même carte peut réapparaître après renouvellement. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |
| Q201 | B personnalisée | Quatre exemplaires identiques maximum dans le deck, toutes raretés ; aucune rareté mythique. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |
| Q202 | B | Cartes déjà à quatre copies exclues du pool des boutiques, avec revalidation à l’achat. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |
| Q203 | B | Cartes déjà à quatre copies exclues des récompenses ; moins de trois offres si pool insuffisant. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |
| Q204 | B | Pool de récompenses vide : compensation en ressources Q178 automatique, sans écran de choix ; EXP et monnaie Q179 préservées. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |

**Q205 ouverte :** prochaine décision de conception. Les quantités et pourcentages illustratifs ne sont pas adoptés.

## Décisions validées Q205–Q214 — consolidation v2.2

| Question | Choix | Règle validée | Module normatif |
|---|---|---|---|
| Q205 | Personnalisée | Retirer une carte du deck actif = transfert réversible vers la réserve d’ascension, pas destruction ni perte du déblocage permanent. | [Deck et réserve](03-progression/deck-reserve-and-capacity.md) |
| Q206 | B | Réorganisation libre et gratuite du deck actif/réserve entre combats ; verrouillage pendant le combat. | [Deck et réserve](03-progression/deck-reserve-and-capacity.md) |
| Q207 | A | Quatre copies identiques possédées **deck actif + réserve réunis**, toutes raretés ; filtres marchands et récompenses en tiennent compte. | [Deck et réserve](03-progression/deck-reserve-and-capacity.md) |
| Q208 | Personnalisée | Minimum et maximum de deck évolutifs ; base initiale **40/40**, deck compact plus sensible à la fatigue ; grand deck soutenu par recherche. | [Deck et réserve](03-progression/deck-reserve-and-capacity.md) |
| Q209 | C | Limites de deck modifiables par sphérier permanent et effets temporaires de run cumulables, dans bornes à équilibrer. | [Deck et réserve](03-progression/deck-reserve-and-capacity.md) |
| Q210 | B | Fatigue progressive **1/2/3… PV perdus directement** sur pioches impossibles, par héros et combat ; **remplace montant fixe Q41**, sans recyclage Q43. | [Fatigue et recherche](01-combat/deck-search-and-fatigue-v22.md) |
| Q211 | C | Recherches ciblées ou aléatoires selon le texte du sort, critères explicites, RNG déterministe. | [Fatigue et recherche](01-combat/deck-search-and-fatigue-v22.md) |
| Q212 | C | Destination et mélange définis par l’effet ; aucune fatigue sur recherche sans résultat, autres instructions indépendantes préservées. | [Fatigue et recherche](01-combat/deck-search-and-fatigue-v22.md) |
| Q213 | B | Recherche ciblée : seules instances éligibles inspectables, pas d’ordre de pioche ; recherche aléatoire sans sélecteur. | [Fatigue et recherche](01-combat/deck-search-and-fatigue-v22.md) |
| Q214 | **A** | Chaque copie éligible affichée **séparément**, même strictement identique, sélection explicite d’une instance ; **aucun regroupement**. | [Fatigue et recherche](01-combat/deck-search-and-fatigue-v22.md) |

**Q215 ouverte :** prochaine question à arbitrer ; ne pas supposer de règle définitive non validée.

## Décisions validées Q215–Q224 — consolidation v2.3

| Question | Choix | Règle validée | Module normatif |
|---|---|---|---|
| Q215 | D adaptée | 20 cartes de base + 2 boosters de 15 cartes débloquées ; 50 exemplaires initiaux pour deck standard 40 et réserve 10 ; pas de construction libre depuis la collection. | [Préparation](03-progression/ascension-start-boosters-and-autobuild.md) |
| Q216 | C | Composition automatique immédiatement jouable, avec changements manuels facultatifs. | [Préparation](03-progression/ascension-start-boosters-and-autobuild.md) |
| Q217 | A | Confirmer la taille de base 40/40 (Q208), avec capacité évolutive Q209. | [Deck et réserve](03-progression/deck-reserve-and-capacity.md) |
| Q218 | B adaptée | Probabilités pondérées par rareté ; compétences du sphérier pouvant accorder des garanties par booster. | [Préparation](03-progression/ascension-start-boosters-and-autobuild.md) |
| Q219 | B | Garanties satisfaites si possible, sinon assouplies sans carte verrouillée ni cinquième copie ; mécanisme exact de secours structurel encore ouvert. | [Préparation](03-progression/ascension-start-boosters-and-autobuild.md) |
| Q220 | **B** | Ouverture **successive** des deux boosters, 15 cartes révélées d’un coup par booster, animations passables. | [Préparation](03-progression/ascension-start-boosters-and-autobuild.md) |
| Q221 | B | Affichage compact, couleurs de rareté et indices de synergie, inspection et filtres facultatifs, transferts rapides. | [Préparation](03-progression/ascension-start-boosters-and-autobuild.md) |
| Q222 | **B** | L'assistant privilégie **la spécialisation du sphérier**, autres critères secondaires, sans privilégier la rareté. | [Préparation](03-progression/ascension-start-boosters-and-autobuild.md) |
| Q223 | C | Toutes les cartes de base peuvent être placées en réserve et remplacées dans le deck actif. | [Préparation](03-progression/ascension-start-boosters-and-autobuild.md) |
| Q224 | **D** | Socle initial fixe de 20 cartes ; des compétences permanentes débloquent progressivement des remplacements par variantes spécialisées ou plus fortes. | [Préparation](03-progression/ascension-start-boosters-and-autobuild.md) |

**Q225–Q234 :** décisions validées et détaillées ci-dessous ; les probabilités et quotas numériques non validés restent ouverts.

## Décisions validées Q225–Q234 — consolidation v2.4

| Question | Choix | Décision | Source normative |
|---|---|---|---|
| Q225 | B | Catalogue fondamental débloqué au départ ; secours déterministe à partir des cartes éligibles, sans carte verrouillée ni dépassement du plafond. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |
| Q226 | Personnalisée / A adaptée | Variantes du sphérier remplacent de façon déterministe les versions précédentes du socle de 20 exemplaires. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |
| Q227 | B | Variantes d'une même famille ; plafond de quatre copies **toutes versions confondues**. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |
| Q228 | A | Amélioration du sphérier limitée aux exemplaires d'origine socle, non appliquée aux acquisitions ordinaires. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |
| Q229 | Précision personnalisée | Variantes du sphérier exclues des boosters ; réservées aux cartes d'origine socle. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |
| Q230 | B puis révision personnalisée | Objectif MVP élargi de 100 à **≈170 définitions** : **40 fondamentales + ≈30 variantes (≈10 familles × 3) + 100 indépendantes**. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |
| Q231 | C adaptée | Catalogue indépendant hybride : neutre/polyvalent, élémentaire, hybride/avancé ; hypothèse 33/50/17 non contraignante. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |
| Q232 | C | Répartition équilibrée selon rôles tactiques, quotas **indicatifs** et cartes multirôles possibles. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |
| Q233 | C enrichie | Spécialisations élémentaires fortes et archétypes transversaux, intégrant peuples/types de créatures Heroic Fantasy. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |
| Q234 | Personnalisée | **Quatre peuples** représentés au MVP ; moteur extensible pour Gobelins, Morts-vivants et autres. Les quatre peuples exacts restent ouverts. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |

**Q235 ouverte.** Prochain arbitrage : nommer les quatre peuples MVP (ou arbitrer leur sélection), sans confondre peuples et archétypes/éléments.

## Décisions Q235–Q244 — consolidation v2.5 (sans doublons moteur)

| Question | Choix | Décision / référence préexistante | Module |
|---|---|---|---|
| Q235 | A | Humains, Elfes, Nains et Dragons retenus pour le MVP ; taxonomie extensible, pas nécessairement des peuples de héros. | [Peuples et stabilisation](01-combat/tribes-positioning-and-stabilization-v25.md) |
| Q236 | C | Identités mécaniques fortes, synergies tribales ouvertes ; decks mixtes et combinaisons éléments/positions. | [Peuples et stabilisation](01-combat/tribes-positioning-and-stabilization-v25.md) |
| Q237 | C | Sphérier fondé sur mécaniques transversales avec nœuds complémentaires pouvant profiter à certains peuples ; pas de branches tribales obligatoires. | [Peuples et stabilisation](01-combat/tribes-positioning-and-stabilization-v25.md) |
| Q238 | C | Synergies de peuples globales et positionnelles : rangées, colonnes, voisinage et formations selon le texte. | [Peuples et stabilisation](01-combat/tribes-positioning-and-stabilization-v25.md) |
| Q239 | C | Adjacent = partage un côté (orthogonal), hors diagonales sauf indication explicite ; autres zones autorisées. | [Peuples et stabilisation](01-combat/tribes-positioning-and-stabilization-v25.md) |
| Q240 | C | Effets continus recalculés après changements pertinents, aux points de cohérence atomiques ; pas de triggers fabriqués par les itérations. | [Peuples et stabilisation](01-combat/tribes-positioning-and-stabilization-v25.md) |
| Q241 | C | Conserver les blessures/dégâts subis quand PV max change ; détecter les morts secondaires en lots et stabiliser. | [Peuples et stabilisation](01-combat/tribes-positioning-and-stabilization-v25.md) |
| Q242 | C | Stabilisation par lots, morts simultanées, puis réactions FIFO ; cycles et budgets causaux existants restent normatifs. | [Peuples et stabilisation](01-combat/tribes-positioning-and-stabilization-v25.md) |
| Q243 | C | Couches et graphe de dépendances pour effets continus ; confirme Q161 et Q164, sans inventer de nouveau solveur. | [Peuples et stabilisation](01-combat/tribes-positioning-and-stabilization-v25.md) |
| Q244 | B (confirmation) | Neutralisation minimale et canonique des dépendances cycliques contradictoires ; règle DÉJÀ validée Q162–Q163. | [Peuples et stabilisation](01-combat/tribes-positioning-and-stabilization-v25.md) |

**Q242–Q244 :** confirmations et intégration ciblée, sans nouvelle file FIFO, sans nouveau budget causal, sans remplacement du solveur Q161–Q164. **Q245 ouverte.**

## Décisions validées Q245–Q254 — consolidation v2.6

| Question | Choix | Décision | Source normative |
|---|---|---|---|
| Q245 | **C** | Taxonomie peuple / faction / types secondaires : métadonnées distinctes, non obligatoires sauf origine pertinente, multiples types, inspectables et extensibles. | [Classification et équipements](01-combat/equipment-and-card-classifications-v26.md) |
| Q246 | **C adaptée** | Deck libre entre peuples/factions/types ; effets conditionnels de composition sans illégalité ; socle neutre de 20 copies, spécialisation émergente des deux boosters aléatoires. | [Classification et équipements](01-combat/equipment-and-card-classifications-v26.md) |
| Q247 | **B** | Conditions de composition évaluées avant la main initiale de chaque combat, sur le deck actif, figées durant ce combat. | [Classification et équipements](01-combat/equipment-and-card-classifications-v26.md) |
| Q248 | **B** | Alliances/rivalités narratives ; aucune règle de bonus/malus automatique, seuls effets explicites des cartes. | [Classification et équipements](01-combat/equipment-and-card-classifications-v26.md) |
| Q249 | **B** | Cartes Équipement attachables aux créatures, distinctes des artefacts d’ascension, sans case créature. | [Classification et équipements](01-combat/equipment-and-card-classifications-v26.md) |
| Q250 | **B adaptée par Q253** | Une créature a au maximum une case Arme et une case Protection, et peut posséder 0, 1 ou 2 emplacements au total. | [Classification et équipements](01-combat/equipment-and-card-classifications-v26.md) |
| Q251 | **B** | Départ du porteur : détacher chaque équipement, puis défausse du propriétaire par défaut, exceptions explicites. | [Classification et équipements](01-combat/equipment-and-card-classifications-v26.md) |
| Q252 | **B** | Emplacement occupé : remplacement autorisé ; ancien objet détaché et envoyé en défausse, sauf effet explicite. | [Classification et équipements](01-combat/equipment-and-card-classifications-v26.md) |
| Q253 | **C adaptée** | Équipements utilisables par défaut si la créature possède la case adéquate ; restrictions de porteur explicites par carte ; certaines créatures (ex. Dragon) ont 0 emplacement. | [Classification et équipements](01-combat/equipment-and-card-classifications-v26.md) |
| Q254 | **C** | Aucune durabilité universelle ; cartes spécifiques avec charges, consommation et conséquence à zéro explicitement définies ; compteur seulement si pertinent. | [Classification et équipements](01-combat/equipment-and-card-classifications-v26.md) |

**Corrections rétroactives** : Q250=B est précisé par Q253 : **0 à 2 emplacements par créature**, pas deux systématiques. Q246 précise Q215/Q222/Q224 : **socle neutre**, spécialisation émerge des boosters tirés aléatoirement ; sphérier favorise les synergies présentes, sans imposer un archétype ni créer des cartes. Artefacts Q182–Q183 distincts des équipements Q249.

**Q255 ouverte** : nouvelle décision à choisir.

## Décisions validées Q255–Q264 — consolidation v2.7

| Question | Choix | Décision | Source normative |
|---|---|---|---|
| Q255 | **B** | Alliés par défaut ; porteur ennemi autorisé ou imposé par texte explicite ; contraintes d’emplacement, compatibilité, propriété et défausse Q250–Q253 demeurent. | [Catalogue v2.7](03-progression/independent-card-catalog-and-synergies-v27.md) |
| Q256 | **C** | Synergies d’équipement transversales ; aucun archétype imposé ; spécialisation issue des cartes réellement tirées. | [Catalogue v2.7](03-progression/independent-card-catalog-and-synergies-v27.md) |
| Q257 | **B** | **20 équipements** parmi 100 indépendantes, cible indicative **10 Armes / 10 Protections**. | [Catalogue v2.7](03-progression/independent-card-catalog-and-synergies-v27.md) |
| Q258 | **B** | **50 créatures, 30 sorts et 20 équipements** = exactement 100 définitions indépendantes ; aucun quota équivalent dans les boosters. | [Catalogue v2.7](03-progression/independent-card-catalog-and-synergies-v27.md) |
| Q259 | **C** | Répartition cible souple des 50 créatures : **15 Humains / 14 Elfes / 13 Nains / 8 Dragons** ; la rareté de booster est indépendante du peuple. | [Catalogue v2.7](03-progression/independent-card-catalog-and-synergies-v27.md) |
| Q260 | **C** | Identité dominante par peuple (~50–60 % de leurs créatures), rôles alternatifs réellement représentés ; pas de restrictions implicites de peuple. | [Catalogue v2.7](03-progression/independent-card-catalog-and-synergies-v27.md) |
| Q261 | **B** | **6 à 10 créatures passerelles** entre peuples, dans les 50 et avec utilité hors synergie optimale. | [Catalogue v2.7](03-progression/independent-card-catalog-and-synergies-v27.md) |
| Q262 | **B** | **13 à 18 créatures hybrides** (~25–35 %) à au moins deux rôles significatifs, pouvant aussi être passerelles. | [Catalogue v2.7](03-progression/independent-card-catalog-and-synergies-v27.md) |
| Q263 | **B** | **5 à 8 créatures évolutives** pendant le combat, sans progression permanente implicite ; mécanismes existants. | [Catalogue v2.7](03-progression/independent-card-catalog-and-synergies-v27.md) |
| Q264 | **B** | **8 à 12 cartes à contrepartie parmi les 100 indépendantes** ; risque/récompense explicite sur créatures, sorts ou équipements. | [Catalogue v2.7](03-progression/independent-card-catalog-and-synergies-v27.md) |

**Q265 ouverte** : nouvelle section de conception ; aucune réponse anticipée. **Attention aux décomptes** : passerelle, hybride et évolutive sont des caractéristiques possiblement cumulées ; elles ne s'ajoutent jamais aux 50 créatures. Les cartes à contrepartie se répartissent parmi les 100.

## Décisions validées Q265–Q274 — consolidation v2.8

| Question | Choix | Décision | Source normative |
|---|---|---|---|
| Q265 | **C** | Profils tactiques ennemis avec adaptation situationnelle, sans avantage caché. | [Rencontres v2.8](03-progression/enemy-encounters-and-special-missions-v28.md) |
| Q266 | **C** | Archétypes ennemis conçus, avec noyau fixe et variations contrôlées. | [Rencontres v2.8](03-progression/enemy-encounters-and-special-missions-v28.md) |
| Q267 | **C** | Difficulté évoluant en puissance et sophistication tactique, sans adaptation secrète au héros. | [Rencontres v2.8](03-progression/enemy-encounters-and-special-missions-v28.md) |
| Q268 | **B** | Avant combat : identité, peuple dominant pertinent et stratégie générale ; deck exact caché. | [Rencontres v2.8](03-progression/enemy-encounters-and-special-missions-v28.md) |
| Q269 | **B** | Minorité de rencontres spéciales à objectifs alternatifs, règles de victoire moteur préservées. | [Rencontres v2.8](03-progression/enemy-encounters-and-special-missions-v28.md) |
| Q270 | **C** | Placement semi-aléatoire avec contraintes d’espacement, diversité et progression. | [Rencontres v2.8](03-progression/enemy-encounters-and-special-missions-v28.md) |
| Q271 | **A** | Deux familles seulement au MVP : Protection et Survie. | [Rencontres v2.8](03-progression/enemy-encounters-and-special-missions-v28.md) |
| Q272 | **C** | Unité à protéger passive ou active, avec rôles tactiques et vulnérabilités variés. | [Rencontres v2.8](03-progression/enemy-encounters-and-special-missions-v28.md) |
| Q273 | **C** | Survie : pression constante, croissante ou par pics selon les scénarios. | [Rencontres v2.8](03-progression/enemy-encounters-and-special-missions-v28.md) |
| Q274 | **C** | Plusieurs scénarios conçus par famille, enrichis de variantes contrôlées. | [Rencontres v2.8](03-progression/enemy-encounters-and-special-missions-v28.md) |

**Points ouverts et non tranchés par Q269–Q274 :** arbitrage objectif spécial vs mort des héros à une même frontière atomique, traitement des départs de la cible protégée et modalités exactes des fins de missions. **Q275 ouverte.**

---

## Fichier : `GLOSSARY.md`

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

## Termes ajoutés en v2.2
- **Deck actif (hors combat)** : ensemble d’exemplaires acquis qui composera la pioche de départ du prochain combat. Doit respecter ses bornes de taille pour lancer le combat (base 40/40, Q208).
- **Réserve d'ascension** : cartes acquises mais momentanément non incluses dans le deck actif ; transfert libre et gratuit hors combat (Q205–Q206).
- **Copies possédées de run** : somme des copies de la même carte dans le deck actif et la réserve, plafonnée à quatre (Q207).
- **Recherche ciblée** : effet faisant sélectionner au joueur une instance éligible de sa pioche. Chaque exemplaire affiché séparément, sans dévoiler l’ordre de la pioche (Q211–Q214).
- **Recherche aléatoire** : sélection moteur via RNG déterministe d’une instance éligible, sans choix UI (Q211).
- **Fatigue progressive** : pertes directes de PV de rang 1, puis 2, puis 3, etc. lors de pioches impossibles pendant un même combat ; remplace la valeur fixe Q41 (Q210).

## Termes ajoutés en v2.3

- **Socle de base** : 20 exemplaires de départ attribués au héros, fixes initialement, dont certaines variantes deviennent accessibles par le sphérier permanent (Q224). Ces exemplaires ne sont pas obligatoires dans le deck actif (Q223).
- **Booster de départ** : paquet de 15 exemplaires de cartes définitivement débloquées, générés avant l'ascension selon rareté pondérée (Q218–Q219). Deux boosters successifs (Q220).
- **Garantie de rareté** : effet de compétence permanente pouvant imposer une rareté minimale par booster, assouplie si aucune carte éligible ne satisfait la condition (Q218–Q219).
- **Proposition automatique du deck** : sélection de copies attribuées favorisant en priorité la spécialisation du sphérier et modifiable librement (Q216/Q222/Q223).
- **Pool de préparation** : somme des 20 copies de base et 30 copies issues des boosters ; distinct de la collection permanente de cartes débloquées (Q215).


## Complément v2.4 — catalogue et peuples

- **Définition de carte :** modèle unique de statistiques, coût, effets et présentation. Le catalogue MVP vise **≈170 définitions** (Q230 révisée), distinctes des copies possédées.
- **Famille de carte (`familyId`) :** groupe de variantes d'une carte fondamentale partageant le plafond de **quatre exemplaires** (Q227).
- **Variante du sphérier :** version d'une carte fondamentale déterminée par les nœuds permanents, attribuée **seulement aux copies du socle initial**, non disponible dans les boosters (Q226–Q229).
- **Peuple/type de créature :** axe de synergie Heroic Fantasy extensible au-delà des **quatre peuples du MVP** (Q233–Q234).
- **Catalogue fondamental initial :** identités débloquées permettant de générer socle et boosters légaux, avec secours déterministe lorsque nécessaire (Q225).

---

## Fichier : `README.md`

# Tower TCG — Spécifications v2.7

**Version consolidée : décisions Q01 à Q264.** Le corpus est conçu pour être lu de façon modulaire par un agent d'implémentation ; les documents liés demeurent les sources de vérité pour chaque système.

**Nouveautés Q65–Q74 :** [attribution des dégâts, arrondis, vol de vie et événements des protections](01-combat/damage-attribution.md) ; [prévention létale](01-combat/damage-prevention.md) ; [file d'événements](01-combat/event-queue.md) ; [tests d'acceptation](09-technical/acceptance-tests.md) ; [journal de décisions](DECISIONS.md).

Ne pas implémenter comme validées les idées présentées comme ouvertes ou proposées. Les effets de soins et de contrôle sont détaillés dans leurs modules ; le placement après prise de contrôle est défini dans [transferts de contrôle](01-combat/control-transfers.md) (Q95).

# Tower TCG — Game Design Documentation

> Version 1.6 — 2026-11-04. Spécifications de combat en cours. Source : décisions explicites du concepteur (Q01–Q154). Aucun code n'est encore implémenté.

## Principe
Jeu solo TCG/RPG : ascension de tours, étages avec ennemis, marchands et ressources, boss par étage ; progression pendant chaque ascension par deck, artefacts et améliorations temporaires du héros ; méta-progression persistante du sphérier (EXP, niveaux, compétences) et déblocage de nouvelles cartes et artefacts éligibles au draft (Q182, Q185–Q194). Le combat tactique est le cœur du jeu.

## Statuts
- **VALIDÉ** : choix explicite du concepteur.
- **PROPOSÉ** : suggestion à arbitrer ; **ne pas implémenter comme règle définitive**.
- **OUVERT** : comportement non encore spécifié.

## Lecture ciblée pour l'agent
Commencer par [AGENTS.md](AGENTS.md) et [l'index combat](01-combat/README.md). Lire uniquement les dépendances déclarées par le concept à implémenter. Ne jamais inférer les règles encore ouvertes.

## Documents
- [Glossaire](GLOSSARY.md) · [Journal des décisions](DECISIONS.md)
- [Champ de bataille](01-combat/battlefield.md) · [Invocation](01-combat/summoning.md) · [Déplacement](01-combat/movement.md)
- [Tours](01-combat/turn-sequence.md) · [Dégâts](01-combat/damage-resolution.md) · [Protections](01-combat/damage-prevention.md)
- [Capacités](01-combat/abilities.md) · [Événements](01-combat/event-queue.md) · [Ciblage](01-combat/targeting.md)
- [Victoire et défaite](01-combat/victory-and-defeat.md) · [Héros, pioche et mana](01-combat/hero-deck-mana.md)
- [Tests de conformité](09-technical/acceptance-tests.md)

## Règle de gouvernance
Une décision nouvelle modifie le document propriétaire de la règle, ses tests et les liens dépendants. Les règles proposées ne doivent jamais être présentées comme définitivement adoptées.

## Modules ajoutés en v0.5
- [Pioche et fatigue](01-combat/draw-and-fatigue.md)
- [Main, défausse et recyclage](01-combat/hand-and-discard.md)

## Modules ajoutés en v0.6
- [Bannissement](01-combat/banishment.md)
- [Résurrection](01-combat/resurrection.md)
- [Récupération et recyclage](01-combat/recovery.md)
- [Transferts entre zones et événements](01-combat/zone-events.md)

## Modules ajoutés en v0.7
- [Identité des instances et dernier état connu](01-combat/instance-identity.md)
- [Effets composés, opérations atomiques et effets simultanés](01-combat/effect-resolution.md)

## Modules ajoutés en v0.8
- [Attribution des dégâts, vol de vie et événements défensifs](01-combat/damage-attribution.md) — Q65–Q74

## Modules ajoutés en v0.9
- [Soins et répartition des soins simultanés](01-combat/healing.md) — Q75–Q77
- [PV maximum, durées et événements d'expiration](01-combat/temporary-effects.md) — Q78–Q84

## Consolidation v1.0 — décisions Q85 à Q94
- [Sources, contrôle, instantanés et vol de vie](01-combat/source-control.md) — référence normative Q85–Q94.
- [Tests d'acceptation](09-technical/acceptance-tests.md) — scénarios T-085 à T-094.
- La version v1.0 est une **étape documentaire**, pas une indication que l'équilibrage, le contenu ou le moteur sont achevés. La règle de placement après contrôle reste ouverte pour Q95.

## Consolidation v1.1 — décisions Q95 à Q104

- [Transferts de contrôle entre camps](01-combat/control-transfers.md) — document propriétaire des règles Q95–Q104.
- [Tests d’acceptation](09-technical/acceptance-tests.md) — scénarios T-095 à T-104.
- **Q105 validée** ; voir la consolidation v1.2 ci-dessous.

## Consolidation v1.2 — décisions Q105 à Q114

- [Attaque après transfert, capacités de tour et sécurité FIFO](01-combat/turn-control-and-loop-safety.md) — **source normative Q105–Q114**.
- [Transferts Q95–Q104](01-combat/control-transfers.md) ; [séquence de tour](01-combat/turn-sequence.md), [effets temporaires](01-combat/temporary-effects.md), [événements](01-combat/event-queue.md).
- [Tests d'acceptation](09-technical/acceptance-tests.md) — série **T-105 à T-114**. Cas documentés, **non exécutés**.
- **Q115 désormais validée** ; voir la consolidation v1.3 ci-dessous.


## Consolidation v1.3 — décisions Q115 à Q124

- **Source normative** : [budgets causaux, réservations FIFO, journalisation, instantanés, replays et compatibilité](09-technical/causal-budgets-and-replay.md).
- Dépendances : [anti-boucles Q105–Q114](01-combat/turn-control-and-loop-safety.md), [FIFO](01-combat/event-queue.md), [opérations atomiques](01-combat/effect-resolution.md), [instances](01-combat/instance-identity.md).
- [Scénarios d’acceptation T-115 à T-124](09-technical/acceptance-tests.md) : **40 nouveaux cas documentés, non exécutés**.
- **Q125 ouverte** : politique de support des anciennes versions et migration de données persistantes ; ne pas implémenter ce point comme arbitrage validé.


## Consolidation v1.4 — Q125–Q134

- [Direction artistique, jetons, cartes d’origine et panneau d’inspection](02-art-direction/card-and-board-ui.md) — Q126–Q134, avec valeurs **ATQ/PV finales visibles** et effet actif exhaustif.
- [Gestion des versions historiques supportées](09-technical/causal-budgets-and-replay.md) — Q125.
- [Tests d’acceptation](09-technical/acceptance-tests.md) — T-125 à T-134.
- **Q135 ouverte** : conventions de couleur, valeurs finales et détail des modifications dans les vues d’inspection.


## Modules consolidés en v1.5
- [Tooltips, durées en langage naturel, contrôle et orchestrateur Juicy & Fast-Paced Q135–Q144](02-art-direction/tooltips-durations-and-vfx.md).
- [Tests d’acceptation v1.5](09-technical/acceptance-tests.md) ; [journal Q135–Q144](DECISIONS.md).

**Q145–Q154 validées ; Q155 ouverte** — consulter le nouveau module UI plateau.


## Consolidation v1.6 — Q145–Q154

- [Plateau fantasy, décor V1 fixe animé discrètement, grille tactique contextuelle, destinations valides et prévisualisation progressive, interactions multimodales](02-art-direction/board-and-tactical-preview.md).
- [Tests d’acceptation T-145-01 à T-154-04](09-technical/acceptance-tests.md) — **40 nouveaux scénarios documentés mais non exécutés**.
- [Décisions Q145–Q154](DECISIONS.md).
- **Q155 ouverte** : suite du questionnaire ; ne pas anticiper d'arbitrage.


## État de consolidation v1.7 — 2026-11-04

Le socle documentaire historique demeure disponible ; la consolidation **v1.7 couvre les décisions explicites jusqu’à Q164**. Modules additionnels : [UI Q135–Q144](02-art-direction/tooltips-durations-and-vfx.md), [plateau et prévision Q145–Q154](02-art-direction/board-and-tactical-preview.md), [sorts et effets continus Q155–Q164](02-art-direction/spells-auras-and-continuous-effects.md). Cette version ne constitue pas une implémentation ni la preuve que les scénarios d’acceptation sont exécutés. **Prochaine question Q165.**

## Consolidation v1.8 — Q165–Q174

- [Journal de combat joueur, inspection historique, visibilité et synchronisation avec les animations](02-art-direction/combat-journal-and-inspection.md).
- [Tests d’acceptation T-165-01 à T-174-04](09-technical/acceptance-tests.md) : **40 nouveaux scénarios spécifiés, non exécutés**.
- [Décisions Q165–Q174](DECISIONS.md).
- Priorité fonctionnelle : journal **secondaire et léger**, jamais permanent sur le plateau, sans replay interactif ni graphe de causalité en V1.
- L’UI ne révèle pas les résultats avant leur présentation visuelle et ne modifie jamais l’état déterministe du combat.
- **Q175–Q184 validées en v1.9** ; la prochaine question est Q185.


## Consolidation v1.9 — Q175–Q184 (2026-11-04)

- **Source normative** : [récompenses, cinq raretés, artefacts et progression des ascensions](03-progression/rewards-rarity-and-ascension.md).
- **Décisions** : [Q175–Q184](DECISIONS.md) ; **Q181** = 5 rangs Commun/blanc, Peu commun/bleu, Rare/rouge, Épique/violet, Légendaire/or, **sans mythique** ; **Q182** = artefacts seulement durant une ascension, déblocages de cartes/artefacts persistants dans les futurs pools de draft.
- **Tests** : [T-175-01 à T-184-04](09-technical/acceptance-tests.md) : **40 scénarios spécifiés et non exécutés**.
- **Références croisées** : [victoire](01-combat/victory-and-defeat.md), [VFX et feedback](02-art-direction/tooltips-durations-and-vfx.md), [journal et visibilité](02-art-direction/combat-journal-and-inspection.md), [événements déterministes](01-combat/event-queue.md), [compatibilité des sauvegardes](09-technical/causal-budgets-and-replay.md).
- **Q185 ouverte** : rôle de l’EXP et acquisition des niveaux/améliorations du héros pendant l’ascension.

## Consolidation v2.0 — décisions Q185–Q194

- [Sphérier permanent du héros](03-progression/hero-sphere-and-skill-tree.md) : EXP et niveaux persistants, branches connectées, coûts variables et réinitialisation totale gratuite uniquement entre les ascensions.
- [Tours, récompenses répétables, commerces et déblocages](03-progression/towers-merchants-and-unlocks.md) : tours majoritairement libres, défis spéciaux conditionnés, difficulté fixe, rendements décroissants et exclusivités des marchands.
- **Q194 personnalisée : toute carte effectivement obtenue ou achetée devient une possibilité des drafts futurs.** La copie possédée dans l’ascension reste temporaire, le déblocage du catalogue est permanent ; une offre simplement vue n’est pas acquise.
- [Décisions](DECISIONS.md) et [40 tests documentaires Q185–Q194](09-technical/acceptance-tests.md).
- **Questions ouvertes :** stocks des marchands, probabilités, barème EXP, détails du sphérier, doublons, conservation de la monnaie, artefacts acquis.

## Consolidation v2.1 — Q195–Q204 (2026-11-06)

- **Source normative** : [boutiques, stock, renouvellements, prix et plafond de deck](03-progression/merchant-stock-and-deck-limits.md).
- Points clés : inventaires aléatoires et sorts propres aux tours ; tarifs basés sur cinq raretés ; monnaie temporaire ; renouvellements payants à coût croissant par marchand ; une offre = un exemplaire ; plafond de **quatre copies** pour toutes les raretés ; exclusion des cartes plafonnées des boutiques/récompenses ; si aucune carte n’est éligible, compensation Q178 automatique en plus de Q179.
- [Décisions Q195–Q204](DECISIONS.md) ; [tests T-195-01 à T-204-04](09-technical/acceptance-tests.md) (40 tests **spécifiés et non exécutés**).
- Aucune sixième rareté « Mythique » (Q181). Les coûts de renouvellement, taux de tirage et prix chiffrés restent ouverts. **Prochaine question Q205.**

## Consolidation v2.2 — décisions Q205 à Q214
- [Deck actif, réserve réversible, modifications hors combat, plafond quatre exemplaires sur toutes les copies possédées et capacités 40/40 évolutives](03-progression/deck-reserve-and-capacity.md) — Q205–Q209.
- [Fatigue progressive 1/2/3… en remplacement de Q41 ; recherche ciblée/aléatoire, destination/mélange, visibilité, sélection individuelle des exemplaires](01-combat/deck-search-and-fatigue-v22.md) — Q210–Q214.
- [Marchands Q195–Q204](03-progression/merchant-stock-and-deck-limits.md) : le filtre de plafond utilise maintenant la somme **deck actif + réserve** (Q207).
- [Tests v2.2](09-technical/acceptance-tests.md) : 40 scénarios nouveaux T-205 à T-214, **non exécutés**.

**Statut :** documentation consolidée jusqu'à **Q214**. Les propositions visuelles et chiffrées non explicitement validées restent ouvertes. Q215 sera la prochaine décision.

## Consolidation v2.3 — décisions Q215–Q224 (2026-11-07)

- **Source normative** : [préparation de l’ascension, boosters, composition automatique, évolutions du socle Q215–Q224](03-progression/ascension-start-boosters-and-autobuild.md).
- Deck standard **40/40** (Q208/Q217), **20 cartes de base + 2 boosters de 15**, **40 actives/10 réserve** ; aucune construction libre à partir de toute la collection permanente (Q215).
- Assistant automatique sans préparation obligatoire (Q216), classement d'abord par **spécialisation du sphérier** (Q222), cartes de base **librement remplaçables dans le deck actif** (Q223).
- Boosters : rareté pondérée et garanties de compétences possibles (Q218), dégradation progressive sans contourner les cartes débloquées ni le maximum de quatre exemplaires (Q219), **ouverture séquentielle** et passable (Q220), présentation compacte et filtres facultatifs (Q221).
- Socle de 20 cartes **initialement fixe**, dont certaines variantes peuvent être autorisées via des nœuds permanents du sphérier (Q224 D).
- [Journal Q215–Q224](DECISIONS.md) ; [40 nouveaux tests d'acceptation v2.3](09-technical/acceptance-tests.md), **spécifiés mais non exécutés**.
- **Ouverts** : secours concret lorsque 50 exemplaires ne sont pas générables sous le plafond de quatre ; probabilité chiffrée, compétences et variantes exactes, adaptation 40/10 aux bornes évolutives Q209. Prochaine question **Q225**.

## Consolidation v2.4 — décisions Q225–Q234 (2026-11-07)

- **Source normative** : [familles évolutives, catalogue MVP et peuples](03-progression/mvp-card-catalog-and-tribes.md).
- Q225 catalogue de base et secours déterministe ; Q226–Q229 variantes du sphérier **déterministes, réservées aux copies du socle** ; **plafond de quatre copies par famille**, boosters sans variantes du sphérier.
- Q230 révisée : **≈170 définitions** (40 fondamentales + ≈30 variantes + 100 indépendantes), et non 100 au total ; 20 copies de socle et 2 × 15 copies de booster par ascension (Q215).
- Q231 catalogue hybride neutre/élémentaire/avancé ; Q232 quotas tactiques souples ; Q233 Heroic Fantasy, peuples et archétypes transversaux ; Q234 **quatre peuples représentés au MVP**, extensibles (Gobelins, Morts-vivants, etc.).
- [Journal Q225–Q234](DECISIONS.md) ; [40 nouveaux scénarios d'acceptation documentés](09-technical/acceptance-tests.md), **non exécutés**.
- **Ouvert :** choix nominatif des quatre peuples, nombre d'éléments et d'archétypes, seuils/probabilités et critères précis des variantes, constitution du catalogue fondamental garantissant toute configuration légale. Prochaine décision : **Q235**.

## Consolidation v2.5 — Q235–Q244 (2026-11-08)

- [Peuples, géométrie et stabilisation](01-combat/tribes-positioning-and-stabilization-v25.md) : Humains, Elfes, Nains, Dragons ; synergies mixtes ; voisinage orthogonal ; recalcul et morts secondaires.
- **Audit des doublons** : Q242 renvoie à Q13–Q14, Q111–Q124 ; Q243–Q244 **réaffirment** Q161–Q164 ; ne pas implémenter des budgets ni des politiques de cycle concurrents.
- [Tests Q235–Q244](09-technical/acceptance-tests.md) : 40 scénarios spécifiés, non exécutés. Prochaine question : Q245.

## Consolidation v2.6 — Q245–Q254 (2026-11-10)

- [Source normative Q245–Q254 : taxonomie, composition et équipements](01-combat/equipment-and-card-classifications-v26.md).
- Q245–Q248 : peuple/faction/types secondaires ; socle de 20 exemplaires neutre et spécialisation par les deux boosters ; conditions du deck actif figées avant la pioche initiale à chaque combat ; relations de factions narratives sans malus automatiques.
- Q249–Q253 : équipements de combat (différents des artefacts), **0–2 emplacements par créature** (au plus un Arme, un Protection ; Q253 corrige Q250), restriction explicite par carte, défausse par défaut après départ ou remplacement du porteur.
- Q254 : **pas de durabilité universelle**, mais charges et effet à épuisement propres aux cartes concernées.
- [Décisions](DECISIONS.md) et [40 tests Q245–Q254](09-technical/acceptance-tests.md), spécifiés et non exécutés.
- Les règles moteur Q13–Q14, Q111–Q124, Q159–Q164, Q240–Q244 demeurent normatives ; pas de nouveau moteur de boucle ou d’aura. Prochaine question : **Q255**.

## Consolidation v2.7 — Q255–Q264 (2026-11-10)

- **Source normative :** [Catalogue indépendant et synergies Q255–Q264](03-progression/independent-card-catalog-and-synergies-v27.md), à lire avec [règles d'équipements Q245–Q254](01-combat/equipment-and-card-classifications-v26.md).
- **Q255 :** allié par défaut, équipement sur ennemi seulement si texte explicite ; propriétaire et porteur distincts, restrictions et départ inchangés.
- **Q256–Q258 :** équipements transversaux, pas d'archétype imposé ; **100 cartes indépendantes = 50 créatures + 30 sorts + 20 équipements** ; cible 10 armes/10 protections.
- **Q259–Q260 :** parmi 50 créatures, cibles souples **15 Humains / 14 Elfes / 13 Nains / 8 Dragons** ; environ **50–60 %** de profils en adéquation avec l'identité dominante de chaque peuple.
- **Q261–Q263 :** parmi ces 50 créatures, **6–10 passerelles**, **13–18 hybrides**, **5–8 évolutives** ; **étiquettes éditoriales recouvrables**, pas de cartes supplémentaires ni quotas de boosters.
- **Q264 :** **8–12 cartes indépendantes** présentant une contrepartie explicite ; réparties entre les 100 définitions, sans coût universel supplémentaire.
- [Journal de décisions](DECISIONS.md) ; [40 tests d'acceptation v2.7](09-technical/acceptance-tests.md), **décrits mais non exécutés**. Les règles moteur précédentes ne sont pas redéfinies.
- **Q265 ouverte** : prochaine dimension de gameplay à arbitrer.

## Consolidation v2.8 — Q265–Q274 (2026-11-11)

- [Source normative : rencontres, missions et adversaires](03-progression/enemy-encounters-and-special-missions-v28.md) : profils IA adaptatifs Q265, decks à archétype avec variation Q266, difficulté hybride Q267, aperçu stratégique précombat Q268.
- **Q269–Q270 :** missions spéciales minoritaires, à placement semi-aléatoire contraint.
- **Q271=A : seulement deux familles au MVP** — Protection et Survie. Q272 : unités protégées passives ou actives ; Q273 : pressions constante, croissante ou en pics ; Q274 : scénarios éditoriaux avec variantes contrôlées.
- [40 nouveaux tests d'acceptation](09-technical/acceptance-tests.md), spécifiés et non exécutés. VIC-001–VIC-006 et difficulté fixe Q192 demeurent normatifs ; les priorités non résolues des objectifs spéciaux restent **ouvertes**, sans changement moteur implicite.
- **Prochaine question : Q275**.

---
