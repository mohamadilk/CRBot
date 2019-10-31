//
//  PlaceNewOrderDetailViewModel.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/7/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation

class PlaceNewOrderDetailViewModel: NSObject {
    
    private var viewController: PlaceNewOrderDetailViewController!
    
    var timer: Timer?
    var symbol: SymbolObject?
    
    init(viewController: PlaceNewOrderDetailViewController) {
        super.init()
        self.viewController = viewController
    }
    
    func initialUpdatePrices(symbol: SymbolObject) {
        self.symbol = symbol
        self.updateLatestPriceFor()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLatestPriceFor), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc func updateLatestPriceFor() {
        if let symbol = symbol {
            MarketDataHandler.shared.getLatestOrder(symbol: symbol) { (order, error) in
                if let order = order {
                    self.viewController.updateLatestDataWith(order: order)
                }
            }
        }
    }
    
    func stopUpdatePrices() {
        timer?.invalidate()
    }
}
