//
//  Notification.swift
//  App
//
//  Created by Sina khanjani on 12/19/1398 AP.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class Message: Codable {
    var id: UUID?
    var title: String
    var description: String?
    var userID: User.ID
    var adminID: Admin.ID
    
    var createdAt: Date?
    var updatedAt: Date?
    
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    
    init(title: String, description: String?, userID: User.ID, adminID: Admin.ID) {
        self.title = title
        self.description = description
        self.userID = userID
        self.adminID = adminID
    }
    
    final class Public: Codable {
        var id: UUID?
        var title: String
        var description: String?
        var userID: User.ID
        var responder: String?
        
        var createdAt: Date?
        var updatedAt: Date?
        
        static let createdAtKey: TimestampKey? = \.createdAt
        static let updatedAtKey: TimestampKey? = \.updatedAt
        
        init(title: String, description: String?, userID: User.ID, responder: String?) {
            self.title = title
            self.description = description
            self.userID = userID
            self.responder = responder
        }
    }
}

extension Message {
    func added() throws -> Message {
        return self
    }
    
    func update(message: Message) -> Message {
        return self
    }
    
    func remove() throws -> Message {
        return self
    }
    
    func edit(_ notification: Message)  throws -> Message {
        return self
    }
}

extension Message {
    var user: Parent<Message, User> {
        return self.parent(\.userID)
    }
    var admin: Parent<Message, Admin> {
        return self.parent(\.userID)
    }
}

extension Message: PostgreSQLUUIDModel {}
extension Message: Migration {}
extension Message: Parameter {}
extension Message: Content {}
extension Message.Public: Content {}
