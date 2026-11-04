# Ciblage et invalidation

**Statut : comportement principal validé** · Q20. Dépend de [event-queue.md](event-queue.md) et [abilities.md](abilities.md).

## Règles VALIDÉES
- **TGT-001** : lorsqu'un effet désigne explicitement une cible, celle-ci reste liée à l'effet durant son attente.
- **TGT-002** : si la cible devient invalide avant la résolution, l'effet qui la concerne échoue.
- **TGT-003** : aucun reciblage automatique.
- **TGT-004** : le mana déjà payé n'est **pas remboursé** lorsque l'effet échoue.
- **TGT-005** : les effets en file peuvent se résoudre même si leur **source** disparaît (distinct de la validité de la cible).

## Exemple
Un effet à 1 mana cible une créature ennemie ; celle-ci est détruite par une autre capacité avant résolution : l'effet ciblé échoue et 1 mana reste consommé.

## PROPOSÉ / OUVERT
- **VALIDÉ Q59** : les conditions sont vérifiées au lancement et à la résolution.
- **VALIDÉ Q60–Q61** : résolution partielle et opérations indépendantes par défaut.
- Texte « créature ennemie ayant le moins de PV » : sélection à la résolution plutôt qu'au lancement (proposé).
- **VALIDÉ Q57–Q58** : toute ré-entrée crée une nouvelle instance ; anciens ciblages invalides.

## Extension v0.6 — VALIDÉ Q51, Q52
- Les sorts de résurrection ne sont **pas jouables** sans emplacement légal dès le lancement ([resurrection](resurrection.md)).
- Au moment de chaque retour, la cible doit toujours être valide dans la défausse et un placement doit être légal ; sinon cette tentative échoue sans nouvelle cible ni remboursement du mana déjà payé.
- Les résurrections multiples préservent leurs réussites précédentes (Q52).

## Extension v0.7 — VALIDÉ Q58–Q60
- **TGT-006 (Q58)** — La cible de créature est identifiée par son `instanceId`. Après son départ du plateau, le ciblage devient définitivement invalide, même si le `cardId` revient dans une nouvelle instance.
- **TGT-007 (Q59)** — À la résolution, revérifier identité et **toutes** les conditions de ciblage : camp, ligne, colonne, type et autres restrictions explicites. Un mouvement sur le plateau conserve l'identité, pas forcément la légalité.
- **TGT-008 (Q60)** — Chaque cible d'un effet multicible est revérifiée individuellement : les cibles invalides échouent sans reciblage ; les cibles restantes sont affectées normalement.
- **TGT-009 (Q60–Q61)** — La partie ciblée échoue si toutes les cibles manquent, mais les opérations indépendantes continuent ; les opérations conditionnelles et indivisibles suivent leurs propres prérequis explicites.
- **TGT-010** — Aucun remboursement du mana lors d'une invalidation à résolution.
- Voir [instances](instance-identity.md) et [effets composés](effect-resolution.md).

## Extension VALIDÉE Q93
Le changement de contrôleur d'une source après le déclenchement ne réinterprète pas automatiquement « allié », « ennemi » ni les cibles/références de camp déjà fixées. Les restrictions de légalité du ciblage sont revérifiées à la résolution ; aucun re-ciblage automatique. Voir [sources et contrôle](source-control.md).

## Référence croisée v1.1

Voir [transferts de contrôle](control-transfers.md) pour échec transfert lorsque cases invalides à résolution Q96.
