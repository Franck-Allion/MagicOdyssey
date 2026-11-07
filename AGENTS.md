# Instructions pour agents d'implémentation

1. Lire [README.md](README.md), puis le README du domaine et les fichiers associés au concept demandé.
2. Implémenter uniquement les règles portant le statut **VALIDÉ**. Une règle **OUVERTE** ou **PROPOSÉE** exige une décision explicite, ou une hypothèse isolée/paramétrable clairement documentée pour un prototype.
3. Conserver les IDs de règles dans les tests et les commentaires utiles.
4. Moteur de combat indépendant du rendu Phaser. État et actions déterministes ; animations consomment le journal d'événements, ne pilotent pas les règles.
5. Préserver l'identité des créatures et des cibles (ID d'instance), même après disparition de la source. Ne pas reciblER implicitement.
6. Vérifier les dépendances et les scénarios [acceptance-tests.md](09-technical/acceptance-tests.md).
7. Phaser/HTML/JS : une interface polished n'autorise pas à inventer des mécaniques.


## Extension v0.8 : dégâts effectifs et événements

Pour implémenter `ON_DAMAGE_DEALT`, `ON_DAMAGE_TAKEN`, le vol de vie, les protections multiples et `ON_LETHAL_PREVENTED`, lire en priorité [damage-attribution.md](01-combat/damage-attribution.md), puis [damage-prevention.md](01-combat/damage-prevention.md), [effect-resolution.md](01-combat/effect-resolution.md) et [acceptance-tests.md](09-technical/acceptance-tests.md). Ne pas confondre déclenchement collectif et valeur quantitative attribuée. Aucune capacité déclenchée n'interrompt une opération atomique.

## Référence croisée v1.2

**Mise à jour v1.2 :** lire [règles de tour et de sécurité FIFO](01-combat/turn-control-and-loop-safety.md) pour Q105–Q114. Les arbitrages de causalité Q115 ont été validés en v1.3 (voir ci-dessous).


## Référence croisée v1.3

Pour les règles **VALIDÉES Q115–Q124**, lire [budgets, réservations, journal et compatibilité](09-technical/causal-budgets-and-replay.md) et [scénarios de tests](09-technical/acceptance-tests.md). Les budgets chiffrés et noms d’API restent **PROPOSÉS**. Q115 n’est plus ouverte.



## Interface — Q125–Q134 (v1.4)

Pour les créatures, lire [le module d'identité visuelle et d'inspection](02-art-direction/card-and-board-ui.md). La carte d'origine reste inchangée ; le panneau doit présenter ATQ finale, PV actuels/max effectifs, protections et **tous les effets actifs**. Les changements visuels ne modifient pas les règles de combat ou de replay.


## Interface — Q135–Q154 (v1.5–v1.6)

La présentation des effets/échéances/VFX est spécifiée dans [tooltips et durées](02-art-direction/tooltips-durations-and-vfx.md) et les nouveaux comportements de décor, grille contextuelle, simulation prévisionnelle isolée, calcul asynchrone non bloquant, validation moteur et modes d'entrée dans [plateau et prévisualisations](02-art-direction/board-and-tactical-preview.md).

**Ne jamais** confondre prévisualisation et engagement ; ne pas consommer le RNG réel, ne pas modifier la FIFO ou les réservations logiques en prévision. Le bouton/drag de placement est revalidé par le moteur au commit. Les 40 [tests Q145–Q154](09-technical/acceptance-tests.md) sont seulement des critères d'acceptation, non des tests exécutés. Q155–Q164 sont validées ; Q165 est ouverte.


## Extension v1.7 — Effets continus et previews

Lire [Q155–Q164](02-art-direction/spells-auras-and-continuous-effects.md) avant d’implémenter des zones, buffs, auras ou cycles. Même solveur déterministe/versionné pour partie et prévision, mais preview isolée sans fuite d’information cachée ; rendus et VFX ne sont pas la source de vérité. Voir [tests d’acceptation](09-technical/acceptance-tests.md). Les détails de l’algorithme canonique de neutralisation et les valeurs concrètes de budgets restent ouverts.

## Règles UI journal Q165–Q174 — v1.8

Lire [le journal de combat et l'inspection historique](02-art-direction/combat-journal-and-inspection.md) pour toute fonction d'historique. Ne jamais révéler une entrée avant son point de présentation VFX ni exposer les données cachées dans la recherche ou les résumés. Le journal V1 est secondaire : pas de graphe causal interactif, de replay graphique ni de simulations supplémentaires pour le produire. Tests documentés : [T-165-* à T-174-*](09-technical/acceptance-tests.md).

## Règles normatives Q195–Q204 — v2.1

Avant d’implémenter boutiques, tirage, achat ou récompense de carte, lire [boutiques, rotation et limites](03-progression/merchant-stock-and-deck-limits.md), puis [récompenses](03-progression/rewards-rarity-and-ascension.md) et [tours](03-progression/towers-merchants-and-unlocks.md). Quatre copies par identité dans le deck ; filtrer avant tirage et revalider au commit. Une compensation automatique Q178 s’applique si **zéro** carte est éligible ; monnaie et EXP Q179 restent acquises. RNG de run déterministe, actions idempotentes et sauvegarde des stocks/compteurs. Les 40 tests nouveaux sont **non exécutés**.

## Règles normatives v2.2 — Q205–Q214
Pour tout transfert entre deck actif et réserve, taille évolutive, recherche dans la pioche ou fatigue : lire [deck et réserve Q205–Q209](03-progression/deck-reserve-and-capacity.md) et [recherches/fatigue Q210–Q214](01-combat/deck-search-and-fatigue-v22.md). **Attention :** Q210 **remplace** les dégâts fixes de fatigue Q41 par 1,2,3… PV perdus directement ; Q207 impose quatre copies **deck+réserve** ; Q214-A impose l’affichage de **chaque exemplaire séparément**, même identique (contrairement à la suggestion non retenue de regroupement en Q213). Respecter les invariants RNG/FIFO et les tests [T-205 à T-214](09-technical/acceptance-tests.md).
