//
//  NotificationController.swift
//  App
//
//  Created by Sina khanjani on 12/23/1398 AP.
//

import Vapor
import Crypto
import Fluent
import Authentication

struct NotificationController: RouteCollection {
    
    private let basePath: PathComponentsRepresentable = [Constant.Path.base,"notification"]

    func boot(router: Router) throws {
        let routes = router.grouped(basePath)
        //...
        // Basic authentication'
        let basicAuthMiddleware = Admin.basicAuthMiddleware(using: BCryptDigest())
        let guardAuthMiddleware = Admin.guardAuthMiddleware()
        let protected = routes.grouped(basicAuthMiddleware,guardAuthMiddleware)
        protected.post("send", use: sendHalndler)
        protected.post("senttag", use: sentToTagIDHandler)
        protected.post("senduser", use: sentToUserIDHandler)
        protected.get("tokens", use: tokensListHandler)
        protected.get("user", use: tokenByUsers)
        protected.get("fcmToken",use: fcmTokenHandler)
    }
    
    // --- Send User ---
    func sendHalndler(_ request: Request) throws -> Future<Generic<Empty>> {
        return try request.content.decode(NotificationSend.self).flatMap(to: Generic<Empty>.self, { (send)  in
            return User.query(on: request).all().flatMap(to: Generic<Empty>.self, { (users) in
                 _ = try users.map { (user) in
                    if let token = user.fcmToken {
                        let directory =  Directory(ext: "jpg", folder: .picture(["Notification"]))
                        if let data = send.coverFile?.data {
                            try directory.save(with: data, compress: .yes)
                        }
                        FCMPush.default.sendNotificationTo(to: token, title: send.title, body: send.description, badge: Int(send.badge ?? ""), notifiCategory: send.category, apn: APN(imageURL: directory.filePath, app: "1.0", syntax: "swift_vapor", type: send.type, source: Source(storyboardID: send.storyboardID, message: send.message, duration: send.duration, webURL: send.webURL, mobile: send.mobile, telephone: send.telephone, chart: send.chart, nerkh: send.nerkh)), sound: send.sound, request: request)
                    }
                }
                return Future.map(on: request) { () -> Generic<Empty> in
                    return Generic<Empty>.init(error: false, reason: "Push notification send complete.", data: nil)
                }
            })
        })
    }
    
    // --- Send to tagID ---
    func sentToTagIDHandler(_ request: Request) throws -> Future<Generic<Empty>> {
        guard let tagID = request.query[String.self, at: "tagID"] else {
            throw Abort(HTTPResponseStatus.badRequest, reason: "Tag not found in database.")
        }
        guard let id = Tag.ID(tagID) else {
            throw Abort(HTTPResponseStatus.badRequest, reason: "Tag not found in database.")
        }
        return try request.content.decode(NotificationSend.self).flatMap(to: Generic<Empty>.self, { (send) in
            return Tag.query(on: request).filter(\.id == id).first().flatMap(to: Generic<Empty>.self) { (tag) in
                if let tag = tag {
                    let directory =  Directory(ext: "jpg", folder: .picture(["Notification"]))
                    if let data = send.coverFile?.data {
                        try directory.save(with: data, compress: .yes)
                    }
                    FCMPush.default.sendNotificationTo(to: "/topics/"+tag.subType, title: send.title, body: send.description, badge: Int(send.badge ?? ""), notifiCategory: send.category, apn: APN(imageURL: directory.filePath, app: "1.0", syntax: "swift_vapor", type: send.type, source: Source(storyboardID: send.storyboardID, message: send.message, duration: send.duration, webURL: send.webURL, mobile: send.mobile, telephone: send.telephone, chart: send.chart, nerkh: send.nerkh)), sound: send.sound, request: request)
                }
                return Future.map(on: request) { () -> Generic<Empty> in
                    return Generic<Empty>.init(error: false, reason: "Push notification send complete.", data: nil)
                }
            }
        })
    }
    
    // --- Send to userID ---
    func sentToUserIDHandler(_ request: Request) throws -> Future<Generic<Empty>> {
        guard let userID = request.query[String.self, at: "userID"] else {
            throw Abort(HTTPResponseStatus.badRequest, reason: "User not found in database.")
        }
        guard let id = User.ID(userID) else {
            throw Abort(HTTPResponseStatus.badRequest, reason: "User not found in database.")
        }
        return try request.content.decode(NotificationSend.self).flatMap(to: Generic<Empty>.self, { (send) in
            return User.query(on: request).filter(\.id == id).first().flatMap(to: Generic<Empty>.self) { (user) in
                if let user = user {
                    let directory =  Directory(ext: "jpg", folder: .picture(["Notification"]))
                    if let data = send.coverFile?.data {
                        try directory.save(with: data, compress: .yes)
                    }
                    if let fcmToken = user.fcmToken {
                        FCMPush.default.sendNotificationTo(to: fcmToken, title: send.title, body: send.description, badge: Int(send.badge ?? ""), notifiCategory: send.category, apn: APN(imageURL: directory.filePath, app: "1.0", syntax: "swift_vapor", type: send.type, source: Source(storyboardID: send.storyboardID, message: send.message, duration: send.duration, webURL: send.webURL, mobile: send.mobile, telephone: send.telephone, chart: send.chart, nerkh: send.nerkh)), sound: send.sound, request: request)
                    }
                }
                return Future.map(on: request) { () -> Generic<Empty> in
                    return Generic<Empty>.init(error: false, reason: "Push notification send complete.", data: nil)
                }
            }
        })
    }
    
    // --- Fetch users tokens ---
    func tokensListHandler(_ request: Request) throws -> Future<Generic<[String]>> {
        return User.query(on: request).all().flatMap(to: Generic<[String]>.self, { (users) in
            let tokens = (users.map { $0.fcmToken ?? "" }).filter { !$0.isEmpty }
            return Future.map(on: request) { () -> Generic<[String]> in
                return Generic<[String]>.init(error: false, reason: "Success", data: tokens)
            }
        })
    }
    
    // --- Fetch token by phone and userID ---
    func tokenByUsers(_ request: Request) throws -> Future<Generic<NotificationSend.Token>> {
        let mobile = request.query[String.self, at: "mobile"]
        let username = request.query[String.self, at: "username"]
        return User.query(on: request)
            .group(.or, closure: { (or) in
                or.filter(\.mobile == mobile ?? "$%*")
                or.filter(\.username == (username?.capitalizingFirstLetter() ?? "*&^"))
            })
            .first().flatMap(to: Generic<NotificationSend.Token>.self, { (user) in
                if let user = user {
                    let token = NotificationSend.Token(mobile: (user.mobile ?? user.username) ?? "---", fcmToken: user.fcmToken ?? "", userID: user.id!, name: user.name ?? "")
                    return Future.map(on: request) { () -> Generic<NotificationSend.Token> in
                        return Generic<NotificationSend.Token>(error: false, reason: "Success", data: token)
                    }
                } else {
                    throw Abort(HTTPResponseStatus.badRequest, reason: "User not found in database.")
                }
        })
    }
    
    // --- fcmToken ---
    func fcmTokenHandler(_ request: Request) throws -> Future<Generic<[String]>> {
        guard let tagID = request.query[String.self, at: "tagID"] else {
            throw Abort(HTTPResponseStatus.badRequest, reason: "tagID not found.")
        }
        return User.query(on: request)
            .all().flatMap(to: Generic<[String]>.self, { (users) in
            let tokens = try users.map { user -> String in
                let tags = user.tags.map { $0.map { $0 } }
                let tagsID:Array<UUID> = tags?.map { $0.id! } ?? []
                guard let tagUUID = Tag.ID(tagID) else {
                    throw Abort(.badRequest, reason: "TagID not correct.")
                }
                var token = ""
                if tagsID.contains(tagUUID) {
                    if let fcmToken = user.fcmToken {
                        token = fcmToken
                    }
                }
                return token
            }.filter { !$0.isEmpty }
            return Future.map(on: request) { () -> Generic<[String]> in
                return Generic<[String]>(error: false, data: tokens)
            }
        })
    }
}
