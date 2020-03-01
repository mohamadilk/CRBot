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
    var timeframeCandles = [[CandleObject]]()
    let infinitTime: Int64 = 1000000000000000
    var index = 0

    func start(timeFrames: [CandlestickChartIntervals]) {
        self.timeFramesArray = timeFrames
        loadAllCandles()
    }
    
    func loadAllCandles() {
        if index == timeFramesArray.count {
            runAlgo()
            return
        }
        
        Table_candle.shared.candle_get(timeInterval: timeFramesArray[index].rawValue, before: infinitTime) { (candles, success) in
            if success ?? false {
                self.timeframeCandles.append(candles)
                self.index += 1
                self.loadAllCandles()
            } else {
                print("Error loading candles")
            }
        }
    }
    
    private func runAlgo() {
        let baseArray = timeframeCandles.removeFirst()
        let firstDivArray = checkDivergene(baseIndex: smallestFrameStartIndex(), arrayToCheck: baseArray)
        
        guard firstDivArray.count > 0 else { return }
        var detectedElements = [firstDivArray]

        while timeframeCandles.count > 0 {
            var arrayToCheck = timeframeCandles.removeFirst()
            var detectedItems = [TimeInterval]()
            
            for time in detectedElements.last! {
                arrayToCheck = arrayToCheck.filter({ $0.closeTime! <= time })
                shortTermTrader.initialCandles(candles: Array(arrayToCheck.suffix(100)))
                if shortTermTrader.runDivergenceCheck() {
                    detectedItems.append(time)
                }
            }
            
            detectedElements.append(detectedItems)
        }

        var finalCandles = [CandleObject]()
        
        for time in detectedElements.last! {
            if let candle = baseArray.filter({ $0.closeTime! == time }).last {
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
    
    private func smallestFrameStartIndex() -> Int {
        guard let firstTimeFrame = timeFramesArray.first else { return 10 }
        switch firstTimeFrame {
        case .oneMin:
            return 500000
        case .threeMin:
            return 168000
        case .fiveMin:
            return 30000
        case .fifteenMin:
            return 33600
        case .thirtyMin:
            return 16800
        case .oneHour:
            return 8400
        case .twoHour:
            return 4200
        case .fourHour:
            return 2100
        case .sixHour:
            return 1575
        case .eightHour:
            return 1050
        case .twelveHour:
            return 700
        case .oneDay:
            return 350
        case .threeDay:
            return 118
        case .oneWeek:
            return 50
        case .oneMonth:
            return 12
        }
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
