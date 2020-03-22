//
//  UserController.swift
//  App
//
//  Created by Sina khanjani on 11/25/1398 AP.
//

import Vapor
import Crypto
import Fluent
import Authentication

struct UserController: RouteCollection {
    
    private let basePath: PathComponentsRepresentable = [Constant.Path.base,"user"]
    
    func boot(router: Router) throws {
        let routes = router.grouped(basePath)
        routes.post("authentication", use: sendOTPCode)
        routes.post("verification", use: verificationHandler)
        routes.post("google", use: googleAuthentication)
        // Bearer Authorization
        let jwtProtected = routes.grouped(JWTMiddleware())
        jwtProtected.get("me",use: meHandler)
        jwtProtected.post("updateInfo", use: editHandler)
        jwtProtected.post("addTag", use: addTagHandler)
        jwtProtected.post("googleAuthentication", use: googleSendCode)
        jwtProtected.post("googleVerification", use: googleVerification)
        // Basic authentication
        let basicAuthMiddleware = Admin.basicAuthMiddleware(using: BCryptDigest())
        let guardAuthMiddleware = Admin.guardAuthMiddleware()
        let protected = routes.grouped(basicAuthMiddleware,guardAuthMiddleware)
        protected.get(use: getHandler)
        protected.get("userDetail",use: userDetailHandler)
        protected.get("delete",User.parameter, use: removeHandler)
    }
    
    // --- Fetch ---
    func meHandler(_ request: Request) throws -> Future<Generic<User.Public>> {
        return try request.authorizedUser().flatMap { (user) in
            guard user.authorized != nil else {
                throw Abort(HTTPResponseStatus.notAcceptable, reason: "User not register")
            }
            return Future.map(on: request) { () -> Generic<User.Public> in
                return Generic<User.Public>(error: false, data: user.convertToPublic())
            }
        }
    }
    
    func getHandler(_ request: Request) throws -> Future<Generic<[User.Public]>> {
        return User.query(on: request).decode(data: User.Public.self)
            .all()
            .flatMap { (pubs) in
                return Future.map(on: request) { () -> Generic<[User.Public]> in
                    return Generic<[User.Public]>(error: false, data: pubs)
            }
        }
    }
    
    func userDetailHandler(_ request: Request) throws -> Future<Generic<User.Public>> {
        let mobile = request.query[String.self, at: "mobile"]
        let username = request.query[String.self, at: "username"]
        return User.query(on: request).decode(data: User.self)
            .group(.or, closure: { (or) in
                or.filter(\.mobile == mobile ?? "$%*")
                or.filter(\.username == username?.capitalizingFirstLetter() ?? "*&^")
            })
            .first()
            .flatMap(to: Generic<User.Public>.self) { (user) in
                if let user = user {
                    return Future.map(on: request) { () -> Generic<User.Public> in
                        return Generic<User.Public>(error: false, data: user.convertToPublic())
                    }
                } else {
                    throw Abort(HTTPResponseStatus.badRequest, reason: "not found user/public")
                }
            }
    }
    
    // --- Login ---
    func sendOTPCode(_ request: Request) throws -> Future<Generic<Empty>> {
        try request.content.decode(User.self)
            .flatMap(to: User.self, { (decodeItem) in
                 User.query(on: request).filter(\.mobile == decodeItem.mobile ?? "*").first().flatMap(to: User.self) { (user) in
                    if let user = user {
                        // ---> Old Auth <---
                        return Future.map(on: request) { () -> User in
                            _ = try user.phoneAdded().save(on: request)
                            return user
                        }
                    } else {
                        // ---> New Auth <---
                        return try decodeItem.phoneAdded().save(on: request)
                    }
                }
            })
            .flatMap { (user) in
                try AuthenticationController.default.sendOTP(user, request)
                return Future.map(on: request) { () -> Generic<Empty> in
                    guard let mobile = user.mobile else {
                        throw Abort(.badRequest,reason: "Phone Requirement")
                    }
                    return Generic<Empty>(error: false, reason: "Verification code send to \(mobile).", data: nil)
                }
        }
    }
    
    // --- Verification ---
    func verificationHandler(_ request: Request) throws -> Future<Generic<JWToken>> {
        try request.content.decode(Authentication.Response.self).flatMap(to: Generic<JWToken>.self, { (auth) in
            Authentication.query(on: request).filter(\.mobile == auth.mobile).sort(\.createdAt,._descending).first().flatMap(to: Generic<JWToken>.self) { (dbAuth) in
                try AuthenticationController.default.verification(dbAuth, auth, request)
            }
        })
    }
    
    // ---========= Auth with google =========---
    func googleAuthentication(_ request: Request) throws -> Future<Generic<JWToken>> {
        try request.content.decode(Authentication.GResponse.self).flatMap(to: Generic<JWToken>.self, { (auth) in
            return try AuthenticationController.default.authWithGoogle(request, auth)
        })
    }
    
    // --- Google Verification ---
    func googleVerification(_ request: Request) throws -> Future<Generic<Empty>> {
        return try AuthenticationController.default.GPhoneVerification(request)
    }
    
    // ----- Google send mobile phone -----
    func googleSendCode(_ request: Request) throws -> Future<Generic<Empty>> {
        return try AuthenticationController.default.GPhoneSendOTP(request)
    }
    
    // --- Removed ---
    func removeHandler(_ request: Request) throws -> Future<Generic<Empty>> {
        _ = try request.parameters.next(User.self).flatMap(to: User.self, { (user) in
            try user.remove().delete(on: request).map(to: User.self, { (_) -> User in
                return user
                })
            })
        
        return Future.map(on: request) { () -> Generic<Empty> in
            return Generic<Empty>(error: false, data: nil)
        }
    }
// ================= =============== ================ ==============
    
    // --- Edited ---
//    func editHandler(_ request: Request) throws -> Future<Generic<Empty>> {
//        _ = try flatMap(to: User.self, request.parameters.next(User.self), request.content.decode(User.self), { (user, updatedUser) in
//            return try user.edit(user: updatedUser)
//            .save(on: request)
//            })
//        return Future.map(on: request) { () -> Generic<Empty> in
//            return Generic<Empty>(error: false, data: nil)
//        }
//    }
    func editHandler(_ request: Request) throws -> Future<Generic<User.Public>> {
         return try request.authorizedUser().flatMap { (user) in
            return try request.content.decode(User.Update.self).flatMap({ (updatedUser) in
                _ = try user.updated(user: updatedUser).save(on: request)
                return Future.map(on: request) { () -> Generic<User.Public> in
                    return Generic<User.Public>(error: false, reason: "User updated parameters successfully", data: user.convertToPublic())
                }
            })
        }
    }
    
    // --- Tag Helper ---
    func addTagHandler(_ request: Request) throws -> Future<Generic<User.Public>> {
        func removeAll(reason: String, user: User) -> Future<Generic<User.Public>> {
            // --- last tags in user ---
            let tagTypes = user.tags.map { $0.map { $0.subType} }
            // -- set all tags to nil ---
            user.tags = nil
            return user.save(on: request).flatMap { (user) in
                // --- set fcm topic ---
                tagTypes?.forEach({ (topic) in
                    FCMPush.default.removeTopic(topic: topic, user: user, request: request)
                })
                // --- return user ---
                return Future.map(on: request) { () -> Generic<User.Public> in
                    return Generic<User.Public>.init(error: false, reason: reason, data: user.convertToPublic())
                }
            }
        }
        return try request.authorizedUser().flatMap { (user) in
            return Tag.query(on: request).all().flatMap { (items) in
                guard let content = try? request.content.syncDecode([String].self) else {
                    return removeAll(reason: "Tags are removed", user: user)
                }
                if !content.isEmpty {
                    // ---- set fcm topic ---
                    let oldTags = user.tags.map { $0.map { $0 } }
                    let tagIDsUpdated = content.map { Tag.ID($0) }
                    let tags = items.filter { tagIDsUpdated.contains($0.id) }
                    user.tags = tags.map { $0.convertToPublic()}
                    let set1:Set<String> = Set(oldTags?.map { $0.subType } ?? [])
                    let set2:Set<String> = Set(tags.map { $0.subType })
                    let removedTopic = set1.subtracting(set2)
                    removedTopic.forEach { (topic) in
                        FCMPush.default.removeTopic(topic: topic, user: user, request: request)
                    }
                    let addedTopic = set2.subtracting(set1)
                    addedTopic.forEach { (topic) in
                        FCMPush.default.createAndAddTopic(topic: topic, user: user, request: request)
                    }
                    // --- save user ----
                    return user.save(on: request).flatMap { (user) in
                        return Future.map(on: request) { () -> Generic<User.Public> in
                            return Generic<User.Public>(error: false, data: user.convertToPublic())
                        }
                    }
                } else {
                    // -- removed when an array empty ---
                    return removeAll(reason: "Tags are removed", user: user)
                }
            }
        }
    }
}


