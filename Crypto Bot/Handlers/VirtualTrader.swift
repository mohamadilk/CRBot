//
//  VirtualTrader.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 9.01.2020.
//  Copyright © 2020 Mohammad Ilkhani. All rights reserved.
//

import Foundation

class VirtualTrader {
    
    let shortTermTrader = ShortTermBuyTradesHandler()

    var timeFramesArray = [CandlestickChartIntervals.fiveMin, CandlestickChartIntervals.fourHour, CandlestickChartIntervals.oneDay]
    
    var firstTimeframeArray = [CandleObject]()
    var secondTimeframeArray = [CandleObject]()
    var thirdTimeframeArray = [CandleObject]()
        
    let infinitTime: Int64 = 1000000000000000
    let smallestFrameStartIndex = 30000 // for 5 min and 1 day, means that we should start from here to be able to get 1000 1D candle for bigest timeframe
    
    func start() {
        loadAllCandles()
    }
    
    func loadAllCandles() {
        Table_candle.shared.candle_get(timeInterval: timeFramesArray[0].rawValue, before: infinitTime) { (firstCandles, firstSuccess) in
            if firstSuccess ?? false {
                self.firstTimeframeArray = firstCandles
                
                Table_candle.shared.candle_get(timeInterval: self.timeFramesArray[1].rawValue, before: self.infinitTime) { (secondCandles, secondSuccess) in
                    if secondSuccess ?? false {
                        self.secondTimeframeArray = secondCandles
                        
                        Table_candle.shared.candle_get(timeInterval: self.timeFramesArray[2].rawValue, before: self.infinitTime) { (thirdCandles, thirdSuccess) in
                            if thirdSuccess ?? false {
                                self.thirdTimeframeArray = thirdCandles
                                self.didReceiveCandles()
                            } else {
                                print("Error loading candles")
                            }
                        }
                    } else {
                        print("Error loading candles")
                    }
                }
            } else {
                print("Error loading candles")
            }
        }
    }
    
    private func didReceiveCandles() {
        runAlgo()
    }
    
    private func runAlgo() {

        var detectedTimes = [TimeInterval]()
        var finalItems = [TimeInterval]()
        
        let firstDivArray = checkDivergene(baseIndex: smallestFrameStartIndex, arrayToCheck: firstTimeframeArray)
        
        for time in firstDivArray {
            let arrayToCheck = secondTimeframeArray.filter({ $0.closeTime! <= time })
            shortTermTrader.initialCandles(candles: Array(arrayToCheck.suffix(100)))
            if shortTermTrader.runDivergenceCheck() {
                detectedTimes.append(time)
            }
        }
        
        for time in detectedTimes {
            let arrayToCheck = thirdTimeframeArray.filter({ $0.closeTime! <= time })
            shortTermTrader.initialCandles(candles: Array(arrayToCheck.suffix(100)))
            if shortTermTrader.runDivergenceCheck() {
                finalItems.append(time)
            }
        }
        
        var finalCandles = [CandleObject]()
        
        for time in finalItems {
            if let candle = firstTimeframeArray.filter({ $0.closeTime! == time }).last {
                finalCandles.append(candle)
            }
        }
        
        print("Final Items")
        
    }
    
    private func checkDivergene(baseIndex: Int, arrayToCheck: [CandleObject]) -> [TimeInterval] {
        var detectedTimes = [TimeInterval]()
        for index in baseIndex..<arrayToCheck.count {
            
            let initialCheckArray = Array(arrayToCheck[(index - 100)...(index - 1)])
            shortTermTrader.initialCandles(candles: initialCheckArray)
            if shortTermTrader.runDivergenceCheck() {
                detectedTimes.append(initialCheckArray.last?.closeTime ?? 0)
            }
        }
        return detectedTimes
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
