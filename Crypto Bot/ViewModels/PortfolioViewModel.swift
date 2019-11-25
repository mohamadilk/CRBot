//
//  PortfolioViewModel.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 9/3/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation

class PortfolioViewModel: NSObject {
    
    var viewController: PortfolioViewController!
    
    var datasource = [BalanceObject]()
    
    init(viewController: PortfolioViewController) {
        super.init()
        self.viewController = viewController
        AccountHandler.shared.getCurrentUserCredit { [weak self] (info, error) in
            guard error == nil, info != nil else {
                return
            }
            self?.datasource = info?.balances ?? []
            self?.viewController.reloadData()
        }
    }
}
