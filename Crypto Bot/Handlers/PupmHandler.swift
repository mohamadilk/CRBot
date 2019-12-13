//
//  PupmHandler.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 9/4/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation

class PumpHandler {
    
    public static let shared = PumpHandler()
    
    var minutesTimer: Timer?
    var secondsTimer: Timer?
    
    var secondPrice = [String: String]()
    var currentPrice = [String: String]()
    
    var symbolPricesDict = [String: [String]]()
    var watchList = [CandidateSymbolObject]()
    
    var finalApprovedArray: [String]?
    
    let tradeFactor: Double = 0.5
    let passToTradeCount = 3
    
    var candidateDetectionCountDict = [String: Int]()
    let detectionConfirmationLimit = 3
    
    var activeOrders = [String]()
    var dayInfoArray: [OneDayTickerPriceChangeObject]?
    var avarageValumePerSymbol = [String: Double]()
    
    let minimumTradeCount = 10
    var minimumVolumeMultiplyer: Double = 4.0
    
    var marketMultiplayer: Double = 1
    
    var ignoreForFiveMin = [String: Double]()
    
    init() {
//        minutesTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true, block: { _ in
//            self.updateMinutesData()
//        })
//        minutesTimer?.fire()
//
//        secondsTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { _ in
//            self.updateSecondsData()
//        })
//        secondsTimer?.fire()
//
//        //TODO: Update everyDay
//        MarketDataServices.shared.fetchOneDayTickerPriceChangeStatistics { (dayInfo, error) in
//            guard error == nil, dayInfo != nil else {
//                return
//            }
//
//            self.dayInfoArray = dayInfo
//            for symbolInfo in self.dayInfoArray ?? [] {
//                if let symbol = symbolInfo.symbol {
//                    if let volume = symbolInfo.volume?.doubleValue {
//                        self.avarageValumePerSymbol[symbol] = volume / 1440.0
//                    }
//                }
//            }
//        }
    }
        
    private func updateMinutesData() {
        MarketDataServices.shared.fetchSymbolPriceTicker { [unowned self] (symbolPricesArray, error) in
            
            
            guard error == nil, symbolPricesArray != nil else {
                return
            }
            
            if self.secondPrice.keys.count == 0,self.currentPrice.keys.count == 0 { //First minute data received
                for symbolPrice in symbolPricesArray! {
                    if let symbol = symbolPrice.symbol, let price = symbolPrice.price {
                        self.currentPrice[symbol] = price
                    }
                }
                return
                
            } else { 
                self.secondPrice = self.currentPrice
                for symbolPrice in symbolPricesArray! {
                    if let symbol = symbolPrice.symbol, let price = symbolPrice.price {
                        self.currentPrice[symbol] = price
                    }
                }
            }
        }
    }
    
    func updateIgnoreList() {
        var tempDic = [String: Double]()
        
        for symbol in ignoreForFiveMin.keys {
            let time = ignoreForFiveMin[symbol]
            
            let difference = Calendar.current.dateComponents([.hour, .minute], from: Date(timeIntervalSinceNow: time!), to: Date())
            if let minuts = difference.minute, minuts <= 3 {
                tempDic[symbol] = time
            }
        }
        
        ignoreForFiveMin = tempDic
    }
    
    private func sellActiveOrdersIfNeeded() {
        for symbol in self.activeOrders {
            MarketDataServices.shared.fetchSymbolPriceTicker(symbol: symbol) { (symbolPrice, error) in
                guard error == nil, symbolPrice != nil else { return }
                
                MarketDataServices.shared.fetchCandlestickData(symbol: symbol, interval: CandlestickChartIntervals.oneMin.rawValue, limit: 50) { (candlesArray, error) in
                    var samples = [Double?]()
                    for candle in candlesArray ?? [] {
                        samples.append(candle.close?.doubleValue ?? 0)
                    }
                    samples.append(symbolPrice?.price?.doubleValue ?? 0)
                    
                    let RSIValues = self.candidateRSIValues(samples: samples, symbol: symbol)
                    guard RSIValues.count >= 3 else { return }
                    
                    guard let lastRsi = RSIValues.last else { return }
                    guard let oneToLast = RSIValues[RSIValues.count - 2] else { return }
                    guard let twoTolastRsi = RSIValues[RSIValues.count - 3] else { return }
                    
                    if oneToLast > 85 {
                        let slope = (lastRsi ?? 0) - (twoTolastRsi)
                        if slope < -2 {
                            print("OCO SHOULD BE CANCELLED!! lastRsi: \(lastRsi ?? 0), oneToLast: \(oneToLast ), twoTolastRsi: \(twoTolastRsi ), slope: \(slope)", to: &logger)
                            OrderHandler.shared.cancelAndResellActiveOrdersFor(symbol: symbol)
                        }
                    }
                }
            }
        }
    }
    
    private func updateSecondsData() {
        
        updateIgnoreList()
        sellActiveOrdersIfNeeded()
        MarketDataServices.shared.fetchSymbolPriceTicker { [unowned self] (symbolOrderBooksArray, error) in
            guard error == nil, symbolOrderBooksArray != nil else {
                return
            }
            
            if self.secondPrice.keys.count == 0 {
                return
            }
            
            self.watchList = []
            
            if let btcOrders = symbolOrderBooksArray?.filter({ ($0.symbol?.contains("BTC") ?? false) }), btcOrders.count > 0 {
                var passedOrders = 0
                for symbolObject in btcOrders {
                    
                    guard let symbol = symbolObject.symbol else { continue }
                    guard symbolObject.price?.doubleValue ?? 0 > 0.000002 else { continue }
                    
                    var weightedScore: Double = 0.0
                    var rawScore: Double = 0.0
                    
                    guard let secondPrice = self.secondPrice[symbol] else { continue }
                    guard symbolObject.price?.doubleValue ?? 0 > secondPrice.doubleValue else { continue }
                    
                    if let currentPrice = self.currentPrice[symbol] {
                        if currentPrice == secondPrice { continue }
                        let secondPercent = (currentPrice.doubleValue / secondPrice.doubleValue - 1) * 100
                        rawScore = rawScore + secondPercent
                        weightedScore = weightedScore + secondPercent * 3
                        
                        if let bidPrice = symbolObject.price?.doubleValue {
                            let currentPercent = (bidPrice / currentPrice.doubleValue - 1) * 100
                            rawScore = rawScore + currentPercent
                            weightedScore = weightedScore + currentPercent * 5
                        }
                    }
                    print(Date(), ">>>>>> Symbol \(symbol) Raw Score is: \(rawScore)" ,to: &logger)
                    passedOrders += 1
                    if rawScore > self.tradeFactor {
                        let candidate = CandidateSymbolObject()
                        candidate.rawScore = rawScore
                        candidate.weightedScore = weightedScore
                        candidate.symbolOrderBook = SymbolOrderBookObject()
                        candidate.symbolOrderBook?.symbol = symbol
                        candidate.latestPrice = symbolObject.price
                        self.watchList.append(candidate)
                    }
                }
                self.updateMarketMultipyer(passedOrders: passedOrders, total: btcOrders.count)
                self.watchListUpdated()
            }
        }
    }
    
    func watchListUpdated() {
        var watchList = self.watchList
        guard watchList.count > 0 else {
            print(Date(), "Watch list is empty" ,to: &logger)
            return
        }
        watchList = watchList.sorted(by: { $0.weightedScore! > $1.weightedScore! })
        var finalArray = [CandidateSymbolObject]()
        
        if watchList.count >= passToTradeCount {
            finalArray = Array(watchList[0 ..< passToTradeCount])
        } else {
            finalArray = watchList
        }
        
        filterByCandleSticData(candidates: finalArray)
    }
    
    func filterByCandleSticData(candidates: [CandidateSymbolObject]) {
        for candida in candidates {
            guard let symbol = candida.symbolOrderBook?.symbol else { continue }
            guard self.candidateIsNotInIgnoreList(symbol: symbol) else { continue }
            guard self.candidateIsNotInActiveOrders(symbol: symbol) else { continue }
            
            MarketDataServices.shared.fetchCandlestickData(symbol: symbol, interval: CandlestickChartIntervals.oneMin.rawValue, limit: 50) { (candlesArray, error) in
                guard let candlesArray = candlesArray, error == nil else { return }
                guard let candlesData = CandlesDataContainer(candles: candlesArray, latestPrice: candida.latestPrice!) else { return }
                
                guard self.candidateMeetsMinimumTradedCandlesCount(candlesData: candlesData, symbol: symbol) else { return }
//                guard self.candleHasPositiveDirection(candleData: candlesData) else { return }
                guard self.totalTradesAndVolumeMeetsMinimumCounts(candles: [candlesData.oldCandle, candlesData.oneToLastCandle, candlesData.lastCandle], symbol: symbol) else { return }
                guard self.candleHighValueIsRational(candle: candlesData.lastCandle) else { return }
                
                guard self.movingAvarageStatusIsAcceptable(samples: candlesData.samplesArray) else { return }
                let RSIValues = self.candidateRSIValues(samples: candlesData.samplesArray, symbol: symbol)
                guard self.rsiSlopeIsPositive(rsiValues: RSIValues) else { return }
                
                print(Date(), "Symbol RSI: \(symbol), \(String(describing: RSIValues.last ?? 0))" ,to: &logger)
                guard (RSIValues.last ?? 0)! < 75 else {
                    print(Date(), "Symbol RSI is greater than or 80: \(symbol)" ,to: &logger)
                    return
                }
                
                guard self.candidateMeetsEnoughDetectionCount(symbol: symbol) else { return }
                
                OrderHandler.shared.placePumpOrder(for: symbol) { (success, error) in
                    if success ?? false {
                        MAudioPlayer.shared.playBellSound()
                        self.activeOrders.append(symbol)
                    }
                }
            }
        }
    }
    
    private func candidateIsNotInIgnoreList(symbol: String) -> Bool {
        if let _ = self.ignoreForFiveMin[symbol] {
            print(Date(), "symbol is in ignore list: \(symbol)" ,to: &logger)
            return false
        }
        return true
    }
    
    private func candidateIsNotInActiveOrders(symbol: String) -> Bool {
        if self.activeOrders.contains(symbol) {
            print(Date(), "candidate is already in active orders \(symbol)" ,to: &logger)
            return false
        }
        return true
    }
    
    private func candidateMeetsEnoughDetectionCount(symbol: String) -> Bool {
        if let count = self.candidateDetectionCountDict[symbol] {
            self.candidateDetectionCountDict[symbol] = count + 1
            if self.candidateDetectionCountDict[symbol]! >= self.detectionConfirmationLimit {
                print(Date(), ">>>>>>>>>>>>>> DETECTED \(symbol)" ,to: &logger)
                self.candidateDetectionCountDict.removeValue(forKey: symbol)
                return true
            }
            return false
        } else {
            self.candidateDetectionCountDict[symbol] = 1
            return false
        }
    }
    
    private func candleHighValueIsRational(candle: CandleObject) -> Bool {
        
        let avarage = (candle.close?.doubleValue ?? 0) - (candle.open?.doubleValue ?? 0)
        let high = (candle.high?.doubleValue ?? 0) - (candle.close?.doubleValue ?? 0)
        
        if  avarage < high {
            print(Date(), "Symbol candle sticks has some atmpspher!" ,to: &logger)
            return false
        }
        return true
    }
    
    private func movingAvarageStatusIsAcceptable(samples: [Double?]) -> Bool {
        
        let fiveAvarage = MovingAverage(period: 5).calculateSimpleMovingAvarage(list: samples).last
        let elevenAvarage = MovingAverage(period: 11).calculateSimpleMovingAvarage(list: samples).last
        
        if elevenAvarage!! >= fiveAvarage!! {
            print(Date(), "Somethings wrong with indicators" ,to: &logger)
            return false
        }
        return true
    }
    
    private func totalTradesAndVolumeMeetsMinimumCounts(candles: [CandleObject], symbol: String) -> Bool {
        
        var totalTrades: Int = 0
        var totalVolume: Double = 0
        
        for candle in candles {
            totalTrades = candle.numberOfTrades!
            totalVolume = candle.volume!.doubleValue
        }
        
        if totalVolume > (self.avarageValumePerSymbol[symbol] ?? 0) * self.minimumVolumeMultiplyer && totalTrades >= self.minimumTradeCount {
            return true
        }
        print(Date(), "Does not meet minimum trade count or volume \(symbol)\n Avarage Volume: \(self.avarageValumePerSymbol[symbol] ?? 0)\n Total Volume: \(totalVolume)" ,to: &logger)
        return false
        
    }
    
    private func candidateRSIValues(samples: [Double?], symbol: String) -> [Double?] {
        
        let rsi = RSI(period: 14)
        rsi.sampleList = samples
        let rsiResult = rsi.CalculateNormalRSI()
        
        let stoRSIResult = StochasticRSI(period: 12).calculateStochasticRSI(list: rsiResult.RSI)
        let smoothedRSI = MovingAverage(period: 3).calculateSimpleMovingAvarage(list: stoRSIResult)
        let finalRSI = MovingAverage(period: 3).calculateSimpleMovingAvarage(list: smoothedRSI)
        
        return finalRSI
    }
    
    private func rsiSlopeIsPositive(rsiValues: [Double?]) -> Bool {
        
        guard let lastRsi = rsiValues.last else { return false }
        guard let twoTolastRsi = rsiValues[rsiValues.count - 3] else { return false }
        
        print("Slope is equal: \(((lastRsi ?? 0) - twoTolastRsi))", to: &logger)
        return ((lastRsi ?? 0) - twoTolastRsi) > 0
    }
    
    private func candidateMeetsMinimumTradedCandlesCount(candlesData: CandlesDataContainer, symbol: String) -> Bool {
        if candlesData.tradedCandlesCount < 4 {
            print(Date(), "tradedCandlesCount is less than 4: \(symbol)" ,to: &logger)
            self.ignoreForFiveMin[symbol] = Date().timeIntervalSince1970
            return false
        }
        return true
    }
    
    private func candleHasPositiveDirection(candleData: CandlesDataContainer) -> Bool {
        if ((candleData.lastCandle.open?.doubleValue ?? 1000000) >= (candleData.lastCandle.close?.doubleValue ?? 0)) {
            print(Date(), "Symbol candle close is less than or equal to open:" ,to: &logger)
            return false
        }
        return true
    }
    
    private func updateMarketMultipyer(passedOrders: Int, total: Int) {
        marketMultiplayer = Double(total / ((passedOrders == 0) ? 1 : passedOrders))
        print(Date(), "Market factor: \(marketMultiplayer)" ,to: &logger)
        minimumVolumeMultiplyer = 3.8 + (20.0 * marketMultiplayer / 100.0)
    }
}
