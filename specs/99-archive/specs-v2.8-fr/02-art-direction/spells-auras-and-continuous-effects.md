# Prévisualisation des sorts, auras et résolution déterministe des effets continus — Q155 à Q164

**Statut : VALIDÉ — Q155–Q164.** Décisions de conception issues des réponses explicites du concepteur. Ces règles décrivent un comportement cible ; aucune conformité d’un moteur implémenté n’est affirmée. Les algorithmes précis, les seuils de performance et les valeurs numériques d’exemple restent **PROPOSÉS / À CALIBRER**, sauf lorsqu’une règle identifiée les impose.

## Autorité et références croisées

- [Plateau, interactions, preview isolé et états de certitude Q145–Q154](board-and-tactical-preview.md) : Q149–Q152 définissent la sémantique des prévisions ; Q153–Q154 le commit et l’annulation.
- [Identité des cartes et inspection Q126–Q134](card-and-board-ui.md) ; [statistiques, effets, durées et VFX Q135–Q144](tooltips-durations-and-vfx.md) : Q133/Q134 maintiennent la carte imprimée inchangée ; Q137/Q157 garantissent une lecture stable, sans encombrement.
- [Capacités et déclenchements](../01-combat/abilities.md), [effets temporaires](../01-combat/temporary-effects.md), [ciblage et revalidation](../01-combat/targeting.md), [zone et opérations atomiques](../01-combat/effect-resolution.md), [FIFO et ordre de résolution](../01-combat/event-queue.md).
- [Attaques](../01-combat/turn-sequence.md), [dégâts](../01-combat/damage-resolution.md), [prévention des dégâts](../01-combat/damage-prevention.md), [contrôle](../01-combat/control-transfers.md), [identités d'instances](../01-combat/instance-identity.md).
- [Sécurité des boucles, checkpoints de tour et Q108–Q114](../01-combat/turn-control-and-loop-safety.md), [budgets causaux, journaux, snapshots et replays Q115–Q124](../09-technical/causal-budgets-and-replay.md), [tests d'acceptation](../09-technical/acceptance-tests.md) et [journal des décisions](../DECISIONS.md).

**Principe d'autorité :** le moteur est la source de vérité des transitions et de la légalité, le simulateur utilise les **mêmes règles versionnées** sur une copie isolée ; l'interface ne doit ni réimplémenter des calculs simplifiés ni confondre l'état prévu avec l'état réellement validé.

## Q155 — Prévisualisation des sorts et capacités ciblés (C)

- **UI-155-01** — Étendre aux sorts et capacités ciblés le moteur de prévisualisation défini pour les créatures, les déplacements et les invocations (Q149–Q152).
- **UI-155-02** — Pour la cible hypothétique, prévoir dégâts effectivement reçus, soins effectivement reçus, protections consommées, morts et modifications de caractéristiques **qui découleraient de l'action**, selon les règles du moteur ; inclure les réactions déterministes pertinentes.
- **UI-155-03** — Recalculer à chaque changement de cible ; cache autorisé seulement pour une identité d'état/action/cible/hypothèses inchangée (Q151).
- **UI-155-04** — Ne pas déduire de certitude sur des effets conditionnels, des choix futurs ou des événements aléatoires inconnus ; appliquer Q152.
- **UI-155-05** — Préserver les informations cachées : aucune prévision ne doit révéler un fait que le joueur ne serait pas autorisé à connaître. Un affichage « incertain » peut être nécessaire même si le moteur interne connaît la cause.
- **UI-155-06** — Aucun effet réel, aucune mutation de FIFO, de réservations, de ressources ou de RNG de partie pendant une preview ; coût plafonné par un budget **distinct** de celui du combat ou des animations.

## Q156 — Affichage uniforme pour une et plusieurs cibles (B, précision du concepteur)

- **UI-156-01** — **Mêmes conventions de présentation sur chaque créature**, quel que soit le nombre de cibles. Interdit : changer de langage graphique au seul motif que la zone touche de nombreuses unités.
- **UI-156-02** — Montrer individuellement les conséquences prévisibles sur toutes les unités directement affectées : PV, protections, modifications de caractéristiques, morts, et `?` si incertain, sans supprimer les valeurs réelles.
- **UI-156-03** — La zone directement affectée est soulignée discrètement ; distinguer clairement les unités touchées **directement** et celles impactées seulement par des réactions secondaires.
- **UI-156-04** — Éviter les chevauchements par placement et gestion des couches, sans remplacer le sens des symboles ni masquer arbitrairement les informations de certaines cibles.
- **UI-156-05** — Maintenir les règles des opérations simultanées/atomiques et du ciblage multiple : la représentation n'implique ni ordre nouveau ni addition de dégâts incorrecte.

## Q157 — Modifications de caractéristiques : valeurs finales sur plateau (A personnalisée)

- **UI-157-01** — Pour buffs, debuffs et transformations : afficher sur le plateau les **caractéristiques finales prévisibles**, avec un rendu de prévision identifiable, sans systématiser `avant → après` près de chaque jeton.
- **UI-157-02** — L'inspection détaillée donne, à la demande, **avant → après**, contribution de chaque effet, source, durée/condition, protection et capacités ajoutées ou retirées.
- **UI-157-03** — La carte imprimée ne change jamais (Q133) ; distinguer état réel, état hypothétique et présentation visuelle.
- **UI-157-04** — Conserver le contrat historique Q150 pour les **PV futurs après dégâts/soins** (`PV actuels → PV futurs`) : la simplification Q157 vise surtout les buffs/debuffs de caractéristiques, sans annuler Q150.
- **UI-157-05** — La convention vaut pour les effets mono- et multicibles (Q156) et leurs cumuls (Q137).

## Q158 — Effets conditionnels : plateau limité aux conséquences immédiates (A)

- **UI-158-01** — Lors d'une preview, les valeurs du plateau intègrent uniquement les conséquences **immédiatement actives après la résolution hypothétique**, pas les bonus futurs qui dépendent encore d'un déclencheur ou d'une condition non remplie.
- **UI-158-02** — Ne pas ajouter à chaque effet conditionnel prévisualisé un indicateur permanent ou un nouveau bloc sur la surface de combat ; le détail complet est disponible dans l'inspection dédiée.
- **UI-158-03** — L'inspection décrit condition d'activation, source, conséquence potentielle et durée, en différenciant « actif maintenant », « en attente » et « seulement éventuel ».
- **UI-158-04** — Après application réelle, les états tactiques actifs restent visibles selon les règles Q132/Q136 : Q158 porte sur la **sobriété de la prévisualisation**, pas sur la dissimulation d'un état actif.
- **UI-158-05** — Si la condition est **déjà vraie et le résultat immédiat déterministe**, son effet est inclus dans l'état final prévu ; il ne faut pas le traiter comme un événement futur fictif.

## Q159 — Auras : influence révélée au choix de la source (B)

- **UI-159-01** — Au repos, les unités montrent leurs caractéristiques **effectives** ; aucun halo d'influence permanent ni trait reliant toutes les créatures.
- **UI-159-02** — Sur sélection/focus d'une créature, d'un artefact ou d'une autre source d'aura, surligner discrètement les bénéficiaires **actuels** de son influence, en utilisant des repères autres que la couleur seule.
- **UI-159-03** — L'inspection indique zone/condition de l'aura, source, valeurs et effets bénéficiaires, indépendamment du nombre de cibles ; effets distincts non fusionnés (Q137).
- **UI-159-04** — Si invocation, déplacement, changement de contrôleur ou disparition de source modifie la portée/condition, les bénéficiaires et leurs valeurs sont recalculés selon le moteur.
- **UI-159-05** — La sélection/focus sur périphérique sans hover donne la même information (Q154).

## Q160 — Cascades d'aura : afficher l'état final déterminé (B)

- **UI-160-01** — Une action hypothétique peut entraîner des effets continus indirects : recalculer les conséquences **immédiates déterministes**, y compris lorsqu'une première modification active/désactive les conditions d'une autre aura.
- **UI-160-02** — Sur chaque créature concernée, montrer les **valeurs finales cohérentes** prévues (Q157), pas une succession de nombres intermédiaires à l'écran.
- **UI-160-03** — L'inspection décrit les variations intermédiaires et leurs sources, sans insérer des étapes artificielles dans la séquence de jeu.
- **UI-160-04** — Respecter Q152 pour les branches incertaines, indisponibles ou trop coûteuses ; ne pas prédire comme acquis un déclenchement futur conditionnel (Q158).
- **UI-160-05** — Le nombre de bénéficiaires ne modifie pas les conventions visuelles (Q156).

## Q161 — Recalcul selon le graphe de dépendances (B)

- **ENGINE-161-01** — Construire les dépendances **fonctionnelles** entre caractéristiques, conditions d'activation, auras et effets continus ; ne pas fonder la logique sur la seule chronologie d'application ou sur l'ordre du tableau de l'interface.
- **ENGINE-161-02** — Réévaluer les nœuds concernés lorsqu'une entrée du graphe change : source, présence, position, camp, état, durée, capacité, caractéristique ou contrôle si pertinent.
- **ENGINE-161-03** — Pour une portion sans cycle, appliquer un ordre de calcul topologique canonique ; pour les portions cycliques, appliquer Q162–Q163.
- **ENGINE-161-04** — Rechercher un état cohérent stable lorsque les règles admettent une telle résolution ; ne pas supposer qu'une itération naïve converge.
- **ENGINE-161-05** — Les mêmes règles, données, tie-breakers et versions sont utilisés par combat réel, preview, sauvegarde et replay.
- **ENGINE-161-06** — Les évaluations d'effets continus et les événements de capacités déclenchées sont des concepts distincts ; une itération de solveur ne crée pas automatiquement un événement FIFO.

## Q162 — Cycles : neutralisation ciblée et réévaluation (B)

- **ENGINE-162-01** — Détecter les composantes cycliques ; classifier l'absence de point fixe, l'ambiguïté de multiples points fixes ou la présence d'un point fixe retenu par les règles.
- **ENGINE-162-02** — Si aucune solution stable non ambiguë ne peut être retenue, appliquer la **résolution canonique** de Q163 ; ne neutraliser que les **dépendances problématiques** nécessaires, pas toutes les cartes/auras de la composante par défaut.
- **ENGINE-162-03** — Les effets indépendants, même portés par les mêmes cartes, restent actifs s'ils ne dépendent pas des arêtes neutralisées.
- **ENGINE-162-04** — La neutralisation est un état de résolution **temporaire et réévaluable** quand changent les conditions causales ; elle n'est pas une suppression définitive de la carte ou de la capacité.
- **ENGINE-162-05** — Journaliser le graphe/empreinte pertinente, les arêtes écartées, la justification, le résultat retenu et le point de cohérence ; assurer reproduction déterministe.
- **ENGINE-162-06** — Les budgets contre boucles de triggers Q111–Q120 ne remplacent pas le solveur des dépendances et ne sont pas consommés par ses itérations internes.

## Q163 — Priorité sémantique et tie-breaker canonique (B)

- **ENGINE-163-01** — Les contraintes fondamentales de règle ont priorité absolue ; elles ne deviennent pas neutralisables à cause d'un conflit de deux auras.
- **ENGINE-163-02** — Si les règles d'une capacité définissent une priorité explicite valide, la respecter. **Aucune nouvelle capacité prioritaire particulière n'est créée ici.**
- **ENGINE-163-03** — À priorité sémantique égale, départager selon une identité fonctionnelle canonique stable et le contexte versionné pertinent ; ne jamais dépendre de l'ordre de parcours mémoire, de l'horloge ou d'un identifiant instable sans normalisation.
- **ENGINE-163-04** — Chercher une **neutralisation minimale** des dépendances incompatibles ; si plusieurs candidats minimaux satisfont les contraintes, sélectionner un unique candidat par départage canonique documenté.
- **ENGINE-163-05** — Ne pas neutraliser des effets indépendants ; maintenir une trace explicable pour les outils de debug, l'inspection si nécessaire et le replay.
- **ENGINE-163-06** — Distinction entre **principes validés** et **algorithme encore à spécifier** : métrique exacte de minimalité (nombre d'arêtes, poids sémantiques, etc.), schéma concret des priorités, ordre de canonicalisation et format de trace restent **OUVERTS / À DÉFINIR** ; leur implémentation devra être versionnée et ne doit pas être improvisée sans validation.

## Q164 — Points de cohérence atomiques et présentation regroupée (B)

- **ENGINE-164-01** — Avant toute étape logique qui doit lire une caractéristique ou condition touchée par une modification, le moteur garantit que le solveur a fourni un **état cohérent** selon les règles Q161–Q163.
- **ENGINE-164-02** — Une opération atomique validée produit un état fonctionnel cohérent ; l'opération suivante et les réactions FIFO ne doivent pas lire des valeurs périmées. Ne pas exposer de caractéristiques intermédiaires incohérentes comme un état validé.
- **ENGINE-164-03** — Le recalcul à l'intérieur d'une opération est un traitement fonctionnel interne ; les capacités déclenchées conservent les frontières atomiques et l'ordonnancement FIFO préexistants (Q61–Q64, Q108–Q110).
- **ENGINE-164-04** — Conserver dans le journal/trace les transitions **logiquement validées** dans l'ordre réel. L'orchestrateur visuel peut **regrouper, accélérer ou superposer** les rendus secondaires, mais pas modifier événements, causalité, valeurs, morts ou chronologie logique.
- **ENGINE-164-05** — La preview hypothétique exécute les mêmes points de cohérence et le même solveur sur un état isolé ; aucune influence sur l'état réel, le RNG, les budgets FIFO ou les empreintes de replay.
- **ENGINE-164-06** — Les animations n'attendent pas des itérations internes du solveur. La présentation peut privilégier l'état final pertinent tout en conservant les événements majeurs lisibles (Q141–Q144).
- **ENGINE-164-07** — Le cache de prévisions doit tenir compte de la version du solveur, de la canonicalisation et de la signature fonctionnelle pertinente ; invalider les résultats après toute variation susceptible de modifier le graphe ou la solution.

## Architecture de référence proposée (non normative quant aux noms d'API)

1. **Moteur / transaction** : reçoit une action ; vérifie sa légalité ; construit les mutations de l'opération atomique ; calcule les caractéristiques dérivées au point de cohérence ; valide le commit ; émet événements logiques, trace et hash versionnés.
2. **Résolveur d'effets continus** : graphe de dépendances, détection des composantes cycliques, sélection canonique d'une solution / neutralisation ciblée selon Q161–Q163 ; ne produit pas de nouvelles résolutions FIFO par simple recalcul.
3. **Prévisualisation** : état cloné ou immuable ; mêmes règles et solveur ; masque de visibilité des informations cachées ; budget distinct ; états déterminé/incertain/en cours/indisponible ; clé de cache versionnée ; aucune modification du RNG de la partie.
4. **Interface** : affiche les valeurs finales et les statuts sur les unités, identiques pour mono/multi-cibles ; révèle détails et sources dans l'inspection ; n'affiche pas de résultats futurs conditionnels comme actifs.
5. **Orchestrateur VFX** : consomme les commits/événements validés ; hiérarchise et regroupe les animations secondaires ; respecte l'objectif indicatif de 3 à 5 secondes des chaînes complexes (Q144) sans affecter les états.

## Invariants et erreurs à éviter

- `preview(state,action,target)` ne modifie ni `state`, ni RNG, ni FIFO, ni journal réel ; les infos cachées restent cachées.
- `commit` est seul à changer l'état réel ; la preview peut expirer, être partielle ou diverger d'un futur non déterministe, **sans changer la légalité**.
- Même snapshot + même action + même version de règles/solveur + même hypothèse = même résultat et même résolution canonique, sur toutes plateformes.
- Identité de l'effet et de la dépendance persistante : ne pas confondre une nouvelle instance avec un changement d'échéance (Q109), ni les IDs techniques avec une priorité sémantique (Q112/Q163).
- Un état stable candidat qui satisfait les conditions ne suffit pas à prouver qu'il est **unique** ; traiter explicitement la multiplicité de points fixes (Q162).
- Ne jamais confondre le cycle d'un **graphe d'effets continus** avec la boucle d'une **FIFO de déclenchements** (Q111–Q120).
- Préférer ne pas afficher une valeur à une estimation faussement certaine ; les conséquences connues restent visibles.

## Points ouverts à préciser pendant implémentation/prototypage

- Métrique exacte et algorithme de neutralisation minimale ; ordre total canonique des dépendances et gestion de plusieurs points fixes ; schéma de trace/version de solveur.
- Budget de temps/calcul du simulateur, cache et invalidations fines ; stratégie de parallélisation et seuil « en cours » / « indisponible ».
- Densité de présentation pour 24 unités et le tactile : placement automatique des annotations sans changement des conventions.
- Contenu et profondeur des explications d'inspection pour les cycles neutralisés, sans exposer d'informations adverses cachées.

## Conditions d'acceptation

Les scénarios Q155–Q164 sont détaillés sous les identifiants `T-155-*` à `T-164-*` dans [les tests d'acceptation](../09-technical/acceptance-tests.md). Ils constituent **des spécifications de tests à exécuter ultérieurement** ; aucune implémentation n'est attestée.
