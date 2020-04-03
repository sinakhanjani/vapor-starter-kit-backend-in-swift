//
//  User.swift
//  App
//
//  Created by Sina khanjani on 11/25/1398 AP.
//

import Vapor
import FluentPostgreSQL
import Authentication

final class User: Codable {
    enum CRUD {
        case add,remove
    }
    enum AuthorizedType: String {
        case google
        case phone
    }
    enum Reference: String {
        case fa,en
    }
    
    var id: UUID?
    var username: String?
    var mobile: String?
    var name: String?
    var family: String?
    var authorized: Bool?
    var auhtorizedType: String?
    var token: String?
    var fcmToken: String?
    var reference: String?
    var tags: [Tag.Public]?
    var operationSystem: Authentication.OperationSystem?

    var createdAt: Date?
    var updatedAt: Date?
    
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    
    init(id: UUID?, mobile: String) {
      self.id = id
      self.mobile = mobile
    }
    
    init(username: String) {
        self.username = username
    }
    
    final class Public: Codable {
        var id: UUID?
        var username: String?
        var mobile: String?
        var name: String?
        var family: String?
        var authorized: Bool?
        var auhtorizedType: String?
        var reference: String?
        var fcmToken: String?
        var token: String?
        var tags: [Tag.Public]?
        var operationSystem: Authentication.OperationSystem?
    
        init(id: UUID?, username: String?, mobile: String?, name: String?, family: String?, authorized: Bool?, tags: [Tag.Public]?, token: String?, auhtorizedType: String?, fcmToken: String?, reference: String?, operationSystem: Authentication.OperationSystem?) {
            self.id = id
            self.username = username
            self.mobile = mobile
            self.name = name
            self.family = family
            self.authorized = authorized
            self.auhtorizedType = auhtorizedType
            self.tags = tags
            self.token = token
            self.fcmToken = fcmToken
            self.reference = reference
            self.operationSystem = operationSystem
        }
    }
    
    final class Update: Codable {
        var name: String?
        var family: String?
        var reference: String?
        
        init(name: String?, family: String?, reference: String?) {
            self.name = name
            self.family = family
            self.reference = reference
        }
    }
}

extension User {
    // --- Phone ---
    func phoneAdded() throws -> User {
        guard let mobile = mobile else {
            throw Abort(.badRequest,reason: "Phone Requirement")
        }
        guard (mobile.count == 11) && (mobile.first == "0") else {
            throw Abort(HTTPResponseStatus.badRequest, reason: "Invalid phone number")
        }
        if self.authorized == nil {
            self.authorized = false
        }
        return self
    }
    
    func authorizedPhoneUser(token: String, fcmToken: String?, reference: String, operationSystem: Authentication.OperationSystem) throws -> User {
        self.authorized = true
        self.auhtorizedType = AuthorizedType.phone.rawValue
        self.token = token
        self.fcmToken = fcmToken
        self.operationSystem = operationSystem
        if let reference = Reference(rawValue: reference) {
            self.reference = reference.rawValue
        } else {
            throw Abort(HTTPResponseStatus.badRequest, reason: "Invalid type of reference")
        }
        return self
    }
    
    func updated(user: User.Update) throws -> User {
        self.name = user.name ?? self.name
        self.family = user.family ?? self.family
        self.reference = user.reference ?? self.reference
        return self
    }
    
    // --- Remove By Admin ---
    func remove() throws -> User {
        return self
    }
}

// ------ Google Auth ------
extension User {
    func addedByGoogle(token: String, fcmToken: String?, reference: String, operationSystem: Authentication.OperationSystem, response: Authentication.GResponse) throws -> User {
        self.authorized = true
        self.auhtorizedType = AuthorizedType.google.rawValue
        self.token = token
        self.fcmToken = fcmToken
        self.operationSystem = operationSystem
        self.name = response.name
        self.family = response.family
        if let reference = Reference(rawValue: reference) {
            self.reference = reference.rawValue
        } else {
            throw Abort(HTTPResponseStatus.badRequest, reason: "Invalid type of reference")
        }
        return self
    }
}

extension User {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        Database.create(self, on: connection) { (builder) in
            try addProperties(to: builder)
            builder.unique(on: \.mobile)
            builder.unique(on: \.username)
        }
    }
}

extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: id, username: username, mobile: mobile, name: name, family: family,authorized: authorized, tags: tags, token: token, auhtorizedType: auhtorizedType, fcmToken: fcmToken, reference:  reference, operationSystem: operationSystem)
  }
}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
    return self.map(to: User.Public.self) { user in
      return user.convertToPublic()
    }
  }
}

extension User {
    var auth: Children<User, Authentication> {
      return children(\.userID)
    }
    var message: Children<User, Message> {
      return children(\.userID)
    }
}

extension User: Content {}
extension User: PostgreSQLUUIDModel {}
extension User: Migration {}
extension User: Parameter {}
extension User.Public: Content {}
extension User.Update: Content {}
