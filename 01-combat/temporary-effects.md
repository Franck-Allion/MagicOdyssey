# PV maximum, effets temporaires, échéances et expiration — Q26, Q78–Q84

**Statut : VALIDÉ** pour les règles ci-dessous. Voir [soins](healing.md), [prévention létale](damage-prevention.md), [tour](turn-sequence.md), [résolution atomique](effect-resolution.md), [événements](event-queue.md) et [tests](../09-technical/acceptance-tests.md).

## Q26 et Q78 — Variation de PV maximum : ni soin ni dégât

- Gagner `+X maxHp` accorde également `+X currentHp` ; perdre ce bonus retire `X` aux **deux**. Les blessures sont préservées.
- Ces modifications sont des changements de caractéristiques, **pas** des soins ni des dégâts. Aucun `ON_HEAL`, `ON_DAMAGE_TAKEN` ou `ON_DAMAGE_DEALT` n'est généré du seul fait de ce changement.
- Exemple : 4/6 → (+3 maxHp) 7/9 → (−3 maxHp) 4/6.
- Des événements spécialisés pour le changement de caractéristiques ne sont **pas encore validés**.

## Q79 — Mort provoquée par modification de caractéristiques

- Un retrait de bonus peut amener `currentHp ≤ 0` et provoquer un événement létal.
- Les protections létales **générales** peuvent intervenir immédiatement, dans l'ordre déterministe de [Q73](damage-prevention.md), sauf restriction textuelle explicite. Une seule protection consommée par événement létal.
- Protection effective : `ON_LETHAL_PREVENTED`, pas `ON_DAMAGE_TAKEN` ; pas `ON_DEATH`.
- Pas de prévention : mort effective, `ON_DEATH` ; aucun déclencheur de dégât.
- Exemple : 2/6 avec bonus +3 expirant → résultat théorique −1/3 ; protection « survit à 1 PV » → 1/3 et `ON_LETHAL_PREVENTED`.

## Q80 — Expirations simultanées atomiques

- Tous les bonus et malus arrivés **au même instant** sont retirés dans **une seule opération atomique**. Calculer les effets combinés et leurs compensations **avant** de déterminer les morts et protections.
- Une cible ne traverse pas une succession fictive de morts liée à l'ordre technique de retrait ; un seul événement létal potentiel par cible pour ce retrait atomique.
- Préventions immédiates, commit, contrôle de victoire/défaite, puis mise en file des réactions ; ne pas résoudre de déclencheurs entre les retraits.
- Exemple : +3 PV maximum et −2 PV maximum expirent simultanément : appliquer l'effet **net** de leurs retraits, pas deux états intermédiaires.

## Q81 et Q83 — Décompte des durées

- Une durée numérique « pendant N tours » compte les tours **personnels du camp ayant appliqué l'effet**, et non les tours globaux ou ceux du bénéficiaire.
- Si l'effet est appliqué pendant **son propre tour**, ce tour en cours compte comme **tour personnel 1** ; il expire à la fin de son Nᵉ tour personnel compté, sauf échéance explicite.
- Si l'effet est appliqué pendant **le tour adverse**, le **prochain** tour personnel du camp qui l'applique compte comme tour 1 ; il expire à la fin de son Nᵉ tour personnel compté.
- « Jusqu'à la fin du tour » signifie **fin du tour actuellement actif**, sans attendre un tour personnel. Les échéances explicites (« début de ton prochain tour », « fin du combat », etc.) priment sur la convention de durée numérique.
- Exemple : malus appliqué par le joueur pendant T1 ennemi « 2 tours » → T2 joueur = 1/2, T3 ennemi = actif, T4 joueur = 2/2, expiration en fin de T4.
- `appliedByCamp`, moment d'application et type d'échéance doivent être conservés, sans changer le détenteur logique après disparition de la source (précisions sur contrôle transféré encore ouvertes).

## Q82 — Instants exacts d'expiration

- Échéance **début de tour** : retrait avant croissance de mana → restauration → capacités de début de tour → pioche.
- Échéance **fin du tour courant** : l'effet reste actif lors des attaques automatiques et de leurs réactions ; il expire **après résolution des attaques et réactions**, avant changement de camp.
- Tous les effets dont l'échéance coïncide sont retirés atomiquement. Les réactions générées par l'expiration sont résolues via FIFO avant progression de phase si le combat n'est pas terminé.
- Un bonus offensif « jusqu'à la fin du tour » s'applique donc encore à l'attaque automatique normale du tour.

## Q84 — Granularité des déclencheurs d'expiration

- **Un `ON_EFFECT_EXPIRED` par effet temporaire retiré**, même si l'ensemble est retiré en une seule opération atomique.
- Chaque événement conserve au minimum `effectInstanceId`, type (bonus/malus), source, cible et valeur/variation portée par l'effet, ainsi que l'échéance.
- Tous les événements sont ajoutés **après** commit du retrait atomique et contrôle de victoire. Ils n'interrompent pas le retrait.
- Ordre entre cibles : [Q13](event-queue.md) (camp actif, colonnes 1→6, offense avant défense) ; entre effets de la même cible : **ordre d'application**, puis ID technique stable.
- Exemple : `+2 ATQ`, `+3 maxHp`, `−1 ATQ` expirent ensemble sur une unité : **3 événements** ; une capacité « chaque fois qu'un bonus expire » voit **2 bonus** et se déclenche deux fois, si ses autres conditions sont satisfaites.
- **Pas d'événement global `ON_EFFECTS_EXPIRED` imposé** par Q84.
- Un événement d'expiration se distingue de la mort éventuelle liée au retrait et de la prévention létale ; `ON_DEATH`/`ON_LETHAL_PREVENTED` restent soumis aux règles existantes.

## Points ouverts

- Définition future des événements propres aux **augmentations de caractéristiques** ; ambiguïtés des valeurs maxHp extrêmes (plancher, écrêtage) ; perte de bonus sur unité déjà quittée du plateau et éventuels effets non liés à une cible vivante.
- Ordonnancement exact **inter-familles** de `ON_EFFECT_EXPIRED`, `ON_DEATH`, `ON_LETHAL_PREVENTED` lorsqu'un même retrait atomique provoque les trois reste à préciser : Q84 fixe la granularité et l'ordre **entre événements d'expiration**, pas une nouvelle priorité universelle entre types.
- Règles de transfert de contrôle d'un effet, suppression/dispel anticipé distinct de l'expiration naturelle, et durée de statut à échéance déclenchée demeurent ouvertes.

## Extension VALIDÉE Q85–Q87
À une expiration atomique, les capacités éligibles sont capturées **avant** le retrait, y compris celles de créatures mourant simultanément et celles **accordées par l'effet expirant lui-même** (Q86–Q87). Pour chaque cible, les événements de mort/prévention sont enregistrés **avant** les événements individuels d'expiration (Q85). Voir [sources et contrôle](source-control.md).

## Référence croisée v1.1

Voir [transferts de contrôle](control-transfers.md) pour expirations simultanées des contrôles Q99–Q100 et ON_EFFECT_EXPIRED Q104.

## Référence croisée v1.2

**Q109–Q110** : création durant `ON_TURN_END` n’accorde aucune durée minimale ; expiration à l’échéance suivante, même immédiate. La prolongation garde le même `effectInstanceId` et ne génère pas `ON_EFFECT_EXPIRED`. Après échéance passée : retrait atomique après l’opération courante, réactions en queue FIFO. Source : [capacités de tour et boucles](turn-control-and-loop-safety.md).
