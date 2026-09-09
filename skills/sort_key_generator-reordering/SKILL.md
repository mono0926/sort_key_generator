---
name: sort_key_generator-reordering
description: >-
  Use when implementing drag-and-drop reordering, generating lexicographical sorting keys,
  or computing fractional indexing between items without full database reindexing using sort_key_generator.
---

# sort_key_generator Reordering Guide

`sort_key_generator` generates intermediate numerical sort keys (`double`) between two existing items. This eliminates the need to rewrite the rank or index of all subsequent items in a collection when an item is inserted or reordered.

## Guidelines

- **Fractional Sorting Pattern**:
  - Store a `sortKey` (floating point `double`) on each document or entity in the database (e.g., Firestore, SQLite, Postgres).
  - Sort entities ascending by `sortKey`.
- **Generating Intermediate Keys**:
  - Call `generateSortKeyDouble({double? previous, double? next})`.
  - When inserting at the very beginning of a list, pass `next: firstItem.sortKey` (`previous: null`).
  - When appending to the end of a list, pass `previous: lastItem.sortKey` (`next: null`).
  - When inserting between two items, pass both `previous: prevItem.sortKey` and `next: nextItem.sortKey`.
- **Handling Precision Limits**:
  - `generateSortKeyDouble()` returns `null` if the float precision gap between `previous` and `next` is exhausted (i.e. `(previous + next) / 2 == previous` due to IEEE-754 precision limits).
  - Always check for `null`. If `null` is returned, trigger a batch re-spacing of keys (e.g., resetting keys to `10.0, 20.0, 30.0...`).

## Examples

### 1. Reordering in a List View

```dart
import 'package:sort_key_generator/sort_key_generator.dart';

class TaskItem {
  TaskItem({required this.id, required this.title, required this.sortKey});

  final String id;
  final String title;
  double sortKey;
}

void onItemReordered(List<TaskItem> sortedItems, int oldIndex, int newIndex) {
  final item = sortedItems.removeAt(oldIndex);
  sortedItems.insert(newIndex, item);

  final double? prevKey = newIndex > 0 ? sortedItems[newIndex - 1].sortKey : null;
  final double? nextKey = newIndex < sortedItems.length - 1 ? sortedItems[newIndex + 1].sortKey : null;

  final newKey = generateSortKeyDouble(previous: prevKey, next: nextKey);

  if (newKey == null) {
    // Floating point precision exhausted -> trigger bulk reindex
    reindexAllItems(sortedItems);
  } else {
    item.sortKey = newKey;
    saveItemSortKey(item.id, newKey);
  }
}

void reindexAllItems(List<TaskItem> items) {
  for (var i = 0; i < items.length; i++) {
    items[i].sortKey = (i + 1) * 1000.0;
    saveItemSortKey(items[i].id, items[i].sortKey);
  }
}

void saveItemSortKey(String id, double key) {
  // Persist updated key to remote database or local storage
}
```

## Common Pitfalls & Anti-Patterns

- ❌ **Anti-pattern**: Updating integer `position` fields for all $N$ items whenever an item is moved to index 0, causing $O(N)$ database writes.
  - ✔️ **Correct**: Use `generateSortKeyDouble()` to update only the single moved item with $O(1)$ writes.
- ❌ **Anti-pattern**: Ignoring `null` return values from `generateSortKeyDouble()`.
  - ✔️ **Correct**: Always handle the `null` return safely by falling back to a full list re-spacing.
