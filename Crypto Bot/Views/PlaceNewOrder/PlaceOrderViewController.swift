//
//  PlaceOrderViewController.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/7/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import UIKit

class PlaceOrderViewController: UIViewController {

    var tapRecognizer: UITapGestureRecognizer?
    var selectedTypeIndex: Int?
    var symbolObject: SymbolObject?
    
    let orderTypeValues = ["Limit","Market","Stop Limit","OCO"]
    let orderTypes = [OrderTypes.LIMIT,OrderTypes.MARKET,OrderTypes.STOP_LOSS_LIMIT,OrderTypes.OCO]
    
    @IBOutlet weak var symbolView: UIView! {
        didSet {
            self.tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(showSymbolsList))
            self.symbolView.isUserInteractionEnabled = true
            self.symbolView.addGestureRecognizer(self.tapRecognizer!)
        }
    }

    @IBOutlet weak var symbolLabel: UILabel! {
        didSet {
            self.symbolLabel.layer.borderColor = UIColor.textfieldBorderColor().cgColor
            self.symbolLabel.layer.borderWidth = 1
            self.symbolLabel.clipsToBounds = true
            self.symbolLabel.layer.cornerRadius = 4
        }
    }
    
    @IBOutlet weak var orderTypeTextfield: UITextField!
    
    @IBOutlet weak var buyButton: UIButton! {
        didSet {
            self.buyButton.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var sellButton: UIButton! {
        didSet {
            self.sellButton.layer.cornerRadius = 5
        }
    }
    
    var orderTypePickerView = ToolbarPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        orderTypePickerView.delegate = self
        orderTypePickerView.toolbarDelegate = self
        orderTypeTextfield.inputView = orderTypePickerView
        orderTypeTextfield.inputAccessoryView = orderTypePickerView.toolbar
        
        symbolObject = SymbolObject()
        symbolObject?.baseAsset = "ETH"
        symbolObject?.quoteAsset = "USDT"
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func buyButtonPressed(_ sender: Any) {
        showDetailViewWith(side: .BUY)
    }
    
    @IBAction func sellButtonPressed(_ sender: Any) {
        showDetailViewWith(side: .SELL)
    }
    
    func showDetailViewWith(side: OrderSide) {
        if let viewController = self.storyboard?.instantiateViewController(identifier: "PlaceNewOrderDetailViewController") as? PlaceNewOrderDetailViewController {
            viewController.symbol = self.symbolObject
            viewController.orderTpye = orderTypes[selectedTypeIndex ?? 0]
            viewController.orderSide = side
            navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    @objc func showSymbolsList() {
        
    }
    
}

extension PlaceOrderViewController: ToolbarPickerViewDelegate {
    func didTapDone(pickerView: ToolbarPickerView) {
        orderTypeTextfield.text = orderTypeValues[selectedTypeIndex ?? 0]
        orderTypeTextfield.resignFirstResponder()
    }
    
    func didTapCancel() {
        orderTypeTextfield.resignFirstResponder()
    }
    
    
}

extension PlaceOrderViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTypeIndex = row
    }
}

extension PlaceOrderViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return orderTypeValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return orderTypeValues[row]
    }
    
    
}
