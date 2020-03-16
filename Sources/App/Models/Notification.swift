//
//  Notification.swift
//  App
//
//  Created by Sina khanjani on 12/23/1398 AP.
//

import Foundation
import Vapor

struct NotificationSend: Codable {
    
    var coverFile: File?
    var title: String?
    var description: String?
    var webURL: String?
    var mobile: String?
    var telephone: String?
    var badge: String?
    var category: String?
    var type: String
    var storyboardID: String?
    var message: String?
    var duration: Int?
    var sound: String?
    var nerkh: String?
    var chart: String?
    
    struct Token: Content {
        var mobile: String
        var fcmToken: String
        var userID: User.ID
        var name: String
    }
}

