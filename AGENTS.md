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
