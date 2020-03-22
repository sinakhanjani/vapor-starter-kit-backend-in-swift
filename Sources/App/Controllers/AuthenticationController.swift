//
//  AuthenticationController.swift
//  App
//
//  Created by Sina khanjani on 12/18/1398 AP.
//

import Foundation
import Vapor
import Crypto
import Fluent
import FluentPostgreSQL

struct AuthenticationController {
    
    static let `default` = AuthenticationController()
    
    private func sendOTPCode(mobile: String, type: OTP_API.CodeType, request: Request) throws -> (mobile: String, code: String) {
        func codegen() -> String {
            var result = ""
            repeat {
                result = String(format:"%04d", arc4random_uniform(10000) )
            } while result.count < 4 || Int(result)! < 1000
            return result
        }
        let code = codegen()
        OTP_API.default.getToken(request: request) { (token) in
            if let token = token {
                OTP_API.default.sendCode(mobile: mobile, code: code, type: type, token: token, request: request) {
                    ///
                }
            }
        }
        return (mobile: mobile, code: code)
    }
    
    public func sendOTP(_ user: User,_ request: Request) throws {
        let codeType: OTP_API.CodeType = user.authorized! ? .login:.register
        guard let mobile = user.mobile else {
            throw Abort(.badRequest,reason: "Phone Requirement")
        }
        let sendOTP = try AuthenticationController.default.sendOTPCode(mobile: mobile, type: codeType, request: request)
        let auth = Authentication(mobile: mobile, code: sendOTP.code, userID: user.id!)
        _ = auth.save(on: request)
    }
    
    public func verification(_ dbAuth: Authentication?,_ auth: Authentication.Response,_ request: Request) throws -> Future<Generic<JWToken>> {
        if let dbAuth = dbAuth {
            if let code = dbAuth.code {
                if code == auth.code {
                    // --- Successfully code ---
                    return try addJWT(request, auth)
                } else {
                    // --- Invalid code ---
                    throw Abort(HTTPResponseStatus.badRequest, reason: "Invalid verification code")
                }
            } else {
                throw Abort(HTTPResponseStatus.badRequest, reason: "Code not available in database")
            }
        } else {
            throw Abort(HTTPResponseStatus.badRequest, reason: "Auth not valid")
        }
    }
    
    private func addJWT(_ request: Request,_ auth: Authentication.Response) throws -> EventLoopFuture<Generic<JWToken>> {
        return User.query(on: request).filter(\.mobile == auth.mobile).first().map(to: Generic<JWToken>.self, { (user) in
            if let user = user {
                guard let mobile = user.mobile else {
                    throw Abort(.badRequest,reason: "Phone Requirement")
                }
                let accessToken = try TokenController.createAccessToken(from: user)
                let jwtAccess = JWToken(token: accessToken, userID: user.id!, mobile: mobile, username: nil)
                _ = jwtAccess.save(on: request)
                _ = User.query(on: request).filter(\.mobile == auth.mobile).first().flatMap { (user) in
                    try user!.authorizedPhoneUser(token: accessToken, fcmToken: auth.fcmToken, reference: auth.reference, operationSystem: auth.operationSystem).save(on: request)
                }
                return Generic.init(error: false, reason: "Success", data: jwtAccess)
            } else {
                throw Abort(HTTPResponseStatus.badRequest, reason: "User not valid.")
            }
        })
    }
}

// ======= Google Auth =========
extension AuthenticationController {
    public func authWithGoogle(_ request: Request,_ auth: Authentication.GResponse) throws -> EventLoopFuture<Generic<JWToken>> {
        return User.query(on: request).filter(\.username == auth.username.capitalizingFirstLetter()).first().flatMap(to: Generic<JWToken>.self, { (user) in
            if let user = user {
                // --- old user ----
                let accessToken = try TokenController.createAccessToken(from: user)
                let jwtAccess = JWToken(token: accessToken, userID: user.id!, mobile: nil, username: auth.username.capitalizingFirstLetter())
                _ = try user.addedByGoogle(token: accessToken, fcmToken: auth.fcmToken, reference: auth.reference, operationSystem: auth.operationSystem, response: auth).save(on: request)
                return Future.map(on: request) { () -> Generic<JWToken> in
                    return Generic<JWToken>.init(error: false, reason: "Success", data: jwtAccess)
                }
            } else {
                // --- new user ---
                // config new user
                let user = User(username: auth.username.capitalizingFirstLetter())
                return user.save(on: request).flatMap(to: Generic<JWToken>.self, { (addedUser) in
                    let accessToken = try TokenController.createAccessToken(from: user)
                    let jwtAccess = JWToken(token: accessToken, userID: addedUser.id!, mobile: nil, username: auth.username.capitalizingFirstLetter())
                    _ = jwtAccess.save(on: request)
                    _ = try addedUser.addedByGoogle(token: accessToken, fcmToken: auth.fcmToken, reference: auth.reference, operationSystem: auth.operationSystem, response: auth).save(on: request)
                    return Future.map(on: request) { () -> Generic<JWToken> in
                        return Generic<JWToken>.init(error: false, reason: "Success", data: jwtAccess)
                    }
                })
            }
        })
    }
    
    public func GPhoneSendOTP(_ request: Request) throws -> Future<Generic<Empty>> {
        return try request.authorizedUser().flatMap { (user) in
            return try request.content.decode(Authentication.GPhone.self).flatMap(to: Generic<Empty>.self) { (auth) in
                let sendOTP = try self.sendOTPCode(mobile: auth.mobile, type: .submit, request: request)
                let auth = Authentication(mobile: auth.mobile, code: sendOTP.code, userID: user.id!)
                _ = auth.save(on: request)
                return Future.map(on: request) { () -> Generic<Empty> in
                    return Generic<Empty>.init(error: false, reason: "Verification code send to \(auth.mobile)", data: nil)
                }
            }
        }
    }
    
    public func GPhoneVerification(_ request: Request) throws -> Future<Generic<Empty>> {
        return try request.authorizedUser().flatMap { (user) in
            return try request.content.decode(Authentication.GPhone.self).flatMap(to: Generic<Empty>.self, { (auth) in
                return Authentication.query(on: request).filter(\.mobile == auth.mobile).sort(\.createdAt,._descending).first().flatMap(to: Generic<Empty>.self) { (dbAuth) in
                    if let code = auth.code {
                        if dbAuth?.code == code {
                            // ---- Correct code here ---
                            return User.query(on: request).filter(\.mobile == auth.mobile).first().flatMap(to: Generic<Empty>.self) { (phoneUser) in
                                if let _ = phoneUser {
                                    // this phone is existed in database
                                    throw Abort(HTTPResponseStatus.alreadyReported, reason: "The phone number is existed in database and you can not use this for your self.")
                                } else {
                                    // this phone is unique
                                    user.mobile = auth.mobile
                                    _ = user.save(on: request)
                                    return Future.map(on: request) { () -> Generic<Empty> in
                                        return Generic<Empty>(error: false, reason: "Success save phone in user", data: nil)
                                    }
                                }
                            }
                        } else {
                            throw Abort(HTTPResponseStatus.failedDependency, reason: "Code is not valid.")
                        }
                    } else {
                        throw Abort(HTTPResponseStatus.failedDependency, reason: "Inser a code.")
                    }
                }
            })
        }
    }
}
