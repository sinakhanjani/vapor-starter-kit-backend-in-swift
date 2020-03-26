//
//  Mag.swift
//  App
//
//  Created by Sina khanjani on 11/25/1398 AP.
//

import Vapor
import FluentPostgreSQL
import Fluent

final class Mag: Codable {
    var id: UUID?
    var title: String
    var coverURL: String
    var coverThumbnailURL: String
    var coverFilesURL: [String]?
    var description: String?
    var adminID: Admin.ID
    var magCategoryID: MagCategory.ID
    
    var createdAt: Date?
    var updatedAt: Date?
    
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    
    init(title: String, description: String?, coverURL: String, adminID: Admin.ID, magCategoryID: MagCategory.ID, coverThumbnailURL: String, coverFilesURL: [String]?) {
        self.adminID = adminID
        self.title = title
        self.description = description
        self.coverURL = coverURL
        self.magCategoryID = magCategoryID
        self.coverThumbnailURL = coverThumbnailURL
        self.coverFilesURL = coverFilesURL
    }
    
    final class Public: Codable {
        var id: UUID?
        var title: String
        var coverURL: String
        var coverThumbnailURL: String
        var coverFilesURL: [String]?
        var description: String?
        var admin: Admin.Public?
        var magCategory: MagCategory?
        
        init(id: UUID?, title: String, description: String?, coverURL: String, admin: Admin.Public?, magCategory: MagCategory?, coverThumbnailURL: String, coverFilesURL: [String]?) {
            self.id = id
            self.title = title
            self.description = description
            self.coverURL = coverURL
            self.coverThumbnailURL = coverThumbnailURL
            self.coverFilesURL = coverFilesURL
            self.admin = admin
            self.magCategory = magCategory
        }
    }
}

extension Mag {
    func added() throws -> Mag {
        return self
    }
    
    func remove() throws -> Mag {
        return self
    }
    
    func edit(_ mag: Mag, adminID: Admin.ID)  throws -> Mag {
        self.title = mag.title
        self.description = mag.description
        self.coverFilesURL = mag.coverFilesURL
        self.coverURL = mag.coverURL
        self.coverThumbnailURL = mag.coverThumbnailURL
        return self
    }
}

extension Mag {
    var magCategory: Parent<Mag, MagCategory> {
        return parent(\.magCategoryID)
    }
    
    var admin: Parent<Mag, Admin> {
        return parent(\.adminID)
    }
    
    var tags: Siblings<Mag,Tag,MagTagPivot> {
      return siblings()
    }
}

extension Mag {
    func convertToPublic(tags: [Tag]? = nil,admin: Admin.Public? = nil, magCategory: MagCategory? = nil) -> Mag.Public {
        return Mag.Public(id: id,title: title, description: description, coverURL: coverURL, admin: admin, magCategory: magCategory,coverThumbnailURL: coverThumbnailURL, coverFilesURL: coverFilesURL)
  }
}

extension Future where T: Mag {
    func convertToPublic(tags: [Tag]? = nil) -> Future<Mag.Public> {
    return self.map(to: Mag.Public.self) { mag in
      return mag.convertToPublic()
    }
  }
}

extension Mag {
static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection) { (builder) in
        try addProperties(to: builder)
        builder.reference(from: \.magCategoryID, to: \MagCategory.id)
        builder.reference(from: \.adminID, to: \Admin.id)
        builder.unique(on: \.title)
        }
    }
}

extension Mag: PostgreSQLUUIDModel {}
extension Mag: Content {}
extension Mag: Migration {}
extension Mag: Parameter {}
extension Mag.Public: Content {}
