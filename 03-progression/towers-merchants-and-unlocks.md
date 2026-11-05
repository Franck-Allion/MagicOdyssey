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
