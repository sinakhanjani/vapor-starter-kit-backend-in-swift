//
//  Tag.swift
//  App
//
//  Created by Sina khanjani on 12/1/1398 AP.
//

import Vapor
import FluentPostgreSQL

final class Tag {    
    enum `Type`: String {
        case none,mag,gendre,gold,currency,person
    }
    
    var id: UUID?
    var title: String
    var description: String
    var type: String
    var subType: String
    var iconURL: String

    var createdAt: Date?
    var updatedAt: Date?
    
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    
    init(title: String, description: String, type: String, iconURL: String, subType: String) {
        self.title = title
        self.description = description
        self.type = type
        self.iconURL = iconURL
        self.subType = subType
    }
    
    final class Public: Codable {
        var id: UUID?
        var title: String
        var description: String
        var type: String
        var iconURL: String
        var subType: String

        init(id: UUID? ,title: String, description: String, type: String, iconURL: String, subType: String) {
            self.title = title
            self.description = description
            self.type = type
            self.iconURL = iconURL
            self.subType = subType
            self.id = id
        }
    }
    
    struct Post: Codable {
        var title: String
        var description: String
        var type: String
        var iconURL: File
        var subType: String
    }
}

extension Tag {
    func added() throws -> Tag {
        guard Type.init(rawValue: type) != nil else {
            throw Abort(HTTPResponseStatus.badRequest, reason: "Insert correct type: mag | gendre | ")
        }
        return self
    }
    
    func remove() throws -> Tag {
        return self
    }
    
    func edit(_ tag: Tag)  throws -> Tag {
        self.title = tag.title
        self.description = tag.description
        return self
    }
}

extension Tag {
static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection) { (builder) in
            try addProperties(to: builder)
            builder.unique(on: \.title)
        }
    }
}

extension Tag {
    func convertToPublic() -> Tag.Public {
        return Tag.Public(id: id, title: title, description: description, type: type, iconURL: iconURL, subType: subType)
  }
}

extension Future where T: Tag {
    func convertToPublic() -> Future<Tag.Public> {
    return self.map(to: Tag.Public.self) { tag in
      return tag.convertToPublic()
    }
  }
}

extension Tag {

}

extension Tag: PostgreSQLUUIDModel {}
extension Tag: Content {}
extension Tag: Migration {}
extension Tag: Parameter {}
extension Tag.Public: Content {}
extension Tag.Post: Content {}
