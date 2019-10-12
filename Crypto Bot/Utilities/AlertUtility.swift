//
//  AlertUtility.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/10/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import UIKit

class AlertUtility {
    
    static func showAlert(title: String, message: String? = nil) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction  = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alertView.addAction(okAction)
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            topController.present(alertView, animated: true, completion: nil)
        }
    }
}
