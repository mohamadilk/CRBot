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
    
    func priceStepsFor(symbol: String, completion: @escaping (_ stepSize: Double?, _ error: ApiError?) -> Swift.Void) {
        ExchangeHandler.shared.getSymbol(symbol: symbol, completion: { (symbolObject, error) in
            
            if error != nil {
                completion(nil,error)
                return
            }
            
            guard let symbolObject = symbolObject else {
                completion(nil,nil)
                return
            }
            
            let priceFilter = symbolObject.filters?.filter({ $0.filterType == .PRICE_FILTER }).first
            completion(priceFilter?.tickSize?.doubleValue, nil)

        })
    }
    
    func quantutyStepsFor(symbol: String, completion: @escaping (_ stepSize: Double?, _ error: ApiError?) -> Swift.Void) {
        ExchangeHandler.shared.getSymbol(symbol: symbol, completion: { (symbolObject, error) in
            
            if error != nil {
                completion(nil,error)
                return
            }
            
            guard let symbolObject = symbolObject else {
                completion(nil,nil)
                return
            }
            
            let priceFilter = symbolObject.filters?.filter({ $0.filterType == .LOT_SIZE }).first
            completion(priceFilter?.stepSize?.doubleValue, nil)

        })
    }
}
