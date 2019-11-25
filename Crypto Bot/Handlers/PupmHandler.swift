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
    
    var preveiws: [String: String]?
    var current: [String: String]?
    
    var symbolPricesDict = [String: [String]]()
    var watchList: [String]?
    
    var finalApprovedArray: [String]?
}
