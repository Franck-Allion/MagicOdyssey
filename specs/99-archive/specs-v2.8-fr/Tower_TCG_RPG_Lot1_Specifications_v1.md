# Tower TCG/RPG — Spécifications fonctionnelles et techniques du Lot 1

**Version :** 1.0 — 11 novembre 2026  
**Statut :** base consolidée de conception, préalable à l'implémentation  
**Cible :** premier combat complet, jouable, visuellement professionnel, sur Windows / Godot 4  
**Référentiel amont :** *Tower TCG/RPG — Spécifications intégrales v2.8* (décisions Q01–Q274), complété par Q275–Q302.  
**Usage futur :** document source pour construire une roadmap puis des prompts atomiques à exécuter avec Codex + Gemini Flash (raisonnement léger).

> **Règle de lecture — niveaux de vérité.** **[VALIDÉ]** = décision de conception acceptée. **[LOT1]** = contrat d'implémentation de ce premier incrément, sans changement du gameplay cible. **[CONFIG]** = valeur de fixture/prototype modifiable sans nouvel arbitrage métier. **[PROPOSITION]** = détail recommandé, à ne pas présenter comme une décision déjà prise. **[HORS LOT1]** = mécanique conservée dans les spécifications globales mais non requise pour valider le premier combat. En cas de contradiction, la décision validée la plus récente fait foi ; la v2.8 conserve la norme détaillée non reproduite ici. Les anciens passages marqués « OUVERT » dans les documents intermédiaires ne doivent pas réouvrir une décision déjà tranchée dans une version ultérieure.

---

## 1. Objectif, périmètre et définition de terminé

### 1.1 Objectif [VALIDÉ]

Livrer **un exécutable Godot Windows permettant de jouer entièrement un combat** humain contre IA : création du combat, tirage initial, alternance des tours, cartes de la main utilisables, invocation/placement/déplacement, sorts, équipements, ressources, attaques automatiques, défenses, capacités simples, fatigue, victoire/défaite, rejouer.

Il s'agit d'une **vertical slice représentative**, pas d'une bibliothèque de règles sans interface, ni d'une maquette cliquable sans combat authentique. Un moteur fonctionnel mais sans écran jouable **ne valide pas** le Lot 1.

### 1.2 Inclus [VALIDÉ Q296–Q299]

- Plateau 6 colonnes × 2 lignes **par camp** (24 emplacements), positionnement et priorité d'invocation.
- Créatures en attaque/défense, mal d'invocation, déplacement naturel et permutation.
- Main, pioche, défausse, points de vie des héros, mana à croissance, pioche et fatigue progressive.
- Attaques automatiques de fin de tour, cibles de colonne, dégâts, armure, bouclier, soins, morts, contrôles de victoire.
- Sorts ciblés, capacités passives et actives simples, équipement Arme et Protection.
- Catalogue initial **16 définitions** : 10 créatures, 4 sorts, 2 équipements.
- IA heuristique V1 utilisant les mêmes commandes légales que le joueur.
- Écran de combat complet 2D premium, 1920×1080 référence, fonctionnel à 1280×720 ; cartes manipulables, écussons, tooltips, inspection, VFX expressifs.
- Tests automatisés de règles, scénarios E2E et build Windows.

### 1.3 Reporté sans suppression du contrat cible [VALIDÉ]

Exploration de tour, marchands, récompenses et navigation entre combats ; exploration du monde ; menu principal définitif, options, sauvegarde de progression hors combat. Mécaniques de contrôle, résurrection, auras complexes, effets rares, éditeur de cartes visuel et totalité du catalogue (~170 définitions) **ne bloquent pas** le Lot 1. Les règles correspondantes restent normatives pour leur future implémentation, sans obligation de les coder maintenant. Les sauvegardes/replays complets du jeu peuvent attendre ; **le caractère déterministe du cœur de combat et les journaux de test sont obligatoires**.

### 1.4 Livrables attendus [LOT1]

Un dépôt Godot contenant scènes, scripts, 16 ressources `.tres`, assets utilisés légalement, tests, configuration de fixtures et un README de lancement ; une exportation Windows si l'environnement d'intégration le permet. L'absence de Godot dans l'environnement de build ne permet pas d'affirmer que le jeu a été testé : différencier **créé**, **testé automatiquement**, **testé manuellement dans Godot**.

---

## 2. Principes d'architecture non négociables

1. **Séparation domaine/présentation** : aucun calcul de règles à partir de sprites, animations, nœuds `Control`, positions en pixels ou délais d'effets visuels.
2. **État autoritatif unique** dans `CombatState`, modifié uniquement via commandes acceptées et opérations de résolution du moteur.
3. **Définitions immuables** (`CardDefinition`, ressources Godot typées) distinctes des copies possédées et des **instances de séjour sur le plateau** (`instance_id`).
4. **Catalogue déclaratif** : les 16 cartes ne sont pas des branches `if card_id == ...` ; composer des opérations d'une bibliothèque réutilisable [Q300–Q301].
5. **Moteur déterministe** : entrée = état + commande + état RNG + version de règles ; sortie = nouvel état + événements ordonnés + résultat ; aucune RNG non contrôlée.
6. **Validation et exécution séparées** : un clic de l'UI ne peut jamais imposer une action illégale. À la résolution, revérifier les préconditions pertinentes.
7. **Transactions atomiques** : préparer une opération, valider invariants, puis commit ; erreur technique => abandon de l'opération non validée et état d'erreur technique, sans effacer les opérations déjà validées [Q287].
8. **Événements de gameplay séparés des VFX** : événements ordonnés dans le moteur, ordonnancement visuel indépendant [Q277, Q302].
9. **Information cachée protégée** : l'IA n'accède qu'aux observations autorisées et à ses propres cartes privées ; ne jamais lui passer l'état intégral du joueur.
10. **Extensibilité testée** : ajouter une 17e carte fictive avec des effets connus sans toucher au code métier est un test architectural de non-régression (peut être exécuté dès Lot 1, extensibilité approfondie au Lot 2).

---

## 3. Modèle de combat et règles fonctionnelles

### 3.1 Plateau et joueurs [VALIDÉ Q01–Q02]

- Deux camps, `PLAYER` et `OPPONENT`. Chaque camp dispose des colonnes `1..6` et des lignes `ATTACK` / `DEFENSE`, soit 12 emplacements.
- Une seule créature par emplacement. Toute position est identifiée sans ambiguïté par `(camp, colonne, ligne)`.
- La ligne `ATTACK` produit les attaques normales ; la ligne `DEFENSE` protège la colonne, mais n'attaque pas normalement sauf texte spécifique.
- Pour une attaque ordinaire en colonne `c`, cible en priorité : ennemi `ATTACK[c]` → ennemi `DEFENSE[c]` → héros adverse. Aucune riposte ordinaire.
- Les deux camps sont représentés visuellement face à face, mais coordonnées d'affichage et indices logiques sont indépendants.

### 3.2 Invocation [VALIDÉ Q03–Q04]

- Jouer une créature requiert assez de mana, une carte en main, le tour actif et un emplacement libre légal.
- Placement possible en attaque ou défense, sous restrictions de carte le cas échéant.
- **Priorité de contestation** : si une colonne possède des ennemis et aucune créature alliée, et qu'un placement admissible y est possible, l'invocation doit aller dans une telle colonne. Sinon, libre choix parmi les emplacements légaux.
- Les places sont recalculées sur l'état courant. Une commande rejetée n'engendre ni paiement ni mutation.
- Cas limites non requis dans les 16 cartes (effets d'invocation à placement forcé très spécifique) : ne pas inventer de règle générale contradictoire ; isoler leur extension.

### 3.3 Déplacement [VALIDÉ Q05–Q08]

- Déplacement naturel : changer **de ligne dans la même colonne**, vers la case libre, coût **1 mana**, **une fois par tour personnel et par créature**.
- Une créature nouvellement invoquée peut se déplacer, même si elle ne peut pas attaquer normalement le tour de son invocation.
- Permutation de deux créatures du même camp dans une même colonne : **1 mana total** ; exige que les deux droits de déplacement naturel soient disponibles, puis consomme les deux.
- Changer de colonne n'est possible que par un effet de sort/capacité explicite ; ces déplacements d'effet ne consomment pas le droit naturel.
- Les nouvelles capacités de déplacement spécialisées sont [HORS LOT1], mais ne pas coder le mouvement naturel comme unique moteur possible de changement de position.

### 3.4 Déroulement des tours [VALIDÉ Q09–Q10, Q28–Q37, Q81–Q83, Q105–Q108, Q275–Q277]

1. Initialisation du combat, mélange déterministe de chaque deck, main initiale de **6 cartes** pour chaque camp selon les règles de visibilité ; cette main remplace la pioche normale du premier tour personnel.
2. **Le joueur humain commence toujours.** Tours alternés. Seul le camp actif peut soumettre des commandes volontaires [Q276].
3. Début de tour : expirations de début de tour, **croissance de capacité** (+1 normalement, y compris premier tour selon Q275), restauration du mana disponible à la capacité, déclencheurs de début de tour, puis pioche normale (sauf premier tour personnel qui a déjà reçu les 6 cartes).
4. Phase d'actions : jouer cartes, invoquer, déplacer, permuter, activer capacités ; les commandes résolvent et stabilisent leurs effets entièrement avant la prochaine commande volontaire.
5. L'utilisateur actionne « Terminer le tour ». Les créatures attaquantes du camp actif frappent **C1 à C6**, une colonne totalement résolue avant la suivante ; une créature invoquée au cours de ce tour ne frappe pas normalement (mal d'invocation), sauf texte explicite.
6. Résoudre réactions, puis `ON_TURN_END` et réactions, puis expirations de fin de tour et réactions, et changer de camp.
7. Toute victoire/défaite stoppe immédiatement le combat après le point de contrôle légal, sans exécuter le reste de la file.

L'interface doit signaler clairement le camp actif, le tour, les ressources et la disponibilité des commandes.

### 3.5 Mana [VALIDÉ Q30–Q34, Q275]

État distinct : `mana_capacity`, `mana_available`, `mana_cap` et modifications de croissance. La capacité augmente de 1 par début de tour personnel dans les limites du plafond ; le mana disponible est restauré intégralement ; le mana non utilisé n'est pas transféré au tour suivant. Une hausse du plafond n'ajoute pas immédiatement du mana ; les effets de croissance reçus en cours de tour agissent à partir des prochaines croissances. Les valeurs numériques initiales/plafond des héros restent **[CONFIG]** ; aucun nombre arbitraire ne devient une règle générale par simple présence dans le prototype.

### 3.6 Deck, main, zones et fatigue [VALIDÉ Q36–Q45, Q210]

- Chaque deck actif de départ comporte **40 cartes**, sur le principe du deck standard 40/40 [Q208–Q209]. Les 16 définitions ont jusqu'à **4 exemplaires** par identité ou famille de variantes selon les limites existantes ; la fixture Lot 1 doit respecter ces plafonds.
- Main initiale **6** ; maximum initial **7** ; pioche normale **1 par tour personnel à compter du second tour personnel**. La limite de main peut évoluer par des effets futurs.
- Pioche au-delà du maximum : carte excédentaire défaussée automatiquement. Les pioches multiples se traitent séquentiellement, avec réactions pertinentes entre tentatives.
- Pioche vide : fatigue **progressive** et non fixe : 1 PV directement perdus à la première tentative infructueuse, 2 à la deuxième, 3 à la troisième, etc. Le compteur ne se réinitialise pas en cas de remplissage ultérieur de la pioche. Ce n'est pas un événement de dégâts ; armure/bouclier n'y changent rien. Aucun recyclage automatique de la défausse.
- Zones minimales : `DECK`, `HAND`, `BOARD`, `DISCARD`, `BANISHED` (la dernière peut ne pas être exposée en UI si aucune carte Lot 1 ne l'emploie). Conserver les causes des transferts : sort joué ≠ mort ≠ défausse de main.
- La défausse existe par camp et expose son contenu lorsque les règles de visibilité le permettent.

### 3.7 Dégâts, protection, mort [VALIDÉ Q09–Q24, Q63–Q80, Q278–Q281, Q288–Q289]

- Dégâts ordinaires d'attaque = ATQ effective, aucune riposte automatique ; excédent perdu sans mot-clé spécifique. Le Piétinement est spécifié globalement mais n'est pas obligatoire pour les cartes initiales.
- Ordre : **armure → bouclier → PV → protection létale**. Armure = réduction réutilisable **par instance de dégâts**, somme de base et modifications, minimum 0, pas de plafond global [Q279, Q281]. Bouclier = réserve consommable [Q279]. Les réserves multiples restent attribuées à leurs sources et se consomment en priorité selon l'expiration la plus proche, puis ordre canonique [Q280] ; affichage agrégé autorisé.
- PV max d'une créature au moins 1 ; conserver les blessures lors des changements de PV max. Une baisse de PV max peut tuer [Q278].
- Appliquer les effets atomiques au moment de commit, vérifier mort/victoire avant la file de réactions. Les déclencheurs ne peuvent pas sauver rétroactivement un héros déjà mort.
- Les dégâts simultanés compatibles sur une même cible sont regroupés selon leur **profil effectif de protection**, pas sur la simple égalité de type ou de source [Q288]. Pour profils incompatibles, consommation des réserves communes dans l'ordre canonique, **commit de PV simultané**, sans victoire ou déclenchement intermédiaire [Q289]. Conserver attribution des sources selon les règles Q65–Q74.
- Les protections létales spécifiques et les réactions à l'absorption restent des mécanismes cibles architecturaux ; aucune des 16 cartes n'exige une protection létale complexe [HORS LOT1].

### 3.8 Soins et modifications temporaires [VALIDÉ Q75–Q84, Q140]

- Les soins restaurent jusqu'aux PV maximum, jamais au-delà ; `ON_HEAL` seulement si restauration effectivement positive.
- Les bonus et malus temporaires possèdent `source_id`, durée, horloge d'expiration et règle d'accumulation. Une modification de durée recalcule son échéance et provoque un feedback visuel transitoire [Q140].
- Les changements de PV maximum ne sont ni des soins ni des dégâts ; préserver les blessures.
- Pour « jusqu'à la fin du tour » de la Bénédiction martiale, utiliser les règles communes d'expiration, ne pas coder un raccourci dans son script.

### 3.9 Ciblage et capacité [VALIDÉ Q19–Q20, Q55–Q64, Q276–Q287]

- Les actions volontaires sont réservées au camp actif ; les réactions automatiques peuvent se produire hors de son tour.
- Prévalidation au lancement **et** revérification à la résolution. Pas de reciblage automatique d'une instance devenue invalide ; pas de remboursement si l'effet a été valablement lancé et que sa cible disparaît avant résolution.
- Les effets multicibles et composés autorisent les succès partiels pour composantes indépendantes ; dépendances/indivisibilité explicites.
- Une capacité passive simple est un modificateur continu calculé depuis l'état ; une capacité active est soumise à son coût, propriétaire d'activation et restrictions ; un déclencheur produit un événement en attente.
- Les événements de gameplay sont ordonnés et consommés dans la file **FIFO** préexistante, avec stabilisation avant nouvelle action volontaire. Protéger contre les boucles à l'aide des budgets causaux définis par les spécifications historiques.
- Les identifiants d'instances de plateau sont distincts des identités de cartes ; une réentrée crée une nouvelle instance, le déplacement conserve l'instance. Conserver un dernier état connu pour les sources qui ont quitté le plateau.

### 3.10 Équipements [VALIDÉ Q245–Q255, Q283–Q286]

- Types `WEAPON` et `PROTECTION`, slots **fixes par créature sur le plateau**, 0 à 2 selon la définition, au plus 1 arme et 1 protection ; pas d'évolution dynamique du nombre de slots.
- Carte jouée **depuis la main** en payant son coût, en ciblant un porteur compatible, selon les mêmes étapes génériques de validation que les autres cartes [Q285].
- Le contrôleur du porteur active par défaut les capacités octroyées par l'équipement ; une exception explicitement déclarée peut réserver l'activation au contrôleur de l'équipement [Q284].
- Remplacement d'un équipement de slot selon les règles de départ préexistantes [Q252]. Il n'existe pas de durabilité universelle ; charges propres aux cartes si prévues [Q254]. Une capacité à charges exige la quantité entière avant toute dépense [Q286].
- Pour Lot 1, les deux équipements passifs apportent respectivement `+2 ATK` et `+2 ARMOR`. Les charges et activations spéciales d'équipement sont [HORS LOT1].

### 3.11 Victoire/défaite [VALIDÉ Q15–Q16, Q63]

- Héros humain ≤0 PV : défaite immédiate.
- Héros adverse ≤0 PV avec héros humain vivant : victoire immédiate.
- Mort simultanée des deux héros lors d'une opération indivisible : **défaite du joueur**.
- Arrêter immédiatement la séquence ultérieure, capacités différées comprises, lorsque le résultat est définitif.
- Afficher le résultat, les stats synthétiques utiles et un bouton de relance.

---

## 4. Catalogue officiel du Lot 1 — 16 cartes [VALIDÉ Q297–Q298]

**Important** : la sélection, les coûts et les statistiques ci-dessous sont la **base de réglage validée** ; les valeurs peuvent évoluer à l'équilibrage. Les capacités individuelles qui n'étaient qu'esquissées au moment de Q298 sont ici signalées **[CONFIG/PROPOSITION]** ; ne pas les faire passer pour des règles historiques.

### 4.1 Créatures

| card_id | Nom | Peuple | Mana | ATQ/PV | Rôle et capacité initiale |
|---|---|---|---:|---|---|
| `human_recruit` | Recrue du Royaume | Humain | 1 | 2/2 | Attaquant économique ; sans capacité supplémentaire |
| `human_guard` | Garde du Rempart | Humain | 2 | 1/5 | Défense ; **armure 1 [CONFIG]** |
| `human_knight` | Chevalier du Serment | Humain | 4 | 4/5 | Polyvalent ; **+1 ATQ si en ligne d'attaque [PROPOSITION]** |
| `elf_archer` | Archer Sylvestre | Elfe | 2 | 3/2 | Attaquant léger ; sans capacité supplémentaire |
| `elf_healer` | Guérisseuse des Bois | Elfe | 3 | 1/4 | Actif simple ; **soigne 2 PV à une créature alliée pour 1 mana [CONFIG]** |
| `elf_sentinel` | Sentinelle des Brumes | Elfe | 4 | 3/5 | Soutien défensif ; **+1 armure personnelle en défense [PROPOSITION]** |
| `dwarf_guardian` | Gardien de Fer | Nain | 2 | 2/4 | Armure naturelle ; **armure 1 [CONFIG]** |
| `dwarf_runecrafter` | Forgeur des Runes | Nain | 4 | 3/5 | Protection ; **à l'invocation +2 bouclier à lui-même [PROPOSITION]** |
| `dragon_whelp` | Dragonnet des Braises | Dragon | 3 | 4/3 | Offensif ; sans capacité supplémentaire |
| `dragon_drake` | Drake Ancestral | Dragon | 6 | 7/7 | Menace lourde ; sans capacité supplémentaire |

**Règle d'implémentation** : les passifs et les actifs doivent être déclarés dans les données et interprétés par le moteur. Pour les capacités notées [PROPOSITION], s'il n'existe pas d'accord ultérieur, conserver des règles simples sans ajouter de nouvelles primitives complexes. Un fichier de configuration doit pouvoir les ajuster sans toucher au moteur. Les chiffres de fixture des héros et des capacités sont à documenter avec le build.

### 4.2 Sorts

| card_id | Nom | Mana | Condition de ciblage | Opération |
|---|---|---:|---|---|
| `spell_fireball` | Boule de feu | 3 | 1 créature ennemie | `DAMAGE(4)` |
| `spell_heal` | Lumière réparatrice | 2 | 1 créature alliée | `HEAL(3)` |
| `spell_barrier` | Barrière arcanique | 2 | 1 créature alliée | `ADD_SHIELD(3)` |
| `spell_blessing` | Bénédiction martiale | 2 | 1 créature alliée | `MODIFY_STAT(ATK,+2,UNTIL_TURN_END)` |

### 4.3 Équipements

| card_id | Nom | Mana | Type | Modificateur |
|---|---|---:|---|---|
| `equip_runic_blade` | Lame runique | 2 | Arme | `MODIFY_STAT(ATK,+2,WHILE_EQUIPPED)` |
| `equip_bastion_armor` | Armure du Bastion | 3 | Protection | `MODIFY_STAT(ARMOR,+2,WHILE_EQUIPPED)` |

### 4.4 Répartition et fixture decks [LOT1/CONFIG]

- Générer **deux decks de 40 cartes** à partir de ces 16 définitions avec plafonds de copies conformes (maximum 4 par identité/famille). Le deck joueur et le deck IA peuvent être identiques au premier test, puis varier par une fixture contrôlée.
- Définir les quantités exactes de chaque carte dans `combat_fixture.tres`, sans coder en dur les decks dans `CombatEngine`.
- Fixer dans la fixture les PV initiaux des héros, capacité de mana de départ, plafond de mana, héros de démonstration et graine RNG ; **ces valeurs ne sont pas des choix définitifs d'équilibrage général**.
- Ne pas exiger de créations de cartes uniques au-delà des 16 pour remplir un deck : répéter des copies dans la limite réglementaire.
- Ne pas mettre de carte qui requiert une mécanique hors Lot 1 dans la fixture.

---

## 5. Contrat de données Godot [VALIDÉ Q290, Q300–Q301]

### 5.1 Technologies

- Godot **4.x stable**, version exacte inscrite dans le dépôt ; GDScript **typé** ; jeu **2D** ; export Windows prioritaire.
- Résolution de référence **1920×1080**, usage possible **1280×720** ; 16:9 privilégié, adaptation du layout aux fenêtres PC.
- Definitions `.tres` avec classes `Resource` ; textures, sons, animations et présentations isolés des propriétés de règles.
- Pas de nécessité d'une couche JSON, d'éditeur nodal de capacités, de DSL maison ni d'un script de gameplay différent pour chaque carte.

### 5.2 Types de données minimaux (noms indicatifs)

```text
CardDefinition Resource
  definition_id: StringName         # ex. spell_fireball
  display_name: String
  card_type: enum                   # CREATURE / SPELL / EQUIPMENT
  rarity: enum                      # COMMON / UNCOMMON / RARE / EPIC / LEGENDARY
  tribe: enum?                      # HUMAN / ELF / DWARF / DRAGON (selon pertinence)
  mana_cost: int
  base_attack: int?; base_max_hp: int?; base_armor: int?
  equipment_slots: []               # max 1 arme + 1 protection
  target_spec: TargetSpec?
  abilities: Array[AbilityDefinition]
  presentation_ref: CardPresentation

AbilityDefinition Resource
  mode: PASSIVE | ACTIVE | TRIGGERED
  activation_cost: CostSpec?
  condition: ConditionSpec?
  target_spec: TargetSpec?
  operations: Array[EffectOperation]
  trigger_event: StringName?
  duration: DurationSpec?

EffectOperation Resource
  op_code: StringName               # DAMAGE / HEAL / ADD_SHIELD / MODIFY_STAT / EQUIP...
  parameters: typed properties      # pas de GDScript arbitraire dans la carte
  execution_policy: INDEPENDENT | DEPENDENT | ATOMIC_GROUP

CardCopy
  copy_id: unique; definition_id; owner_id; zone; zone_order

BoardInstance
  instance_id: unique; copy_id; definition_id; controller_id
  position; damage_taken; shield_reserves; modifiers; equipment_refs
  movement_used; summoned_turn; abilities; effect_durations

CombatState
  combat_id; rules_version; rng_state; active_camp; turn_phase
  hero_state[2]; zones[2]; board[2][6][2]; event_queue
  next_instance_sequence; status; result

CombatCommand
  actor; action_type; source_id; target_ids; board_position?; params?

CombatResult
  accepted: bool; rejection_code?; state_revision
  ordered_events: Array[CombatEvent]; resulting_status

CombatObservation
  public_state; self_private_hand; legal_action_descriptors; masked_opponent_info
```

**Précision d'identité** : `definition_id` = modèle de carte ; `copy_id` = exemplaire possédé dans le deck ; `instance_id` = séjour sur le plateau. Ne jamais les confondre.

### 5.3 API / contrats entre modules [LOT1]

```text
CardCatalog.load_and_validate() -> ValidationReport
CardCatalog.get_definition(definition_id) -> CardDefinition
CombatFactory.new_combat(fixture, rng_seed) -> CombatState
CombatEngine.get_observation(actor_id) -> CombatObservation
CombatEngine.get_legal_actions(actor_id) -> Array[CombatCommandDescriptor]
CombatEngine.validate(command) -> ValidationResult
CombatEngine.execute(command) -> CombatResult
CombatEngine.get_state_hash() -> String
EffectRegistry.resolve(effect, resolution_context) -> EffectOutcome
AIController.choose_action(observation, legal_actions, rng_state) -> CombatCommand
CombatPresenter.consume(result.events, projected_state) -> void
```

`get_legal_actions()` doit connaître les cibles/positions réellement légales ; l'interface n'en déduit pas indépendamment les règles. Pour l'IA, fournir une interface de simulation/évaluation qui ne divulgue pas la main et la pioche privées adverses. Les types exacts et méthodes statiques/instance sont des décisions d'implémentation, à conserver cohérents avec les tests.

### 5.4 Registre initial d'effets [LOT1]

- `DAMAGE`, `HEAL`, `ADD_SHIELD`, `MODIFY_STAT` temporaire/permanent sous condition, `EQUIP` et `UNEQUIP`, `SUMMON`, `DRAW`/`MOVE_CARD_ZONE` pour les règles de tour, `MOVE_UNIT`, `SWAP_UNITS`, `SPEND_MANA`, `GAIN_MANA` sous contrôle du moteur.
- Les passifs simples sont calculés en termes de modificateurs actifs, **pas appliqués à répétition** comme des bonus persistants à chaque rafraîchissement.
- Les déclencheurs simples `ON_SUMMON`, `ON_DEATH`, `ON_DAMAGE_TAKEN`, `ON_TURN_START`/`END` peuvent exister dans l'architecture même si seul `ON_SUMMON` est utilisé par la fixture initiale.
- Les opérations non supportées dans le Lot 1 doivent échouer à **la validation du catalogue**, avec diagnostic intelligible ; pas de no-op silencieux en combat.

### 5.5 Validation au chargement [LOT1]

Tester identifiants uniques, coût non négatif, PV max ≥1, type/attributs cohérents, op_code reconnu, paramètres complets et de bon type, cible compatible, durée valide, slots d'équipement 0..2 avec catégories compatibles, références d'assets valides ou fallback explicite, pas de cycles de définition interdits. Erreur bloquante et liste des ressources fautives avant lancement du combat.

### 5.6 Ordre logique et erreurs [VALIDÉ Q277, Q287–Q289, Q302]

```text
UI/IA -> commande -> validation -> préparation des opérations atomiques
  -> validation des invariants -> commit
  -> contrôle victoire/défaite
  -> émission événements et triggers FIFO -> stabilisation complète
  -> snapshot/révision/retour CombatResult
  -> projection UI, animations et sons
```

- Une action n'est pas interrompue par une animation. L'UI peut permettre la suivante dès que la présentation des éléments nécessaires est à jour ; les particules décoratives restent libres de finir.
- Les animations dépendent des événements produits par le moteur ; une animation ne provoque jamais de dégâts.
- En cas d'erreur de programmation pendant une opération non commitée : conserver le dernier état valide, stopper proprement la résolution avec rapport et graine reproductible ; ne pas traiter l'erreur technique comme une cible invalide normale.

---

## 6. IA adverse V1 [VALIDÉ Q265–Q266, Q299]

### 6.1 Obligation

Une IA **heuristique** capable de finir un combat seule, réévaluant l'état après chaque commande légale. Pas de triche (aucun accès à la main du joueur ou à la pioche masquée), aucune règle privée. Reproductible à graine + état donnés.

### 6.2 Boucle de décision

1. Obtenir `CombatObservation` de l'adversaire.
2. Récupérer les commandes autorisées du moteur, **y compris terminer le tour**.
3. Évaluer les commandes candidates dans une politique de score explicable, sans appliquer de mutation sur le vrai combat.
4. Choisir le maximum avec départage stable/RNG contrôlée ; exécuter par `CombatEngine.execute`.
5. Recommencer sur le nouvel état jusqu'à fin de tour ou fin de combat ; imposer un garde-fou contre des actions volontaires infinies.

### 6.3 Heuristiques minimales [LOT1]

Priorités fortes : victoire immédiate légale ; éviter une défaite immédiate si une défense accessible existe. Puis : valeur attendue des attaques à venir, dégâts effectifs sur héros/cibles, réduction de menaces, protection de son propre héros, qualité de placement/colonne, économie de mana, soin réellement utile, équipement pertinent sur porteur durable. Ne pas soigner des PV déjà pleins ni buff une cible déjà condamnée sans intérêt. L'IA sait terminer son tour même si elle conserve du mana ; elle ne boucle pas sur des commandes rejetées.

Un profil `balanced` suffit à Lot 1 ; autres profils stratégiques paramétrables, pas indispensables maintenant. Préserver la possibilité Q265 de pondérations par adversaire et archétype Q266 sans ajouter de scripts par carte.

### 6.4 Tests IA

- Main avec seulement cartes inabordables : termine son tour.
- Létal accessible : privilégie la victoire si détectable par l'heuristique de premier niveau.
- Créature alliée presque morte menacée : peut poser une défense pertinente.
- Sort de soin sans cible blessée : ne l'utilise pas ou le moteur ne propose aucune action légale.
- Suite répétée avec même graine : mêmes décisions et mêmes événements.
- Le changement de main cachée du joueur, à observation publique identique, n'affecte pas le comportement de l'IA.

---

## 7. UX/UI et direction artistique [VALIDÉ Q126–Q154, Q290–Q295, Q302]

### 7.1 Direction visuelle

Fantasy **illustrée semi-réaliste**, peintures numériques détaillées, éclairages cinématographiques, personnages et silhouettes identifiables. Univers cohérent, finition premium et animations expressives. **Créer une identité originale**, sans recopier logos, illustrations ou cadres d'une licence existante.

Le jeu affiche les cinq raretés : **Commun blanc, Peu commun bleu, Rare rouge, Épique violet, Légendaire or** [Q181]. Ce code couleur ne constitue pas seul un indicateur (formes, bordures, libellés accessibles). Les teintes exactes et pourcentages ne sont pas à arbitrer au Lot 1.

### 7.2 Écran de combat

- **16:9**, référence **1920×1080** ; compatible **1280×720** ; adaptation dimensionnelle réelle et vérifiée.
- **Plateau central immersif**, adversaire en haut, joueur en bas ; héros et ressources toujours visibles ; main du joueur dans la zone basse ; indicateur de tour et bouton « Terminer le tour » accessible.
- 24 cases identifiables en permanence même avec effets/animations ; distinction de la rangée ATTACK / DEFENSE et des colonnes 1..6.
- Panneaux de journal/inspection secondaires contextuels ou escamotables, pas de panneau latéral permanent mangeant le plateau.
- Les créatures sur plateau sont des **jetons en écusson fantasy**, portrait dominant [Q293–Q294]. Cela **remplace** l'ancienne géométrie « médaillon circulaire/ovale » de Q129, sans modifier l'emplacement des statistiques ni les niveaux d'information Q127–Q134.

### 7.3 Cartes et écussons

- **Main :** cartes premium illustrées avec nom, coût, type, valeurs imprimées, capacités et rareté ; interaction par glisser-déposer **et** sélection puis clic sur cible/case [Q154]. Animation fluide, zoom/inspection de carte et validation légale avant mutation.
- **Écusson :** ATQ effective **bas gauche**, PV actuels **bas droit**, portrait identifiable, signalisation de camp, armure/bouclier non confondus, jusqu'à **3 icônes d'état** puis `+N` pour le surplus [Q128–Q132]. PV max dans tooltip/inspection.
- **Survol/focus :** tooltip tactique synthétique, comprenant valeur actuelle, protections et états significatifs, sans tronquer les informations qui peuvent être vues au clic.
- **Clic :** ouvrir **carte d'origine inchangée** + panneau de détails séparé donnant les **valeurs finales**, différences imprimé/effectif, sources, échéances, restrictions et capacités [Q133–Q134]. Les infos effectives ne doivent jamais réécrire le recto imprimé.
- **Interactions :** cases légales/surlignages, zones de ciblage, retour de carte en main en cas d'annulation ou dépôt illégal ; Échap annule une sélection **non encore committée** ; aucune annulation implicite d'une action résolue [Q153–Q154].
- **Information adverse :** les cartes en main adverse affichent leur dos, sauf effet explicitement révélateur ; ne pas masquer ses créatures ni ses ressources publiques.

### 7.4 Feedback « juicy » et lisibilité

Contrats événement -> rendu :

| Événement | Feedback minimal observable |
|---|---|
| Carte sélectionnée | Surélévation, halo discret, animation de préhension, zones légales |
| Carte jouée | Trajectoire depuis la main, impact d'invocation, métamorphose en écusson |
| Créature déplacée | Interpolation vers nouvelle case / permutation synchronisée |
| Attaque | Mise en tension, projectile ou frappe, impact et retour lisible |
| Dégâts PV | Flash bref sur cible, nombre de **PV effectifs** perdu, variation PV |
| Armure absorbée | Étincelles/ricochet métallique et valeur d'absorption dédiée |
| Bouclier absorbé | Effet énergétique distinct, diminution du compteur de bouclier |
| Soin | Halo positif, nombre de PV restaurés effectivement |
| Buff/expiration | Effet magique localisé, changement de statistique, échéance actualisée [Q140] |
| Mort | Désintégration/transfert visuel, case libérée, événement de mort |
| Fin de combat | Annonce victoire ou défaite lisible, arrêt des contrôles, relancer |

- Durées VFX paramétrables ; désactiver/réduire motion et densité de particules si besoin sans changer la logique.
- Effets prioritaires devant les décorations ; ne pas masquer durablement PV, ciblage ou cases. Les VFX terminés tardivement ne réécrivent **jamais** un état de jeu plus récent.
- Audio recommandé (clic, pioche, impact, absorption, invocation) mais utiliser des placeholders licenciés/locaux si assets définitifs indisponibles ; le critère principal est une identité cohérente, pas un volume encyclopédique d'assets.

### 7.5 Scènes proposées [LOT1]

```text
scenes/
  combat/CombatScreen.tscn           # racine visuelle, orchestration de présentation
  combat/BattlefieldView.tscn       # grille logique projetée en 2D
  combat/CampBoardView.tscn         # 6 x 2 cases
  combat/CreatureToken.tscn         # écusson illustré et overlays tactiques
  cards/CardView.tscn               # carte complète, main et inspecteur
  cards/HandView.tscn
  cards/CardTooltip.tscn
  cards/CardInspector.tscn          # recto original + panneau courant
  hud/HeroHUD.tscn
  hud/TurnHUD.tscn
  hud/CombatResultOverlay.tscn
  effects/CombatVFXLayer.tscn
scripts/
  domain/                            # commandes, état, effets, file d'événements
  catalog/                           # ressources et registre de définitions
  ai/                                # IA heuristique
  controllers/                       # adaptateurs domaine -> GUI
  presentation/                      # écoute et visualisation des événements
resources/cards/                     # 16 .tres
resources/fixtures/                  # héros, decks, RNG
assets/                               # illustration, UI, FX, audio
```

La structure est proposée comme base de travail, non comme obligation de créer un fichier par classe si cela nuit à la lisibilité. Privilégier petites unités autonomes adaptées à Codex + Gemini Flash.

---

## 8. Tests automatisés et critères d'acceptation

Les tests sont **à réaliser**, non présumés exécutés. Les scénarios ci-dessous forment la recette du Lot 1 ; chacun devra posséder un nom d'identification stable, une fixture reproductible, une commande et une assertion de résultat.

### 8.1 Matrice de tests métier

| ID | Scénario | Résultat attendu |
|---|---|---|
| L1-B01 | Lancement avec 2 decks de 40 | État valide, 6 cartes initiales, joueur actif |
| L1-B02 | Début du premier tour | Croissance/restauration Q275, aucune pioche normale supplémentaire |
| L1-B03 | Tours personnels suivants | Pioche 1, mana restauré et capacité augmentée selon plafond |
| L1-B04 | Carte trop chère | Action rejetée, aucune mutation/mana consommé |
| L1-B05 | Invocation avec colonne ennemie non contestée | Seules les places prioritaires admissibles sont proposées |
| L1-B06 | Invocation sur plateau libre | Placement légal sur attaque ou défense |
| L1-B07 | Mal d'invocation | Nouvelle unité protège mais n'attaque pas normalement ce tour |
| L1-B08 | Déplacement naturel | 1 mana, même colonne, 1 fois par tour |
| L1-B09 | Permutation alliée | 1 mana total, droits des deux consommés |
| L1-B10 | Fin de tour | Attaques C1→C6, cible attaque → défense → héros |
| L1-B11 | Absence de riposte | Une attaque normale ne contre-attaque pas |
| L1-B12 | Armure 2, bouclier 3, dégâts 7 | Absorptions 2 puis 3, perte 2 PV |
| L1-B13 | Deux groupes de bouclier | Consommation par échéance, total affichable cohérent |
| L1-B14 | Bouclier consommé | Réserve restante correcte, sans restauration spontanée |
| L1-B15 | Soin sur unité blessée | PV plafonnés, quantité effective correcte |
| L1-B16 | Soin sur unité pleine | Pas de PV excédentaires, pas d'ON_HEAL positif |
| L1-B17 | Bénédiction temporaire | +2 ATQ immédiatement ; expiration correcte fin du tour concerné |
| L1-B18 | Équipement arme et protection | Coûts payés, porteur compatible, bonus effectifs |
| L1-B19 | Deux armes sur un même porteur | Rejet/remplacement selon règle d'emplacement [Q252], jamais double slot non autorisé |
| L1-B20 | Mort d'une créature | Départ plateau, défausse et ON_DEATH, case libre |
| L1-B21 | Cible invalidée avant résolution | Pas de reciblage, pas de remboursement, autres opérations indépendantes poursuivies |
| L1-B22 | Dégâts atomiques multiples | Une seule validation de l'état final avant événements différés |
| L1-B23 | Héros adverse tué | Victoire immédiate et arrêt des actions suivantes |
| L1-B24 | Héros humain tué | Défaite immédiate |
| L1-B25 | Deux héros morts simultanément | Défaite du joueur |
| L1-B26 | Pioche vide, trois tentatives | Fatigue 1, puis 2, puis 3, ignorent armure/bouclier |
| L1-B27 | Carte supplémentaire au-delà de main max 7 | Défausse automatique avec motif correct |
| L1-B28 | Actions de l'IA | Toutes valides, pas d'accès aux cartes cachées |
| L1-B29 | Même seed + mêmes commandes | Même empreinte d'état, mêmes événements et issue |
| L1-B30 | Erreur technique simulée en opération atomique | Aucun commit partiel de l'opération fautive ; état technique explicite |
| L1-B31 | 17e définition utilisant DAMAGE/HEAL existants | Cataloguée sans branche métier spécifique ni changement du moteur |
| L1-B32 | Ressource `.tres` malformée | Diagnostic de validation avant démarrage |

### 8.2 Tests de parcours graphique et expérience

| ID | Critère observable |
|---|---|
| L1-U01 | 1920×1080 : aucune information essentielle hors champ, aucune carte inutilisable |
| L1-U02 | 1280×720 : zones de clic, PV et mana lisibles ; 24 cases accessibles |
| L1-U03 | 24 créatures simultanées : ATQ/PV et appartenance visibles, sans recouvrement critique |
| L1-U04 | Survol d'un écusson : tooltip ; clic : fiche avec recto original et valeurs finales |
| L1-U05 | État avec plus de trois icônes : trois icônes prioritaires + `+N` exact |
| L1-U06 | Carte jouée par drag/drop et par clic-clic : commande logique identique |
| L1-U07 | Dépôt sur case invalide : carte revient sans perte de ressource |
| L1-U08 | Invocation/attaque/armure/bouclier/soin/mort : feedbacks distincts et correctement synchronisés |
| L1-U09 | Animation secondaire encore active : prochaine action possible quand plateau visuellement cohérent |
| L1-U10 | Dernier événement VFX ancien : ne remplace jamais l'état affiché plus récent |
| L1-U11 | Main adverse privée : dos de cartes uniquement ; IA soumise aux mêmes règles |
| L1-U12 | Tour IA entièrement automatique ; bouton fin de tour joueur accessible ; résultat et relance utilisables |
| L1-U13 | Accessibilité : ne pas dépendre uniquement des couleurs, accès aux détails par focus/clic |

### 8.3 Critères de sortie obligatoires (gate)

La livraison Lot 1 est **ACCEPTÉE** uniquement si :

1. Toutes les règles métier utilisées par le mini-catalogue passent leurs tests automatisés, sans régression bloquante.
2. Un utilisateur peut faire une partie complète en utilisant souris et interface, sans terminal de commande.
3. L'IA effectue un tour et joue jusqu'à la conclusion du combat sans blocage ni triche.
4. Les 16 définitions sont effectivement chargées depuis le catalogue déclaratif ; aucune carte n'est codée spécialement dans le moteur.
5. La présentation est réellement cohérente et non un assemblage d'éléments de debug ; critères L1-U01..U13 vérifiés manuellement.
6. La partie est reproductible via seed + journal des commandes, pour les opérations prises en charge dans la fixture.
7. Le projet est ouvrable dans la version de Godot indiquée et son lancement est documenté ; export Windows testé lorsqu'il est réalisable.
8. La checklist de validation indique les preuves et l'état **PASS / FAIL / NOT RUN**, sans fausse affirmation d'exécution.

---

## 9. Sécurité des évolutions et discipline de développement IA

### 9.1 Règle pour toute future tâche Codex + Gemini Flash

Chaque prompt doit demander **une seule tranche verticale étroite**, identifier les fichiers à modifier, expliciter les contrats et tests avant modifications, lister les invariants interdits à modifier, puis fournir une condition de terminé vérifiable. Éviter les prompts du type « développe tout le moteur / tout le GUI » qui dépassent les capacités d'un modèle à raisonnement léger.

### 9.2 Garde-fous

- Aucun ajout de mécanique hors Lot 1 « pour faire joli ».
- Aucun passage implicite d'un paramètre [CONFIG] en règle métier [VALIDÉ].
- Aucun calcul de PV, de coûts ou de ciblage dans un script de `CreatureToken`.
- Aucun accès IA au `CombatState` brut contenant des secrets adverses.
- Aucune dépendance moteur à un timer, Tween ou signal d'animation.
- Pas de branche spéciale par carte, aucune modification du moteur exigée pour une nouvelle carte combinant les opérations existantes.
- Pas de remplacement du moteur déterministe par des nœuds de scène comme stockage d'état.
- Interdire les ressources externes sous copyright non autorisées dans le dépôt distribué.

### 9.3 Contrôles avant chaque intégration

Compilation/import Godot sans erreur ; formatage et types ; tests unitaires/domaines ; tests des cartes et ressources ; capture de logs de simulation ; capture vidéo ou screenshots de la scène si vérification visuelle ; commit petit et réversible. Toute régression d'invariant prioritaire bloque l'étape suivante.

---

## 10. Décisions Q290–Q302 consolidées

| Question | Choix | Contrat normatif pour le Lot 1 |
|---|---|---|
| Q290 | A | Windows prioritaire ; Godot 4, GDScript typé, 2D |
| Q291 | A | 16:9, référence 1920×1080, jouable à 1280×720 |
| Q292 | A | Plateau central immersif, héros visibles, main en bas, panneaux contextuels |
| Q293 | B | Créatures sous forme de jetons illustrés, tooltip et inspection au clic |
| Q294 | B | Jetons en **écusson fantasy**, remplace la forme ancienne de médaillon |
| Q295 | A | Illustrations fantasy semi-réalistes, qualité premium et lisibilité |
| Q296 | B | Noyau tactique représentatif (protections, soins, actifs/passifs simples, équipements) |
| Q297 | B | 16 définitions : 10 créatures, 4 sorts, 2 équipements |
| Q298 | A | Mini-catalogue détaillé validé, valeurs rééquilibrables |
| Q299 | B | IA heuristique scorant des commandes légales, aucune triche |
| Q300 | A | Ressources Godot typées `.tres` |
| Q301 | B | Bibliothèque générique d'opérations et composition déclarative |
| Q302 | B | Résolution immédiate, VFX découplés, synchronisation visuelle contrôlée |

---

## 11. Éléments configurables / clarifications d'implémentation non bloquants

Pour permettre le développement sans relancer une série de questions de design, les paramètres suivants sont rangés dans les **fixtures ou fichiers de thème** et peuvent être corrigés après les premiers essais : PV de départ de chaque héros, mana initial et plafond, quantités exactes des cartes dans chaque deck de 40, rareté assignée aux 16 cartes, illustrations finales de chaque carte, pondérations de l'IA, timings VFX, version Godot 4.x exacte, sonorisation finale. Les capacités nouvelles proposées dans la table des créatures ne deviennent obligatoires qu'une fois intégrées à une fixture officiellement retenue.

**Attention sur l'exhaustivité :** cette spécification est **complète pour le périmètre décidé du Lot 1**, pas une réécriture exhaustive des centaines de règles du jeu final contenues dans la v2.8. Lorsqu'une règle historique détaillée est utilisée pendant le Lot 1 (ex. classement des protections létales, événements FIFO ou attribution de dégâts), son texte normatif amont et ses décisions correctives Q275–Q289 doivent être consultés ; ne pas improviser une variante. Les exemples et règles expressément « proposées » de l'ancien corpus n'ont aucune autorité face aux décisions validées.

## 12. Ordre des phases du projet [VALIDÉ]

1. **Lot 1 :** spécification complète → validation documentaire → roadmap/prompting → implémentation du combat vertical jouable → recette.
2. **Lot 2 :** preuve d'extensibilité déclarative/technique et enrichissement ciblé du catalogue pour l'exploration ; **ne pas attendre ~170 cartes**.
3. **Lot 3 :** spécifier et implémenter l'exploration de tour.
4. **Lot 4 :** spécifier et implémenter l'exploration du monde reliant les tours.
5. **Lot 5 :** menus, paramètres et fonctions transversales définitives.

**Prochaine étape demandée :** revue et approbation de la présente spécification Lot 1 ; **ensuite seulement** roadmap détaillée puis prompts unitaires pour Codex + Gemini Flash. Aucun développement n'est présumé commencé ni terminé par la rédaction de ce document.
