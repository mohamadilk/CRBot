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

class CandlesDataContainer {
    
    var oldCandle: CandleObject!
    var lastCandle: CandleObject!
    var oneToLastCandle: CandleObject!
    
    var tradedCandlesCount = 0
    var samplesArray = [Double?]()
    
    init?(candles: [CandleObject], latestPrice: String) {
        
        guard candles.count > 0 else { return nil }
        for i in 0..<candles.count {
            
            let candleObject = candles[i]
            samplesArray.append(candleObject.close?.doubleValue)
            
            if i == candles.count - 2 { lastCandle = candleObject }
            if i == candles.count - 3 { oneToLastCandle = candleObject }
            if i == candles.count - 4 { oldCandle = candleObject }
            
            if candles.count > 7 {
                if (candles.count - 7)..<(candles.count - 1) ~= i {
                    if ((candleObject.open?.doubleValue ?? 0) != (candleObject.close?.doubleValue ?? 0)) {
                        tradedCandlesCount += 1
                    }
                }
            }
        }
        
        samplesArray.append(latestPrice.doubleValue)
    }
}
