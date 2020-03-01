//
//  SheetsHandler.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 22.12.2019.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class SheetsHandler: NSObject {
    
    public static let shared = SheetsHandler()
    
    private var service = GTLRSheetsService()
    
    private var updateTimer: Timer?
    private var symbol = "ETHBTC"
    private var candle_Limits = 500
    private var price_type = PriceType.close
    private var time_Frame = CandlestickChartIntervals.fiveMin
    private var update_Data = true
    
    private var RSIValues = [Double?]()
    private var stocRSIValues = [Double?]()
    private var stocRSISmoothD = [Double?]()
    private var stocRSISmoothK = [Double?]()
    private var stocRSISmoothT = [Double?]()
    
    let spreadsheetId = "1eoc9LJYe6odgRbbCs7DCor4ZcqwM5qxhmZz11PZyiKI"

    let formatter = DateFormatter()
    
    override init() {
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeSheetsSpreadsheets]
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        service.apiKey = "AIzaSyBvQJSZMaSHM7P4x2186XsnHC-lWeUfhkU";
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
    }
    
    func startUpdatingSheets() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
            self.getCell(page: "Input")
        })
    }
    
    private func getCell(page: String) {
        

        let getRange = page
        let getQuery = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range:getRange)
        
        service.executeQuery(getQuery, delegate: self, didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }

    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                       finishedWithObject result : GTLRSheets_ValueRange,
                                       error : NSError?) {
        if let error = error {
            print("\(error.localizedDescription)")
            return
        }

        let rows = result.values!
        symbol = rows[1][0] as? String ?? "ETHBTC"
        candle_Limits = Int(rows[1][1] as? String ?? "500")!
        price_type = PriceType(rawValue: rows[1][2] as? String ?? "Close")!
        time_Frame = CandlestickChartIntervals(rawValue: rows[1][3] as? String ?? "5m")!
        update_Data = (rows[1][4] as? String == "Yes") ? true : false
        
        if update_Data {
            updateCandlesData()
        }
    }
    
    private func updateCandlesData() {
        MarketDataServices.shared.fetchCandlestickData(symbol: symbol, interval: time_Frame.rawValue, limit: candle_Limits) { candlesArray, error in
            guard candlesArray != nil, error == nil else { return }
            
            
            var samples = [Double?]()
            var highSamples = [Double?]()
            var lowSamples = [Double?]()

            for candle in candlesArray ?? [] {
                
                highSamples.append(candle.high?.doubleValue ?? 0)
                lowSamples.append(candle.low?.doubleValue ?? 0)

                switch self.price_type {
                case .close:
                    samples.append(candle.close?.doubleValue ?? 0)
                    break
                case .open:
                    samples.append(candle.open?.doubleValue ?? 0)
                    break
                case .high:
                    samples.append(candle.high?.doubleValue ?? 0)
                    break
                case .low:
                    samples.append(candle.low?.doubleValue ?? 0)
                    break
                }
            }
            
            let ma9 = MovingAverage(period: 9).calculateSimpleMovingAvarage(list: samples)
            let ma26 = MovingAverage(period: 26).calculateSimpleMovingAvarage(list: samples)

            
            let ema7 = MovingAverage(period: 7).calculateExponentialMovingAvarage(list: samples)
            let ema25 = MovingAverage(period: 25).calculateExponentialMovingAvarage(list: samples)
            let ema99 = MovingAverage(period: 99).calculateExponentialMovingAvarage(list: samples)
            
            let trix = TRIX(period: 4).calculateTrixValues(samples: samples)
            
            let BB = BollingerBands(period: 11, mult: 2).calculateBollingerBands(samples: samples as! [Double], highs: highSamples  as! [Double], lows: lowSamples as! [Double])
                        
            let rsi = RSI(period: 14)
            rsi.sampleList = samples
            let rsiResult = rsi.CalculateRSI()
                        
            let lowRsi = RSI(period: 14)
            lowRsi.sampleList = lowSamples
            let lowRsiResult = lowRsi.CalculateRSI()
            
            let highRsi = RSI(period: 14)
            highRsi.sampleList = highSamples
            let highRsiResult = highRsi.CalculateRSI()
            
            self.RSIValues = rsiResult.RSI
            self.candidateRSIValues(samples: samples, symbol: self.symbol)
            
            let candlesTopDowns = self.calculateCandlesTopsAndDowns(samples: candlesArray!, window: 5)
            let rsiTopDowns = self.calculateTopsAndDowns(samples: self.RSIValues as! [Double], window: 5)

            let isDivergence = self.checkForDivergence(candleTops: candlesTopDowns.tops, candleBottoms: candlesTopDowns.bottoms, indicatorTops: rsiTopDowns.tops, indicatorBottoms: rsiTopDowns.bottoms, diff: candlesArray!.count - self.stocRSISmoothK.count)
            
            var candleValues:[[Any]] = [["Time","Low","Open","Close","High"]]
            var RSIValues:[[Any]] = [["Time","RSI","Low RSI","High RSI"]]
            var stocRSIValues:[[Any]] = [["Time","SmoothD","SmoothK","SmoothT"]]
            var MAValues:[[Any]] = [["Time","Value"]]
            
            var crossMAValues:[[Any]] = [["Time","Value1","Value2"]]
            var EMAValues:[[Any]] = [["Time","EMA 7","EMA 25","EMA 99"]]
            var TRIXValues:[[Any]] = [["Time","BinanceTRIX","TVTRIX"]]
            var BBValues:[[Any]] = [["Time","Mid","Upp","Low"]]
            
            let rsiDiff = candlesArray!.count - self.RSIValues.count
            let stocRSIDiff = candlesArray!.count - self.stocRSISmoothD.count
            let ema7Diff = candlesArray!.count - ema7.count
            
            let ema25Diff = candlesArray!.count - ema25.count
            let ema99Diff = candlesArray!.count - ema99.count
            let trixDiff = candlesArray!.count - trix.0.count
            let BBDiff = candlesArray!.count - BB.upper.count
            
            for i in 0..<candlesArray!.count {
                let candle = candlesArray![i]
                let date = self.formatter.string(from: Date.init(timeIntervalSince1970: (candle.openTime!) / 1000))
                
                candleValues.append([date,candle.low!.doubleValue,candle.open!.doubleValue,candle.close!.doubleValue,candle.high!.doubleValue])
                
                if i >= rsiDiff {
                    RSIValues.append([date, self.RSIValues[i - rsiDiff]!, lowRsiResult.RSI[i - rsiDiff]!, highRsiResult.RSI[i - rsiDiff]!])
                } else {
                    RSIValues.append([date,0,0])
                }
                
                if i >= trixDiff {
                    TRIXValues.append([date, trix.0[i - trixDiff]!, trix.1[i - trixDiff]!])
                } else {
                    TRIXValues.append([date,0,0])
                }
                
                if i >= BBDiff {
                    BBValues.append([date, BB.middle[i - BBDiff]!, BB.upper[i - BBDiff]!, BB.lower[i - BBDiff]!])
                } else {
                    BBValues.append([date,0,0,0])
                }
                
                if i >= stocRSIDiff {
                    stocRSIValues.append([date,self.stocRSISmoothD[i - stocRSIDiff]!,self.stocRSISmoothK[i - stocRSIDiff]!,self.stocRSISmoothT[i - stocRSIDiff]!])
                } else {
                    stocRSIValues.append([date,0,0,0])
                }
                
                MAValues.append([date, ma9[i]!])
                
                crossMAValues.append([date, ma9[i]!, ma26[i]!])
                
                if i >= ema7Diff {
                    if i >= ema25Diff {
                        if i >= ema99Diff {
                            EMAValues.append([date, ema7[i - ema7Diff]!, ema25[i - ema25Diff]!, ema99[i - ema99Diff]!])
                        } else {
                            EMAValues.append([date, ema7[i - ema7Diff]!, ema25[i - ema25Diff]!, 0])
                        }
                    } else {
                        EMAValues.append([date, ema7[i - ema7Diff]!, 0, 0])
                    }
                } else {
                    EMAValues.append([date, 0, 0, 0])
                }
            }

            self.service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()

            let clearValues = GTLRSheets_ClearValuesRequest()
            let clearQuery = GTLRSheetsQuery_SpreadsheetsValuesClear.query(withObject: clearValues, spreadsheetId: self.spreadsheetId, range: "CANDLE")
            
            self.service.executeQuery(clearQuery) { (ticket, result, error) in
                guard error == nil else { return }
                
                 let valueRange = GTLRSheets_ValueRange()
                 valueRange.values = candleValues
                 let appendQuery = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: valueRange, spreadsheetId: self.spreadsheetId, range: "CANDLE")
                 appendQuery.valueInputOption = kGTLRSheetsValueInputOptionRaw
                
                 self.service.executeQuery(appendQuery) { (ticket, result, error) in
                     print("")
                 }
            }
            
            let clearRSIValues = GTLRSheets_ClearValuesRequest()
            let clearRSIQuery = GTLRSheetsQuery_SpreadsheetsValuesClear.query(withObject: clearRSIValues, spreadsheetId: self.spreadsheetId, range: "RSI")
            
            self.service.executeQuery(clearRSIQuery) { (ticket, result, error) in
                guard error == nil else { return }

                 let valueRange = GTLRSheets_ValueRange()
                 valueRange.values = RSIValues
                 let appendQuery = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: valueRange, spreadsheetId: self.spreadsheetId, range: "RSI")
                 appendQuery.valueInputOption = kGTLRSheetsValueInputOptionRaw
                
                 self.service.executeQuery(appendQuery) { (ticket, result, error) in
                     print("")
                 }
            }
            
            let clearStocRSIValues = GTLRSheets_ClearValuesRequest()
            let clearStocRSIQuery = GTLRSheetsQuery_SpreadsheetsValuesClear.query(withObject: clearStocRSIValues, spreadsheetId: self.spreadsheetId, range: "STOCHASTIC_RSI")
            
            self.service.executeQuery(clearStocRSIQuery) { (ticket, result, error) in
                guard error == nil else { return }

                 let valueRange = GTLRSheets_ValueRange()
                 valueRange.values = stocRSIValues
                 let appendQuery = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: valueRange, spreadsheetId: self.spreadsheetId, range: "STOCHASTIC_RSI")
                 appendQuery.valueInputOption = kGTLRSheetsValueInputOptionRaw
                
                 self.service.executeQuery(appendQuery) { (ticket, result, error) in
                     print("")
                 }
            }
            
            let clearMIValues = GTLRSheets_ClearValuesRequest()
            let clearMIQuery = GTLRSheetsQuery_SpreadsheetsValuesClear.query(withObject: clearMIValues, spreadsheetId: self.spreadsheetId, range: "MA")
            
            self.service.executeQuery(clearMIQuery) { (ticket, result, error) in
                guard error == nil else { return }

                 let valueRange = GTLRSheets_ValueRange()
                 valueRange.values = MAValues
                 let appendQuery = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: valueRange, spreadsheetId: self.spreadsheetId, range: "MA")
                 appendQuery.valueInputOption = kGTLRSheetsValueInputOptionRaw
                
                 self.service.executeQuery(appendQuery) { (ticket, result, error) in
                     print("")
                 }
            }
            
            let clearCrossMIValues = GTLRSheets_ClearValuesRequest()
            let clearCrossMIQuery = GTLRSheetsQuery_SpreadsheetsValuesClear.query(withObject: clearCrossMIValues, spreadsheetId: self.spreadsheetId, range: "CROSS_MA")
            
            self.service.executeQuery(clearCrossMIQuery) { (ticket, result, error) in
                guard error == nil else { return }

                 let valueRange = GTLRSheets_ValueRange()
                 valueRange.values = crossMAValues
                 let appendQuery = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: valueRange, spreadsheetId: self.spreadsheetId, range: "CROSS_MA")
                 appendQuery.valueInputOption = kGTLRSheetsValueInputOptionRaw
                
                 self.service.executeQuery(appendQuery) { (ticket, result, error) in
                     print("")
                 }
            }
            
            let clearEMAValues = GTLRSheets_ClearValuesRequest()
            let clearEMAQuery = GTLRSheetsQuery_SpreadsheetsValuesClear.query(withObject: clearEMAValues, spreadsheetId: self.spreadsheetId, range: "EMA")
            
            self.service.executeQuery(clearEMAQuery) { (ticket, result, error) in
                guard error == nil else { return }

                 let valueRange = GTLRSheets_ValueRange()
                 valueRange.values = EMAValues
                 let appendQuery = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: valueRange, spreadsheetId: self.spreadsheetId, range: "EMA")
                 appendQuery.valueInputOption = kGTLRSheetsValueInputOptionRaw
                
                 self.service.executeQuery(appendQuery) { (ticket, result, error) in
                     print("")
                 }
            }
            
            let clearTRIXValues = GTLRSheets_ClearValuesRequest()
            let clearTRIXQuery = GTLRSheetsQuery_SpreadsheetsValuesClear.query(withObject: clearTRIXValues, spreadsheetId: self.spreadsheetId, range: "TRIX")
            
            self.service.executeQuery(clearTRIXQuery) { (ticket, result, error) in
                guard error == nil else { return }

                 let valueRange = GTLRSheets_ValueRange()
                 valueRange.values = TRIXValues
                 let appendQuery = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: valueRange, spreadsheetId: self.spreadsheetId, range: "TRIX")
                 appendQuery.valueInputOption = kGTLRSheetsValueInputOptionRaw
                
                 self.service.executeQuery(appendQuery) { (ticket, result, error) in
                     print("")
                 }
            }
            
            let clearBBValues = GTLRSheets_ClearValuesRequest()
            let clearBBQuery = GTLRSheetsQuery_SpreadsheetsValuesClear.query(withObject: clearBBValues, spreadsheetId: self.spreadsheetId, range: "BBAND")
            
            self.service.executeQuery(clearBBQuery) { (ticket, result, error) in
                guard error == nil else { return }

                 let valueRange = GTLRSheets_ValueRange()
                 valueRange.values = BBValues
                 let appendQuery = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: valueRange, spreadsheetId: self.spreadsheetId, range: "BBAND")
                 appendQuery.valueInputOption = kGTLRSheetsValueInputOptionRaw
                
                 self.service.executeQuery(appendQuery) { (ticket, result, error) in
                     print("")
                 }
            }


        }
    }
    
    private func calculateCandlesTopsAndDowns(samples: [CandleObject], window: Int) -> (tops: [Int:Double], bottoms: [Int:Double]) {
        
        var tops = [Int:Double]()
        var bottoms = [Int:Double]()
        
        guard samples.count >= window * 2 + 1 else { return (tops, bottoms) }

        for i in window..<samples.count {
            let high = samples[i].high!
            let low = samples[i].low!
            
            var isHigh = true
            var isLow = true
            
            for w in 1...window {
                if high <= samples[i - w].high! {
                    isHigh = false
                    break
                }
            }
            
            if isHigh {
                if i < samples.count - 1 {
                    for w in (i + 1)...i + window {
                        if w < samples.count {
                            if high <= samples[w].high! {
                                isHigh = false
                                break
                            }
                        }
                    }
                }
            }
            
            if isHigh {
                tops[i] = high.doubleValue
            }
            
            
            
            for w in 1...window {
                if low >= samples[i - w].low! {
                    isLow = false
                    break
                }
            }
            
            if isLow {
                if i < samples.count - 1 {
                    for w in (i + 1)...i + window {
                        if w < samples.count {
                            if low >= samples[w].low! {
                                isLow = false
                                break
                            }
                        }
                    }
                }
            }
            
            if isLow {
                bottoms[i] = low.doubleValue
            }
        }
        
        return (tops, bottoms)
    }
    
    private func calculateTopsAndDowns(samples: [Double], window: Int) -> (tops: [Int:Double], bottoms: [Int:Double]) {
        
        var tops = [Int:Double]()
        var bottoms = [Int:Double]()
        
        guard samples.count >= window * 2 + 1 else { return (tops, bottoms) }

        for i in window..<samples.count {
            let high = samples[i]
            let low = samples[i]
            
            var isHigh = true
            var isLow = true
            
            for w in 1...window {
                if high <= samples[i - w] {
                    isHigh = false
                    break
                }
            }
            
            if isHigh {
                if i < samples.count - 1 {
                    for w in (i + 1)...i + window {
                        if w < samples.count {
                            if high <= samples[w] {
                                isHigh = false
                                break
                            }
                        }
                    }
                }
            }
            
            if isHigh {
                tops[i] = high
            }

            for w in 1...window {
                if low >= samples[i - w] {
                    isLow = false
                    break
                }
            }
            
            if isLow {
                if i < samples.count - 1 {
                    for w in (i + 1)...i + window {
                        if w < samples.count {
                            if low >= samples[w] {
                                isLow = false
                                break
                            }
                        }
                    }
                }
            }
            
            if isLow {
                bottoms[i] = low
            }
        }

        return (tops, bottoms)
    }
    
    private func checkForDivergence(candleTops: [Int:Double],candleBottoms: [Int:Double],indicatorTops: [Int:Double],indicatorBottoms: [Int:Double], diff: Int) -> Bool {
        
        let sortedIndicatorTops =  Array(indicatorTops.keys).sorted(by: <)
        let sortedCandlesTops =  Array(candleTops.keys).sorted(by: <)
//        let sortedIndicatorDowns =  Array(indicatorBottoms.keys).sorted(by: <)
//        let sortedCandlesDowns =  Array(candleBottoms.keys).sorted(by: <)

        let lastCandleIndex = sortedCandlesTops.last!
        let lastIndicatorIndex = sortedIndicatorTops.last!
        
        guard min(candleTops.count,indicatorTops.count) > 1 else { return false }
        
        let defaultDivergenceLookup = 10
        let count = (min(candleTops.count,indicatorTops.count) > defaultDivergenceLookup) ? defaultDivergenceLookup : min(candleTops.count,indicatorTops.count)
        for i in 1...count {
            if ((candleTops[lastCandleIndex]! > candleTops[sortedCandlesTops[sortedCandlesTops.count - i - 1]]!) && (indicatorTops[lastIndicatorIndex]! < indicatorTops[sortedIndicatorTops[sortedIndicatorTops.count - i - 1]]!)) ||
                ((candleTops[lastCandleIndex]! < candleTops[sortedCandlesTops[sortedCandlesTops.count - i - 1]]!) && (indicatorTops[lastIndicatorIndex]! > indicatorTops[sortedIndicatorTops[sortedIndicatorTops.count - i - 1]]!)) {
                
                if abs(sortedIndicatorTops[sortedIndicatorTops.count - i - 1] - sortedCandlesTops[sortedCandlesTops.count - i - 1]) > 5 {
                    print("too much difference!")
                    break
                }

                let priceSlope = abs(candleTops[sortedCandlesTops[sortedCandlesTops.count - i - 1]]! - candleTops[lastCandleIndex]!) / Double(sortedCandlesTops[sortedCandlesTops.count - 1] - sortedCandlesTops[sortedCandlesTops.count - i - 1])
                
                let indicatorSlope = abs(indicatorTops[sortedIndicatorTops[sortedIndicatorTops.count - i - 1]]! - indicatorTops[lastIndicatorIndex]!) / Double(sortedIndicatorTops[sortedIndicatorTops.count - 1] - sortedIndicatorTops[sortedIndicatorTops.count - i - 1])

                let slopeDiff = priceSlope + indicatorSlope
                
                if slopeDiff > 30 {
                    return true
                }
                
                print(i)
                print(candleTops[lastCandleIndex]!)
                print(candleTops[sortedCandlesTops[sortedCandlesTops.count - i - 1]]!)
                print(indicatorTops[lastIndicatorIndex]!)
                print(indicatorTops[sortedIndicatorTops[sortedIndicatorTops.count - i - 1]]!)
                print("\n\n\n\n")
                
            }
        }
        
        
        return false
    }
    
    private func calculateTrixValue(samples: [Double?]) -> (bTRIX: [Double?], tTRIX: [Double?]) {
    
        let EMA1 = MovingAverage(period: 18).calculateExponentialMovingAvarage(list: samples)
        let EMA2 = MovingAverage(period: 18).calculateExponentialMovingAvarage(list: EMA1)
        let EMA3 = MovingAverage(period: 18).calculateExponentialMovingAvarage(list: EMA2)
        
        var tradingTRIX = [0.0]
        
        for i in 1..<EMA3.count {
            tradingTRIX.append(((EMA3[i]! - EMA3[i - 1]!) / EMA3[i - 1]!) * 10000)
        }
        return (EMA3, tradingTRIX)
    }
    
    private func candidateRSIValues(samples: [Double?], symbol: String) {
        
        let rsi = RSI(period:14)
        rsi.sampleList = samples
        let rsiResult = rsi.CalculateRSI()
        
        let stoRSIResult = StochasticRSI(period: 14).calculateStochasticRSI(list: rsiResult.RSI)
        stocRSISmoothD = MovingAverage(period: 3).calculateSimpleMovingAvarage(list: stoRSIResult)
        stocRSISmoothK = MovingAverage(period: 3).calculateSimpleMovingAvarage(list: stocRSISmoothD)
        stocRSISmoothT = MovingAverage(period: 1).calculateSimpleMovingAvarage(list: stocRSISmoothK)
    }
    
    
}
