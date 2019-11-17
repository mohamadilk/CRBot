//
//  OrderBookObject.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/7/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

struct OrderBookObject {
    
    var lastUpdateId: UInt?
    var bids = [BidAskObject]()
    var asks = [BidAskObject]()
}
