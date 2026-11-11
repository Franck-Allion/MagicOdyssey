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
