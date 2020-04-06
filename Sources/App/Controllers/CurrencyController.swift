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
import Jobs

struct CurrencyController: RouteCollection {
    
    private let basePath: PathComponentsRepresentable = [Constant.Path.base,"currency"]
        
    func boot(router: Router) throws {
        let routes = router.grouped(basePath)
        routes.post("add",TrackingSession.parameter, use: sessionManager.createTrackingSession)
        routes.post("close",TrackingSession.parameter, use: closeWSHandler)
        routes.post("update",TrackingSession.parameter, use: updateWSHandler)
        routes.get("fetch", use: fetchHTML)
    }
    
    func fetchHTML(_ request: Request) throws ->  Future<Generic<Empty>> {
        TGJU.default.fetchTGJU(request)
        return Future.map(on: request) { () -> Generic<Empty> in
            return Generic<Empty>(error: false, reason: "fetch started.", data: nil)
        }
    }
    
    func closeWSHandler(_ request: Request) throws -> HTTPStatus {
        let session = try request.parameters.next(TrackingSession.self)
          sessionManager.close(session)
          return .ok
    }
    
    func updateWSHandler(_ request: Request) throws -> Future<Generic<[CurrencyBuilder]>> {
        func callBack(session: TrackingSession) throws -> Future<Generic<[CurrencyBuilder]>> {
            TGJU.default.session = session
            return CurrencyBuilder.query(on: request)
                .sort(\.createdAt,._descending)
                .all()
                .flatMap(to: Generic<[CurrencyBuilder]>.self) { (currencyBuilders) in
                    if !TGJU.default.wcEnable {
                        Jobs.add(interval: Duration.seconds(3)) {
                            _ = try self.updateWSHandler(request)
                        }
                        TGJU.default.wcEnable = true
                    }
                    sessionManager.update(Generic<[CurrencyBuilder]>(error: false, data: currencyBuilders), for: session)
                    return Future.map(on: request) { () -> Generic<[CurrencyBuilder]> in
                        return Generic<[CurrencyBuilder]>(error: false, data: currencyBuilders)
                    }
            }
        }
        if let session = try? request.parameters.next(TrackingSession.self) {
            return try callBack(session: session)
        } else {
            return try callBack(session: TGJU.default.session)
        }
    }
}
//curl -w "%{response_code}\n"   -d '{"price": 37}'   -H "Content-Type: application/json" -X POST http://localhost:8080/api/currency/update/test
