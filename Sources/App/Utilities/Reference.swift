//
//  Reference.swift
//  App
//
//  Created by Sina khanjani on 1/15/1399 AP.
//

import Foundation

enum ReferenceType:String {
    case en,fa
    
    func tgjuURL() -> String {
        switch self {
        case .en:
            return "https://english.tgju.net"
        case .fa:
            return "https://www.tgju.org"
        }
    }
}
