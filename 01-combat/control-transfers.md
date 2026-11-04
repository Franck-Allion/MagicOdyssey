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
