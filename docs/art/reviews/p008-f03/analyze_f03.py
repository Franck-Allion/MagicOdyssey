"""
Read-only analysis of original GPU captures for P008-F03.
Measures real rasterized glyphs at 1080p and 720p and compares V03 vs Variant B vs V05.
"""

from pathlib import Path
import json
import numpy as np
from PIL import Image

OUT = Path(__file__).resolve().parent

def run():
    print("Running P008-F03 glyph measurement analysis...")
    probes_dir = OUT / "probes"
    probe_files = sorted(probes_dir.glob("v05_*.png"))
    print(f"Found {len(probe_files)} probe files.")
    
    measurements = []
    
    for p in probe_files:
        # Format: v05_{Stat}_{Val}_{Res}p.png
        parts = p.stem.split("_")
        stat_name = parts[1]
        val = int(parts[2])
        res = int(parts[3][:-1])
        
        img = Image.open(p).convert("RGBA")
        arr = np.array(img)
        
        # Bright white ink criterion: alpha>=128 and R>=150, G>=150, B>=140
        ink_mask = (arr[:,:,3] >= 128) & (arr[:,:,0] >= 150) & (arr[:,:,1] >= 150) & (arr[:,:,2] >= 140)
        all_alpha_mask = arr[:,:,3] > 0
        
        if np.any(ink_mask):
            iy, ix = np.where(ink_mask)
            ink_bbox = [int(ix.min()), int(iy.min()), int(ix.max() - ix.min() + 1), int(iy.max() - iy.min() + 1)]
        else:
            ink_bbox = [0, 0, 0, 0]
            
        if np.any(all_alpha_mask):
            ay, ax = np.where(all_alpha_mask)
            alpha_bbox = [int(ax.min()), int(ay.min()), int(ax.max() - ax.min() + 1), int(ay.max() - ay.min() + 1)]
        else:
            alpha_bbox = [0, 0, 0, 0]
            
        measurements.append({
            "stat": stat_name,
            "value": val,
            "resolution": res,
            "bright_ink_bbox_xywh": ink_bbox,
            "all_alpha_bbox_xywh": alpha_bbox,
            "ink_width": ink_bbox[2],
            "ink_height": ink_bbox[3]
        })
        
    out_json = OUT / "measurements.json"
    out_json.write_text(json.dumps({
        "method": "GPU probes; bright ink alpha>=128 and RGB>=150/150/140; all-alpha separately includes outline and shadow.",
        "measurements": measurements
    }, indent=2) + "\n")
    print(f"Saved {out_json}")
    
    # Print summary of 720p values
    print("\n--- 720p Ink Height Summary ---")
    for stat in ["Attack", "Health", "Armor", "Shield"]:
        items = [m for m in measurements if m["stat"] == stat and m["resolution"] == 720]
        h_map = {m["value"]: m["ink_height"] for m in items}
        print(f"  {stat:6s}: {h_map}")

if __name__ == "__main__":
    run()
