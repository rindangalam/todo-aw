import 'package:flutter/material.dart';

import '../../core/design/tokens.dart';

const _paletteColors = [
  Color(0xFFF44336),
  Color(0xFFE53935),
  Color(0xFFD32F2F),
  Color(0xFFC62828),
  Color(0xFFEF5350),
  Color(0xFFE91E63),
  Color(0xFFD81B60),
  Color(0xFFC2185B),
  Color(0xFFAD1457),
  Color(0xFFF06292),
  Color(0xFF9C27B0),
  Color(0xFF8E24AA),
  Color(0xFF7B1FA2),
  Color(0xFF6A1B9A),
  Color(0xFFAB47BC),
  Color(0xFF673AB7),
  Color(0xFF5E35B1),
  Color(0xFF512DA8),
  Color(0xFF4527A0),
  Color(0xFF7E57C2),
  Color(0xFF3F51B5),
  Color(0xFF3949AB),
  Color(0xFF303F9F),
  Color(0xFF283593),
  Color(0xFF5C6BC0),
  Color(0xFF2196F3),
  Color(0xFF1E88E5),
  Color(0xFF1976D2),
  Color(0xFF1565C0),
  Color(0xFF42A5F5),
  Color(0xFF03A9F4),
  Color(0xFF039BE5),
  Color(0xFF0288D1),
  Color(0xFF0277BD),
  Color(0xFF4FC3F7),
  Color(0xFF00BCD4),
  Color(0xFF00ACC1),
  Color(0xFF0097A7),
  Color(0xFF00838F),
  Color(0xFF26C6DA),
  Color(0xFF009688),
  Color(0xFF00897B),
  Color(0xFF00796B),
  Color(0xFF00695C),
  Color(0xFF26A69A),
  Color(0xFF4CAF50),
  Color(0xFF43A047),
  Color(0xFF388E3C),
  Color(0xFF2E7D32),
  Color(0xFF66BB6A),
  Color(0xFF8BC34A),
  Color(0xFF7CB342),
  Color(0xFF689F38),
  Color(0xFF558B2F),
  Color(0xFF9CCC65),
  Color(0xFFCDDC39),
  Color(0xFFC0CA33),
  Color(0xFFAFB42B),
  Color(0xFF9E9D24),
  Color(0xFFD4E157),
  Color(0xFFFFEB3B),
  Color(0xFFFDD835),
  Color(0xFFFBC02D),
  Color(0xFFF9A825),
  Color(0xFFFFEE58),
  Color(0xFFFFC107),
  Color(0xFFFFB300),
  Color(0xFFFFA000),
  Color(0xFFFF8F00),
  Color(0xFFFFB74D),
  Color(0xFFFF9800),
  Color(0xFFFB8C00),
  Color(0xFFF57C00),
  Color(0xFFEF6C00),
  Color(0xFFFFA726),
  Color(0xFFFF5722),
  Color(0xFFF4511E),
  Color(0xFFE64A19),
  Color(0xFFD84315),
  Color(0xFFFF7043),
  Color(0xFF795548),
  Color(0xFF6D4C41),
  Color(0xFF5D4037),
  Color(0xFF4E342E),
  Color(0xFF8D6E63),
  Color(0xFF607D8B),
  Color(0xFF546E7A),
  Color(0xFF455A64),
  Color(0xFF37474F),
  Color(0xFF78909C),
  Color(0xFF0EA5E9),
  Color(0xFF0284C7),
  Color(0xFF0369A1),
  Color(0xFF075985),
  Color(0xFF38BDF8),
];

class ColorPickerSheet extends StatefulWidget {
  final Color initialColor;

  const ColorPickerSheet({super.key, required this.initialColor});

  @override
  State<ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<ColorPickerSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _handle(),
          const SizedBox(height: Spacing.md),
          _preview(),
          const SizedBox(height: Spacing.md),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Palet'),
              Tab(text: 'Material'),
              Tab(text: 'Kustom'),
            ],
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: Spacing.md),
          SizedBox(
            height: 320,
            child: TabBarView(
              controller: _tabController,
              children: [
                _paletteTab(),
                _materialTab(),
                _customTab(),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _selectedColor),
              child: const Text('Pilih'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        width: 32,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _preview() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _selectedColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            ),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Text(
          '#${_selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
              ),
        ),
      ],
    );
  }

  Widget _paletteTab() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _paletteColors.length,
      itemBuilder: (context, index) {
        final color = _paletteColors[index];
        return _colorSwatch(color);
      },
    );
  }

  Widget _materialTab() {
    final materialColors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.blueGrey,
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: materialColors.length * 3,
      itemBuilder: (context, i) {
        final baseIndex = i ~/ 3;
        final shadeIndex = i % 3;
        final color = _materialShade(materialColors[baseIndex], shadeIndex);
        return _colorSwatch(color);
      },
    );
  }

  Color _materialShade(MaterialColor color, int shadeIndex) {
    switch (shadeIndex) {
      case 0:
        return color.shade200;
      case 1:
        return color;
      case 2:
        return color.shade700;
      default:
        return color;
    }
  }

  Widget _customTab() {
    return _HsvPicker(
      initialColor: _selectedColor,
      onChanged: (c) => setState(() => _selectedColor = c),
    );
  }

  Widget _colorSwatch(Color color) {
    final isSelected = _selectedColor.value == color.value;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        transform: isSelected
            ? Matrix4.diagonal3Values(1.15, 1.15, 1)
            : Matrix4.identity(),
        child: isSelected
            ? const Center(
                child: Icon(Icons.check, size: 18, color: Colors.white),
              )
            : null,
      ),
    );
  }
}

class _HsvPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onChanged;

  const _HsvPicker({required this.initialColor, required this.onChanged});

  @override
  State<_HsvPicker> createState() => _HsvPickerState();
}

class _HsvPickerState extends State<_HsvPicker> {
  late double _hue;
  late double _saturation;
  late double _value;

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initialColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
  }

  void _update() {
    final color = HSVColor.fromAHSV(1, _hue, _saturation, _value).toColor();
    widget.onChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        _hueSlider(theme),
        const SizedBox(height: Spacing.md),
        _saturationSlider(theme),
        const SizedBox(height: Spacing.md),
        _valueSlider(theme),
      ],
    );
  }

  Widget _hueSlider(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Hue',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text('${_hue.round()}°',
                style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: _hue,
            min: 0,
            max: 360,
            onChanged: (v) {
              setState(() => _hue = v);
              _update();
            },
          ),
        ),
      ],
    );
  }

  Widget _saturationSlider(ThemeData theme) {
    final satColor = HSVColor.fromAHSV(1, _hue, 1, _value).toColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Saturasi',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text('${(_saturation * 100).round()}%',
                style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: satColor,
            inactiveTrackColor: Colors.grey.shade200,
          ),
          child: Slider(
            value: _saturation,
            onChanged: (v) {
              setState(() => _saturation = v);
              _update();
            },
          ),
        ),
      ],
    );
  }

  Widget _valueSlider(ThemeData theme) {
    final valColor = HSVColor.fromAHSV(1, _hue, _saturation, 1).toColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Kecerahan',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text('${(_value * 100).round()}%',
                style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: valColor,
            inactiveTrackColor: Colors.grey.shade200,
          ),
          child: Slider(
            value: _value,
            onChanged: (v) {
              setState(() => _value = v);
              _update();
            },
          ),
        ),
      ],
    );
  }
}

Future<Color?> showColorPickerSheet(BuildContext context,
    {required Color initialColor}) {
  return showModalBottomSheet<Color>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(RadiusTokens.lg)),
    ),
    builder: (_) => ColorPickerSheet(initialColor: initialColor),
  );
}
