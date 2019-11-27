//
//  ExchangeManager.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/11/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation

class ExchangeHandler {
    
    static let shared = ExchangeHandler()
    
    private var exchangeInfo: ExchangeInformationResponse?
    
    func getAllAvailableSymbols(completion: @escaping (_ info: [SymbolObject]?, _ error: ApiError?) -> Swift.Void) {
        
        guard exchangeInfo == nil else {
            completion(exchangeInfo!.symbols, nil)
            return
        }
        
        GeneralServices.shared.exchangeInformation { (response, error) in
            guard response != nil else {
                completion(nil, nil)
                return
            }
            self.exchangeInfo = response
            completion(self.exchangeInfo?.symbols, nil)
        }
    }
    
    func getSyncSymbol(symbol: String) -> SymbolObject? {
        guard exchangeInfo != nil else {
            return nil
        }
        if let symbols = exchangeInfo!.symbols?.filter({ $0.symbol == symbol }) {
            return symbols[0]
        }
        return nil
    }
    
    func getSymbol(symbol: String, completion: @escaping (_ info: SymbolObject?, _ error: ApiError?) -> Swift.Void) {
        
        guard exchangeInfo == nil else {
            if let symbols = exchangeInfo!.symbols?.filter({ $0.symbol == symbol }) {
                completion(symbols.first, nil)
            } else {
                completion(nil, nil)
            }
            return
        }
        
        GeneralServices.shared.exchangeInformation { (response, error) in
            guard response != nil else {
                completion(nil, nil)
                return
            }
            self.exchangeInfo = response
            if let symbols = self.exchangeInfo!.symbols?.filter({ $0.symbol == symbol }) {
                completion(symbols.first, nil)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    func getAllAvailableFilters(completion: @escaping (_ info: [FilterObject]?, _ error: ApiError?) -> Swift.Void) {
        
        guard exchangeInfo == nil else {
            completion(exchangeInfo!.exchangeFilters, nil)
            return
        }
        
        GeneralServices.shared.exchangeInformation { (response, error) in
            guard response != nil else {
                completion(nil, nil)
                return
            }
            self.exchangeInfo = response
            completion(self.exchangeInfo?.exchangeFilters, nil)
        }
        
    }
}
