class_name Heap
extends RefCounted

var heap_list = Array()
var comparator

func _init(comparator_func):
	comparator = comparator_func

func size() -> int:
	return heap_list.size()

func push(item):
	heap_list.append(item)
	_sift_up(heap_list.size() - 1)

func pop():
	if heap_list.size() == 0:
		return null

	if heap_list.size() == 1:
		return heap_list.pop_back()

	var first = heap_list[0]
	heap_list[0] = heap_list.pop_back()
	_sift_down(0)

	return first

func swap(idx1, idx2):
	var temp = heap_list[idx1]
	heap_list[idx1] = heap_list[idx2]
	heap_list[idx2] = temp
	
func _sift_up(idx):
	while idx > 0:
		var parent_idx = (idx - 1) / 2
		if self.comparator.call(heap_list[idx], heap_list[parent_idx]) < 0:
			swap(idx, parent_idx)
			idx = parent_idx
		else:
			break

func _sift_down(idx):
	while true:
		var left_child_idx = 2 * idx + 1
		var right_child_idx = 2 * idx + 2
		var min_idx = idx

		if left_child_idx < heap_list.size() and self.comparator.call(heap_list[left_child_idx], heap_list[min_idx]) < 0:
			min_idx = left_child_idx

		if right_child_idx < heap_list.size() and self.comparator.call(heap_list[right_child_idx], heap_list[min_idx]) < 0:
			min_idx = right_child_idx

		if min_idx != idx:
			swap(idx, min_idx)
			idx = min_idx
		else:
			break

func heapify():
	var start_index = (heap_list.size() - 2) / 2

	while start_index >= 0:
		_sift_down(start_index)
		start_index -= 1
