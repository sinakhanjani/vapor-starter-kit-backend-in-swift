//
//  NotificationAPI.swift
//  App
//
//  Created by Sina khanjani on 12/23/1398 AP.
//

import Foundation

class FCMPush {
    static let `default` = FCMPush()
    
    typealias completion = (_ status: Bool) -> Void
    private let serverKey = "AAAA-HdHMtM:APA91bFr9H2zmRArCn663j-wJp2QW-B9IMGUALI-Ag7IqXIXfNNoeVXY2k2WZ1g6PaSVAeTmhQ-9Vb-jsJpf3Xz7Tv1Rti3fACbRxGiMIiF_1bSM8_1WqT36ElFZAUts5VwiTdyWpVj6"
    
    func sendNotificationTo(to: String, title: String?, body: String?, badge: Int?, notifiCategory: String?, apn: APN, sound: String?) {
        guard let url = URL.init(string: "https://fcm.googleapis.com/fcm/send") else { return }
        let notification = Notification(title: title ?? "", body: body ?? "", sound: sound ?? "", badge: badge ?? 0, clickAction: notifiCategory)
        let sendNotification = SendFCM(contentAvailable: true, mutableContent: true, priority: "high", data: apn, to: to, notification: notification)
        var request = URLRequest.init(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key="+serverKey, forHTTPHeaderField: "Authorization")
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(sendNotification)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error as Any)
                return
            }
        }
        task.resume()
    }
    
    func createAndAddTopic(topic: String, user: User) {
        guard let token = user.fcmToken else { return }
        guard let url = URL.init(string: "https://iid.googleapis.com/iid/v1:batchAdd") else { return }
        let topic = Topic(to: "/topics/"+topic, registrationTokens: [token])
        var request = URLRequest.init(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key="+serverKey, forHTTPHeaderField: "Authorization")
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(topic)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error as Any)
                return
            }
        }
        task.resume()
    }
    
    func removeTopic(topic: String, user: User) {
        guard let token = user.fcmToken else { return }
        guard let url = URL.init(string: "https://iid.googleapis.com/iid/v1:batchRemove") else { return }
        let topic = Topic(to: "/topics/"+topic, registrationTokens: [token])
        var request = URLRequest.init(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key="+serverKey, forHTTPHeaderField: "Authorization")
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(topic)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error as Any)
                return
            }
        }
        task.resume()
    }
}

