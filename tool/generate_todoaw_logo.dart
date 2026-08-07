import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

// ── Brand colors (t, r, g, b) ───────────────────────────────────
// Dominant brand blue: #0EA5E9
const _lightBg = <List<double>>[
  [0.00, 56, 189, 248], //  #38BDF8
  [0.22, 14, 165, 233], //  #0EA5E9 (dominant)
  [0.45, 2, 132, 199], //   #0284C7
  [0.68, 3, 105, 161], //   #0369A1
  [0.85, 7, 93, 133], //    #0E5D8A
  [1.0, 12, 58, 94], //     #0C3A5E
];

// Letter strokes - diagonal gradient (sampled from reference PNG)
const _letterLight = <List<double>>[
  [0.0, 251, 252, 255], // #FBFCFF (near-white, ref apex)
  [0.5, 241, 245, 254], // #F1F5FE (ref mid strokes)
  [1.0, 223, 232, 250], // #DFE8FA (ref base strokes)
];
const _letterDark = <List<double>>[
  [0.0, 243, 248, 253], // #F3F8FD
  [0.5, 202, 220, 243], // #CADCEF
  [1.0, 146, 182, 226], // #92B6E2
];

const _darkBg = [16, 27, 54]; //    #101B36
const _cornerRgb = [24, 38, 72]; //  #182648
const _borderRgb = [42, 58, 92]; //  #2A3A5C

// ── Geometry (from original SVG, relative to 320x320 squircle) ──
const _rxRel = 0.225;

// AW interlock path (relative points)
const _p0 = [0.1656, 0.425];
const _p1 = [0.3250, 0.7166];
const _apex = [0.5000, 0.2781];
const _p3 = [0.6750, 0.7166];
const _p4 = [0.8344, 0.425];
const _barX1 = 0.4219, _barX2 = 0.5781, _barY = 0.475;
const _strokeRel = 0.075;
const _barRel = 0.0594;

void main() {
  const s = 2048;
  final light = _lightIcon(s);
  final dark = _darkIcon(s);

  final dir = Directory('assets/icon')..createSync(recursive: true);
  _write(dir, 'todoaw_light.png', light, 1024);
  _write(dir, 'todoaw_dark.png', dark, 1024);
  print('Generated assets/icon/todoaw_light.png & todoaw_dark.png');
}

void _write(Directory dir, String name, img.Image im, int size) {
  final small = img.copyResize(im,
      width: size, height: size, interpolation: img.Interpolation.linear);
  File('${dir.path}/$name').writeAsBytesSync(img.encodePng(small));
}

// ── Icon builders ───────────────────────────────────────────────

img.Image _lightIcon(int s) {
  final im = img.Image(s, s);
  _drawRoundedRect(im, 0, 0, s - 1, s - 1, (_rxRel * s).round(), [14, 165, 233]);
  _fillRoundedGradient(im, s, (_rxRel * s).round(), _lightBg);
  _drawMonogram(im, s, _letterLight);
  return im;
}

img.Image _darkIcon(int s) {
  final im = img.Image(s, s);
  _drawRoundedRect(im, 0, 0, s - 1, s - 1, (_rxRel * s).round(), _darkBg);
  _drawCornerTriangle(im, s);
  _drawRoundedBorder(im, s, _borderRgb, 0.5);
  _drawMonogram(im, s, _letterDark);
  return im;
}

// ── Monogram ────────────────────────────────────────────────────

void _drawMonogram(img.Image im, int s, List<List<double>> grad) {
  final r = (_strokeRel / 2 * s).round();
  final br = (_barRel / 2 * s).round();

  final pts = <List<double>>[_p0, _p1, _apex, _p3, _p4];

  _polyGradient(im, pts, r, grad, s);
  _lineGradient(
      im,
      (_barX1 * s).round(),
      (_barY * s).round(),
      (_barX2 * s).round(),
      (_barY * s).round(),
      br,
      grad,
      s);
}

// ── Gradient helpers ────────────────────────────────────────────

List<int> _interp(List<List<double>> stops, double t) {
  var tt = t.clamp(0.0, 1.0);
  for (var i = 0; i < stops.length - 1; i++) {
    final a = stops[i];
    final b = stops[i + 1];
    if (tt <= b[0]) {
      final f = ((tt - a[0]) / (b[0] - a[0])).clamp(0.0, 1.0);
      return [
        _lerp(a[1], b[1], f),
        _lerp(a[2], b[2], f),
        _lerp(a[3], b[3], f),
      ];
    }
  }
  final last = stops.last;
  return [last[1].round(), last[2].round(), last[3].round()];
}

int _lerp(double a, double b, double t) {
  return (a + (b - a) * t).round().clamp(0, 255).toInt();
}

double _letterT(int x, int y, int s) {
  final xr = x / s, yr = y / s;
  return (((xr - 0.15) * 0.7) + yr) / 1.49;
}

// ── Drawing primitives ──────────────────────────────────────────

void _drawRoundedRect(img.Image im, int l, int t, int r, int b, int rad,
    List<int> color) {
  final c = img.getColor(color[0], color[1], color[2]);
  for (var y = t; y <= b; y++) {
    for (var x = l; x <= r; x++) {
      if (_inRoundedRect(x, y, l, t, r, b, rad)) im.setPixel(x, y, c);
    }
  }
}

void _fillRoundedGradient(img.Image im, int s, int rad, List<List<double>> stops) {
  for (var y = 0; y < s; y++) {
    final rgb = _interp(stops, y / s);
    final c = img.getColor(rgb[0], rgb[1], rgb[2]);
    for (var x = 0; x < s; x++) {
      if (_inRoundedRect(x, y, 0, 0, s - 1, s - 1, rad)) im.setPixel(x, y, c);
    }
  }
}

void _drawCornerTriangle(img.Image im, int s) {
  final c = img.getColor(_cornerRgb[0], _cornerRgb[1], _cornerRgb[2]);
  final rad = (_rxRel * s).round();
  for (var y = 0; y < s; y++) {
    for (var x = 0; x < s; x++) {
      if (y <= 0.5625 * (s - x) &&
          _inRoundedRect(x, y, 0, 0, s - 1, s - 1, rad)) {
        im.setPixel(x, y, c);
      }
    }
  }
}

void _drawRoundedBorder(img.Image im, int s, List<int> color, double alpha) {
  final rad = (_rxRel * s).round();
  final w = (3.0 / 320.0 * s).round().clamp(2, 24).toInt();
  for (var y = 0; y < s; y++) {
    for (var x = 0; x < s; x++) {
      final inside = _inRoundedRect(x, y, 0, 0, s - 1, s - 1, rad);
      if (!inside) continue;
      final inner = _inRoundedRect(
          x, y, w, w, s - 1 - w, s - 1 - w, math.max(0, rad - w).toInt());
      if (!inner) {
        final p = im.getPixel(x, y);
        im.setPixel(
            x,
            y,
            img.getColor(
              _blend(img.getRed(p), color[0], alpha),
              _blend(img.getGreen(p), color[1], alpha),
              _blend(img.getBlue(p), color[2], alpha),
            ));
      }
    }
  }
}

bool _inRoundedRect(int x, int y, int l, int t, int r, int b, int rad) {
  if (rad <= 0) return x >= l && x <= r && y >= t && y <= b;
  if (x < l || x > r || y < t || y > b) return false;
  if (x >= l + rad && x <= r - rad) return true;
  if (y >= t + rad && y <= b - rad) return true;
  final dx = x < l + rad ? l + rad - x : x - (r - rad);
  final dy = y < t + rad ? t + rad - y : y - (b - rad);
  return dx * dx + dy * dy <= rad * rad;
}

int _blend(int base, int over, double a) {
  return (base * (1 - a) + over * a).round().clamp(0, 255).toInt();
}

void _polyGradient(img.Image im, List<List<double>> pts, int r,
    List<List<double>> grad, int s) {
  for (var i = 0; i < pts.length - 1; i++) {
    _lineGradient(im, (pts[i][0] * s).round(), (pts[i][1] * s).round(),
        (pts[i + 1][0] * s).round(), (pts[i + 1][1] * s).round(), r, grad, s);
  }
}

void _lineGradient(img.Image im, int x1, int y1, int x2, int y2, int r,
    List<List<double>> grad, int s) {
  final dx = x2 - x1, dy = y2 - y1;
  final len = math.sqrt((dx * dx + dy * dy).toDouble());
  final steps = len.ceil().clamp(1, 30000);
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    final cx = x1 + ((dx * t).round());
    final cy = y1 + ((dy * t).round());
    _dotGradient(im, cx, cy, r, grad, s);
  }
}

void _dotGradient(
    img.Image im, int cx, int cy, int r, List<List<double>> grad, int s) {
  for (var dy = -r; dy <= r; dy++) {
    for (var dx = -r; dx <= r; dx++) {
      if (dx * dx + dy * dy > r * r) continue;
      final x = cx + dx, y = cy + dy;
      if (x < 0 || x >= im.width || y < 0 || y >= im.height) continue;
      final rgb = _interp(grad, _letterT(x, y, s));
      im.setPixel(x, y, img.getColor(rgb[0], rgb[1], rgb[2]));
    }
  }
}