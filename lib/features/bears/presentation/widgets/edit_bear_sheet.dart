import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bear.dart';
import '../controllers/color_list_controller.dart';
import 'add_color_sheet.dart';
import '../../../../core/utils/color_utils.dart';

class EditBearSheet extends ConsumerStatefulWidget {
  const EditBearSheet({
    super.key,
    required this.bear,
    required this.onUpdate,
  });
  final Bear bear;
  final Future<bool> Function(int id, String? name, int? size, List<String>? colorNames) onUpdate;

  @override
  ConsumerState<EditBearSheet> createState() => _EditBearSheetState();
}

class _EditBearSheetState extends ConsumerState<EditBearSheet> {
  late TextEditingController _name;
  late TextEditingController _size;
  final Set<String> _selectedColorNames = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.bear.name);
    _size = TextEditingController(text: widget.bear.size.toString());
    // Initialize with existing colors
    _selectedColorNames.addAll(widget.bear.colors.map((c) => c.name));
  }

  @override
  void dispose() {
    _name.dispose();
    _size.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final colorState = ref.watch(colorListControllerProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Edit Bear', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _size,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Size (int)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Colors',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (ctx) => AddColorSheet(
                        onAdd: (name, hex) async {
                          final success = await ref
                              .read(colorListControllerProvider.notifier)
                              .addColor(name, hex);
                          return success;
                        },
                      ),
                    );
                    // Colors will be automatically reloaded by the colorListControllerProvider
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Color', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: const Size(0, 30),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (colorState.loading)
              const Center(child: CircularProgressIndicator())
            else if (colorState.items.isEmpty)
              const Text('No colors available. Add a color to get started.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colorState.items.map((color) {
                  final selected = _selectedColorNames.contains(color.name);
                  return FilterChip(
                    selected: selected,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: ColorUtils.hexToColor(color.hex),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(color.name),
                      ],
                    ),
                    onSelected: (bool value) {
                      setState(() {
                        if (value) {
                          _selectedColorNames.add(color.name);
                        } else {
                          _selectedColorNames.remove(color.name);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _saving
                  ? null
                  : () async {
                      final name = _name.text.trim();
                      final size = int.tryParse(_size.text.trim());

                      // Determine what has changed
                      final nameChanged = name != widget.bear.name;
                      final sizeChanged = size != null && size != widget.bear.size;
                      final originalColorNames = widget.bear.colors.map((c) => c.name).toSet();
                      final colorsChanged = !_selectedColorNames.equals(originalColorNames);

                      if (!nameChanged && !sizeChanged && !colorsChanged) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No changes detected')),
                        );
                        return;
                      }

                      // Validate inputs for changed fields
                      if (nameChanged && name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Name cannot be empty')),
                        );
                        return;
                      }

                      if (sizeChanged && size <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Size must be a positive number')),
                        );
                        return;
                      }

                      setState(() => _saving = true);
                      final ok = await widget.onUpdate(
                        widget.bear.id,
                        nameChanged ? name : null,
                        sizeChanged ? size : null,
                        colorsChanged ? _selectedColorNames.toList() : null,
                      );
                      if (context.mounted) {
                        Navigator.of(context).pop(ok);
                      }
                    },
              child: _saving
                  ? const CircularProgressIndicator()
                  : const Text('Update'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// Extension to compare sets
extension SetEquality<T> on Set<T> {
  bool equals(Set<T> other) {
    if (length != other.length) return false;
    return every((element) => other.contains(element));
  }
}
