# Identité des instances et dernier état connu

**VALIDÉ Q19, Q56–Q58.** Dépendances : [événements](event-queue.md), [ciblage](targeting.md), [résurrection](resurrection.md), [zones](zone-events.md).

## Règles validées
- **INST-001 (Q57)** — `cardId` désigne la même carte acquise, malgré les transferts.
- **INST-002 (Q57)** — `instanceId` désigne un séjour précis sur le champ de bataille ; chaque nouvelle entrée crée un identifiant neuf.
- **INST-003 (Q57)** — Mort, retour en main ou bannissement termine l'instance du plateau. Les mouvements entre cases du plateau préservent l'instance.
- **INST-004 (Q19/Q57)** — Une capacité déjà en file demeure attachée à l'instance qui l'a déclenchée ; une résurrection ne la rattache jamais à l'instance suivante.
- **INST-005 (Q56)** — Une capacité lisant une caractéristique variable de sa source utilise sa valeur **à la résolution** si cette source demeure sur le plateau.
- **INST-006 (Q56–Q57)** — Si la source a quitté le plateau, utiliser les valeurs de son **dernier état connu immédiatement avant son départ** ; ne pas consulter sa nouvelle instance.
- **INST-007 (Q58)** — Une cible explicitement associée à une ancienne instance demeure invalide même si la même carte réapparaît.

## Exemple vérifiable
Instance I1 avec ATQ 5 déclenche une capacité d'attaque dépendante de l'ATQ. I1 meurt avec ATQ 5, carte ressuscitée en I2 à ATQ 3 : la capacité de I1 utilise 5, I2 n'est pas la source. Si I1 avait perdu 2 ATQ avant sa mort, la capacité utiliserait 3.

## OUVERT
- Définir la structure sérialisée des instantanés (valeurs, effets actifs, propriétaire, position et contexte) ; ne pas stocker des liens vers des objets d'instance mutables.
- Cas des caractéristiques modifiées *dans une zone hors plateau* : non spécifié pour les capacités de source d'instance ancienne.

## Tests
[TEST-047 à TEST-051](../09-technical/acceptance-tests.md).

## Extension VALIDÉE Q88–Q94
La source d'une capacité accordée à une créature est la créature porteuse (`instanceId`) ; conserver séparément son origine historique. Les capacités déclenchées lisent les valeurs courantes à la résolution tant que la source existe, sinon son dernier état connu à la sortie. Une prise de contrôle conserve `cardId` et `instanceId`, tous les états et les capacités en file, en modifiant `controllerId` et éventuellement la case (placement ouvert Q95). Voir [sources et contrôle](source-control.md).

## Référence croisée v1.1

Voir [transferts de contrôle](control-transfers.md) pour instanceId préservé lors d’un transfert Q94–Q104.


## Référence croisée v1.3 — identité et empreintes

Les identifiants pertinents pour les futurs événements et le rejeu sont préservés dans la sérialisation canonique et les instantanés, distinctement de la normalisation anti-cycle Q112. Voir [Q122–Q123](../09-technical/causal-budgets-and-replay.md).



## Carte d'origine et vue d'inspection — Q133–Q134

Le [recto imprimé d'origine est présenté séparément de l'état effectif et des effets actifs](../02-art-direction/card-and-board-ui.md). `instanceId` et états fonctionnels persistent indépendamment de la vue d'interface.
