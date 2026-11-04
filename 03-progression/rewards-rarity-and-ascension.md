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
