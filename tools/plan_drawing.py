#!/usr/bin/env python3
"""Draws a blueprint-style technical layout from a plan's slots.json entry (needs: pip install pillow).

  python tools/plan_drawing.py fabrika_30x20 --width-m 20 --length-m 30 --name "Millbrook Bay Plant" --out godot/art/floor/teknik
"""
import argparse
import json
import os
from PIL import Image, ImageDraw, ImageFont

BG = (10, 28, 44)
GRID = (22, 52, 76)
GRID5 = (34, 74, 104)
WALL = (214, 232, 244)
CYAN = (110, 200, 235)
SLOT = (255, 191, 0)
TEXT = (226, 238, 246)
FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
FONT_B = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"


def dashed_rect(draw, box, color, width, dash=18, gap=10):
    x0, y0, x1, y1 = box
    for (ax, ay, bx, by) in ((x0, y0, x1, y0), (x1, y0, x1, y1), (x1, y1, x0, y1), (x0, y1, x0, y0)):
        length = max(abs(bx - ax), abs(by - ay))
        steps = int(length // (dash + gap)) + 1
        dx = (bx - ax) / length
        dy = (by - ay) / length
        for i in range(steps):
            s = i * (dash + gap)
            e = min(s + dash, length)
            draw.line((ax + dx * s, ay + dy * s, ax + dx * e, ay + dy * e), fill=color, width=width)


def arrow_line(draw, a, b, color, width=2):
    draw.line((a, b), fill=color, width=width)
    for p, q in ((a, b), (b, a)):
        dx, dy = q[0] - p[0], q[1] - p[1]
        n = (dx * dx + dy * dy) ** 0.5
        dx, dy = dx / n, dy / n
        px, py = -dy, dx
        draw.polygon([p, (p[0] + dx * 14 + px * 5, p[1] + dy * 14 + py * 5), (p[0] + dx * 14 - px * 5, p[1] + dy * 14 - py * 5)], fill=color)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("stem")
    parser.add_argument("--width-m", type=float, required=True)
    parser.add_argument("--length-m", type=float, required=True)
    parser.add_argument("--name", default="")
    parser.add_argument("--plans", default="godot/art/floor/plans")
    parser.add_argument("--out", default="godot/art/floor/teknik")
    args = parser.parse_args()
    data = json.load(open(os.path.join(args.plans, "slots.json")))
    slots = data[args.stem]
    src = Image.open(os.path.join(args.plans, args.stem + ".jpg"))
    W, H = src.size
    pad = 120
    # the photo has a light frame: the building itself is the inner rectangle
    inner = (22, 22, W - 22, H - 22)
    ppm = (inner[2] - inner[0]) / args.width_m
    img = Image.new("RGB", (W + pad * 2, H + pad * 2 + 60), BG)
    d = ImageDraw.Draw(img)
    ox, oy = pad, pad
    f_small = ImageFont.truetype(FONT, 20)
    f_mid = ImageFont.truetype(FONT, 26)
    f_big = ImageFont.truetype(FONT_B, 34)
    bx0, by0, bx1, by1 = inner[0] + ox, inner[1] + oy, inner[2] + ox, inner[3] + oy
    # metre grid
    x = 0.0
    while x <= args.width_m + 1e-6:
        px = bx0 + x * ppm
        d.line((px, by0, px, by1), fill=GRID5 if int(round(x)) % 5 == 0 else GRID, width=1)
        x += 1
    y = 0.0
    while y <= args.length_m + 1e-6:
        py = by0 + y * ppm
        d.line((bx0, py, bx1, py), fill=GRID5 if int(round(y)) % 5 == 0 else GRID, width=1)
        y += 1
    # walls: double line
    for off, w in ((0, 5), (-12, 2)):
        d.rectangle((bx0 + off, by0 + off, bx1 - off, by1 - off), outline=WALL, width=w)
    # doors: where the photo has hazard-striped ramps (top and bottom, two each), drawn as a gap with swing marks
    door_w = 205
    for cx_ratio in (0.235, 0.775):
        cx = bx0 + cx_ratio * (bx1 - bx0)
        for top in (True, False):
            y_wall = by0 if top else by1
            x0, x1 = cx - door_w / 2, cx + door_w / 2
            d.rectangle((x0, y_wall - 14, x1, y_wall + 14), fill=BG)
            d.line((x0, y_wall, x1, y_wall), fill=SLOT, width=3)
            for k in range(0, int(door_w), 22):
                a = (x0 + k, y_wall + (-14 if top else 14))
                b = (x0 + k + 14, y_wall + (14 if top else -14))
                d.line((a, b), fill=SLOT, width=2)
            d.line((x0, y_wall - 14, x0, y_wall + 14), fill=WALL, width=3)
            d.line((x1, y_wall - 14, x1, y_wall + 14), fill=WALL, width=3)
            d.text((cx, y_wall + (-34 if top else 34)), "RAMPA", font=f_small, fill=SLOT, anchor="mm")
    # slots
    for i, (sx, sy, sw, sh) in enumerate(slots):
        x0, y0 = sx * W + ox, sy * H + oy
        x1, y1 = x0 + sw * W, y0 + sh * H
        dashed_rect(d, (x0, y0, x1, y1), SLOT, 4)
        c = 26
        for (cx, cy, dx, dy) in ((x0, y0, 1, 1), (x1, y0, -1, 1), (x0, y1, 1, -1), (x1, y1, -1, -1)):
            d.line((cx, cy, cx + dx * c, cy), fill=SLOT, width=7)
            d.line((cx, cy, cx, cy + dy * c), fill=SLOT, width=7)
        mx, my = (x0 + x1) / 2, (y0 + y1) / 2
        d.line((mx - 14, my, mx + 14, my), fill=CYAN, width=2)
        d.line((mx, my - 14, mx, my + 14), fill=CYAN, width=2)
        d.text((x0 + 14, y0 + 12), "T-%02d" % (i + 1), font=f_mid, fill=SLOT)
        wm, hm = sw * W / ppm, sh * H / ppm
        d.text((mx, y1 - 18), ("%.1f × %.1f m" % (wm, hm)).replace(".", ","), font=f_small, fill=CYAN, anchor="ms")
    # dimension lines
    ya = by0 - 54
    arrow_line(d, (bx0, ya), (bx1, ya), CYAN)
    d.text(((bx0 + bx1) / 2, ya - 8), ("%g m" % args.width_m).replace(".", ","), font=f_mid, fill=CYAN, anchor="ms")
    for px in (bx0, bx1):
        d.line((px, ya - 10, px, by0 - 8), fill=CYAN, width=1)
    xa = bx0 - 54
    arrow_line(d, (xa, by0), (xa, by1), CYAN)
    label = Image.new("RGBA", (200, 40), (0, 0, 0, 0))
    ImageDraw.Draw(label).text((100, 20), ("%g m" % args.length_m).replace(".", ","), font=f_mid, fill=CYAN, anchor="mm")
    img.paste(label.rotate(90, expand=True), (int(xa - 50), int((by0 + by1) / 2 - 100)), label.rotate(90, expand=True))
    for py in (by0, by1):
        d.line((xa - 10, py, bx0 - 8, py), fill=CYAN, width=1)
    # title block
    ty = img.size[1] - 74
    d.rectangle((bx0, ty, bx1, ty + 56), outline=WALL, width=2)
    d.text((bx0 + 16, ty + 28), "%s" % args.name.upper(), font=f_big, fill=TEXT, anchor="lm")
    total = args.width_m * args.length_m
    d.text((bx1 - 16, ty + 28), ("%d m²  ·  %d TEZGAH  ·  KUŞBAKIŞI YERLEŞİM" % (round(total), len(slots))), font=f_small, fill=CYAN, anchor="rm")
    os.makedirs(args.out, exist_ok=True)
    path = os.path.join(args.out, args.stem + "_teknik.png")
    img.save(path)
    print("saved", path, img.size)


if __name__ == "__main__":
    main()
