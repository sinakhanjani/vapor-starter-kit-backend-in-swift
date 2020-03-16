//
//  MagController.swift
//  App
//
//  Created by Sina khanjani on 11/26/1398 AP.
//

import Vapor
import Authentication
import Fluent

struct MagCategoryController: RouteCollection {
    
    private let basePath: PathComponentsRepresentable = [Constant.Path.base,"magCategory"]

    func boot(router: Router) throws {
        let routes = router.grouped(basePath)
        routes.get(use: getHandler)
        routes.get("mags",MagCategory.parameter, use: getByCategory)
        routes.get("delete",MagCategory.parameter, use: removeHandler)
        // Basic authentication
        let basicAuthMiddleware = Admin.basicAuthMiddleware(using: BCryptDigest())
        let guardAuthMiddleware = Admin.guardAuthMiddleware()
        let protected = routes.grouped(basicAuthMiddleware,guardAuthMiddleware)
        protected.post(Post.self, at: "add", use: createHandler)
    }
    
    // --- Fetch ---
    func getHandler(_ request: Request) throws -> Future<Generic<[MagCategory]>> {
        return MagCategory.query(on: request)
            .all()
            .flatMap { (categories) in
                return Future.map(on: request) { () -> Generic<[MagCategory]> in
                    return Generic<[MagCategory]>(error: false, data: categories)
                }
        }
    }
    
    // --- Fetch by categoryID([Mag]) ---
    func getByCategory(_ request: Request) throws -> Future<Generic<[Mag]>> {
        return try request.parameters.next(MagCategory.self)
        .flatMap(to: [Mag].self) { (magCategory) in
            try magCategory.mag.query(on: request)
            .all()
        }
        .flatMap(to: Generic<[Mag]>.self) { (mags) in
            return Future.map(on: request) { () -> Generic<[Mag]> in
                return Generic<[Mag]>(error: false, data: mags)
            }
        }
    }
    
    // --- Add ---
    func createHandler(_ request: Request,_ post: Post) throws -> Future<Generic<MagCategory>> {
        guard let adminID = Admin.ID(post.adminID) else {
            throw Abort(.badRequest, reason: "adminID not found")
        }
        _ = Admin.find(adminID, on: request).map { (admin) in
            if let _ = admin {
                //
            } else {
                throw Abort(HTTPResponseStatus.nonAuthoritativeInformation)
            }
        }
        let picture = Directory(ext: "jpg", folder: .picture(["MagCategory","\(post.title)"]))
        let magCategory = MagCategory(title: post.title, description: post.description, coverURL: picture.filePath, adminID: adminID)
        return request.transaction(on: .psql) { (connection) -> Future<MagCategory> in
            try picture.save(with: post.coverFile.data, compress: .yes)
            return magCategory.create(on: connection)
        }
        .flatMap { (magCategory) in
            return Future.map(on: request) { () -> Generic<MagCategory> in
                return Generic<MagCategory>(error: false, data: magCategory)
            }
        }
    }
    
    // --- Removed ---
    func removeHandler(_ request: Request) throws -> Future<Generic<Empty>> {
        _ = try request.parameters.next(MagCategory.self).flatMap(to: MagCategory.self, { (magCategory) in
            try magCategory.remove().delete(on: request).map(to: MagCategory.self, { (_) -> MagCategory in
                return magCategory
                })
            })
        return Future.map(on: request) { () -> Generic<Empty> in
            return Generic<Empty>(error: false, data: nil)
        }
    }
}

extension MagCategoryController {
    internal struct Post: Content {
        let title: String
        let description: String
        let adminID: String
        let coverFile: File
    }
}
