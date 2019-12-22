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
            updateSheetsData()
        }
    }
    
    private func updateSheetsData() {
        MarketDataServices.shared.fetchCandlestickData(symbol: symbol, interval: time_Frame.rawValue, limit: candle_Limits) { candlesArray, error in
            guard candlesArray != nil, error == nil else { return }
            
            var values = [[String]]()
            
            for candle in candlesArray! {
                values.append([self.formatter.string(from: Date.init(timeIntervalSince1970: candle.closeTime! / 1000)),candle.low!,candle.open!,candle.close!,candle.high!])
            }

            self.service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()

            let clearValues = GTLRSheets_ClearValuesRequest()
            let clearQuery = GTLRSheetsQuery_SpreadsheetsValuesClear.query(withObject: clearValues, spreadsheetId: self.spreadsheetId, range: "CANDLE")
            
            self.service.executeQuery(clearQuery) { (ticket, result, error) in
                guard error == nil else { return }
                
                 let valueRange = GTLRSheets_ValueRange()
                 valueRange.values = values
                 let appendQuery = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: valueRange, spreadsheetId: self.spreadsheetId, range: "CANDLE")
                 appendQuery.valueInputOption = kGTLRSheetsValueInputOptionRaw
                
                 self.service.executeQuery(appendQuery) { (ticket, result, error) in
                     print("")
                 }
            }
        }
    }
}
