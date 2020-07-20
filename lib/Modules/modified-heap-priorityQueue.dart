import 'dart:collection';

import 'package:collection/collection.dart';

class ModifiedHeapPriorityQueue<E> implements PriorityQueue<E> {
  static const int _INITIAL_CAPACITY = 7;

  final Comparator<E> comparison;

  final bool Function(E,E) isEqual;

  /// List implementation of a heap.
  List<E> _queue = List<E>(_INITIAL_CAPACITY);

  int _length = 0;

  /// Create a new priority queue.
  ///
  /// The [comparison] is a [Comparator] used to compare the priority of
  /// elements. An element that compares as less than another element has
  /// a higher priority.
  ///
  /// If [comparison] is omitted, it defaults to [Comparable.compare]. If this
  /// is the case, `E` must implement [Comparable], and this is checked at
  /// runtime for every comparison.
  ModifiedHeapPriorityQueue(this.isEqual, [int comparison(E e1, E e2)])
      : comparison = comparison ?? null;//defaultCompare<E>();
    // }

  void add(E element) {
    _add(element);
  }

  void addAll(Iterable<E> elements) {
    for (E element in elements) {
      _add(element);
    }
  }

  void clear() {
    _queue = const [];
    _length = 0;
  }

  int _myLocate(E object)
  {
    int index ;
    for(index =0;index<_length;index++ )
      {
        if(isEqual(_queue[index],object)) return index;
      }
    return -1;
  }

  E containsObject(E object){
    int temp = _myLocate(object);
    return temp >=0 ? _queue[temp] : null;
  }

  bool contains(E object) {
    return _myLocate(object) >= 0;
//    return _locate(object) >= 0;
  }

  E get first {
    if (_length == 0) throw StateError("No such element");
    return _queue[0];
  }

  bool get isEmpty => _length == 0;

  bool get isNotEmpty => _length != 0;

  int get length => _length;

  bool remove(E element) {
    int index = _myLocate(element);
//    int index = _locate(element);
    if (index < 0) return false;
    E last = _removeLast();
    if (index < _length) {
      int comp = comparison(last, element);
      if (comp <= 0) {
        _bubbleUp(last, index);
      } else {
        _bubbleDown(last, index);
      }
    }
    return true;
  }

  Iterable<E> removeAll() {
    List<E> result = _queue;
    int length = _length;
    _queue = const [];
    _length = 0;
    return result.take(length);
  }

  E removeFirst() {
    if (_length == 0) throw StateError("No such element");
    E result = _queue[0];
    E last = _removeLast();
    if (_length > 0) {
      _bubbleDown(last, 0);
    }
    return result;
  }

  List<E> toList() {
    List<E> list = List<E>()
      ..length = _length;
    list.setRange(0, _length, _queue);
    list.sort(comparison);
    return list;
  }

  Set<E> toSet() {
    Set<E> set = SplayTreeSet<E>(comparison);
    for (int i = 0; i < _length; i++) {
      set.add(_queue[i]);
    }
    return set;
  }

  /// Returns some representation of the queue.
  ///
  /// The format isn't significant, and may change in the future.
  String toString() {
    return _queue.take(_length).toString();
  }

  /// Add element to the queue.
  ///
  /// Grows the capacity if the backing list is full.
  void _add(E element) {
    if (_length == _queue.length) _grow();
    _bubbleUp(element, _length++);
  }

  E _removeLast() {
    int newLength = _length - 1;
    E last = _queue[newLength];
    _queue[newLength] = null;
    _length = newLength;
    return last;
  }

  /// Place [element] in heap at [index] or above.
  ///
  /// Put element into the empty cell at `index`.
  /// While the `element` has higher priority than the
  /// parent, swap it with the parent.
  void _bubbleUp(E element, int index) {
    while (index > 0) {
      int parentIndex = (index - 1) ~/ 2;
      E parent = _queue[parentIndex];
      if (comparison(element, parent) > 0) break;
      _queue[index] = parent;
      index = parentIndex;
    }
    _queue[index] = element;
  }

  /// Place [element] in heap at [index] or above.
  ///
  /// Put element into the empty cell at `index`.
  /// While the `element` has lower priority than either child,
  /// swap it with the highest priority child.
  void _bubbleDown(E element, int index) {
    int rightChildIndex = index * 2 + 2;
    while (rightChildIndex < _length) {
      int leftChildIndex = rightChildIndex - 1;
      E leftChild = _queue[leftChildIndex];
      E rightChild = _queue[rightChildIndex];
      int comp = comparison(leftChild, rightChild);
      int minChildIndex;
      E minChild;
      if (comp < 0) {
        minChild = leftChild;
        minChildIndex = leftChildIndex;
      } else {
        minChild = rightChild;
        minChildIndex = rightChildIndex;
      }
      comp = comparison(element, minChild);
      if (comp <= 0) {
        _queue[index] = element;
        return;
      }
      _queue[index] = minChild;
      index = minChildIndex;
      rightChildIndex = index * 2 + 2;
    }
    int leftChildIndex = rightChildIndex - 1;
    if (leftChildIndex < _length) {
      E child = _queue[leftChildIndex];
      int comp = comparison(element, child);
      if (comp > 0) {
        _queue[index] = child;
        index = leftChildIndex;
      }
    }
    _queue[index] = element;
  }

  /// Grows the capacity of the list holding the heap.
  ///
  /// Called when the list is full.
  void _grow() {
    int newCapacity = _queue.length * 2 + 1;
    if (newCapacity < _INITIAL_CAPACITY) newCapacity = _INITIAL_CAPACITY;
    List<E> newQueue = List<E>(newCapacity);
    newQueue.setRange(0, _length, _queue);
    _queue = newQueue;
  }
}