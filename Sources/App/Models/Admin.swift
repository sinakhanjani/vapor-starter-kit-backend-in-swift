//
//  Admin.swift
//  App
//
//  Created by Sina khanjani on 11/27/1398 AP.
//

import Vapor
import FluentPostgreSQL
import Authentication

final class Admin: Codable {    
    var id: UUID?
    var name: String
    var username: String
    var password: String
    
    var createdAt: Date?
    var updatedAt: Date?
    
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    
    init(name: String, username: String, password: String) {
      self.name = name
      self.username = username
      self.password = password
    }
    
    final class Public: Codable {
      var id: UUID?
      var name: String
      var username: String
      
      init(id: UUID?, name: String, username: String) {
      self.id = id
      self.name = name
      self.username = username
      }
    }
}

extension Admin {
    func added() throws -> Admin {
        guard !password.isEmpty && !username.isEmpty else {
            throw Abort(HTTPResponseStatus.notImplemented)
        }
        return self
    }
    
    func remove() throws -> Admin {
        return self
    }
    
    func edit(_ admin: Admin)  throws -> Admin {
        self.password = admin.password
        self.name = admin.name
        self.password = try BCrypt.hash(admin.password)
        return self
    }
}

extension Admin {
    var magCategory: Children<Admin, MagCategory> {
      return children(\.adminID)
    }
    
    var mag: Children<Admin, Mag> {
        return children(\.adminID)
    }
}

extension Admin {
    func convertToPublic() -> Admin.Public {
    return Admin.Public(id: id, name: name, username: username)
  }
}

extension Future where T: Admin {
  func convertToPublic() -> Future<Admin.Public> {
    return self.map(to: Admin.Public.self) { admin in
      return admin.convertToPublic()
    }
  }
}

extension Admin {
static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection) { (builder) in
        try addProperties(to: builder)
        builder.unique(on: \.username)
        }
    }
}

extension Admin: BasicAuthenticatable {
  static let usernameKey: UsernameKey = \Admin.username
  static let passwordKey: PasswordKey = \Admin.password
}

extension Admin: PostgreSQLUUIDModel {}
extension Admin: Content {}
extension Admin: Migration {}
extension Admin: Parameter {}
extension Admin.Public: Content {}
