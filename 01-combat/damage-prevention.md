# Armure, boucliers et prévention létale

**Statut : règles Q21–Q23 VALIDÉES ; ordre de départage et détails de prévention létale encore OUVERTS.**  
**Dépendances :** [damage-resolution.md](damage-resolution.md), [abilities.md](abilities.md), [victory-and-defeat.md](victory-and-defeat.md).  
**Décisions :** Q21 option A ; Q22 option A ; Q23 option A.

## VALIDÉ

- **PREV-001** — L’armure et le bouclier diminuent les dégâts disponibles pour le Piétinement.
- **PREV-002** — Une créature qui survit grâce à une protection arrête le Piétinement.
- **PREV-003** — Chaque nouvelle cible traversée applique ses propres protections.
- **PREV-004** — Les effets préventifs / de remplacement interviennent avant que la mort devienne effective ; un soin différé n’est pas une prévention.
- **PREV-005 (Q22)** — L’ordre des protections est **Armure → Bouclier → PV → Protection létale**.
- **PREV-006 (Q22)** — L’armure réduit en premier les dégâts entrants ; le bouclier absorbe ensuite les dégâts restants ; les dégâts non absorbés affectent les PV ; une éventuelle protection létale intervient **en dernier**, si les dégâts feraient mourir la cible.

- **PREV-007 (Q23)** — Pour un même événement létal, **une seule** protection létale est consommée pour empêcher la mort.
- **PREV-008 (Q23)** — Les autres protections létales disponibles restent intactes et pourront servir lors d’un événement létal ultérieur.
- **PREV-009 (Q23)** — La protection consommée est sélectionnée selon une priorité **déterministe et automatique**. Le critère de priorité exact est **OUVERT**.

### Lecture opérationnelle de PREV-005

1. Évaluer les dégâts entrants sur cette cible.
2. Appliquer l’armure pertinente.
3. Déduire l’absorption du bouclier.
4. Déterminer l’impact résiduel sur les PV.
5. Si cet impact serait létal, évaluer les protections contre la mort **avant de rendre la mort effective**.
6. Vérifier si la créature a effectivement été éliminée avant de poursuivre un éventuel Piétinement.

**Important :** l’ordre est validé, mais le comportement exact d’une protection létale (PV fixés à 1, quantité absorbée), les règles de cumul d’armures/boucliers et certains calculs de Piétinement ne le sont pas encore. Ne pas déduire ces règles du seul ordre ci-dessus.

## Exemple d'ordre (sans protection létale)

Cible : **4 PV, armure 2, bouclier 3** ; dégâts entrants **7**. Armure : 7 − 2 = 5 ; bouclier : 5 − 3 = 2 ; la cible reçoit 2 dégâts sur ses PV et survit avec 2 PV. Le bouclier a consommé 3 points. Cet exemple illustre l'ordre validé, sous l'hypothèse de protections à réduction additive.

## PROPOSÉ — NON VALIDÉ

- **PREV-P02** — L'armure réduit les dégâts de chaque attaque ; le bouclier forme une réserve consommable.
- **PREV-P03** — Une protection létale à usage unique maintient la cible à 1 PV, bloque Piétinement et n'est consommée que lorsqu'elle est nécessaire.
- **PREV-P04** — Les dégâts nuls ne déclenchent pas « subit des dégâts ».

## OUVERT — décisions suivantes

1. **Q24** — Quelle priorité déterministe départage plusieurs protections létales (temporaire, artefact, carte ; date d’application, etc.) ?
2. Une protection létale absorbe-t-elle tout le reliquat et comment mesure-t-on la puissance restante d'une attaque avec Piétinement ?
3. Plusieurs boucliers, plusieurs armures et réductions diverses : ordre de départage.
4. Invulnérabilité et Piétinement ; dégâts de sorts hors combat ; dégâts nuls ; protections contre destruction directe.

## Tests

Voir [acceptance-tests.md](../09-technical/acceptance-tests.md) : TEST-015 à TEST-018.

## Extension v0.7 — VALIDÉ Q64
- Pour une même cible, agréger les composantes de dégâts simultanées **compatibles** avant application unique des protections, dans l'ordre Q22. Les types de dégâts nécessitant une protection spécifique demeurent séparés. Voir [effect-resolution](effect-resolution.md).
- **OUVERT** : détails de compatibilité (types/résistances), multiplicité de protections identiques et granularité des déclencheurs par source.


## Protections multiples et événements — v0.8 (Q71–Q74)

Ordre des réactions différées pour chaque cible : `ON_ARMOR_ABSORBED` → `ON_SHIELD_ABSORBED` → `ON_DAMAGE_TAKEN` (seulement avec perte nette de PV) → `ON_LETHAL_PREVENTED`. Au plus un événement par type de protection et opération. Les capacités supplémentaires de la protection consommée suivent `ON_LETHAL_PREVENTED` dans FIFO.

Pour choisir une protection létale, consommer au plus une protection par événement létal ; sélectionner temporaire avant permanente, échéance la plus proche entre temporaires, puis ancienneté, puis identifiant stable. Pour les permanentes, ancienneté puis identifiant. Voir [attribution des dégâts et vol de vie](damage-attribution.md), [file d'événements](event-queue.md), [tests](../09-technical/acceptance-tests.md).

## Interaction avec variations de caractéristiques — Q79–Q80
Le retrait d'un bonus de PV maximum peut créer un événement létal même sans dégât ; les protections létales générales fonctionnent normalement, sauf restriction expresse. Expirations simultanées évaluées en un seul résultat atomique (une seule protection consommable par cible et événement). Voir [effets temporaires](temporary-effects.md).

## Référence croisée v1.1

Voir [transferts de contrôle](control-transfers.md) pour mort de placement non prévenable par protection létale ordinaire Q98.



## Armure/bouclier dans l'interface — Q131–Q134

Les [protections restantes sont indiquées distinctement des PV et de l'ATQ](../02-art-direction/card-and-board-ui.md). Le terme « défense » dans l'UI n'ajoute pas de statistique autonome au moteur.
