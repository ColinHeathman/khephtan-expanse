#!/usr/bin/env -S godot -s
extends SceneTree

class TestObject:
	extends RefCounted
	var value : int = 0

func _init():
	test_int_heap()
	test_int_heapify()
	test_obj_heap()
	print("HeapTest passed 3/3 tests")
	
func test_int_heap():
	var h = Heap.new(func (a, b): return b - a)
	
	# Test push method
	h.push(5)
	h.push(7)
	h.push(3)
	h.push(1)
	assert(h.heap_list == [7, 5, 3, 1])
	
	# Test pop method
	assert(h.pop() == 7)
	assert(h.heap_list == [5, 1, 3])
	
	assert(h.pop() == 5)
	assert(h.heap_list == [3, 1])
	
	assert(h.pop() == 3)
	assert(h.heap_list == [1])
	
	assert(h.pop() == 1)
	assert(h.heap_list == [])
	
	assert(h.pop() == null)
	assert(h.heap_list == [])
	
func test_int_heapify():
	var h = Heap.new(func (a, b): return b - a)
	
	# Test push method
	h.heap_list = [5, 7, 3, 1]
	h.heapify()
	assert(h.heap_list == [7, 5, 3, 1])
	
	# Test pop method
	assert(h.pop() == 7)
	assert(h.heap_list == [5, 1, 3])
	
	assert(h.pop() == 5)
	assert(h.heap_list == [3, 1])
	
	assert(h.pop() == 3)
	assert(h.heap_list == [1])
	
	assert(h.pop() == 1)
	assert(h.heap_list == [])
	
	assert(h.pop() == null)
	assert(h.heap_list == [])
	
func test_obj_heap():
	
	# Test push method with custom object and comparator
	var obj1 = TestObject.new()
	obj1.value = 3
	
	var obj2 = TestObject.new()
	obj2.value = 1
	
	var obj3 = TestObject.new()
	obj3.value = 5
	
	var obj4 = TestObject.new()
	obj4.value = 2
	
	var h2 = Heap.new(func(a,b): return b.value - a.value)
	h2.push(obj1)
	h2.push(obj2)
	h2.push(obj3)
	h2.push(obj4)
	
	assert(h2.heap_list == [obj3, obj4, obj1, obj2])

	assert(h2.pop().value == 5)
	assert(h2.heap_list == [obj1, obj4, obj2])
	
	assert(h2.pop().value == 3)
	assert(h2.heap_list == [obj4, obj2])
	
	assert(h2.pop().value == 2)
	assert(h2.heap_list == [obj2])
	
	assert(h2.pop().value == 1)
	assert(h2.heap_list == [])
	
	assert(h2.pop() == null)
	assert(h2.heap_list == [])
