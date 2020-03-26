//
//  CurrencyController.swift
//  App
//
//  Created by Sina khanjani on 1/7/1399 AP.
//

import Vapor
import Crypto
import Fluent
import Authentication

struct CurrencyController: RouteCollection {
    
    private let basePath: PathComponentsRepresentable = [Constant.Path.base,"currency"]

    func boot(router: Router) throws {
        let routes = router.grouped(basePath)
        routes.post("add", use: sessionManager.createTrackingSession)
        routes.post("close",TrackingSession.parameter, use: closeWSHandler)
        routes.post("update",TrackingSession.parameter, use: updateWSHandler)
    }
    
    func closeWSHandler(_ request: Request) throws -> HTTPStatus {
        let session = try request.parameters.next(TrackingSession.self)
          sessionManager.close(session)
          return .ok
    }
    
    func updateWSHandler(_ request: Request) throws -> Future<HTTPStatus> {
        let session = try request.parameters.next(TrackingSession.self)
           return try Currency.decode(from: request)
                              .map(to: HTTPStatus.self) { currency in
                                sessionManager.update(currency, for: session)
                                return .ok
        }
    }
}


//curl -w "%{response_code}\n"   -d '{"price": 37}'   -H "Content-Type: application/json" -X POST http://localhost:8080/api/currency/update/test
