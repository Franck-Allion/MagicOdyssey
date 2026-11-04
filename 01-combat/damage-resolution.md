# Résolution des attaques et des dégâts

**Statut : principales décisions validées, calculs secondaires à préciser** · Q09–Q12, Q18, Q21. Dépend de [battlefield.md](battlefield.md), [damage-prevention.md](damage-prevention.md), [event-queue.md](event-queue.md), [victory-and-defeat.md](victory-and-defeat.md).

## Règles VALIDÉES
- **DMG-001** : à la fin du tour du joueur actif, ses créatures en attaque frappent C1→C6 ; pas de riposte normale.
- **DMG-002** : cible normale : créature ennemie attaque > créature ennemie défense > héros adverse.
- **DMG-003** : chaque attaque normale frappe une cible ; dégâts excédentaires **perdus**, sauf Piétinement.
- **DMG-004** : **Piétinement** transporte le résiduel vers la ligne suivante, puis éventuellement le héros ; nécessite l'élimination effective de la créature ciblée.
- **DMG-005** : armure et bouclier diminuent la quantité qui peut être transmise ; si la cible survit, la propagation s'arrête ; chaque cible suivante applique ses propres protections.
- **DMG-006** : l'attaque complète, Piétinement compris, précède la résolution des capacités de mort ou de dégâts déclenchées par cette attaque.
- **DMG-007** : une créature à 0 PV ou moins meurt et quitte le plateau. Ses capacités de mort peuvent être mises en attente.
- **DMG-008** : aucun effet différé ne peut annuler rétroactivement les dégâts déjà appliqués.
- **DMG-009** : effets d'une colonne entièrement résolus avant la suivante.
- **DMG-010** : exception prioritaire : mort immédiate d'un héros, voir [victory-and-defeat.md](victory-and-defeat.md).

## Exemples
- Attaquant 8 ATQ sans Piétinement contre ennemi 2 PV : ennemi meurt, 6 dégâts perdus.
- Même attaque avec Piétinement contre ennemi attaque 3 PV + ennemi défense 2 PV sans protections : 3 puis 2 absorbés, 3 atteignent le héros.
- Si une protection létale empêche la mort de la première cible, le Piétinement s'arrête.

## OUVERT
- Définition formelle du « résiduel » pour chaque type de réduction/prévention ; Q22 : ordre de protection validé ; calcul exact du reliquat avec protection létale encore ouvert.
- Statuts indestructible, dégâts égaux à zéro, dégâts au-delà du maximum, attaques spéciales, durées et soins, effets infligeant simultanément des dégâts à plusieurs cibles.

## Extension v0.7 — VALIDÉ Q63–Q64
- Dégâts simultanés : grouper par cible les composantes compatibles et appliquer les protections une fois au total ; préserver distinctement les composantes nécessitant des règles de protections différentes.
- Commit simultané des résultats d'une opération atomique ; vérifier victoire immédiatement après commit. Voir [effect-resolution](effect-resolution.md).


## Attribution, dégâts simultanés et déclenchements — v0.8 (Q65–Q69)

**Règles normatives :** voir [attribution des dégâts](damage-attribution.md) pour le regroupement des composantes compatibles, la participation collective des sources, la méthode des plus grands restes et la distinction entre quantum de dégât et déclenchement. La simultanéité et le contrôle de victoire restent définis par [la résolution des effets](effect-resolution.md).

## Extensions validées Q75–Q84
La variation concomitante de `currentHp` et `maxHp` n'est ni un soin ni un dégât (Q78). Si elle provoque une mort, appliquer les protections létales générales puis `ON_DEATH` ou `ON_LETHAL_PREVENTED` (Q79). Voir [effets temporaires](temporary-effects.md) et [soins](healing.md).


## Référence de présentation v1.5

Les nombres flottants représentent les pertes de PV **effectives**, les absorptions d’armure/bouclier et les soins sont visuellement distincts : [Q143 — Feedbacks de combat](../02-art-direction/tooltips-durations-and-vfx.md). La couche visuelle ne change ni l’attribution ni les événements du moteur.
