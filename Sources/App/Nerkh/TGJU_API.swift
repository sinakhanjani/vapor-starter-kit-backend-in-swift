//
//  FetchNerkhAPI.swift
//  App
//
//  Created by Sina khanjani on 1/7/1399 AP.
//

import Foundation
import SwiftSoup
import Vapor
import SwiftSoup

class TGJU {
    
    public static let `default` = TGJU()
    
    public func fetchTGJU(_ path: String = "/", request: Request) {
        parseHTML(request: request, key: "price_dollar_rl")
    }
    
    private func parseHTML(request: Request, key: String) {
        do {

            _ = try? request.client().get("https://www.tgju.org").map { (res) in
                guard let httpData = res.http.body.data else { return }
                guard let str = String(data: httpData, encoding: .utf8) else { return }
                let document: Document = try SwiftSoup.parse(str)
                //.attr("data-market-row", "price_eur").toggleClass("pointer ").attr("data-price")
                let trs = try document.select("tr").array()
                try trs.forEach { (tr) in
                    let pointer = try tr.getElementsByAttributeValueContaining("data-market-row", key).first()
                    if let pointer = try pointer?.getElementsByClass("pointer") {
                        let tds = try pointer.select("td").array()
                        for td in tds {
                            print(try td.text())
                        }
                    }
                }
            }
        }
    }
}
