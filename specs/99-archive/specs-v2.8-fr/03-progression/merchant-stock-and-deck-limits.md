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
