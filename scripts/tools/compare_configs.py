"""
Compare Configuration 1 (Raised Variant B layout) vs Configuration 2 (Housing baseline layout) on V05.
"""

from PIL import Image, ImageDraw, ImageFont, ImageOps, ImageEnhance
import numpy as np

# Load assets
v05 = Image.open("assets/textures/tokens/mo_creature_token_frame_v05_final.png").convert("RGBA")
inlay_atk = Image.open("assets/textures/cards/icons/mo_inlay_attack.png").convert("RGBA")
inlay_hlth = Image.open("assets/textures/cards/icons/mo_inlay_health.png").convert("RGBA")
plate_arm = Image.open("assets/textures/cards/icons/mo_plate_armor.png").convert("RGBA")
plate_shd = Image.open("assets/textures/cards/icons/mo_plate_shield.png").convert("RGBA")
portrait_raw = Image.open("assets/_source/lot1/cards/illustrations/mo_illustration_arcane_knight_test_v01.png").convert("RGBA")

# Font for numbers
font_path = "C:/Windows/Fonts/arialbd.ttf"

def render_token(config_type, values=(12, 14, 10, 12)):
    atk_val, hlth_val, arm_val, shd_val = values
    
    comp = Image.new("RGBA", (1536, 1024), (20, 24, 30, 255))
    
    # Portrait
    # In V05, portrait aperture is X in [94, 1444], Y in [98, 772]
    p_fit = ImageOps.fit(portrait_raw, (1350, 674), centering=(0.5, 0.2))
    comp.paste(p_fit, (94, 98), p_fit)
    
    # Attack and Health centers in V05: (216, 823) and (1320, 823)
    # Or in Variant B: (204, 821) and (1332, 821)
    if config_type == "raised_b":
        atk_c = (204, 821)
        hlth_c = (1332, 821)
        arm_c = (588, 653)
        shd_c = (948, 653)
        arm_size = (319, 110)
        shd_size = (319, 122)
        font_p_size = 280
        font_s_size = 190
    else: # "v05_calibrated"
        # Calibrated directly to V05's actual physical cavities:
        atk_c = (216, 823)
        hlth_c = (1320, 823)
        arm_c = (555, 851)
        shd_c = (970, 851)
        # Sized to fit inside the 391x179 and 401x179 housings
        arm_size = (360, 124)
        shd_size = (360, 138)
        font_p_size = 260
        font_s_size = 190

    # Inlays behind frame
    atk_inlay_scaled = inlay_atk.resize((380, 380), Image.Resampling.LANCZOS)
    hlth_inlay_scaled = inlay_hlth.resize((380, 380), Image.Resampling.LANCZOS)
    comp.paste(atk_inlay_scaled, (atk_c[0] - 190, atk_c[1] - 190), atk_inlay_scaled)
    comp.paste(hlth_inlay_scaled, (hlth_c[0] - 190, hlth_c[1] - 190), hlth_inlay_scaled)
    
    # Frame on top
    comp.alpha_composite(v05)
    
    # Plaques
    if arm_val > 0:
        arm_p = plate_arm.resize(arm_size, Image.Resampling.LANCZOS)
        comp.paste(arm_p, (arm_c[0] - arm_size[0]//2, arm_c[1] - arm_size[1]//2), arm_p)
    if shd_val > 0:
        shd_p = plate_shd.resize(shd_size, Image.Resampling.LANCZOS)
        comp.paste(shd_p, (shd_c[0] - shd_size[0]//2, shd_c[1] - shd_size[1]//2), shd_p)
        
    # Draw numbers
    draw = ImageDraw.Draw(comp)
    font_p = ImageFont.truetype(font_path, font_p_size)
    font_s = ImageFont.truetype(font_path, font_s_size)
    
    def draw_num(c, val, font, stroke=10):
        text = str(val)
        bbox = draw.textbbox((0, 0), text, font=font, stroke_width=stroke)
        w = bbox[2] - bbox[0]
        h = bbox[3] - bbox[1]
        x = c[0] - w // 2 - bbox[0]
        y = c[1] - h // 2 - bbox[1]
        draw.text((x, y), text, font=font, fill="white", stroke_fill="black", stroke_width=stroke)
        
    draw_num(atk_c, atk_val, font_p)
    draw_num(hlth_c, hlth_val, font_p)
    if arm_val > 0:
        draw_num(arm_c, arm_val, font_s)
    if shd_val > 0:
        draw_num(shd_c, shd_val, font_s)
        
    return comp

c1 = render_token("raised_b")
c1.save("docs/art/reviews/p008-f03/comp_config1_raised_b.png")

c2 = render_token("v05_calibrated")
c2.save("docs/art/reviews/p008-f03/comp_config2_v05_calibrated.png")

print("Saved config1 and config2 composites.")
