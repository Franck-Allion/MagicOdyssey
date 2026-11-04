# Invocation des créatures

**Statut : règles fondamentales validées, cas limites ouverts** · Q03–Q04. Dépend de [battlefield.md](battlefield.md), [movement.md](movement.md) et [hero-deck-mana.md](hero-deck-mana.md).

## Règles VALIDÉES
- **SUM-001** : pour invoquer une créature, payer son coût en mana.
- **SUM-002** : toute créature peut être invoquée librement en ligne d'attaque ou de défense, dans un emplacement libre et légal.
- **SUM-003** : lorsqu'il existe des colonnes ennemies **non contestées** (présence d'ennemi et absence de créature alliée), l'invocation doit prioritairement se faire dans l'une de ces colonnes.
- **SUM-004** : si toutes les colonnes avec ennemis sont contestées, le joueur peut invoquer dans toute colonne admissible, y compris vide.
- **SUM-005** : une colonne est contestée dès qu'elle contient une créature de chaque camp, quelle que soit leur ligne.

## Scénarios de test
- Ennemi C2 et C5 ; aucun allié : invocation possible C2 ou C5 (sur ligne libre), pas C1.
- Ennemi C2/C5 ; allié C2 en défense : invocation prioritaire C5.
- Ennemi C2/C5 ; alliés C2/C5 : invocation libre dans les colonnes disposant d'un emplacement.
- Aucun ennemi : invocation libre.

## OUVERT / PROPOSÉ
- **SUM-P01** (proposé) : si les colonnes non contestées n'ont aucun emplacement légal, autoriser une invocation ailleurs plutôt que créer une impasse.
- Définir les cas avec restrictions de cartes, emplacements bloqués, invocations créées par effets et plateau plein.
- Recalculer les obligations à chaque invocation : proposé, cohérent mais non explicitement adopté.

## Extension v0.6 — VALIDÉ Q47
- Les retours par résurrection suivent les mêmes règles de placement et de priorité aux colonnes non contestées : [resurrection](resurrection.md).
- L'absence d'une case légale **au lancement** interdit le sort de résurrection ; une disparition ultérieure des places entraîne l'échec du retour.

## Référence croisée v1.1

Voir [transferts de contrôle](control-transfers.md) pour mêmes règles de placement pour transfert de contrôle Q95.
