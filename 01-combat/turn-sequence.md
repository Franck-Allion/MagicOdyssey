# Déroulement des tours — v0.5

**Statut : règles Q09, Q10, Q28, Q29, Q35, Q36 VALIDÉES ; autres phases OUVERTES.**

Dépendances : [hero-deck-mana](hero-deck-mana.md), [draw-and-fatigue](draw-and-fatigue.md), [damage-resolution](damage-resolution.md), [event-queue](event-queue.md).

## VALIDÉ
- **TURN-001 — Q28** : le joueur humain commence toujours le combat, puis alternance des tours.
- **TURN-002 — Q35** : début de tour = croissance de capacité de mana → restauration du mana disponible → résolution des capacités de début de tour → pioche normale.
- **TURN-003 — Q36** : avant le premier tour, pioche initiale de 6 cartes, qui **remplace** la pioche normale de ce premier tour ; première pioche normale au deuxième tour personnel.
- **TURN-004 — Q29** : mal d'invocation : une créature ne peut pas attaquer normalement au tour où elle est invoquée, mais protège sa colonne immédiatement, peut se déplacer et utiliser ses capacités actives selon leurs textes.
- **TURN-005 — Q09** : seules les créatures du joueur actif en attaque effectuent les attaques normales en fin de tour ; pas de riposte automatique de l'adversaire.
- **TURN-006 — Q10** : attaques de la colonne 1 à la colonne 6, en résolvant les événements d'une colonne avant la suivante.
- **TURN-007 — Q31** : mana non dépensé perdu en fin de tour.
- Pendant la phase d'action, le joueur peut invoquer, jouer des sorts et activer des capacités en payant les coûts requis ; voir [movement](movement.md).

## OUVERT / à ne pas inférer
- L'absence de croissance au tour 1 est une **proposition**, pas une validation explicite.
- Calendrier exact des effets de fin de tour ; ordre des effets « début de tour » ; réaction durant le tour adverse ; nombre et ordre d'actions ; effet d'une interruption de combat pendant la préparation.

## Extension v0.6 — VALIDÉ Q48
- Une créature ressuscitée pendant le tour de son propriétaire subit le même mal d'invocation qu'une créature invoquée ordinairement ; voir [resurrection](resurrection.md).

## Expiration des effets — Q81–Q83
- Expirations de **début de tour** avant croissance/restauration du mana, capacités de début de tour et pioche.
- Expirations de **fin de tour** après attaques automatiques et réactions, avant changement de camp.
- Tours numériques = tours personnels du camp qui a **appliqué** l'effet ; tour personnel d'application compte si déjà actif, sinon premier tour personnel suivant compte comme tour 1. Fin du tour courant = tour actif, quel que soit le camp. Voir [effets temporaires](temporary-effects.md).

## Extension VALIDÉE Q94
Lors d'une prise de contrôle, les effets temporaires continuent de compter leur durée selon le camp qui les avait appliqués (Q81–Q83), même si `controllerId` change. Les règles de placement au changement de camp ont été tranchées en Q95–Q104 ; voir [transferts](control-transfers.md). Voir [sources et contrôle](source-control.md).

## Référence croisée v1.1

Voir [transferts de contrôle](control-transfers.md) pour effets de contrôle expirant après combat et transferts Q97–Q104.

## Référence croisée v1.2

**Q105–Q108** : après un transfert effectif, première attaque du premier tour personnel du nouveau contrôleur bloquée (même si acquis hors tour ou retour), sauf exception explicite. Les capacités de début/fin de tour suivent le contrôleur effectif au déclenchement. **Fin de tour** : attaques et réactions → `ON_TURN_END` et réactions entièrement résolues → expiration atomique et réactions → changement de camp. Source normative : [capacités de tour et boucles](turn-control-and-loop-safety.md).
