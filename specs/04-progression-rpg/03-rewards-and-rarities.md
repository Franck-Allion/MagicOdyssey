# Combat Rewards, Card Rarities, and Ascension

**Normative References:** Decisions Q175, Q176, Q177, Q178, Q179, Q180, Q181, Q182, Q183, Q184.

---

## 1. Post-Combat Reward Structure [Q175–Q177]

Upon successfully winning a combat encounter, the player receives:
1. **Card Draft [Q175]:** A choice of **1 card selected from 3 offered cards** generated according to current floor drop rates. The player may also skip taking a card to keep their deck lean.
2. **Gold Currency [Q176]:** Used at Tower Merchants for card purchases, card removals, and relic acquisitions.
3. **Sphere Points:** Progression currency invested into the Hero Sphere Grid [Q185].
4. **Boss Relics [Q177]:** Defeating a Tower Floor Boss grants a choice of powerful persistent artifacts that alter combat rules for the remainder of the run.

---

## 2. The Five Card Rarities [Q181]

All cards belong to one of five established rarity tiers:

| Rarity Tier | Color Code | Distinct Visual Signatures | Typical Drop Probability |
|---|---|---|:---:|
| **COMMON** | White / Silver | Smooth iron/slate border, circular gem | Baseline (~60%) |
| **UNCOMMON** | Blue (Azure) | Carved bronze/steel border, diamond gem | Moderate (~28%) |
| **RARE** | Red (Ruby) | Gilded filigree border, multifaceted gem | High value (~9%) |
| **EPIC** | Purple (Amethyst) | Runic etched border, radiant star gem | Exceptional (~2.5%) |
| **LEGENDARY** | Gold (Solar) | Dragon-crested golden border, animated glow | Elite (~0.5%) |

*Accessibility Mandate [Q181, Q295]:* Color hue is never the sole indicator of rarity. Each rarity tier features distinct frame geometry, corner flourishes, and accessible text labels.

---

## 3. Relics and Run Artifacts [Q178–Q180]

- **Relics** are passive artifacts collected during a run that remain active across all combat encounters.
- Examples include:
  - *Shield Ring:* Grants hero 3 shield at the start of combat.
  - *Whetstone:* Allied units in Column 1 gain +1 Attack.
- Relic modifiers integrate into the engine via standard passive ability hooks and are visible in the HUD.
