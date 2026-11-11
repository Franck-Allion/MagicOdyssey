# Bannissement — v0.6

**Statut : VALIDÉ (Q45).** Dépend de [hand-and-discard](hand-and-discard.md), [zone-events](zone-events.md), [targeting](targeting.md).

## VALIDÉ
- **ZONE-005 (Q45)** : chaque camp dispose d'une zone de bannissement distincte de sa défausse.
- **ZONE-006** : une carte bannie est inaccessible pendant le combat à toute pioche, récupération, recyclage ou résurrection **ordinaire**.
- **ZONE-007** : le bannissement dure jusqu'à la fin du combat.
- **ZONE-008** : la carte reste acquise au joueur, et redevient disponible pour les combats ultérieurs, notamment si elle appartient à son deck persistant.
- **ZONE-009** : aucune réintégration automatique dans la défausse pendant le combat.

## Conséquences
- La zone de bannissement est la cinquième zone, avec deck, main, plateau, défausse.
- Un effet de résurrection ordinaire ne peut pas cibler une carte bannie ; les vérifications de ciblage s'appliquent ([targeting](targeting.md)).
- Les événements de transfert vers le bannissement suivent [zone-events](zone-events.md).

## OUVERT
- Existence future de rares effets qui ciblent **explicitement** les cartes bannies (l'interdiction ordinaire est validée, pas une exception future).
- Sort des jetons, cartes générées ou empruntées lorsque le combat se termine.
