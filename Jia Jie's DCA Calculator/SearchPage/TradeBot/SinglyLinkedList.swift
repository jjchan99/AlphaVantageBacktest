//
//  SinglyLinkedList.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 16/12/21.
//

import Foundation

//class Node<T> {
//  // 2
//  var value: T
//  var next: Node<T>?
//  weak var previous: Node<T>?
//
//  // 3
//  init(value: T) {
//    self.value = value
//  }
//}

protocol Node: AnyObject {
    associatedtype T: Node
   
    var next: T? { get set }
    var previous: T? { get set }
}

class LinkedList<T: Node> {
  var head: T?
  var tail: T?
  
  init(head: T?) {
        self.head = head
  }

  var isEmpty: Bool {
    return head == nil
  }

    var first: T? {
    return head
  }

    var last: T? {
    return tail
    }

    func append(value: T) {
      // 1
      let newNode = value
      // 2
      if let tailNode = tail {
        newNode.previous = (newNode as! T.T)
        tailNode.next = (newNode as! T.T)
      }
      // 3
      else {
        head = newNode
      }
      // 4
      tail = newNode
    }
    
    func nodeAt(index: Int) -> T? {
      // 1
      if index >= 0 {
        var node = head
        var i = index
        // 2
        while node != nil {
          if i == 0 { return node }
          i -= 1
          node = (node!.next as! T)
        }
      }
      // 3
      return nil
    }
    
    func removeAll() {
      head = nil
      tail = nil
    }
    
    func remove(node: T) -> T {
      let prev = node.previous
      let next = node.next

      if let prev = prev {
        prev.next = (next as! T.T.T) // 1
      } else {
          head = (next as! T) // 2
      }
      next?.previous = (prev as! T.T.T) // 3

      if next == nil {
        tail = (prev as! T) // 4
      }

      // 5
      node.previous = nil
      node.next = nil

      // 6
      return node
    }
}

