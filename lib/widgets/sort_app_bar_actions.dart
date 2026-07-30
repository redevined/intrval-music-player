import 'package:flutter/material.dart';

/// The ascending/descending toggle + sort-field menu shared by the
/// Library, Playlists, and Sets tab app bars.
class SortAppBarActions<T> extends StatelessWidget {
  const SortAppBarActions({
    super.key,
    required this.ascending,
    required this.onToggleAscending,
    required this.sortValue,
    required this.onSortSelected,
    required this.items,
  });

  final bool ascending;
  final VoidCallback onToggleAscending;
  final T sortValue;
  final ValueChanged<T> onSortSelected;
  final List<PopupMenuItem<T>> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: ascending ? 'Ascending' : 'Descending',
          icon: Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward),
          onPressed: onToggleAscending,
        ),
        PopupMenuButton<T>(
          icon: const Icon(Icons.sort),
          initialValue: sortValue,
          onSelected: onSortSelected,
          itemBuilder: (context) => items,
        ),
      ],
    );
  }
}
