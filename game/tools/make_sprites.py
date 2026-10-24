#!/usr/bin/env python3
"""Prepare les sprites du cosmonaute (pack v6 : recadrages a fond flou/texture) pour le jeu.

Usage : python3 game/tools/make_sprites.py <dossier_du_pack> [dossier_sortie]
  - detoure le scaphandrier (alpha du pack, ou remplissage depuis les bords pour le saut),
  - ne garde que le personnage (retire la console, les traits parasites),
  - met tout a la meme echelle, pieds en bas, sur un canevas commun (CAN_W x CAN_H),
  - ecrit assets/sprites/<nom>.png avec les noms attendus par src/game.lua.
Le jeu les dessine a l'echelle 2 (1 pixel de sprite = 1 pixel ecran AKA).
"""
import os, sys
import numpy as np
from PIL import Image
from scipy import ndimage as ndi

CAN_H = 38          # hauteur du canevas (le jeu dessine a 76 px virtuels = echelle 2)
STAND = 35          # hauteur du personnage debout, en pixels de sprite
SRC = sys.argv[1] if len(sys.argv) > 1 else "pack"
OUT = sys.argv[2] if len(sys.argv) > 2 else os.path.join(os.path.dirname(__file__), "..", "assets", "sprites")

def visor_mask(rgb):
    r, g, b = rgb[..., 0].astype(int), rgb[..., 1].astype(int), rgb[..., 2].astype(int)
    return (b > 90) & (r < 70) & (g < 100)

def cut_rgba(img, left=False):
    """Pack avec alpha doux : seuil, plus grande zone contenant la visiere, trous rebouches, bord erode."""
    a = np.array(img.getchannel("A")).astype(int)
    rgb = np.array(img.convert("RGB"))
    m = a > 120
    lab, n = ndi.label(m)
    if n == 0:
        return None
    v = visor_mask(rgb) & m
    best, score = 1, -1
    for k in range(1, n + 1):
        s = int(v[lab == k].sum()) * 1000 + int((lab == k).sum())
        if s > score:
            best, score = k, s
    if left:   # planche d'interaction : le personnage est la grande zone la plus a gauche
        sizes = ndi.sum(m, lab, range(1, n + 1))
        big = [k for k in range(1, n + 1) if sizes[k - 1] >= 0.25 * sizes.max()]
        best = min(big, key=lambda k: np.where((lab == k).any(axis=0))[0].min())
    m = ndi.binary_fill_holes(lab == best)
    m = ndi.binary_erosion(m, iterations=1)
    return rgb, m

def drop_console(rgb, m):
    """Planches d'interaction : la console (ardoise sombre, a droite) est dessinee par le jeu ; on la retire.
    A droite du bord de la console on ne garde que ce qui est clair ou orange (gant, manche) : la main reste entiere."""
    r, g, b = rgb[..., 0].astype(int), rgb[..., 1].astype(int), rgb[..., 2].astype(int)
    slate = (b - r > 6) & (r < 95) & (g < 105) & (b > 40)
    h, w = m.shape
    xs = np.where(m.any(axis=0))[0]
    cols = slate[h // 3:, :].sum(axis=0)
    edge = None
    for x in range(xs.min() + (xs.max() - xs.min()) // 2, xs.max() + 1):
        if cols[x] >= 18 and cols[x:x + 6].min() >= 14:
            edge = x
            break
    if edge is None:
        return m
    lum = (r + g + b) / 3
    sat = rgb.max(axis=2).astype(int) - rgb.min(axis=2).astype(int)
    screen = (b > 140) & (r < 110)          # ecran bleu / lueur cyan
    keep = ((lum >= 150) | ((sat >= 80) & (r > 150))) & ~screen
    m = m.copy()
    m[:, edge - 2:] &= keep[:, edge - 2:]
    lab, n = ndi.label(m)
    if n > 1:
        sizes = ndi.sum(m, lab, range(1, n + 1))
        m = lab == (1 + int(np.argmax(sizes)))
    return m

def cut_flat(img):
    """Pack sans alpha (saut) : le fond est un gris texture, borde par le contour sombre du personnage."""
    rgb = np.array(img.convert("RGB"))
    lum = rgb.astype(int).sum(axis=2) / 3
    sat = rgb.max(axis=2).astype(int) - rgb.min(axis=2).astype(int)
    # le fond : clair, peu sature ; le personnage est entoure d'un contour sombre ou colore
    bgish = (lum > 120) & (sat < 40)
    lab, n = ndi.label(bgish)
    border = set(lab[0, :]) | set(lab[-1, :]) | set(lab[:, 0]) | set(lab[:, -1])
    border.discard(0)
    bg = np.isin(lab, list(border))
    m = ~bg
    lab, n = ndi.label(m)
    v = visor_mask(rgb) & m
    best, score = 1, -1
    for k in range(1, n + 1):
        s = int(v[lab == k].sum()) * 1000 + int((lab == k).sum())
        if s > score:
            best, score = k, s
    m = ndi.binary_fill_holes(lab == best)
    m = ndi.binary_opening(m, iterations=1)
    m = ndi.binary_erosion(m, iterations=1)
    return rgb, m

def cut(path):
    img = Image.open(path)
    flat = img.mode == "RGB" or np.array(img.convert("RGBA").getchannel("A")).min() == 255
    r = cut_flat(img) if flat else cut_rgba(img, left="interaction" in path)
    if r is not None and "interaction" in path and np.ptp(np.where(r[1].any(axis=0))[0]) > 75:
        r = (r[0], drop_console(r[0], r[1]))
    return r

def bbox(m):
    ys, xs = np.where(m)
    return xs.min(), ys.min(), xs.max() + 1, ys.max() + 1

def build(files, mirror=False):
    """files : chemins d'un meme ensemble -> liste d'images RGBA (canevas commun)."""
    items = []
    for f in files:
        r = cut(os.path.join(SRC, f))
        rgb, m = r
        if mirror:
            rgb, m = rgb[:, ::-1], m[:, ::-1]
        x0, y0, x1, y1 = bbox(m)
        items.append((rgb, m, (x0, y0, x1, y1)))
    hmax = max(b[3] - b[1] for _, _, b in items)
    s = STAND / hmax
    cxs = []
    for rgb, m, b in items:
        ys, xs = np.where(m)
        cxs.append(xs.mean())
    anchor = float(np.median(cxs))
    return items, s, anchor

OUTLINE = (28, 36, 50)

def clean(px, glow_off=False):
    """Nettoyage final a la taille du jeu : pixels isoles, lueur cyan de la console, liseres clairs du fond."""
    a = px[..., 3] > 0
    rgb = px[..., :3].astype(int)
    px = px.copy()
    # lueur cyan de l'ecran de la console (hors combinaison : tres cyan et clair)
    glow = a & (rgb[..., 1] > 170) & (rgb[..., 2] > 190) & (rgb[..., 0] < 190) & (rgb[..., 2] - rgb[..., 0] > 40)
    # (la visiere est bleu fonce : elle n'est pas touchee)
    if glow_off:
        a = a & ~glow
    # une seule zone connexe (8 voisins)
    lab, n = ndi.label(a, structure=np.ones((3, 3)))
    if n > 1:
        sizes = ndi.sum(a, lab, range(1, n + 1))
        a = lab == (1 + int(np.argmax(sizes)))
    # trous interieurs (casque, jambes) : rebouches avec la couleur du pixel plein le plus proche
    holes = ndi.binary_fill_holes(a) & ~a
    if holes.any():
        idx = ndi.distance_transform_edt(~a, return_distances=False, return_indices=True)
        px[holes, :3] = px[idx[0][holes], idx[1][holes], :3]
        rgb = px[..., :3].astype(int)
        a = a | holes
    # pixels trop peu entoures : on les retire (deux passes)
    for _ in range(2):
        nb = ndi.convolve(a.astype(int), np.ones((3, 3), int), mode="constant") - a
        a = a & (nb >= 3)
    lab, n = ndi.label(a, structure=np.ones((3, 3)))
    if n > 1:
        sizes = ndi.sum(a, lab, range(1, n + 1))
        a = lab == (1 + int(np.argmax(sizes)))
    # lisere : pixel de bord clair et peu sature -> couleur de contour sombre
    er = ndi.binary_erosion(a, structure=np.ones((3, 3)), border_value=0)
    edge = a & ~er
    lum = rgb.sum(axis=2) / 3
    sat = rgb.max(axis=2) - rgb.min(axis=2)
    fringe = edge & (lum > 150) & (sat < 45)
    out = px.copy()
    out[fringe, :3] = OUTLINE
    if glow_off:   # interaction, bras tendu vers la console : le gant du pack est masque avec l'ecran, on le redessine
        cols = np.where(a.any(axis=0))[0]
        xs0, xs1 = cols.min(), cols.max()
        tipcol = a[:, xs1]
        ys = np.where(tipcol)[0]
        body_right = np.where(a[a.shape[0] * 3 // 4:, :].any(axis=0))[0].max()
        if xs1 - body_right >= 5 and len(ys) <= 6 and xs1 + 4 < a.shape[1]:
            cy = int(round(ys.mean()))
            for dx, col in ((1, (214, 220, 224)), (2, (190, 198, 206)), (3, OUTLINE)):
                for dy in (-1, 0, 1):
                    y, x = cy + dy, xs1 + dx
                    c = col if dx < 3 and abs(dy) < 2 else OUTLINE
                    if dx == 3 and abs(dy) == 1:
                        continue
                    out[y, x, :3] = c; a[y, x] = True
            for dx in (1, 2):
                for dy in (-2, 2):
                    out[cy + dy, xs1 + dx, :3] = OUTLINE; a[cy + dy, xs1 + dx] = True
    out[..., 3] = np.where(a, 255, 0)
    out[~a, :3] = 0
    return out

def render(items, s, anchor, can_w, glow_off=False):
    out = []
    for rgb, m, (x0, y0, x1, y1) in items:
        rgba = np.dstack([rgb, (m * 255).astype(np.uint8)])
        im = Image.fromarray(rgba, "RGBA").crop((x0, y0, x1, y1))
        w, h = max(1, round(im.width * s)), max(1, round(im.height * s))
        # fond transparent : on pre-multiplie pour ne pas faire baver la couleur du fond
        pm = np.array(im).astype(float)
        pm[..., :3] *= pm[..., 3:] / 255.0
        small = Image.fromarray(pm.astype(np.uint8), "RGBA").resize((w, h), Image.LANCZOS)
        arr = np.array(small).astype(float)
        a = arr[..., 3:]
        arr[..., :3] = np.where(a > 0, arr[..., :3] * 255.0 / np.maximum(a, 1), 0)
        a_hard = (a > 110) * 255.0         # pas d'alpha doux : bord net pour le runtime AKA
        arr[..., 3:] = a_hard
        arr[..., :3] = np.clip(arr[..., :3], 0, 255)
        small = Image.fromarray(clean(arr.astype(np.uint8), glow_off), "RGBA")
        canvas = Image.new("RGBA", (can_w, CAN_H), (0, 0, 0, 0))
        # centre horizontal : barycentre de l'ensemble (evite le tremblement du cycle de marche)
        ys, xs = np.where(m)
        cx = (xs.mean() - x0) * s
        px = int(round(can_w / 2 - cx))
        py = CAN_H - 1 - h
        canvas.paste(small, (px, max(0, py)), small)
        out.append(canvas)
    return out

SETS = {
    # nom_sortie : (fichiers sources, miroir)
    "idle": (["idle/idle_01.png"], False),
    "walk_right": ([f"walk_right/walk_right_0{i}.png" for i in range(1, 5)], False),
    "walk_left": ([f"walk_left/walk_left_0{i}.png" for i in range(1, 5)], False),
    "jump": ([f"jump/jump_0{i}.png" for i in range(1, 9)], False),
    "jump_left": ([f"jump/jump_0{i}.png" for i in range(1, 9)], True),   # le saut est dessine vers la droite
    "interaction": ([f"interaction/interaction_0{i}.png" for i in range(1, 6)], False),
    "orient": ([f"orientations/orientation_0{i}.png" for i in range(1, 5)], False),
}
ORIENT_NAMES = ["orientation_right", "orientation_left", "orientation_up", "orientation_down"]

def main():
    os.makedirs(OUT, exist_ok=True)
    built = {}
    for key, (files, mir) in SETS.items():
        built[key] = build(files, mir)
    can_w = 0
    for key, (items, s, anchor) in built.items():
        for rgb, m, (x0, y0, x1, y1) in items:
            can_w = max(can_w, int(round((x1 - x0) * s)) + 8)
    can_w += can_w % 2
    for key, (items, s, anchor) in built.items():
        imgs = render(items, s, anchor, can_w, key == "interaction")
        if key == "orient":
            names = ORIENT_NAMES
        elif key == "idle":
            names = ["idle_01"]
        else:
            names = [f"{key}_{i + 1:02d}" for i in range(len(imgs))]
        for n, im in zip(names, imgs):
            im.save(os.path.join(OUT, n + ".png"), optimize=True)
    print("canevas", can_w, "x", CAN_H, "->", OUT)

if __name__ == "__main__":
    main()
