//
//  Currency.swift
//  App
//
//  Created by Sina khanjani on 1/7/1399 AP.
//

import Vapor

struct Currency: Content, Codable {
    var key: String
    var currentPrice: Double
    var maxPrice: Double
    var minPrice: Double
    var extend: Extend
    var date: String
    var iconURL: String
    var reference: Reference
    
    static let dict: [String:[String]] = {
        let data = ["currency":["price_dollar_rl",
                                "price_eur",
                                "price_gbp",
                                "price_aed",
                                "price_try",
                                "price_chf",
                                "price_cny",
                                "price_jpy",
                                "price_cad",
                                "price_aud",
                                "price_nzd",
                                "price_sgd",
                                "price_inr",
                                "price_pkr",
                                "price_iqd",
                                "price_nok",
                                "price_sek",
                                "price_dkk",
                                "price_sar",
                                "price_qar",
                                "price_omr",
                                "price_kwd",
                                "price_bhd",
                                "price_myr",
                                "price_thb",
                                "price_hkd",
                                "price_rub",
                                "price_azn",
                                "price_gel",
                                "price_afn",
                                "price_syp"]]
        return data
    }()
}

struct Extend: Content, Codable {
    var percent: Double
    var meter: String
}

struct Reference: Content, Codable {
    var fa: String
    var en: String
    
    mutating func changeEn(en: String) {
        self.en = en
    }
}
