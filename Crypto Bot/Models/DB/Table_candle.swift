//
//  DBHandler.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/26/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//
//

import Foundation
import SQLite


class Table_candle
{
    static let shared = Table_candle()
    
    //-- candle Table
    let candle = Table("candles")
    
    let id = Expression<Int64>("id")
    let openTime = Expression<Int64>("openTime")
    let open = Expression<String>("open")
    let high = Expression<String>("high")
    let low = Expression<String>("low")
    let close = Expression<String>("close")
    let volume = Expression<String>("volume")
    let closeTime = Expression<Int64>("closeTime")
    let quoteAssetVolume = Expression<String>("quoteAssetVolume")
    let numberOfTrades = Expression<Int64>("numberOfTrades")
    let takerBuyBaseAssetVolume = Expression<String>("takerBuyBaseAssetVolume")
    let takerBuyquoteAssetVolume = Expression<String>("takerBuyquoteAssetVolume")
    let ignore = Expression<String>("ignore")
    let interval = Expression<String>("interval")
    
    func initUserTable()
    {
        self.candle_createTable { (success) in }
    }
    
    //-- Create Table
    func candle_createTable(completionHandler : @escaping( Bool?) -> Void)
    {
        do
        {
            try DBHelper.shared.connectDB().run(candle.create { t in
                t.column(id, primaryKey: true)
                t.column(openTime)
                t.column(open)
                t.column(high)
                t.column(low)
                t.column(close)
                t.column(volume)
                t.column(closeTime)
                t.column(quoteAssetVolume)
                t.column(numberOfTrades)
                t.column(takerBuyBaseAssetVolume)
                t.column(takerBuyquoteAssetVolume)
                t.column(ignore)
                t.column(interval)
            })
            completionHandler(true)
        } catch {
            completionHandler(false)
        }
    }
    
    //-- Insert batch values into table
    func candle_insertBatch(candleObjects: [CandleObject], completionHandler : @escaping( Bool?) -> Void)
    {
        for candleObject in candleObjects {
            do
            {
                try DBHelper.shared.connectDB().run(candle.insert(
                    open <- candleObject.open!,
                    high <- candleObject.high!,
                    low <- candleObject.low!,
                    close <- candleObject.close!,
                    volume <- candleObject.volume!,
                    openTime <- Int64(candleObject.openTime!),
                    closeTime <- Int64(candleObject.closeTime!),
                    quoteAssetVolume <- candleObject.quoteAssetVolume!,
                    numberOfTrades <- Int64(candleObject.numberOfTrades!),
                    takerBuyBaseAssetVolume <- candleObject.takerBuyBaseAssetVolume!,
                    takerBuyquoteAssetVolume <- candleObject.takerBuyquoteAssetVolume!,
                    ignore <- candleObject.ignore!,
                    interval <- candleObject.interval
                ))
            }
            catch
            {
//                completionHandler(false)
                print("Error to insert user table")
                
            }
            
        }
        completionHandler(true)
    }
    //-- Insert values into table
    func candle_insert(candleObject: CandleObject, completionHandler : @escaping( Bool?) -> Void)
    {
        do
        {
            try DBHelper.shared.connectDB().run(candle.insert(
                open <- candleObject.open!,
                high <- candleObject.high!,
                low <- candleObject.low!,
                close <- candleObject.close!,
                volume <- candleObject.volume!,
                closeTime <- Int64(candleObject.closeTime!),
                quoteAssetVolume <- candleObject.quoteAssetVolume!,
                numberOfTrades <- Int64(candleObject.numberOfTrades!),
                takerBuyBaseAssetVolume <- candleObject.takerBuyBaseAssetVolume!,
                takerBuyquoteAssetVolume <- candleObject.takerBuyquoteAssetVolume!,
                ignore <- candleObject.ignore!,
                interval <- candleObject.interval
            ))
            completionHandler(true)
        }
        catch
        {
            completionHandler(true)
            print("Error to insert user table")
            
            //-- Update values into table
            //            self.user_update(candleObject: candleObject) { (success) in
            //                success == true ? completionHandler(true) : completionHandler(false)
            //            }
        }
    }
    
    //-- Get values from table
    func candle_get(timeInterval : String, before: Int64,completionHandler : @escaping([CandleObject], Bool?) -> Void)
    {
        let query = candle.filter(openTime < before && interval == timeInterval)
        var resultArray = [CandleObject]()
        do{
            for candleResult in try DBHelper.shared.connectDB().prepare(query) {
                let candleObject = CandleObject(openTime: TimeInterval(integerLiteral: candleResult[openTime]), open: candleResult[open], high: candleResult[high], low: candleResult[low], close: candleResult[close], volume: candleResult[volume], closeTime: TimeInterval(integerLiteral: candleResult[closeTime]), quoteAssetVolume: candleResult[quoteAssetVolume], numberOfTrades: Int(candleResult[numberOfTrades]), takerBuyBaseAssetVolume: candleResult[takerBuyBaseAssetVolume], takerBuyquoteAssetVolume: candleResult[takerBuyquoteAssetVolume], ignore: candleResult[ignore])
                resultArray.append(candleObject)
            }
            completionHandler(resultArray, true)
        }
        catch
        {
            completionHandler(resultArray, false)
        }
    }
    
    //-- Update values into table
    //    func user_update(valueDict: NSDictionary, completionHandler : @escaping( Bool?) -> Void)
    //    {
    //        let query = user.filter(user_username == (valueDict.object(forKey: "username") as! String))
    //
    //        //-- Get existing datas from table
    //        var resultRow : Row!
    //        self.user_getForEmail(forEmail: (valueDict.object(forKey: "username") as! String)) { (resultDict, rowData,  isSuccess) in
    //            resultRow = rowData
    //        }
    //
    //        //-- Update values in table
    //        do{
    //            try DBHelper.shared.connectDB().run(query.update(
    //                user_username <- (valueDict.object(forKey: "username") as? String) ?? resultRow[user_username],
    //                user_email <- (valueDict.object(forKey: "email") as? String) ?? resultRow[user_email]
    //            ))
    //            completionHandler(true)
    //        }
    //        catch{
    //            print("Error to update user table")
    //            completionHandler(false)
    //        }
    //    }
    
    
    //-- Update column into table
    //    func user_UpdateColumn()
    //    {
    //        do
    //        {
    //            try DBHelper.shared.connectDB().run(user.addColumn(Expression<String?>(user_mobile), defaultValue: ""))
    //            print("Column updated successfully in user table")
    //        } catch {
    //            print("Column update error in user table = \(error)")
    //        }
    //    }
    
    //-- Delete row from table
    //    func user_deleteDataForEmail(forEmail : String, completionHandler : @escaping( Bool?) -> Void)
    //    {
    //        let query = user.filter(user_username == forEmail)
    //
    //        do {
    //            if try DBHelper.shared.connectDB().run(query.delete()) > 0 {
    //                print("row deleted")
    //                completionHandler(true)
    //            } else {
    //                print("row not found")
    //                completionHandler(false)
    //            }
    //        } catch {
    //            print("delete failed: \(error)")
    //            completionHandler(false)
    //        }
    //    }
}

