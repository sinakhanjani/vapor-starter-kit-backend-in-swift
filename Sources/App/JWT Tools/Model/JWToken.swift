//
//  AccessDto.swift
//  App
//
//  Created by Timur Shafigullin on 25/01/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct JWToken: Codable {
    var id: UUID?
    var token: String
    var userID: User.ID
    var mobile: String?
    var username: String?
    
    init(id: UUID? = nil, token: String, userID: User.ID, mobile: String?, username: String?) {
        self.id = id
        self.token = token
        self.userID = userID
        self.mobile = mobile
        self.username = username
    }
}

extension JWToken {
    var user: Parent<JWToken, User> {
        return self.parent(\.userID)
    }
}

extension JWToken: Content { }
extension JWToken: PostgreSQLUUIDModel { }
extension JWToken: Parameter { }
extension JWToken: Migration { }
