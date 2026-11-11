# Sphérier permanent du héros — décisions Q185–Q189

> **VALIDÉ :** principes explicitement décidés, sans valeurs d’équilibrage. **Source de vérité** pour l’EXP, les niveaux, les points, les chemins et la réinitialisation. Documentation de conception, non implémentée.

## Modèle canonique et séparation des persistances

- **Q185 personnalisée :** le héros possède un **arbre/sphérier de compétences permanent**, inspiré du principe de sphérier de RPG, apportant des caractéristiques (+PV par exemple), améliorations élémentaires (dégâts de feu) et capacités. L’objectif est la montée en puissance vers des tours plus difficiles. Il ne s’agit **pas** d’une simple offre de trois améliorations par niveau. Les compétences acquises demeurent entre les ascensions.
- **Q186 B :** l’**EXP de combat est permanente** (Q179), contribue au **niveau permanent** du héros ; chaque niveau accorde des points de compétence (quantité ouverte). Points gagnés et non dépensés persistent. Les tours difficiles peuvent rapporter davantage d’EXP, sous réserve du rendement Q192.
- **Q187 C :** départ central, branches thématiques interconnectées, progression de proche en proche et passerelles entre spécialisations. Les nœuds avancés ont des prérequis explicitement affichés. Un nœud verrouillé ne peut être acquis même avec assez de points.
- **Q188 C :** coûts de nœuds **prédéfinis individuellement**, variables avec la valeur mécanique et le type de compétence, pas nécessairement proportionnels à la distance. Le chemin et les points suffisants sont exigés.
- **Q189 B :** **réinitialisation totale gratuite** depuis la préparation **hors ascension**, avec confirmation explicite ; restitue l’intégralité des points investis, conserve niveau/EXP/capital total acquis, permet une nouvelle répartition légale. Aucune réinitialisation en cours d’ascension.

## Contrats fonctionnels

| ID | Invariant |
|---|---|
| RPG-185-01 | Les bonus permanents du sphérier modifient les caractéristiques/capacités du héros conformément au moteur, y compris les spécialisations élémentaires. |
| RPG-185-02 | Les effets déjà achetés dans l’arbre sont actifs pour les ascensions suivantes ; aucune remise à zéro implicite à la défaite. |
| RPG-186-01 | L’EXP de Q179 et le niveau permanent sont conservés en cas d’échec, victoire, fermeture ou nouvelle tentative. |
| RPG-186-02 | À chaque niveau, attribuer le nombre paramétré de points sans duplication ; les points restants sont persistants. |
| RPG-187-01 | L’accès à un nœud respecte la topologie de dépendances, les passerelles et les prérequis explicitement configurés. |
| RPG-187-02 | L’UI distingue acquis, accessible, verrouillé et explique le verrouillage. |
| RPG-188-01 | Dépenser le coût configuré une seule fois après validation atomique ; fonds négatifs interdits. |
| RPG-189-01 | Reset intégral gratuit, uniquement hors tentative active ; pas de retrait individuel validé. |
| RPG-189-02 | Le reset rembourse les points effectivement investis et maintient exactement le capital total mérité. |

## Articulation avec Q184, Q180 et Q182

Deux sources de bonus au héros **coexistent sans être confondues** :

1. **Sphérier permanent Q185–Q189** : développement par points issus des niveaux/EXP ; conservé entre les ascensions.
2. **Améliorations temporaires de récompenses Q180/Q184** : sélection de bonus de caractéristiques ou capacités durant l’ascension ; supprimées en fin de tentative.

Le deck constitué et les artefacts ramassés pendant l’ascension sont temporaires (Q182). Le catalogue de cartes/artefacts éligibles au futur draft est permanent : voir [tours, déblocages, commerces](towers-merchants-and-unlocks.md). Le moteur de combat doit lire un instantané cohérent des bonus permanents et temporaires, voir [résolution atomique](../01-combat/effect-resolution.md) et [effets continus](../02-art-direction/spells-auras-and-continuous-effects.md).

## Ouvert / non validé

Seuils d’EXP par niveau ; nombre de points par niveau ; coûts chiffrés ; contenu et topologie réels ; caps de statistiques ; nombre et rôles de branches ; répartition initiale. Les exemples de +2 PV / bonus feu sont des **types d’améliorations**, pas des valeurs d’équilibrage imposées.

## Extension v2.3 — compétences influençant la préparation

- **Q209** : nœuds permanents peuvent ajuster les bornes de taille du deck (source : [deck et réserve](deck-reserve-and-capacity.md)).
- **Q218 B adaptée** : certains nœuds peuvent augmenter les probabilités des boosters ou garantir une rareté minimale **par booster** (exemple ≥1 Rare+ lorsque éligible), sous [règles de secours Q219](ascension-start-boosters-and-autobuild.md). Nœuds précis non définis.
- **Q222 B** : les compétences réellement acquises orientent prioritairement la composition automatique de deck ; une spécialisation feu favorise les cartes en synergie lorsqu'elles sont présentes, sans en créer.
- **Q224 D** : des nœuds permanents peuvent autoriser des substitutions d'instances dans le **socle fixe de 20 cartes**, par variantes prédéfinies. Il s’agit d’une progression du socle, différente du retrait libre de cartes de base vers la réserve (Q223). Conditions exactes ouvertes.
- Le reset gratuit **entre ascensions** Q189 permet de changer les effets de préparation **pour une nouvelle tentative**, pas rétroactivement au milieu d'une ascension en cours.

## Précision v2.4 — portée des variantes (Q226–Q229)

Le sphérier remplace de façon déterministe des versions **dans les 20 emplacements du socle** avant l'ascension, **pas dans les boosters** ni dans les exemplaires acquis lors de l'ascension. Les versions partagent le plafond de leur famille. Voir [catalogue v2.4](mvp-card-catalog-and-tribes.md).
