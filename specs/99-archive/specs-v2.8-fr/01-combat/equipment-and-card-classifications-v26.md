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
