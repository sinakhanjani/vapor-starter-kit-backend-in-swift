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
        routes.get("fetch",String.parameter, use: fetchHTML)
    }
    
    func fetchHTML(_ request: Request) throws ->  Future<Generic<Empty>> {
        guard let type = try? request.parameters.next(String.self) else {
            throw Abort(HTTPResponseStatus.badRequest,reason: "insert reference type: en,fa")
        }
        TGJU.default.fetchTGJU(request: request, reference: ReferenceType(rawValue: type) ?? .en)
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
        let session = try request.parameters.next(TrackingSession.self)
        return CurrencyBuilder.query(on: request)
            .sort(\.createdAt,._descending)
            .range(lower: 0, upper: 4)
            .all()
            .flatMap(to: Generic<[CurrencyBuilder]>.self) { (currencyBuilders) in
                if !TGJU.default.wcEnable {
                    Jobs.add(interval: Duration.seconds(4)) {
                        sessionManager.update(Generic<[CurrencyBuilder]>(error: false, data: currencyBuilders), for: session)
                    }
                    TGJU.default.wcEnable = true
                }
                return Future.map(on: request) { () -> Generic<[CurrencyBuilder]> in
                    return Generic<[CurrencyBuilder]>(error: false, data: currencyBuilders)
                }
        }
    }
}


//curl -w "%{response_code}\n"   -d '{"price": 37}'   -H "Content-Type: application/json" -X POST http://localhost:8080/api/currency/update/test
