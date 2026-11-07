# Recherche dans la pioche, visibilité et fatigue progressive — Q210–Q214 (v2.2)

> **Statut : VALIDÉ**. Ce document complète et corrige [Q41 / Q42](draw-and-fatigue.md), [Q43](hand-and-discard.md) et [Q53–Q54](recovery.md). La **fatigue fixe de Q41 est remplacée** par la progression Q210. Les valeurs des cartes concrètes de recherche restent **OUVERTES**.

## Invariants du moteur
1. La recherche opère sur des **instances de cartes de la pioche de combat**, pas sur la réserve hors combat ni sur le catalogue de drafts ([deck actif et réserve Q205–Q209](../03-progression/deck-reserve-and-capacity.md)). Les cartes en main, défausse ou plateau n’y sont éligibles que si un effet explicite étend la zone recherchée.
2. Le moteur résout toute recherche, sélection, déplacement et mélange via des transitions d’état et la file FIFO normatives ([résolution atomique](effect-resolution.md), [file](event-queue.md), [événements de zone](zone-events.md)). RNG déterministe et consignation nécessaires pour sauvegardes/replays ([replay](../09-technical/causal-budgets-and-replay.md)).
3. Une carte obtenue par transfert depuis la pioche n’est **pas automatiquement piochée** ni « nouvellement obtenue » pour le pool de collection ; un effet doit explicitement demander une véritable pioche pour en déclencher les événements.

## Q210 — Fatigue progressive (modification Q41)
- **DRAW-210-01** : compteur de fatigue `fatigueAttempts[heroId, combatId]` initialisé à 0 à chaque début de combat.
- **DRAW-210-02** : quand une vraie **tentative de pioche** échoue parce que la pioche est vide, incrémenter le compteur puis faire perdre **directement** `n` PV, où `n` est le nouveau compteur (1, 2, 3, ...).
- **DRAW-210-03** : les tentatives réussies, les recherches sans résultat et les récupérations depuis la défausse ne déclenchent pas la fatigue, et ne remettent pas le compteur à zéro. La fatigue passée demeure malgré toute réintégration ultérieure de cartes.
- **DRAW-210-04** : aucun recyclage automatique ([Q43](hand-and-discard.md)); les effets explicites peuvent recycler des cartes, sans effacer le compteur.
- **DRAW-210-05** : perte directe de PV, pas des dégâts ; ignore armure, boucliers et protections létales ordinaires ; seules les protections explicitement prévues contre la fatigue/perte létale directe sont applicables ([Q41](draw-and-fatigue.md)). Ne déclenche pas « subit des dégâts ».
- **DRAW-210-06** : multi-pioche résolue séquentiellement Q42 avec événements FIFO entre tentatives ; mort du héros annule la suite.

## Q211 — Deux sortes de recherche, choisies par l’effet
- **DRAW-211-01** : `targeted` : le joueur choisit une instance éligible ; `randomEligible` : le moteur choisit une instance au hasard parmi les instances éligibles, via RNG déterministe.
- **DRAW-211-02** : les critères (type, élément, coût, caractéristiques, etc.) appartiennent à la définition de l’effet et sont évalués sur l’état éligible au moment prévu par la résolution.
- **DRAW-211-03** : sans permission explicite d’accès à d’autres zones, uniquement cartes dans la pioche ; aucune visibilité du contenu non éligible.
- **DRAW-211-04** : coûts, limites et règles de ciblage propres aux cartes restent à équilibrer ; les recherches ciblées et aléatoires ne sont pas interchangeables.

## Q212 — Destination, mélange et échec définis par l’effet
- **DRAW-212-01** : chaque effet déclare la destination autorisée : main, dessus de pioche, défausse ou autre zone explicitement validée par l’effet.
- **DRAW-212-02** : chaque effet déclare **si et quand** mélanger la pioche ; sans instruction de mélange, ordre relatif des autres cartes préservé.
- **DRAW-212-03** : recherche sans carte éligible : pas de sélection ni de fatigue ; les composantes indépendantes du sort continuent si applicables. Si le texte prévoit un mélange même sans résultat, le moteur l’effectue ; sinon aucun mélange implicite.
- **DRAW-212-04** : transfert vers la main ≠ pioche (sauf instruction explicite) ; appliquer la limite de main Q38, et si une carte ne peut rester en main, suivre les règles de zone/effet, sans inventer un nouveau comportement.
- **DRAW-212-05** : RNG et résultat de la sélection/mélange inscrits dans les événements, permettant déterminisme et rejouabilité.

## Q213 — Visibilité restrictive et interface
- **DRAW-213-01** : lors d’une recherche ciblée, afficher **toutes et seulement** les instances éligibles, inspectables, sans ordre de pioche ni cartes non éligibles.
- **DRAW-213-02** : la recherche aléatoire n’ouvre pas de sélection ; présenter seulement le feedback/resultat effectivement visible.
- **DRAW-213-03** : toute donnée affichée respecte les permissions et le masquage d’information, y compris dans le [journal de combat](../02-art-direction/combat-journal-and-inspection.md).
- **DRAW-213-04** : Q213 envisageait un regroupement possible, mais **Q214-A tranche explicitement pour un affichage individuel**, même pour des copies identiques.

## Q214 — Affichage individuel de chaque exemplaire (option A)
- **DRAW-214-01** : afficher **chaque instance éligible séparément**, même si plusieurs cartes ont même nom, identité de modèle ou caractéristiques identiques. **Aucun regroupement de copies avec badge `×N`** pendant une recherche ciblée.
- **DRAW-214-02** : chaque entrée possède un identifiant d’instance stable interne, sans confondre l’identité de carte (modèle) et celle de la copie ; l’UI peut inspecter les modifications pertinentes à chaque instance.
- **DRAW-214-03** : le joueur choisit **une instance précise**, transférée selon Q212 ; aucune sélection automatique d’un autre exemplaire équivalent.
- **DRAW-214-04** : tri visuel autorisé pour lisibilité, à condition de **ne pas révéler l’ordre réel de la pioche** ; les cartes identiques restent des entrées séparées.
- **DRAW-214-05** : à la résolution, valider que l’instance choisie existe encore dans la zone et demeure éligible ; si elle ne l’est plus, respecter la politique existante de cible invalide ([Q20](targeting.md)), sans choisir silencieusement une autre copie. Aucun RNG de départage inutile.
- **DRAW-214-06** : recherches sans résultat : conserver la sémantique d’échec Q212, sans afficher de sélecteur vide ni déclencher la fatigue.

## Cas d’acceptation clés
- Pioche vide et demande de 3 cartes : fatigue 1/2/3 avec FIFO, interruption en cas de mort ; carte réinsérée n'efface pas le compteur déjà accumulé.
- Recherche ciblée dans une pioche contenant trois instances de « Boule de feu » : **trois entrées distinctes**, inspectables, choix d'une seule instance ; aucune indication d'ordre réel.
- Recherche aléatoire sans cible : pas d'interface de sélection, pas de fatigue, pas de changement d'ordre sans instruction de mélange.
- Recherche en main pleine : appliquer Q38/Q212 ; une recherche n’est pas artificiellement requalifiée en pioche pour déclencher des effets « on draw ».

## Références croisées et points ouverts
- [Deck actif/réserve et capacité Q205–Q209](../03-progression/deck-reserve-and-capacity.md), [filtres des marchands et récompenses Q201–Q204](../03-progression/merchant-stock-and-deck-limits.md).
- [Pioche Q36–Q42](draw-and-fatigue.md) · [Défausse Q43](hand-and-discard.md) · [Récupération Q53–Q54](recovery.md) · [Identité d’instance](instance-identity.md) · [Ciblage Q20](targeting.md) · [tests](../09-technical/acceptance-tests.md).
- **OUVERT** : cartes réelles et leurs coûts, filtres concrets, UX de pagination si liste très longue, libellés du feedback, éventuelles permissions de révélation exceptionnelles propres à des cartes futures. Ces points ne changent pas la règle validée d’affichage individuel Q214.
