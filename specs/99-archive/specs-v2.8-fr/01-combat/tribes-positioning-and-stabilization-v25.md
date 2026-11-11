# Peuples, positionnement et stabilisation — décisions Q235–Q244 (v2.5)

**Statut : VALIDÉ.** Ce module consigne surtout des **applications et rappels** des règles historiques, non un deuxième moteur de résolution.

## Sources normatives et règle de précédence

- [File FIFO et priorités Q13–Q14](event-queue.md) ; [résolution atomique et destructions simultanées](effect-resolution.md) ; [dégâts et PV max](damage-resolution.md).
- [Contrôle des boucles FIFO Q111–Q114](turn-control-and-loop-safety.md) et [budgets causaux, journal et replays Q115–Q124](../09-technical/causal-budgets-and-replay.md).
- [Auras, calculs de dépendances et résolution minimale des cycles Q159–Q164](../02-art-direction/spells-auras-and-continuous-effects.md).
- [Familles/peuples et catalogue](../03-progression/mvp-card-catalog-and-tribes.md) ; [sphérier](../03-progression/hero-sphere-and-skill-tree.md) ; [plateau](battlefield.md).

**Non-duplication :** Q242 ne remplace pas Q111–Q124 ; Q243 et Q244 **confirment** Q161–Q164. Les budgets techniques déjà validés demeurent applicables. L’algorithme détaillé de neutralisation minimale reste ouvert dans Q163.

## Registre de décisions

| Question | Choix | Portée |
|---|---|---|
| Q235 | A | Humains, Elfes, Nains et Dragons retenus pour le MVP ; taxonomie extensible, pas nécessairement des peuples de héros. |
| Q236 | C | Identités mécaniques fortes, synergies tribales ouvertes ; decks mixtes et combinaisons éléments/positions. |
| Q237 | C | Sphérier fondé sur mécaniques transversales avec nœuds complémentaires pouvant profiter à certains peuples ; pas de branches tribales obligatoires. |
| Q238 | C | Synergies de peuples globales et positionnelles : rangées, colonnes, voisinage et formations selon le texte. |
| Q239 | C | Adjacent = partage un côté (orthogonal), hors diagonales sauf indication explicite ; autres zones autorisées. |
| Q240 | C | Effets continus recalculés après changements pertinents, aux points de cohérence atomiques ; pas de triggers fabriqués par les itérations. |
| Q241 | C | Conserver les blessures/dégâts subis quand PV max change ; détecter les morts secondaires en lots et stabiliser. |
| Q242 | C | Stabilisation par lots, morts simultanées, puis réactions FIFO ; cycles et budgets causaux existants restent normatifs. |
| Q243 | C | Couches et graphe de dépendances pour effets continus ; confirme Q161 et Q164, sans inventer de nouveau solveur. |
| Q244 | B (confirmation) | Neutralisation minimale et canonique des dépendances cycliques contradictoires ; règle DÉJÀ validée Q162–Q163. |

## Règles complémentaires propres à Q235–Q241

- **RACE-235-01** — Peuples initiaux du catalogue : Humains, Elfes, Nains, Dragons ; types additionnels configurables sans code dur du moteur. Ce choix n’impose pas les peuples des héros.
- **RACE-236-01** — Chaque peuple présente des tendances mécaniques visibles ; certaines capacités ciblent le peuple, mais la majorité des cartes reste utile dans les decks mêlant peuples, éléments et rôles.
- **SPHERE-237-01** — Priorité aux nœuds génériques (armure, magie, formation, mobilité, commandement, éléments) ; bonus tribaux ponctuels et combinables, pas de branche unique obligatoire par peuple.
- **BOARD-238-01** — Les synergies peuvent être globales ou dépendre d’un motif géométrique, et requérir d’autres critères (peuple, élément, contrôleur, état).
- **BOARD-239-01** — `ADJACENT` signifie partage de côté dans la grille 6 × 2 d’un camp ; une diagonale, ligne, colonne, distance ou formation doit être explicitement nommée par la capacité. L’inspection visualise les cases ciblables.
- **BOARD-240-01** — Changement de position, apparition/disparition, contrôle, type, caractéristique ou durée relance les portions du graphe Q161 affectées ; stabilisation aux commits atomiques Q164. Les recalculs purs ne créent aucun événement FIFO.
- **COMBAT-241-01** — Conserver la quantité de dégâts subis lorsque changent les PV max. Une perte de PV max peut rendre une unité létale sans événement de dégâts ; voir règles préexistantes Q26 et Q80–Q86 sur les PV et les opérations simultanées.
- **COMBAT-241-02** — Identifier en lot les unités devenues létales après recalcul cohérent et les traiter comme mortes simultanément pour les déclenchements, dans l’ordre canonique historique des événements Q13/Q27 ; nouvelle stabilisation si disparition d’aura.

## Clarifications de compatibilité Q242–Q244

- **ENGINE-242-01 (rappel)** — Pour un événement atomique : calcul de l’état cohérent, identification par lots des morts, réévaluation si nécessaire ; enregistrement des capacités déclenchées et résolution FIFO sans avancer les réactions avant le commit. Les priorités préexistantes priment.
- **ENGINE-242-02 (rappel)** — Les cycles **de déclenchement** sont identifiés à partir de signatures fonctionnelles du combat et de la FIFO Q112. La neutralisation de la branche et la préservation des événements admis suivent Q111/Q114.
- **ENGINE-242-03 (rappel)** — Les **budgets techniques de sécurité** et les réservations causales par branche, chaîne et opération Q113–Q120 restent en vigueur. Éviter d’affirmer qu’aucune chaîne longue ne peut être interrompue : une limite technique peut bloquer la descendance problématique, sans rollback. Valeurs numériques définitives non fixées.
- **ENGINE-243-01 (rappel)** — Résolution des auras par graphe de dépendances Q161, couches de calcul et points de cohérence Q164 ; ne pas dépendre de l’ordre arbitraire d’apparition des cartes.
- **ENGINE-244-01 (confirmation)** — Cycles d’auras **sans solution stable non ambiguë** : neutralisation minimale ciblant les dépendances problématiques, selon priorité sémantique et départage canonique Q162–Q163. Réévaluation à changement de contexte causal.
- **ENGINE-244-02 (à préciser, non validé comme nouvel algorithme)** — Coût/minimalité exacts, canonicalisation et implémentation des dépendances Q163 restent ouverts ; ne pas inventer une règle supplémentaire ni une valeur numérique de budget.

## Exemples de non-régression

1. Deux Nains voisins reçoivent leur bonus orthogonal ; une case diagonale ne compte pas par défaut.
2. Une aura de commandement disparaît : les blessures restent, des unités peuvent mourir simultanément, puis leurs `ON_DEATH` rejoignent la FIFO selon Q13/Q27.
3. Une boucle `ON_DEATH` ↔ `ON_SUMMON` non progressive est bloquée selon Q111–Q120, sans purger les entrées déjà admises.
4. Deux auras dont les conditions oscillent relèvent de **Q161–Q164**, non des budgets de déclenchement ; elles utilisent la neutralisation ciblée canonique.
5. Une chaîne finie longue peut fonctionner ; les budgets de sûreté par branche/chaîne/opération restent néanmoins effectifs.

## Ouverts

- Identités et métriques exactes des dépendances minimales Q163 ; valeurs de budgets Q113–Q120.
- Identités/effets exacts des premières cartes Humain, Elfe, Nain et Dragon ; équilibre des archétypes.
- Politique détaillée pour situations de sauvegarde au milieu des cascades : utiliser frontières atomiques Q123.
