# Soins, événements de soin et attribution — Q75–Q77

**Statut : VALIDÉ.** Voir [l'attribution des dégâts](damage-attribution.md), [les effets atomiques](effect-resolution.md), [la file d'événements](event-queue.md), [les modifications des PV maximum](temporary-effects.md) et [les tests](../09-technical/acceptance-tests.md).

## Q75 — Soins excédentaires

- `requestedHeal` = quantité positive de soin demandée. `effectiveHeal = min(requestedHeal, max(0, maxHp-currentHp))` pour une cible vivante éligible, sauf effet spécial explicite.
- `effectiveHeal` est le seul montant ajouté aux PV de la cible. Tout surplus est perdu par défaut ; un effet de carte peut explicitement convertir ce surplus.
- Les soins ne dépassent jamais les PV maximum ordinaires. Conserver séparément `requestedHeal`, `effectiveHeal`, `overheal` (surplus).

## Q76 — Déclenchement ON_HEAL

- `ON_HEAL` est émis **uniquement si effectiveHeal ≥ 1**. Un soin tenté avec zéro PV restauré ne déclenche rien.
- L'événement conserve le montant effectivement restauré, non le montant demandé.
- Les réactions rejoignent la [file FIFO](event-queue.md), après l'achèvement de l'opération ou effet composé ; elles ne l'interrompent pas.
- Une augmentation des PV actuels accompagnant un gain de PV maximum **n'est pas un soin** : aucun `ON_HEAL` ([Q78](temporary-effects.md)).

## Q77 — Soins simultanés compatibles

- Les composantes simultanées compatibles visant la même cible dans la même opération atomique sont additionnées **avant** le plafonnement aux PV manquants.
- **Un seul** `ON_HEAL` est émis par cible et opération atomique lorsque le total restauré est ≥ 1 ; valeur = soin effectif total.
- Les parts de soin effectivement attribuées aux sources sont des entiers ; leur somme est égale au soin effectif total. Attribution proportionnelle aux contributions demandées positives par **méthode des plus grands restes**, exactement comme [Q68–Q69 pour les dégâts](damage-attribution.md). Départager les égalités par ordre stable des sources, puis ID stable.
- La contribution d'une source peut être créditée de **0**, même si elle a participé au soin global. Q77 **ne valide pas** un événement distinct de type `ON_HEAL_DONE` pour chaque source : une seule émission `ON_HEAL` par cible.
- Exemple : cible 4/10, soins A=4 et B=5 ; soin effectif 6, surplus 3 ; attribution A=3, B=3 ; `ON_HEAL(6)` une seule fois.

## Points ouverts

- La sémantique d'éventuelles capacités spécifiques aux *sources* de soins reste à définir ; ne pas les assimiler automatiquement à `ON_HEAL`.
- Interactions de soins et dégâts au sein de **composantes incompatibles**, effets de remplacement non spécifiés ou modificateurs spéciaux de soin : définir explicitement avant implémentation.
