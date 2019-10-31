//
//  SymbolsListViewModel.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/31/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation

class SymbolsListViewModel: NSObject {
    
    private var viewController: SymbolsListTableViewController!
    private var symbolsArray = [SymbolObject]()
    
    init(viewController: SymbolsListTableViewController) {
        super.init()
        self.viewController = viewController
    }
    
    func getSymbolsArray(response:@escaping (_ symbols: [SymbolObject]?, _ error: ApiError?) -> Swift.Void) {
        ExchangeManager.shared.getAllAvailableSymbols { (symbols, error) in
            guard error == nil else {
                response(nil, error)
                return
            }
            
            self.symbolsArray = symbols ?? []
            response(self.symbolsArray, nil)
        }
    }
}
