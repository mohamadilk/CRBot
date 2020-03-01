//
//  DBHepler.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/26/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//
//

import Foundation
import SQLite

class DBHelper
{
    static let shared = DBHelper()
    static let dbName : String = "maindb.sqlite3"
    
    func initDatabase()
    {
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        {
            let databasePath = documentsURL.appendingPathComponent(DBHelper.dbName).path
            if !fileManager.fileExists(atPath: databasePath) {
                fileManager.createFile(atPath: databasePath, contents: nil, attributes: nil)
            }
            
            //-- Create Table
            self.createTable()
        }
        
    }
    
    func createTable()
    {
        Table_candle.shared.initUserTable()
    }
    
    func getDBPath()->String
    {
        let fileManager = FileManager.default
        var databasePath : String = ""
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        {
            databasePath = documentsURL.appendingPathComponent(DBHelper.dbName).path
            if !fileManager.fileExists(atPath: databasePath) {
                fileManager.createFile(atPath: databasePath, contents: nil, attributes: nil)
            }
        }
        return databasePath
    }
    
    func connectDB() ->Connection
    {
        var db  = try? Connection(getDBPath())
        do
        {
            db = try Connection(getDBPath())
        } catch {
            print("DB Connection Error")
        }
        return db!
    }
}
