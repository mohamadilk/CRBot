//
//  AccountManager.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/10/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation

class AccountHandler {
    
    static let shared = AccountHandler()
    
    func getCurrentUserCredit(response: @escaping(_ accountInfo: AccountInformation?, _ error: ApiError?) -> Swift.Void){
        AccountServices.shared.fetchAccountInformation(timestamp: NSDate().timeIntervalSince1970 * 1000) { (info, error) in
            guard error == nil else {
                response(nil, error)
                return
            }
            
            response(info, nil)
        }
    }
}
