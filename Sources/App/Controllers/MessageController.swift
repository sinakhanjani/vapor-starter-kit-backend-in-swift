//
//  NotificationController.swift
//  App
//
//  Created by Sina khanjani on 12/19/1398 AP.
//

import Vapor
import Crypto
import Fluent
import Authentication

struct MessageController: RouteCollection {
    
    private let basePath: PathComponentsRepresentable = [Constant.Path.base,"message"]

    func boot(router: Router) throws {
        let routes = router.grouped(basePath)
        // JWT authentication
        let jwtProtected = routes.grouped(JWTMiddleware())
        jwtProtected.get(use: getHandler)
        // Basic authentication
        let basicAuthMiddleware = Admin.basicAuthMiddleware(using: BCryptDigest())
        let guardAuthMiddleware = Admin.guardAuthMiddleware()
        let protected = routes.grouped(basicAuthMiddleware,guardAuthMiddleware)
        protected.post(Message.self, at: "add", use: createHandler)
    }
    
    // --- Fetch ---
    func getHandler(_ request: Request) throws -> Future<Generic<[Message.Public]>> {
        return try request.authorizedUser().flatMap { (user) in
            let lower = Int(request.query[String.self, at: "from"] ?? "0") ?? 0
            let upper = Int(request.query[String.self, at: "per"] ?? "10") ?? 10
            return try user.message.query(on: request)
            .sort(\.createdAt,._descending)
            .range(lower: lower, upper: upper-1)
            .all()
            .flatMap(to: Generic<[Message.Public]>.self) { (messages) in
                let publics = messages.map {
                           Message.Public(title: $0.title, description: $0.description, userID: $0.userID, responder: nil)
                       }
                return try user.message.query(on: request).count().map(to: Generic<[Message.Public]>.self, { (total) in
                      return Generic<[Message.Public]>(error: false, data: publics, pagination: Pagination(from: lower, per: upper, total: total))
                  })
            }
        }
    }

    // ---- Added ---
    func createHandler(_ request: Request,_ parent: Message) throws -> Future<Generic<Empty>> {
        try request.content.decode(Message.self)
            .flatMap(to: Message.self, { (message) in
                User.query(on: request).filter(\.id == parent.userID).first().flatMap(to: Message.self) { (user) in
                    if user == nil {
                        throw Abort(HTTPResponseStatus.badRequest)
                    } else {
                        return try message.added().save(on: request)
                    }
                }
            })
        .flatMap { (notify)in
            return Future.map(on: request) { () -> Generic<Empty> in
                return Generic<Empty>(error: false, reason: "Message send to user", data: nil)
            }
        }
    }
}
