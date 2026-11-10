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
