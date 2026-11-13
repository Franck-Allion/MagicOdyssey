"""
Detailed circle fitting for Master Frame v03 Attack Socket
and Attack Cabochon V2.
"""
from pathlib import Path
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[5]
FRAME_PATH = ROOT / "assets/_source/lot1/cards/frames/mo_card_frame_master_v03.png"
ATK_V02_SRC = ROOT / "assets/_source/lot1/cards/icons/mo_stat_cabochon_attack_v02.png"
ATK_V02_RT = ROOT / "assets/textures/cards/icons/mo_cabochon_attack_v02.png"
HP_V01_SRC = ROOT / "assets/_source/lot1/cards/icons/mo_stat_cabochon_health_v01.png"

def fit_circle(points):
    points = np.array(points)
    x, y = points.T
    A = np.column_stack([2 * x, 2 * y, np.ones(len(x))])
    b = x * x + y * y
    cx, cy, c = np.linalg.lstsq(A, b, rcond=None)[0]
    r = np.sqrt(c + cx**2 + cy**2)
    return float(cx), float(cy), float(r)

def measure_frame_socket():
    img = Image.open(FRAME_PATH).convert("RGBA")
    arr = np.array(img, dtype=float)
    rgb = arr[:, :, :3]
    lum = 0.299 * rgb[:, :, 0] + 0.587 * rgb[:, :, 1] + 0.114 * rgb[:, :, 2]
    
    # Let's inspect the attack socket around (162, 1279)
    cx_est, cy_est = 162.0, 1279.0
    
    # 1. Inner circle: transition from dark core to bronze rim
    # Along 360 rays from (162, 1279)
    inner_pts = []
    outer_pts = []
    peak_pts = []
    
    for angle in np.linspace(0, 2 * np.pi, 360, endpoint=False):
        cos_a = np.cos(angle)
        sin_a = np.sin(angle)
        
        # Ray for inner edge: where lum crosses threshold or has max gradient between r=60 and 85
        r_vals = np.arange(55, 90, 0.5)
        xs = np.round(cx_est + r_vals * cos_a).astype(int)
        ys = np.round(cy_est + r_vals * sin_a).astype(int)
        lums = lum[ys, xs]
        # gradient
        grad = np.gradient(lums)
        max_idx = np.argmax(grad)
        inner_pts.append((xs[max_idx], ys[max_idx]))
        
        # Ray for peak of bronze ring
        r_peak_vals = np.arange(75, 105, 0.5)
        xs_p = np.round(cx_est + r_peak_vals * cos_a).astype(int)
        ys_p = np.round(cy_est + r_peak_vals * sin_a).astype(int)
        lums_p = lum[ys_p, xs_p]
        peak_idx = np.argmax(lums_p)
        peak_pts.append((xs_p[peak_idx], ys_p[peak_idx]))
        
        # Ray for outer edge of bronze ring: negative gradient drop between r=85 and 120
        r_out_vals = np.arange(85, 120, 0.5)
        xs_o = np.round(cx_est + r_out_vals * cos_a).astype(int)
        ys_o = np.round(cy_est + r_out_vals * sin_a).astype(int)
        lums_o = lum[ys_o, xs_o]
        grad_o = np.gradient(lums_o)
        min_idx = np.argmin(grad_o) # steepest drop
        outer_pts.append((xs_o[min_idx], ys_o[min_idx]))

    icx, icy, ir = fit_circle(inner_pts)
    pcx, pcy, pr = fit_circle(peak_pts)
    ocx, ocy, orad = fit_circle(outer_pts)
    
    print("=== FRAME ATTACK SOCKET MEASUREMENTS ===")
    print(f"Inner Edge (Aperture): Center = ({icx:.2f}, {icy:.2f}), Radius = {ir:.2f} px (Diameter = {2*ir:.2f} px)")
    print(f"Bronze Ring Peak:      Center = ({pcx:.2f}, {pcy:.2f}), Radius = {pr:.2f} px (Diameter = {2*pr:.2f} px)")
    print(f"Outer Bronze Edge:     Center = ({ocx:.2f}, {ocy:.2f}), Radius = {orad:.2f} px (Diameter = {2*orad:.2f} px)")
    
    # Also check Health socket around (919, 1279) for comparison
    h_cx_est, h_cy_est = 919.0, 1279.0
    h_inner_pts, h_outer_pts = [], []
    for angle in np.linspace(0, 2 * np.pi, 360, endpoint=False):
        cos_a = np.cos(angle)
        sin_a = np.sin(angle)
        r_vals = np.arange(55, 90, 0.5)
        xs = np.round(h_cx_est + r_vals * cos_a).astype(int)
        ys = np.round(h_cy_est + r_vals * sin_a).astype(int)
        grad = np.gradient(lum[ys, xs])
        h_inner_pts.append((xs[np.argmax(grad)], ys[np.argmax(grad)]))
        
        r_out_vals = np.arange(85, 120, 0.5)
        xs_o = np.round(h_cx_est + r_out_vals * cos_a).astype(int)
        ys_o = np.round(h_cy_est + r_out_vals * sin_a).astype(int)
        grad_o = np.gradient(lum[ys_o, xs_o])
        h_outer_pts.append((xs_o[np.argmin(grad_o)], ys_o[np.argmin(grad_o)]))
        
    h_icx, h_icy, h_ir = fit_circle(h_inner_pts)
    h_ocx, h_ocy, h_orad = fit_circle(h_outer_pts)
    print("\n=== FRAME HEALTH SOCKET MEASUREMENTS ===")
    print(f"Inner Edge (Aperture): Center = ({h_icx:.2f}, {h_icy:.2f}), Radius = {h_ir:.2f} px (Diameter = {2*h_ir:.2f} px)")
    print(f"Outer Bronze Edge:     Center = ({h_ocx:.2f}, {h_ocy:.2f}), Radius = {h_orad:.2f} px (Diameter = {2*h_orad:.2f} px)")

def measure_cabochon_features(path, name):
    img = Image.open(path).convert("RGBA")
    w, h = img.size
    arr = np.array(img, dtype=float)
    alpha = arr[:, :, 3]
    rgb = arr[:, :, :3]
    lum = 0.299 * rgb[:, :, 0] + 0.587 * rgb[:, :, 1] + 0.114 * rgb[:, :, 2]
    
    cx_est, cy_est = w / 2.0, h / 2.0
    
    # 1. Inner core boundary (transition from dark gem core to metallic rim)
    # 2. Outer rim peak
    # 3. Outer rim silhouette (e.g. alpha = 128 / alpha = 20)
    inner_pts = []
    peak_pts = []
    a128_pts = []
    a20_pts = []
    
    scale_factor = w / 1254.0
    r_core_min, r_core_max = 300 * scale_factor, 420 * scale_factor
    r_peak_min, r_peak_max = 400 * scale_factor, 480 * scale_factor
    r_alpha_min, r_alpha_max = 440 * scale_factor, 580 * scale_factor
    
    for angle in np.linspace(0, 2 * np.pi, 360, endpoint=False):
        cos_a = np.cos(angle)
        sin_a = np.sin(angle)
        
        # Inner rim rise (from core to rim)
        r_vals = np.arange(r_core_min, r_core_max, 1.0)
        xs = np.clip(np.round(cx_est + r_vals * cos_a).astype(int), 0, w-1)
        ys = np.clip(np.round(cy_est + r_vals * sin_a).astype(int), 0, h-1)
        grad = np.gradient(lum[ys, xs])
        inner_pts.append((xs[np.argmax(grad)], ys[np.argmax(grad)]))
        
        # Outer rim peak
        r_p_vals = np.arange(r_peak_min, r_peak_max, 1.0)
        xs_p = np.clip(np.round(cx_est + r_p_vals * cos_a).astype(int), 0, w-1)
        ys_p = np.clip(np.round(cy_est + r_p_vals * sin_a).astype(int), 0, h-1)
        peak_pts.append((xs_p[np.argmax(lum[ys_p, xs_p])], ys_p[np.argmax(lum[ys_p, xs_p])]))
        
        # Alpha contour at alpha=128
        r_a_vals = np.arange(r_alpha_min, r_alpha_max, 0.5)
        xs_a = np.clip(np.round(cx_est + r_a_vals * cos_a).astype(int), 0, w-1)
        ys_a = np.clip(np.round(cy_est + r_a_vals * sin_a).astype(int), 0, h-1)
        alphas = alpha[ys_a, xs_a]
        
        # find where alpha crosses 128
        idx128 = np.where(alphas < 128)[0]
        if len(idx128) > 0:
            a128_pts.append((xs_a[idx128[0]], ys_a[idx128[0]]))
        else:
            a128_pts.append((xs_a[-1], ys_a[-1]))
            
        # find where alpha crosses 20
        idx20 = np.where(alphas < 20)[0]
        if len(idx20) > 0:
            a20_pts.append((xs_a[idx20[0]], ys_a[idx20[0]]))
        else:
            a20_pts.append((xs_a[-1], ys_a[-1]))

    icx, icy, ir = fit_circle(inner_pts)
    pcx, pcy, pr = fit_circle(peak_pts)
    a128_cx, a128_cy, a128_r = fit_circle(a128_pts)
    a20_cx, a20_cy, a20_r = fit_circle(a20_pts)
    
    print(f"\n=== {name} CIRCLE FITS ({w}x{h}) ===")
    print(f"Canvas Center:                  ({w/2:.1f}, {h/2:.1f})")
    print(f"Inner Core Boundary:            Center = ({icx:.2f}, {icy:.2f}), Radius = {ir:.2f} px, Diam = {2*ir:.2f} px (rel: {2*ir/w:.4f})")
    print(f"Metallic Outer Rim Peak:        Center = ({pcx:.2f}, {pcy:.2f}), Radius = {pr:.2f} px, Diam = {2*pr:.2f} px (rel: {2*pr/w:.4f})")
    print(f"Opaque Rim Edge (alpha=128):    Center = ({a128_cx:.2f}, {a128_cy:.2f}), Radius = {a128_r:.2f} px, Diam = {2*a128_r:.2f} px (rel: {2*a128_r/w:.4f})")
    print(f"Visible Shadow Outer (alpha=20):Center = ({a20_cx:.2f}, {a20_cy:.2f}), Radius = {a20_r:.2f} px, Diam = {2*a20_r:.2f} px (rel: {2*a20_r/w:.4f})")
    
    return {
        "inner_core": (icx, icy, ir),
        "rim_peak": (pcx, pcy, pr),
        "rim_a128": (a128_cx, a128_cy, a128_r),
        "rim_a20": (a20_cx, a20_cy, a20_r),
        "w": w, "h": h
    }

if __name__ == "__main__":
    measure_frame_socket()
    measure_cabochon_features(ATK_V02_SRC, "Attack V2 Source")
    measure_cabochon_features(ATK_V02_RT, "Attack V2 Runtime")
    measure_cabochon_features(HP_V01_SRC, "Health V1 Source")
