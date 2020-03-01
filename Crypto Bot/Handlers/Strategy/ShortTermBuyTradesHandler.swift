//
//  ShortTermBuyTradesHandler.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8.01.2020.
//  Copyright © 2020 Mohammad Ilkhani. All rights reserved.
//

import Foundation

class ShortTermBuyTradesHandler: AccountsTradeHandler {
    
    func initialSamples(candles: [CandleObject]) {
        initialCandles(candles: candles)
    }
    
    override func updatedSamples() {
        let lowRSI = RSI(period: 4)
        lowRSI.sampleList = lowSamples
        lowRsi = lowRSI.CalculateRSI()
        lowRsi?.RSI.insert(0, at: 0)
        
        let highRSI = RSI(period: 4)
        highRSI.sampleList = highSamples
        highRsi = highRSI.CalculateRSI()
        highRsi?.RSI.insert(0, at: 0)
    }
    
    func runDivergenceCheck() -> Bool {
                
        //        lowTrix = TRIX(period: 3).calculateTrixValues(samples: lowSamples)
        //        highTrix = TRIX(period: 3).calculateTrixValues(samples: highSamples)
                
        let candlesTopDowns = self.calculateCandlesTopsAndDowns(samples: candles, window: 2)
        let LowRsiTopDowns = self.calculateTopsAndDowns(samples: self.lowRsi?.RSI as! [Double], window: 2)
        let highRsiTopDowns = self.calculateTopsAndDowns(samples: self.highRsi?.RSI as! [Double], window: 2)
        
        let divInfo = checkForDivergence(candleTops: candlesTopDowns.tops, candleBottoms: candlesTopDowns.bottoms, rsiTops: highRsiTopDowns.tops, rsiBottoms: LowRsiTopDowns.bottoms, lastPossibleIndex: candles.count)
        
        if divInfo.hasDivergence {
            let firstCandle = self.candles[divInfo.startIndex]
            let lastCandle = self.candles[divInfo.endindex]
            print("DIVERGENCE>>>>>>>>>>>>: first candle open time:\(firstCandle.openTime ?? 0) last candle open time:\(lastCandle.openTime ?? 0)")
        } else {
            print("NOTHING ESPECIAL")
        }
        
        return divInfo.hasDivergence
        //        let LowTrixTopDowns = self.calculateTopsAndDowns(samples: self.lowTrix?.tradingViewTRIX as! [Double], window: 3)
        //        let highTrixTopDowns = self.calculateTopsAndDowns(samples: self.highTrix?.tradingViewTRIX as! [Double], window: 3)
    }
}
