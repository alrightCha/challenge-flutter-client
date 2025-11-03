import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/bear_list_controller.dart';
import '../controllers/color_list_controller.dart';
import '../controllers/filter_state.dart';
import 'color_chip.dart' as custom;

class BearFilterBar extends ConsumerStatefulWidget {
  const BearFilterBar({super.key, required this.initial, required this.onChanged});
  final FilterState initial;
  final ValueChanged<FilterState> onChanged;

  @override
  ConsumerState<BearFilterBar> createState() => _BearFilterBarState();
}

class _BearFilterBarState extends ConsumerState<BearFilterBar> {
  late TextEditingController _search;
  late TextEditingController _sizeFrom;
  late TextEditingController _sizeTo;
  final Set<int> _selectedColorIds = {};
  bool _showSizeFilter = false;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.initial.search);
    _sizeFrom = TextEditingController(
      text: widget.initial.startSize?.toString() ?? '0',
    );
    _sizeTo = TextEditingController(
      text: widget.initial.endSize?.toString() ?? '200',
    );
    _selectedColorIds.addAll(widget.initial.colorIds);
    // Show size filter if values are set
    _showSizeFilter = widget.initial.startSize != null || widget.initial.endSize != null;
  }

  @override
  void didUpdateWidget(BearFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers if the filter prop changed (e.g., from cached data)
    if (oldWidget.initial != widget.initial) {
      _search.text = widget.initial.search;
      _sizeFrom.text = widget.initial.startSize?.toString() ?? '0';
      _sizeTo.text = widget.initial.endSize?.toString() ?? '200';
      _selectedColorIds.clear();
      _selectedColorIds.addAll(widget.initial.colorIds);
      _showSizeFilter = widget.initial.startSize != null || widget.initial.endSize != null;
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _sizeFrom.dispose();
    _sizeTo.dispose();
    super.dispose();
  }

  void _emit() {
    final startSize = int.tryParse(_sizeFrom.text);
    final endSize = int.tryParse(_sizeTo.text);
    widget.onChanged(FilterState(
      search: _search.text,
      colorIds: _selectedColorIds.toList(),
      startSize: startSize,
      endSize: endSize,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colorState = ref.watch(colorListControllerProvider);

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact search bar
            SizedBox(
              height: 36,
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 18),
                  hintText: 'Search bears...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 13),
                onChanged: (_) => _emit(),
              ),
            ),
            const SizedBox(height: 12),
            // Size filter toggle button
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _showSizeFilter = !_showSizeFilter);
                  },
                  icon: Icon(
                    _showSizeFilter ? Icons.expand_less : Icons.tune,
                    size: 18,
                  ),
                  label: Text(
                    _showSizeFilter ? 'Hide Size Filter' : 'Add Size Filter',
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(0, 32),
                  ),
                ),
                if (_showSizeFilter) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: TextField(
                      controller: _sizeFrom,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Min',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 13),
                      onChanged: (_) => _emit(),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('-', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  SizedBox(
                    width: 70,
                    child: TextField(
                      controller: _sizeTo,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Max',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 13),
                      onChanged: (_) => _emit(),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (colorState.loading)
              const CircularProgressIndicator()
            else if (colorState.error != null)
              Text('Error loading colors: ${colorState.error}',
                   style: const TextStyle(color: Colors.red, fontSize: 12))
            else if (colorState.items.isEmpty)
              const Text('No colors available',
                   style: TextStyle(fontSize: 12, color: Colors.grey))
            else
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  ...colorState.items.map((color) {
                    final selected = _selectedColorIds.contains(color.id);
                    return custom.ColorChip(
                      colorModel: color,
                      isSelected: selected,
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedColorIds.remove(color.id);
                          } else {
                            _selectedColorIds.add(color.id);
                          }
                        });
                        _emit();
                      },
                      onDelete: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Color'),
                            content: Text(
                              'Are you sure you want to delete "${color.name}"? This will remove all the bears associated with this color.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await ref
                              .read(colorListControllerProvider.notifier)
                              .deleteColor(color.name);
                          // Remove the deleted color from selected colors
                          setState(() {
                            _selectedColorIds.remove(color.id);
                          });
                          // Refresh bear list to reflect the deletion
                          await ref
                              .read(bearListControllerProvider.notifier)
                              .load();
                        }
                      },
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
