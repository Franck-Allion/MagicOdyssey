# Attribution des dégâts, vol de vie et réactions aux protections — v0.8

**Statut : VALIDÉ Q65–Q74.** Source normative pour les événements de dégâts. Voir [résolution des dégâts](damage-resolution.md), [prévention](damage-prevention.md), [résolution atomique](effect-resolution.md), [file FIFO](event-queue.md) et [tests](../09-technical/acceptance-tests.md).

## Agrégation et événements (Q65–Q67)

- Les composantes simultanées **compatibles** sont regroupées **par cible** pour l'application des protections, sans perdre l'identité des sources. Les effets requérant des règles particulières restent différenciés (Q64).
- Une cible ayant perdu au moins 1 PV à cause des dégâts produit **au maximum un** `ON_DAMAGE_TAKEN` **par opération atomique**, même pour plusieurs sources (Q65). Si les protections absorbent tout, aucun événement de dégâts subis n'est produit.
- Chaque source à contribution d'entrée positive participe collectivement si l'opération inflige au moins 1 PV de dégâts à la cible ; elle produit **au maximum un** `ON_DAMAGE_DEALT` **par cible et opération atomique** (Q66–Q67). Il n'existe pas de déclenchement `ON_DAMAGE_DEALT` si la perte de PV est nulle. Une source contributrice peut déclencher cet événement avec **quantité attribuée = 0**, sans contradiction : éligibilité collective et volume numérique sont deux données séparées.
- Les événements en attente utilisent les règles [FIFO](event-queue.md) ; ils ne s'intercalent pas dans une opération atomique ni à l'intérieur d'un [effet composé](effect-resolution.md).

## Attribution entière des dégâts effectifs (Q68–Q69)

Soit `d_i > 0` la contribution brute compatible de la source `i` et `L` la **perte effective finale** de PV attribuable à cette opération (non la valeur brute, et non une restauration ultérieure). On utilise `D = somme(d_i)`. Pour chaque source :

1. Part exacte `q_i = L × d_i / D`.
2. Attribution initiale `a_i = floor(q_i)`.
3. `R = L − somme(a_i)` points à distribuer, à raison d'un point aux `R` plus grands restes `q_i − floor(q_i)`.
4. En cas d'égalité des restes, départager par l'**ordre stable des sources** issu du contexte de l'opération, puis par identifiant technique stable.

**Invariants :** `a_i` est un entier positif ou nul ; `somme(a_i) = L` ; aucune création artificielle de PV perdus. L'ordre des sources doit être sérialisé dans le contexte pour rejouer un combat à l'identique. Exemple : contributions 5, 3, 2 ; perte finale de 4 PV ; attributions **2, 1, 1**. Exemple : contributions 3, 2 ; bouclier absorbant 4 ; perte finale 1 : attributions **1, 0** (sans modifier l'éligibilité collective des deux sources à `ON_DAMAGE_DEALT`).

La méthode suppose des dégâts compatibles à contributions positives. La répartition de dégâts hétérogènes, des immunités par type ou de dommages résultant d'effets particuliers reste à spécifier avant introduction de ces mécaniques. Le calcul de perte de PV et de prévention létale demeure prioritaire sur l'attribution.

## Vol de vie (Q70)

- Le vol de vie ordinaire est **une capacité déclenchée** de la source après `ON_DAMAGE_DEALT`, non une prévention ni un soin atomique.
- Sa quantité de soin est **l'attribution entière `a_i`** de sa source, éventuellement `0` ; le soin respecte les PV maximum du destinataire.
- Le soin rejoint la file FIFO et attend la fin de l'effet composé. Il ne sauve pas un héros dont la défaite a déjà été constatée (Q15, Q62–Q63).
- Une participation collective peut donc déclencher une capacité de vol de vie dont la quantité de soin est nulle ; aucune récupération de PV n'en résulte.

## Événements d'absorption (Q71–Q72)

Par cible et opération atomique, produire au maximum :

| Événement | Condition | Contexte |
|---|---|---|
| `ON_ARMOR_ABSORBED` | armure absorbe au moins 1 dégât | `armorAbsorbed` total |
| `ON_SHIELD_ABSORBED` | bouclier absorbe au moins 1 dégât | `shieldAbsorbed` total |
| `ON_DAMAGE_TAKEN` | perte effective finale d'au moins 1 PV due aux dégâts | `effectiveHpLost` |
| `ON_LETHAL_PREVENTED` | une protection létale a réellement empêché une mort | `lethalPreventionUsed` |

**Ordre d'enregistrement pour une même cible :** armure → bouclier → dégâts subis → mort évitée. Omettre les événements non applicables. Pour plusieurs cibles, appliquer aussi les priorités générales [Q13](event-queue.md), en conservant FIFO pour les événements préexistants. L'effet de prévention lui-même intervient **immédiatement** pendant le calcul ; `ON_LETHAL_PREVENTED` est une **réaction différée**.

## Choix de protection létale (Q73)

- Au plus **une protection létale consommée par événement létal** (Q23).
- Privilégier les **temporaires avant les permanentes** (Q24).
- Temporaires : expiration la plus proche, puis plus ancienne date d'acquisition/application.
- Permanentes : date d'acquisition/application la plus ancienne.
- Égalité résiduelle : identifiant technique stable.
- Les autres protections ne sont pas consommées et restent disponibles, sous réserve de leur propre expiration.

## Résultat final après prévention (Q74)

- Déclencher `ON_DAMAGE_TAKEN` **seulement lorsque la cible termine l'opération avec moins de PV qu'au début**, et que cette perte est due à des dégâts. `effectiveHpLost` = cette perte nette pertinente ; les soins produits plus tard ne la modifient pas rétroactivement.
- Déclencher `ON_LETHAL_PREVENTED` si une protection a réellement empêché la mort, **même lorsque les PV finaux ne sont pas inférieurs aux PV initiaux**.
- Les capacités additionnelles propres à la **protection consommée** sont ajoutées à la file FIFO **après `ON_LETHAL_PREVENTED`** ; elles ne sauvent pas rétroactivement de la mort.
- Aucun `ON_DEATH` lorsque la mort est effectivement empêchée.
- Avec une prévention « reste à 1 PV » : PV initiaux 3 → finaux 1 : `ON_DAMAGE_TAKEN` + `ON_LETHAL_PREVENTED` ; avec une prévention « restaure à 6/6 » depuis 3/6 : aucun `ON_DAMAGE_TAKEN`, mais `ON_LETHAL_PREVENTED`. Les sources ne reçoivent pas de quantité positive de dégâts effectifs dans le second cas : pas de vol de vie fondé sur ces dégâts.

## Explicitement ouvert / non déduit

- Le comportement d'effets élémentaires, des résistances spécifiques et des agrégations entre classes de dégâts incompatibles.
- L'attribution individuelle d'absorptions armure/bouclier aux sources pour de futurs effets qui l'exigeraient : seuls les totaux **par cible et type** sont validés.
- Les règles détaillées des soins et des effets temporaires (à partir de Q75).

## Mise à jour VALIDÉE Q89–Q93 — Vol de vie et bénéficiaire
**Rectificatif normatif de Q70 par Q92** : le héros soigné est celui du **contrôleur de la source lors de l'application des dégâts**, et non nécessairement celui du propriétaire permanent. Figer la propriété vol de vie et le destinataire lors de l'application des dégâts, dans `ON_DAMAGE_DEALT` (Q91–Q92). La quantité soignée reste la part de dégâts effectifs attribuée à la source (Q68–Q70). Si la source a quitté le plateau, consulter son dernier état connu ; une nouvelle instance ressuscitée est ignorée (Q89–Q90). Voir [sources et contrôle](source-control.md).
