# Tests d'acceptation du moteur de combat

> Scénarios à transformer en tests unitaires ; les cas dépendant de règles ouvertes sont marqués **À CONFIRMER**.

| ID | Règles | État initial et action | Résultat attendu |
|---|---|---|---|
| TEST-001 | BTL-003/004 | Attaquant C1, ennemi seulement en défense C1 | Défenseur ciblé |
| TEST-002 | SUM-003 | Ennemis C2/C5, aucun allié ; tenter invocation C4 | Interdite |
| TEST-003 | SUM-004 | Ennemis C2/C5, alliés C2/C5 ; invocation C4 libre | Autorisée si emplacement libre |
| TEST-004 | MOV-002/003 | Déplacer une créature verticalement deux fois dans le même tour | Premier possible pour 1 mana ; second interdit naturellement |
| TEST-005 | MOV-006/007 | Permuter deux alliés n'ayant pas bougé | Possible pour 1 mana ; deux droits consommés |
| TEST-006 | MOV-008/009 | Sort déplace créature après son mouvement naturel | Mouvement par effet encore possible |
| TEST-007 | DMG-003 | 8 ATQ sans Piétinement contre créature 2 PV | Créature détruite, 6 dégâts perdus |
| TEST-008 | DMG-004 | 8 ATQ avec Piétinement contre 3 PV ATQ + 2 PV DEF | 3 dégâts au héros sans protections |
| TEST-009 | EVT-003/004 | Deux effets simultanés des deux camps, puis réaction nouvelle | Actif avant inactif, ordre spatial ; réaction en fin de file |
| TEST-010 | EVT-005 | Source détruite alors que capacité en file | Capacité conservée |
| TEST-011 | TGT-002/004 | Cible détruite avant résolution d'un sort payé | Effet ciblé échoue, mana non remboursé |
| TEST-012 | VIC-003 | Deux héros à 3 PV ; effet simultané 5 dégâts chacun | Défaite joueur |
| TEST-013 | VIC-004 | Piétinement létal au héros avec effets de mort en attente | Combat terminé sans jouer la file |
| TEST-014 | PREV-002 | Piétinement contre créature survivant grâce à protection létale | Propagation stoppée |
| TEST-015 | PREV-005/006 | Armure 2, bouclier 3, PV 4, attaque 10 | Le moteur traite dans cet ordre : armure, bouclier, impact sur PV, puis protection létale si nécessaire ; issue finale de la protection à confirmer |
| TEST-016 | PREV-005/006 | PV 4, armure 2, bouclier 3 ; 7 dégâts entrants, aucune protection létale | 2 dégâts sur PV ; PV restants 2 ; bouclier consomme 3 |

| TEST-017 | PREV-007/008 | Deux protections létales valides ; un événement létal ; aucune autre protection | Exactement une protection consommée, la seconde conservée ; priorité temporaire avant permanente (Q24) ; départage dans la même classe à confirmer |
| TEST-018 | PREV-007/008 | Une protection a déjà été consommée lors d'un premier événement létal ; nouvel événement létal ultérieur | La protection restante peut être utilisée sur le second événement si ses conditions sont réunies ; détails de retour à 1 PV **À CONFIRMER** |

## Risques nécessitant spécification
- Cibles multiples et ciblage dynamique ; cas où aucune colonne non contestée n'a de place ; ripostes spéciales ; événements identiques ; cycle infini ; effets létaux simultanés et prévention.

## Tests ajoutés après Q34
| Test | Décision | Entrée | Résultat attendu |
|---|---|---|---|
| TEST-019 | Q35 | Début de tour | Croissance puis restauration, capacités puis pioche |
| TEST-020 | Q36 | Premier tour, deck 20 | Main 6 ; aucune pioche normale additionnelle |
| TEST-021 | Q37 | Deuxième tour, sans bonus | Une carte piochée |
| TEST-022 | Q38 | Main 7/7 et deck 1, pioche 1 | Carte va en défausse et deck −1 ; pas de fatigue |
| TEST-023 | Q39 | Héros débutant | Main maximum 7 |
| TEST-024 | Q40 | Main A–G dans ordre d'arrivée, maximum passe de 7 à 5 | G puis F défaussées |
| TEST-025 | Q41 | Deck vide, héros 2 PV, 2 tentatives | Perte directe 1 PV puis 1 PV ; défaite, bouclier ignoré |
| TEST-026 | Q42 | Deck 1, piocher 3 | Pioche 1 ; résoudre effets ; fatigue 1 ; résoudre effets ; fatigue 1 |
| TEST-027 | Q43 | Deck vide, défausse non vide, tentative pioche | Aucune réintégration automatique ; fatigue |
| TEST-028 | Q44 | Sort joué, créature détruite, carte défaussée | Même défausse, métadonnées de raison et origine distinctes |

## Tests ajoutés en v0.6 — décisions Q45–Q54

| Test | Décisions | Situation | Résultat attendu |
|---|---|---|---|
| TEST-029 | Q45 | Carte bannie ; tenter récupération/recyclage/résurrection ordinaire pendant combat | Carte inaccessible ; reste bannie |
| TEST-030 | Q45 | Terminer le combat avec carte de deck bannie | Carte préservée pour futurs combats ; non supprimée de la collection |
| TEST-031 | Q46 | Créature de base 3/4 morte avec bonus provisoire +2 ATQ ; résurrection +1 ATQ, +2 PV max | Revient 4 ATQ / 6 PV max et actuels, sans bonus ancien |
| TEST-032 | Q47 | Ennemi en C2 non contestée, case C2 légale, sort ressuscite en C4 | Placement C4 interdit ; résurrection C2 admissible |
| TEST-033 | Q48 | Créature avec `ON_SUMMON` et `ON_RESURRECT`, ressuscitée pendant son tour | Deux déclenchements ; elle ne peut attaquer normalement ce tour |
| TEST-034 | Q49 | Base 3 ATQ, résurrection +2 ATQ, capacité `ON_SUMMON` dépendant d'ATQ | 5 ATQ déjà appliqués au déclenchement ; valeur lue à la résolution selon Q56 ; dernier état connu si la source a quitté le plateau |
| TEST-035 | Q50 | File contient événement X ; résurrection déclenche S et R | Ordre de file X, S (`ON_SUMMON`), R (`ON_RESURRECT`) |
| TEST-036 | Q51 | Toutes cases occupées avant lancer sort de résurrection | Lancement interdit ; aucun mana dépensé |
| TEST-037 | Q51 | Sort légal au lancement ; case devient indisponible avant résolution | Tentative échoue, mana déjà dépensé non remboursé, aucun `ON_SUMMON` / `ON_RESURRECT` |
| TEST-038 | Q51 | Créature ciblée quitte défausse avant résolution | Pas de reciblage, effet ciblé échoue, mana non remboursé |
| TEST-039 | Q52 | 3 créatures choisies dans ordre A-B-C, seulement deux placements possibles successifs | A et B placées ; C reste en défausse ; aucun rollback des placements réussis |
| TEST-040 | Q53–Q54 | Main 7/7, récupérer 1 carte depuis défausse | Carte revient en défausse, aucune fatigue ; produire récupération puis défausse FIFO |
| TEST-041 | Q54 | Sort joué puis rejoint défausse | `ON_SPELL_USED`, pas `ON_DISCARD` |
| TEST-042 | Q54 | Créature meurt puis rejoint défausse | `ON_DEATH`, pas `ON_DISCARD` simplement à cause du changement de zone |
| TEST-043 | Q54 | Pioche carte au-delà du maximum de main | Carte va en défausse, `ON_DISCARD` généré ; aucun effet de fatigue si deck contient carte |
| TEST-044 | Q54 | Défausser une carte depuis main | `ON_DISCARD`, non `ON_SPELL_USED` |
| TEST-045 | Q54 | Recycler défausse→deck, puis bannir autre carte | `ON_CARD_RECYCLED`, puis `ON_CARD_BANISHED`, avec métadonnées distinctes |

**VALIDÉ Q55 (TEST-046)** : les capacités déclenchées par les résurrections attendent la fin du sort. Voir [resurrection](../01-combat/resurrection.md).

## Tests v0.7 — décisions Q55–Q64

| ID | Décision | État / action | Attendu |
|---|---|---|---|
| TEST-046 | Q55 | Sort ressuscite A, B, C ; A a `ON_SUMMON` qui détruit B | Toutes les tentatives sont terminées avant résolution des `ON_SUMMON` ; la destruction ne change pas les places pendant le sort |
| TEST-047 | Q56 | Créature ATQ 5 déclenche dégâts=ATQ ; ATQ tombe à 2 avant résolution sans quitter le plateau | La capacité inflige 2 dégâts avant protections |
| TEST-048 | Q56 | Source ATQ 5 puis subit −2 ATQ puis meurt avant sa capacité | La capacité utilise dernier état connu 3 ATQ |
| TEST-049 | Q57 | Carte `cardId=C1` meurt en instance I1, puis ressuscite | Nouvel `instanceId=I2` ; `cardId=C1` conservé ; bonus anciens effacés |
| TEST-050 | Q57 | I1 déclenche dégâts=ATQ 5, meurt, revient en I2 avec ATQ 3 | Capacité ancienne = 5, aucune lecture des stats I2 |
| TEST-051 | Q58 | Sort cible I1 ; I1 meurt ; `cardId` revient comme I2 | Cible invalide ; pas de dégâts sur I2, pas de remboursement |
| TEST-052 | Q59 | Sort « cible ennemie » ; I1 passe offense→défense avant résolution | Reste valide si autre condition inchangée |
| TEST-053 | Q59 | Sort « cible ennemie offensive » ; I1 passe offense→défense | Devient invalide ; pas de reciblage |
| TEST-054 | Q60 | Sort dégâts à A et B ; A quitte plateau ; B reste légale | Dégâts seulement sur B ; mana non remboursé |
| TEST-055 | Q60 | Sort cible trois ennemis ; deux invalides | Troisième résout normalement |
| TEST-056 | Q61 | Effet « dégâts cible ; soigne héros » ; cible invalide | Dégâts échouent, soin indépendant tenté |
| TEST-057 | Q61 | « Détruis allié ; si détruit ainsi, soigne » ; destruction impossible | Aucun soin |
| TEST-058 | Q61 | Permutation indivisible : une condition échoue | Aucune des deux positions ne change |
| TEST-059 | Q62 | Sort 3 dégâts tuant cible, puis soin +2, puis pioche ; `ON_DEATH` déclenché | `ON_DEATH` ajouté en file ; soin et pioche tentés avant son exécution |
| TEST-060 | Q62/Q63 | Le héros meurt de fatigue à l'étape pioche d'un sort ; `ON_DEATH` antérieur en file | Combat terminé immédiatement ; aucune capacité en file ne s'exécute |
| TEST-061 | Q63 | Deux héros à 3 PV ; une opération simultanée retire 5 à chacun | Un commit commun, puis défaite du joueur (pas victoire transitoire) |
| TEST-062 | Q63 | Prévention applicable empêche le létal d'un héros lors d'un commit simultané | Prévention calculée avant commit ; résultat victoire évalué après commit |
| TEST-063 | Q64 | Même cible : composantes simultanées compatibles 4 + 3, protection générique absorbant 3, PV initiaux 5 | 7 dégâts groupés, 3 absorbés, 4 PV perdus, survie 1 PV |
| TEST-064 | Q64 | Même cible : dégâts soumis à protections spécifiques distinctes | Ne pas fusionner les composantes qui nécessitent traitements différents ; calculs spécifiques **À CONFIRMER** si mécanique non spécifiée |

**Statut** : scénarios rédigés pour implémentation future ; non exécutés. TEST-064 valide seulement la séparation des composantes incompatibles, pas une formule de résistance élémentaire.


## Tests de conformité supplémentaires — v0.8 (Q65–Q74)

| ID | Préconditions et action | Attendu | Décisions |
|---|---|---|---|
| T-065-01 | Une cible sans protection subit simultanément 3+2 dégâts de deux sources | Perte 5 PV ; exactement **un** `ON_DAMAGE_TAKEN` | Q65 |
| T-065-02 | Même opération entièrement absorbée | Aucun `ON_DAMAGE_TAKEN` ni `ON_DAMAGE_DEALT` | Q65–Q67 |
| T-066-01 | Deux sources de dégâts simultanés causent une perte réelle de PV | Exactement un `ON_DAMAGE_DEALT` par source contributrice et par cible | Q66 |
| T-067-01 | Sources 3+2 ; bouclier 4 ; perte 1 PV | Les **deux** sources déclenchent, une seule fois la cible ; pas de duplication du PV perdu | Q67 |
| T-068-01 | Sources 3+2 ; perte 1 PV ; attribution entière | Quantum `[1,0]`, somme = 1 ; source créditée 0 déclenche tout de même | Q68–Q69 |
| T-069-01 | Sources 5+3+2 ; perte effective 4 PV | Parts `[2,1.2,0.8]`, attribution `[2,1,1]` | Q69 |
| T-069-02 | Sources de contribution égale, points résiduels limités | Départage stable (ordre des sources, identifiant), résultat identique à chaque exécution | Q69 |
| T-070-01 | Source avec vol de vie, quantum 2, héros blessé | Soin de 2 PV **après** effet composé, limité au max du héros | Q70 |
| T-070-02 | Source avec vol de vie, déclenchement collectif mais quantum 0 | Capacité mise en file ; aucun PV soigné | Q67–Q70 |
| T-070-03 | Héros atteint 0 PV pendant opération malgré vol de vie encore en file | Défaite immédiate ; soin jamais appliqué | Q15/Q63/Q70 |
| T-071-01 | 9 dégâts ; armure 2, bouclier 3, PV 8 | Un `ON_ARMOR_ABSORBED(2)`, un `ON_SHIELD_ABSORBED(3)`, un `ON_DAMAGE_TAKEN(4)` | Q71 |
| T-071-02 | Plusieurs sources épuisent des couches de bouclier | Un seul `ON_SHIELD_ABSORBED` par cible/opération ; quantité totale correcte | Q71 |
| T-072-01 | Une cible subit armure, bouclier, perte de PV et prévention létale | Ordre de mise en file armure → bouclier → dégâts subis → prévention létale ; aucun callback intercalé | Q72 |
| T-073-01 | Protection temporaire expire ce tour, autre temporaire expire dans 3 tours, une permanente | Consommer celle qui expire ce tour, conserver les autres | Q73 |
| T-073-02 | Deux temporaires expirent au même instant, dates d'application différentes | Consommer la plus ancienne ; égalité par ID stable | Q73 |
| T-073-03 | Deux protections permanentes | Consommer plus ancienne, puis ID si nécessaire | Q73 |
| T-074-01 | Créature passe de 3 PV à 1 PV par prévention « reste à 1 » | `ON_DAMAGE_TAKEN(2)` + `ON_LETHAL_PREVENTED` ; aucun `ON_DEATH` | Q74 |
| T-074-02 | Créature 3/6, prévention restaure à 6/6 pendant l'opération | Aucun `ON_DAMAGE_TAKEN`, aucun `ON_DAMAGE_DEALT` positif ; `ON_LETHAL_PREVENTED` | Q74 |
| T-074-03 | Prévention consommée avec effet secondaire déclenché | `ON_LETHAL_PREVENTED` mis en file avant effet secondaire ; la prévention intervient avant contrôle de victoire | Q74 |
| T-074-04 | Plusieurs cibles simultanées, chacune avec absorptions | Evénements par cible suivant ordre Q72 ; priorités inter-cibles Q13 et FIFO respectées | Q13/Q71–Q74 |

Ces tests constituent des **cas d'acceptation spécifiés**, pas des tests logiciels déjà exécutés.

## Tests d’acceptation supplémentaires — v0.9 (Q75–Q84)

| ID | Décision | Situation / action | Attendu |
|---|---|---|---|
| T-075-01 | Q75 | Unité 4/6 reçoit soin +5 | 6/6 ; soin effectif 2 ; surplus 3 perdu |
| T-075-02 | Q75 | Héros 10/10 reçoit soin +3 | PV 10/10 ; soin effectif 0 ; surplus 3 |
| T-076-01 | Q76 | Unité 4/6 reçoit soin +5 | Un `ON_HEAL(2)` mis en file, pas `ON_HEAL(5)` |
| T-076-02 | Q76 | Unité 6/6 reçoit soin +3 | Aucun `ON_HEAL` |
| T-077-01 | Q77 | Cible 4/10, soins simultanés A=4, B=5 | 10/10 ; soin effectif 6 ; un `ON_HEAL(6)` ; parts A=3, B=3 |
| T-077-02 | Q77 | Cible manque 1 PV ; soins A=3, B=2 | Attribution `[1,0]` ; somme=1 ; un `ON_HEAL(1)` |
| T-077-03 | Q77 | Cible pleine vie ; 2 sources guérissent simultanément | Aucun `ON_HEAL`, aucun PV crédité |
| T-078-01 | Q78 | Unité 4/6 reçoit +3 PV maximum | 7/9 ; aucun `ON_HEAL` |
| T-078-02 | Q78 | Bonus +3 PV max expire sur unité 7/9 | 4/6 ; ni `ON_DAMAGE_TAKEN` ni `ON_HEAL` |
| T-079-01 | Q79 | Unité 2/6 perd bonus +3, protection « reste à 1 » | Résultat théorique −1/3, puis 1/3 ; `ON_LETHAL_PREVENTED`, pas `ON_DEATH` ni `ON_DAMAGE_TAKEN` |
| T-079-02 | Q79 | Même état sans protection | Mort ; `ON_DEATH` ; aucun événement de dégâts |
| T-080-01 | Q80 | Unité 3/9, deux bonus +3 et +2 PV max expirent ensemble ; deux protections létales | Retrait atomique −5/−5, un seul événement létal potentiel, au plus une protection consommée |
| T-080-02 | Q80 | Bonus +3 et malus −2 PV max expirent ensemble | Calcul net de retrait (−1 max et −1 actuel) sans contrôles létaux intermédiaires |
| T-081-01 | Q81 | Effet « jusqu'à fin du tour » appliqué pendant le tour adverse | Expire à la fin de **ce tour adverse**, pas au prochain tour du créateur |
| T-082-01 | Q82 | +3 ATQ « jusqu'à fin du tour » sur une unité qui attaque automatiquement | Bonus actif durant attaque et réactions, expire après |
| T-082-02 | Q82 | Effet « jusqu'au début de ton prochain tour » | Expire avant croissance/restauration mana et capacités de début de tour |
| T-083-01 | Q83 | Effet « pendant 2 tours » appliqué par le joueur pendant T1 ennemi | T2 joueur = 1/2 ; T4 joueur = 2/2 ; expire fin T4 |
| T-083-02 | Q83 | Effet « pendant 2 tours » appliqué pendant T1 joueur | T1 joueur = 1/2 ; T3 joueur = 2/2 ; expire fin T3 |
| T-084-01 | Q84 | 2 bonus + 1 malus expirent ensemble sur une cible | Une opération atomique ; trois `ON_EFFECT_EXPIRED` après commit ; capacité « lorsqu'un bonus expire » déclenchée deux fois |
| T-084-02 | Q84 | Trois effets sur même cible appliqués à des instants distincts, expirant ensemble | Événements dans l'ordre d'application, puis ID technique ; pas de callback entre retraits |
| T-084-03 | Q84 | Expiration simultanée cause défaite immédiate du héros | État commité, défaite immédiate ; événements en attente non exécutés |

**Statut :** cas rédigés et vérifiables par une implémentation ultérieure ; tests de moteur non exécutés. Les priorités entre familles d'événements issus de la même expiration restent ouvertes (voir [module](../01-combat/temporary-effects.md)).

## Scénarios ajoutés v1.0 — Q85 à Q94

| ID | Règles | État initial et action | Résultat attendu |
|---|---|---|---|
| T-085-01 | Q85 | Deux bonus expirent et créature meurt | `ON_DEATH` de la créature est en file avant ses deux `ON_EFFECT_EXPIRED` |
| T-085-02 | Q85 | Une prévention sauve créature pendant expiration | `ON_LETHAL_PREVENTED` précède `ON_EFFECT_EXPIRED` pour la même cible |
| T-086-01 | Q86 | Deux bonus expirent et tuent la source qui possède « 2 dégâts par bonus expiré » | Deux déclenchements de 2 dégâts sont produits depuis l’instantané, s’ils peuvent se résoudre |
| T-086-02 | Q86 | Source meurt pendant expiration, capacité déjà déclenchée | Événement non annulé ; utilise instance originale/dernier état connu |
| T-087-01 | Q87 | Effet confère capacité « réagit à expiration bonus », puis expire lui-même | Capacité se déclenche sur sa propre expiration |
| T-087-02 | Q87 | Deux effets confèrent des capacités identiques et expirent ensemble | Chaque capacité éligible conserve son identité, reçoit les expirations correspondantes |
| T-088-01 | Q88 | Sort S donne capacité dégâts à créature I1 | Source de gameplay I1 ; S reste origine historique |
| T-088-02 | Q88 | Artefact confère capacité à créature puis disparaît | La capacité déjà déclenchée reste attribuée à la créature, pas à l’artefact |
| T-089-01 | Q89 | I1 avec vol de vie déclenche dégâts, meurt puis renaît I2 | Source et vol de vie de I1 conservés ; I2 ne remplace pas I1 |
| T-090-01 | Q90 | I1 déclenche « dégâts=ATQ » à 3, reçoit +2 ATQ avant résolution | 5 dégâts avant protections si I1 encore active |
| T-090-02 | Q90 | I1 déclenche à ATQ 3, reçoit +2, quitte plateau, renaît I2 à ATQ 9 | 5 dégâts depuis dernier état connu de I1, jamais 9 de I2 |
| T-091-01 | Q91 | I1 acquiert vol de vie après déclenchement avant ses 4 dégâts | `ON_DAMAGE_DEALT` retient vol de vie, soin différé de 4 si attribués |
| T-091-02 | Q91 | I1 perd vol de vie avant dégâts, ou le gagne après dégâts | Pas de soin dans les deux cas si absent au moment des dégâts |
| T-091-03 | Q91 | I1 avec vol de vie inflige dégâts, perd vol de vie avant réaction | Vol de vie enregistré reste applicable |
| T-092-01 | Q92 | Propriétaire ennemi, contrôleur joueur ; 4 PV infligés avec vol de vie | Héros joueur soigné de 4, pas héros ennemi |
| T-092-02 | Q92 | Contrôle retourne à ennemi après dégâts mais avant soin | Bénéficiaire fixé = joueur |
| T-092-03 | Q92 | Deux sources A/B avec contrôle distinct et attribution respective 2/3 | Chaque soin bénéficie au contrôleur de sa source lors de dégâts, montants 2/3 |
| T-093-01 | Q93 | Capacité cible héros joueur sous contrôle ennemi ; contrôleur devient joueur | Cible initiale reste héros joueur ; si légal dégâts appliqués, vol de vie joueur |
| T-093-02 | Q93 | Cible unité ennemie devient alliée avant résolution ; contrainte interdit allié | Effet ciblé échoue, sans retarget ni remboursement |
| T-094-01 | Q94 | I1 à 5/8, +2 ATQ et protection, est contrôlée par nouveau camp | `instanceId` I1 conservé, caractéristiques/protections conservées, seul contrôleur change |
| T-094-02 | Q94 | I1 a capacité en FIFO et effet temporaire appliqué par adversaire ; contrôle change | Même instance, capacité en FIFO conservée, durée dépend du camp ayant appliqué effet |
| T-094-03 | Q94 | Prise de contrôle sans autre effet de zone | Aucun `ON_SUMMON`, `ON_DEATH` ni `ON_RESURRECT` généré |

**État** : cas spécifiés mais non exécutés dans un moteur. Le placement au changement de contrôleur est couvert par les tests v1.1 (Q95–Q104). Voir [sources et contrôle](../01-combat/source-control.md).

## Scénarios ajoutés v1.1 — Q95 à Q104

| ID | Précondition / action | Résultat attendu | Décision |
|---|---|---|---|
| T-095-01 | Prise de contrôle avec colonnes ennemies non contestées | Placement uniquement en cases libres légales de ces colonnes ; choix ligne autorisée ; instance et PV conservés. | Q095 |
| T-095-02 | Prise de contrôle réussie | Aucun ON_SUMMON ni ON_RESURRECT ; même instanceId. | Q095 |
| T-096-01 | Nouveau camp sans aucun emplacement légal au lancement | Sort illégal ; pas de dépense de mana. | Q096 |
| T-096-02 | Case légale à l’annonce, aucune à la résolution | Transfert échoue ; mana non remboursé, ancien contrôle/position conservés. | Q096 |
| T-097-01 | Contrôle temporaire expire, destination dispose de place | Retour légal choisi par camp destination ; même instance et états, pas ON_SUMMON. | Q097 |
| T-097-02 | Contrôle expire, camp destination 12/12 sans départ | Mort de placement ; carte défausse de son propriétaire ; ON_DEATH. | Q097 |
| T-098-01 | Créature protégée, retour impossible | Protection létale non consommée ; ni ON_LETHAL_PREVENTED ni ON_DAMAGE_TAKEN. | Q098 |
| T-098-02 | Effet explicite remplace sortie du plateau pour manque de place | Remplacement consulté avant mort et appliqué selon son texte ; pas de fausse prévention générique. | Q098 |
| T-099-01 | Effets A joueur ancien, B ennemi récent ; B expire seul | Joueur redevient contrôleur si A actif ; instance préservée. | Q099 |
| T-099-02 | Plus aucun effet de contrôle actif | ownerId détermine controllerId final. | Q099 |
| T-100-01 | Deux effets expirent ; troisième conserve le même contrôleur | Aucun transfert, deux ON_EFFECT_EXPIRED, zéro ON_CONTROL_CHANGED. | Q100 |
| T-100-02 | Plusieurs effets expirent au même instant avec contrôleurs intermédiaires différents | Un seul contrôleur final et au plus un transfert physique. | Q100 |
| T-101-01 | Deux retours obligatoires, une case libre | Destination choisit une créature ; autre meurt de placement ; un ON_DEATH. | Q101 |
| T-101-02 | IA avec même état et même seed stratégique | Même choix de placement et même créature survivante à chaque exécution. | Q101 |
| T-102-01 | Chaque camp 12/12, un départ dans chaque sens | Réservation des départs ouvre une case de chaque côté ; deux transferts réussissent. | Q102 |
| T-102-02 | Deux retours croisés + priorités d’invocation | Réservation des cases puis choix respecte colonnes non contestées sur état préparé. | Q102 |
| T-103-01 | Deux camps font des choix dans un même commit | Camp actif décide d’abord ; adversaire connaît le choix ; aucune capacité intermédiaire. | Q103 |
| T-103-02 | L’IA est camp actif et le joueur non actif | L’IA prend un choix déterministe puis joueur choisit avec visibilité, commit commun. | Q103 |
| T-104-01 | Nouveau contrôle appliqué et transfert réussi | Exactement un ON_CONTROL_CHANGED contenant anciens/nouveaux camps et cases. | Q104 |
| T-104-02 | Un contrôle expire mais contrôleur final inchangé | Zéro ON_CONTROL_CHANGED ; ON_EFFECT_EXPIRED émis. | Q104 |
| T-104-03 | Retour impossible et mort de placement | ON_DEATH puis ON_EFFECT_EXPIRED ; aucun ON_CONTROL_CHANGED. | Q104 |
| T-104-04 | Deux contrôles expirent ensemble et un transfert réel unique | Un ON_CONTROL_CHANGED et deux ON_EFFECT_EXPIRED ; ordre contrôle puis expirations. | Q104 |
| T-104-05 | Opération provoque mort par PV et expirations sur même cible | ON_DEATH ou ON_LETHAL_PREVENTED avant événements contrôle/expiration pertinents. | Q104 |
| T-104-06 | Héros atteint zéro PV au commit du transfert composé | Défaite immédiate ; aucune réaction FIFO ne renverse le résultat. | Q104 |

**Statut** : scénarios documentés, non exécutés sur un moteur. Voir [transferts de contrôle](../01-combat/control-transfers.md).

## v1.2 — Tests d’acceptation VALIDÉS Q105–Q114 (spécifiés, **non exécutés**)

Source normative : [capacités de tour et protection anti-boucle](../01-combat/turn-control-and-loop-safety.md).

| ID | Précondition et action | Attendu | Décision |
|---|---|---|---|
| T-105-01 | Contrôle réussi d’une créature déjà active durant le tour joueur | Même instance, aucune invocation ; attaque automatique de ce tour interdite, mouvement/capacités légaux. | Q105 |
| T-105-02 | Une créature transférée possède « ignore le mal d’invocation » | Attaque possible si position offensive et autres conditions satisfaites. | Q105 |
| T-105-03 | Contrôle tenté mais aucun emplacement légal | Aucun transfert, aucune nouvelle restriction d’attaque provenant du transfert raté. | Q105 |
| T-106-01 | Transfert de l’ennemi vers le joueur pendant le tour ennemi T1 | Premier tour joueur T2 : attaque interdite ; second tour joueur T4 : attaque permise si autres critères. | Q106 |
| T-106-02 | Retour au contrôleur d’origine après expiration du contrôle temporaire | Le premier tour personnel du contrôleur revenu est à nouveau bloqué. | Q106 |
| T-106-03 | Deux transferts effectifs successifs vers des camps différents | Chaque nouveau contrôleur reçoit sa propre restriction, sans réutiliser une ancienne autorisation. | Q106 |
| T-107-01 | Prise de contrôle après événement ON_TURN_START mais avant ON_TURN_END | Aucune capacité de début de tour rétroactive ; capacité de fin de tour éligible sous nouveau contrôleur. | Q107 |
| T-107-02 | Capacité ON_TURN_END en FIFO puis la source change de contrôleur | Source, cibles et références de camp figées au déclenchement ; résolution selon Q89–Q93. | Q107 |
| T-107-03 | Créature sous mal d’invocation avec capacité de fin de tour | Capacité ON_TURN_END se déclenche normalement si conditions réunies. | Q107 |
| T-108-01 | Créature ATQ base 3, buff +3 jusqu’à fin de tour, capacité ON_TURN_END = dégâts ATQ | À la résolution ON_TURN_END, attaque automatique déjà passée ; valeur ATQ 6 avant protections, buff expire après. | Q108 |
| T-108-02 | Réaction à ON_TURN_END crée une autre réaction | Toutes les réactions de ON_TURN_END finissent avant l’expiration globale de fin de tour. | Q108 |
| T-108-03 | Une capacité ON_TURN_END tue le héros | Combat terminé immédiatement, aucune expiration ultérieure n’est exécutée. | Q108 |
| T-109-01 | ON_TURN_END crée +2 ATQ jusqu’à fin de ce tour | Le bonus est appliqué puis expire pendant l’étape d’expiration qui suit, génère ON_EFFECT_EXPIRED. | Q109 |
| T-109-02 | ON_TURN_END prolonge effet E42 à échéance plus lointaine | E42 conserve instance, charges et ancienneté ; aucun ON_EFFECT_EXPIRED avant nouvelle échéance. | Q109 |
| T-109-03 | Bonus de fin de tour créé très tard | Aucune durée minimale d’un tour implicite ; texte de carte respecté. | Q109 |
| T-110-01 | FIFO A puis B ; A crée effet dont échéance déjà passée | Après A : création, expiration atomique distincte ; C = réaction en queue ; B résolue avant C. | Q110 |
| T-110-02 | Effet immédiatement périmé déclenche plusieurs réactions | Un ON_EFFECT_EXPIRED par effet ; réactions ordonnées FIFO après événements préexistants. | Q110 |
| T-110-03 | Création d’un effet déjà périmé et héros atteint 0 PV dans l’opération | Victoire/défaite immédiate au contrôle atomique, pas de réaction ultérieure qui inverse le résultat. | Q110 |
| T-111-01 | Capacité ON_EFFECT_EXPIRED recrée sans fin le même bonus périmé | Répétition non progressive confirmée ; seul prochain déclenchement responsable supprimé ; autres événements préservés. | Q111 |
| T-111-02 | Cinq effets distincts expirent et déclenchent la même capacité | Cinq capacités restent autorisées : répétition ne suffit pas à qualifier une boucle. | Q111 |
| T-111-03 | Boucle stoppée alors qu’un événement de soin indépendant attend | Le soin est conservé, aucune opération déjà validée annulée, interruption tracée. | Q111 |
| T-112-01 | Effets identiques successifs portent E42, E43, E44 sans différence fonctionnelle | Signature normalise les identifiants purement techniques et détecte répétition identique. | Q112 |
| T-112-02 | Même plateau mais FIFO A→B puis B→A | Signatures distinctes : ordre FIFO significatif. | Q112 |
| T-112-03 | À chaque tour de boucle la créature perd 1 PV | Signatures différentes tant que les PV progressent ; pas de faux cycle sur seul type de capacité. | Q112 |
| T-112-04 | Effets identiques mais ancienneté différente décide la protection consommée | Ancienneté préservée dans la signature ; pas de fusion abusive. | Q112 |
| T-113-01 | Chaîne augmente bouclier indéfiniment sans état identique | Budget configurable atteint ; branche responsable bloquée, pas de rollback ni défaite technique. | Q113 |
| T-113-02 | Budget atteint avec une branche indépendante | La branche indépendante peut continuer, sous ses propres contrôles de sécurité. | Q113 |
| T-113-03 | Interruption d’une branche par budget | Journal conserve chaîne, branche, compteur, limite, cause et état ; même comportement pour IA/joueur. | Q113 |
| T-114-01 | FIFO = A.27 issu branche bloquée, puis B.1 soin indépendant | A.27 et B.1 restent dans cet ordre et résolvent leurs effets directs normaux. | Q114 |
| T-114-02 | A.27 conservé tente d’insérer A.28 nouveau descendant branche bloquée | A.28 refusé avant insertion, motif journalisé ; les effets directs de A.27 restent validés. | Q114 |
| T-114-03 | B.1 indépendant déclenche un nouvel événement B.2 | B.2 peut être ajouté normalement sous protection de son propre budget/anti-cycle. | Q114 |
| T-114-04 | Branche bloquée avait déjà enregistré trois événements descendants | Les trois événements déjà enregistrés ne sont pas purgés ; ordre FIFO initial préservé. | Q114 |
