//
//  LockedDictionary.swift
//  App
//
//  Created by Sina khanjani on 1/7/1399 AP.
//

import Foundation

struct LockedDictionary<Key: Hashable, Value> {
  private let lock = NSLock()
  private var backing: [Key: Value] = [:]
  
  subscript(key: Key) -> Value? {
    get {
      lock.lock()
      defer { lock.unlock() }
      
      return backing[key]
    }
    set {
      lock.lock()
      defer { lock.unlock() }
      
      backing[key] = newValue
    }
  }
}

extension LockedDictionary: ExpressibleByDictionaryLiteral {
  init(dictionaryLiteral elements: (Key, Value)...) {
    for (key, value) in elements {
      backing[key] = value
    }
  }
}
