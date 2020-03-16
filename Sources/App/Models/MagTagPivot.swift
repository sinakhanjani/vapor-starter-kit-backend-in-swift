//
//  TagMagPivot.swift
//  App
//
//  Created by Sina khanjani on 12/1/1398 AP.
//

import Foundation
import FluentPostgreSQL
import SwifQLVapor

final class MagTagPivot: PostgreSQLUUIDPivot,ModifiablePivot {
    var id: UUID?
    var magID: Mag.ID
    var tagID: Tag.ID
      
    typealias Left = Mag
    typealias Right = Tag
      
    static let leftIDKey: LeftIDKey = \.magID
    static let rightIDKey: RightIDKey = \.tagID

    init(_ mag: Mag, _ tag: Tag) throws {
      self.magID = try mag.requireID()
      self.tagID = try tag.requireID()
    }
}

extension MagTagPivot: Migration {}
extension MagTagPivot {
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection) { builder in
      try addProperties(to: builder)
        builder.reference(from: \.magID,to: \Mag.id,onDelete: ._cascade)
        builder.reference(from: \.tagID,to: \Tag.id,onDelete: .cascade)
        builder.unique(on: \.tagID)
    }
  }
}

extension MagTagPivot: Tableable {}
