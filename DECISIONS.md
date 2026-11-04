# Journal des décisions Q01–Q114

Toutes les décisions ci-dessous ont été exprimées par le concepteur. Q114 est validée ; les règles non décidées restent explicitement ouvertes.

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
