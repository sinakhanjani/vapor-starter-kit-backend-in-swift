//
//  AdminController.swift
//  App
//
//  Created by Sina khanjani on 11/27/1398 AP.
//

import Vapor
import Crypto

struct AdminController: RouteCollection {
    
    private let basePath: PathComponentsRepresentable = [Constant.Path.base,"administrator"]
    
    func boot(router: Router) throws {
        let routes = router.grouped(basePath)
        routes.post("add", use: createHandler)
        // Basic authentication
        let basicAuthMiddleware = Admin.basicAuthMiddleware(using: BCryptDigest())
        let guardAuthMiddleware = Admin.guardAuthMiddleware()
        let protected = routes.grouped(basicAuthMiddleware,guardAuthMiddleware)
        protected.get(use: getHandler)
        protected.get("magCategory",Admin.parameter, use: getMagCategoryByID)
        protected.get("delete",Admin.parameter, use: removeHandler)
        protected.post("update",Admin.parameter, use: editHandler)
    }
    
    // --- Fetch ---
    func getHandler(_ request: Request) throws -> Future<Generic<[Admin.Public]>> {
        return Admin.query(on: request)
            .decode(data: Admin.Public.self)
            .all()
            .flatMap { (pubs) in
                return Future.map(on: request) { () -> Generic<[Admin.Public]> in
                    return Generic<[Admin.Public]>(error: false, data: pubs)
                }
        }
    }
    
    // --- Fetch magCategory create's by Admin ---
    func getMagCategoryByID(_ request: Request) throws -> Future<Generic<[MagCategory]>> {
        return try request.parameters.next(Admin.self)
        .flatMap(to: [MagCategory].self) { (admin) in
            try admin.magCategory.query(on: request)
            .all()
        }
        .flatMap(to: Generic<[MagCategory]>.self) { (magCategorys) in
            return Future.map(on: request) { () -> Generic<[MagCategory]> in
                return Generic<[MagCategory]>(error: false, data: magCategorys)
            }
        }
    }
    
    // ---- Added ---
    func createHandler(_ request: Request) throws -> Future<Generic<Admin>> {
        try request.content.decode(Admin.self)
            .flatMap(to: Admin.self, { (admin) in
                admin.password = try BCrypt.hash(admin.password)
                return try admin.added().save(on: request)
            })
        .flatMap { (admin)in
            return Future.map(on: request) { () -> Generic<Admin> in
                return Generic<Admin>(error: false, data: admin)
            }
        }
    }
    
    // --- Removed ---
    func removeHandler(_ request: Request) throws -> Future<Generic<Empty>> {
        _ = try request.parameters.next(Admin.self).flatMap(to: Admin.self, { (admin) in
            try admin.remove().delete(on: request).map(to: Admin.self, { (_) -> Admin in
                return admin
                })
            })
        
        return Future.map(on: request) { () -> Generic<Empty> in
            return Generic<Empty>(error: false, data: nil)
        }
        
    }
    
    // --- Edited ---
    func editHandler(_ request: Request) throws -> Future<Generic<Empty>> {
        _ = try flatMap(to: Admin.self, request.parameters.next(Admin.self), request.content.decode(Admin.self), { (admin, updatedUser) in
            return try admin.edit(updatedUser)
            .save(on: request)
            })
        return Future.map(on: request) { () -> Generic<Empty> in
            return Generic<Empty>(error: false, data: nil)
        }
    }
}
