import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

// Builds the app icon master from assets/icon/aw-Photoroom.png:
// - glyph inside kept EXACTLY as-is (white & blue colors preserved)
// - the rounded outer badge is removed: transparent corners are filled by
//   extending the badge's own linear gradient (LSQ plane fit per channel)
// - result: full-bleed smooth gradient, opaque, 1024x1024.

void main() {
  final src = img.decodePng(File('assets/icon/aw-Photoroom.png').readAsBytesSync());
  if (src == null) throw StateError('cannot decode aw-Photoroom.png');
  final w = src.width, h = src.height;
  print('src ${w}x$h');

  // Glyph bbox (measured): white check / AW area — excluded from gradient fit.
  const gx1 = 88, gy1 = 80, gx2 = 292, gy2 = 325;

  // 1) Collect badge samples (opaque, outside glyph bbox).
  var n = 0.0, sx = 0.0, sy = 0.0, sxx = 0.0, syy = 0.0, sxy = 0.0;
  final sums = [0.0, 0.0, 0.0]; // r, g, b
  final sumx = [0.0, 0.0, 0.0], sumy = [0.0, 0.0, 0.0];
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      if (x >= gx1 && x <= gx2 && y >= gy1 && y <= gy2) continue;
      final p = src.getPixel(x, y);
      if (img.getAlpha(p) < 200) continue;
      final xd = x.toDouble(), yd = y.toDouble();
      n++;
      sx += xd; sy += yd; sxx += xd * xd; syy += yd * yd; sxy += xd * yd;
      final vals = [img.getRed(p).toDouble(), img.getGreen(p).toDouble(), img.getBlue(p).toDouble()];
      for (var c = 0; c < 3; c++) {
        sums[c] += vals[c]; sumx[c] += xd * vals[c]; sumy[c] += yd * vals[c];
      }
    }
  }
  print('badge samples: ${n.toInt()}');

  // 2) Solve 3x3 normal equations per channel: color = c0 + cx*x + cy*y.
  final m = [
    [n, sx, sy],
    [sx, sxx, sxy],
    [sy, sxy, syy],
  ];
  final planes = <List<double>>[];
  for (var c = 0; c < 3; c++) {
    planes.add(solve3(m, [sums[c], sumx[c], sumy[c]]));
  }
  print('plane R: c0=${planes[0][0].toStringAsFixed(3)} cx=${planes[0][1].toStringAsFixed(4)} cy=${planes[0][2].toStringAsFixed(4)}');
  print('plane G: c0=${planes[1][0].toStringAsFixed(3)} cx=${planes[1][1].toStringAsFixed(4)} cy=${planes[1][2].toStringAsFixed(4)}');
  print('plane B: c0=${planes[2][0].toStringAsFixed(3)} cx=${planes[2][1].toStringAsFixed(4)} cy=${planes[2][2].toStringAsFixed(4)}');

  double plane(int c, double x, double y) {
    final pl = planes[c];
    return pl[0] + pl[1] * x + pl[2] * y;
  }

  // 3) Upscale to 1024x1024: composite opaque pixels by NEAREST sampling
  //    (exact glyph colors preserved), transparent corners filled with the
  //    extended gradient (smooth, seamless).
  final out = img.Image(1024, 1024);
  final scale = 1024.0 / w;
  for (var y = 0; y < 1024; y++) {
    for (var x = 0; x < 1024; x++) {
      final sx = (x / scale).floor().clamp(0, w - 1);
      final sy = (y / scale).floor().clamp(0, h - 1);
      final p = src.getPixel(sx, sy);
      final a = img.getAlpha(p) / 255.0;
      final gr = plane(0, sx.toDouble(), sy.toDouble());
      final gg = plane(1, sx.toDouble(), sy.toDouble());
      final gb = plane(2, sx.toDouble(), sy.toDouble());
      final r = (img.getRed(p) * a + gr * (1 - a)).round().clamp(0, 255);
      final g = (img.getGreen(p) * a + gg * (1 - a)).round().clamp(0, 255);
      final b = (img.getBlue(p) * a + gb * (1 - a)).round().clamp(0, 255);
      out.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  File('assets/icon/todoaw_light.png').writeAsBytesSync(img.encodePng(out));
  print('wrote assets/icon/todoaw_light.png (1024x1024, nearest glyph, gradient corners, opaque)');
}

List<double> solve3(List<List<double>> a, List<double> b) {
  final m = a.map((r) => r.toList()).toList();
  final v = b.toList();
  for (var c = 0; c < 3; c++) {
    var p = c;
    for (var r = c + 1; r < 3; r++) {
      if (m[r][c].abs() > m[p][c].abs()) p = r;
    }
    var t = m[c]; m[c] = m[p]; m[p] = t;
    var tv = v[c]; v[c] = v[p]; v[p] = tv;
    for (var r = c + 1; r < 3; r++) {
      final f = m[r][c] / m[c][c];
      for (var k = c; k < 3; k++) m[r][k] -= f * m[c][k];
      v[r] -= f * v[c];
    }
  }
  final x = [0.0, 0.0, 0.0];
  for (var c = 2; c >= 0; c--) {
    var s = v[c];
    for (var k = c + 1; k < 3; k++) s -= m[c][k] * x[k];
    x[c] = s / m[c][c];
  }
  return x;
}
