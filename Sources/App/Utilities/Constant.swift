//
//  Constant.swift
//  App
//
//  Created by Sina khanjani on 11/26/1398 AP.
//

import Foundation

struct Constant {
    // --- Paths ---
    struct Path {
        // <BASE_URL:PORT>/api/
        static public let base = "api"
    }
    // --- Document ---
    struct Directory {
        // Root
        static let base = "Public"
        // Path
        struct Path {
            // images
            static let images = "Images"
            // root of public
            static let root = ""
        }
    }
    // --- Messages ---
    struct Message {
        struct Generic {
            static let success = "Success"
        }
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}
