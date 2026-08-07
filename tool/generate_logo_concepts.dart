import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

// Brand colors
const _sky = [0x0E, 0xA5, 0xE9]; // primary blue
const _navy = [0x0B, 0x1A, 0x2E]; // dark navy
const _green = [0x10, 0xB9, 0x81]; // success green
const _lightBlue = [0xCF, 0xEB, 0xF9]; // light blue
const _white = [0xFF, 0xFF, 0xFF];

math.Point<double> Point(num x, num y) => math.Point<double>(x.toDouble(), y.toDouble());

void main() {
  const s = 1024;
  final dir = Directory('assets/icon');

  _save(dir, '1.png', _concept1(s));
  _save(dir, '2.png', _concept2(s));
  _save(dir, '3.png', _concept3(s));
  _save(dir, '4.png', _concept4(s));
  _save(dir, '5.png', _concept5(s));

  print('Generated assets/icon/1.png .. 5.png');
}

void _save(Directory dir, String name, img.Image image) {
  dir.createSync(recursive: true);
  File('${dir.path}/${name}').writeAsBytesSync(img.encodePng(image));
}

// ── Concept 1: A monogram + checkmark ────────────────────────────
img.Image _concept1(int s) {
  final im = img.Image(s, s);
  _fill(im, _sky, s);

  final c = s * 0.5;
  final apex = Point(c, s * 0.24);
  final lt = Point(c - s * 0.26, s * 0.72);
  final rt = Point(c + s * 0.26, s * 0.72);
  final w = s * 0.085;

  // A strokes
  _line(im, apex, lt, w, _white);
  _line(im, apex, rt, w, _white);

  // crossbar
  final cy = s * 0.52;
  final frac = (cy - s * 0.24) / (s * 0.72 - s * 0.24);
  final xl = c - s * 0.26 * frac;
  final xr = c + s * 0.26 * frac;
  _line(im, Point(xl, cy), Point(xr, cy), w * 0.62, _white);

  // check inside
  final a = Point(c - s * 0.11, s * 0.585);
  final b = Point(c + s * 0.02, s * 0.655);
  final chk = Point(c + s * 0.14, s * 0.57);
  _line(im, a, b, s * 0.055, _green);
  _line(im, b, chk, s * 0.055, _green);
  return im;
}

// ── Concept 2: Task card with active toggle ──────────────────────
img.Image _concept2(int s) {
  final im = img.Image(s, s);
  _fill(im, _sky, s);

  // Card
  final cardTop = s * 0.14, cardBottom = s * 0.86;
  final cardL = s * 0.18, cardR = s * 0.82;
  _roundedRect(im, cardL, cardTop, cardR, cardBottom, s * 0.06, _white);

  final rows = [s * 0.30, s * 0.50, s * 0.70];
  final boxL = s * 0.30;
  final box = s * 0.115;
  final barL = s * 0.49;
  final barR = s * 0.70;

  for (var i = 0; i < 3; i++) {
    final y = rows[i];
    final bx = boxL;
    final by = y - box / 2;
    if (i == 1) {
      // checked: green fill + white check
      _roundedRect(im, bx, by, bx + box, by + box, s * 0.022, _green);
      final ch = s * 0.085;
      final cx = bx + box / 2;
      final cy = by + box / 2;
      _line(im, Point(cx - ch, cy), Point(cx - ch * 0.3, cy + ch * 0.7),
          s * 0.022, _white);
      _line(im, Point(cx - ch * 0.3, cy + ch * 0.7),
          Point(cx + ch * 0.9, cy - ch * 0.45), s * 0.022, _white);
    } else {
      _roundedRect(im, bx, by, bx + box, by + box, s * 0.022, _lightBlue);
    }
    // text bar
    final bx2 = barL;
    _roundedRect(im, bx2, y - s * 0.024, barR, y + s * 0.024, s * 0.024,
        i == 1 ? const [0xDD, 0xF1, 0xF8] : const [0xCF, 0xEB, 0xF9]);
  }
  return im;
}

// ── Concept 3: Paperclip with check tail ─────────────────────────
img.Image _concept3(int s) {
  final im = img.Image(s, s);
  _fill(im, _sky, s);

  final c = s * 0.5;
  final P = (double x, double y) => Point(c + x * s, s * 0.5 + y * s);

// continuous wire path (opens at top into the inner curl)
  _line(im, P(-0.17, 0.10), P(-0.17, -0.24), s * 0.040, _white);
  _line(im, P(-0.17, -0.24), P(-0.04, -0.30), s * 0.040, _white);
  _line(im, P(-0.04, -0.30), P(0.14, -0.28), s * 0.040, _white);
  _line(im, P(0.14, -0.28), P(0.14, 0.10), s * 0.040, _white);
  _line(im, P(0.14, 0.10), P(0.02, 0.15), s * 0.040, _white);
  _line(im, P(0.02, 0.15), P(-0.13, 0.12), s * 0.040, _white);

  // wire end into the pocket (inner curl)
  _line(im, P(0.088, -0.28), P(0.025, -0.10), s * 0.035, _white);
  _line(im, P(0.025, -0.10), P(-0.09, -0.06), s * 0.035, _white);
  _line(im, P(-0.09, -0.06), P(-0.11, 0.07), s * 0.035, _white);
  _line(im, P(-0.11, 0.07), P(0.02, 0.10), s * 0.035, _white);

  // green check dangling at the end
  _line(im, P(0.06, 0.30), P(0.02, 0.42), s * 0.032, _green);
  _line(im, P(0.02, 0.42), P(-0.08, 0.32), s * 0.032, _green);
  return im;
}

// ── Concept 4: Progress ring + check ─────────────────────────────
img.Image _concept4(int s) {
  final im = img.Image(s, s);
  _fill(im, _sky, s);

  final cx = s * 0.5, cy = s * 0.46;
  final rr = s * 0.16;
  final ringW = s * 0.05;

  // progress arc (green 230deg starting at top, white for the rest)
  _arc(im, cx, cy, rr, ringW * 1.08, -90, 230, _green);
  _arc(im, cx, cy, rr, ringW * 1.08, 140, 130, _white);

  // rounded caps on the progress arc
  _dot(im, Point(cx + rr * math.cos(-90 * math.pi / 180),
          cy + rr * math.sin(-90 * math.pi / 180)),
      ringW * 0.62, _green);
  _dot(im, Point(cx + rr * math.cos(140 * math.pi / 180),
          cy + rr * math.sin(140 * math.pi / 180)),
      ringW * 0.62, _green);

  // center check in white
  _check(im, Point(cx, cy + s * 0.02), s * 0.115, s * 0.038, _white);
  return im;
}

// ── Concept 5: "aw" wordmark ─────────────────────────────────────
img.Image _concept5(int s) {
  final im = img.Image(s, s);
  _fill(im, _navy, s);

  final ox = s * 0.5 - s * 0.5;
  final baseline = s * 0.68;

  // a bowl (sits on baseline)
  _ring(im, Point(s * 0.245 + ox, s * 0.59), s * 0.09, s * 0.055, _white);
  // a stem
  _line(im, Point(s * 0.307 + ox, s * 0.42), Point(s * 0.307 + ox, baseline),
      s * 0.055, _white);

  // w
  final wp = [
    Point(s * 0.435 + ox, baseline),
    Point(s * 0.545 + ox, s * 0.52),
    Point(s * 0.655 + ox, baseline),
    Point(s * 0.765 + ox, s * 0.52),
    Point(s * 0.875 + ox, baseline),
  ];
  _polyline(im, wp, s * 0.055, _white);

  // small green check badge at the top
  final bc = Point(s * 0.26 + ox, s * 0.33);
  _roundedRect(im, bc.x - s * 0.055, bc.y - s * 0.055, bc.x + s * 0.055,
      bc.y + s * 0.055, s * 0.028, _green);
  final ch = s * 0.062;
  _line(im, Point(bc.x - ch * 0.5, bc.y), Point(bc.x - ch * 0.12, bc.y + ch * 0.5),
      s * 0.022, _white);
  _line(im, Point(bc.x - ch * 0.12, bc.y + ch * 0.5),
      Point(bc.x + ch * 0.55, bc.y - ch * 0.35), s * 0.022, _white);
  return im;
}

// ── Primitives ─────────────────────────────────────────────────────

void _fill(img.Image im, List<int> c, int s) {
  final col = img.getColor(c[0], c[1], c[2]);
  for (var y = 0; y < s; y++) {
    for (var x = 0; x < s; x++) {
      im.setPixel(x, y, col);
    }
  }
}

void _roundedRect(img.Image im, num l, num t, num r, num b, num rad,
    List<int> c) {
  final col = img.getColor(c[0], c[1], c[2]);
  final rr = rad.round().clamp(0, 2000);
  for (var y = t.round(); y <= b.round(); y++) {
    for (var x = l.round(); x <= r.round(); x++) {
      if (_inRoundedRect(x, y, l.round(), t.round(), r.round(), b.round(), rr)) {
        im.setPixel(x, y, col);
      }
    }
  }
}

bool _inRoundedRect(int x, int y, int l, int t, int r, int b, int rr) {
  if (rr == 0) return x >= l && x <= r && y >= t && y <= b;
  if (x < l || x > r || y < t || y > b) return false;
  if (x >= l + rr && x <= r - rr) return true;
  if (y >= t + rr && y <= b - rr) return true;
  final dx = x < l + rr ? l + rr - x : x - (r - rr);
  final dy = y < t + rr ? t + rr - y : y - (b - rr);
  return dx * dx + dy * dy <= rr * rr;
}

void _line(img.Image im, math.Point<double> a, math.Point<double> b, num w,
    List<int> c) {
  final col = img.getColor(c[0], c[1], c[2]);
  final r = (w / 2).clamp(1, 500);
  _brushLine(im, a.x.round(), a.y.round(), b.x.round(), b.y.round(), r.round(),
      col);
}

void _dot(img.Image im, math.Point<double> p, num r, List<int> c) {
  _brushDot(im, p.x.round(), p.y.round(), r.round().clamp(1, 500), img.getColor(c[0], c[1], c[2]));
}

void _polyline(img.Image im, List<math.Point<double>> pts, num w, List<int> c) {
  for (var i = 0; i < pts.length - 1; i++) {
    _line(im, pts[i], pts[i + 1], w, c);
  }
}

void _check(img.Image im, math.Point<double> c, double size, double w,
    List<int> col) {
  final a = Point(c.x - size, c.y);
  final b = Point(c.x - size * 0.28, c.y + size * 0.72);
  final d = Point(c.x + size, c.y - size * 0.62);
  _line(im, a, b, w, col);
  _line(im, b, d, w, col);
}

void _ring(img.Image im, math.Point<double> c, num radius, num thickness,
    List<int> col) {
  final rIn = radius - thickness / 2;
  final rOut = radius + thickness / 2;
  final colr = img.getColor(col[0], col[1], col[2]);
  for (var y = (c.y - rOut).floor(); y <= (c.y + rOut).ceil(); y++) {
    for (var x = (c.x - rOut).floor(); x <= (c.x + rOut).ceil(); x++) {
      final d = math.sqrt((x - c.x) * (x - c.x) + (y - c.y) * (y - c.y));
      if (d >= rIn && d <= rOut) im.setPixel(x, y, colr);
    }
  }
}

void _arc(img.Image im, num cx, num cy, num radius, num thickness, num startDeg,
    num sweepDeg, List<int> col) {
  final colr = img.getColor(col[0], col[1], col[2]);
  final rIn = radius - thickness / 2;
  final rOut = radius + thickness / 2;
  final start = (startDeg * math.pi / 180) % (2 * math.pi);
  final sweep = sweepDeg.abs() * math.pi / 180;
  for (var y = (cy - rOut).floor(); y <= (cy + rOut).ceil(); y++) {
    for (var x = (cx - rOut).floor(); x <= (cx + rOut).ceil(); x++) {
      if (x == cx && y == cy) continue;
      final d = math.sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy));
      if (d < rIn || d > rOut) continue;
      var ang = math.atan2(y - cy, x - cx);
      if (ang < 0) ang += 2 * math.pi;
      final aa = (ang - start) % (2 * math.pi);
      if (aa <= sweep) im.setPixel(x, y, colr);
    }
  }
}

void _brushLine(img.Image image, int x1, int y1, int x2, int y2, int r, int color) {
  final dx = x2 - x1, dy = y2 - y1;
  final len = math.sqrt((dx * dx + dy * dy).toDouble());
  final steps = len.ceil().clamp(1, 5000);
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    final cx = (x1 + dx * t).round();
    final cy = (y1 + dy * t).round();
    _brushDot(image, cx, cy, r, color);
  }
}

void _brushDot(img.Image image, int cx, int cy, int r, int color) {
  for (var dy = -r; dy <= r; dy++) {
    for (var dx = -r; dx <= r; dx++) {
      if (dx * dx + dy * dy > r * r) continue;
      final x = cx + dx, y = cy + dy;
      if (x < 0 || x >= image.width || y < 0 || y >= image.height) continue;
      image.setPixel(x, y, color);
    }
  }
}