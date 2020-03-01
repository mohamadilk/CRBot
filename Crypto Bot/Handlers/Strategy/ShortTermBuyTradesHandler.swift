//
//  ShortTermBuyTradesHandler.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8.01.2020.
//  Copyright © 2020 Mohammad Ilkhani. All rights reserved.
//

import Foundation

class ShortTermBuyTradesHandler: AccountsTradeHandler {
    
    func initialSamples(symbol: String, timeFrame: CandlestickChartIntervals, candleLimit: Int) {
        initialCandles(symbol: symbol, timeFrame: timeFrame, candleLimit: candleLimit)
    }
    
    override func updatedSamples() {
        
        let lowRSI = RSI(period: 4)
        lowRSI.sampleList = lowSamples
        lowRsi = lowRSI.CalculateRSI()
        
        let highRSI = RSI(period: 4)
        highRSI.sampleList = highSamples
        highRsi = highRSI.CalculateRSI()
        
//        lowTrix = TRIX(period: 3).calculateTrixValues(samples: lowSamples)
//        highTrix = TRIX(period: 3).calculateTrixValues(samples: highSamples)
        
        let candlesTopDowns = self.calculateCandlesTopsAndDowns(samples: candles, window: 3)
        
        let LowRsiTopDowns = self.calculateTopsAndDowns(samples: self.lowRsi?.RSI as! [Double], window: 3)
        let highRsiTopDowns = self.calculateTopsAndDowns(samples: self.highRsi?.RSI as! [Double], window: 3)
        
        let divInfo = checkForDivergence(candleTops: candlesTopDowns.tops, candleBottoms: candlesTopDowns.bottoms, rsiTops: highRsiTopDowns.tops, rsiBottoms: LowRsiTopDowns.bottoms, lastPossibleIndex: candles.count)
        
        if divInfo.hasDivergence {
            let firstCandle = self.candles[divInfo.startIndex]
            let lastCandle = self.candles[divInfo.endindex]
            print("DIVERGENCE>>>>>>>>>>>>: first candle open time:\(firstCandle.openTime ?? 0) last candle open time:\(lastCandle.openTime ?? 0)")
        } else {
            print("NOTHING ESPECIAL")
        }
        
        if divInfo.hasDivergence {
            print("Start Index: \(divInfo.startIndex), End Index: \(divInfo.endindex)")
        }
//        let LowTrixTopDowns = self.calculateTopsAndDowns(samples: self.lowTrix?.tradingViewTRIX as! [Double], window: 3)
//        let highTrixTopDowns = self.calculateTopsAndDowns(samples: self.highTrix?.tradingViewTRIX as! [Double], window: 3)

    }
}
