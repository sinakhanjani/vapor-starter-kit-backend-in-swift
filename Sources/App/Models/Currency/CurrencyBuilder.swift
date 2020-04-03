//
//  CurrencyBuilder.swift
//  App
//
//  Created by Sina khanjani on 1/12/1399 AP.
//

import Foundation
import FluentPostgreSQL
import Fluent
import Vapor

final class CurrencyBuilder: Codable {
    var id : UUID?
    var group: String
    var parameters: [Currency]
    
    var createdAt: Date?
    var updatedAt: Date?
    
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    
    init(parameters: [Currency], group: String) {
        self.parameters = parameters
        self.group = group
    }
    
    func changeEn(currency: Currency, en: String) {
        var cr = self.parameters.filter({$0.key == currency.key}).first
        cr?.reference.changeEn(en: en)
    }
}

extension CurrencyBuilder: Content {}
extension CurrencyBuilder: PostgreSQLUUIDModel {}
extension CurrencyBuilder: Migration {}
extension CurrencyBuilder: Parameter {}
