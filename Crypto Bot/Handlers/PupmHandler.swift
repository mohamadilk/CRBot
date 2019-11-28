//
//  PupmHandler.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 9/4/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation

class PupmHandler {
    
    public static let shared = PupmHandler()
    
    var minutesTimer: Timer?
    var secondsTimer: Timer?
    
//    var firstPrice = [String: String]()
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
    let minimumVolumeMultiplyer: Double = 6.0
    
    init() {
        minutesTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true, block: { _ in
            self.updateMinutesData()
        })
        minutesTimer?.fire()
        
        secondsTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { _ in
            self.updateSecondsData()
        })
        secondsTimer?.fire()
        
        MarketDataServices.shared.fetchOneDayTickerPriceChangeStatistics { (dayInfo, error) in
            guard error == nil, dayInfo != nil else {
                return
            }
            
            self.dayInfoArray = dayInfo
            for symbolInfo in self.dayInfoArray ?? [] {
                if let symbol = symbolInfo.symbol {
                    if let volume = symbolInfo.volume?.doubleValue {
                        self.avarageValumePerSymbol[symbol] = volume / 1440.0
                    }
                }
            }
        }
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
                
            } else if self.secondPrice.keys.count == 0, self.currentPrice.keys.count > 0 { //Second minute of data received
                self.secondPrice = self.currentPrice
                for symbolPrice in symbolPricesArray! {
                    if let symbol = symbolPrice.symbol, let price = symbolPrice.price {
                        self.currentPrice[symbol] = price
                    }
                }
                
                
            }
//            else if self.secondPrice.keys.count > 0, self.currentPrice.keys.count > 0  { // Data after second minute received
//                self.firstPrice = self.secondPrice
//                self.secondPrice = self.currentPrice
//                for symbolPrice in symbolPricesArray! {
//                    if let symbol = symbolPrice.symbol, let price = symbolPrice.price {
//                        self.currentPrice[symbol] = price
//                    }
//                }
//            }
        }
    }
    
    private func updateSecondsData() {
        
        MarketDataServices.shared.fetchSymbolPriceTicker { [unowned self] (symbolOrderBooksArray, error) in
            guard error == nil, symbolOrderBooksArray != nil else {
                return
            }
            
            if self.secondPrice.keys.count == 0 {
                return
            }
            
            self.watchList = []
            
            if let btcOrders = symbolOrderBooksArray?.filter({ ($0.symbol?.contains("BTC") ?? false) }), btcOrders.count > 0 {
                for symbolObject in btcOrders {

                    guard let symbol = symbolObject.symbol else { continue }
                    guard symbolObject.price?.doubleValue ?? 0 > 0.00000100 else { continue }
                    
                    var weightedScore: Double = 0.0
                    var rawScore: Double = 0.0
                    
                    guard let secondPrice = self.secondPrice[symbol] else { continue }
                    guard symbolObject.price?.doubleValue ?? 0 > secondPrice.doubleValue else {
                        self.secondPrice.removeValue(forKey: symbol)
//                        self.firstPrice.removeValue(forKey: symbol)
                        self.watchList = self.watchList.filter({ $0.symbolOrderBook?.symbol != symbol })
                        continue
                    }
//
//                    if self.firstPrice.keys.count > 0 , let firstPrice = self.firstPrice[symbol] {
//                        if firstPrice == secondPrice { continue }
//                        let firstPercentage = (secondPrice.doubleValue / firstPrice.doubleValue - 1) * 100
//                        rawScore = rawScore + firstPercentage
//                        weightedScore = weightedScore + firstPercentage
//                    }
                    
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
                    
                    if rawScore > self.tradeFactor {
                        let candidate = CandidateSymbolObject()
                        candidate.rawScore = rawScore
                        candidate.weightedScore = weightedScore
                        candidate.symbolOrderBook = SymbolOrderBookObject()
                        candidate.symbolOrderBook?.symbol = symbol
                        self.watchList.append(candidate)
                    }
                }
                self.watchListUpdated()
            }
        }
    }
    
    func watchListUpdated() {
        var watchList = self.watchList
        guard watchList.count > 0 else {
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
            MarketDataServices.shared.fetchCandlestickData(symbol: symbol, interval: CandlestickChartIntervals.oneMin.rawValue, limit: 2) { (candlesArray, error) in
                guard candlesArray != nil, error == nil else { return }
                
                var totalTrades = 0
                var totalVolume: Double = 0.0
                
                for candle in candlesArray! {
                    if candle.open?.doubleValue ?? 1 >= candle.close?.doubleValue ?? 0 { return }
                    totalTrades = totalTrades + (candle.numberOfTrades ?? 0)
                    totalVolume = totalVolume + (candle.volume?.doubleValue ?? 0.0)
                }
                
                if totalTrades >= self.minimumTradeCount {
                    if totalVolume > (self.avarageValumePerSymbol[symbol] ?? 0) * self.minimumVolumeMultiplyer {
                        
                        if !self.activeOrders.contains(symbol) {
                            print(">>>>>>>>>>>>>> CANDIDATE CONFIRMED \(symbol)")
                            if let count = self.candidateDetectionCountDict[symbol] {
                                self.candidateDetectionCountDict[symbol] = count + 1
                                if self.candidateDetectionCountDict[symbol] ?? 0 >= self.detectionConfirmationLimit {
                                    print(">>>>>>>>>>>>>> DETECTED \(symbol)")
                                    self.activeOrders.append(symbol)
                                    self.candidateDetectionCountDict.removeValue(forKey: symbol)
                                    OrderHandler.shared.placePumpOrder(for: symbol)
                                }
                            } else {
                                self.candidateDetectionCountDict[symbol] = 1
                            }
                        } else {
                            print("Already in active orders \(symbol)")
                        }
                    } else {
                        print("Does not meet minimum volume \(symbol)\n\n Avarage Volume: \(self.avarageValumePerSymbol[symbol] ?? 0)\n Total Volume: \(totalVolume)")
                    }
                } else {
                    print("Does not meet minimum trade count \(symbol)")
                }
            }
        }
    }
}
