//
//  Generic.swift
//  App
//
//  Created by Sina khanjani on 11/27/1398 AP.
//

import Foundation
import Vapor

final class Generic <T> : Content where T: Content {
    let error: Bool
    let reason: String
    let data: T?
    let pagination: Pagination?
    
    init(error: Bool, reason: String = Constant.Message.Generic.success, data: T?) {
        self.reason = reason
        self.data = data
        self.error = error
        self.pagination = nil
    }
    
    init(error: Bool, reason: String = Constant.Message.Generic.success, data: T?, pagination: Pagination?) {
        self.reason = reason
        self.data = data
        self.error = error
        self.pagination = pagination
    }
}

final class Empty: Content { }

final class Pagination: Codable {
    let from: Int?
    let per: Int?
    let total: Int?
    
    init(from: Int?, per: Int?, total: Int?) {
        self.from = from
        self.per = per
        self.total = total
    }
}

