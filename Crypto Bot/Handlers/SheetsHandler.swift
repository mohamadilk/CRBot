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
//
//            guard self.StochRSILenthRSI != nil else {
//                AlertUtility.showAlert(title: "Please set RSI Lenght")
//                return
//            }
            
            let ma9 = MovingAverage(period: 9).calculateSimpleMovingAvarage(list: samples)
            let ma26 = MovingAverage(period: 26).calculateSimpleMovingAvarage(list: samples)

            
            let ema7 = MovingAverage(period: 7).calculateExponentialMovingAvarage(list: samples)
            let ema25 = MovingAverage(period: 25).calculateExponentialMovingAvarage(list: samples)
            let ema99 = MovingAverage(period: 99).calculateExponentialMovingAvarage(list: samples)
            
            let rsi = RSI(period: 14)
            rsi.sampleList = samples
            let rsiResult = rsi.CalculateNormalRSI()
            
            let lowRsi = RSI(period: 14)
            lowRsi.sampleList = lowSamples
            let lowRsiResult = lowRsi.CalculateNormalRSI()
            
            let highRsi = RSI(period: 14)
            highRsi.sampleList = highSamples
            let highRsiResult = highRsi.CalculateNormalRSI()
            
            self.RSIValues = rsiResult.RSI
            self.candidateRSIValues(samples: samples, symbol: self.symbol)
            
            
            var candleValues:[[Any]] = [["Time","Low","Open","Close","High"]]
            var RSIValues:[[Any]] = [["Time","LowRSI","HighRSI"]]
            var stocRSIValues:[[Any]] = [["Time","SmoothD","SmoothK","SmoothT"]]
            var MAValues:[[Any]] = [["Time","Value"]]
            var crossMAValues:[[Any]] = [["Time","Value1","Value2"]]
            var EMAValues:[[Any]] = [["Time","Value1","Value2","Value3"]]

            let rsiDiff = candlesArray!.count - self.RSIValues.count
            let stocRSIDiff = candlesArray!.count - self.stocRSISmoothD.count
            let ema7Diff = candlesArray!.count - ema7.count
            let ema25Diff = candlesArray!.count - ema25.count
            let ema99Diff = candlesArray!.count - ema99.count

            for i in 0..<candlesArray!.count {
                let candle = candlesArray![i]
                let date = self.formatter.string(from: Date.init(timeIntervalSince1970: candle.closeTime! / 1000))
                
                candleValues.append([date,candle.low!.doubleValue,candle.open!.doubleValue,candle.close!.doubleValue,candle.high!.doubleValue])
                
                if i >= rsiDiff {
                    RSIValues.append([date, lowRsiResult.RSI[i - rsiDiff]!, highRsiResult.RSI[i - rsiDiff]!])
                } else {
                    RSIValues.append([date,50,50])
                }
                
                if i >= stocRSIDiff {
                    stocRSIValues.append([date,self.stocRSISmoothD[i - stocRSIDiff]!,self.stocRSISmoothK[i - stocRSIDiff]!,self.stocRSISmoothT[i - stocRSIDiff]!])
                } else {
                    stocRSIValues.append([date,50,50,50])
                }
                
                MAValues.append([date, ma9[i]!])
                
                crossMAValues.append([date, ma9[i]!, ma26[i]!])
                
                if i >= ema7Diff {
                    if i >= ema25Diff {
                        if i >= ema99Diff {
                            EMAValues.append([date, ema7[i - ema99Diff]!, ema25[i - ema99Diff]!, ema99[i - ema99Diff]!])
                        } else {
                            EMAValues.append([date, ema7[i - ema25Diff]!, ema25[i - ema25Diff]!, 0])
                        }
                    } else {
                        EMAValues.append([date, ema7[i - ema7Diff]!, 0, 0])
                    }
                } else {
                    EMAValues.append([date, 0, 0, 0])
                }
            }

//            RSIValues.appe
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
        }
    }
    
    
    private func candidateRSIValues(samples: [Double?], symbol: String) {
        
        let rsi = RSI(period:14)
        rsi.sampleList = samples
        let rsiResult = rsi.CalculateNormalRSI()
        
        let stoRSIResult = StochasticRSI(period: 12).calculateStochasticRSI(list: rsiResult.RSI)
        stocRSISmoothD = MovingAverage(period: 3).calculateSimpleMovingAvarage(list: stoRSIResult)
        stocRSISmoothK = MovingAverage(period: 3).calculateSimpleMovingAvarage(list: stocRSISmoothD)
        stocRSISmoothT = MovingAverage(period: 3).calculateSimpleMovingAvarage(list: stocRSISmoothK)
    }
    
    
}
