//
//  TagController.swift
//  App
//
//  Created by Sina khanjani on 12/1/1398 AP.
//

import Vapor
import Fluent
import Crypto

struct TagController: RouteCollection {
    
    private let basePath: PathComponentsRepresentable = [Constant.Path.base,"tag"]

    func boot(router: Router) throws {
        let routes = router.grouped(basePath)
        routes.get(use: getHandler)
        routes.get("search",use: searchHandler)
        // Basic authentication
        let basicAuthMiddleware = Admin.basicAuthMiddleware(using: BCryptDigest())
        let guardAuthMiddleware = Admin.guardAuthMiddleware()
        let protected = routes.grouped(basicAuthMiddleware,guardAuthMiddleware)
        protected.get("delete",Tag.parameter, use: removeHandler)
        protected.post("add", use: createHandler)
        protected.post("update",Tag.parameter, use: editHandler)
    }
    
    // --- Fetch ---
    func getHandler(_ request: Request) throws -> Future<Generic<[Tag.Public]>> {
        return Tag.query(on: request)
            .decode(data: Tag.Public.self)
            .all()
            .flatMap { (pubs) in
                return Future.map(on: request) { () -> Generic<[Tag.Public]> in
                    return Generic<[Tag.Public]>(error: false, data: pubs)
            }
        }
    }
    
    // --- Fetch by filter ---
    func searchHandler(_ request: Request) throws -> Future<Generic<[Tag]>> {
        guard let searchItem = request
          .query[String.self, at: "type"] else {
            throw Abort(HTTPResponseStatus.badRequest)
        }
        let queryBuilder = Tag.query(on: request)
        var fetch:EventLoopFuture<[Tag]>
        if searchItem.isEmpty {
            fetch = queryBuilder.all()
        } else {
            fetch = queryBuilder.group(.or) { (or) in
                or.filter(\.type == searchItem)
            }.all()
        }
        func results(_ input: EventLoopFuture<[Tag]>) -> Future<Generic<[Tag]>> {
            input.flatMap { (tags) in
                return Future.map(on: request) { () -> Generic<[Tag]> in
                    return Generic<[Tag]>(error: false, data: tags)
                }
            }
        }
        return results(fetch)
    }
    
    // ---- Added ---
//    func createHandler(_ request: Request) throws -> Future<Generic<Tag>> {
//        try request.content.decode(Tag.self)
//            .flatMap(to: Tag.self, { (tag) in
//                return try tag.added().save(on: request)
//            })
//        .flatMap { (tag)in
//            return Future.map(on: request) { () -> Generic<Tag> in
//                return Generic<Tag>(error: false, data: tag)
//            }
//        }
//    }
    func createHandler(_ request: Request) throws -> Future<Generic<Tag>> {
        try request.content.decode(Tag.Post.self)
            .flatMap(to: Tag.self, { (post) in
                let iconDir = Directory(ext: "jpg", folder: .picture(["Tags","\(post.title)"]))
                let tag = Tag(title: post.title, description: post.description, type: post.type, iconURL: iconDir.filePath, subType: post.subType)
                _ = try iconDir.save(with: post.iconURL.data, compress: .yes)
                return try tag.added().save(on: request)
            })
        .flatMap { (tag)in
            return Future.map(on: request) { () -> Generic<Tag> in
                return Generic<Tag>(error: false, data: tag)
            }
        }
    }
    
    // --- Removed ---
    func removeHandler(_ request: Request) throws -> Future<Generic<Empty>> {
        _ = try request.parameters.next(Tag.self).flatMap(to: Tag.self, { (admin) in
            try admin.remove().delete(on: request).map(to: Tag.self, { (_) -> Tag in
                return admin
                })
            })
        
        return Future.map(on: request) { () -> Generic<Empty> in
            return Generic<Empty>(error: false, data: nil)
        }
        
    }
    
    // --- Edited ---
    func editHandler(_ request: Request) throws -> Future<Generic<Empty>> {
        _ = try flatMap(to: Tag.self, request.parameters.next(Tag.self), request.content.decode(Tag.self), { (tag, updatedUser) in
            return try tag.edit(updatedUser)
            .save(on: request)
            })
        return Future.map(on: request) { () -> Generic<Empty> in
            return Generic<Empty>(error: false, data: nil)
        }
    }
}
