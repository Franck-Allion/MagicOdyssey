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
| TEST-025 | Q41/Q210 | Deck vide, héros 2 PV, 2 tentatives | Perte directe 1 PV puis 2 PV si le héros survit ; dans cet exemple défaite à la deuxième tentative, bouclier ignoré |
| TEST-026 | Q42/Q210 | Deck 1, piocher 3 | Pioche 1 ; résoudre effets ; fatigue 1 PV ; résoudre effets ; fatigue 2 PV |
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


## Consolidation v1.3 — Q115–Q124 (scénarios documentés, non exécutés)

Les scénarios ci-dessous sont des critères d’acceptation à automatiser après implémentation du moteur. Références : [budgets causaux et rejeu](causal-budgets-and-replay.md), [FIFO](../01-combat/event-queue.md), [anti-cycles Q105–Q114](../01-combat/turn-control-and-loop-safety.md). Les seuils numériques sont des **fixtures de test**, pas des valeurs d’équilibrage adoptées.

| ID | Mise en situation | Résultat attendu | Décision |
|---|---|---|---|
| T-115-01 | Deux événements parentaux A/B déclenchent une unique admission sémantique C | C entre une fois en FIFO ; tous parents/branches conservés, une seule résolution. | Q115 |
| T-115-02 | Branche A bloquée ; B autorisée contribue à C | La convergence ne réactive pas A ; descendants seulement pour B autorisée. | Q115 |
| T-115-03 | Deux expirations distinctes Q84 déclenchent chacune la même capacité | Deux déclenchements séparés demeurent si la sémantique prévoit deux événements, sans fusion artificielle. | Q115 |
| T-115-04 | Joueur et IA exécutent mêmes causes et même état | Même arbre causal, mêmes admissions, mêmes interruptions. | Q115 |
| T-116-01 | Branche A atteint plafond individuel avec B encore libre | A cesse d’engendrer de nouveaux descendants ; B reste autorisée si plafonds supérieurs disponibles. | Q116 |
| T-116-02 | Branches individuellement sous leur plafond mais chaîne globale épuisée | Toute nouvelle admission descendante de cette chaîne est refusée ; réservations existantes préservées. | Q116 |
| T-116-03 | Plusieurs chaînes créées par une opération atteignent plafond supérieur | Nouvelles admissions de cette origine refusées sans annulation des effets déjà validés. | Q116 |
| T-116-04 | Rejeu sur machine différente avec mêmes règles et budgets versionnés | Même ordre et mêmes décisions, indépendamment du temps CPU. | Q116 |
| T-117-01 | C unique avec deux branches A/B autorisées | Une seule exécution ; +1 branche A, +1 B, +1 chaîne, +1 opération. | Q117 |
| T-117-02 | C unique avec trois causes dont deux de branche A | Une seule imputation +1 pour A, non +2, et +1 pour chaque autre branche distincte autorisée. | Q117 |
| T-117-03 | C atteint exactement plafond A | C autorisée si réservation préalable valide ; nouveaux descendants imputables à A bloqués ensuite. | Q117 |
| T-117-04 | Une des deux branches est déjà bloquée à nouvelle admission C | Aucun coût/nouveau descendant attribuable à branche bloquée ; seul apport autorisé suit les règles de causalité. | Q117 |
| T-118-01 | 998 consommés sur limite 1000, trois admissions successives A,B,C | A et B réservent chacune 1 ; C refusée sans entrée FIFO, ordre canonique conservé. | Q118 |
| T-118-02 | 997 consommés, 3 réservés ; plafond atteint avant résolution | Les trois capacités réservées se résolvent en FIFO ; zéro dépassement du plafond. | Q118 |
| T-118-03 | Une admission requiert branche disponible mais chaîne globale pleine | Aucune réservation partielle : refus atomique et compteurs inchangés. | Q118 |
| T-118-04 | Événement de jeu survient mais capacité réactive est refusée pour budget | Événement source reste dans le journal ; seule la capacité non admise est absente de FIFO. | Q118 |
| T-119-01 | C multicausale réservée A/B puis branche A bloquée avant résolution | Réservations A et B inchangées ; C se résout ; aucun nouveau descendant de A. | Q119 |
| T-119-02 | Capacité réservée A/B/chaîne/opération explicitement annulée avant résolution | Libération atomique des quatre crédits réservés ; aucun crédit consommé retiré. | Q119 |
| T-119-03 | Annulation libère crédit sur branche déjà interrompue | Compteur disponible augmente mais branche demeure bloquée. | Q119 |
| T-119-04 | Même reservationId reçoit une deuxième demande de libération | Deuxième transition refusée comme anomalie, aucun compteur négatif/double crédit. | Q119 |
| T-120-01 | C refusée à budget plein ; B libère ensuite 1 | C reste refusée, aucune file d’attente secondaire. | Q120 |
| T-120-02 | Après libération, nouveau déclenchement D sous branche autorisée | D peut réserver le crédit nouvellement disponible selon FIFO. | Q120 |
| T-120-03 | Branche bloquée récupère des crédits et génère nouveau déclenchement | Déclenchement refusé malgré crédit disponible. | Q120 |
| T-120-04 | Admission refusée puis revue du journal | Aucune mutation des compteurs au refus, motif conservé. | Q120 |
| T-121-01 | Exécution avec deux capacités causales, réservation, interruption, résolution | Journal ordonné enregistre décisions intermédiaires et causes, en plus du résultat. | Q121 |
| T-121-02 | Snapshot périodique puis reprise | Reconstruction avec version des règles, budgets, choix et état RNG identiques. | Q121 |
| T-121-03 | Combat avec choix de joueur et décision IA | Choix explicitement journalisés en ordre canonique. | Q121 |
| T-121-04 | Combat avec tirage aléatoire | Graine, version/état RNG et tirage effectif permettent reproduction du résultat. | Q121 |
| T-122-01 | Deux replays identiques après cinq commits atomiques | Empreintes canoniques identiques après chacun des cinq commits. | Q122 |
| T-122-02 | Écart introduit après troisième commit | Arrêt immédiat au troisième point ; diagnostic identifie commit et différences. | Q122 |
| T-122-03 | Signature anti-cycle Q112 normalise des IDs mais identités différant en rejeu | L’empreinte exacte signale divergence si identité pertinente diffère, sans confusion des deux signatures. | Q122 |
| T-122-04 | FIFO/PRNG diffèrent mais PV finaux identiques | Empreintes différentes : identité d’état futur non garantie malgré PV identiques. | Q122 |
| T-123-01 | FIFO A terminée, B et C réservées ; création snapshot | Snapshot valide avec FIFO B,C et budgets, reprise commence par B sans réexécuter A. | Q123 |
| T-123-02 | Demande snapshot au milieu d’un commit atomique | Snapshot différé au point stable suivant ; jamais de demi-commit sérialisé. | Q123 |
| T-123-03 | Charger snapshot ayant état RNG/counters/FIFO complets | Reprise produit même empreinte après prochaine opération que exécution continue. | Q123 |
| T-123-04 | Choix encore en attente au point de sauvegarde | Choix représenté explicitement et restaurable, ou sauvegarde différée jusqu’à finalisation. | Q123 |
| T-124-01 | Combat commencé avec règles R1 puis installation de R2 | Combat sauvegardé reprend sous R1, cartes/configuration/PRNG liés à R1. | Q124 |
| T-124-02 | Rejeu historique R1 alors que R2 est version par défaut | Rejeu R1 reproduit exactement les empreintes historiques. | Q124 |
| T-124-03 | Dépendance R1 indisponible au chargement | Incompatibilité signalée ; pas de migration silencieuse en R2. | Q124 |
| T-124-04 | Progression RPG entre combats R1 et R2 | Migration RPG possible hors combat ; prochain combat utilise R2, combat R1 inchangé. | Q124 |


## Consolidation v1.4 — Q125–Q134 : scénarios UI et compatibilité (documentés, non exécutés)

Références : [direction artistique et inspection](../02-art-direction/card-and-board-ui.md), [versions historiques](causal-budgets-and-replay.md), [statistiques PV](../01-combat/temporary-effects.md). Tests UI vérifiables par maquettes et tests d’interface ; règles de combat exécutées uniquement après développement du moteur.

| ID | Mise en situation | Critère d’acceptation | Décision |
|---|---|---|---|
| T-125-01 | Règles R1 restent officiellement supportées après sortie R2 | R1 disponible/chargeable à la demande ; combat/replay original reproductible. | Q125 |
| T-125-02 | Version R1 archivée dans dépôt historique compatible | Chargement R1 utilise le manifeste R1 et non les règles R2. | Q125 |
| T-125-03 | Version R1 manquante malgré sauvegarde R1 | Incompatibilité explicite, aucune substitution R2. | Q125 |
| T-125-04 | Mise à jour purement graphique avec règles R1 | Même empreinte fonctionnelle et mêmes résultats. | Q125 |
| T-126-01 | Prototype de carte fantasy avec portrait détaillé | Illustration riche et colorée, texte et stats faciles à lire. | Q126 |
| T-126-02 | Collection de cartes avec créatures et sorts | Direction fantasy cohérente, familles reconnaissables. | Q126 |
| T-126-03 | Revue des sources visuelles | Pas de réutilisation d’assets ou cadres protégés Hearthstone/Magic. | Q126 |
| T-126-04 | Affichage dense du plateau | Lisibilité tactique conservée malgré style illustré. | Q126 |
| T-127-01 | Carte en main puis même créature posée | Carte complète en main ; jeton compact sur plateau. | Q127 |
| T-127-02 | Survol du jeton | Tooltip de synthèse des stats et états. | Q127 |
| T-127-03 | Clic sur jeton | Vue de la carte complète et état de combat. | Q127 |
| T-127-04 | Plateau 24 créatures | Ni chevauchement de cartes complètes ni blocage de lecture. | Q127 |
| T-128-01 | Créature ordinaire sans état | Portrait, ATQ finale et PV actuels visibles. | Q128 |
| T-128-02 | Créature avec effet critique | Icône d’état pertinent ajoutée sans modifier les chiffres. | Q128 |
| T-128-03 | Créature avec capacité secondaire seulement | Jeton reste sobre ; capacité accessible au survol. | Q128 |
| T-128-04 | État absent du jeton | État présent dans le tooltip et l’inspection. | Q128 |
| T-129-01 | Jeton d’une créature alliée | Médaillon rond/ovale et socle tactique visibles. | Q129 |
| T-129-02 | Jeton adverse de même type | Camp discernable sans s’appuyer uniquement sur couleur. | Q129 |
| T-129-03 | Colonne offense/défense remplie | Portrait et socle n’empêchent pas lecture de la position. | Q129 |
| T-129-04 | Affichage avec 24 unités | Forme compacte et emplacements restent reconnaissables. | Q129 |
| T-130-01 | Jeton ATQ 5 PV 6 | 5 en bas à gauche, 6 en bas à droite. | Q130 |
| T-130-02 | Créature avec deux états | Icônes sous le portrait et pas sur les valeurs. | Q130 |
| T-130-03 | PV réduits par opération atomique | Valeur à droite synchronisée après commit. | Q130 |
| T-130-04 | Clic du jeton | Structure de la carte originale distincte du rendu compact. | Q130 |
| T-131-01 | ATQ de base 3, bonus +2 | ATQ effective 5, signe positif visible en plus de la couleur. | Q131 |
| T-131-02 | ATQ de base 5, malus -2 | ATQ effective 3, signe négatif sans seul code couleur. | Q131 |
| T-131-03 | 6 PV actuels, 8 PV max | Jeton montre 6, tooltip/inspection montrent 6/8. | Q131 |
| T-131-04 | 2 armures et 1 bouclier | Symboles distincts et quantités identifiables, aucune DEF inventée. | Q131 |
| T-132-01 | Deux effets actifs | Deux icônes, pas de +N. | Q132 |
| T-132-02 | Six états actifs distincts | Trois icônes prioritaires et +3. | Q132 |
| T-132-03 | Clic jeton avec six états | Vue complète présente les six, y compris ceux masqués. | Q132 |
| T-132-04 | Changement de priorité après effet expiré | Trio recalculé selon règles stables, +N exact. | Q132 |
| T-133-01 | Carte imprimée 3 ATQ/8 PV, bonus +2 | Carte d’origine reste 3/8 ; panneau explique +2 ATQ. | Q133 |
| T-133-02 | Capacité initiale neutralisée | Texte imprimé intact ; panneau explique la neutralisation. | Q133 |
| T-133-03 | Aucun effet ni différence à l’original | Carte seule possible, aucun panneau vide imposé. | Q133 |
| T-133-04 | Carte avec capacité temporaire | Capacité temporaire présentée hors recto et avec durée/source. | Q133 |
| T-134-01 | Base 3 ATQ, +4, -2 simultanés | **ATQ FINALE 5** visible en tête de panneau et détail 3+4-2. | Q134 |
| T-134-02 | 6/8 PV et +2 PV max temporaire | **PV actuels/max effectifs** reflètent Q78 ; blessure conservée, aucune guérison fictive. | Q134 |
| T-134-03 | Armure 2 et bouclier 1 | Valeurs défensives distinctes visibles ; pas de DEF unique fabriquée. | Q134 |
| T-134-04 | Créature avec sept buffs/debuffs et contrôle temporaire | Tous les effets actifs, sources, durées et restrictions accessibles, panneau défilable. | Q134 |


## Consolidation v1.5 — Q135–Q144 : tests de tooltip, durée et feedbacks (spécifiés, non exécutés)

Références : [spécification UI/VFX Q135–Q144](../02-art-direction/tooltips-durations-and-vfx.md), [cartes et inspections Q126–Q134](../02-art-direction/card-and-board-ui.md), [règles d’effets](../01-combat/temporary-effects.md), [règles de la FIFO](../01-combat/event-queue.md). Les objectifs de 3–5 secondes sont **indicatifs**, à mesurer sur prototypes et plateformes cibles ; les critères logiques demeurent stricts.

| Test | Mise en situation | Critère d’acceptation | Décision |
|---|---|---|---|
| T-135-01 | ATQ 5 +2 et ATQ 5 −2 | 7 vert/flèche haute et 3 rouge/flèche basse, lisibles sans couleur | Q135 |
| T-135-02 | 6/8 PV sans modificateur max | Blessure visible distincte du malus PV max | Q135 |
| T-135-03 | Bonus +3 et malus −3 | Valeur finale neutre, calcul des deux effets conservé dans panneau | Q135 |
| T-135-04 | Source en dehors du plateau | Actualisation des valeurs finales après commit sans changer la carte imprimée | Q135 |
| T-136-01 | Survol avec six effets | Les six apparaissent sous forme condensée, pas seulement les trois icônes | Q136 |
| T-136-02 | Créature à 6 PV sur 8 max | Tooltip 6/8, jeton 6 | Q136 |
| T-136-03 | Effet très long / plusieurs textes de capacités | Tooltip condensé et inspection au clic pour descriptions détaillées | Q136 |
| T-136-04 | Tooltip près du bord de plateau | Position adaptée sans masquer la cible ou les commandes | Q136 |
| T-137-01 | Deux effets +2 ATQ identiques | Deux lignes distinctes avec durées propres | Q137 |
| T-137-02 | Effets caractéristiques/protection/restriction/capacité | Ordre de catégorie stable quelle que soit la phase | Q137 |
| T-137-03 | Deux effets catégorie identique, âges différents | Ordre d’application stable et déterministe | Q137 |
| T-137-04 | Réordonnancement UI après expiration | Aucune modification de priorité logique FIFO/expiration | Q137 |
| T-138-01 | Buff créé par joueur, portée par unité ennemie | Libellé de durée basé sur tour du joueur créateur | Q138 |
| T-138-02 | Effet permanent | Affichage Permanent sans compteur inventé | Q138 |
| T-138-03 | Effet conditionnel lié à artefact | Condition de disparition indiquée, pas fausse durée | Q138 |
| T-138-04 | Expiration prochain tour adverse | Texte naturel explicitant le camp et la phase sans confusion | Q138 |
| T-139-01 | Contrôle ennemi réussi | Icône contrôle incluse parmi états tactiques prioritaires | Q139 |
| T-139-02 | Buff « Encore 2 tours ennemi » change de contrôleur | Texte « Encore 2 tours ennemi » invariant | Q139 |
| T-139-03 | Créature volée | Owner reste propriétaire original, controller nouveau | Q139 |
| T-139-04 | Plus de trois états dont contrôle | Trois icônes prioritaires +N ; source et contrôle détaillés au clic | Q139 |
| T-140-01 | Bonus prolongé de deux tours | Durée mise à jour + bref +2 tours / horloge sur jeton | Q140 |
| T-140-02 | Bonus raccourci d’un tour | Durée mise à jour + feedback négatif distinct | Q140 |
| T-140-03 | Prolongation sans expiration | Aucun événement ON_EFFECT_EXPIRED ou nouvelle instance | Q140 |
| T-140-04 | Feedback de durée fini | Aucune quatrième icône permanente ajoutée au jeton | Q140 |
| T-141-01 | Action mineure répétée dix fois | Feedback perceptible mais bref sans attente excessive | Q141 |
| T-141-02 | Sort puissant et boss tué | Animation graduée intense, résultat perceptible | Q141 |
| T-141-03 | Mode animations réduites | Même information et état final, mouvement/flash réduits | Q141 |
| T-141-04 | Mêmes actions avec différents FPS | Mêmes transitions logiques, aucun effet sur résolution | Q141 |
| T-142-01 | Dix réactions secondaires compatibles | Accélération ou regroupement visuel sans changement des effets | Q142 |
| T-142-02 | Deux cibles frappées simultanément | Rendus indépendants sans nombres confondus | Q142 |
| T-142-03 | Fin de chaîne avec mort et soin | Mort et PV final restent visibles avant reprise | Q142 |
| T-142-04 | Replay avec animations désactivées | Journal logique et empreintes identiques | Q142 |
| T-143-01 | 8 dégâts bruts et 3 absorbés armure | −3 armure représenté séparément de −5 PV | Q143 |
| T-143-02 | Soin demandé 6, réalisé 2 | Nombre flottant +2 et non +6 | Q143 |
| T-143-03 | Bouclier consommé sans perte PV | Éclat/rupture magique sans nombre −PV | Q143 |
| T-143-04 | Sort exceptionnel | Éclairs, halo ou secousse si pertinent, chiffres restent lisibles | Q143 |
| T-144-01 | Chaîne de 20 effets mineurs | Objectif initial de 3–5 s visé par orchestrateur, mesures de prototype | Q144 |
| T-144-02 | Chaîne avec ultime et mort de boss | Moment spectaculaire préservé malgré accélération du reste | Q144 |
| T-144-03 | Effets indépendants et réactions secondaires | Superposition et regroupement compatibles sans pertes d’information | Q144 |
| T-144-04 | Chaîne calculée en 1 ms, présentation ralentie par GPU | Moteur logique, budgets et résultats indépendants du temps visuel | Q144 |


## Tests UI / plateau et prévisualisations — v1.6, Q145 à Q154

> **40 scénarios supplémentaires documentés, non exécutés** : les résultats attendus sont des exigences d’acceptation et non des affirmations de conformité d’un prototype. Les valeurs temporelles et les seuils de performance restent à mesurer. Source : [spécification Q145–Q154](../02-art-direction/board-and-tactical-preview.md).

| ID | Situation / action | Résultat attendu | Référence |
|---|---|---|---|
| T-145-01 | Décor unique V1 et changement de thème simulé | Mêmes positions, règles, états et cibles ; seul habillage varie | [Q145](../02-art-direction/board-and-tactical-preview.md) |
| T-145-02 | Grille 6x4 et deux camps | 24 emplacements fonctionnels alignés et identifiables pendant interaction | [Q145](../02-art-direction/board-and-tactical-preview.md) |
| T-145-03 | Thème fantaisie visuellement chargé | Cases, chiffres et jetons lisibles sans recouvrement | [Q145](../02-art-direction/board-and-tactical-preview.md) |
| T-145-04 | Données de combat rechargées après changement de décor | Aucune différence de hash fonctionnel ni événement moteur | [Q145](../02-art-direction/board-and-tactical-preview.md) |
| T-146-01 | Torche animée derrière une créature | PV et ATQ lisibles ; ambiance visuellement secondaire | [Q146](../02-art-direction/board-and-tactical-preview.md) |
| T-146-02 | Animations d’ambiance désactivées | Aucune perte de capacité à jouer, cibler ou comprendre | [Q146](../02-art-direction/board-and-tactical-preview.md) |
| T-146-03 | Sort puissant sur case avec rune de décor | Feedback du sort reste prioritaire | [Q146](../02-art-direction/board-and-tactical-preview.md) |
| T-146-04 | Changement de profil de mouvement réduit | Ambiance réduite, données tactiques intactes | [Q146](../02-art-direction/board-and-tactical-preview.md) |
| T-147-01 | Plateau au repos | Absence de pictogrammes répétitifs encombrants | [Q147](../02-art-direction/board-and-tactical-preview.md) |
| T-147-02 | Survol case offensive | Indication contextuelle de rôle/camp visible puis masquée | [Q147](../02-art-direction/board-and-tactical-preview.md) |
| T-147-03 | Sélection puis annulation | Highlights et étiquettes temporaires supprimés | [Q147](../02-art-direction/board-and-tactical-preview.md) |
| T-147-04 | Thème dénué de bleu/rouge | Symboles/contours permettent toujours de différencier les camps | [Q147](../02-art-direction/board-and-tactical-preview.md) |
| T-148-01 | Carte sélectionnée avec 3 destinations légales | Seules 3 cases légales identifiées | [Q148](../02-art-direction/board-and-tactical-preview.md) |
| T-148-02 | Tentative sur case non autorisée | Feedback local et motif court ; pas de dépôt exécuté | [Q148](../02-art-direction/board-and-tactical-preview.md) |
| T-148-03 | Début du geste de déplacement | Destinations légales du mouvement effectif affichées | [Q148](../02-art-direction/board-and-tactical-preview.md) |
| T-148-04 | Fin de geste/annulation | Cases éclairées effacées sans persistance | [Q148](../02-art-direction/board-and-tactical-preview.md) |
| T-149-01 | Créature sélectionnée, attaque déterministe létale | La cible et la créature affichent leurs conséquences de phase pertinentes | [Q149](../02-art-direction/board-and-tactical-preview.md) |
| T-149-02 | Unité fraîchement invoquée et malade | Aucune attaque supposée pendant phase non autorisée | [Q149](../02-art-direction/board-and-tactical-preview.md) |
| T-149-03 | Capacité de dégâts en réaction déterministe | Ordre de résolution pris en compte ; pas de calcul naïf de riposte | [Q149](../02-art-direction/board-and-tactical-preview.md) |
| T-149-04 | Prévision sans commit et RNG isolé | État réel, FIFO, seed et hash identiques avant/après consultation | [Q149](../02-art-direction/board-and-tactical-preview.md) |
| T-150-01 | Cible à 8 PV finissant à 3 | Indicateur temporaire 8 → 3 sans masquer 8 PV réels | [Q150](../02-art-direction/board-and-tactical-preview.md) |
| T-150-02 | Mort prévue après protections | Crâne et zéro PV visibles, sans animation de mort réelle | [Q150](../02-art-direction/board-and-tactical-preview.md) |
| T-150-03 | Issue pouvant dépendre d’une réaction | ? explicite, pas de faux résultat garanti | [Q150](../02-art-direction/board-and-tactical-preview.md) |
| T-150-04 | Fin de sélection | Overlays disparaissent, caractéristiques réelles inchangées | [Q150](../02-art-direction/board-and-tactical-preview.md) |
| T-151-01 | Glissement entre deux cases valides | Aperçu et valeurs changent selon la case, non selon pixels | [Q151](../02-art-direction/board-and-tactical-preview.md) |
| T-151-02 | Retour vers case déjà consultée sans modification d’état | Cache réutilisable ; résultat identique | [Q151](../02-art-direction/board-and-tactical-preview.md) |
| T-151-03 | État réel changé après mise en cache | Invalidation et nouveau calcul, pas de chiffres périmés | [Q151](../02-art-direction/board-and-tactical-preview.md) |
| T-151-04 | Calcul tardif pour ancienne case | Résultat rejeté si la case cible a changé | [Q151](../02-art-direction/board-and-tactical-preview.md) |
| T-152-01 | Résultat déterministe rapide | Montre valeurs certaines sans attendre branches non pertinentes | [Q152](../02-art-direction/board-and-tactical-preview.md) |
| T-152-02 | Aléa ou choix futur peut inverser décès | Statut incertain et hypothèses explicites | [Q152](../02-art-direction/board-and-tactical-preview.md) |
| T-152-03 | Budget de prévision épuisé | Indisponible ou partiel explicitement, sans bloquer case légale | [Q152](../02-art-direction/board-and-tactical-preview.md) |
| T-152-04 | Mode preview sur partie rejouée | Aucune influence sur RNG, budget logique, log ni issue | [Q152](../02-art-direction/board-and-tactical-preview.md) |
| T-153-01 | Dépôt sur case légale avec prévision en cours | Action traitée immédiatement après vérification moteur | [Q153](../02-art-direction/board-and-tactical-preview.md) |
| T-153-02 | Dépôt sur case devenue interdite | Rejet sans mutation, carte retourne à l’origine | [Q153](../02-art-direction/board-and-tactical-preview.md) |
| T-153-03 | Dépôt légal d’invocation forte | Feedback juicy gradué ; action logique indépendante animation | [Q153](../02-art-direction/board-and-tactical-preview.md) |
| T-153-04 | Réponse de preview tardive après dépôt | Ignorée ; ne modifie ni nouveaux chiffres ni partie | [Q153](../02-art-direction/board-and-tactical-preview.md) |
| T-154-01 | Placement au drag et clic-clic sur même case | Action identique, mêmes règles/couts et informations de placement | [Q154](../02-art-direction/board-and-tactical-preview.md) |
| T-154-02 | Tactile sans survol | Accès par sélection/focus aux cases et prévisions | [Q154](../02-art-direction/board-and-tactical-preview.md) |
| T-154-03 | Échap ou annulation avant commit | Retour initial sans dépense ni événement | [Q154](../02-art-direction/board-and-tactical-preview.md) |
| T-154-04 | Commande d’annulation après commit | Aucun undo implicite de l’action effective | [Q154](../02-art-direction/board-and-tactical-preview.md) |


## Tests de conformité v1.7 — Q155 à Q164

> **40 nouveaux scénarios définis, non exécutés.** Le tableau ci-dessous décrit les critères de réception du futur moteur et de l’interface, et non des résultats de test d’un logiciel existant. Les tie-breakers canoniques précis et seuils techniques doivent être finalisés et versionnés avant automatisation de leurs valeurs attendues. Source : [sorts, auras et effets continus](../02-art-direction/spells-auras-and-continuous-effects.md).

| ID | Scénario | Résultat attendu | Source |
|---|---|---|---|
| T-155-01 | Sort ciblé sur une créature protégée | Dégâts et consommations estimés selon résolution moteur ; statistiques réelles intactes | [Q155](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-155-02 | Même sort vers deux cibles successives | Preview mise à jour ; aucun résultat tardif de la cible précédente | [Q155](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-155-03 | Capacité adverse cachée | Aucune révélation d’information secrète ou de mort garantie trompeuse | [Q155](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-155-04 | Prévision d’un sort suivie d’un commit | Aucune mutation RNG/FIFO/ressources avant le commit réel | [Q155](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-156-01 | Sort ne touche qu’une unité puis plusieurs | Même graphisme, symboles et convention de chiffres par créature | [Q156](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-156-02 | Zone touche 6 créatures de caractéristiques distinctes | Six résultats individuels lisibles, sans chevauchement ni omission | [Q156](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-156-03 | Créature hors zone touchée par réaction | Cible indirecte distinguée de la zone directement visée | [Q156](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-156-04 | Dégâts de zone atomiques avec protections | Prévision identique aux règles de dégâts simultanés, sans faux ordre | [Q156](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-157-01 | Buff +3 ATQ sur une cible | Plateau montre ATQ finale prévisionnelle, sans imposer la flèche avant/après | [Q157](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-157-02 | Inspection du buff | Valeurs avant/après, source et durée explicitement consultables | [Q157](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-157-03 | Sort modifie PV maximum et actuels | PV prévus cohérents avec Q26 ; chiffre réel non écrasé | [Q157](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-157-04 | Cible et zone avec même buff | Conventions identiques quel que soit le nombre de cibles | [Q157](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-158-01 | Enchantement donne bonus immédiat et armure au prochain coup | Bonus immédiatement actif présent, armure future absente du total | [Q158](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-158-02 | Inspection de condition non déclenchée | Condition, durée, source et conséquence future visibles | [Q158](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-158-03 | Condition déjà satisfaite après le sort | Effet immédiatement effectif intégré à la valeur finale prévue | [Q158](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-158-04 | Capacité conditionnelle réellement appliquée | Icône tactique prioritaire reste disponible selon Q132/Q136 | [Q158](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-159-01 | Plateau avec plusieurs auras au repos | Absence de rayons/halos permanents entre toutes les unités | [Q159](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-159-02 | Source d’aura sélectionnée | Tous les bénéficiaires actuels surlignés sans ambiguïté | [Q159](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-159-03 | Source retirée ou contrôleur changé | Bénéficiaires et caractéristiques actualisés selon règles | [Q159](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-159-04 | Interaction tactile sur source | Même liste de bénéficiaires disponible sans hover | [Q159](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-160-01 | Aura ATQ ouvre condition armure | Preview montre ATQ et armure finales après cascade | [Q160](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-160-02 | Déplacer source sur autre colonne | Tous bénéficiaires pertinents recalculés sans étapes intermédiaires visibles | [Q160](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-160-03 | Réaction future dépend du prochain tour | Elle reste non comptée comme bonus immédiat | [Q160](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-160-04 | Une cascade devient incertaine | Marqueur incertitude et détails, aucun faux état final certain | [Q160](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-161-01 | Chaîne d’auras A vers B vers C acyclique | Ordre topologique canonique, mêmes résultats quel que soit parcours interne | [Q161](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-161-02 | Deux états d’entrée identiques historiques différents | Même état final sauf règles explicitement historiques | [Q161](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-161-03 | Modification de condition dans la même opération | Dépendances concernées recomputées avant lecture pertinente | [Q161](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-161-04 | Prévisualisation puis moteur sur mêmes paramètres déterministes | Même solveur, mêmes valeurs, aucune FIFO issue des itérations internes | [Q161](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-162-01 | Cycle sans point fixe | Détecté, sortie déterministe sans oscillation infinie | [Q162](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-162-02 | Deux points fixes possibles sans priorité | Ambiguïté détectée et règle canonique appliquée | [Q162](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-162-03 | Cycle avec branche indépendante | Branche indépendante reste active après neutralisation ciblée | [Q162](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-162-04 | Modification casse le cycle | Dépendances neutralisées réévaluées, trace de décision reproductible | [Q162](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-163-01 | Cycle oppose une contrainte fondamentale et un bonus | Contrainte fondamentale préservée, seule dépendance neutralisable écartée | [Q163](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-163-02 | Deux dépendances de même priorité peuvent être écartées | Tie-break canonique stable, identique entre exécutions | [Q163](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-163-03 | Même état sous autre ordre mémoire ou plateforme | Même dépendance neutralisée et même résultat final | [Q163](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-163-04 | Conflit local et bonus indépendant sur une même source | Bonus indépendant reste actif ; neutralisation minimale vérifiable | [Q163](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-164-01 | Source détruite, aura ATQ et armure conditionnelle perdues | Valeurs cohérentes avant l’opération suivante et ses réactions FIFO | [Q164](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-164-02 | Cascades de 8 modifications dans une opération atomique | Pas d’état intermédiaire incohérent exposé comme commit | [Q164](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-164-03 | UI regroupe plusieurs transitions rapides | Journal logique et empreintes identiques avec VFX détaillés ou regroupés | [Q164](../02-art-direction/spells-auras-and-continuous-effects.md) |
| T-164-04 | Preview en cache sous version antérieure du solveur | Cache invalidé, aucun résultat périmé ; RNG et FIFO réels inchangés | [Q164](../02-art-direction/spells-auras-and-continuous-effects.md) |


## Scénarios d’acceptation v1.8 — Q165–Q174 (spécifiés, non exécutés)

| ID | Scénario | Résultat attendu | Référence |
|---|---|---|---|
| T-165-01 | Conflit neutralise une dépendance d’aura | Feedback bref source + bénéficiaires, valeurs effectives exactes, aucun pictogramme permanent ajouté | [Q165](../02-art-direction/combat-journal-and-inspection.md) |
| T-165-02 | Cycle résolu et condition extérieure change | Feedback distinct de réactivation et retour du bonus, sans double application | [Q165](../02-art-direction/combat-journal-and-inspection.md) |
| T-165-03 | Inspection d’un bonus neutralisé | Source, contribution non appliquée et raison visible sans divulguer de secret | [Q165](../02-art-direction/combat-journal-and-inspection.md) |
| T-165-04 | Même conflit en preview et en combat | Même contribution neutralisée et logs/replay déterministes | [Q165](../02-art-direction/combat-journal-and-inspection.md) |
| T-166-01 | Combat sans consultation | Journal masqué par défaut, VFX et résolution non affectés | [Q166](../02-art-direction/combat-journal-and-inspection.md) |
| T-166-02 | Attaque avec huit réactions | Résumé par séquence ; détail complet des huit réactions dans leur ordre | [Q166](../02-art-direction/combat-journal-and-inspection.md) |
| T-166-03 | Événement masqué par règle de visibilité | Ni résumé ni détail joueur ne révèle le secret | [Q166](../02-art-direction/combat-journal-and-inspection.md) |
| T-166-04 | Ouverture puis fermeture du journal | Aucune variation du moteur, du RNG ou de la FIFO | [Q166](../02-art-direction/combat-journal-and-inspection.md) |
| T-167-01 | Large écran, ouverture sur demande | Panneau latéral ; plateau encore visible et lisible | [Q167](../02-art-direction/combat-journal-and-inspection.md) |
| T-167-02 | Petit écran, ouverture sur demande | Panneau se superpose ou s’adapte, sans écraser les 24 cases | [Q167](../02-art-direction/combat-journal-and-inspection.md) |
| T-167-03 | Fermeture immédiate | Panneau disparaît, aucun changement de combat | [Q167](../02-art-direction/combat-journal-and-inspection.md) |
| T-167-04 | Journal avec séquences nombreuses | Dépliage et défilement fonctionnels dans le panneau | [Q167](../02-art-direction/combat-journal-and-inspection.md) |
| T-168-01 | Survol événement, créature encore présente | Mise en évidence de la bonne instance et retour visuel à la normale | [Q168](../02-art-direction/combat-journal-and-inspection.md) |
| T-168-02 | Deux créatures au même nom | Seule instance historiquement liée est sélectionnée | [Q168](../02-art-direction/combat-journal-and-inspection.md) |
| T-168-03 | Créature détruite ou déplacée depuis événement | Identité/portrait/position d’époque dans journal ; plateau actuel inchangé | [Q168](../02-art-direction/combat-journal-and-inspection.md) |
| T-168-04 | Événement historique de contrôle | Pas de déplacement ni changement de camp en direct durant consultation | [Q168](../02-art-direction/combat-journal-and-inspection.md) |
| T-169-01 | Créature perd 7 PV et meurt | Inspection distingue avant 7 PV et après 0 PV | [Q169](../02-art-direction/combat-journal-and-inspection.md) |
| T-169-02 | Créature détruite puis ressuscitée | Événements historiques restent attribués à leur instance correcte | [Q169](../02-art-direction/combat-journal-and-inspection.md) |
| T-169-03 | Aura active à T puis disparue à T+1 | Inspection de T montre état et source pertinents à T | [Q169](../02-art-direction/combat-journal-and-inspection.md) |
| T-169-04 | Créature a changé de colonne et contrôleur | Position et contrôle historiques corrects, sans reconstruction depuis état courant | [Q169](../02-art-direction/combat-journal-and-inspection.md) |
| T-170-01 | Recherche par nom de sort connu | Seules séquences concernées et visibles retournées | [Q170](../02-art-direction/combat-journal-and-inspection.md) |
| T-170-02 | Filtre morts puis remise à zéro | Événements filtrés adéquats, retour au journal complet | [Q170](../02-art-direction/combat-journal-and-inspection.md) |
| T-170-03 | Filtre d’une chaîne multi-événements | Ordre des enfants conservé après filtrage | [Q170](../02-art-direction/combat-journal-and-inspection.md) |
| T-170-04 | Recherche d’information cachée | Aucun secret affiché, indexé ou suggéré | [Q170](../02-art-direction/combat-journal-and-inspection.md) |
| T-171-01 | Attaque annonce 8, 3 absorbés, 5 PV perdus | Résumé : 5 PV perdus et 3 absorbés, sans double compte | [Q171](../02-art-direction/combat-journal-and-inspection.md) |
| T-171-02 | Chaîne de 20 événements dont deux morts | Résumé identifie deux morts ; détail conserve les 20 événements | [Q171](../02-art-direction/combat-journal-and-inspection.md) |
| T-171-03 | Changement de contrôle sans dégâts | Événement majeur mis en avant malgré zéro dégât | [Q171](../02-art-direction/combat-journal-and-inspection.md) |
| T-171-04 | Consultation d’une vieille séquence après changements du plateau | Résumé historique stable, jamais recalculé depuis état actuel | [Q171](../02-art-direction/combat-journal-and-inspection.md) |
| T-172-01 | Capacité déclenchée après mort | Texte décrit capacité, source et déclencheur visibles | [Q172](../02-art-direction/combat-journal-and-inspection.md) |
| T-172-02 | Longue chaîne multi-causale | Aucun lien de navigation causale ni graphe requis ; événements lisibles en ordre | [Q172](../02-art-direction/combat-journal-and-inspection.md) |
| T-172-03 | Panneau ouvert pendant séquence | Descriptions calculées depuis événements existants, pas de simulation rétroactive | [Q172](../02-art-direction/combat-journal-and-inspection.md) |
| T-172-04 | Effet venant d’une source cachée | Texte ne révèle pas source secrète | [Q172](../02-art-direction/combat-journal-and-inspection.md) |
| T-173-01 | Combat de trente tours avec nombreuses réactions | Début et fin du combat consultables, aucune purge par tour | [Q173](../02-art-direction/combat-journal-and-inspection.md) |
| T-173-02 | Événements secondaires multiples | Tous les événements visibles pertinents retrouvables dans les détails | [Q173](../02-art-direction/combat-journal-and-inspection.md) |
| T-173-03 | Fin de combat normal | Historique joueur peut être libéré sans supprimer logs techniques nécessaires | [Q173](../02-art-direction/combat-journal-and-inspection.md) |
| T-173-04 | Sauvegarde puis reprise pendant combat | Journal cohérent et complet pour la partie déjà révélée | [Q173](../02-art-direction/combat-journal-and-inspection.md) |
| T-174-01 | Ouverture pendant longue animation | Panneau consultable, VFX continuent, aucune pause moteur | [Q174](../02-art-direction/combat-journal-and-inspection.md) |
| T-174-02 | Moteur a résolu mort mais animation non présentée | Mort pas encore révélée dans journal joueur | [Q174](../02-art-direction/combat-journal-and-inspection.md) |
| T-174-03 | Événements visuels groupés | Révélation progressive cohérente avec groupes, sans inversion chronologique | [Q174](../02-art-direction/combat-journal-and-inspection.md) |
| T-174-04 | Fin des animations, journal encore ouvert | Historique visible complet et résumé définitif, combat inchangé | [Q174](../02-art-direction/combat-journal-and-inspection.md) |


## V1.9 — Tests Q175–Q184 : récompenses et progression (40 scénarios non exécutés)

| ID | Scénario | Résultat attendu | Référence |
|---|---|---|---|
| T-175-01 | Victoire normale | Célébration courte, feedback final identifiable et accès rapide aux gains | [Q175](../03-progression/rewards-rarity-and-ascension.md) |
| T-175-02 | Victoire de boss | Mise en scène enrichie mais non obligatoire pour combat ordinaire | [Q175](../03-progression/rewards-rarity-and-ascension.md) |
| T-175-03 | Animation écourtée par joueur | Issue, trace et gains inchangés | [Q175](../03-progression/rewards-rarity-and-ascension.md) |
| T-175-04 | Attaque létale + événements de fin | Aucune célébration ne change le verdict canonique | [Q175](../03-progression/rewards-rarity-and-ascension.md) |
| T-176-01 | Récompense avec gains automatiques et choix | Zones distinctes, sélection explicite | [Q176](../03-progression/rewards-rarity-and-ascension.md) |
| T-176-02 | Trois cartes à inspecter | Inspection sans acquisition ni perte de contexte | [Q176](../03-progression/rewards-rarity-and-ascension.md) |
| T-176-03 | Révélation d’une carte commune | Effet et couleur cohérents avec la rareté réelle | [Q176](../03-progression/rewards-rarity-and-ascension.md) |
| T-176-04 | Reprise pendant écran de gains | Offre identique, aucune duplication | [Q176](../03-progression/rewards-rarity-and-ascension.md) |
| T-177-01 | Offre standard | Exactement trois cartes éligibles affichées | [Q177](../03-progression/rewards-rarity-and-ascension.md) |
| T-177-02 | Inspection des trois cartes | Toutes consultables avant confirmation | [Q177](../03-progression/rewards-rarity-and-ascension.md) |
| T-177-03 | Choisir une proposition | Une seule carte ajoutée, autres non acquises | [Q177](../03-progression/rewards-rarity-and-ascension.md) |
| T-177-04 | Double clic sur validation | Un seul ajout par décision | [Q177](../03-progression/rewards-rarity-and-ascension.md) |
| T-178-01 | Refuser toutes les cartes | Aucune carte ajoutée, compensation attribuée | [Q178](../03-progression/rewards-rarity-and-ascension.md) |
| T-178-02 | Refus avec gains automatiques | Monnaie et EXP normales conservées + compensation | [Q178](../03-progression/rewards-rarity-and-ascension.md) |
| T-178-03 | Prévisualiser compensation | Type et quantité visibles avant validation | [Q178](../03-progression/rewards-rarity-and-ascension.md) |
| T-178-04 | Recharger après confirmation | Pas de compensation distribuée deux fois | [Q178](../03-progression/rewards-rarity-and-ascension.md) |
| T-179-01 | Combat ordinaire gagné | Monnaie et EXP reçues | [Q179](../03-progression/rewards-rarity-and-ascension.md) |
| T-179-02 | Refus du draft | Gains monnaie/EXP préservés indépendamment | [Q179](../03-progression/rewards-rarity-and-ascension.md) |
| T-179-03 | Étage et difficulté différents | Paramètres de calcul pris en compte selon barème disponible | [Q179](../03-progression/rewards-rarity-and-ascension.md) |
| T-179-04 | Affichage de gains | Distingue gains garantis des options | [Q179](../03-progression/rewards-rarity-and-ascension.md) |
| T-180-01 | Boss vaincu | Monnaie et EXP renforcées, offre exceptionnelle | [Q180](../03-progression/rewards-rarity-and-ascension.md) |
| T-180-02 | Joueur préfère deck compact | Possibilité de choisir artefact ou amélioration, sans carte | [Q180](../03-progression/rewards-rarity-and-ascension.md) |
| T-180-03 | Offres intercatégories | Inspection et confirmation de la catégorie choisie | [Q180](../03-progression/rewards-rarity-and-ascension.md) |
| T-180-04 | Reprise avant validation | Une seule récompense exceptionnelle au maximum validée | [Q180](../03-progression/rewards-rarity-and-ascension.md) |
| T-181-01 | Affichage des cinq rangs | Blanc/bleu/rouge/violet/or associés aux bons noms | [Q181](../03-progression/rewards-rarity-and-ascension.md) |
| T-181-02 | Carte peu commune | Bleu, non rare ; carte rare rouge | [Q181](../03-progression/rewards-rarity-and-ascension.md) |
| T-181-03 | Pool de rareté | Aucun niveau Mythique | [Q181](../03-progression/rewards-rarity-and-ascension.md) |
| T-181-04 | Affichage daltonisme | Libellé/motif distinct au-delà du code couleur | [Q181](../03-progression/rewards-rarity-and-ascension.md) |
| T-182-01 | Fin ascension avec artefacts | Artefacts de tentative non conservés à la prochaine | [Q182](../03-progression/rewards-rarity-and-ascension.md) |
| T-182-02 | Tour terminée et déblocage | Nouvel élément éligible au draft des ascensions suivantes | [Q182](../03-progression/rewards-rarity-and-ascension.md) |
| T-182-03 | Nouvelle ascension après déblocage | Nouvel élément pas attribué automatiquement | [Q182](../03-progression/rewards-rarity-and-ascension.md) |
| T-182-04 | Sauvegarde des déblocages | Déblocages persistants à travers tentatives | [Q182](../03-progression/rewards-rarity-and-ascension.md) |
| T-183-01 | Inventaire rempli | Acquisition supplémentaire impose libération/remplacement | [Q183](../03-progression/rewards-rarity-and-ascension.md) |
| T-183-02 | Récompense augmentant capacité | Emplacement supplémentaire disponible pendant ascension | [Q183](../03-progression/rewards-rarity-and-ascension.md) |
| T-183-03 | Recommencer après hausse capacité | Capacité de départ rétablie | [Q183](../03-progression/rewards-rarity-and-ascension.md) |
| T-183-04 | UI montre capacité | Occupés/disponibles exacts sans présumer valeur initiale | [Q183](../03-progression/rewards-rarity-and-ascension.md) |
| T-184-01 | Offre caractéristique | Bonus choisi appliqué durant tentative | [Q184](../03-progression/rewards-rarity-and-ascension.md) |
| T-184-02 | Offre capacité | Nouvelle capacité ou évolution appliquée selon moteur | [Q184](../03-progression/rewards-rarity-and-ascension.md) |
| T-184-03 | Fin tentative | Améliorations temporaires réinitialisées | [Q184](../03-progression/rewards-rarity-and-ascension.md) |
| T-184-04 | Déblocages permanents existants | Déblocages Q182 restent, mais bonus Q184 disparaissent | [Q184](../03-progression/rewards-rarity-and-ascension.md) |

**État** : tous les tests v1.9 ci-dessus sont **documentaires, non exécutés** ; ne pas les annoncer comme réussis. Les tests de probabilités, des seuils numériques d’EXP et des capacités initiales ne sont pas spécifiés tant que ces paramètres restent ouverts.


## Consolidation v2.0 — Tests d’acceptation Q185–Q194 (spécifiés, NON exécutés)

| ID | Scénario | Résultat attendu | Référence |
|---|---|---|---|
| T-185-01 | Acquisition d’un bonus de PV via arbre | Les PV du héros augmentent selon le nœud et le bonus subsiste à la prochaine ascension. | [Q185](../03-progression/hero-sphere-and-skill-tree.md) |
| T-185-02 | Échec après investissement dans le sphérier | Le nœud permanent reste acquis ; le deck et les artefacts de tentative sont perdus. | [Q185](../03-progression/hero-sphere-and-skill-tree.md) |
| T-185-03 | Bonus feu permanent et amélioration temporaire de boss | Les deux bonus suivent leurs sources ; seul celui du sphérier persiste. | [Q185](../03-progression/hero-sphere-and-skill-tree.md) |
| T-185-04 | Début d’une nouvelle ascension | Aucun bonus du sphérier n’est perdu ni doublé. | [Q185](../03-progression/hero-sphere-and-skill-tree.md) |
| T-186-01 | Gain d’EXP sur victoire | Le cumul permanent augmente exactement une fois. | [Q186](../03-progression/hero-sphere-and-skill-tree.md) |
| T-186-02 | Montée de niveau | Le nombre paramétré de points est crédité une fois. | [Q186](../03-progression/hero-sphere-and-skill-tree.md) |
| T-186-03 | Défaite avec points non dépensés | EXP, niveau et points non dépensés persistent. | [Q186](../03-progression/hero-sphere-and-skill-tree.md) |
| T-186-04 | Reprise après sauvegarde au seuil de niveau | Aucun second crédit de points de niveau. | [Q186](../03-progression/hero-sphere-and-skill-tree.md) |
| T-187-01 | Tentative sur nœud non connecté | Déblocage refusé avec prérequis explicite. | [Q187](../03-progression/hero-sphere-and-skill-tree.md) |
| T-187-02 | Déblocage d’un nœud accessible adjacent | Nœud acquis et successeurs accessibles selon leurs prérequis. | [Q187](../03-progression/hero-sphere-and-skill-tree.md) |
| T-187-03 | Passerelle interbranche activée | Nouvel itinéraire de progression disponible sans contourner les prérequis. | [Q187](../03-progression/hero-sphere-and-skill-tree.md) |
| T-187-04 | Affichage de trois états de nœuds | Acquis, accessible et verrouillé distincts et corrects. | [Q187](../03-progression/hero-sphere-and-skill-tree.md) |
| T-188-01 | Nœuds de coûts distincts | Chaque nœud débite son coût configuré. | [Q188](../03-progression/hero-sphere-and-skill-tree.md) |
| T-188-02 | Fonds insuffisants | Aucune acquisition ni solde négatif. | [Q188](../03-progression/hero-sphere-and-skill-tree.md) |
| T-188-03 | Compétence avancée sans prérequis | Coût disponible ne suffit pas à contourner le prérequis. | [Q188](../03-progression/hero-sphere-and-skill-tree.md) |
| T-188-04 | Double confirmation du même nœud | Déblocage et débit effectués une seule fois. | [Q188](../03-progression/hero-sphere-and-skill-tree.md) |
| T-189-01 | Reset hors ascension confirmé | Nœuds libérés, total des points restitué sans coût. | [Q189](../03-progression/hero-sphere-and-skill-tree.md) |
| T-189-02 | Reset pendant ascension | Action impossible. | [Q189](../03-progression/hero-sphere-and-skill-tree.md) |
| T-189-03 | Réallocation après reset | Nœuds acquis selon nouveaux chemins et coûts ; capital total constant. | [Q189](../03-progression/hero-sphere-and-skill-tree.md) |
| T-189-04 | Reset puis rechargement | Niveau, EXP et points comptabilisés sans création ou perte. | [Q189](../03-progression/hero-sphere-and-skill-tree.md) |
| T-190-01 | Nouveau profil de joueur | Plusieurs tours de difficultés distinctes immédiatement accessibles. | [Q190](../03-progression/towers-merchants-and-unlocks.md) |
| T-190-02 | Tour spéciale non déverrouillée | Accès refusé, prérequis de tour explicite. | [Q190](../03-progression/towers-merchants-and-unlocks.md) |
| T-190-03 | Fin des tours requises | Tour spéciale débloquée de manière persistante. | [Q190](../03-progression/towers-merchants-and-unlocks.md) |
| T-190-04 | Héros sous niveau conseillé | Une tour accessible autorise l’entrée quand même. | [Q190](../03-progression/towers-merchants-and-unlocks.md) |
| T-191-01 | Première victoire sur une tour | Déblocages uniques et récompenses répétables prévus crédités. | [Q191](../03-progression/towers-merchants-and-unlocks.md) |
| T-191-02 | Seconde victoire même tour | Aucun duplicata de déblocage unique ; récompenses répétables accordées. | [Q191](../03-progression/towers-merchants-and-unlocks.md) |
| T-191-03 | Rechargement après première victoire | Flag de première victoire préservé, pas de double gain. | [Q191](../03-progression/towers-merchants-and-unlocks.md) |
| T-191-04 | Déblocage de carte par fin de tour | Carte devient éligible au draft, pas ajoutée automatiquement au deck initial. | [Q191](../03-progression/towers-merchants-and-unlocks.md) |
| T-192-01 | Héros niveau faible entre dans une tour | Ennemis ont la difficulté canonique de la tour. | [Q192](../03-progression/towers-merchants-and-unlocks.md) |
| T-192-02 | Héros niveau élevé entre dans la même tour | Ennemis gardent exactement les mêmes caractéristiques de difficulté. | [Q192](../03-progression/towers-merchants-and-unlocks.md) |
| T-192-03 | Répétition d’une tour facile à haut niveau | Récompenses répétables deviennent moins intéressantes selon barème configurable. | [Q192](../03-progression/towers-merchants-and-unlocks.md) |
| T-192-04 | Première victoire à haut niveau | Déblocage unique inchangé, pas soumis à la décote d’EXP. | [Q192](../03-progression/towers-merchants-and-unlocks.md) |
| T-193-01 | Accomplissement global débloqué | Contenu correspondant devient éligible aux futures propositions. | [Q193](../03-progression/towers-merchants-and-unlocks.md) |
| T-193-02 | Visite d’un marchand de tour exclusive | Carte exclusive est disponible à l’achat dans la tour prévue selon les règles de stock. | [Q193](../03-progression/towers-merchants-and-unlocks.md) |
| T-193-03 | Visite d’un marchand d’une autre tour | Exclusivité non offerte à l’achat par ce marchand avant déblocage selon règles d’offre. | [Q193](../03-progression/towers-merchants-and-unlocks.md) |
| T-193-04 | Offre d’une carte rare | Rare est rouge, peu commune bleue ; code couleur respecté. | [Q193](../03-progression/towers-merchants-and-unlocks.md) |
| T-194-01 | Carte choisie parmi trois | Carte obtenue et son identité enregistrée immédiatement dans le catalogue permanent ; cartes refusées non débloquées. | [Q194](../03-progression/towers-merchants-and-unlocks.md) |
| T-194-02 | Carte exclusive achetée puis ascension perdue | Copie de tentative perdue ; identité reste débloquée et éligible aux futurs drafts. | [Q194](../03-progression/towers-merchants-and-unlocks.md) |
| T-194-03 | Carte seulement inspectée ou proposée | Aucun déblocage de cette carte. | [Q194](../03-progression/towers-merchants-and-unlocks.md) |
| T-194-04 | Achat répété / rechargement / double clic | Une seule attribution d’achat et un seul déblocage idempotent ; carte non garantie au prochain draft. | [Q194](../03-progression/towers-merchants-and-unlocks.md) |

**Statut :** 40 scénarios ajoutés à v2.0 ; **non exécutés**. Les barèmes EXP, tailles de stocks, coût des compétences et taux de draft restent ouverts.


## Consolidation v2.1 — Tests d’acceptation Q195–Q204 (SPÉCIFIÉS, NON EXÉCUTÉS)

| ID | Scénario | Résultat attendu | Référence |
|---|---|---|---|
| T-195-01 | Tirage marchand dans une tour donnée | Stock généré dans le pool de la tour, mélange génériques/exclusives éligibles. | [Q195](../03-progression/merchant-stock-and-deck-limits.md) |
| T-195-02 | Exclusivité absente d’un tirage | Aucune obligation de présenter une carte exclusive à chaque visite. | [Q195](../03-progression/merchant-stock-and-deck-limits.md) |
| T-195-03 | Exclusivité autre tour | Impossible de trouver dans ce commerce une carte exclusive d’une autre tour non éligible. | [Q195](../03-progression/merchant-stock-and-deck-limits.md) |
| T-195-04 | Carte exclusive achetée | Carte utilisable pendant le run et débloquée pour les drafts futurs (Q194). | [Q195](../03-progression/merchant-stock-and-deck-limits.md) |
| T-196-01 | Cartes de raretés différentes | Références tarifaires correspondantes, cinq couleurs Q181 et prix affichés. | [Q196](../03-progression/merchant-stock-and-deck-limits.md) |
| T-196-02 | Ajustement individuel | Une carte peut différer de sa référence selon son paramétrage sans prix RNG arbitraire. | [Q196](../03-progression/merchant-stock-and-deck-limits.md) |
| T-196-03 | État de collection | UI distingue clairement carte débloquée ou non. | [Q196](../03-progression/merchant-stock-and-deck-limits.md) |
| T-196-04 | Confirmation achat | Débit exact du prix affiché, aucune acquisition en cas de fonds insuffisants. | [Q196](../03-progression/merchant-stock-and-deck-limits.md) |
| T-197-01 | Défaite avec monnaie restante | Solde de run supprimé ; aucun transfert au run suivant. | [Q197](../03-progression/merchant-stock-and-deck-limits.md) |
| T-197-02 | Victoire avec monnaie restante | Solde de run supprimé également. | [Q197](../03-progression/merchant-stock-and-deck-limits.md) |
| T-197-03 | Achat carte puis défaite | Monnaie effacée mais identité de carte débloquée pour drafts futurs. | [Q197](../03-progression/merchant-stock-and-deck-limits.md) |
| T-197-04 | Nouvelle ascension | Solde initial configuré et progression permanente EXP/sphérier intacte. | [Q197](../03-progression/merchant-stock-and-deck-limits.md) |
| T-198-01 | Renouvellements successifs | Prochain coût strictement croissant pour ce marchand. | [Q198](../03-progression/merchant-stock-and-deck-limits.md) |
| T-198-02 | Fonds insuffisants | Aucun débit, nouveau stock ni incrément de compteur. | [Q198](../03-progression/merchant-stock-and-deck-limits.md) |
| T-198-03 | Renouvellement conforme au pool | Tirage respecte les exclusivités et raretés ; rien n’est garanti. | [Q198](../03-progression/merchant-stock-and-deck-limits.md) |
| T-198-04 | Renouvellement rejoué après sauvegarde | Stock, compteur et débit appliqués une seule fois. | [Q198](../03-progression/merchant-stock-and-deck-limits.md) |
| T-199-01 | Deux marchands différents | Renouvellement A ne modifie pas le compteur ni le coût du marchand B. | [Q199](../03-progression/merchant-stock-and-deck-limits.md) |
| T-199-02 | Quitter/rentrer même commerce | Même stock et même coût progressif. | [Q199](../03-progression/merchant-stock-and-deck-limits.md) |
| T-199-03 | Sauvegarde/reprise même tentative | Stocks et compteurs identiques avant et après reprise. | [Q199](../03-progression/merchant-stock-and-deck-limits.md) |
| T-199-04 | Nouvelle tentative | Compteurs réinitialisés pour les nouvelles instances de marchands. | [Q199](../03-progression/merchant-stock-and-deck-limits.md) |
| T-200-01 | Achat dans emplacement | Une seule carte attribuée, emplacement vidé, autres offres inchangées. | [Q200](../03-progression/merchant-stock-and-deck-limits.md) |
| T-200-02 | Renouvellement après achat | Carte achetée peut réapparaître si elle reste éligible et sous plafond. | [Q200](../03-progression/merchant-stock-and-deck-limits.md) |
| T-200-03 | Second achat même carte | Deux exemplaires dans le deck, une seule identité débloquée durablement. | [Q200](../03-progression/merchant-stock-and-deck-limits.md) |
| T-200-04 | Double clic achat | Un achat, un débit et un exemplaire attribués une fois. | [Q200](../03-progression/merchant-stock-and-deck-limits.md) |
| T-201-01 | Quatre copies Commune | Quatre autorisées, cinquième refusée. | [Q201](../03-progression/merchant-stock-and-deck-limits.md) |
| T-201-02 | Quatre copies Légendaire | Même plafond de quatre, pas de règle unique légendaire. | [Q201](../03-progression/merchant-stock-and-deck-limits.md) |
| T-201-03 | Copie temporaire en combat | Ne modifie pas le compteur de copies du deck d’ascension. | [Q201](../03-progression/merchant-stock-and-deck-limits.md) |
| T-201-04 | Carte déjà débloquée achetée de nouveau | Pas de duplicata dans le catalogue permanent ; plafond du deck respecté. | [Q201](../03-progression/merchant-stock-and-deck-limits.md) |
| T-202-01 | Génération magasin avec carte à 4 | Carte exclue avant tirage. | [Q202](../03-progression/merchant-stock-and-deck-limits.md) |
| T-202-02 | Renouvellement magasin à 4 | Carte exclue également au renouvellement. | [Q202](../03-progression/merchant-stock-and-deck-limits.md) |
| T-202-03 | Pool magasin trop petit | Moins d’offres, aucune offre impossible ou hors-tour. | [Q202](../03-progression/merchant-stock-and-deck-limits.md) |
| T-202-04 | Offre affichée devenue plafonnée | Validation rejette sans débit ni nouvelle copie. | [Q202](../03-progression/merchant-stock-and-deck-limits.md) |
| T-203-01 | Trois cartes éligibles ou plus | Trois propositions valides selon Q177. | [Q203](../03-progression/merchant-stock-and-deck-limits.md) |
| T-203-02 | Une ou deux cartes éligibles | Seulement une ou deux propositions, aucune carte invalidée. | [Q203](../03-progression/merchant-stock-and-deck-limits.md) |
| T-203-03 | Refus de propositions | Compensation Q178 disponible même avec moins de trois cartes. | [Q203](../03-progression/merchant-stock-and-deck-limits.md) |
| T-203-04 | Réévaluation à l’engagement | Aucune cinquième copie admise après changements ou reprise. | [Q203](../03-progression/merchant-stock-and-deck-limits.md) |
| T-204-01 | Zéro carte éligible | Compensation Q178 automatique sans écran de sélection vide. | [Q204](../03-progression/merchant-stock-and-deck-limits.md) |
| T-204-02 | Récompense automatique parallèle | Monnaie et EXP Q179 accordées en plus de la compensation. | [Q204](../03-progression/merchant-stock-and-deck-limits.md) |
| T-204-03 | Reprise et retry au point de récompense | Compensation enregistrée exactement une fois. | [Q204](../03-progression/merchant-stock-and-deck-limits.md) |
| T-204-04 | Aucun pool éligible | Pas d’extension cachée de pools ni de carte débloquée par la compensation. | [Q204](../03-progression/merchant-stock-and-deck-limits.md) |

**Statut :** 40 scénarios nouveaux documentés et **non exécutés** sur un jeu. Les paramètres numériques restent à arbitrer.

## Consolidation v2.2 — tests d’acceptation Q205–Q214

> **40 scénarios nouveaux, spécifiés et NON EXÉCUTÉS.** Les tests ci-dessous s’ajoutent aux tests précédents. Ils respectent les prérequis ouverts, et emploient les valeurs initiales 40/40 validées en Q208.

| ID | Cas | Résultat attendu | Référence |
|---|---|---|---|
| T-205-01 | Retrait réversible | Une copie acquise est déplacée du deck actif à la réserve, sans destruction ni perte de déblocage. | [Q205](../03-progression/deck-reserve-and-capacity.md) |
| T-205-02 | Réintégration | La même instance peut revenir de réserve au deck actif sans nouvelle acquisition. | [Q205](../03-progression/deck-reserve-and-capacity.md) |
| T-205-03 | Fin de run | Deck actif et réserve réinitialisés ; identité de carte reste déverrouillée pour le draft futur. | [Q205](../03-progression/deck-reserve-and-capacity.md) |
| T-205-04 | Copies multiples | Transfert de deux copies conserve le total possédé et les identifiants des instances. | [Q205](../03-progression/deck-reserve-and-capacity.md) |
| T-206-01 | Entre combats | Transfert gratuit sans marchand, sauvegarde et affichage de la répartition à jour. | [Q206](../03-progression/deck-reserve-and-capacity.md) |
| T-206-02 | Combat démarré | Action manuelle de transfert refusée sans modification d’état. | [Q206](../03-progression/deck-reserve-and-capacity.md) |
| T-206-03 | Sauvegarde/reprise | Deck et réserve reconstruits exactement après reprise pendant une ascension. | [Q206](../03-progression/deck-reserve-and-capacity.md) |
| T-206-04 | Composition invalide avant combat | Préparation éditable, mais lancement de combat bloqué tant que taille hors bornes. | [Q206](../03-progression/deck-reserve-and-capacity.md) |
| T-207-01 | Plafond réparti 2+2 | Deux copies actives et deux en réserve : achat d’une cinquième refusé. | [Q207](../03-progression/deck-reserve-and-capacity.md) |
| T-207-02 | Déplacer en réserve | Déplacer 2 copies du deck à la réserve ne rend pas la carte éligible à un nouveau draft/achat. | [Q207](../03-progression/deck-reserve-and-capacity.md) |
| T-207-03 | Quatre légendaires | Même plafond de quatre pour une identité légendaire, sans unique par rareté. | [Q207](../03-progression/deck-reserve-and-capacity.md) |
| T-207-04 | Copy temporaire | Une copie créée exclusivement en combat ne change pas le compteur d’acquisition deck+réserve. | [Q207](../03-progression/deck-reserve-and-capacity.md) |
| T-208-01 | Départ 40/40 | Un deck actif de 40 cartes respecte la taille initiale ; 39 et 41 ne peuvent commencer un combat sans bonus. | [Q208](../03-progression/deck-reserve-and-capacity.md) |
| T-208-02 | Minimum abaissé | Minimum effectif à 35, deck 35 : lancement autorisé ; fatigue ordinaire inchangée. | [Q208](../03-progression/deck-reserve-and-capacity.md) |
| T-208-03 | Maximum augmenté | Maximum effectif à 45, deck 45 : lancement autorisé, aucun transfert auto. | [Q208](../03-progression/deck-reserve-and-capacity.md) |
| T-208-04 | Transfert hors bornes | Cartes non détruites ; deck invalide ne peut pas lancer de combat avant correction. | [Q208](../03-progression/deck-reserve-and-capacity.md) |
| T-209-01 | Sphérier permanent | Réduction du minimum par nœud de sphérier persiste entre ascensions et apparaît dans les bornes. | [Q209](../03-progression/deck-reserve-and-capacity.md) |
| T-209-02 | Bonus temporaire | Bonus de maximum en run s’ajoute au sphérier selon les bornes effectives. | [Q209](../03-progression/deck-reserve-and-capacity.md) |
| T-209-03 | Expiration bonus | Une expiration rend le deck potentiellement invalide, sans supprimer silencieusement d’exemplaire. | [Q209](../03-progression/deck-reserve-and-capacity.md) |
| T-209-04 | Nouvelle ascension | Bonus temporaire perdu, bonus du sphérier conservé ; capacité revalidée. | [Q209](../03-progression/deck-reserve-and-capacity.md) |
| T-210-01 | Multi-pioche 2/5 | Deux cartes disponibles, cinq pioches : fatigue 1, 2, 3 PV après les deux pioches, réactions FIFO entre. | [Q210](../01-combat/deck-search-and-fatigue-v22.md) |
| T-210-02 | Pas de recyclage | Pioche vide avec cartes en défausse : fatigue, pas de remélange automatique Q43. | [Q210](../01-combat/deck-search-and-fatigue-v22.md) |
| T-210-03 | Réinsertion | Après fatigue 1, une carte est réinsérée puis piochée : prochaine pioche impossible inflige 2 PV. | [Q210](../01-combat/deck-search-and-fatigue-v22.md) |
| T-210-04 | Nature et interruption | Fatigue directe ignore bouclier et ne déclenche pas ON_DAMAGE_TAKEN ; mort interrompt les pioches suivantes. | [Q210](../01-combat/deck-search-and-fatigue-v22.md) |
| T-211-01 | Recherche ciblée | Choix manuel d’une instance valide selon critères type/élément/coût et zone pioche. | [Q211](../01-combat/deck-search-and-fatigue-v22.md) |
| T-211-02 | Recherche aléatoire | Une instance éligible sélectionnée via RNG déterministe sans ouverture de sélecteur. | [Q211](../01-combat/deck-search-and-fatigue-v22.md) |
| T-211-03 | Zones exclues | Copie dans main/défausse/réserve non trouvée par recherche limitée à la pioche. | [Q211](../01-combat/deck-search-and-fatigue-v22.md) |
| T-211-04 | Aucune carte éligible | Résolution sans résultat ni fatigue et sans sélection artificielle. | [Q211](../01-combat/deck-search-and-fatigue-v22.md) |
| T-212-01 | Destination main | Carte recherchée déplacée en main, sans événement de pioche sauf texte explicite ; limite main respectée. | [Q212](../01-combat/deck-search-and-fatigue-v22.md) |
| T-212-02 | Destination sommet | Carte ciblée placée au sommet, ordre relatif des autres copies conservé sans instruction de mélange. | [Q212](../01-combat/deck-search-and-fatigue-v22.md) |
| T-212-03 | Mélange demandé | Mélange RNG déterministe conforme à l’instruction et reproductible après replay. | [Q212](../01-combat/deck-search-and-fatigue-v22.md) |
| T-212-04 | Recherche manquée multi-effet | Aucune fatigue ; composante indépendante se résout ; pas de mélange si non ordonné. | [Q212](../01-combat/deck-search-and-fatigue-v22.md) |
| T-213-01 | Filtre visibilité | Recherche ciblée montre toutes et seulement les instances éligibles, inspectables. | [Q213](../01-combat/deck-search-and-fatigue-v22.md) |
| T-213-02 | Ordre masqué | Affichage des cartes éligibles ne permet pas de reconstruire l’ordre réel de la pioche. | [Q213](../01-combat/deck-search-and-fatigue-v22.md) |
| T-213-03 | Recherche aléatoire | Pas de fenêtre de choix, résultat exposé seulement selon règles de visibilité. | [Q213](../01-combat/deck-search-and-fatigue-v22.md) |
| T-213-04 | Journal confidentialité | Journal et historique ne révèlent ni cartes non éligibles ni ordre caché. | [Q213](../01-combat/deck-search-and-fatigue-v22.md) |
| T-214-01 | Trois copies identiques | Trois instances éligibles de même carte affichées dans trois entrées séparées, jamais ×3. | [Q214](../01-combat/deck-search-and-fatigue-v22.md) |
| T-214-02 | Choix instance | Le joueur clique une instance précise ; exactement cette instance est transférée. | [Q214](../01-combat/deck-search-and-fatigue-v22.md) |
| T-214-03 | Copies modifiées | Copies d’état différent restent séparées et inspectables, identités stables. | [Q214](../01-combat/deck-search-and-fatigue-v22.md) |
| T-214-04 | Instance devenue invalide | Validation rejette la cible disparue sans sélectionner un autre exemplaire et sans RNG de départage. | [Q214](../01-combat/deck-search-and-fatigue-v22.md) |

**Non-régression obligatoire :** remplacer dans la suite Q41 les assertions de « −1 PV à chaque pioche impossible » par `−1, −2, −3… PV` dans un même combat. Pour Q201–Q203, filtrer sur **deck actif + réserve** ; pour Q213, ne jamais fusionner les exemplaires identiques (Q214-A).

## Tests de conformité Q215–Q224 — v2.3 (40 scénarios, **spécifiés et non exécutés**)

| Test | Décision | Entrée | Résultat attendu | Source |
|---|---|---|---|---|
| T-215-01 | Allocation standard | Débuter ascension sans bonus de taille. | 20 cartes de base + deux boosters de 15, soit 50 instances ; 40 actives/10 réserve après constitution. | [Q215](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-215-02 | Collection non directement utilisable | Une carte est débloquée mais absente du socle et des deux boosters. | Impossible de l’ajouter directement au deck initial, malgré son déblocage. | [Q215](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-215-03 | Copies non permanentes | Achever une ascension, puis en commencer une nouvelle. | Les 50 instances de run ne persistent pas ; les déblocages permanents demeurent. | [Q215](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-215-04 | Bornes améliorées | Sphérier modifie le minimum et/ou maximum avant ascension. | Validation avec bornes effectives ; aucune répartition 40/10 inventée si elle est incompatible. | [Q215](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-216-01 | Proposition immédiate | Deux boosters ouverts ; déclencher l’assistant. | Proposition de deck/réserve légale sans choisir manuellement 40 cartes. | [Q216](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-216-02 | Ajustement facultatif | Modifier librement la proposition avant le combat. | Instances conservées et transfert gratuit ; taille vérifiée au démarrage. | [Q216](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-216-03 | Aucune inspection obligatoire | Joueur passe animations et n’ouvre aucun inspecteur. | Peut commencer dès que la composition automatique est légale. | [Q216](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-216-04 | Proposition invalide | Un état partiellement modifié ne satisfait pas minDeckSize. | Démarrage du combat bloqué, édition de préparation autorisée. | [Q216](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-217-01 | Bornes de base | Héros sans bonus de capacité. | minDeckSize=maxDeckSize=40, pas 30 ni 35. | [Q217](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-217-02 | Répartition standard | 20 + 15 + 15 exemplaires attribués. | 40 deck actif et 10 réserve après composition. | [Q217](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-217-03 | Réduction min sphérier | Compétence permanente abaisse minDeckSize. | Valeur effective appliquée, sans changer la base enregistrée 40. | [Q217](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-217-04 | Hausse max run | Bonus temporaire augmente maxDeckSize. | Max effectif augmenté, retour à la base après fin run ; aucune destruction de copies. | [Q217](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-218-01 | Pool de rareté | Génération de booster avec plusieurs raretés débloquées. | Tirage pondéré par rareté, et non sélection égale ou quota fixe. | [Q218](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-218-02 | Aucune garantie passive | Aucun nœud de garantie actif. | Pas de carte Rare+ systématiquement imposée. | [Q218](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-218-03 | Garantie par booster | Compétence garantissant Rare+ et ≥1 carte éligible Rare+. | Booster 1 et booster 2 contiennent chacun au moins une Rare+, si faisable selon les plafonds. | [Q218](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-218-04 | Rareté inaccessible | Garantie Rare+ mais aucun exemplaire Rare+ déverrouillé/éligible. | Aucune carte verrouillée créée ; renvoi vers assouplissement Q219. | [Q218](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-219-01 | Plafond trans-packs | Socle contient trois copies X ; booster 1 ajoute X. | Booster 2 ne peut plus contenir X ; total X=4. | [Q219](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-219-02 | Assouplir garantie | Garantie Rare+, seules cartes Peu communes éligibles. | Dégradation vers meilleure rareté éligible, sans ajout de carte verrouillée. | [Q219](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-219-03 | Pool structurellement impossible | Moins de capacité totale de 50 copies sous cap de quatre. | Détection explicite ; pas de boucle infinie ni violation ; secours **À DÉFINIR** avant implémentation complète. | [Q219](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-219-04 | RNG reproductible | Même seed, pool éligible, socle et état sphérier. | Mêmes exemplaires générés dans le même ordre, sauvegarde/reprise cohérente. | [Q219](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-220-01 | Ordre des boosters | Démarrer le flux de révélation. | Booster 1 avant booster 2, jamais simultanés. | [Q220](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-220-02 | Révélation groupée | Ouvrir un booster de 15 cartes. | Affichage des 15 cartes en une seule révélation, pas 15 clics obligatoires. | [Q220](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-220-03 | Passer animation | Passer l’animation du booster 1 et poursuivre. | Booster 2 est accessible ; résultats tirés invariants. | [Q220](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-220-04 | Rare feedback | Carte de rareté élevée tirée dans un booster. | Feedback visuel distinctif et lisible sans obligation de visionner l’animation. | [Q220](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-221-01 | Rareté lisible | Afficher les cartes des boosters. | Couleurs conformes Q181 pour les cinq niveaux ; pas de mythique. | [Q221](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-221-02 | Filtres optionnels | Filtrer type puis rareté puis synergie. | Visibilité filtrée ; sélection/possession des cartes inchangées. | [Q221](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-221-03 | Transfert rapide | Déplacer une carte de deck vers réserve puis inversement. | Conserve identité de copie ; plafonds et taille revalidés. | [Q221](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-221-04 | Libellé de découverte | Carte déjà débloquée présente dans booster. | Identifiée comme tirage du run, sans faux statut de nouveau déblocage permanent. | [Q221](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-222-01 | Spécialisation dominante | Héros feu ; boosters avec cartes feu et cartes hors élément. | Assistant privilégie feu parmi cartes disponibles selon compatibilité du sphérier. | [Q222](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-222-02 | Rareté non dominante | Légendaire hors synergie et commune utile au héros. | La légendaire n’est pas obligatoirement sélectionnée pour sa seule rareté. | [Q222](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-222-03 | Aucune synergie | Héros polyvalent sans orientation dominante. | Assistant utilise critères subsidiaires de cohérence, sans inventer de cartes. | [Q222](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-222-04 | Déterminisme | Même sphérier, pool d’instances et paramètres. | Même composition et même répartition deck/réserve. | [Q222](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-223-01 | Base non obligatoire | 30 cartes de boosters et 20 de base disponibles. | Un deck actif de 40 peut contenir moins de 20 cartes de base. | [Q223](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-223-02 | Remplacer base | Déplacer une base vers réserve et booster vers deck. | Transfert permis si composition finale valide. | [Q223](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-223-03 | Conserver identités | Une carte de base entre et sort du deck actif. | Même instance et même décompte global ; aucune duplication. | [Q223](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-223-04 | Limiter au pool | Une carte débloquée n’a pas été attribuée parmi les 50. | Elle ne peut pas être insérée manuellement avant le combat. | [Q223](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-224-01 | Socle fixe débutant | Aucun nœud de variante acquis. | 20 exemplaires de base selon liste fixe de départ. | [Q224](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-224-02 | Substitution autorisée | Nœud de variante du sphérier acquis avant ascension. | Remplacement(s) permis dans le socle attribué selon configuration du nœud. | [Q224](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-224-03 | Pas de catalogue libre | Nœud de variante acquis ; carte non autorisée par le nœud. | Le joueur ne peut pas l’utiliser comme remplacement arbitraire du socle. | [Q224](../03-progression/ascension-start-boosters-and-autobuild.md) |
| T-224-04 | Socle et réserve distincts | Variante de base attribuée puis envoyée en réserve. | La réserve l’accepte (Q223) ; aucune base obligatoire dans le deck actif. | [Q224](../03-progression/ascension-start-boosters-and-autobuild.md) |

**Non-régression v2.3** : Q207 plafond de **quatre copies** deck+réserve incluant le socle et les deux boosters ; Q208/Q217 min/max standard 40/40 ; Q209 compétences permanentes et temporaires ; Q211–Q214 recherches pendant combat indépendantes de la préparation ; Q218 garantie Rare+ **seulement si compétence active et éligibilité**, sinon assouplissement Q219 ; Q220 ouverture **séquentielle** ; Q222 spécialisation du héros **prioritaire**, et non optimisation multicritère dominante ; Q223 **aucune base imposée dans le deck** ; Q224 variantes du socle **uniquement via compétences permanentes autorisées**.

**Blocage de conception ouvert** : le mécanisme exact Q219 de secours pour un pool incapable de fournir 50 copies légales ne peut pas avoir de test de résultat positif définitif avant arbitrage. `T-219-03` porte uniquement sur la détection et l'absence de violation.


## Tests de conformité v2.4 — Q225 à Q234

> **40 scénarios nouveaux spécifiés, non exécutés.** Les tests de disponibilité de contenus exigent un jeu de données MVP réel ; ne pas interpréter leur rédaction comme une preuve de faisabilité. Référence normative : [catalogue et peuples v2.4](../03-progression/mvp-card-catalog-and-tribes.md).

| ID | Sujet | État initial / action | Résultat attendu |
|---|---|---|---|
| T-225-01 | Départ nouveau profil | Profil neuf avec catalogue fondamental configuré | Le pool débloqué rend possible 20+15+15 copies légales. |
| T-225-02 | Secours sans carte verrouillée | Pool pondéré épuisé, alternatives fondamentales débloquées | Les slots restants utilisent des copies fondamentales éligibles selon une règle déterministe. |
| T-225-03 | Plafond familial sous secours | Famille déjà à quatre copies dans socle et boosters | Aucune cinquième copie n’est tirée ou attribuée. |
| T-225-04 | Pool mathématiquement impossible | Moins de capacités légales que 50 exemplaires | Erreur de validation de contenu/configuration détectée sans boucle infinie ni déblocage artificiel. |
| T-226-01 | Substitution fixe | Même nœud actif et même socle sur deux ascensions | Les mêmes emplacements reçoivent les mêmes variantes. |
| T-226-02 | Sans nœud | Sphérier ne débloque aucune variante | Socle original inchangé, 20 copies. |
| T-226-03 | Réinitialisation sphérier | Réinitialiser le sphérier entre deux ascensions | Le socle de l’ascension suivante reflète les nœuds actifs, sans modifier l’ascension antérieure. |
| T-226-04 | Conflit non défini | Deux nœuds tentent de modifier le même emplacement sans priorité | Validation de contenu refuse l’ambiguïté ou requiert règle explicite ; pas de choix aléatoire silencieux. |
| T-227-01 | Quatre versions mélangées | 2 originales + 1 Feu + 1 Glace d’une même famille | Plafond familial atteint ; une cinquième variante est inéligible. |
| T-227-02 | Deck et réserve | 2 copies actives et 2 en réserve de même famille | Le compteur familial vaut 4. |
| T-227-03 | Familles différentes | Deux familles indépendantes avec copies respectives | Les plafonds sont appliqués séparément. |
| T-227-04 | Identifiants d’instance | Deux copies de la même variante | Chaque copie conserve son identité distincte lors des transferts. |
| T-228-01 | Socle amélioré | Nœud actif, exemplaire d’origine socle | La variante améliorée est attribuée. |
| T-228-02 | Booster non amélioré | Même famille tirée dans booster, nœud actif | La copie du booster conserve sa définition non améliorée. |
| T-228-03 | Déplacement vers réserve | Déplacer copie de socle améliorée du deck à la réserve | La version améliorée et l’origine sont conservées. |
| T-228-04 | Acquisition après combat | Récompense d’une famille améliorée dans le socle | La copie acquise ne change pas de version en raison du sphérier. |
| T-229-01 | Filtre de booster | Variante du sphérier existante et carte ordinaire de même famille débloquée | La variante n’est jamais candidate dans les boosters. |
| T-229-02 | Catalogue limité | Seules variantes du sphérier existent dans une famille du socle | Le booster ne tire pas ces variantes comme cartes indépendantes. |
| T-229-03 | Compte familial | Socle contient deux variantes et booster propose deux copies ordinaires | Quatre copies au total acceptées ; aucune cinquième. |
| T-229-04 | Secours strict | Pool de booster insuffisant avec variantes du sphérier non éligibles | Le secours n’introduit aucune variante réservée au socle. |
| T-230-01 | Budget calculé | 40 fondamentales, 30 variantes, 100 indépendantes | Le nombre de définitions est 170, distinct des copies de préparation. |
| T-230-02 | Socle de 20 | Catalogue fondamental contient 40 définitions | Une ascension n’attribue que 20 copies de socle selon ses règles. |
| T-230-03 | Cartes non débloquées | Catalogue indépendant de 100, profil au début | Toutes les 100 définitions ne sont pas automatiquement dans le pool débloqué. |
| T-230-04 | Famille et variante | Une famille possède trois variantes additionnelles | Quatre définitions peuvent partager une famille et un plafond commun de quatre copies. |
| T-231-01 | Trois groupes | Inventaire de 100 cartes indépendantes | Les cartes se classent en neutre, élémentaire ou hybride/avancé. |
| T-231-02 | Quotas non forcés | Répartition différente de 33/50/17, mais catalogue équilibré | La validation ne rejette pas seulement pour différence aux proportions illustratives. |
| T-231-03 | Carte hybride | Carte avec deux éléments/stratégies | La catégorie avancée/hybride peut porter plusieurs interactions. |
| T-231-04 | Compatibilité rareté | Cartes de toutes les catégories avec raretés Q181 | Catégorie de design et rareté sont deux axes distincts. |
| T-232-01 | Rôle principal | Carte attaque+pioche | Un rôle principal et des rôles secondaires peuvent être indexés. |
| T-232-02 | Quotas souples | Répartition différente de 25/15/20/15/15/10 | Le suivi signale l’écart sans le traiter comme violation normative. |
| T-232-03 | Couverture utilitaire | Catalogue comprend recherche/pioche | La catégorie fonctionnelle est prise en compte en conception. |
| T-232-04 | Diversité tactique | Cartes d’un même élément avec défense et attaque | Les rôles ne sont pas conditionnés exclusivement par l’élément. |
| T-233-01 | Synergie de peuple | Créature de peuple Nain, effet ciblant les Nains | L’effet filtre selon le peuple et non uniquement selon l’élément. |
| T-233-02 | Élément transversal | Deux créatures de peuples différents avec élément Feu | Un effet Feu peut s’appliquer aux deux selon ses critères. |
| T-233-03 | Archétype multiaxe | Deck mélange peuple, élément et rôle | Les axes de classification coexistent sans exclusion arbitraire. |
| T-233-04 | Créature sans peuple majeur | Créature de type Bête/Élémentaire suivant catalogue | Le moteur n’oblige pas à appartenir à l’un des quatre peuples principaux. |
| T-234-01 | Quatre peuples MVP | Catalogue MVP validé avec quatre peuples définis | L’inventaire signale exactement quatre peuples représentés. |
| T-234-02 | Ajout futur Gobelin | Charger une définition d’extension avec peuple Gobelin | Indexation, ciblage et inspection fonctionnent sans modification du moteur. |
| T-234-03 | Ajout futur Mort-vivant | Charger une définition d’extension de type Mort-vivant | Aucune règle de combat existante n’est cassée ; cible et sauvegarde restent compatibles. |
| T-234-04 | Aucun archétype forcé | Un peuple n’a que quelques cartes dans le MVP | L’existence du peuple ne requiert pas un deck tribal complet. |

**Non-régression :** Q207 limite de quatre copies sur deck+réserve, **par famille** si variantes Q227 ; Q208/Q217 deck standard 40/40 ; Q215 20 copies de base et 30 de boosters ; Q218–Q219 raretés et garanties conditionnelles ; Q220 boosters séquentiels ; Q222 proposition spécialisée ; Q223 cartes du socle non obligatoires dans deck ; Q224–Q229 variantes **du seul socle**, boosters sans variantes du sphérier. Le budget Q230 **≈170 définitions** ne modifie pas les 50 copies de préparation.

## Tests v2.5 — Q235–Q244 (spécifiés, non exécutés)

Les tests ci-dessous réutilisent les invariants Q13–Q14, Q26–Q27, Q111–Q124 et Q159–Q164. Ils ne créent pas un nouveau solveur concurrent.

| ID | Scénario | Attendu |
|---|---|---|
| T-235-01 | Indexation des quatre peuples MVP | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-235-02 | Charge d’un type Gobelin en extension | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-235-03 | Typage Humain distinct de classe de héros | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-235-04 | Sauvegarde avec nouveau type extensible | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-236-01 | Effet ciblant un Nain allié | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-236-02 | Deck mixte Humains-Elfes fonctionne | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-236-03 | Combinaison tribale et élémentaire | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-236-04 | Carte hors tribu reste jouable | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-237-01 | Nœud générique armure fonctionne pour Nain et Humain | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-237-02 | Bonus tribal ponctuel se combine à élément | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-237-03 | Pas de branche peuple obligatoire | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-237-04 | Réinitialisation hors ascension recalcule bonus | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-238-01 | Aura globale affecte cibles éligibles | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-238-02 | Bonus de rangée seulement pour bonnes cases | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-238-03 | Critère tribu filtre zone géométrique | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-238-04 | Inspection révèle les unités ciblées | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-239-01 | Voisins orthogonaux sur deux rangées | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-239-02 | Diagonale exclue de adjacent | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-239-03 | Carte mentionnant diagonale l’inclut | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-239-04 | Effet colonne et bord de plateau corrects | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-240-01 | Déplacement brise une aura | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-240-02 | Invocation active une aura | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-240-03 | Transformation de peuple retire un bonus | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-240-04 | Aucune activation FIFO par simple itération | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-241-01 | Perte PV max conserve blessures | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-241-02 | Deux unités létales identifiées dans même lot | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-241-03 | Destruction secondaire réévalue aura | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-241-04 | Perte de PV max ne déclenche pas ON_DAMAGE_TAKEN | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-242-01 | Morts simultanées en ordre canonique Q13/Q27 | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-242-02 | Réactions FIFO conservées après stabilisation | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-242-03 | Boucle de triggers bloquée par Q111/Q112 | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-242-04 | Budget causal Q113–Q120 bloque seulement descendance non admise | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-243-01 | Graphe acyclique donne résultat canonique Q161 | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-243-02 | Auras indépendantes recalculées localement | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-243-03 | Même état donne même replay Q164 | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-243-04 | Pas de consommation budget FIFO durant solveur aura Q162 | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-244-01 | Cycle sans point fixe neutralisé minimalement Q162 | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-244-02 | Tie-break sémantique canonique Q163 | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-244-03 | Effet indépendant reste actif | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |
| T-244-04 | Recalcul sur changement externe sans boucle infinie | Résultat déterministe, sans violer les règles normatives antérieures ; assertion à implémenter. |

**État des tests : 40 cas spécifiés, non exécutés.** Q244 est testé comme régression de Q162–Q163.

## Tests v2.6 — Q245–Q254 (spécifiés, non exécutés)

Ces scénarios respectent les systèmes normatifs de FIFO, stabilisation, changements de zone, budgets causaux et sauvegardes existants.

| ID | Scénario | Mise en situation | Résultat attendu |
|---|---|---|---|
| T-245-01 | Peuple et faction indépendants | Créer un Humain de deux factions différentes | Même peuple, factions différentes ; filtres exacts indépendants. |
| T-245-02 | Types secondaires multiples | Une créature Mage et Guerrier | Les deux filtres de type la reconnaissent. |
| T-245-03 | Faction facultative | Créature sans faction | Validation, inspection et capacités ne requièrent aucune faction. |
| T-245-04 | Extension sans migration moteur | Ajouter un peuple Gobelin | Ciblage et sauvegarde acceptent le nouvel identifiant. |
| T-246-01 | Deck factions rivales | Mettre deux factions opposées dans le même deck | Deck légal si toutes les autres limites sont respectées. |
| T-246-02 | Bonus conditionnel insuffisant | Seulement 5 Nains pour seuil fictif de 8 | Carte jouable, bonus conditionnel inactif. |
| T-246-03 | Pool booster sans élément spécialisé | Sphérier feu, boosters sans cartes feu | Composition auto légale sans générer de carte feu. |
| T-246-04 | Socle neutre | Initialiser 20 cartes fondamentales | Aucun archétype imposé par la composition du socle. |
| T-247-01 | Instant avant main initiale | Deck avec 8 Nains puis distribuer 6 cartes | Condition de composition reste vraie après distribution. |
| T-247-02 | Réserve exclue | 7 Nains deck actif et 2 en réserve | Seuls les 7 du deck actif comptent. |
| T-247-03 | Deck change entre combats | Passer 1 Nain de réserve au deck | Condition réévaluée au combat suivant. |
| T-247-04 | Défausse durant combat | 8 Nains initialement, 4 défaussés | Condition reste figée ; snapshot replay identique. |
| T-248-01 | Rivalité seule | Deux factions rivales sans capacité spécifique | Aucun modificateur implicite. |
| T-248-02 | Effet contre faction | Carte ciblant faction ennemie explicitement | Bonus seulement selon texte de carte. |
| T-248-03 | Allié narratif sans effet | Deux factions alliées sans capacités | Aucun bonus automatique. |
| T-248-04 | Nouvelle faction | Charger une faction d’extension | Aucune table de rivalités obligatoire. |
| T-249-01 | Équipement vs artefact | Équiper une épée pendant une ascension | Aucun emplacement d’artefact consommé. |
| T-249-02 | Case plateau | Attacher un bouclier à une unité | Aucune case de créature occupée. |
| T-249-03 | Bonus standard | Équipement +2 attaque | Le calcul des statistiques existant l’intègre. |
| T-249-04 | Instance distincte | Deux objets identiques dans deux zones | Identités d’instance et snapshots distincts. |
| T-250-01 | Deux catégories | Un slot Arme et un Protection | Une arme et un bouclier coexistent. |
| T-250-02 | Deux armes | Créature avec Arme déjà occupé | Ne peut porter simultanément deux armes ; remplacement Q252. |
| T-250-03 | Catégorie Protection utilitaire | Équiper une amulette accordant pioche | Admissible dans Protection malgré effet non défensif. |
| T-250-04 | Pas de troisième slot | Créature avec deux équipements | Pas d’accessoire supplémentaire indépendant. |
| T-251-01 | Mort du porteur | Créature équipée détruite | Chaque objet est détaché et défaussé au bon propriétaire. |
| T-251-02 | Retour en main | Porteur équipé renvoyé en main | Équipements en défausse ; ne suivent pas le porteur. |
| T-251-03 | Bannissement | Porteur équipé banni | Équipements en défausse par défaut. |
| T-251-04 | Exception retour objet | Carte équipement indique retour en main | La destination explicite prime sur défaut. |
| T-252-01 | Remplacer arme | Épée remplace hache | Hache en défausse, épée en slot Arme. |
| T-252-02 | Remplacer protection | Anneau remplace bouclier | Bouclier en défausse, anneau en slot Protection. |
| T-252-03 | Refus restriction | Nouvelle arme non compatible avec créature | Attachement invalide ; ancienne arme conservée. |
| T-252-04 | Retrait bonus PV maximum | Ancienne protection accorde +3 PV max | Stabilisation Q240–Q244, aucun moteur parallèle. |
| T-253-01 | Créature sans slot | Dragon à zéro emplacement | Aucun équipement attachable. |
| T-253-02 | Créature un seul slot | Elfe avec Arme uniquement | Arme permise ; Protection refusée. |
| T-253-03 | Restrictions explicites | Épée réservée aux Guerriers | Mage sans type Guerrier refusé malgré slot Arme. |
| T-253-04 | Bonus conditionnel | Bouclier universel +1 si Nain | Autres peuples peuvent porter sans bonus nain. |
| T-254-01 | Sans durabilité | Équipement ordinaire après dix activations de combat | Pas d’usure ni destruction implicite. |
| T-254-02 | Charges consommées | Objet à 3 charges effectue une activation coûtant 1 | Instance passe à 2 charges, journal et replay cohérents. |
| T-254-03 | Zéro charges sans destruction | Carte désactive seulement une capacité à zéro | Carte reste équipée, capacité indisponible. |
| T-254-04 | Zéro charges avec défausse | Carte stipule défausse à zéro | Détachement et défausse ordinaires, stabilisation conforme. |

**État : 40 nouveaux tests d’acceptation spécifiés ; exécution non réalisée.** Non-régression obligatoire Q183 artefacts, Q207/Q227 quatre copies par famille, Q215/Q246 pool neutre + boosters, Q250/Q253 zéro à deux slots, Q251/Q252 transferts, Q254 charges sans durabilité globale.

## Tests v2.7 — Q255–Q264 (spécifiés, non exécutés)

Les tests suivants couvrent les décisions nouvelles de ciblage d’équipements et les **invariants de contenu du catalogue**. Ils ne réimplémentent pas la FIFO, les durées, la stabilisation ou les transferts de zone des versions antérieures. Les scénarios à décomptes indicatifs sont des contrôles **éditoriaux de conception**, pas des assertions bloquantes du moteur ou du générateur de boosters.

| ID | Scénario | Mise en situation | Résultat attendu |
|---|---|---|---|
| T-255-01 | Cible alliée par défaut | Une épée sans texte de ciblage spécial ; créature ennemie compatible | Cible ennemie refusée, alliée compatible acceptée. |
| T-255-02 | Cible ennemie explicite | Anneau maudit avec « ciblez un ennemi » | Créature ennemie admissible si emplacement Protection présent. |
| T-255-03 | Ennemi sans emplacement | Dragon ennemi avec zéro slot ; anneau maudit | Attachement refusé ; pas de contournement de Q253. |
| T-255-04 | Remplacement sur ennemi et propriétaire | Ennemi avec ancienne protection du joueur adverse ; nouvelle protection maudite | Ancien équipement défaussé chez SON propriétaire ; nouveau remplace ; départ du porteur => défausse du propriétaire de la malédiction. |
| T-256-01 | Synergie artisanat sur tirage valide | Boosters contiennent créature artisane et équipement éligibles | Les deux cartes peuvent interagir sans qu’un archétype soit imposé. |
| T-256-02 | Tirage sans équipement | Boosters du pool débloqué ne contiennent aucun équipement | Deck légal sans ajout artificiel d’objet. |
| T-256-03 | Synergie maudite explicite | Créature réagit aux équipements sur ennemis | Interaction possible seulement si les textes la prévoient. |
| T-256-04 | Synergie croisée | Équipement affecte une créature d’un autre peuple | Règles de peuple, faction, cible et effet réutilisées. |
| T-257-01 | Quota catalogue | Inventaire des 100 définitions indépendantes | Exactement 20 définitions de type Équipement. |
| T-257-02 | Quotas Arme / Protection souples | Répartition 11 Armes / 9 Protections proposée pour équilibrage | Total 20 respecté ; ajustement admis car cible 10/10 indicative. |
| T-257-03 | Non addition aux fondamentales | Inventaire contient 40 fondamentales et ~30 variantes | Les 20 équipements se trouvent dans les 100 indépendantes, non ajoutées au total ~170. |
| T-257-04 | Type et fonction indépendants | Amulette dans Protection avec effet offensif | Type Protection légitime malgré fonction offensive. |
| T-258-01 | Total exact | Compter types des 100 indépendantes | 50 Créatures + 30 Sorts + 20 Équipements = 100. |
| T-258-02 | Fonctions transversales | Sort de pioche également classé soutien | Une seule définition dans 30 Sorts ; pas de double comptage. |
| T-258-03 | Pas de quota booster | Pack de 15 avec proportions différentes de 50/30/20 | Pack valide si toutes règles de tirage, déblocage et plafonds respectées. |
| T-258-04 | Socle et ouverture inchangés | Démarrer ascension standard | 20 base + 2 × 15 booster ; 40 actives et 10 réserve ; proportions catalogue ne changent pas cela. |
| T-259-01 | Répartition cible | Inventorier 50 créatures indépendantes proposées | Cible 15/14/13/8 (total 50), déviations justifiées comme ajustements de conception. |
| T-259-02 | Rareté non déduite | Définir un jeune Dragon Commun et un Humain Rare | Deux raretés acceptées sans contrainte raciale automatique. |
| T-259-03 | Booster sans quota de peuple | Boosters proposés avec aucun Dragon | Pas de rejet du seul fait du quota catalogue. |
| T-259-04 | Taxonomie distincte | Elfe et Nain partageant une faction | La faction ne remplace pas le peuple dans les comptages. |
| T-260-01 | Identité dominante indicative | Comptage des 15 Humains dont 8 commandement/cooperation | Atteint environ 50–60 % comme cible de conception, sans erreur de validation runtime. |
| T-260-02 | Rôle alternatif | Nain offensif plutôt que défensif | Carte admissible, cohérente avec son peuple. |
| T-260-03 | Dragon soutien | Un des 8 Dragons spécialisé en soutien élémentaire | Profil accepté ; identité narrative maintenue. |
| T-260-04 | Unité mixte | Un Elfe soutien utilisé avec Humains | Deck autorisé ; pas de verrouillage par identité dominante. |
| T-261-01 | Quota passerelles | Marquer 8 créatures passerelles dans catalogue de 50 | Quota cible 6–10 atteint sans créer 8 cartes supplémentaires. |
| T-261-02 | Recouvrement hybride | Une créature passerelle est également hybride | Comptage des deux labels permis sur la même définition. |
| T-261-03 | Utilité hors synergie | Carte passerelle sans autre peuple sur plateau | Carte a un effet de base raisonnable, sans exiger de générer le peuple manquant. |
| T-261-04 | Booster sans passerelles | Pack valide ne contient aucune passerelle | Pas de reroll ou de garantie non prévue. |
| T-262-01 | Quota hybride | Marquer 15 créatures ayant au moins deux fonctions significatives | Entre 13 et 18 sur 50, sans dépasser 50 définitions. |
| T-262-02 | Fonctions non décoratives | Carte attaque mais ajoute un effet de protection situationnel substantiel | Profil hybride justifié par deux fonctions effectives. |
| T-262-03 | Double attribution | Créature hybride et évolutive appartenant à un peuple dominant | Une seule définition malgré plusieurs labels. |
| T-262-04 | Booster mono-rôle | Pack ne contient que créatures spécialisées | Aucune obligation de tirage d’hybrides. |
| T-263-01 | Population évolutive | Marquer 6 créatures évolutives sur 50 | Cible 5–8 atteinte, cartes non ajoutées au total. |
| T-263-02 | Condition propre à carte | Dragon avec progression à l’usage de sorts feu | Seule la condition écrite incrémente le compteur, pas un niveau global automatique. |
| T-263-03 | Fin du combat | Progression acquise pendant un combat puis combat suivant | Pas de conservation par défaut de progression de combat. |
| T-263-04 | Lisibilité et replay | Progression d’une carte par événement et franchissement de seuil | Indicateur et journal conformes, mêmes résultats en replay déterministe. |
| T-264-01 | Nombre de cartes | Marquer 10 définitions indépendantes à contrepartie | Cible 8–12 atteinte ; toutes déjà comprises parmi les 100. |
| T-264-02 | Répartition entre types | 4 créatures, 4 sorts et 2 équipements à contrepartie | Aucune nouvelle catégorie ni augmentation des quotas Q258. |
| T-264-03 | Capacité facultative | Carte propose « activer : sacrifiez allié pour... » | Sans activation, aucun sacrifice ; avec activation, contrepartie selon texte et règles de coût. |
| T-264-04 | Contrepartie automatique explicite | Équipement donnant +ATQ et -PV max de manière continue | Malus appliqué selon texte, sans option universelle de refus ; règles de PV max existantes. |

**État : 40 scénarios supplémentaires spécifiés, 0 exécuté.** Vérifications de non-régression : propriété de l’équipement Q251, remplacement Q252, emplacements Q253, charges Q254, classification Q245, composition neutre et tirages Q215/Q246, 4 copies par famille Q207/Q227, risques de cycles Q111–Q124 et Q159–Q164.
