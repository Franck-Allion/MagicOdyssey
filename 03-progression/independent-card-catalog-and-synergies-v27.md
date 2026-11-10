# Catalogue indépendant du MVP — Q255 à Q264 (v2.7)

**Statut : VALIDÉ pour les décisions ci-dessous.** Les exemples d'effets ne sont pas des cartes définitives. Ce module porte sur les **règles d'usage des équipements** et sur les **objectifs de conception du catalogue**, sans créer de moteur de résolution concurrent. Les plages quantitatives « cibles » constituent des objectifs de conception et ne sont pas des garanties de boosters.

## Dépendances normatives

- [Classification, équipements, zéro à deux emplacements, détachement et charges — Q245 à Q254](../01-combat/equipment-and-card-classifications-v26.md).
- [Catalogue MVP initial — Q225 à Q234](mvp-card-catalog-and-tribes.md) ; [socle de vingt cartes et boosters — Q215 à Q224](ascension-start-boosters-and-autobuild.md) ; [raretés et déblocages](rewards-rarity-and-ascension.md).
- [Ciblage](../01-combat/targeting.md), [changements de zone](../01-combat/zone-events.md), [identités d'instance](../01-combat/instance-identity.md), [résolution des effets](../01-combat/effect-resolution.md), [effets continus](../02-art-direction/spells-auras-and-continuous-effects.md), [sécurité FIFO](../01-combat/turn-control-and-loop-safety.md) et [budgets / replay](../09-technical/causal-budgets-and-replay.md) : restent les seules sources de vérité pour leurs mécanismes.

## Q255 — Équiper une créature ennemie (B)

- **EQUIP-255-01 :** par défaut, un équipement est attachable à une créature **alliée** de son joueur.
- **EQUIP-255-02 :** le texte de la carte peut **autoriser** un porteur ennemi, ou **imposer** une cible ennemie.
- **EQUIP-255-03 :** les conditions habituelles demeurent : présence de l'emplacement **Arme** ou **Protection** sur le porteur (Q250 révisée par Q253), compatibilité du porteur avec la carte et validation ordinaire des cibles.
- **EQUIP-255-04 :** l'équipement ennemi peut occuper un emplacement déjà équipé, en appliquant la règle de remplacement **Q252**, y compris la destination de l'ancien équipement et ses éventuelles exceptions explicites.
- **EQUIP-255-05 :** la propriété de la carte reste distincte du camp du porteur. La sortie du porteur fait rejoindre l'équipement, par défaut, la **défausse de son propriétaire** (Q251), pas automatiquement celle du contrôleur du porteur.
- **EQUIP-255-06 :** les cartes maudites sont une **possibilité de design** et n'imposent ni sous-type technique obligatoire, ni pénalité automatique de faction, ni moteur de contrôle supplémentaire.
- **EQUIP-255-07 :** l'interface indique si la carte cible les alliés, les ennemis ou exclusivement ces derniers ; un ciblage impossible n'entraîne pas un attachement implicite.

**Non décidé par Q255 :** la résolution détaillée d'un éventuel changement de contrôle du porteur **pendant que l'équipement reste attaché**, ou d'une prise de contrôle de l'équipement, conserve les règles générales déjà spécifiées et requiert clarification uniquement si elles ne couvrent pas le cas. Ne pas ajouter ici de nouvelle règle.

## Q256 — Synergies transversales des équipements (C)

- **MVP-256-01 :** plusieurs stratégies peuvent exploiter les équipements ; **aucun archétype d'équipement n'est imposé** au début de l'ascension.
- **MVP-256-02 :** conception de synergies possibles avec créatures équipées, objets joués, remplacés, récupérés et objets attachés à des ennemis ; règles événementielles inchangées.
- **MVP-256-03 :** les synergies peuvent se combiner avec les peuples, factions, types secondaires et éléments (Q245–Q248).
- **MVP-256-04 :** le deck se spécialise en fonction **des cartes effectivement obtenues** dans les deux boosters aléatoires puis durant l'ascension (Q215/Q246), sans ajout ni génération garantie de cartes adaptées.
- **MVP-256-05 :** le catalogue prévoit des cartes créatures/sorts capables de profiter des équipements, sans quota ou puissance précise déterminés à ce stade.

## Q257 — Quota d'équipements indépendants (B)

- **MVP-257-01 :** sur les **100 définitions indépendantes** du MVP, **20 sont des équipements** (20 %).
- **MVP-257-02 :** cible indicative **10 Armes / 10 Protections**, ajustable lors de l'équilibrage, sans modifier le total 20 sans nouveau choix.
- **MVP-257-03 :** ces 20 cartes participent à plusieurs fonctions offensives, défensives, magiques, utilitaires et maudites ; aucune catégorie ne déduit ses effets de son seul emplacement.
- **MVP-257-04 :** les cartes fondamentales (40 définitions) et variantes du sphérier (~30) sont **hors** de ces 100 cartes indépendantes (Q230).

## Q258 — Répartition complète du catalogue indépendant (B)

| Type de carte | Nombre de définitions | Pourcentage des indépendantes |
|---|---:|---:|
| Créatures | **50** | 50 % |
| Sorts | **30** | 30 % |
| Équipements | **20** | 20 % |
| **TOTAL** | **100** | **100 %** |

- **MVP-258-01 :** 50 créatures, 30 sorts, 20 équipements constituent des **définitions de cartes indépendantes**, non des copies physiques dans une ascension.
- **MVP-258-02 :** les fonctions dégâts/défense/contrôle/soutien/pioche/recherche demeurent des **rôles transversaux**, non six autres catégories disjointes ; les anciennes répartitions indicatives de Q232 ne s'additionnent pas aux quotas définitifs Q258.
- **MVP-258-03 :** aucun quota de type de carte n'est garanti dans un booster de 15 ; seuls les cartes **débloquées et éligibles** participent au tirage, conformément à Q218–Q219 et Q246.
- **MVP-258-04 :** le socle de **20 exemplaires neutres**, les deux boosters de **15 exemplaires** et le deck de **40 actives / 10 en réserve** demeurent inchangés (Q215–Q224 et Q246).

## Q259 — Répartition des peuples parmi les 50 créatures indépendantes (C)

| Peuple | Nombre cible de définitions |
|---|---:|
| Humains | **15** |
| Elfes | **14** |
| Nains | **13** |
| Dragons | **8** |
| **TOTAL** | **50** |

- **MVP-259-01 :** la répartition 15/14/13/8 est un **objectif de conception souple**, pouvant subir de petits ajustements pour améliorer l'équilibrage, le total restant 50.
- **MVP-259-02 :** les Dragons sont moins nombreux en **définitions distinctes** ; ils ne sont **pas automatiquement** de rareté Rare/Épique/Légendaire dans les boosters.
- **MVP-259-03 :** aucun peuple n'est synonyme d'un élément, d'une faction unique ou d'un rôle unique ; les 20 exemplaires fondamentaux restent neutres et polyvalents au démarrage.
- **MVP-259-04 :** ces cibles n'imposent ni fréquence de peuple par booster, ni déblocage anticipé, ni garantie de synergies.

## Q260 — Identité tactique et polyvalence des peuples (C)

- **MVP-260-01 :** environ **50–60 %** des créatures de chaque peuple servent directement ses axes dominants ; les autres explorent des rôles alternatifs ou complémentaires.
- **MVP-260-02 :** Humains : commandement/cooperation ; Elfes : mobilité/magie/précision ; Nains : défense/fortifications/artisanat ; Dragons : puissance/éléments ; ces axes sont des **orientations de design**, pas des pouvoirs automatiques ni des interdictions.
- **MVP-260-03 :** cohérence narrative et visuelle conservée même pour les cartes atypiques ; possibilité d'utilisation dans des decks mixtes.
- **MVP-260-04 :** éviter les doublons fonctionnels parmi les **8 Dragons**. Les proportions sont indicatives, pas des contraintes du générateur de booster.

Exemple indicatif **non normatif** : 8 Humains, 8 Elfes, 7 Nains et 4 Dragons dominants (= 27 cartes sur 50), autres 23 profils complémentaires. L'arrondi exact se décide lors de la création du catalogue.

## Q261 — Créatures passerelles entre peuples (B)

- **MVP-261-01 :** **6 à 10** des **50 créatures indépendantes** seront conçues pour encourager explicitement les synergies entre plusieurs peuples.
- **MVP-261-02 :** elles restent incluses dans les quotas Q259, sans cartes supplémentaires, et réparties sur plusieurs peuples et fonctions.
- **MVP-261-03 :** elles peuvent récompenser ou faciliter la composition mixte et les interactions entre peuples, sans imposer un deck multipeuple ni interdire un deck homogène.
- **MVP-261-04 :** concevoir une utilité raisonnable même sans déclenchement optimal de leur synergie ; compatibilité avec les classifications Q245 et la règle d'évaluation de composition Q247 si pertinente.

## Q262 — Profils de créatures hybrides (B)

- **MVP-262-01 :** **25 à 35 %** des 50 créatures indépendantes, soit environ **13 à 18**, remplissent au moins **deux rôles tactiques significatifs**.
- **MVP-262-02 :** le reste du catalogue conserve des rôles principaux clairement lisibles ; hybrider ne signifie ni statistiques supérieures à tous les spécialistes ni carte automatiquement plus rare.
- **MVP-262-03 :** distribution sur plusieurs peuples ; recoupement possible avec les **créatures passerelles** Q261 et évolutives Q263.
- **MVP-262-04 :** proportion de **conception** et non quota de pioche, de génération ou de placement sur le champ de bataille.

## Q263 — Créatures évolutives au cours d'un combat (B)

- **MVP-263-01 :** **5 à 8** des 50 créatures indépendantes sont volontairement conçues autour d'une progression pendant le combat.
- **MVP-263-02 :** les **conditions précises** figurent dans la carte : actions offensives, défensives, sorts, équipements ou événements ; pas de mécanique d'évolution universelle imposée.
- **MVP-263-03 :** la progression peut modifier des caractéristiques, renforcer des effets ou débloquer des capacités par les mécanismes de déclenchement, compteurs et stabilisation existants.
- **MVP-263-04 :** aucune progression permanente **entre les combats** par défaut ; un mécanisme distinct explicitement validé peut prévoir une exception.
- **MVP-263-05 :** les évolutions sont inspectables, visibles et accompagnées d'un feedback clair/expressif sans surcharge visuelle ni modification de la logique moteur.
- **MVP-263-06 :** réparties sur plusieurs peuples ; recoupement permis avec hybride/passerelle ; **aucune nouvelle définition** au-delà des 50.

## Q264 — Cartes à contrepartie : risque/récompense (B)

- **MVP-264-01 :** **8 à 12** des **100 cartes indépendantes** présentent une contrepartie significative, soit un coût supplémentaire ou un désavantage en échange d'un bénéfice plus élevé.
- **MVP-264-02 :** ces cartes peuvent être des **créatures, sorts ou équipements** ; elles sont incluses dans leurs quotas Q258, et non ajoutées à l'effectif.
- **MVP-264-03 :** les contreparties peuvent notamment prendre la forme de perte de PV, sacrifice de créature, défausse, réduction d'une caractéristique ou avantage offert à l'adversaire, selon des effets **explicitement écrits**.
- **MVP-264-04 :** si la contrepartie fait partie d'une **capacité activable facultative**, le joueur choisit de l'activer ou non. Une carte à contrepartie automatique doit l'indiquer explicitement ; la carte n'est pas automatiquement facultative.
- **MVP-264-05 :** les contreparties doivent constituer un arbitrage intéressant et intelligible, pas une pénalité arbitraire ; coûts, cibles, compatibilité et ordre des événements suivent les règles déjà définies.
- **MVP-264-06 :** les cartes à contrepartie peuvent être hybrides, passerelles, évolutives ou équipements maudits ; **ces attributs ne partitionnent pas le catalogue**.

## Invariants transversaux et données attendues du catalogue

1. Budget total approximatif **40 fondamentales + ~30 variantes du sphérier + 100 indépendantes = ~170 définitions** (Q230) ; les variantes sont réservées aux exemplaires du socle. Parmi les **100 indépendantes**, total strict **50 créatures / 30 sorts / 20 équipements**.
2. Les 50 créatures sont réparties selon **15 Humains / 14 Elfes / 13 Nains / 8 Dragons** comme cibles souples ; cette taxonomie concerne les définitions, pas les exemplaires de boosters. Types secondaires et faction restent indépendants du peuple (Q245).
3. Attributs de catalogue **non exclusifs** : 6–10 *passerelles*, 13–18 *hybrides*, 5–8 *évolutives* ; 8–12 *à contrepartie* parmi les **100** cartes et non seulement les créatures. Les groupes peuvent se recouper ; ne **jamais additionner** ces nombres pour calculer un nouveau nombre de cartes.
4. Débloquages, raretés, plafond par famille, répartition des boosters et sphérier **inchangés** (Q181, Q194, Q201, Q207, Q215–Q229, Q246). Aucun nouveau quota de peuple/type/rôle dans les boosters n'est validé.
5. Les cartes « passerelles », « hybrides », « évolutives » et « à contrepartie » sont des **labels éditoriaux de conception**, pas nécessairement de nouveaux types techniques de cartes ou de nouvelles mécaniques automatiques.
6. **OUVERT** : liste finale des cent cartes ; affectation exacte des raretés, des types et des peuples ; coûts et chiffres des capacités ; critères et poids des cartes spécialisées dans le pool effectivement débloqué ; effets et données particuliers de certaines cartes d'équipement maudites. Ne pas promouvoir des exemples en règles.

## Recette

Voir [tests d'acceptation v2.7 : T-255 à T-264](../09-technical/acceptance-tests.md). **Tous sont spécifiés, aucun n'a été exécuté sur un moteur.**
