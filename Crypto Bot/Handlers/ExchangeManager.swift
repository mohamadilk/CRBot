//
//  ExchangeManager.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/11/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation

class ExchangeManager {
    
    static let shared = ExchangeManager()
    
    private var exchangeInfo: ExchangeInformationresponse?
    
    func getAllAvailableSymbols(result:@escaping (_ info: [SymbolObject]?, _ error: ApiError?) -> Swift.Void) {
        
        guard exchangeInfo == nil else {
            result(exchangeInfo!.symbols, nil)
            return
        }
        
        GeneralServices.shared.exchangeInformation { (response, error) in
            guard response != nil else {
                result(nil, nil)
                return
            }
            self.exchangeInfo = response
            result(self.exchangeInfo?.symbols, nil)
        }
    }
    
    func getSymbol(symbol: String, result:@escaping (_ info: SymbolObject?, _ error: ApiError?) -> Swift.Void) {
        
        guard exchangeInfo == nil else {
            if let symbols = exchangeInfo!.symbols?.filter({ $0.symbol == symbol }) {
                result(symbols.first, nil)
            } else {
                result(nil, nil)
            }
            return
        }
        
        GeneralServices.shared.exchangeInformation { (response, error) in
            guard response != nil else {
                result(nil, nil)
                return
            }
            self.exchangeInfo = response
            if let symbols = self.exchangeInfo!.symbols?.filter({ $0.symbol == symbol }) {
                result(symbols.first, nil)
            } else {
                result(nil, nil)
            }
        }
    }
    
    func getAllAvailableFilters(result:@escaping (_ info: [FilterObject]?, _ error: ApiError?) -> Swift.Void) {
        
        guard exchangeInfo == nil else {
            result(exchangeInfo!.exchangeFilters, nil)
            return
        }
        
        GeneralServices.shared.exchangeInformation { (response, error) in
            guard response != nil else {
                result(nil, nil)
                return
            }
            self.exchangeInfo = response
            result(self.exchangeInfo?.exchangeFilters, nil)
        }
        
    }
}
