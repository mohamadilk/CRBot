//
//  CandleObject.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/8/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation

class CandleObject {

    var openTime: TimeInterval?
    var open: String?
    var high: String?
    var low: String?
    var close: String?
    var volume: String?
    var closeTime: TimeInterval?
    var quoteAssetVolume: String?
    var numberOfTrades: Int?
    var takerBuyBaseAssetVolume: String?
    var takerBuyquoteAssetVolume: String?
    var ignore: String?
    
    init(openTime: TimeInterval?, open: String?, high: String?, low: String?, close: String?, volume: String?, closeTime: TimeInterval?, quoteAssetVolume: String?, numberOfTrades: Int?, takerBuyBaseAssetVolume: String?, takerBuyquoteAssetVolume: String?, ignore: String?) {
        
        self.openTime = openTime
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
        self.closeTime = closeTime
        self.quoteAssetVolume = quoteAssetVolume
        self.numberOfTrades = numberOfTrades
        self.takerBuyBaseAssetVolume = takerBuyBaseAssetVolume
        self.takerBuyquoteAssetVolume = takerBuyquoteAssetVolume
        self.ignore = ignore
    }
}
