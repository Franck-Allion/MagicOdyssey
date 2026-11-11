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
