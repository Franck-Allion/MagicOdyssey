# Plateau fantasy, aide tactique et interactions — Q145 à Q154

**Statut : VALIDÉ sur décisions explicites Q145–Q154.** Ce module définit l'interface et l'aide à la décision ; il ne remplace pas les règles d'invocation, déplacement, attaque, ciblage, coûts, prise de contrôle ou déclenchement du moteur. Les exemples de chiffres ne créent pas de nouvelles mécaniques. L'implémentation et les budgets de calcul concrets restent à mesurer.

## Références croisées et ordre d'autorité

- [Organisation réelle des 6 colonnes / deux lignes par camp, ciblage et interception](../01-combat/battlefield.md) ; [attaques et ordre de résolution](../01-combat/turn-sequence.md), [résolution des dégâts](../01-combat/damage-resolution.md).
- [Invocation, restrictions et priorités de placement](../01-combat/summoning.md) ; [déplacements naturels, permutations et déplacements par effets](../01-combat/movement.md) ; [ciblage](../01-combat/targeting.md).
- [Contrôle et maladie d'invocation](../01-combat/control-transfers.md) ; [décompte des durées](../01-combat/temporary-effects.md) ; [capacités et déclenchements](../01-combat/abilities.md).
- [File d'événements et opérations atomiques](../01-combat/event-queue.md), [résolution](../01-combat/effect-resolution.md), [budgets et reproductibilité](../09-technical/causal-budgets-and-replay.md).
- [Identité visuelle des cartes et jetons](card-and-board-ui.md) ; [Juicy & Fast-Paced, feedbacks et budget d'animation](tooltips-durations-and-vfx.md) ; [tests d'acceptation](../09-technical/acceptance-tests.md) ; [journal de décisions](../DECISIONS.md).

**Séparation des domaines :** le moteur est source de vérité pour légalité et résultats ; l'interface restitue des informations contextualisées ; le simulateur de prévision travaille sur un état hypothétique isolé ; l'orchestrateur VFX ne modifie pas le combat. Une prévision n'est ni un coup joué ni une garantie de résultat futur.

## Q145 — Plateau fantasy premium et architecture modulaire (B + précision)

- **BOARD-145-01** — Direction « fantasy premium », riche, colorée, immersive ; priorité constante aux cartes et aux états tactiques.
- **BOARD-145-02** — Surface de combat : **6 colonnes × 4 lignes au total** (deux lignes offensive/défensive par camp) ; grille subtile, suffisamment compréhensible lors des interactions.
- **BOARD-145-03** — Cases discrètes au repos ; affichage renforcé au survol, pendant la sélection, le ciblage et le déplacement.
- **BOARD-145-04** — Séparer dans l'architecture la **couche décor**, la **couche ambiance**, la **couche grille tactique**, la **couche unités et interactions**, et la **couche feedback gameplay**.
- **BOARD-145-05** — **V1 : un décor fantasy unique**, sans devoir produire plusieurs arènes.
- **BOARD-145-06** — Prévoir une interface de thème/de décor pour évolution ultérieure selon tour, étage, étape, biome ou boss, sans aucune dépendance des règles du moteur au visuel choisi.
- **BOARD-145-07** — Aucune variation décorative future ne doit diminuer la lisibilité des colonnes, camps, jetons et indicateurs ; les cas d'usage multi-décors restent futurs, non engagés en V1.

## Q146 — Décor majoritairement fixe, ambiance discrète (B)

- **BOARD-146-01** — Illustration principale fixe richement travaillée ; pas d'arrière-plan intensément animé.
- **BOARD-146-02** — Petites animations environnementales facultatives (torches, poussières, halos, runes, brume légère), limitées aux zones qui ne nuisent pas à la lecture.
- **BOARD-146-03** — Les animations décoratives sont de priorité inférieure aux jetons, aux statistiques, aux aides tactiques et aux VFX de gameplay.
- **BOARD-146-04** — Les animations ambiantes peuvent être réduites/désactivées sans désactiver les informations critiques ; préserver les préférences d'accessibilité Q141.
- **BOARD-146-05** — Les futures variantes de décor pourront échanger illustration et ambiance sans refaire le système de cases.

## Q147 — Identités de camps et marquages tactiques contextuels (B personnalisé)

- **BOARD-147-01** — Identité chromatique discrète pour chaque camp, sans dépendre exclusivement de la couleur.
- **BOARD-147-02** — Pas de répétition permanente de pictogrammes épée/bouclier ou de contours de cases qui encombreraient le décor.
- **BOARD-147-03** — État au repos : priorité à l'illustration et aux unités ; l'emplacement et le rôle des lignes restent compréhensibles.
- **BOARD-147-04** — Survol / focus : révéler uniquement l'information de case pertinente (camp, ligne, emplacement).
- **BOARD-147-05** — Sélection / glisser-déposer : rendre explicites les destinations et contraintes liées à l'action.
- **BOARD-147-06** — Les indicateurs utilisent symbole, contour ou texture en plus de leur couleur ; les animations de ciblage ne masquent pas le plateau.
- **BOARD-147-07** — Retirer les indications temporaires à la fin ou à l'annulation de l'interaction.

## Q148 — Cases valides et erreurs de placement (B)

- **BOARD-148-01** — Dès la sélection ou le début du geste, le jeu affiche les **cases légalement autorisées** selon l'état moteur courant et le type d'action.
- **BOARD-148-02** — Les cases valides sont indiquées de manière légère et multimodale (symbole/contour, pas seulement une teinte).
- **BOARD-148-03** — Cases interdites neutres par défaut ; en cas de tentative de ciblage illégal, feedback local et raison courte si le moteur fournit la cause.
- **BOARD-148-04** — Masquer les indications après dépôt, annulation ou fin de sélection.
- **BOARD-148-05** — Ne pas dupliquer les règles de légalité dans le rendu ; la liste des cases valides et le rejet proviennent d'une API moteur ou d'un service conforme aux règles moteur.

## Q149 — Prévisualisation de la prochaine phase de combat à la sélection (C)

- **BOARD-149-01** — Quand une créature est sélectionnée, évaluer les conséquences de la prochaine phase de combat **sur elle et sa cible pertinente** plutôt que tracer seulement sa trajectoire généralement évidente.
- **BOARD-149-02** — Intégrer les statistiques effectives, protections, ordre des attaques, maladie d'invocation, ciblage, capacités et réactions déterministes pertinentes ; distinguer l'impact direct de l'ensemble de la phase.
- **BOARD-149-03** — Montrer PV futurs, protections consommées, mort ou survie lorsque ces résultats sont prédictibles sous les hypothèses courantes.
- **BOARD-149-04** — Une prévision déterminée exige qu'aucune branche incertaine pertinente ne la contredise ; ne jamais présenter un avenir dépendant de futures actions ou de RNG inconnue comme garanti.
- **BOARD-149-05** — Exécuter l'analyse dans une copie/snapshot isolé ; aucune écriture dans l'état réel, aucun événement réel, aucune consommation du RNG de partie, aucune réservation FIFO durable.
- **BOARD-149-06** — Aucun replay des animations de dégâts durant la prévision ; résultat compact et quasi immédiat lorsque calculable.

## Q150 — Indicateurs de PV futurs et certitude (B)

- **BOARD-150-01** — Valeurs fantômes compactes `PV actuels → PV prévus` près de la créature sélectionnée et de sa cible ; ne pas remplacer ni masquer les vrais PV/ATQ.
- **BOARD-150-02** — Crâne pour mort prévue, symbole armure/bouclier pour protection absorbée ou consommée, `?` explicite pour résultat incertain ; indices visuels distincts au-delà des seules couleurs.
- **BOARD-150-03** — État « prévision » visuellement différent d'un dégât effectivement infligé : transparence, contour, absence de secousse et de chiffres d'impact réels.
- **BOARD-150-04** — Détails de calcul et capacité impliquée accessibles dans inspection ; affichage minimal autour des jetons.
- **BOARD-150-05** — Disparition à l'annulation, déselection et après engagement de l'action ; rafraîchissement lorsque l'état pertinent change.

## Q151 — Drag-and-drop et cache de simulation (C)

- **BOARD-151-01** — Au survol d'une **case valide**, simuler la position hypothétique et montrer les conséquences pour cette position ; changer de résultat quand la case cible change.
- **BOARD-151-02** — Préférer calcul au changement de case plutôt qu'à chaque pixel/cycle de rendu ; ne pas bloquer le pointeur ni le geste tactile pendant les calculs.
- **BOARD-151-03** — Cache autorisé, indexé sur la version/empreinte pertinente de l'état, la source, la destination, l'action et les hypothèses de prévision ; invalidation si l'état réel ou les hypothèses changent.
- **BOARD-151-04** — Ignorer les résultats asynchrones tardifs relatifs à une case qui n'est plus sélectionnée ; jamais afficher une prévision d'une ancienne position sur la nouvelle.
- **BOARD-151-05** — Simulation respecte les restrictions de placement, coût et déplacement ; une unité nouvellement invoquée n'attaque pas si les règles de maladie d'invocation l'interdisent.
- **BOARD-151-06** — Survol d'une case illégale : pas de prévision de déplacement exécuté ; explication d'illégalité conformément à Q148.
- **BOARD-151-07** — Le dépôt reste revalidé par le moteur actuel, indépendamment de tout résultat en cache.

## Q152 — Prévisions progressives et limites de calcul (C)

- **BOARD-152-01** — Différencier états **déterminé**, **conditionnel/aléatoire**, **en cours** et **indisponible** ; afficher immédiatement les parties certaines lorsque possible.
- **BOARD-152-02** — Si un résultat futur est incertain, afficher `?` ou une hypothèse clairement étiquetée ; fourchette ou scénarios seulement s'ils sont fiables, avec hypothèses explicites.
- **BOARD-152-03** — Calculs sous **budget technique indépendant**, limites et coût à calibrer en prototypes ; dépassement -> « indisponible » ou résultat partiel non trompeur.
- **BOARD-152-04** — La disponibilité du calcul n'est **pas** la légalité de l'action ; une prévision lente ou impossible n'empêche pas le dépôt sur une case valide.
- **BOARD-152-05** — Ni le budget de simulation, ni le cache, ni le RNG hypothétique n'influencent les budgets/états du moteur (Q113–Q120), le replay (Q121–Q125) ou les animations (Q144).
- **BOARD-152-06** — Révision explicite des prévisions quand une information certaine supplémentaire est calculée ; ne pas afficher des résultats temporaires comme définitifs.

## Q153 — Dépôt immédiat et revalidation (B)

- **BOARD-153-01** — Dépôt sur case légale : demande d'action immédiate, **sans confirmation systématique**, même si prévision incertaine/en cours/indisponible.
- **BOARD-153-02** — Au dépôt, le moteur **revalide** source, destination, coûts, restrictions et état courant ; un aperçu antérieur n'autorise aucune exception.
- **BOARD-153-03** — Action acceptée : exécution selon l'ordre moteur, feedback d'invocation/déplacement gradué, rapide, cohérent avec Q140–Q144.
- **BOARD-153-04** — Action refusée : **aucun changement de combat** ; retour visuel de carte/jeton vers sa position d'origine, explication courte si disponible.
- **BOARD-153-05** — Annuler/ignorer les simulations précédentes à l'engagement ou au refus ; pas d'application tardive de prévision.

## Q154 — Modalités multimodales et annulation avant validation (C)

- **BOARD-154-01** — **Glisser-déposer**, **sélection par clic puis clic sur case**, et **interactions tactiles** partagent les mêmes règles d'actions et destinations valides.
- **BOARD-154-02** — Les mêmes aides (cases valides, invalidité expliquée, prévisions, incertitudes) sont accessibles au survol, au focus/sélection et au toucher adapté ; le survol physique ne doit pas être obligatoire.
- **BOARD-154-03** — Annulation possible avant validation moteur : Échap sur clavier, clic hors de la cible ou commande explicite d'annulation ; geste tactile d'annulation à définir ergonomiquement sans provoquer de dépôt involontaire.
- **BOARD-154-04** — L'annulation remet la carte ou le jeton à son état/visuel initial et masque les aides sans coût, événement ni mutation de l'état moteur.
- **BOARD-154-05** — Après validation moteur, le simple bouton « annuler la sélection » ne constitue pas un mécanisme de retour en arrière sur l'action exécutée.
- **BOARD-154-06** — États d'interaction explicites : `idle → selected/dragging → previewing → submitted/committed` ou `cancelled/refused`. Tout résultat de prévision lié à un ancien état est ignoré.
- **BOARD-154-07** — Navigation clavier/focus visible, tailles de zones tactiles, gestes précis mobile et paramètres manette restent à prototyper ; pas de fonctionnalité manette implicitement validée.

## Contraintes transversales — Juicy & Fast-Paced, performance et accessibilité

1. Le décor et les aides contextuelles n'encombrent pas le plateau au repos ; les informations apparaissent au moment pertinent (Q145–Q148).
2. Aides de prévision **sans effets d'impact réels** ; feedback expressif réservé aux actions exécutées (Q140–Q144).
3. Isoler trois budgets distincts : **budget de résolution logique** (Q113–Q120), **budget d'animation** (Q144 ; objectif indicatif 3–5 s pour chaîne complexe), **budget de prévision** (Q152 ; valeur chiffrée ouverte).
4. Les deux interfaces d'entrée et le tactile utilisent une seule validation métier. Une simulation non terminée ne retarde jamais une action légale.
5. Les marqueurs de statut sont perceptibles sans couleur, avec option de réduire l'ambiance et les mouvements, et accès sans survol.

## Ouvert après Q154 — Ne pas implémenter comme décision validée

- **Q155** et suivantes : suite de l'ergonomie du plateau, retours, actions ciblées et navigation.
- Dimensions définitives des cases, mode paysage/mobile, densité des overlays, séquences sonores et rendu exact des thèmes.
- Algorithme et budget chiffré du simulateur de prévision (temps, nombres de branches, scénarios aléatoires), seuils de cache et éventuel rendu multi-cibles global.
- Définition graphique des gestes tactiles d'annulation, des raccourcis, de la compatibilité manette et des normes de confort visuel à tester.
- Les exemples visuels de créatures, dégâts et échanges ne sont pas des formules de combat supplémentaires ; conserver la maladie d'invocation et l'absence de riposte normale Q09.
