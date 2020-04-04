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
    
    
    func enNames(key: String) -> String {
        let en = ["USD", "EUR", "GBP", "AED", "TRY", "CHF", "CNY", "JPY", "CAD", "AUD", "NZD", "SGD", "INR", "PKR", "IQD", "NOK", "SEK", "DKK", "SAR", "QAR", "OMR", "KWD", "BHD", "MYR", "THB", "HKD", "RUB", "AZN", "GEL", "AFN", "SYP"]
        let keys = ["price_dollar_rl", "price_eur", "price_gbp", "price_aed", "price_try", "price_chf", "price_cny", "price_jpy", "price_cad", "price_aud", "price_nzd", "price_sgd", "price_inr", "price_pkr", "price_iqd", "price_nok", "price_sek", "price_dkk", "price_sar", "price_qar", "price_omr", "price_kwd", "price_bhd", "price_myr", "price_thb", "price_hkd", "price_rub", "price_azn", "price_gel", "price_afn", "price_syp"]
        if en.count == keys.count {
            for (index,k) in keys.enumerated() {
                if key == k {
                    return en[index]
                }
            }
        }
        return "no name"
    }
}
