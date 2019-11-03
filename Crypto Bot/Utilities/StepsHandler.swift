//
//  StepsHandler.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/10/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation

class StepsUtility {
    
    public static let shared = StepsUtility()
    
    func priceStepsFor(symbol: String, result:@escaping (_ stepSize: Double?, _ error: ApiError?) -> Swift.Void) {
        ExchangeHandler.shared.getSymbol(symbol: symbol, result: { (symbolObject, error) in
            
            if error != nil {
                result(nil,error)
                return
            }
            
            guard let symbolObject = symbolObject else {
                result(nil,nil)
                return
            }
            
            let priceFilter = symbolObject.filters?.filter({ $0.filterType == .PRICE_FILTER }).first
            result(priceFilter?.tickSize?.doubleValue, nil)

        })
    }
    
    func quantutyStepsFor(symbol: String, result:@escaping (_ stepSize: Double?, _ error: ApiError?) -> Swift.Void) {
        ExchangeHandler.shared.getSymbol(symbol: symbol, result: { (symbolObject, error) in
            
            if error != nil {
                result(nil,error)
                return
            }
            
            guard let symbolObject = symbolObject else {
                result(nil,nil)
                return
            }
            
            let priceFilter = symbolObject.filters?.filter({ $0.filterType == .LOT_SIZE }).first
            result(priceFilter?.stepSize?.doubleValue, nil)

        })
    }
}
