//
//  MagCategory.swift
//  App
//
//  Created by Sina khanjani on 11/25/1398 AP.
//

import Vapor
import FluentPostgreSQL
import SwifQLVapor

final class MagCategory: Codable {
    var id: UUID?
    var title: String
    let description: String?
    var coverURL: String?
    let adminID: Admin.ID
    
    var createdAt: Date?
    var updatedAt: Date?
    
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    
    init(title: String, description: String?, coverURL: String?, adminID: Admin.ID) {
        self.adminID = adminID
        self.coverURL = coverURL
        self.title = title
        self.description = description
    }
}

extension MagCategory {
    func added() throws -> MagCategory {
        return self
    }
    
    func remove() throws -> MagCategory {
        return self
    }
    
    func edit(_ magCategory: MagCategory)  throws -> MagCategory {
        //
        return self
    }
}

extension MagCategory {
    var admin: Parent<MagCategory, Admin> {
      return parent(\.adminID)
    }
    
    var mag: Children<MagCategory, Mag> {
      return children(\.magCategoryID)
    }
}

extension MagCategory {
    static func prepare(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { (builder) in
            try addProperties(to: builder)
            builder.reference(from: \.adminID, to: \Admin.id)
            builder.unique(on: \.title)
        }
    }
}

extension MagCategory: PostgreSQLUUIDModel {}
extension MagCategory: Content {}
extension MagCategory: Migration {}
extension MagCategory: Parameter {}
extension MagCategory: Tableable {}
