import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/bear_list_controller.dart';
import '../widgets/add_bear_sheet.dart';
import '../widgets/bear_card.dart';
import '../widgets/bear_filter_bar.dart';
import '../widgets/edit_bear_sheet.dart';

class BearsPage extends ConsumerWidget {
  const BearsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bearListControllerProvider);
    final ctrl = ref.read(bearListControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Bears')),
      body: Padding(
        padding: const EdgeInsets.all(70.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(128.0, 0, 128.0, 32.0),
              child: BearFilterBar(
                initial: state.filter,
                onChanged: (f) => ctrl.updateFilter(f),
              ),
            ),
            if (state.loading) const LinearProgressIndicator(),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (_, i) => BearCard(
                  bear: state.items[i],
                  onEdit: () async {
                    final updated = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => EditBearSheet(
                        bear: state.items[i],
                        onUpdate: (id, name, size, colorNames) => ctrl.updateBear(
                          id: id,
                          name: name,
                          size: size,
                          colorNames: colorNames,
                        ),
                      ),
                    );
                    if (updated == true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bear updated')),
                      );
                    }
                  },
                  onDelete: () => ctrl.deleteBear(state.items[i].id),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (_) =>
                AddBearSheet(onCreate: (n, s, c) => ctrl.createBear(n, s, c)),
          );
          if (created == true && context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Bear created')));
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add new Bear'),
      ),
    );
  }
}
