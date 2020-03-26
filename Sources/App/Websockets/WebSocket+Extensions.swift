//
//  WebSocket+Extensions.swift
//  App
//
//  Created by Sina khanjani on 1/7/1399 AP.
//

import Vapor
import WebSocket
import Foundation

extension WebSocket {
  func send(_ currency: Currency) {
    let encoder = JSONEncoder()
    guard let data = try? encoder.encode(currency) else { return }
    send(data)
  }
}
