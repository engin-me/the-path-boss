#!/usr/bin/env python3
"""Art helpers for the factory floor sprites (needs: pip install pillow).

  slice   cut a grid sheet into separate transparent PNGs (chroma-key background)
  key     remove the background of single images
  resize  shrink big images so the game folder stays small

Examples:
  python tools/art_tools.py slice sheet.png --cols 4 --rows 3 --names torna_1,torna_2,torna_3,freze_1,... --out godot/art/floor/machines
  python tools/art_tools.py key godot/art/floor/raw/forklift.png --out godot/art/floor/equipment
  python tools/art_tools.py resize godot/art/factories --max 1024
"""
import argparse
import os
import sys

from PIL import Image


def parse_color(text):
    text = text.lstrip("#")
    return tuple(int(text[i:i + 2], 16) for i in (0, 2, 4))


def distance(a, b):
    return ((a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2 + (a[2] - b[2]) ** 2) ** 0.5


def key_image(image, bg, tolerance):
    """Remove a magenta-ish background by hue (not by distance to one exact colour) and trim.

    Magentaness m = min(r, b) - g. It is large for any magenta (pure or dull), and
    near zero or negative for grays, blues, yellows and oranges, so dull/darker
    backgrounds are removed without eating the machine. Edge pixels are despilled
    so no pink fringe remains. `tolerance` shifts the sensitivity (default 70).
    """
    image = image.convert("RGBA")
    pixels = image.load()
    lo = 30.0 + (70.0 - tolerance) * 0.3   # below this: fully kept
    hi = lo + 70.0                          # above this: fully transparent
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            m = min(r, b) - g
            if m <= lo:
                if m > 0:
                    cap = g + int(lo * 0.5)
                    pixels[x, y] = (min(r, cap), g, min(b, cap), a)
                continue
            if m >= hi:
                pixels[x, y] = (0, 0, 0, 0)
                continue
            alpha = int(a * (hi - m) / (hi - lo))
            cap = g
            pixels[x, y] = (min(r, cap), g, min(b, cap), alpha)
    alpha_band = image.getchannel("A").point(lambda v: 255 if v > 128 else 0)
    box = alpha_band.getbbox()
    if box:
        pad = 2
        box = (max(0, box[0] - pad), max(0, box[1] - pad), min(image.width, box[2] + pad), min(image.height, box[3] + pad))
        image = image.crop(box)
    return image


def cmd_slice(args):
    sheet = Image.open(args.sheet).convert("RGBA")
    names = [n.strip() for n in args.names.split(",")] if args.names else []
    cell_w = sheet.width // args.cols
    cell_h = sheet.height // args.rows
    os.makedirs(args.out, exist_ok=True)
    count = 0
    for row in range(args.rows):
        for col in range(args.cols):
            index = row * args.cols + col
            name = names[index] if index < len(names) else "sprite_%02d" % (index + 1)
            if name in ("-", ""):
                continue
            cell = sheet.crop((col * cell_w, row * cell_h, (col + 1) * cell_w, (row + 1) * cell_h))
            out = key_image(cell, parse_color(args.bg), args.tol)
            if args.max:
                out.thumbnail((args.max, args.max))
            path = os.path.join(args.out, name + ".png")
            out.save(path)
            count += 1
            print("saved", path, out.size)
    print("done:", count, "sprites")


def cmd_key(args):
    os.makedirs(args.out, exist_ok=True)
    for path in args.files:
        image = key_image(Image.open(path), parse_color(args.bg), args.tol)
        if args.max:
            image.thumbnail((args.max, args.max))
        target = os.path.join(args.out, os.path.splitext(os.path.basename(path))[0] + ".png")
        image.save(target)
        print("saved", target, image.size)


def cmd_resize(args):
    changed = 0
    for root, _dirs, files in os.walk(args.folder):
        for name in files:
            if os.path.splitext(name)[1].lower() not in (".png", ".jpg", ".jpeg", ".webp"):
                continue
            path = os.path.join(root, name)
            image = Image.open(path)
            if max(image.size) <= args.max:
                continue
            image.thumbnail((args.max, args.max))
            image.save(path, quality=90) if path.lower().endswith((".jpg", ".jpeg")) else image.save(path)
            changed += 1
            print("resized", path, image.size)
    print("done:", changed, "files resized")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)
    s = sub.add_parser("slice")
    s.add_argument("sheet")
    s.add_argument("--cols", type=int, required=True)
    s.add_argument("--rows", type=int, required=True)
    s.add_argument("--names", default="")
    s.add_argument("--out", required=True)
    s.add_argument("--bg", default="FF00FF")
    s.add_argument("--tol", type=float, default=70.0)
    s.add_argument("--max", type=int, default=512, help="longest side in pixels (0 = keep)")
    s.set_defaults(func=cmd_slice)
    k = sub.add_parser("key")
    k.add_argument("files", nargs="+")
    k.add_argument("--out", required=True)
    k.add_argument("--bg", default="FF00FF")
    k.add_argument("--tol", type=float, default=70.0)
    k.add_argument("--max", type=int, default=512)
    k.set_defaults(func=cmd_key)
    r = sub.add_parser("resize")
    r.add_argument("folder")
    r.add_argument("--max", type=int, default=1024)
    r.set_defaults(func=cmd_resize)
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    sys.exit(main())
