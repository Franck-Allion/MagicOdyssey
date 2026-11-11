# Tower TCG/RPG — Roadmap d’implémentation du Lot 1

**Version :** 1.0 — 11 novembre 2026  
**Statut :** plan d’exécution, aucun développement présumé effectué  
**Cible :** Godot 4 stable (version précise à verrouiller à P001), GDScript typé, PC Windows, 2D  
**Mode d’exécution :** VS Code + Codex + Gemini Flash (raisonnement léger), **un prompt par tâche**  
**Source normative :** `Tower_TCG_RPG_Lot1_Specifications_v1.md` (550 lignes) ; détails normatifs hérités du corpus intégral v2.8 et décisions Q275–Q302.  
**Portée :** combat vertical complet et beau, 16 cartes, IA heuristique, tests et build. **Exclu :** exploration, menu final, 170 cartes et mécaniques rares.

> Les nombres de prompts sont **une granularité initiale**, non un quota absolu. Une tâche doit être découpée davantage si la modification ou les tests dépassent la capacité d’une IA à raisonnement léger. Les ID de prompts restent stables ; en cas de subdivision, utiliser P021a/P021b et documenter l’écart. Le Lot 1 n’est **pas achevé** à l’issue du premier combat de créatures (J4) : il faut atteindre G8.

## A. Stratégie de développement

Le travail suit un **double fil technique + artistique** : l’interface est architecturée visuellement dès J1, tandis que le moteur déterministe est construit par petits incréments dès J2. Une première intégration créatures seules apparaît à J4, ensuite les effets déclaratifs et l’IA deviennent complets, puis les animations et les vrais assets atteignent le seuil professionnel. Les scènes précoces sont **des composants définitifs enrichis progressivement**, pas une maquette jetable.

**Ordre contractuel :** G0 → G1 → G2 → G3 → G4 → G5 → G6 → G7 → G8. Chaque jalon ferme ses défauts bloquants avant le suivant. Les assets artistiques peuvent être produits en parallèle à J2–J6, mais sont exigés à G7. La première implémentation peut utiliser des fixtures et textures de secours explicitement marquées comme provisoires.

### Principes non négociables

- **Moteur autoritatif indépendant de la scène 2D** : logique métier hors `Control`, `Tween`, `Timer`, VFX et événements souris.
- **Catalogue `.tres` typé** : 10 créatures, 4 sorts, 2 équipements ; pas de `if card_id == ...` dans l’exécution.
- **Règles héritées** : 6×2 positions par camp, priorité d’invocation, mana +1 dès le premier tour personnel, 6 cartes initiales, decks de 40 (4 copies max), main max 7, fatigue **1 puis 2 puis 3**…, attaques C1→C6, armure réutilisable, bouclier consommable, simultanéité/FIFO/déterminisme.
- **Confidentialité et équité** : IA limitée à `CombatObservation`, aucun accès à la main/pioche cachées de l’autre camp.
- **Visuel premium** : HUD/jetons/cards en 1080p et 720p ; portraits semi-réalistes et écussons, inspection au clic et tooltip au survol ; feedback « juicy » qui ne ralentit pas les règles.
- **Pas de déviation de scope** : absence d’exploration, menus finaux, sauvegarde hors combat, contrôle, résurrection, auras complexes ; ces fonctions reviendront dans les lots ultérieurs.

## B. Règles de travail prompt par prompt (pour Codex/Gemini Flash)

Chaque prompt est une **unité de travail** visant un comportement précis. Le prompt sera rédigé lorsque son ID sera démarré, avec les dépendances **réellement présentes dans le dépôt**. Ne pas envoyer en une fois toute la roadmap au modèle comme ordre d’implémentation ; utiliser la roadmap comme plan de pilotage.

1. **Lecture ciblée :** rappeler au modèle les extraits pertinents des specs, les ID de tests, les contrats existants et les fichiers réellement présents. En cas de conflit, appliquer la décision validée la plus récente et arrêter toute invention de gameplay.
2. **Périmètre limité :** viser 1 fonctionnalité, environ 1–4 fichiers code/scène (avec exceptions pour lots de ressources `.tres`), petits diffs et refactorings interdits hors demande. Si l’agent a besoin de plus de travail, proposer une sous-tâche au lieu d’élargir silencieusement.
3. **Sortie obligatoire :** (a) fichiers modifiés ; (b) comportement implémenté ; (c) tests ajoutés et exécutés avec commande + résultat réel ; (d) limites/risques ; (e) besoin de validation manuelle et captures ; (f) identifiant du commit si créé.
4. **Interdictions :** ne pas affirmer qu’un test ou screenshot a été exécuté s’il ne l’a pas été ; ne pas coder une règle dans `CreatureToken`; ne pas simuler un test par une sortie fixe ; ne pas ignorer silencieusement les opérations non prises en charge.
5. **Boucle :** prompt PNNN → modification locale → tests headless/import → revue diff → essai manuel si UI → corrections dans le même périmètre → validation → commit petit → mise à jour `docs/progress.md` → prochain prompt.

**Commandes-types à adapter au chemin de l’exécutable Godot installé :**

```powershell
# Import et validation des ressources (la version exacte doit être celle verrouillée à P001)
& $GodotExe --headless --editor --path . --quit
# Lancement des tests natifs du dépôt
& $GodotExe --headless --path . --script res://tests/run_all.gd
```

Ces commandes sont des **conventions à installer/tester à P003** ; elles ne prouvent pas qu’un test a déjà été exécuté. Si des flags ou scripts diffèrent dans la version retenue, P003 les fige et les documente. Les tests d’interface et le rendu final restent à vérifier dans Godot avec captures réelles.

## C. Plan détaillé — 65 prompts ordonnés

### J0 — Socle de projet et discipline IA · P001–P004

**Objectif :** Un projet Godot vierge mais exécutable, un protocole Codex/Gemini Flash et un contrôle qualité reproductible.

| Prompt | Tâche autonome | Périmètre attendu | Preuve / critère de sortie |
|---|---|---|---|
| **P001** | Créer le dépôt Godot 4 | Créer `project.godot`, scène de démarrage, dossiers cibles, `.gitignore` et README de lancement ; figer et inscrire la version exacte de Godot utilisée. | Ouverture Godot et lancement d’une scène sans erreur ; fichiers de base versionnés. |
| **P002** | Installer les références normatives | Placer les spécifications Lot 1 et le référentiel historique v2.8 dans `docs/specs/`, créer `AGENTS.md` pour Codex et `docs/progress.md` avec l’état des tâches et la hiérarchie VALIDÉ / LOT1 / CONFIG / PROPOSITION. | Un agent peut identifier la source de vérité sans inventer une règle ; le projet n’importe pas automatiquement l’ancien prototype non audité. |
| **P003** | Créer le harnais de tests natifs | Créer un runner GDScript en mode headless, des assertions sans extension tierce obligatoire et un script PowerShell pour lancer import/parse/test avec codes retour fiables. | Test volontairement réussi puis volontairement échoué : le script retourne correctement PASS/FAIL ; si Godot n’est pas installé, statut NOT RUN. |
| **P004** | Définir le design system et les assets | Créer `Theme` Godot, tokens UI (typos, contrastes, espacements, couleurs de rareté), manifeste d’assets et licences, conventions de noms ; établir une baseline de captures 1920×1080 et 1280×720. | Thème visible dans une scène démo ; les assets manquants sont identifiés sans les faire passer pour des illustrations finales. |

**G0 — Projet importable, tests déclenchables, conventions IA disponibles, direction graphique traduite en composants réutilisables.**

### J1 — Interface de combat — vraie base graphique · P005–P010

**Objectif :** Fixer tôt la composition premium et les composants graphiques définitifs, d’abord alimentés par des données de prévisualisation.

| Prompt | Tâche autonome | Périmètre attendu | Preuve / critère de sortie |
|---|---|---|---|
| **P005** | Composer `CombatScreen` | Définir le plateau central immersif, les zones héros adverse et héros joueur, la main et la zone de commandes ; ancrages adaptatifs sans logique de combat. | Aucune zone essentielle ne disparaît en 1920×1080 et 1280×720 (préparation L1-U01/U02). |
| **P006** | Créer les 24 emplacements | Dessiner 2 camps × 6 colonnes × 2 lignes, rendre les lignes ATTACK/DEFENSE et les colonnes identifiables ; exposer signaux UI de sélection et survol, sans inventer la légalité. | Les 24 cases sont accessibles, même toutes occupées (L1-U03 structure). |
| **P007** | Créer les HUD de héros et de tour | PV, mana capacité/disponible, decks, compteur de main, camp actif et bouton Terminer le tour ; API de présentation à partir d’un view-model. | Tous les chiffres se rafraîchissent via données injectées, jamais par lecture d’un état interne du moteur. |
| **P008** | Créer `CreatureToken` en écusson | Portrait dominant, ATQ en bas à gauche, PV en bas à droite, armure et bouclier distincts, trois statuts maximum +N, camp/rareté visibles sans couleur seule. | Démonstration sur 24 jetons avec statistiques variées et au moins quatre états (L1-U03/U05). |
| **P009** | Créer `CardView` et `HandView` | Carte premium complète et main éventail/alignée, états focus/sélection et zoom ; découpler contenu imprimé des données d’instance. | Des exemplaires d’une même définition se présentent indépendamment ; rendu non générique, lisible en 720p. |
| **P010** | Créer tooltip et inspecteur | Survol/focus : résumé tactique ; clic : recto imprimé intact + valeurs finales et effets dans panneau contextuel scrollable. | L1-U04 démontrable sur une créature modifiée ; effectuer première revue de captures 1080p/720p. |

**G1 — Écran visuellement cohérent, 24 cases et composants de cartes réels ; pas de « cubes de debug » destinés à subsister jusqu’à la recette.**

### J2 — Catalogue typé et modèle de combat · P011–P020

**Objectif :** Préparer ressources `.tres`, identités, zones, fixtures contrôlées et initialisation reproductible sans encore coder les effets avancés.

| Prompt | Tâche autonome | Périmètre attendu | Preuve / critère de sortie |
|---|---|---|---|
| **P011** | Définir `CardDefinition` | Définir la ressource typée et ses métadonnées (identifiant stable, type, peuple, rareté, mana, caractéristiques, portrait et références de présentation). | Chargement/édition d’une carte dans l’inspecteur Godot ; champs incohérents détectables. |
| **P012** | Définir les ressources de capacités | Créer `AbilityDefinition`, `TargetSpec`, `CostSpec`, `DurationSpec` et `EffectOperation` typées, sans script arbitraire par carte. | Une opération de test décrit `DAMAGE(4)` sans `if card_id`. |
| **P013** | Créer registre et validateur | `CardCatalog` charge les ressources, détecte doublons, champs invalides, cibles incohérentes et opcodes sans contrat ; distinguer validation de structure et disponibilité des handlers runtime. | Rapport d’erreurs sur ressource malformée (préparation L1-B32) ; pas de no-op silencieux. |
| **P014** | Définir les 5 premières créatures | Créer les ressources `.tres` Humains et Elfes du catalogue Q298 selon valeurs validées, avec éventuels effets configurés documentés. | 5 définitions chargées, IDs uniques, caractéristiques conformes ; aucun script propre à la créature. |
| **P015** | Définir les 5 autres créatures | Créer les autres ressources `.tres` du catalogue Q298 (Elfe, Nains, Dragons) avec capacités proposées explicitement marquées CONFIG. | 10/10 créatures présentes et validées structurellement. |
| **P016** | Définir les 4 sorts | Créer les ressources de Boule de feu, Lumière réparatrice, Barrière arcanique et Bénédiction martiale avec leurs `EffectOperation` paramétrées. | 4/4 sorts référencent DAMAGE/HEAL/ADD_SHIELD/MODIFY_STAT ; aucun effet implémenté par nom de carte. |
| **P017** | Définir les 2 équipements | Créer Lame runique et Armure du Bastion, classe Arme/Protection, bonus déclaratifs et contraintes de porteur. | 2/2 équipements chargés ; types et bonus cohérents. |
| **P018** | Modéliser héros, copies, instances et plateau | Créer les structures typées `HeroState`, `CardCopy`, `BoardInstance`, `BoardPosition` ; différencier definition_id, copy_id, instance_id. | Une carte réintroduite peut avoir un nouvel instance_id ; déplacer n’en crée pas. |
| **P019** | Créer zones et fixtures de 40 cartes | Zones DECK/HAND/BOARD/DISCARD/BANISHED ; `CombatFixture` avec deux decks de 40, maximum quatre copies par identité/famille, PV/mana de démonstration et graine. | Validation taille/copies ; les valeurs de test sont CONFIG et non des règles universelles. |
| **P020** | Créer la fabrique déterministe de combat | `CombatFactory` crée l’état initial, mélange avec RNG reproductible et distribue 6 cartes initiales à chaque camp ; le joueur est premier. | L1-B01 : même seed → mêmes mains ; aucun accès à l’ordre caché via l’interface publique. |

**G2 — Les 16 ressources existent ; les deux decks de 40 sont valides ; l’état initial est reproductible. Les handlers d’effets ne sont pas encore tous disponibles.**

### J3 — Moteur déterministe de combat — noyau · P021–P031

**Objectif :** Obtenir un moteur testable sans interface, puis l’alimenter avec les règles indispensables aux premières invocations et attaques.

| Prompt | Tâche autonome | Périmètre attendu | Preuve / critère de sortie |
|---|---|---|---|
| **P021** | Construire la transaction de commande | `CombatCommand`, `ValidationResult`, `CombatResult`, révision d’état ; validation avant mutation et commit atomique, rejet sans effet ni mana. | L1-B04 ; erreur technique non confondue avec action illégale (Q287). |
| **P022** | Exposer les actions légales | API calculant les commandes autorisées depuis camp actif/état (invocation, mouvement, permutation, fin de tour) ; autres types ajoutés plus tard. | Le contrôleur ne calcule pas lui-même la légalité ; camp non actif interdit (Q276). |
| **P023** | Implémenter croissance et phases de tour | Début personnel : expiration pertinente, +1 capacité dès premier tour, restauration du mana et pas de pioche normale au premier tour ; fin de tour et alternance. | L1-B02/B03 ; ordre Q275 et TURN-001..007 vérifié. |
| **P024** | Implémenter pioche, limite de main et fatigue | Pioche 1 à partir du second tour personnel, main max 7, overflow vers défausse, tentatives vides à pertes directes 1/2/3…, sans recyclage automatique. | L1-B26/B27 ; fatigue ne consomme pas l’armure et n’émet pas de dégâts. |
| **P025** | Implémenter l’invocation et la priorité | Paiement, vérification de case libre, priorité aux colonnes ennemies non contestées, création d’instance et événement ON_SUMMON. | L1-B05/B06 ; rejet d’une destination illégale sans mutation. |
| **P026** | Implémenter déplacements et permutations | Mouvement naturel interlignes même colonne à 1 mana, une fois/tour ; permutation 2 alliés pour 1 mana consommant les deux droits. | L1-B08/B09 ; une créature invoquée ce tour peut se déplacer. |
| **P027** | Créer le résolveur de dégâts | Ordre armure réutilisable → réserves de bouclier → PV ; provenance conservée, buffs d’armure additifs ; soins seront ajoutés via registre. | L1-B12/B13/B14 ; pas de réduction d’armure cumulée à chaque coup. |
| **P028** | Implémenter les attaques de fin de tour | Colonnes C1..C6, ligne ATTACK du camp actif uniquement, priorité cible ATTACK→DEFENSE→héros, aucune riposte, mal d’invocation. | L1-B07/B10/B11 ; résolution d’une colonne avant la suivante. |
| **P029** | Gérer morts, défausses et résultat final | Mort d’unité → case libérée et zone appropriée ; mort d’un héros → victoire/défaite immédiate, égalité létale → défaite joueur ; bloquer commandes suivantes. | L1-B20/B23/B24/B25. |
| **P030** | Implémenter FIFO et stabilisation | Événements gameplay ordonnés, `ON_SUMMON`/`ON_DEATH`, vidage FIFO entre commandes, contrôles anti-boucles ; logique indépendante de toute animation. | Aucun effet différé exécuté après résultat final ; les futures capacités ne peuvent interrompre une opération atomique. |
| **P031** | Tester le noyau en mode headless | Compléter tests B01–B14 et B20/B23–B27 utiles, hash d’état canonique minimal et journal commandes + seed ; corriger anomalies bloquantes. | G3 : scénario scripté complet reproductible, zéro UI requise pour l’exécuter. |

**G3 — Un combat de créatures peut être simulé jusqu’à l’issue en headless, avec règles testées et commandes déterministes.**

### J4 — Premier parcours visuel réellement manipulable · P032–P037

**Objectif :** Faire passer le noyau dans l’interface et obtenir le premier duel manuel contre un opposant automatique provisoire.

| Prompt | Tâche autonome | Périmètre attendu | Preuve / critère de sortie |
|---|---|---|---|
| **P032** | Créer `CombatPresenter` | Projeter `CombatState` vers des view-models et consommer événements/révisions ; les scènes ne modifient jamais l’état métier. | Après une commande, plateau, main et HUD présentent exactement la même révision. |
| **P033** | Brancher plateau, jetons et HUD | Binder les 24 cases, écussons, héros, mana et camp actif sur les vues fournies par le moteur. | Invocations, déplacements et pertes de PV se reflètent sans recalcul UI. |
| **P034** | Connecter le jeu des cartes par clic | Sélection d’une carte de la main → destinations/cibles autorisées par get_legal_actions → clic destination → command ; Échap annule avant commit. | La carte revient si invalide ; clic-clic compatible L1-U06/U07. |
| **P035** | Ajouter glisser-déposer | Drag/drop avec le même `CombatCommand` et même validation que clic-clic, sans logique alternative ni coûts doublés. | L1-U06/U07 : les deux chemins produisent une commande et un résultat identiques. |
| **P036** | Ajouter tour adverse automatique provisoire | Stratégie provisoire minimale fondée sur actions légales : jouer une option raisonnable ou terminer ; informations privées masquées côté joueur. | Un utilisateur peut alterner ses tours avec l’ordinateur, aucune action volontaire pendant tour IA. |
| **P037** | Valider le premier duel visuel | Test manuel écran : lancer combat → plusieurs invocations/déplacements → attaques → résultat → relance ; capturer 1080p et 720p, consigner défauts. | G4 : parcours créatures jouable à la souris. **Ce n’est PAS encore le Lot 1 terminé** : sorts, équipements, IA tactique et VFX restent à faire. |

**G4 — Premier combat concret et manipulable à l’écran, sans le confondre avec l’acceptation finale du Lot 1.**

### J5 — Mécaniques complètes du mini-catalogue déclaratif · P038–P048

**Objectif :** Rendre les 16 cartes réellement jouables au moyen d’opérations partagées, et clôturer les invariants d’effets/ciblages nécessaires.

| Prompt | Tâche autonome | Périmètre attendu | Preuve / critère de sortie |
|---|---|---|---|
| **P038** | Déployer `EffectRegistry` | Créer le dispatch d’`EffectOperation` déclaratives, les contrats de ciblage/coûts et l’erreur claire si handler indisponible ; pas de branche par ID de carte. | Une ressource arbitraire avec op déjà prise en charge s’exécute via le même handler. |
| **P039** | Brancher `DAMAGE` pour les sorts | Boule de feu : ciblage ennemi et dommages génériques, paiement et événement ; le handler ne connaît pas « Boule de feu ». | Une seconde définition de sort DAMAGE fonctionne sans changement code. |
| **P040** | Brancher `HEAL` | Soin générique avec plafond de PV, quantum effectif, événement ON_HEAL si positif ; premier sort de soin actif. | L1-B15/B16 et soin via `.tres`. |
| **P041** | Brancher `ADD_SHIELD` et ses réserves | Créer réserves de bouclier par source, quantités et échéances, agrégation affichable et consommation par échéance/ordre stable. | L1-B13/B14 ; Barrière arcanique supportée. |
| **P042** | Brancher `MODIFY_STAT` temporaire | Bonus ATQ +2 jusqu’à fin du tour via durées et expiration communes, pas de raccourci lié au sort ; mise à jour HUD/jetons. | L1-B17 et Q140 lors de changement d’échéance si opération concernée. |
| **P043** | Brancher les passifs de position simples | Modificateurs calculés sur l’état courant (ATQ/armure selon ATTACK/DEFENSE) sans empiler des bonus au rafraîchissement. | Changer de ligne met à jour valeurs effectives une seule fois. |
| **P044** | Brancher la capacité active de guérison | `AbilityDefinition` ACTIVE, coût mana, cible alliée, validation du contrôleur, exécution de HEAL générique. | Activation licite et illégale testées ; la créature soignante réutilise HEAL. |
| **P045** | Brancher le déclencheur `ON_SUMMON` simple | Capacité du Forgeur des Runes : bouclier via file FIFO et opération générique ; aucun script propre à cette carte. | Événement en file, résolu avant nouvelle commande volontaire ; effet cohérent avec la source. |
| **P046** | Implémenter `EQUIP` et slots fixes | Jouer armes/protections depuis la main, coût et porteur compatibles ; bonus pendant portage ; règle Q252 de remplacement. | L1-B18/B19 ; aucune double arme indue ni bonus orphelin après remplacement. |
| **P047** | Fiabiliser le ciblage et les effets composés | Revalidation au lancement/résolution, référence instance_id, invalidation sans reciblage ni remboursement, opérations indépendantes ou liées explicitement. | L1-B21 ; déplacement ou mort d’une cible ne corrompt pas l’état. |
| **P048** | Finaliser transactions et dommages simultanés | Regroupement compatible par profil effectif de protections, ordre canonique des groupes incompatibles, attribution de source, commit simultané, échec technique rollback. | L1-B22/B30 et Q287–Q289 testés ; 16/16 cartes utilisables dans le moteur. |

**G5 — Les 16 définitions sont exécutables sans scripts métier par carte, sorts/équipements/capacités et protections respectent les règles ; tests essentiels au vert.**

### J6 — IA heuristique V1 sans triche · P049–P053

**Objectif :** Passer de l’adversaire provisoire à une IA déterministe, capable de choix tactiques crédibles et d’un combat complet.

| Prompt | Tâche autonome | Périmètre attendu | Preuve / critère de sortie |
|---|---|---|---|
| **P049** | Étendre l’espace des actions légales | Fournir à l’IA tous les actes Lot 1 (invocation, déplacement, sorts, équipements, capacités et fin de tour) avec cibles/positions validées. | Chaque suggestion exécutable provient du moteur et respecte les coûts. |
| **P050** | Sécuriser `CombatObservation` | Masquer données privées de l’adversaire du point de vue IA ; ne passer ni état brut ni ordre caché au calcul de score. | Changer seulement la main cachée joueur ne doit pas modifier le choix IA (L1-B28). |
| **P051** | Implémenter la fonction d’évaluation heuristique | Scores transparents : valeur de carte, placement et menace, mana, efficacité dégâts/soins/protections et préservation de ressources. | L’IA évite les soins inutiles et privilégie une carte utile à une action strictement moins bonne. |
| **P052** | Ajouter priorités tactiques et garde-fous | Létal immédiat, prévention d’une perte évidente, départage déterministe, limite de décisions par tour et fin de tour garantie. | Pas de boucle, pas de tentative répétée illégale, tour IA termine sans intervention. |
| **P053** | Valider l’IA par combats reproductibles | Scénarios IA (mana insuffisant, létal, défense, soin, main cachée, même seed), série de duels complets consignés. | G6 : IA V1 autonome, légale, sans triche, reproductible (L1-B28/B29). |

**G6 — Adversaire autonome crédible, aucun accès aux secrets du joueur et aucune boucle de décision.**

### J7 — Direction artistique intégrée et VFX « juicy » · P054–P060

**Objectif :** Atteindre la qualité visuelle professionnelle prévue dès le départ, sans introduire de mécanique supplémentaire.

| Prompt | Tâche autonome | Périmètre attendu | Preuve / critère de sortie |
|---|---|---|---|
| **P054** | Produire/importer les assets originaux essentiels | Inventorier et intégrer plateau/ambiances, 16 illustrations originales ou légalement utilisables, portraits écussons, icônes, cadres et sprites VFX ; documenter droits et sources. | Tous les assets essentiels sont présents, cohérents, exploitables légalement ; aucun visuel de debug en surface. Production d’images à réaliser séparément de Codex si nécessaire. |
| **P055** | Finaliser cartes premium et cinq raretés | Appliquer finitions picturales semi-réalistes, contrastes, cadrage, cadres et couleurs Common/Uncommon/Rare/Epic/Legendary ; inspection recto intact. | Carte lisible en main et au clic, icônes de rareté non exclusivement chromatiques. |
| **P056** | Créer l’orchestrateur VFX découplé | Associer événements/revisions de `CombatResult` à animations, bloquer brièvement commandes seulement tant que représentation non cohérente ; particules résiduelles libres. | L1-U09/U10 : aucune animation ancienne ne remplace l’état courant. |
| **P057** | Animer la manipulation, l’invocation et les mouvements | Sélection/hover/drag/zoom fluide, transformation carte→écusson, déplacement et permutation synchronisée. | Aucun Tween ne déclenche une mutation logique ; mêmes commandes pour clic et drag. |
| **P058** | Animer les attaques et protections | Anticipation de frappe/projectile, impacts, nombres de PV réellement perdus, armure métallique, bouclier énergétique, soin positif. | L1-U08 : feedbacks distincts, chiffres conformes aux événements. |
| **P059** | Animer capacités, équipements, mort et résultat | Buffs/échéances, équipement du porteur, disparition de créature, victoire/défaite et relance ; signaux sonores facultatifs non bloquants. | Les transitions donnent une lecture claire de l’état final sans recouvrement persistant. |
| **P060** | Corriger ergonomie en 1080p et 720p | Revue sur 24 jetons occupés, boutons accessibles, texte, états +N, focus clavier, réductions de mouvement/particules ; captures avant/après. | G7 : L1-U01..U13 prêts pour recette ; rendu premium effectivement observable, pas seulement décrit. |

**G7 — Revue visuelle approuvée sur les deux résolutions, animations cohérentes avec l’état et identité originale fantasy semi-réaliste.**

### J8 — Recette complète et livraison Windows · P061–P065

**Objectif :** Clore le Lot 1 avec preuves de conformité, stabilité, documentation et build fonctionnel.

| Prompt | Tâche autonome | Périmètre attendu | Preuve / critère de sortie |
|---|---|---|---|
| **P061** | Auditer les 32 tests métier | Exécuter/compléter L1-B01..B32 à partir des tests créés progressivement, corriger les échecs ; rapport par ID. | 32 résultats PASS ou défaut explicitement bloquant ; jamais de faux PASS. |
| **P062** | Auditer les 13 tests UX | Exécuter L1-U01..U13 avec captures ou enregistrement : 1080/720, plateau rempli, tooltip/inspection, drag/clic, VFX/IA. | 13 résultats PASS ou défaut explicite ; vérification visuelle réelle indispensable. |
| **P063** | Tester robustesse et extensibilité | Série de combats seedés sans blocage, 17e carte fictive par composition d’effets, `.tres` invalide et erreur atomique forcée ; rassembler hash/logs. | L1-B29/B30/B31/B32, aucun effet caché ou branche par carte. |
| **P064** | Préparer et vérifier le build Windows | Configurer export Godot Windows, vérifier ressources embarquées/licences, produire exécutable si export templates disponibles, README d’installation et lancer une partie. | Exécutable démarré sous Windows **si disponible** ; sinon marquer export/test NOT RUN, sans déclarer Lot 1 achevé. |
| **P065** | Signer la recette finale | Consolider matrice PASS/FAIL/NOT RUN, preuves, journal de bugs et limitations ; accepter uniquement si 45 critères et gates sont satisfaits. | G8 : combat complet jouable avec 16 cartes, IA V1, rendu professionnel, moteur déterministe et export vérifié. |

**G8 — Lot 1 terminé seulement après validation de tous les critères, sur un vrai combat jouable. Aucun passage automatique au Lot 2.**

## D. Correspondance avec les 45 tests d’acceptation

**Le fichier de spécifications constitue la source détaillée des assertions.** Les plages ci-dessous indiquent où elles doivent devenir exécutables ; les tests créés à un jalon sont rejoués à chaque jalon suivant.

| Catégorie de recette | Tests concernés | Premiers jalons principaux | Revalidation finale |
|---|---|---|---|
| Initialisation, tours, ressources | L1-B01–B04, B26–B27 | J2–J3 | J8 / P061 |
| Placement, invocation, déplacement | L1-B05–B09 | J3–J4 | J8 / P061 |
| Attaques, armure et boucliers | L1-B10–B14 | J3, J5 | J8 / P061 |
| Soins, buffs et équipements | L1-B15–B19 | J5 | J8 / P061 |
| Mort, ciblage, atomique, victoire | L1-B20–B25, B30 | J3, J5 | J8 / P061 |
| IA, reproductibilité et catalogue | L1-B28–B29, B31–B32 | J2, J5–J6 | J8 / P061/P063 |
| Adaptation, jetons, info, interactions | L1-U01–U07, U11, U13 | J1, J4, J7 | J8 / P062 |
| Animations, réactivité, combat complet | L1-U08–U10, U12 | J4, J6–J7 | J8 / P062 |

Les catégories sont des regroupements thématiques, pas des sommes : les IDs source sont exactement **32 tests métier (B01–B32) + 13 tests UX (U01–U13) = 45**, sans doublons d’acceptation. La couverture automatisée peut dépasser ces 45 scénarios, mais aucun scénario obligatoire ne doit rester non exécuté au gate G8.

## E. Contrat de qualité visuelle / assets

La qualité artistique est une **dépendance explicite**, pas un « polish optionnel ». Pour éviter qu’un codeur IA ne fabrique une interface générique faute d’assets :

- **Pendant J1 :** thème travaillé, composition lisible, écussons et cartes premium, interactions consultables. Prévisualisations ou images de secours permises uniquement si marquées provisoires.
- **Pendant J2–J6 :** préparer les illustrations originales/licenciées. Minimum attendu à la recette : 16 illustrations utilisables dans les cartes, portraits des 10 créatures (éventuellement recadrages autorisés des illustrations), fond de plateau et décor, éléments de cadre et de rareté, icônes d’état, éléments/particules VFX. Créer des assets avec un outil graphique ou de génération d’images distinct de Codex si nécessaire ; Codex importe et intègre les fichiers fournis.
- **À G7 :** les visuels intégrés sont cohérents en palette/cadrage/lumière fantasy semi-réaliste ; preuve sur captures 1920×1080 et 1280×720, plus captures du plateau 24/24, de la main, du tooltip et de l’inspecteur.
- **À G8 :** les 13 critères UI passent une revue humaine ; aucun asset dépourvu de droits connus, aucun texte critique caché, pas de retour visuel issu d’un état obsolète.

**Avertissement de portée :** si les illustrations définitives ne sont pas fournies/produites, le moteur peut être fonctionnel mais **le gate visuel G7, et donc le Lot 1, reste non validé**.

## F. Matrice des jalons / état d’avancement

Cette matrice est volontairement **à suivre après chaque prompt**. État initial : aucune preuve d’exécution dans le dépôt cible n’est présumée.

| Gate | Prompts | Preuve attendue | État initial |
|---|---:|---|---|
| G0 — Socle | P001–P004 | Projet Godot importable + tests/consignes IA | NOT STARTED |
| G1 — Socle graphique | P005–P010 | Composants premium, plateau, tooltip/inspection | NOT STARTED |
| G2 — Catalogue et état | P011–P020 | 16 ressources + decks de 40 + seed stable | NOT STARTED |
| G3 — Règles de base | P021–P031 | Combat scripté reproductible, règles essentielles | NOT STARTED |
| G4 — Duel écran intermédiaire | P032–P037 | Souris + écran jouable contre opposant basique | NOT STARTED |
| G5 — Catalogue complet Lot 1 | P038–P048 | Tous les types et capacités simples réellement actifs | NOT STARTED |
| G6 — IA V1 | P049–P053 | Duel autonome, légal et sans triche | NOT STARTED |
| G7 — Présentation professionnelle | P054–P060 | Assets et VFX originaux, captures 1080/720 | NOT STARTED |
| G8 — Acceptation | P061–P065 | 45 tests, E2E, export Windows, dossier PASS | NOT STARTED |

## G. Critères d’arrêt et traitement des anomalies

- **Bloquant immédiat :** parse/import Godot en erreur, test métier existant en échec, fuite d’information cachée, action illégale acceptée, inventaire de cartes incohérent, carte exécutée via branche hardcodée, erreur technique laissant commit partiel, VFX modifiant la logique.
- **Bloquant de gate visuel :** éléments illisibles en 720p, plateau non accessible 24/24, tooltip/inspection incomplets, animations masquant durablement PV/cibles, assets provisoires ou sous droits non clarifiés.
- **Correction :** produire un **prompt correctif ciblé rattaché au prompt fautif**, rejouer les tests affectés et laisser l’ID du prompt suivant inchangé. Ne pas utiliser une « grande refonte » pour corriger un problème local.
- **Mesure d’avancement :** nombre de prompts acceptés **et**, surtout, gates réellement passés. 65/65 prompts rédigés ne signifient pas que le Lot 1 est terminé si G8 manque.

## H. Format du futur prompt unique

```text
[LOT1 — PNNN — Titre exact du jalon]
OBJECTIF UNIQUE
  <une fonctionnalité vérifiable, pas tout le sous-système>
SOURCES
  docs/specs/LOT1.md, IDs de règles et de tests applicables
CONTEXTE DU DÉPÔT
  fichiers existants, signatures déjà implémentées, état du jalon précédent
FICHIERS AUTORISÉS
  liste limitative (+ tests pertinents)
CONTRATS / INVARIANTS
  types, ordre des opérations, données privées, règles intouchables
IMPLÉMENTATION DEMANDÉE
  étapes locales et exemples limités
TESTS À CRÉER OU REJOUER
  commandes exécutables et assertions exactes
CONDITION DE TERMINÉ
  preuve observable et critères PASS/FAIL/NOT RUN
SORTIE DE L’AGENT
  liste fichiers, diff synthétique, commandes/résultats, risques et blocages
```

**Exécution recommandée :** un seul prompt à la fois, revue par l’utilisateur dans VS Code, puis validation avant de préparer le suivant. Pour un comportement anormal, un prompt de correction spécifique ; ne pas passer immédiatement à PNNN+1.

## I. Définition de terminé du Lot 1

**G8 est PASS uniquement si les conditions suivantes sont toutes prouvées :**

1. Combat complet jouable à la souris contre IA jusqu’à victoire/défaite, puis relance ; pas de console requise pour jouer.
2. 24 slots, 16 cartes `.tres`, decks de 40, sorts, capacités simples, armes/protections, IA heuristique V1.
3. Conformité aux règles du prototype : tours, pioche/fatigue, ciblage, dégâts et protections, FIFO/stabilisation, déterminisme, contrôle des informations cachées.
4. Graphisme fantasy semi-réaliste original, écussons, 3 niveaux d’information, animations expressives et lisibilité confirmée sur 1920×1080 et 1280×720.
5. **45 scénarios d’acceptation** exécutés et PASS, sans FAIL ou NOT RUN masqué ; preuves consultables.
6. Build Godot importable et export Windows réellement testé, inventaire des assets et droits documentés.

Ensuite seulement : **Lot 2**, ciblé sur l’extensibilité réelle et l’enrichissement raisonnable du gameplay avant d’engager la spécification/implémentation de l’exploration de tour. Les ~170 définitions complètes ne sont pas un préalable au Lot 3.

**Premier futur prompt à préparer, lorsque le développement commencera : `P001 — Créer le dépôt Godot 4`.**
