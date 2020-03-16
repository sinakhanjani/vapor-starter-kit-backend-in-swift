//
//  Authentication.swift
//  App
//
//  Created by Sina khanjani on 12/18/1398 AP.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Fluent
import SwifQLVapor

final class Authentication: Codable {
    var id: UUID?
    var mobile: String
    var code: String?
    var userID: User.ID
    
    var createdAt: Date?
    var updatedAt: Date?
    
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    
    init(mobile: String, code: String?, userID: User.ID) {
        self.mobile = mobile
        self.code = code
        self.userID = userID
    }
    
    final class Response: Codable {
        var mobile: String
        var code: String
        var fcmToken: String?
        var reference: String
        var operationSystem: OperationSystem
        
        init(mobile: String, code: String, fcmToken: String?, reference: String, operationSystem: OperationSystem) {
            self.mobile = mobile
            self.code = code
            self.fcmToken = fcmToken
            self.reference = reference
            self.operationSystem = operationSystem
        }
    }
    
    final class GResponse: Codable {
        var username: String
        var name: String?
        var family: String?
        var fcmToken: String?
        var reference: String
        var operationSystem: OperationSystem
        
        init(username: String, name: String?, family: String?, fcmToken: String?, reference: String, operationSystem: OperationSystem) {
            self.username = username
            self.name = name
            self.family = family
            self.fcmToken = fcmToken
            self.reference = reference
            self.operationSystem = operationSystem
        }
    }
    
    final class GPhone: Codable {
        var mobile: String
        var code: String?
    }
    
    final class OperationSystem: Codable {
        var platform: String
        var phone: String
        var osVersion: String
        var appVersion: String
        var build: String
    }
}

extension Authentication {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { (builder) in
            try addProperties(to: builder)
        }
    }
}

extension Authentication {
    var user: Parent<Authentication, User> {
        return parent(\.userID)
    }
}

extension Authentication: PostgreSQLUUIDModel {}
extension Authentication: Content {}
extension Authentication: Migration {}
extension Authentication: Parameter {}
extension Authentication: Tableable {}
extension Authentication.Response: Content {}
