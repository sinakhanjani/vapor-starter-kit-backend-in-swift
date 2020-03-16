//
//  FCM_MODEL.swift
//  App
//
//  Created by Sina khanjani on 12/23/1398 AP.
//

import Foundation

// MARK: - SentNotification
struct SendFCM: Codable {
    let contentAvailable, mutableContent: Bool
    let priority: String
    let data: APN
    let to: String
    let notification: Notification

    enum CodingKeys: String, CodingKey {
        case contentAvailable = "content_available"
        case mutableContent = "mutable_content"
        case priority, data, to, notification
    }
}

// MARK: - DataClass
struct APN: Codable {
    let imageURL: String?
    let app, syntax: String
    let type: String
    let source: Source?
}

// MARK: - Source
struct Source: Codable {
    let storyboardID: String?
    let message: String?
    let duration: Int?
    let webURL: String?
    let mobile: String?
    let telephone: String?
    var chart: String?
    var nerkh: String?
}

// MARK: - Notification
struct Notification: Codable {
    let title, body, sound: String
    let badge: Int
    let clickAction: String?

    enum CodingKeys: String, CodingKey {
        case title, body, sound, badge
        case clickAction = "click_action"
    }
}


// MARK: - SentNotification
struct Topic: Codable {
    let to: String
    let registrationTokens: [String]

    enum CodingKeys: String, CodingKey {
        case to
        case registrationTokens = "registration_tokens"
    }
}
