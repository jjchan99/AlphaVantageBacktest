//
//  SinglyLinkedList.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 16/12/21.
//

import Foundation

class Node<T> {
  // 2
  var value: T
  var next: Node<T>?
  weak var previous: Node<T>?

  // 3
  init(value: T) {
    self.value = value
  }
}

class LinkedList<BindingClass> {
  var head: Node<BindingClass>?
  var tail: Node<BindingClass>?

  var isEmpty: Bool {
    return head == nil
  }

  var first: Node<BindingClass>? {
    return head
  }

  var last: Node<BindingClass>? {
    return tail
  }

  func append(value: BindingClass) {
      // 1
      let newNode: Node<BindingClass> = Node(value: value)
      // 2
      if let tailNode = tail {
        newNode.previous = newNode
        tailNode.next = newNode
      }
      // 3
      else {
        head = newNode
      }
      // 4
      tail = newNode
    }
    
    func nodeAt(index: Int) -> Node<BindingClass>? {
      // 1
      if index >= 0 {
        var node = head
        var i = index
        // 2
        while node != nil {
          if i == 0 { return node }
          i -= 1
          node = node!.next
        }
      }
      // 3
      return nil
    }
    
    func removeAll() {
      head = nil
      tail = nil
    }
    
    func remove(node: Node<BindingClass>) -> BindingClass {
      let prev = node.previous
      let next = node.next

      if let prev = prev {
        prev.next = next // 1
      } else {
        head = next // 2
      }
      next?.previous = prev // 3

      if next == nil {
        tail = prev // 4
      }

      // 5
      node.previous = nil
      node.next = nil

      // 6
      return node.value
    }
}
