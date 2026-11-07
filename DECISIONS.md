# Journal des décisions Q01–Q234

Toutes les décisions ci-dessous ont été exprimées par le concepteur. Q124 est validée ; les règles non décidées restent explicitement ouvertes.

| Question | Choix | Résumé | Fichier propriétaire |
|---|---|---|---|
| Q01 | B | Défense = soutien, protection, pas d'attaque normale | [battlefield](01-combat/battlefield.md) |
| Q02 | A | Défenseur intercepte si ligne d'attaque absente | [battlefield](01-combat/battlefield.md) |
| Q03 | A | Contester les colonnes ennemies non contestées avant déploiement libre | [summoning](01-combat/summoning.md) |
| Q04 | A | Invocation libre dans les deux lignes | [summoning](01-combat/summoning.md) |
| Q05 | C | Déplacement naturel vertical seulement ; horizontal par effet | [movement](01-combat/movement.md) |
| Q06 | B / A / A | 1 mana ; une fois par créature/tour ; possible dès l'invocation | [movement](01-combat/movement.md) |
| Q07 | B | Permutation de deux alliés d'une colonne pour 1 mana, consomme leurs déplacements | [movement](01-combat/movement.md) |
| Q08 | B | Déplacements par effets ignorent les limites naturelles ; arrivée libre sauf mention | [movement](01-combat/movement.md) |
| Q09 | A | Seul le camp actif attaque à la fin de son tour ; pas de riposte normale | [turn-sequence](01-combat/turn-sequence.md) |
| Q10 | B | Attaques colonne 1 vers 6 ; événements résolus entre colonnes | [damage-resolution](01-combat/damage-resolution.md) |
| Q11 | A + Piétinement | Dégâts résiduels perdus sauf Piétinement jusqu'au héros | [damage-resolution](01-combat/damage-resolution.md) |
| Q12 | B | Fin de l'attaque avant effets de mort | [event-queue](01-combat/event-queue.md) |
| Q13 | A | Simultanés : actif puis inactif, gauche→droite, attaque avant défense | [event-queue](01-combat/event-queue.md) |
| Q14 | A | File FIFO pour les réactions en chaîne | [event-queue](01-combat/event-queue.md) |
| Q15 | A | Mort du héros immédiate à 0 PV, arrêt du combat | [victory](01-combat/victory-and-defeat.md) |
| Q16 | B | Mort simultanée des deux héros = défaite du joueur | [victory](01-combat/victory-and-defeat.md) |
| Q17 | B + prévention | Empêcher les boucles dès la conception ; neutraliser répétitions en dernier recours | [event-queue](01-combat/event-queue.md) |
| Q18 | B | Déclenchements suite aux dégâts différés jusqu'à fin d'attaque | [event-queue](01-combat/event-queue.md) |
| Q19 | A | Effet en attente survit à la disparition de sa source | [event-queue](01-combat/event-queue.md) |
| Q20 | A + mana perdu | Cible devenue invalide : effet échoue, sans remboursement | [targeting](01-combat/targeting.md) |
| Q21 | A | Piétinement traverse uniquement une cible effectivement éliminée ; protections diminuent le résiduel | [damage-prevention](01-combat/damage-prevention.md) |
| Q22 | A | Ordre fixe : armure → bouclier → PV → protection létale | [damage-prevention](01-combat/damage-prevention.md) |
| Q23 | A | Une seule protection létale consommée par événement létal ; les autres conservées ; départage déterministe encore ouvert | [damage-prevention](01-combat/damage-prevention.md) |
| Q24 | A | Protections létales temporaires prioritaires sur permanentes | [damage-prevention](01-combat/damage-prevention.md) |
| Q25 | A | Une attaque à zéro dégât déclenche ON_ATTACK, pas les déclencheurs de perte effective de PV | [damage-resolution](01-combat/damage-resolution.md) |
| Q26 | A | Bonus PV max et PV actuels évoluent ensemble ; perte du bonus potentiellement mortelle | [damage-resolution](01-combat/damage-resolution.md) |
| Q27 | A | Dégâts de zone simultanés ; morts groupées, déclenchements différés | [damage-resolution](01-combat/damage-resolution.md) |
| Q28 | A | Le joueur commence toujours le combat | [turn-sequence](01-combat/turn-sequence.md) |
| Q29 | B | Mal d'invocation : attaque normale seulement à partir du prochain tour personnel | [turn-sequence](01-combat/turn-sequence.md) |
| Q30 | C | Mana hybride : initial, capacité actuelle et plafond | [hero-deck-mana](01-combat/hero-deck-mana.md) |
| Q31 | A/A | Restauration complète en début de tour ; mana non dépensé perdu en fin de tour | [hero-deck-mana](01-combat/hero-deck-mana.md) |
| Q32 | D + base +1 | Croissance +1 par défaut, modifiable par héros/artefacts/sorts | [hero-deck-mana](01-combat/hero-deck-mana.md) |
| Q33 | A | Bonus de croissance appliqué aux prochains tours, pas immédiatement | [hero-deck-mana](01-combat/hero-deck-mana.md) |
| Q34 | B | Bonus plafond sans gain immédiat de capacité ; gain immédiat possible au-delà capacité, limité au plafond | [hero-deck-mana](01-combat/hero-deck-mana.md) |

## Décisions nouvelles — v0.5

| Question | Choix | Décision | Document |
|---|---|---|---|
| Q35 | A | Début de tour : croissance → restauration → capacités → pioche | [document](01-combat/turn-sequence.md) |
| Q36 | A | 6 cartes initiales remplacent pioche normale du premier tour | [document](01-combat/draw-and-fatigue.md) |
| Q37 | A | Pioche normale de 1 carte par tour à partir du second tour, améliorable | [document](01-combat/draw-and-fatigue.md) |
| Q38 | A | Cartes piochées excédentaires envoyées automatiquement en défausse | [document](01-combat/hand-and-discard.md) |
| Q39 | B | Main max initiale 7, améliorable | [document](01-combat/hand-and-discard.md) |
| Q40 | B | Réduction main max : défausse des arrivées les plus récentes | [document](01-combat/hand-and-discard.md) |
| Q41 | B | Fatigue : perte directe de 1 PV par pioche impossible, ignore protections ordinaires | [document](01-combat/draw-and-fatigue.md) |
| Q42 | A | Pioche multiple séquentielle ; effets résolus entre chaque tentative | [document](01-combat/draw-and-fatigue.md) |
| Q43 | A | Aucun recyclage automatique du deck | [document](01-combat/hand-and-discard.md) |
| Q44 | A | Défausse unique conservant type, origine, raison | [document](01-combat/hand-and-discard.md) |

## Décisions nouvelles — v0.6 (Q45–Q54)

| Question | Choix | Décision | Document propriétaire |
|---|---|---|---|
| Q45 | A | Bannissement inaccessible durant le combat, sans perte permanente du deck/collection | [banishment](01-combat/banishment.md) |
| Q46 | A, précision | Résurrection à l'état de référence, blessures et bonus anciens effacés ; **nouveaux bonus possibles par la résurrection** | [resurrection](01-combat/resurrection.md) |
| Q47 | A | Résurrection soumise à la même priorité de placement qu'une invocation normale | [resurrection](01-combat/resurrection.md) |
| Q48 | A | Résurrection = nouvelle invocation ; mal d'invocation et capacités d'invocation + résurrection | [resurrection](01-combat/resurrection.md) |
| Q49 | A | Restaurer → appliquer nouveaux bonus → déclencher capacités | [resurrection](01-combat/resurrection.md) |
| Q50 | A | En file, capacités d'invocation avant capacités de résurrection | [resurrection](01-combat/resurrection.md) |
| Q51 | D | Interdire lancement sans emplacement légal ; si devenu illégal à résolution : échec sans remboursement | [resurrection](01-combat/resurrection.md) |
| Q52 | A | Résurrections multiples séquentielles, succès partiels conservés, ordre choisi au lancement | [resurrection](01-combat/resurrection.md) |
| Q53 | B | Récupération avec main pleine : carte immédiatement remise en défausse ; jamais de fatigue | [recovery](01-combat/recovery.md) |
| Q54 | A | Événements de transfert distincts selon motifs ; récupération débordante déclenche récupération puis défausse | [zone-events](01-combat/zone-events.md) |

**Mise à jour Q55 :** toutes les tentatives de résurrection terminent avant le traitement de leurs capacités : **VALIDÉ**.

## Décisions nouvelles — v0.7 (Q55–Q64)

| Question | Choix | Décision validée | Document propriétaire |
|---|---|---|---|
| Q55 | B | Finir toutes les tentatives de résurrection avant de résoudre les capacités ; chaque succès enregistre ses déclenchements dans l’ordre | [resurrection](01-combat/resurrection.md) |
| Q56 | B | Lire les caractéristiques à la résolution ; utiliser le dernier état connu de l’instance si elle a quitté le plateau | [instance-identity](01-combat/instance-identity.md) |
| Q57 | A | `cardId` persistant ; chaque arrivée sur le plateau crée un nouvel `instanceId`, distinct des vies précédentes | [instance-identity](01-combat/instance-identity.md) |
| Q58 | A | Quitter le plateau invalide définitivement le ciblage de l’ancienne instance ; retour sans reciblage | [targeting](01-combat/targeting.md) |
| Q59 | A | Conditions complètes de ciblage revérifiées à la résolution, y compris camp, ligne, colonne et type | [targeting](01-combat/targeting.md) |
| Q60 | A | Effets multicibles résolus partiellement sur chaque cible encore valide | [targeting](01-combat/targeting.md) |
| Q61 | A | Effets composés : opérations indépendantes par défaut ; conditions et indivisibilité explicites | [effect-resolution](01-combat/effect-resolution.md) |
| Q62 | B | Terminer toutes les opérations de l’effet composé avant de résoudre les capacités déclenchées, en les mettant en file au fil de l’effet | [effect-resolution](01-combat/effect-resolution.md) |
| Q63 | A | Tester victoire/défaite après commit simultané de chaque opération atomique, avant de continuer | [effect-resolution](01-combat/effect-resolution.md) |
| Q64 | A | Agréger par cible les dégâts simultanés compatibles avant application unique des protections ; séparer les composantes nécessitant des règles distinctes | [effect-resolution](01-combat/effect-resolution.md) |


## Décisions nouvelles — v0.8 (Q65–Q74)

| Question | Choix | Règle confirmée | Document |
|---|---|---|---|
| Q65 | A | `ON_DAMAGE_TAKEN` une fois par cible et opération atomique si PV réellement perdus | [Attribution](01-combat/damage-attribution.md) |
| Q66 | A | `ON_DAMAGE_DEALT` une fois par source effectivement contributrice, cible et opération | [Attribution](01-combat/damage-attribution.md) |
| Q67 | C | Attribution collective de l'éligibilité offensive après pertes de PV, indépendamment du quantum | [Attribution](01-combat/damage-attribution.md) |
| Q68 | B | Quantum attribué proportionnel, entier, somme égale aux PV perdus, zéro possible malgré déclenchement | [Attribution](01-combat/damage-attribution.md) |
| Q69 | A | Plus grands restes, égalités départagées de façon stable | [Attribution](01-combat/damage-attribution.md) |
| Q70 | A | Vol de vie différé dans FIFO, égal à la quantité attribuée, sans sauvetage rétroactif | [Attribution](01-combat/damage-attribution.md) |
| Q71 | A | Au maximum un événement d'absorption par type et cible pour chaque opération | [Attribution](01-combat/damage-attribution.md) |
| Q72 | A | Événements : armure, bouclier, perte de PV, prévention létale | [Attribution](01-combat/damage-attribution.md) |
| Q73 | A | Prévention létale : temporaire puis permanente ; expiration proche puis ancienneté puis ID | [Prévention](01-combat/damage-prevention.md) |
| Q74 | A | Réactions aux dégâts selon perte nette de PV ; prévention et capacités consommées distinctes et différées | [Attribution](01-combat/damage-attribution.md) |

## Décisions nouvelles — v0.9 (Q75–Q84)

| Question | Choix | Décision validée | Document propriétaire |
|---|---|---|---|
| Q75 | A | Soin plafonné aux PV maximum, surplus perdu sauf exception explicite | [Soins](01-combat/healing.md) |
| Q76 | A | `ON_HEAL` seulement si au moins 1 PV effectivement restauré ; valeur effective | [Soins](01-combat/healing.md) |
| Q77 | A | Soins simultanés regroupés par cible ; unique `ON_HEAL` ; attribution aux sources par plus grands restes | [Soins](01-combat/healing.md) |
| Q78 | A | Variations de PV max/current ne sont ni des soins ni des dégâts ; aucun déclencheur associé | [Effets temporaires](01-combat/temporary-effects.md) |
| Q79 | A | Mort par retrait de bonus : protections létales générales applicables ; `ON_DEATH` ou `ON_LETHAL_PREVENTED` | [Effets temporaires](01-combat/temporary-effects.md) |
| Q80 | A | Tous les effets expirant au même instant retirés atomiquement ; protections sur le résultat global | [Effets temporaires](01-combat/temporary-effects.md) |
| Q81 | A | Durée en tours personnels du camp ayant appliqué l'effet ; « fin du tour » = tour courant | [Effets temporaires](01-combat/temporary-effects.md) |
| Q82 | A | Début : expiration avant mana ; fin : après attaques et réactions, avant changement de camp | [Effets temporaires](01-combat/temporary-effects.md) |
| Q83 | A | Effet pendant tour adverse : prochain tour personnel = tour 1 ; propre tour en cours = tour 1 | [Effets temporaires](01-combat/temporary-effects.md) |
| Q84 | A | Un `ON_EFFECT_EXPIRED` par effet expiré après retrait atomique ; ordre déterministe | [Effets temporaires](01-combat/temporary-effects.md) |

| Q85 | A | Mort ou prévention avant événements individuels d’expiration, pour chaque cible | [Sources et contrôle](01-combat/source-control.md) |
| Q86 | A | Capacités pré-expiration d’une créature mourant dans la même opération éligibles | [Sources et contrôle](01-combat/source-control.md) |
| Q87 | A | Capacité accordée temporairement pouvant déclencher sur sa propre expiration | [Sources et contrôle](01-combat/source-control.md) |
| Q88 | A | Source de gameplay de capacité accordée = créature porteuse ; origine historique conservée | [Sources et contrôle](01-combat/source-control.md) |
| Q89 | A | Capacité différée conserve dernier état connu de l’instance disparue, vol de vie inclus | [Sources et contrôle](01-combat/source-control.md) |
| Q90 | A | Caractéristiques lues à la résolution ou dans dernier état connu si source absente | [Sources et contrôle](01-combat/source-control.md) |
| Q91 | A | Vol de vie vérifié lors des dégâts ; état figé dans ON_DAMAGE_DEALT | [Sources et contrôle](01-combat/source-control.md) |
| Q92 | A | Vol de vie bénéficie au contrôleur lors des dégâts, remplace destinataire propriétaire Q70 | [Sources et contrôle](01-combat/source-control.md) |
| Q93 | A | Cibles/références de camp fixées au déclenchement ; bénéfices selon contrôleur aux dégâts | [Sources et contrôle](01-combat/source-control.md) |
| Q94 | A | Prise de contrôle conserve instanceId, cardId, états et capacités ; change controllerId | [Sources et contrôle](01-combat/source-control.md) |

## Décisions nouvelles — v1.1 (Q95–Q104)

| Question | Option | Décision validée | Document propriétaire |
|---|---|---|---|
| Q95 | E personnalisée | Placement choisi par nouveau contrôleur selon toutes les règles ordinaires d’invocation. | [Transferts et contrôle](01-combat/control-transfers.md) |
| Q96 | A | Sans case au lancement : action illégale ; devenue impossible à la résolution : échec sans remboursement. | [Transferts et contrôle](01-combat/control-transfers.md) |
| Q97 | A | Retour obligatoire au camp précédent ; si aucune case légale : mort de placement et défausse du propriétaire. | [Transferts et contrôle](01-combat/control-transfers.md) |
| Q98 | A | Protection létale ordinaire inapplicable à une mort de placement ; ON_DEATH sans dégâts. | [Transferts et contrôle](01-combat/control-transfers.md) |
| Q99 | A | Contrôles superposés indépendants ; le plus récent encore actif détermine le contrôleur. | [Transferts et contrôle](01-combat/control-transfers.md) |
| Q100 | A | Expirations simultanées : recalcul global et au plus un transfert, aucun mouvement si contrôleur final identique. | [Transferts et contrôle](01-combat/control-transfers.md) |
| Q101 | A | Retours concurrents : camp de destination choisit les unités accueillies et leurs emplacements. | [Transferts et contrôle](01-combat/control-transfers.md) |
| Q102 | A | Transferts croisés : les cases libérées par les départs simultanés servent aux arrivées. | [Transferts et contrôle](01-combat/control-transfers.md) |
| Q103 | A | Camp actif choisit les placements en premier, puis camp adverse informé ; commit atomique. | [Transferts et contrôle](01-combat/control-transfers.md) |
| Q104 | A | ON_CONTROL_CHANGED une fois par changement effectif réussi ; ordre mort/prévention → contrôle → expiration. | [Transferts et contrôle](01-combat/control-transfers.md) |

## Consolidation v1.2 — décisions VALIDÉES Q105 à Q114

| Question | Choix | Résumé | Fichier propriétaire |
|---|---|---|---|
| Q105 | A | Mal d’invocation sur prise de contrôle effective, sans ON_SUMMON ; exception explicite possible. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |
| Q106 | A | Premier tour personnel du nouveau contrôleur bloqué, même transfert hors tour et retour. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |
| Q107 | A | Capacités ON_TURN_START/ON_TURN_END selon le contrôleur au déclenchement, sans rétroactivité. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |
| Q108 | A | Attaques + réactions → ON_TURN_END complet → expirations atomiques + réactions → changement de camp. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |
| Q109 | A | Échéances strictes, pas de durée minimale ; prolongation même effectInstanceId, sans expiration. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |
| Q110 | A | Effet créé après échéance expire après opération atomique ; réaction ajoutée en fin de FIFO. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |
| Q111 | A | Cycle non progressif : interruption ciblée du prochain déclenchement répétitif ; garde-fou indépendant. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |
| Q112 | A | Détection par signature fonctionnelle du combat et FIFO ordonnée, identifiants neutres normalisés. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |
| Q113 | A | Budget configurable par chaîne, interruption de branche ; exemple 1 000 non définitif. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |
| Q114 | A | Conserver tous les événements déjà en FIFO ; empêcher seulement nouveaux descendants branche bloquée. | [Capacités de tour et boucles](01-combat/turn-control-and-loop-safety.md) |


## Consolidation v1.3 — décisions Q115 à Q124

| Question | Choix | Résumé | Fichier propriétaire |
|---|---|---|---|
| Q115 | A | Résolution multicausale unique ; causes et branches préservées ; branche bloquée non réactivable. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |
| Q116 | A | Triple plafond configurable et versionné : branche, chaîne globale, opération initiale. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |
| Q117 | A | Une unité par branche contributrice active, une seule unité par chaîne et opération. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |
| Q118 | A | Réservation atomique à l’admission FIFO ; capacités admises garanties ; pas de dépassement. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |
| Q119 | A | Réservations multicausales immuables ; libération atomique à l’annulation ; blocage de branche permanent. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |
| Q120 | A | Déclenchement refusé définitivement ; crédits libérés réservés aux admissions futures. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |
| Q121 | A | Journal déterministe complet + instantanés périodiques ; états, causes, budgets, RNG et choix traçables. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |
| Q122 | A | Empreinte canonique après chaque commit atomique ; arrêt et diagnostic à première divergence. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |
| Q123 | A | Sauvegarde entre commits atomiques, FIFO non vide admise ; restauration sans double exécution. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |
| Q124 | A | Versions de règles/cartes/PRNG/budgets figées par combat ; incompatibilité explicite si dépendance manquante ; RPG migrable entre combats. | [Budgets causaux et rejeu](09-technical/causal-budgets-and-replay.md) |

**Q125 validée** : voir le lot v1.4 ci-dessous.


## Consolidation v1.4 — décisions Q125 à Q134

| Question | Choix | Résumé | Document propriétaire |
|---|---|---|---|
| Q125 | A | Moteurs/règles historiques archivés et chargés à la demande tant que sauvegardes/replays restent officiellement pris en charge. | [Spécification](09-technical/causal-budgets-and-replay.md) |
| Q126 | Hearthstone / Magic | Fantasy illustrée riche et colorée, identité originale et forte lisibilité des cartes. | [Spécification](02-art-direction/card-and-board-ui.md) |
| Q127 | D personnalisée | Carte premium riche dans la main/inspection ; jeton compact portrait sur plateau ; tooltip et clic pour détails. | [Spécification](02-art-direction/card-and-board-ui.md) |
| Q128 | D | Jeton adaptatif avec portrait, ATQ et PV toujours visibles, états tactiques importants uniquement. | [Spécification](02-art-direction/card-and-board-ui.md) |
| Q129 | D | Médaillon circulaire/ovale à socle tactique, camp reconnaissable. | [Spécification](02-art-direction/card-and-board-ui.md) |
| Q130 | A | ATQ en bas à gauche, PV en bas à droite, états sous le portrait. | [Spécification](02-art-direction/card-and-board-ui.md) |
| Q131 | A | Valeurs numériques et couleurs avec symboles ; armure et bouclier distincts, PV actuels sur jeton. | [Spécification](02-art-direction/card-and-board-ui.md) |
| Q132 | A personnalisée | Maximum 3 icônes prioritaires et +N ; clic ouvre carte complète avec tous bonus/malus. | [Spécification](02-art-direction/card-and-board-ui.md) |
| Q133 | A personnalisée | Inspection de la carte d’origine inchangée, panneau latéral séparé pour modifications. | [Spécification](02-art-direction/card-and-board-ui.md) |
| Q134 | B personnalisée | Panneau exhaustif avec ATQ finale et PV/défense effective clairement visibles, protections et calcul des effets. | [Spécification](02-art-direction/card-and-board-ui.md) |

**Q135 validée** : voir lot v1.5 ci-dessous.


## Consolidation v1.5 — Q135 à Q144

| Question | Choix | Décision | Module propriétaire |
|---|---|---|---|
| Q135 | A | ATQ/PV effectifs codés par couleur et flèche ; blessure différente de réduction de PV max. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |
| Q136 | C | Tooltip tactique condensé : stats finales, tous effets, protections et échéances ; clic pour sources/texte détaillés. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |
| Q137 | A | Ordre fixe par catégorie, ancienneté dans la catégorie ; une ligne et une durée par effectInstanceId, aucune fusion. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |
| Q138 | A | Échéances naturelles explicites, temporaires/permanentes/conditionnelles ; calendrier du créateur. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |
| Q139 | Personnalisée | Symbole de prise de contrôle parmi états prioritaires ; durée des autres effets inchangée, propriétaire conservé. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |
| Q140 | B + principe global | Changement de durée signalé par bref feedback ; chaque action/effet donne un retour expressif et lisible. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |
| Q141 | C | Animations juicy hiérarchisées, rythme adaptatif, accessibilité, spectacle proportionné sans ralentissement. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |
| Q142 | C | Orchestrateur de VFX indépendant, regroupement/accélération/superposition sans changer FIFO et résultats. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |
| Q143 | A + précision | Nombres flottants dégâts/soins et protections distincts ; effets puissants : éclairs, halos, secousses. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |
| Q144 | B | Objectif indicatif global de 3–5 s pour chaîne complexe, avec rythme adaptatif et moments décisifs préservés. | [UI/VFX](02-art-direction/tooltips-durations-and-vfx.md) |




## Consolidation v1.6 — Décisions Q145–Q154

| Question | Choix | Décision | Fichier propriétaire |
|---|---|---|---|
| Q145 | B + précision | Plateau fantasy premium, grille subtile ; V1 un seul décor riche, architecture prévue pour variantes futures par étape/tour/biome/boss. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |
| Q146 | B | Illustration principalement fixe, quelques animations d'ambiance discrètes, réductibles ; priorité au gameplay. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |
| Q147 | B personnalisé | Camps distingués subtilement ; épée/bouclier et marquages contextuels seulement au survol, focus ou drag-and-drop, pas de surcharge permanente. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |
| Q148 | B | Cases valides révélées ; interdites neutres sauf tentative ciblée avec retour et explication. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |
| Q149 | C | Sélection créature → simulation des conséquences pertinentes de la prochaine phase de combat plutôt que simple cible/trajectoire. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |
| Q150 | B | PV futurs temporaires `actuel → prévu`, crâne/protections/`?` contextuels ; détail en inspection. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |
| Q151 | C | Prévisions mises à jour sur case valide durant drag-and-drop, cache lié à l'état, calcul non bloquant. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |
| Q152 | C | Résultats certains, incertains, en calcul, indisponibles explicites ; budget de prévision indépendant, non bloquant. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |
| Q153 | B | Dépôt immédiat sans confirmation, revalidation moteur, animation si succès, retour visuel si refus. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |
| Q154 | C | Drag-and-drop, clic-clic et tactile cohérents ; prévisions accessibles sans hover ; annulation sans effet tant qu'aucune validation n'a eu lieu. | [Plateau / prévisions](02-art-direction/board-and-tactical-preview.md) |

**Q155–Q164 validées en v1.7. Q165 ouverte.**


## Consolidation v1.7 — Décisions Q155–Q164

| Question | Choix | Décision | Fichier propriétaire |
|---|---|---|---|
| Q155 | C | Prévisualisation des sorts/capacités ciblés via moteur commun isolé, sans fuite d’information cachée. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |
| Q156 | B + précision | Même langage visuel pour une ou plusieurs cibles ; informations individuelles conservées, zone discrète. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |
| Q157 | A + précision | Sur plateau, valeurs finales prévues pour buffs/debuffs ; avant/après dans inspection. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |
| Q158 | A | Conditions futures expliquées en inspection, pas ajoutées aux caractéristiques immédiates du plateau. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |
| Q159 | B | Aura discrète au repos ; sélection de source révèle les bénéficiaires. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |
| Q160 | B | Cascades d'auras : état final immédiatement prévisible de chaque créature, détails au clic. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |
| Q161 | B | Graphe de dépendances, ordre stable, détection des cycles et solveur commun combat/preview. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |
| Q162 | B | Cycles ambigus / insolubles : neutralisation ciblée, temporaire, traçable des dépendances problématiques. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |
| Q163 | B | Priorités sémantiques, contraintes fondamentales préservées, neutralisation minimale, départage canonique stable. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |
| Q164 | B | Cohérence recalculée aux frontières atomiques nécessaires ; rendu VFX peut regrouper sans changer la logique. | [Sorts et auras](02-art-direction/spells-auras-and-continuous-effects.md) |

**Q165 ouverte.** Les paramètres numériques, l’algorithme exact de départage canonique et les noms d’API ne sont pas encore validés.


## Décisions validées Q165–Q174 — v1.8

| Question | Choix | Résumé | Fichier propriétaire |
|---|---|---|---|
| Q165 | B | Feedback temporaire lors de la neutralisation ou réactivation d’une aura. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |
| Q166 | B + précision | Journal hiérarchique, masqué par défaut, consultable à la demande. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |
| Q167 | B | Panneau latéral escamotable pour le journal. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |
| Q168 | B | Survol/sélection d’un événement : mise en évidence contextuelle des créatures. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |
| Q169 | B | Résumé compact des créatures et inspection historique détaillée à la demande. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |
| Q170 | B | Historique par tour, recherche textuelle et filtres légers. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |
| Q171 | B | Résumé tactique et détail exhaustif à la demande. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |
| Q172 | A + contrainte de coût | Explications textuelles, sans navigation causale avancée en V1. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |
| Q173 | B | Conservation de l’historique complet du combat en cours. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |
| Q174 | B | Journal consultable pendant les animations sans pause ni fuite anticipée. | [Journal et inspection](02-art-direction/combat-journal-and-inspection.md) |

**Q175–Q184 validées en v1.9.** Le journal V1 reste volontairement léger et non central.


## Décisions validées Q175–Q184 — v1.9

| Question | Choix | Résumé | Fichier propriétaire |
|---|---|---|---|
| Q175 | B | Victoire expressive graduée : rapide en combat courant, plus spectaculaire contre boss ; VFX sans impact moteur. | [Progression](03-progression/rewards-rarity-and-ascension.md) |
| Q176 | B | Écran de récompenses fantasy dédié ; inspection, choix distingués des gains automatiques, animations brèves. | [Progression](03-progression/rewards-rarity-and-ascension.md) |
| Q177 | B | Trois cartes éligibles proposées ; inspection puis choix d’une seule ou alternative Q178. | [Progression](03-progression/rewards-rarity-and-ascension.md) |
| Q178 | C | Refuser les trois cartes contre compensation en ressources visible avant confirmation. | [Progression](03-progression/rewards-rarity-and-ascension.md) |
| Q179 | B | Gains automatiques après chaque victoire : monnaie et EXP du héros. | [Progression](03-progression/rewards-rarity-and-ascension.md) |
| Q180 | C | Boss : gains renforcés + choix exceptionnel entre carte, artefact ou amélioration du héros. | [Progression](03-progression/rewards-rarity-and-ascension.md) |
| Q181 | C modifiée | Cinq rangs SANS mythique : Commun blanc, Peu commun bleu, Rare rouge, Épique violet, Légendaire or. | [Progression](03-progression/rewards-rarity-and-ascension.md) |
| Q182 | B + précision | Artefacts conservés pendant l’ascension ; finir la tour peut débloquer cartes et artefacts draftables lors des suivantes. | [Progression](03-progression/rewards-rarity-and-ascension.md) |
| Q183 | C | Nombre limité d’emplacements d’artefacts, capacité augmentable pendant une ascension, réinitialisée ensuite. | [Progression](03-progression/rewards-rarity-and-ascension.md) |
| Q184 | C | Améliorations temporaires du héros : caractéristiques ou capacités, au choix parmi propositions éligibles. | [Progression](03-progression/rewards-rarity-and-ascension.md) |

**Q185 ouverte :** usage de l’EXP, niveaux du héros et acquisition d’améliorations. Aucun seuil ni mode de persistance de l’EXP n’est encore fixé.


## Décisions validées Q185–Q194 — v2.0

| Question | Choix | Résumé | Fichier propriétaire |
|---|---|---|---|
| Q185 | B profondément personnalisée | Sphérier permanent de compétences/caractéristiques (PV, feu, etc.), conservé entre ascensions ; remplace le modèle simple de trois choix par niveau. | [Sphérier](03-progression/hero-sphere-and-skill-tree.md) |
| Q186 | B | EXP permanente, niveau permanent, points acquis à chaque niveau et conservés. | [Sphérier](03-progression/hero-sphere-and-skill-tree.md) |
| Q187 | C | Branches interconnectées, progression de proche en proche, passerelles et prérequis. | [Sphérier](03-progression/hero-sphere-and-skill-tree.md) |
| Q188 | C | Coût variable de chaque nœud selon sa valeur, avec respect des prérequis. | [Sphérier](03-progression/hero-sphere-and-skill-tree.md) |
| Q189 | B | Réinitialisation intégrale gratuite du sphérier uniquement hors ascension ; points restitués, niveau/EXP préservés. | [Sphérier](03-progression/hero-sphere-and-skill-tree.md) |
| Q190 | D personnalisée | Plusieurs tours ouvertes d’emblée ; quelques tours spéciales conditionnées par l’achèvement d’autres tours ; pas de niveau minimum imposé. | [Tours et boutiques](03-progression/towers-merchants-and-unlocks.md) |
| Q191 | B | Première victoire : déblocages permanents uniques ; victoires suivantes : récompenses répétables. | [Tours et boutiques](03-progression/towers-merchants-and-unlocks.md) |
| Q192 | A personnalisée | Difficulté des tours fixe ; les récompenses répétables de tours faciles perdent de l’intérêt à haut niveau. | [Tours et boutiques](03-progression/towers-merchants-and-unlocks.md) |
| Q193 | D personnalisée | Déblocages par succès, défis et combats, plus achats chez les marchands présents dans les tours ; certaines cartes exclusives à des marchands de tours données. | [Tours et boutiques](03-progression/towers-merchants-and-unlocks.md) |
| Q194 | Règle personnalisée | **Toute carte effectivement obtenue ou achetée est ajoutée définitivement au pool potentiel de draft futur** ; la copie de tentative disparaît en fin d’ascension ; ne pas confondre vu/acheté, ni déblocage/obtention garantie. | [Tours et boutiques](03-progression/towers-merchants-and-unlocks.md) |

**Q195 ouverte :** structure des inventaires des commerces (fixes, variables ou mixtes) et garantie d’accès aux exclusivités.


## Décisions validées Q195–Q204 — v2.1

| Question | Choix | Résumé | Fichier propriétaire |
|---|---|---|---|
| Q195 | C personnalisée | Inventaire marchand aléatoire ; certains sorts/cartes uniquement dans les pools de commerces de tours précises, jamais garantis. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |
| Q196 | B | Prix de référence par rareté et ajustements par carte, stables et affichés. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |
| Q197 | A | Monnaie temporaire perdue à la fin de chaque ascension, progression permanente conservée. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |
| Q198 | B personnalisée | Renouvellements payants sans plafond fixe ; chaque renouvellement successif coûte davantage. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |
| Q199 | A | Compteur de renouvellement indépendant par instance de marchand, persistant jusqu’à fin du run. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |
| Q200 | B | Un exemplaire par offre ; achat vide la place ; même carte peut réapparaître après renouvellement. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |
| Q201 | B personnalisée | Quatre exemplaires identiques maximum dans le deck, toutes raretés ; aucune rareté mythique. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |
| Q202 | B | Cartes déjà à quatre copies exclues du pool des boutiques, avec revalidation à l’achat. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |
| Q203 | B | Cartes déjà à quatre copies exclues des récompenses ; moins de trois offres si pool insuffisant. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |
| Q204 | B | Pool de récompenses vide : compensation en ressources Q178 automatique, sans écran de choix ; EXP et monnaie Q179 préservées. | [Boutiques et limites de deck](03-progression/merchant-stock-and-deck-limits.md) |

**Q205 ouverte :** prochaine décision de conception. Les quantités et pourcentages illustratifs ne sont pas adoptés.

## Décisions validées Q205–Q214 — consolidation v2.2

| Question | Choix | Règle validée | Module normatif |
|---|---|---|---|
| Q205 | Personnalisée | Retirer une carte du deck actif = transfert réversible vers la réserve d’ascension, pas destruction ni perte du déblocage permanent. | [Deck et réserve](03-progression/deck-reserve-and-capacity.md) |
| Q206 | B | Réorganisation libre et gratuite du deck actif/réserve entre combats ; verrouillage pendant le combat. | [Deck et réserve](03-progression/deck-reserve-and-capacity.md) |
| Q207 | A | Quatre copies identiques possédées **deck actif + réserve réunis**, toutes raretés ; filtres marchands et récompenses en tiennent compte. | [Deck et réserve](03-progression/deck-reserve-and-capacity.md) |
| Q208 | Personnalisée | Minimum et maximum de deck évolutifs ; base initiale **40/40**, deck compact plus sensible à la fatigue ; grand deck soutenu par recherche. | [Deck et réserve](03-progression/deck-reserve-and-capacity.md) |
| Q209 | C | Limites de deck modifiables par sphérier permanent et effets temporaires de run cumulables, dans bornes à équilibrer. | [Deck et réserve](03-progression/deck-reserve-and-capacity.md) |
| Q210 | B | Fatigue progressive **1/2/3… PV perdus directement** sur pioches impossibles, par héros et combat ; **remplace montant fixe Q41**, sans recyclage Q43. | [Fatigue et recherche](01-combat/deck-search-and-fatigue-v22.md) |
| Q211 | C | Recherches ciblées ou aléatoires selon le texte du sort, critères explicites, RNG déterministe. | [Fatigue et recherche](01-combat/deck-search-and-fatigue-v22.md) |
| Q212 | C | Destination et mélange définis par l’effet ; aucune fatigue sur recherche sans résultat, autres instructions indépendantes préservées. | [Fatigue et recherche](01-combat/deck-search-and-fatigue-v22.md) |
| Q213 | B | Recherche ciblée : seules instances éligibles inspectables, pas d’ordre de pioche ; recherche aléatoire sans sélecteur. | [Fatigue et recherche](01-combat/deck-search-and-fatigue-v22.md) |
| Q214 | **A** | Chaque copie éligible affichée **séparément**, même strictement identique, sélection explicite d’une instance ; **aucun regroupement**. | [Fatigue et recherche](01-combat/deck-search-and-fatigue-v22.md) |

**Q215 ouverte :** prochaine question à arbitrer ; ne pas supposer de règle définitive non validée.

## Décisions validées Q215–Q224 — consolidation v2.3

| Question | Choix | Règle validée | Module normatif |
|---|---|---|---|
| Q215 | D adaptée | 20 cartes de base + 2 boosters de 15 cartes débloquées ; 50 exemplaires initiaux pour deck standard 40 et réserve 10 ; pas de construction libre depuis la collection. | [Préparation](03-progression/ascension-start-boosters-and-autobuild.md) |
| Q216 | C | Composition automatique immédiatement jouable, avec changements manuels facultatifs. | [Préparation](03-progression/ascension-start-boosters-and-autobuild.md) |
| Q217 | A | Confirmer la taille de base 40/40 (Q208), avec capacité évolutive Q209. | [Deck et réserve](03-progression/deck-reserve-and-capacity.md) |
| Q218 | B adaptée | Probabilités pondérées par rareté ; compétences du sphérier pouvant accorder des garanties par booster. | [Préparation](03-progression/ascension-start-boosters-and-autobuild.md) |
| Q219 | B | Garanties satisfaites si possible, sinon assouplies sans carte verrouillée ni cinquième copie ; mécanisme exact de secours structurel encore ouvert. | [Préparation](03-progression/ascension-start-boosters-and-autobuild.md) |
| Q220 | **B** | Ouverture **successive** des deux boosters, 15 cartes révélées d’un coup par booster, animations passables. | [Préparation](03-progression/ascension-start-boosters-and-autobuild.md) |
| Q221 | B | Affichage compact, couleurs de rareté et indices de synergie, inspection et filtres facultatifs, transferts rapides. | [Préparation](03-progression/ascension-start-boosters-and-autobuild.md) |
| Q222 | **B** | L'assistant privilégie **la spécialisation du sphérier**, autres critères secondaires, sans privilégier la rareté. | [Préparation](03-progression/ascension-start-boosters-and-autobuild.md) |
| Q223 | C | Toutes les cartes de base peuvent être placées en réserve et remplacées dans le deck actif. | [Préparation](03-progression/ascension-start-boosters-and-autobuild.md) |
| Q224 | **D** | Socle initial fixe de 20 cartes ; des compétences permanentes débloquent progressivement des remplacements par variantes spécialisées ou plus fortes. | [Préparation](03-progression/ascension-start-boosters-and-autobuild.md) |

**Q225–Q234 :** décisions validées et détaillées ci-dessous ; les probabilités et quotas numériques non validés restent ouverts.

## Décisions validées Q225–Q234 — consolidation v2.4

| Question | Choix | Décision | Source normative |
|---|---|---|---|
| Q225 | B | Catalogue fondamental débloqué au départ ; secours déterministe à partir des cartes éligibles, sans carte verrouillée ni dépassement du plafond. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |
| Q226 | Personnalisée / A adaptée | Variantes du sphérier remplacent de façon déterministe les versions précédentes du socle de 20 exemplaires. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |
| Q227 | B | Variantes d'une même famille ; plafond de quatre copies **toutes versions confondues**. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |
| Q228 | A | Amélioration du sphérier limitée aux exemplaires d'origine socle, non appliquée aux acquisitions ordinaires. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |
| Q229 | Précision personnalisée | Variantes du sphérier exclues des boosters ; réservées aux cartes d'origine socle. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |
| Q230 | B puis révision personnalisée | Objectif MVP élargi de 100 à **≈170 définitions** : **40 fondamentales + ≈30 variantes (≈10 familles × 3) + 100 indépendantes**. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |
| Q231 | C adaptée | Catalogue indépendant hybride : neutre/polyvalent, élémentaire, hybride/avancé ; hypothèse 33/50/17 non contraignante. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |
| Q232 | C | Répartition équilibrée selon rôles tactiques, quotas **indicatifs** et cartes multirôles possibles. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |
| Q233 | C enrichie | Spécialisations élémentaires fortes et archétypes transversaux, intégrant peuples/types de créatures Heroic Fantasy. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |
| Q234 | Personnalisée | **Quatre peuples** représentés au MVP ; moteur extensible pour Gobelins, Morts-vivants et autres. Les quatre peuples exacts restent ouverts. | [Catalogue MVP](03-progression/mvp-card-catalog-and-tribes.md) |

**Q235 ouverte.** Prochain arbitrage : nommer les quatre peuples MVP (ou arbitrer leur sélection), sans confondre peuples et archétypes/éléments.
