//
//  MarketDataHandler.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/31/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation

class MarketDataHandler {
    
    static let shared = MarketDataHandler()
    let dataService = MarketDataServices.shared
    
    func getLatestOrder(symbol: SymbolObject, completion: @escaping(_ order: SymbolOrderBookObject?, _ error: ApiError?) -> Swift.Void) {
        if let symbol = symbol.symbol {
            dataService.fetchSymbolOrderBookTicker(symbol: symbol) { (order, error) in

                if error != nil {
                    completion(nil, error)
                    return
                }
                
                completion(order, nil)
            }
        }
    }
}
