import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  const big = 4096;
  const small = 1024;

  final image = img.Image(big, big);

  _drawBlueBg(image, big);
  _drawClipboard(image, big);
  _drawItems(image, big);

  final down = img.copyResize(
    image,
    width: small,
    height: small,
    interpolation: img.Interpolation.linear,
  );

  final png = img.encodePng(down);
  File('assets/icon/icon.png').writeAsBytesSync(png);
  print('Icon generated: assets/icon/icon.png');
}

final _white = img.getColor(255, 255, 255);
final _clipBlue = img.getColor(0x1A, 0x3A, 0x5C);
final _itemBlue = img.getColor(0x0E, 0xA5, 0xE9);
final _lineBlue = img.getColor(0xC8, 0xE8, 0xFB);
final _rivetBlue = img.getColor(0x0B, 0x1A, 0x2E);

void _drawBlueBg(img.Image image, int s) {
  for (var y = 0; y < s; y++) {
    for (var x = 0; x < s; x++) {
      image.setPixel(x, y, _itemBlue);
    }
  }
}

// ── Clipboard ──

void _drawClipboard(img.Image image, int s) {
  final cx = s ~/ 2;
  final cw = (s * 0.54).round();
  final ch = (s * 0.70).round();
  final rr = (s * 0.10).round();

  final left = cx - cw ~/ 2;
  final top = (s * 0.18).round();
  final right = left + cw;
  final bottom = top + ch;

  for (var y = top; y <= bottom; y++) {
    for (var x = left; x <= right; x++) {
      if (_inRoundedRect(x, y, left, top, right, bottom, rr)) {
        image.setPixel(x, y, _white);
      }
    }
  }

  final clipW = (s * 0.34).round();
  final clipH = (s * 0.10).round();
  final clipRR = (s * 0.05).round();
  final clipLeft = cx - clipW ~/ 2;
  final clipTop = top - (clipH ~/ 3);
  final clipRight = clipLeft + clipW;
  final clipBottom = clipTop + clipH;

  for (var y = clipTop; y <= clipBottom; y++) {
    for (var x = clipLeft; x <= clipRight; x++) {
      if (_inRoundedRect(x, y, clipLeft, clipTop, clipRight, clipBottom, clipRR)) {
        image.setPixel(x, y, _clipBlue);
      }
    }
  }

  _brushDot(image, cx, (clipTop + clipBottom) ~/ 2, (s * 0.010).round().clamp(1, 20), _rivetBlue);
}

bool _inRoundedRect(int x, int y, int l, int t, int r, int b, int rr) {
  if (x < l || x > r || y < t || y > b) return false;
  if (x >= l + rr && x <= r - rr && y >= t + rr && y <= b - rr) return true;
  if (x < l + rr && y < t + rr) return _sq(x - (l + rr)) + _sq(y - (t + rr)) <= rr * rr;
  if (x > r - rr && y < t + rr) return _sq(x - (r - rr)) + _sq(y - (t + rr)) <= rr * rr;
  if (x < l + rr && y > b - rr) return _sq(x - (l + rr)) + _sq(y - (b - rr)) <= rr * rr;
  if (x > r - rr && y > b - rr) return _sq(x - (r - rr)) + _sq(y - (b - rr)) <= rr * rr;
  return true;
}

int _sq(int v) => v * v;

// ── Todo Items (BOLD) ──

void _drawItems(img.Image image, int s) {
  final cx = s ~/ 2;
  final cw = (s * 0.54).round();
  final ch = (s * 0.70).round();

  final left = cx - cw ~/ 2;
  final top = (s * 0.18).round();

  final innerLeft = left + (cw * 0.10).round();
  final innerW = (cw * 0.76).round();
  final bulletR = (s * 0.040).round().clamp(2, 56);
  final spacing = (ch * 0.26).round();
  final firstY = top + (s * 0.12).round();
  final lineH = (s * 0.040).round().clamp(2, 28);
  final lineR = lineH ~/ 2;

  for (var i = 0; i < 3; i++) {
    final y = firstY + i * spacing;

    // BIG bold bullet
    _brushDot(image, innerLeft, y, bulletR, _itemBlue);

    // BOLD thick horizontal line
    final lineX1 = innerLeft + bulletR + (s * 0.03).round();
    final lineX2 = innerLeft + innerW - (s * 0.03).round();
    _brushHLineBold(image, lineX1, y, lineX2, lineR, _lineBlue);

    // BIG checkmark on items 0 and 2
    if (i == 0 || i == 2) {
      final ckX = lineX2 + (s * 0.05).round();
      final ckSize = (s * 0.080).round();
      _drawBoldCheckmark(image, ckX, y, ckSize, _itemBlue);
    }
  }
}

void _brushHLineBold(img.Image image, int x1, int y, int x2, int r, int color) {
  for (var x = x1; x <= x2; x++) {
    _brushDot(image, x, y, r, color);
  }
}

void _drawBoldCheckmark(img.Image image, int cx, int cy, int size, int color) {
  final r = (size * 0.40).round().clamp(2, 18);
  final p1x = cx - size ~/ 2;
  final p1y = cy;
  final p2x = cx - (size * 0.15).round();
  final p2y = cy + (size * 0.4).round();
  final p3x = cx + (size * 0.55).round();
  final p3y = cy - (size * 0.4).round();

  _brushLine(image, p1x, p1y, p2x, p2y, r, color);
  _brushLine(image, p2x, p2y, p3x, p3y, r, color);
  _brushDot(image, p1x, p1y, r, color);
  _brushDot(image, p2x, p2y, r, color);
  _brushDot(image, p3x, p3y, r, color);
}

// ── Circular brush ──

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

int _lerp(int a, int b, double t) => (a + (b - a) * t).round().clamp(0, 255);
