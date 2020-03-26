//
//  TrackingSession.swift
//  App
//
//  Created by Sina khanjani on 1/7/1399 AP.
//

import Vapor

struct TrackingSession: Content, Hashable {
  let id: String
}

extension TrackingSession: Parameter {
  static func resolveParameter(_ parameter: String, on container: Container) throws -> TrackingSession {
    return .init(id: parameter)
  }
}

