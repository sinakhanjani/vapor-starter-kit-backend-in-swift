//
//  Sample.swift
//  App
//
//  Created by Sina khanjani on 1/9/1399 AP.
//

import Foundation
import Fluent
import FluentPostgreSQL

struct MyDataType: Codable, Equatable {
    let foo: Int
    let bar: String
}

extension MyDataType: ReflectionDecodable {
    static func reflectDecoded() throws -> (MyDataType, MyDataType) {
        return (
            MyDataType(foo: 42, bar: "towel"),
            MyDataType(foo: 42, bar: "mostly harmless")
        )
    }
}

extension MyDataType: PostgreSQLDataConvertible {
    static func convertFromPostgreSQLData(_ data: PostgreSQLData) throws -> MyDataType {
        let decoder = JSONDecoder()
        if let binary = data.binary {
            return try decoder.decode(MyDataType.self, from: binary[1...])
        } else {
            throw PostgreSQLError(identifier: "Null data", reason: "Beats me")
        }
    }

    func convertToPostgreSQLData() throws -> PostgreSQLData {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return PostgreSQLData(.jsonb, binary: [0x01] + data)
    }
}

struct Samp: PostgreSQLUUIDModel {
    var id: UUID?
    let name: String
    let Data: MyDataType
}
