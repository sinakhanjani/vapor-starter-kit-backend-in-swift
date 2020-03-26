//
//  MagController.swift
//  App
//
//  Created by Sina khanjani on 11/28/1398 AP.
//

import Vapor
import Fluent
import Crypto

struct MagController: RouteCollection {
    
    private let basePath: PathComponentsRepresentable = [Constant.Path.base,"mag"]

    func boot(router: Router) throws {
        let routes = router.grouped(basePath)
        routes.get(use: fetchAllHandler)
        routes.get(MagCategory.parameter,use: fetchByCategoryHandler)
        routes.get("tags",Mag.parameter, use: getTagsHandler)
        routes.get("category",Mag.parameter, use: getCategoryHandler)
        // Basic authentication
        let basicAuthMiddleware = Admin.basicAuthMiddleware(using: BCryptDigest())
        let guardAuthMiddleware = Admin.guardAuthMiddleware()
        let protected = routes.grouped(basicAuthMiddleware,guardAuthMiddleware)
        protected.get("delete",Mag.parameter, use: removeHandler)
        protected.get("addTag",Tag.parameter,"to",Mag.parameter, use: subscribeTag)
        protected.get("deleteTag",Tag.parameter,"from",Mag.parameter, use: unsubscribeTag)
        protected.post("update",Mag.parameter, use: editHandler)
        protected.post(Post.self, at: "add", use: createHandler)
    }
    
    // --- Fetches ---
    func fetchByCategoryHandler(_ request: Request) throws -> Future<Generic<[Mag.Public]>> {
        let lower = Int(request.query[String.self, at: "from"] ?? "0") ?? 0
        let upper = Int(request.query[String.self, at: "per"] ?? "10") ?? 10
        return try request.parameters.next(MagCategory.self).flatMap(to: Generic<[Mag.Public]>.self) { (magCategory) in
            return Mag.query(on: request)
                .filter(\.magCategoryID == magCategory.id!)
                .sort(\.createdAt,._descending)
                .range(lower: lower, upper: upper-1)
                .join(\Admin.id, to: \Mag.adminID, method: .left)
                .join(\MagCategory.id, to: \Mag.magCategoryID)
                .alsoDecode(MagCategory.self)
                .alsoDecode(Admin.self)
                .all()
                .map(to: Generic<[Mag.Public]>.self) { (result) in
                    let data =  result.map {
                        $0.0.0.convertToPublic(admin: $0.1.convertToPublic(), magCategory: $0.0.1)
                    }
                    return Generic<[Mag.Public]>(error: false, data: data, pagination: Pagination(from: lower, per: upper, total: result.count))
            }
        }
    }
    
    func fetchAllHandler(_ request: Request) throws -> Future<Generic<[Mag.Public]>> {
        let lower = Int(request.query[String.self, at: "from"] ?? "0") ?? 0
        let upper = Int(request.query[String.self, at: "per"] ?? "10") ?? 10
        return Mag.query(on: request)
            .sort(\.createdAt,._descending)
            .range(lower: lower, upper: upper-1)
            .join(\Admin.id, to: \Mag.adminID, method: .left)
            .join(\MagCategory.id, to: \Mag.magCategoryID)
            .alsoDecode(MagCategory.self)
            .alsoDecode(Admin.self)
            .range(lower: 0, upper: 10000)
            .all()
            .map(to: Generic<[Mag.Public]>.self) { (result) in
                let data =  result.map {
                    $0.0.0.convertToPublic(admin: $0.1.convertToPublic(), magCategory: $0.0.1)
                }
                return Generic<[Mag.Public]>(error: false, data: data, pagination: Pagination(from: lower, per: upper, total: result.count))
        }
    }

    // -- Get Parent -> (magCategory) ---
    func getCategoryHandler(_ request: Request) throws -> Future<Generic<MagCategory>> {
        return try request.parameters.next(Mag.self)
        .flatMap(to: MagCategory.self) { (mag) in
            return mag.magCategory.get(on: request)
        }
        .flatMap(to: Generic<MagCategory>.self) { (magCategory) in
            return Future.map(on: request) { () -> Generic<MagCategory> in
                return Generic<MagCategory>(error: false, data: magCategory)
            }
        }
    }
    
    // --- Add ---
    func createHandler(_ request: Request,_ post: Post) throws -> Future<Generic<Mag>> {
        guard let adminID = Admin.ID(post.adminID), let magCategoryID = MagCategory.ID(post.magCategoryID) else {
            throw Abort(HTTPResponseStatus.badRequest, reason: "AdminID or magCategoryID not valid.")
        }
        let coverDir = Directory(ext: "jpg", folder: .picture(["Mags","\(post.title)"]))
        let coverThumbnailDir = Directory(ext: "jpg", folder: .picture(["Mags","\(post.title)"]))
        var coversDir: [Directory]?
        _ = try post.coverFiles.map { coverFile in
            let coverDir = Directory(ext: "jpg", folder: .picture(["Mags","\(post.title)"]))
            if let _ = coversDir {
                coversDir!.append(coverDir)
            } else {
                coversDir = [coverDir]
            }
            try coverDir.save(with: coverFile.data, compress: .no)
        }
        let mag = Mag(title: post.title, description: post.description, coverURL: coverDir.filePath, adminID: adminID, magCategoryID: magCategoryID, coverThumbnailURL: coverThumbnailDir.filePath, coverFilesURL: coversDir?.map { $0.filePath })
        return request.transaction(on: .psql) { (connection) -> Future<Mag> in
            try coverDir.save(with: post.coverFile.data, compress: .no)
            try coverThumbnailDir.save(with: post.coverFile.data, compress: .yes)
            return mag.create(on: connection)
        }
        .flatMap { (mag) in
            return Future.map(on: request) { () -> Generic<Mag> in
                return Generic<Mag>(error: false, data: mag)
            }
        }
    }

    //   --- Edit ---
    func editHandler(_ request: Request) throws -> Future<Generic<Mag>> {
        return try request.parameters.next(Mag.self).flatMap(to: Generic<Mag>.self, { (mag) in
            return try request.content.decode(Post.Update.self).flatMap(to: Generic<Mag>.self) { (updatedPost) in
                guard let adminID = Admin.ID(updatedPost.adminID) else {
                    throw Abort(HTTPResponseStatus.badRequest, reason: "AdminID not valid.")
                }
                let coverDir = Directory(ext: "jpg", folder: .picture(["Mags","\(mag.title)"]))
                let coverThumbnailDir = Directory(ext: "jpg", folder: .picture(["Mags","\(mag.title)"]))
                var coversDir: [Directory]?
                _ = try updatedPost.coverFiles.map { coverFile in
                    let coverDir = Directory(ext: "jpg", folder: .picture(["Mags","\(mag.title)"]))
                    if let _ = coversDir {
                        coversDir!.append(coverDir)
                    } else {
                        coversDir = [coverDir]
                    }
                    try coverDir.save(with: coverFile.data, compress: .no)
                }
                let newCoverPath = updatedPost.coverFile == nil ? mag.coverURL:coverDir.filePath
                let newCoverThumbnailPath = updatedPost.coverFile == nil ? mag.coverThumbnailURL:coverThumbnailDir.filePath
                let coverFilesPath = updatedPost.coverFiles.isEmpty ? mag.coverFilesURL:coversDir?.map { $0.filePath }
                let updatedMag = Mag(title: mag.title, description: updatedPost.description ?? mag.description, coverURL: newCoverPath, adminID: adminID, magCategoryID: mag.magCategoryID, coverThumbnailURL: newCoverThumbnailPath, coverFilesURL: coverFilesPath)
                return request.transaction(on: .psql) { (connection) -> Future<Mag> in
                    if let coverFile = updatedPost.coverFile {
                        try coverDir.save(with: coverFile.data, compress: .no)
                        try coverThumbnailDir.save(with: coverFile.data, compress: .yes)
                    }
                    return try mag.edit(updatedMag, adminID: adminID).save(on: request)
                }
                .flatMap { (mag) in
                    return Future.map(on: request) { () -> Generic<Mag> in
                        return Generic<Mag>(error: false, data: mag)
                    }
                }
            }
        })
    }
    
    // --- Remove ---
    func removeHandler(_ request: Request) throws -> Future<Generic<Empty>> {
        _ = try request.parameters.next(Mag.self).flatMap(to: Mag.self, { (mag) in
            try mag.remove().delete(on: request).map(to: Mag.self, { (_) -> Mag in
                return mag
                })
            })
        return Future.map(on: request) { () -> Generic<Empty> in
            return Generic<Empty>(error: false, data: nil)
        }
    }
    
    // --- Subscribe tag to mag ---
    func subscribeTag(_ request: Request) throws -> Future<Generic<Empty>> {
          try flatMap(to: Generic<Empty>.self,request.parameters.next(Tag.self),request.parameters.next(Mag.self)
          ) { tag, mag in
            _ = mag.tags.attach(tag, on: request)
              return Future.map(on: request) { () -> Generic<Empty> in
                  return Generic<Empty>(error: false, reason: "Tag is added to article", data: nil)
              }
        }
    }
    
    // --- Unsubscribe tag to mag ---
    func unsubscribeTag(_ request: Request) throws -> Future<Generic<Empty>> {
          try flatMap(to: Generic<Empty>.self,request.parameters.next(Tag.self),request.parameters.next(Mag.self)
          ) { tag, mag in
              _ = mag.tags.detach(tag, on: request)
              return Future.map(on: request) { () -> Generic<Empty> in
                  return Generic<Empty>(error: false, reason: "Tag is removed from article", data: nil)
              }
        }
    }
    
    // -- Fetch tags ---
    func getTagsHandler(_ request: Request) throws -> Future<Generic<[Tag]>> {
        return try request.parameters.next(Mag.self)
            .flatMap(to: Generic<[Tag]>.self, { (mag) in
                try mag.tags.query(on: request)
                .all()
                .flatMap { (tags) in
                    return Future.map(on: request) { () -> Generic<[Tag]> in
                        return Generic<[Tag]>(error: false, data: tags)
                    }
                }
            })
    }
}

extension MagController {
     struct Post: Content {
        let title: String
        let description: String
        let coverFile: File
        var coverFiles: [File]
        let adminID: String
        let magCategoryID: String

        struct Update: Content {
            let description: String?
            let coverFile: File?
            var coverFiles: [File]
            let adminID: String
        }
    }
}
