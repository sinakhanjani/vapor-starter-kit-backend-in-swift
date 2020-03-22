//
//  Authentication.swift
//  App
//
//  Created by Sina khanjani on 12/18/1398 AP.
//

import Foundation
import CoreFoundation
import Dispatch
import Vapor

class OTP_API {
    
    static let `default` = OTP_API()
    
    enum CodeType {
        case register,login,submit
    }

    typealias completion = (_ status: Bool) -> Void
    
    private let baseURL = URL.init(string: "https://RestfulSms.com/api/")!
    public var otpToken: String?

    public func getToken(request: Request , completion: @escaping (_ token: String?) -> Void) {
        // MARK: - GetToken
        struct GetToken: Codable {
            let tokenKey: String
            let isSuccessful: Bool
            let message: String

            enum CodingKeys: String, CodingKey {
                case tokenKey = "TokenKey"
                case isSuccessful = "IsSuccessful"
                case message = "Message"
            }
        }
//        let url = baseURL.appendingPathComponent("Token")
//        var request = URLRequest.init(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(["UserApiKey":"c3660c7c6df3c559a9800c7c","SecretKey":"app"]) else { return }
//        request.httpBody = jsonData
//        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//            if let error = error {
//                print(error as Any)
//                completion(nil)
//                return
//            }
//            if let data = data {
//                guard let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]) as [String : Any]??) else { completion(nil) ; return }
//                if let token = json?["TokenKey"] as? String {
//                    completion(token)
//                } else {
//                    completion(nil)
//                }
//            } else {
//                completion(nil)
//            }
//        }
//        task.resume()
        var headers: HTTPHeaders = .init()
        headers.add(name: "Content-Type", value: "application/json")
        let body = HTTPBody(data: jsonData)
        let httpRequest = HTTPRequest(method: .POST, url: "/api/Token", headers: headers, body: body)
        let client = HTTPClient.connect(hostname: "RestfulSms.com", on: request)
        let _ = client.flatMap(to: HTTPResponse.self) { client in
            return client.send(httpRequest).map { (httpResponse) in
                let response = Response(http: httpResponse, using: request)
                _ = try response.content.decode(GetToken.self).map({ (getToken) in
                    completion(getToken.tokenKey)
                })
                return httpResponse
            }
        }
    }
    
    public func sendCode(mobile: String, code: String, type: CodeType, token: String, request: Request, completion: @escaping () -> Void) {
//        let url = baseURL.appendingPathComponent("UltraFastSend")
//        var request = URLRequest.init(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue(token, forHTTPHeaderField: "x-sms-ir-secure-token")
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(smsGenerator(type: type, mobile: mobile, code: code)) else { return }
//        request.httpBody = jsonData
//        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//            if let error = error {
//                print(error as Any)
//                return
//            }
//            if data != nil {
//                completion()
//            }
//        }
//        task.resume()
        var headers: HTTPHeaders = .init()
        headers.add(name: "Content-Type", value: "application/json")
        headers.add(name: "x-sms-ir-secure-token", value: token)
        let body = HTTPBody(data: jsonData)
        let httpRequest = HTTPRequest(method: .POST, url: "/api/UltraFastSend", headers: headers, body: body)
        let client = HTTPClient.connect(hostname: "RestfulSms.com", on: request)
        let _ = client.flatMap(to: HTTPResponse.self) { client in
            return client.send(httpRequest)
        }
    }
    
    private func smsGenerator(type: CodeType, mobile: String, code: String) -> UltraFastSend {
        switch type {
        case .login:
            return UltraFastSend(parameterArray: [ParameterArray(parameter: "VerificationCode", parameterValue: code)], mobile: mobile, templateID: "22269")
        case .register:
            return UltraFastSend(parameterArray: [ParameterArray(parameter: "VerificationCode", parameterValue: code)], mobile: mobile, templateID: "22267")
        case .submit:
            return UltraFastSend(parameterArray: [ParameterArray(parameter: "VerificationCode", parameterValue: code)], mobile: mobile, templateID: "22627")
        }
    }
}

extension OTP_API {
    // MARK: - UltraFastSend
    struct UltraFastSend: Codable {
        let parameterArray: [ParameterArray]
        let mobile, templateID: String

        enum CodingKeys: String, CodingKey {
            case parameterArray = "ParameterArray"
            case mobile = "Mobile"
            case templateID = "TemplateId"
        }
    }

    // MARK: - ParameterArray
    struct ParameterArray: Codable {
        let parameter, parameterValue: String

        enum CodingKeys: String, CodingKey {
            case parameter = "Parameter"
            case parameterValue = "ParameterValue"
        }
    }
}
