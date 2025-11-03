import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class AddColorSheet extends StatefulWidget {
  const AddColorSheet({super.key, required this.onAdd});

  final Future<bool> Function(String name, String hex) onAdd;

  @override
  State<AddColorSheet> createState() => _AddColorSheetState();
}

class _AddColorSheetState extends State<AddColorSheet> {
  Color _selectedColor = Colors.black;
  final _nameController = TextEditingController();
  bool _loading = false;

  String _colorToHex(Color color) {
    final argb = color.toARGB32();
    return '#${argb.toRadixString(16).substring(2).toUpperCase()}';
  }

  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a color name')),
      );
      return;
    }

    setState(() => _loading = true);

    final hex = _colorToHex(_selectedColor);
    final success = await widget.onAdd(_nameController.text.trim(), hex);

    if (mounted) {
      setState(() => _loading = false);
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add color')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add New Color',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Color Name',
              border: OutlineInputBorder(),
              hintText: 'e.g., Navy Blue',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose Color',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ColorPicker(
            color: _selectedColor,
            onColorChanged: (color) => setState(() => _selectedColor = color),
            width: 40,
            height: 40,
            borderRadius: 50,
            spacing: 5,
            runSpacing: 5,
            wheelDiameter: 240,
            heading: const SizedBox.shrink(),
            subheading: const SizedBox.shrink(),
            pickersEnabled: const {
              ColorPickerType.wheel: true,
              ColorPickerType.primary: false,
              ColorPickerType.accent: false,
            },
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _colorToHex(_selectedColor),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Add Color'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
