"""
Inspect supplied V05 asset and generate dark/light background composites.
"""

from PIL import Image, ImageOps, ImageEnhance
import numpy as np
import os
import hashlib

OUT = "docs/art/reviews/p008-f03"
os.makedirs(OUT, exist_ok=True)

SOURCE = "assets/_source/lot1/tokens/mo_creature_token_frame_v05_final.png"

def inspect_v05():
    data = open(SOURCE, "rb").read()
    sha256 = hashlib.sha256(data).hexdigest()
    print(f"V05 Source: {SOURCE}")
    print(f"Size: {len(data):,} bytes")
    print(f"SHA-256: {sha256}")
    
    img = Image.open(SOURCE).convert("RGBA")
    w, h = img.size
    print(f"Dimensions: {w}x{h}")
    assert (w, h) == (1536, 1024), "Wrong dimensions!"
    
    arr = np.array(img)
    alpha = arr[:,:,3]
    rgb = arr[:,:,:3]
    
    # Check alpha histogram
    print(f"Alpha == 0: {np.sum(alpha == 0):,} ({np.mean(alpha == 0)*100:.2f}%)")
    print(f"Alpha == 1: {np.sum(alpha == 1):,} ({np.mean(alpha == 1)*100:.2f}%)")
    print(f"Alpha 2..253: {np.sum((alpha >= 2) & (alpha <= 253)):,} ({np.mean((alpha >= 2) & (alpha <= 253))*100:.2f}%)")
    print(f"Alpha == 254: {np.sum(alpha == 254):,} ({np.mean(alpha == 254)*100:.2f}%)")
    print(f"Alpha == 255: {np.sum(alpha == 255):,} ({np.mean(alpha == 255)*100:.2f}%)")
    
    # 1. Composite over dark battlefield
    bg_field_path = "assets/_source/lot1/battlefield/wip/mo_battlefield_sundered_observatory_bg_wip_v03.png"
    if os.path.exists(bg_field_path):
        bg_dark = Image.open(bg_field_path).convert("RGBA")
        bg_dark = ImageEnhance.Brightness(ImageOps.fit(bg_dark, (1536, 1024))).enhance(0.40)
    else:
        bg_dark = Image.new("RGBA", (1536, 1024), (20, 24, 30, 255))
    
    comp_dark = bg_dark.copy()
    comp_dark.alpha_composite(img)
    comp_dark.save(f"{OUT}/v05_dark_composite.png")
    print(f"Saved {OUT}/v05_dark_composite.png")
    
    # 2. Composite over light contrasting background (246, 246, 238)
    bg_light = Image.new("RGBA", (1536, 1024), (246, 246, 238, 255))
    comp_light = bg_light.copy()
    comp_light.alpha_composite(img)
    comp_light.save(f"{OUT}/v05_light_composite.png")
    print(f"Saved {OUT}/v05_light_composite.png")
    
    # 3. Check for fringing / matte residue
    # Compare composite colors on edges
    print("Checking edge transitions...")
    # Pixels where alpha is low (2..30): check contrast against light vs dark
    low_alpha_mask = (alpha >= 2) & (alpha <= 30)
    print(f"Low alpha (2..30) pixels: {np.sum(low_alpha_mask):,}")
    
    # Check if there are any opaque pixels inside the intended transparent cavities
    # Attack cavity center box (180..250, 780..860)
    atk_cavity = alpha[780:860, 180:250]
    print(f"Attack cavity max alpha: {atk_cavity.max()}")
    
    # Health cavity center box (1280..1360, 780..860)
    hlth_cavity = alpha[780:860, 1280:1360]
    print(f"Health cavity max alpha: {hlth_cavity.max()}")
    
    # Portrait center box (600..900, 300..500)
    port_cavity = alpha[300:500, 600:900]
    print(f"Portrait cavity max alpha: {port_cavity.max()}")
    
    # Exterior corners
    corners = [(0, 0), (1535, 0), (0, 1023), (1535, 1023)]
    for cx, cy in corners:
        print(f"Corner ({cx}, {cy}) alpha: {alpha[cy, cx]}")

if __name__ == "__main__":
    inspect_v05()
