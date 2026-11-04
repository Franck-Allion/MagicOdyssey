# Victoire, défaite et mort des héros

**Statut : cœur validé** · Q15–Q16. Dépend de [damage-resolution.md](damage-resolution.md), [damage-prevention.md](damage-prevention.md), [event-queue.md](event-queue.md).

## Règles VALIDÉES
- **VIC-001** : héros joueur à 0 PV ou moins → **défaite immédiate**.
- **VIC-002** : héros adverse à 0 PV ou moins, joueur survivant → **victoire immédiate**.
- **VIC-003** : décès simultané des deux héros au cours d'un même effet indivisible → **défaite du joueur**.
- **VIC-004** : arrêt immédiat de la résolution à mort d'un héros ; les effets FIFO restants ne s'exécutent pas.
- **VIC-005** : un soin déclenché après des dégâts létaux ne sauve pas un héros mort.
- **VIC-006** : une prévention ou un remplacement intervenant avant la perte de PV peut empêcher la mort.

## Cas de test
- Joueur 3 PV, ennemi 4 PV ; sort simultané 5 dégâts aux deux → défaite.
- Joueur 8 PV, ennemi 4 PV ; même sort → victoire, joueur 3 PV.
- Héros adverse tué par Piétinement → arrêt sans exécuter les morts en file déclenchées pendant l'attaque.

## OUVERT
- Définitions précises d'effet indivisible et d'ordonnancement des dégâts simultanés.
- Défaite par abandon, temporisation, autres conditions spéciales.

## Extension v0.7 — VALIDÉ Q63
- Pour une opération atomique, évaluer les préventions avant commit, valider toutes les modifications simultanément, puis tester victoire/défaite immédiatement avant toute autre opération ou événement FIFO. Mort simultanée des deux héros : défaite joueur. Voir [effect-resolution](effect-resolution.md).


## Vol de vie et prévention — v0.8

Le vol de vie est un soin déclenché **différé** : il ne peut annuler la mort d'un héros validée après une opération atomique. Seuls les effets immédiats de prévention/l'interception autorisés avant le contrôle de victoire peuvent intervenir. Les événements `ON_LETHAL_PREVENTED` sont différés. Voir [attribution des dégâts](damage-attribution.md).

## Mort due à un retrait temporaire — Q79–Q80
Un retrait de bonus qui amène des PV à zéro peut tuer, après application des protections létales générales ; un retrait collectif s'évalue atomiquement et le contrôle victoire/défaite intervient au commit avant les réactions. Voir [effets temporaires](temporary-effects.md).


## Référence de progression v1.9

**Transition victoire → récompenses :** voir [Q175–Q180](../03-progression/rewards-rarity-and-ascension.md). Les gains n’altèrent pas les règles de détermination de l’issue du combat.
