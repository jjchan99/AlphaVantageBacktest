//
//  DIContainer.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 25/9/21.
//

protocol DIContainerProtocol {
  func register<T>(type: T.Type, item: Any)
  func retrieve<T>(type: T.Type) -> T?
}

final class DIContainer: DIContainerProtocol {
  static let shared = DIContainer()

  private init() {}

  var items: [String: Any] = [:]

  func register<T>(type: T.Type, item: Any) {
    items["\(type)"] = item
  }

  func retrieve<T>(type: T.Type) -> T? {
    return items["\(type)"] as? T
  }
}

