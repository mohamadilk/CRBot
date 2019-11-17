//
//  BasicOrderObject.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/26/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation
import CoreData

class CoreDataBasicEntity {
    
    // MARK: - Attributes
    
    var asset: String
    var currency: String
    var price: String
    var stopPrice: String
    var stopLimitPrice: String
    var amount: String
    var orderId: String
    
    // MARK: - Init
    
    init(object: BasicOrderObject) {
        self.asset = object.asset!
        self.currency = object.currency!
        self.price = object.price!
        self.stopPrice = object.stopPrice!
        self.stopLimitPrice = object.stopLimitPrice!
        self.amount = object.amount!
        self.orderId = object.orderId!
    }
}

