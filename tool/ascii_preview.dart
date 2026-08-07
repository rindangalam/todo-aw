import 'dart:io';
import 'package:image/image.dart' as img;

void main(List<String> args) {
  final names = args.isEmpty ? ['1', '2', '3', '4', '5'] : args;
  const grid = 88;
  for (final n in names) {
    final im = img.decodePng(
        File('assets/icon/$n.png').readAsBytesSync())!;
    final small = img.copyResize(im, width: grid, height: grid,
        interpolation: img.Interpolation.average);
    print('===== ICON $n =====');
    for (var y = 0; y < grid; y++) {
      final sb = StringBuffer();
      for (var x = 0; x < grid; x++) {
        final p = small.getPixel(x, y);
        final a = img.getAlpha(p);
        if (a < 40) {
          sb.write(' ');
          continue;
        }
        final r = img.getRed(p), g = img.getGreen(p), b = img.getBlue(p);
        if (r > 225 && g > 230 && b > 235) {
          sb.write('#'); // bright letter
        } else if (b > 200 && r < 200 && g > 150) {
          sb.write('W'); // mid-blue letter
        } else if (r < 70 && g < 85 && b < 130) {
          sb.write('d'); // dark navy
        } else if (b > r && r < 140) {
          sb.write(':'); // blue bg
        } else {
          sb.write('.'); // other
        }
      }
      print(sb.toString());
    }
    print('');
  }
}