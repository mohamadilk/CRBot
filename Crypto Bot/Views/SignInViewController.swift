//
//  SignInViewController.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 19.12.2019.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

class SignInViewController: UIViewController {

    @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(userSignedIn), name: NSNotification.Name(rawValue: "successfulySignedIn"), object: nil)

        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeSheetsSpreadsheets]
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
    }
    
    @objc func userSignedIn() {
        dismiss(animated: true, completion: nil)
        SheetsHandler.shared.startUpdatingSheets()
    }
}
