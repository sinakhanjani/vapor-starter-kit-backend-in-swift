//
//  NotificationAPI.swift
//  App
//
//  Created by Sina khanjani on 12/23/1398 AP.
//

import Foundation
import Vapor
import Alamofire

class FCMPush {
    static let `default` = FCMPush()
    
    typealias completion = (_ status: Bool) -> Void
    private let serverKey = "AAAA-HdHMtM:APA91bFr9H2zmRArCn663j-wJp2QW-B9IMGUALI-Ag7IqXIXfNNoeVXY2k2WZ1g6PaSVAeTmhQ-9Vb-jsJpf3Xz7Tv1Rti3fACbRxGiMIiF_1bSM8_1WqT36ElFZAUts5VwiTdyWpVj6"
    
    func sendNotificationTo(to: String, title: String?, body: String?, badge: Int?, notifiCategory: String?, apn: APN, sound: String?, request: Request) {
        let notification = Notification(title: title ?? "", body: body ?? "", sound: sound ?? "", badge: badge ?? 0, clickAction: notifiCategory)
        let sendNotification = SendFCM(contentAvailable: true, mutableContent: true, priority: "high", data: apn, to: to, notification: notification)
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(sendNotification) else { return }
        var headers: HTTPHeaders = .init()
        headers.add(name: "Content-Type", value: "application/json")
        headers.add(name: "Authorization", value: "key="+serverKey)
        let body = HTTPBody(data: jsonData)
        let httpRequest = HTTPRequest(method: .POST, url: "/fcm/send", headers: headers, body: body)
        let client = HTTPClient.connect(hostname: "fcm.googleapis.com", on: request)
        let _ = client.flatMap(to: HTTPResponse.self) { client in
            return client.send(httpRequest)
        }
    }
    
    func createAndAddTopic(topic: String, user: User, request: Request) {
        guard let token = user.fcmToken else { return }
        let topic = Topic(to: "/topics/"+topic, registrationTokens: [token])
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(topic) else { return }
        var headers: HTTPHeaders = .init()
        headers.add(name: "Content-Type", value: "application/json")
        headers.add(name: "Authorization", value: "key="+serverKey)
        let body = HTTPBody(data: jsonData)
        let httpRequest = HTTPRequest(method: .POST, url: "/iid/v1:batchAdd", headers: headers, body: body)
        let client = HTTPClient.connect(hostname: "iid.googleapis.com", on: request)
        let _ = client.flatMap(to: HTTPResponse.self) { client in
            return client.send(httpRequest)
        }
    }
    
    func removeTopic(topic: String, user: User, request: Request) {
        guard let token = user.fcmToken else { return }
        let topic = Topic(to: "/topics/"+topic, registrationTokens: [token])
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(topic) else { return }
        var headers: HTTPHeaders = .init()
        headers.add(name: "Content-Type", value: "application/json")
        headers.add(name: "Authorization", value: "key="+serverKey)
        let body = HTTPBody(data: jsonData)
        let httpRequest = HTTPRequest(method: .POST, url: "/iid/v1:batchRemove", headers: headers, body: body)
        let client = HTTPClient.connect(hostname: "iid.googleapis.com", on: request)
        let _ = client.flatMap(to: HTTPResponse.self) { client in
            return client.send(httpRequest)
        }
    }
}

