//
//  NotificationAPI.swift
//  App
//
//  Created by Sina khanjani on 12/23/1398 AP.
//

import Foundation
import Vapor
import Just

class FCMPush {
    typealias completion = (_ status: Bool) -> Void

    static let `default` = FCMPush()
    
    private let serverKey = "AAAA-HdHMtM:APA91bFr9H2zmRArCn663j-wJp2QW-B9IMGUALI-Ag7IqXIXfNNoeVXY2k2WZ1g6PaSVAeTmhQ-9Vb-jsJpf3Xz7Tv1Rti3fACbRxGiMIiF_1bSM8_1WqT36ElFZAUts5VwiTdyWpVj6"
    
    func sendNotificationTo(to: String, title: String?, body: String?, badge: Int?, notifiCategory: String?, apn: APN, sound: String?, request: Request) {
        let notification = Notification(title: title ?? "", body: body ?? "", sound: sound ?? "", badge: badge ?? 0, clickAction: notifiCategory)
        let sendNotification = SendFCM(contentAvailable: true, mutableContent: true, priority: "high", data: apn, to: to, notification: notification)
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(sendNotification) else { return }
        var header: HTTPHeaders = .init()
        header.add(name: "Content-Type", value: "application/json")
        header.add(name: "Authorization", value: "key="+serverKey)
        let body = HTTPBody(data: jsonData)
        _ = try? request.client().post(URL(string: "https://fcm.googleapis.com/fcm/send")!, headers: header, beforeSend: { (request) in
            request.http.body = body
        }).map({ (response) in
            print(String(data: response.http.body.data!, encoding: .utf8)!)
        })
    }
    
    func createAndAddTopic(topic: String, user: User, request: Request) {
        guard let token = user.fcmToken else { return }
        let topic = Topic(to: "/topics/"+topic, registrationTokens: [token])
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(topic) else { return }
        var header: HTTPHeaders = .init()
        header.add(name: "Content-Type", value: "application/json")
        header.add(name: "Authorization", value: "key="+serverKey)
        let body = HTTPBody(data: jsonData)
        _ = try? request.client().post(URL(string: "https://iid.googleapis.com/iid/v1:batchAdd")!, headers: header, beforeSend: { (request) in
            request.http.body = body
        }).map({ (response) in
            print(String(data: response.http.body.data!, encoding: .utf8)!)
        })
    }
    
    func removeTopic(topic: String, user: User, request: Request) {
        guard let token = user.fcmToken else { return }
        let topic = Topic(to: "/topics/"+topic, registrationTokens: [token])
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(topic) else { return }
        var header: HTTPHeaders = .init()
        header.add(name: "Content-Type", value: "application/json")
        header.add(name: "Authorization", value: "key="+serverKey)
        let body = HTTPBody(data: jsonData)
        _ = try? request.client().post(URL(string: "https://iid.googleapis.com/iid/v1:batchRemove")!, headers: header, beforeSend: { (request) in
            request.http.body = body
        }).map({ (response) in
            print(String(data: response.http.body.data!, encoding: .utf8)!)
        })
    }
}

