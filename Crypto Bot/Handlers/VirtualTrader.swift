//
//  VirtualTrader.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 9.01.2020.
//  Copyright © 2020 Mohammad Ilkhani. All rights reserved.
//

import Foundation

class VirtualTrader {
    
    var candlesArray = [CandleObject]()
    var timeFramesArray = CandlestickChartIntervals.oneMonth
    var total = 24
    
    func fetchCandles(timeFrame: CandlestickChartIntervals, total: Int) {
        
        self.timeFrame = timeFrame
        self.total = total
        
//        fetchDataRecursively()
    }
    
    func fetchDataRecursively(endTime: TimeInterval? = Date().timeIntervalSince1970 * 1000) {

        Table_candle.shared.candle_get(timeInterval: "", before: 0) { (Candles, success) in
            if success ?? false {
                self.candlesArray = Candles
                self.didReceiveCandles()
            }
        }
//        MarketDataServices.shared.fetchCandlestickData(symbol: "BTCUSDT", interval: timeFrame.rawValue , limit: 1000, endTime: UInt(endTime!)) { (candlesArray, error) in
//            guard error == nil, candlesArray != nil else {
//                self.didReceiveCandles()
//                return
//            }
//
//            var candles = candlesArray!
//
//            for candle in candles {
//                candle.interval = self.timeFrame.rawValue
//            }
//
//            candles.append(contentsOf: self.candlesArray)
//            candles.removeFirst()
//            self.candlesArray = candles
//
//            if self.candlesArray.count >= self.total {
//                self.didReceiveCandles()
//                return
//            }
//
//            guard let firstCandle = candlesArray?.first else {
//                self.didReceiveCandles()
//                return
//            }
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.fetchDataRecursively(endTime: firstCandle.openTime!)
//            }
//        }
    }
    
    private func didReceiveCandles() {
        for index in 100..<self.candlesArray.count {
            let initialCheckArray = Array(self.candlesArray[(index - 100)...(index - 1)])
            ShortTermBuyTradesHandler().initialCandles(symbol: "", timeFrame: .fiveMin, candleLimit: 100, candles: initialCheckArray)
        }
    }
}
