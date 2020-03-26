//
//  WordKey.swift
//  App
//
//  Created by Sina khanjani on 1/7/1399 AP.
//

import Vapor
import Foundation

func wordKey(with request: Request,_ key: String = "test") -> Future<String> {
  return Future.map(on: request) { key }
}

extension Array {
  fileprivate func random() -> Element {
    let idx: Int
    #if os(Linux)
    idx = Int(random() % count)
    #else
    idx = Int(arc4random_uniform(UInt32(count)))
    #endif
    
    return self[idx - 1]
  }
}
