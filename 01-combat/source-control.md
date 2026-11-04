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
