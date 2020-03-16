//
//  JWTConfig.swift
//  App
//
//  Created by Timur Shafigullin on 22/01/2019.
//

import JWT

enum JWTConfig {
    static let signerKey = "khanjani.nerkh" // Key for signing JWT Access Token
    static let header = JWTHeader(alg: "HS256", typ: "JWT") // Algorithm and Type
    static let signer = JWTSigner.hs256(key: JWTConfig.signerKey) // Signer for JWT
    static let expirationTime: TimeInterval = 2_400*60_000_000*4_000_9999*16_000_000_000 // In seconds
}
