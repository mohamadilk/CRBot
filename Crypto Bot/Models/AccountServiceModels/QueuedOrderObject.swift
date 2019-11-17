//
//  QueuedOrderObject.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/25/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation

class QueuedOrderObject {
    
    var asset: String
    var currency: String
    var price: String
    var stopPrice: String
    var stopLimitPrice: String
    var amount: String
    var orderId: String
    var type = OrderTypes.OCO
    let side = OrderSide.SELL
    
    init(asset: String, currency: String, price: String, stopPrice: String, stopLimitPrice: String, amount: String, orderId: String) {
        self.asset = asset
        self.currency = currency
        self.price = price
        self.stopPrice = stopPrice
        self.stopLimitPrice = stopLimitPrice
        self.amount = amount
        self.orderId = orderId
    }
}
