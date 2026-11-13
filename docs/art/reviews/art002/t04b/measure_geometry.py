"""Read-only measurement of the painted inner socket edges; no artwork edits.

Cast 360 rays from the old registration points. Find the first warm bronze
pixel from radius 55..115. Fit circles at three brightness thresholds to
avoid choosing one highlight edge. These are painted rings, not ideal circles.
"""
import json
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[5]
SOURCE = ROOT / "assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png"
OLD = {"mana": (154, 157), "attack": (157, 1284), "health": (934, 1284)}
pixels = np.array(Image.open(SOURCE).convert("RGB"), dtype=float)
result = {}
for name, origin in OLD.items():
    fits = []
    for threshold in (65, 70, 80):
        points = []
        for angle in np.linspace(0, 2 * np.pi, 360, endpoint=False):
            for radius in np.arange(55, 115, 0.5):
                x, y = np.round(np.array(origin) + radius * np.array([np.cos(angle), np.sin(angle)])).astype(int)
                red, green, blue = pixels[y, x]
                if red > threshold and green > 35 and red > blue * 1.35 and red > green * 1.1:
                    points.append((x, y))
                    break
        points = np.array(points)
        x, y = points.T
        cx, cy, constant = np.linalg.lstsq(
            np.column_stack([2 * x, 2 * y, np.ones(len(x))]), x * x + y * y, rcond=None
        )[0]
        fits.append({"threshold": threshold, "rays": len(points), "center": [cx, cy],
                     "radius": float(np.sqrt(constant + cx * cx + cy * cy))})
    median = np.median([fit["center"] for fit in fits], axis=0)
    center = np.round(median).astype(int)
    # Nearest low-threshold warm metal pixel bounds a conservative circular area.
    yy, xx = np.mgrid[center[1]-110:center[1]+111, center[0]-110:center[0]+111]
    patch = pixels[yy, xx]
    red, green, blue = patch.transpose(2, 0, 1)
    metal = (red > 55) & (green > 35) & (red > blue * 1.35) & (red > green * 1.1)
    distance = np.sqrt((xx-center[0])**2 + (yy-center[1])**2)
    nearest = float(distance[metal].min())
    result[name] = {"old_center": origin, "fits": fits,
                    "median_center": median.tolist(), "rounded_center": center.tolist(),
                    "registration_delta": (center-np.array(origin)).tolist(),
                    "nearest_detected_metal": nearest}
destination = Path(__file__).with_name("socket_geometry.json")
destination.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
print(destination.read_text(encoding="utf-8"))
