//
//  FetchNerkhAPI.swift
//  App
//
//  Created by Sina khanjani on 1/7/1399 AP.
//

import Foundation
import SwiftSoup
import Vapor
import Fluent
import SwiftSoup
import Jobs
import Just

class TGJU {
    public static let `default` = TGJU()
    
    private var timeEstimated:Double = 0
    private var duration:Double = 4
    private var deleteDBDuration: Double = 100
    public var wcEnable = false
    private var refType: ReferenceType = .en
    private var fetchEnable = false
    
    public func fetchTGJU(request: Request, dict: [String: [String]] = Currency.dict, reference: ReferenceType) {
        if !self.fetchEnable {
            Jobs.add(interval: .seconds(duration)) {
                self.timeEstimated += self.duration
                if self.timeEstimated == self.deleteDBDuration {
                    self.timeEstimated = 0
                }
                self.updateCurrencyBuilder(request: request,dict: dict)
            }
            self.fetchEnable = true
        }
    }
    
    private func addTag(_ request: Request, builder: CurrencyBuilder) {
        _ = builder.parameters.map { (currency) in
            let tag = Tag(title: currency.key, description: currency.key, type: builder.group, iconURL: "Images/Tags/default.jpg", subType: currency.key)
            _ = tag.save(on: request)
        }
    }
    
    private func updateCurrencyBuilder(request: Request, dict: [String:[String]]) {
        try? self.parseHTML(request: request,dict: dict, completion: { currencyBuilders in
            if let currencyBuilders = currencyBuilders {
                _ = currencyBuilders.map { (currencyBuilder) in
                    CurrencyBuilder.query(on: request)
                        .group(.or, closure: { (or) in
                            or.filter(\.group == currencyBuilder.group)
                        })
                        .first().map { (builder) -> CurrencyBuilder? in
                        if let builder = builder {
                            builder.parameters = currencyBuilder.parameters
                            _ = builder.save(on: request)
                        } else {
                            self.addTag(request, builder: currencyBuilder)
                            _ = currencyBuilder.save(on: request)
                        }
                        return builder
                    }
                }
            }
        })
    }
    
    private func parseHTML(request: Request,dict: [String:[String]], completion: @escaping (_ results: [CurrencyBuilder]?) -> Void) throws {
        do {
            let tgjuURL = self.refType.tgjuURL()
            guard let httpData = Just.get(tgjuURL).content else {
                return
            }
            guard let str = String(data: httpData, encoding: .utf8) else { return }
            let document: Document = try SwiftSoup.parse(str)
            let trs = try document.select("tr").array()
            var data = [CurrencyBuilder]()
            var currencies = [Currency]()
            var meter:String = "none"
            var name:String = ""
            _ = try dict.map { (dic) in
                _ = try trs.map { (tr) in
                    let keys = dic.value
                    _ = try keys.map { (key) in
                        let pointer = try tr.getElementsByAttributeValueContaining("data-market-row", key).first()
                        if let pointer = try pointer?.getElementsByClass("pointer") {
                            let tds = try pointer.select("td").array()
                            let th = try pointer.select("th").first()
                            if let th = try th?.text() {
                                name = th
                            }
                            var tds_str = [String]()
                            for (index,td) in tds.enumerated() {
                                let text = try td.text()
                                if index == 1 {
                                    let atrr = try td.select("span").attr("class")
                                    meter = atrr
                                }
                                tds_str.append(text)
                            }
                            if tds_str.count >= 4 {
                                let currentPrice = Double(tds_str[0].replacingOccurrences(of: ",", with: "", options: NSString.CompareOptions.literal, range: nil))!
                                let maxPrice = Double(tds_str[3].replacingOccurrences(of: ",", with: "", options: NSString.CompareOptions.literal, range: nil))!
                                let minPrice = Double(tds_str[2].replacingOccurrences(of: ",", with: "", options: NSString.CompareOptions.literal, range: nil))!
                                let character = tds_str[1].last ?? "0"
                                let percent = Double(String(character))!
                                let _ = tds_str[4]
                                let formatter = DateFormatter()
                                formatter.dateStyle = .medium
                                if currencies.contains(where: { (cr) -> Bool in
                                    cr.key == key
                                }) {
                                    return
                                }
                                let currency = Currency(key: key,currentPrice: currentPrice, maxPrice: maxPrice, minPrice: minPrice, extend: Extend(percent: percent, meter: meter), date: formatter.string(from: Date()),reference: Reference(fa: name, en: ""))
                                currencies.append(currency)
                            }
                        }
                    }
                }
                let currencyBuilder = CurrencyBuilder(parameters: currencies, group: dic.key)
                data.append(currencyBuilder)
                currencies.removeAll()
            }
            completion(data)
            data.removeAll()
        }
    }
}
