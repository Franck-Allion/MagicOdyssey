# Direction artistique, cartes et interface des créatures — Q126–Q134

**Statut : décisions Q126–Q134 validées**, incluant les précisions personnalisées Q127, Q132 et Q133–Q134. Ces règles portent sur l'interface du jeu ; elles ne modifient pas la résolution fonctionnelle des combats. La gamme chromatique exacte, les dimensions et les icônes finales **restent à arbitrer sur maquette**.

**Documents connexes :** [plateau](../01-combat/battlefield.md), [identité des instances](../01-combat/instance-identity.md), [contrôle](../01-combat/control-transfers.md), [protections](../01-combat/damage-prevention.md), [dégâts](../01-combat/damage-resolution.md), [bonus et durées](../01-combat/temporary-effects.md), [capacités](../01-combat/abilities.md), [tests UI](../09-technical/acceptance-tests.md), [journal de décisions](../DECISIONS.md).

## Q125 — Versions historiques : disponibilité conditionnée au support officiel

Le propriétaire de Q125 est [compatibilité et rejeu](../09-technical/causal-budgets-and-replay.md) ; la direction artistique ne doit pas altérer le moteur historique ni modifier les signatures de gameplay par une simple évolution graphique.

## Q126 — Socle artistique : fantasy illustrée Hearthstone / Magic: The Gathering

- **ART-126-01** : direction **fantasy illustrée, riche et colorée**, avec plaisir de collection et illustrations détaillées, inspirée des qualités visuelles de *Hearthstone* et *Magic: The Gathering*, sans reproduire ni réutiliser leurs images, cadres ou identité protégée.
- **ART-126-02** : identité propre au jeu, cadres premium sans sacrifier lisibilité et ergonomie ; le style précis des peintures et palettes reste à définir par prototypes.
- **ART-126-03** : privilégier la compréhension tactique et la lecture rapide quand l'immersion visuelle risquerait de masquer une information.

## Q127 — Deux rendus de carte et trois profondeurs d'information

- **ART-127-01** : **carte complète premium** en main et en inspection : illustration fantasy riche, colorée et détaillée ; coût, type, caractéristiques, capacités lisibles et hiérarchisées.
- **ART-127-02** : **sur plateau**, ne PAS afficher la carte complète : utiliser un **jeton/portrait illustré** compact, adapté aux 24 emplacements (6 colonnes × 2 rangées × 2 camps).
- **ART-127-03** : trois niveaux de consultation : **jeton** (instantané), **tooltip** au survol (synthèse), **clic** (vue complète de la carte et détails de combat). Prévoir accès équivalent au focus/clavier et sur matériel sans survol ; modalités précises à spécifier en UX.
- **ART-127-04** : l'information temporaire de combat n'altère pas la définition imprimée de carte (cf. Q133).

## Q128 — Affichage adaptatif des informations critiques

- **UI-128-01** : toujours montrer portrait, ATQ effective et PV actuels sur les jetons.
- **UI-128-02** : ajouter uniquement des icônes pour états/capacités tactiquement pertinents selon une hiérarchie UI stable ; ne pas afficher coût de mana, texte complet ou historique sur jeton.
- **UI-128-03** : un effet non affiché sur jeton demeure consultable via tooltip/inspection ; sélection des icônes précisée par Q132.

## Q129 — Médaillon fantasy et socle tactique

- **UI-129-01** : créature matérialisée par un **médaillon portrait circulaire ou légèrement ovale**, avec **socle tactique** discret.
- **UI-129-02** : afficher l'appartenance au camp de manière perceptible (couleur et/ou forme, sans couleur seule) ; préserver visibilité des colonnes, positions offensive/défensive et états de déplacement.
- **UI-129-03** : le design doit rester lisible à occupation maximale de 24 unités ; dimensions exactes non fixées.

## Q130 — Statistiques latérales (option A choisie)

- **UI-130-01** : **ATQ en bas à gauche**, **PV en bas à droite** du médaillon ; icônes d'états prioritaires **sous le portrait**.
- **UI-130-02** : portrait reste élément visuel majeur, chiffres suffisamment contrastés, actualisation après commit fonctionnel ; pas de carte intégrale sur plateau.

## Q131 — Numériques et codes couleur non exclusifs

- **UI-131-01** : ATQ **effective** et PV **actuels** visibles en nombres sur chaque jeton ; PV maximum visibles dans tooltip et inspection.
- **UI-131-02** : bonus/améliorations vs malus/affaiblissements repérés par couleur **et** convention non chromatique (flèches, icônes, signe) ; accessibilité daltonisme.
- **UI-131-03** : **armure et bouclier distincts**, avec indicateurs chiffrés lorsque pertinents. Ne pas confondre armure/bouclier avec les PV ou une hypothétique statistique de défense.
- **UI-131-04** : palette indicative : vert bonus, rouge malus, bleu bouclier, métal armure, orange altération dangereuse, violet contrôle. **Couleurs exactes non validées**, à éprouver sur maquette.

## Q132 — Trois icônes, +N, inspection exhaustive

- **UI-132-01** : **au plus 3 icônes d'état** affichées directement sur jeton, choisies selon priorité tactique **stable** : protections, restriction d'action, menace immédiate, aptitude offensive ; l'ordre de priorité détaillé peut être précisé par la conception UX.
- **UI-132-02** : `+N` signale le nombre d'états supplémentaires masqués (les 3 affichés ne sont pas comptés dans N) ; pas d'icône ni de `+0` fictif si aucun effet restant.
- **UI-132-03** : survol = synthèse de tous les états ; **clic = carte complète + bonus/malus, capacités, protections et autres états exhaustifs**.
- **UI-132-04** : une variation d'état peut modifier le trio visible mais la priorité demeure stable, sans oscillation arbitraire.

## Q133 — Carte imprimée inchangée + panneau latéral conditionnel

- **UI-133-01** : au clic, afficher **la carte d'origine inchangée**, avec son illustration, coût, type, ATQ/PV imprimés et texte de capacités d'origine, dans une grande vue.
- **UI-133-02** : les effets qui modifient statistiques, capacités ou état de combat sont expliqués **dans un panneau latéral séparé**, sans réécrire numériquement ni textuellement le recto original.
- **UI-133-03** : panneau présent si la créature a des changements/effets pertinents ; si rien ne diffère et aucun état complémentaire, la carte originale peut s'afficher seule.
- **UI-133-04** : identifier les sources, types, échéances et capacités temporaires ajoutées, neutralisées ou supprimées ; ne jamais afficher un effet expiré comme encore actif.

## Q134 — Panneau exhaustif avec valeurs finales explicites (option B + précision)

- **UI-134-01** : panneau d'inspection = **référence complète de l'état courant** : statistiques effectives, toutes modifications, capacités temporaires/neutralisées, protections, restrictions, contrôles et états actifs, regroupés en catégories.
- **UI-134-02** : afficher en **tête de panneau et de façon très visible** les **VALEURS FINALES** : `ATQ effective`, `PV actuels / PV max effectifs`, `armure restante`, `boucliers restants` (si applicables). Les statistiques de la carte d'origine sont conservées dans la carte et peuvent être répétées à des fins de comparaison.
- **UI-134-03** : montrer **comment est obtenue l'ATQ finale** : ATQ imprimée + ajustements persistants applicables + bonus/malus actifs = ATQ effective. Même logique pour PV maximum / points de vie actuels, en respectant les règles fonctionnelles Q78–Q80 (le changement de PV max conserve les blessures, pas de soin/dégât automatique).
- **UI-134-04** : **« défense » n'est pas une statistique autonome validée** dans la spécification actuelle. Le panneau restitue l'état défensif réel par **PV, armure, bouclier et protections spécifiques**, sans inventer une valeur de défense totale ou les additionner arbitrairement. Une éventuelle stat DÉF distincte requerra une décision de conception ultérieure.
- **UI-134-05** : afficher chaque effet actif avec **nom/type, contribution chiffrée lorsque applicable, source, durée/échéance ou absence de durée**, et capacité affectée. Groupes recommandés : `Statistiques`, `Protections`, `Capacités`, `Contrôle`, `Restrictions/altérations` ; pas de limite arbitraire de lignes, autoriser défilement dans le panneau.
- **UI-134-06** : séparation des valeurs **imprimées**, **modifications**, **finales** ; les chiffres finaux doivent être cohérents avec ceux du jeton Q128/Q130/Q131 au même état de combat.
- **UI-134-07** : le panneau ne remplace pas le journal historique des événements : il reflète **l'état actif actuel**. Un historique complet peut être une fonctionnalité distincte non décidée.
- **UI-134-08** : si seules des blessures ou des consommations de protection demeurent, le panneau doit pouvoir présenter ces **états courants** sans prétendre qu'il s'agit de buffs temporaires ; la condition d'apparition porte sur les différences/états pertinents, pas uniquement les bonus/malus.

### Exemple d'inspection non ambigu

Carte d'origine `Gardien runique` : **3 ATQ / 8 PV maximum imprimés**. En combat, `+2 ATQ` actif, 6 PV actuels, 2 armure et 1 bouclier :

| En-tête du panneau : valeurs finales | Valeur affichée | Explication |
|---|---|---|
| **ATQ EFFECTIVE** | **5** | 3 imprimée + 2 bonus actif |
| **PV ACTUELS / MAX EFFECTIF** | **6 / 8** | Deux blessures encore présentes |
| **ARMURE** | **2** | Protection active |
| **BOUCLIER** | **1** | Protection active |

Le recto de carte continue d'afficher **3 ATQ / 8 PV**. Le jeton montre **5 ATQ et 6 PV**. Le panneau fournit le calcul complet. En présence de bonus de PV max (Q78), utiliser le PV max **effectif** au lieu de l'imprimé et ne jamais confondre bonus de max PV et soin.

## Dépendances et questions ouvertes

- La priorité exacte entre états de même catégorie, les dimensions, la palette finale, l'animation, le tooltip précis, la disposition smartphone/écran réduit et le design complet du plateau seront discutés après Q134.
- La différence entre caractéristique imprimée et amélioration **persistante RPG** doit rester explicite selon [carte et instances](../01-combat/instance-identity.md). Le terme « carte d'origine » renvoie au recto de référence pour le combat considéré ; les modalités de présentation des améliorations RPG persistantes restent ouvertes.
- **Q135** : règles de couleur et conventions des valeurs finales, notamment comment signaler modification positive/négative et blessures sans surcharger le panneau.
