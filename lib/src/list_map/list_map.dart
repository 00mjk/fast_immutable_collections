import "dart:collection";
import "dart:math";
import "package:fast_immutable_collections/fast_immutable_collections.dart";
import "package:fast_immutable_collections/src/list_map/list_map_view.dart";

/// A [ListMap] is a mutable, fixed-sized, and ordered map.
///
/// Compared to a [LinkedHashMap], a [ListMap] is also ordered and has a slightly worse
/// performance. But a [ListMap] takes less memory, and has some [List] methods like [sort] and
/// [shuffle]. Also, you can efficiently read its information by index, by using the [entryAt],
/// [keyAt] and [valueAt] methods.
///
/// The disadvantage, of course, is that [ListMap] has a fixed size,
/// while a [LinkedHashMap] does not.
///
class ListMap<K, V> implements Map<K, V> {
  Map<K, V> _map;
  List<K> _list;

  ListMap.empty() {
    _map = HashMap();
    _list = List.empty(growable: false);
  }

  /// Create a [ListMap] from the [map].
  /// If [sort] is true, it will sort the map keys. Otherwise, it will keep the [map] order.
  /// If [compare] is provided, it will use it to sort the map.
  ///
  ListMap.of(Map<K, V> map, {bool sort = false, int Function(K a, K b) compare}) {
    _map = HashMap.from(map);
    _list = List.of(map.keys, growable: false);
    if (sort) _list.sort(compare ?? compareObject);
  }

  /// Creates a [ListMap] from [entries].
  /// If [entries] contains the same keys multiple times, the last occurrence
  /// overwrites the previous value.
  ///
  /// If [sort] is true, then the entries will be sorted with [compare],
  /// if provided, or [compareObject] if not provided. If [sort] is false,
  /// [compare] will be ignored.
  ///
  ListMap.fromEntries(
    Iterable<MapEntry<K, V>> entries, {
    bool sort = false,
    int Function(K a, K b) compare,
  }) {
    // Sorted:
    if (sort) {
      _map = HashMap<K, V>();
      for (MapEntry<K, V> entry in entries) {
        _map[entry.key] = entry.value;
      }
      _list = _map.entries.map((entry) => entry.key).toList(growable: false);
      _list.sort(compare ?? compareObject);
    }
    // Insertion order:
    else {
      Map<K, V> map = LinkedHashMap<K, V>.fromEntries(entries);
      _map = HashMap.of(map);
      _list = map.entries.map((entry) => entry.key).toList(growable: false);
    }
  }

  factory ListMap.fromIterables(
    Iterable<K> keys,
    Iterable<V> values, {
    bool sort = false,
    int Function(K a, K b) compare,
  }) {
    Iterable<MapEntry<K, V>> combined =
        combineIterables(keys, values, (K key, V value) => MapEntry(key, value));

    return ListMap.fromEntries(combined, sort: sort, compare: compare);
  }

  ListMap.unsafe(this._map, {bool sort = false, int Function(K a, K b) compare}) {
    _list = List.of(_map.keys, growable: false);
    if (sort) _list.sort(compare ?? compareObject);
  }

  ListMap._(this._map, this._list)
      : assert(_map != null),
        assert(_list != null),
        assert(_map.length == _list.length);

  @override
  V operator [](Object key) => _map[key];

  /// You can replace the value of a key that already exists in the map.
  /// However, if the key is not already present, this will throw an error.
  @override
  void operator []=(K key, V value) {
    if (containsKey(key)) {
      _map[key] = value;
    } else
      throw UnsupportedError("Can't add a new key to the map.");
  }

  @override
  void addAll(Map<K, V> other) {
    // TODO: Implement
    throw UnsupportedError("This is not yet supported, but will be in the future.");
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> newEntries) {
    // TODO: Implement
    throw UnsupportedError("This is not yet supported, but will be in the future.");
  }

  @override
  ListMap<RK, RV> cast<RK, RV>() => ListMap<RK, RV>._(_map.cast<RK, RV>(), _list.cast<RK>());

  // TODO: Implement
  @override
  void clear() => throw UnsupportedError("Can't clear a ListMap.");

  @override
  bool containsKey(Object key) => _map.containsKey(key);

  @override
  bool containsValue(Object value) => _map.containsValue(value);

  @override
  void forEach(void Function(K key, V value) f) => _map.forEach(f);

  @override
  bool get isEmpty => _list.isEmpty;

  @override
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  Iterable<K> get keys => UnmodifiableListView(_list);

  @override
  Iterable<V> get values => _list.map((key) => _map[key]);

  MapEntry<K, V> entry(K key) => MapEntry(key, _map[key]);

  @override
  Iterable<MapEntry<K, V>> get entries => _list.map((key) => entry(key));

  @override
  int get length => _list.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) f) => _map.map(f);

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    throw UnsupportedError("Can't putIfAbsent into a ListMap.");
  }

  @override
  V remove(Object key) {
    throw UnsupportedError("Can't remove from a ListMap.");
  }

  @override
  void removeWhere(bool Function(K key, V value) predicate) {
    throw UnsupportedError("Can't removeWhere from a ListMap.");
  }

  // TODO: Implement
  @override
  V update(K key, V Function(V value) update, {V Function() ifAbsent}) {
    throw UnsupportedError("This is not yet supported, but will be in the future.");
  }

  // TODO: Implement
  @override
  void updateAll(V Function(K key, V value) update) {
    throw UnsupportedError("This is not yet supported, but will be in the future.");
  }

  // TODO: Implement
  /// Shuffles the keys of this map randomly.
  void shuffle([Random random]) {
    _list.shuffle(random);
  }

  /// Sorts the keys of this map.
  void sort([int Function(K a, K b) compare]) {
    _list.sort(compare);
  }

  /// Returns the [index]th entry.
  /// The [index] must be non-negative and less than [length].
  /// Index zero represents the first entry.
  ///
  MapEntry<K, V> entryAt(int index) {
    K key = _list[index];
    return MapEntry<K, V>(key, _map[key]);
  }

  /// Returns the [index]th key.
  /// The [index] must be non-negative and less than [length].
  /// Index zero represents the first key.
  ///
  K keyAt(int index) => _list[index];

  /// Returns the [index]th value.
  /// The [index] must be non-negative and less than [length].
  /// Index zero represents the first value.
  ///
  V valueAt(int index) => _map[_list[index]];

  /// Creates a [ListMap] form the given [map].
  /// If the [map] is already of type [ListMap], return the same instance.
  /// This is unsafe because a [ListMapView] is fixed size, but the given [map] may not.
  static ListMap<K, V> unsafeView<K, V>(Map<K, V> map) =>
      (map is ListMap<K, V>) ? map : ListMapView<K, V>(map);
}
