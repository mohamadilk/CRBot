//
//  PlaceNewOrderViewController.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/10/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import UIKit

class PlaceNewOrderViewController: UIViewController {
    
    @IBOutlet weak var orderTypeTextfield: UITextField!
    @IBOutlet weak var assetTextfield: UITextField!
    @IBOutlet weak var sideTextfield: UITextField!
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var priceTextfield: UITextField! {
        didSet {
            priceTextfield.delegate = self
            priceTextfield.keyboardType = .decimalPad
        }
    }
    
    @IBOutlet weak var stopPriceTextfield: UITextField! {
        didSet {
            stopPriceTextfield.delegate = self
            stopPriceTextfield.keyboardType = .decimalPad
        }
    }
    
    @IBOutlet weak var stopLimitPriceTextfield: UITextField! {
        didSet {
            stopLimitPriceTextfield.delegate = self
            stopLimitPriceTextfield.keyboardType = .decimalPad
        }
    }
    
    @IBOutlet weak var percentageTextfield: UITextField!
    
    
    @IBOutlet weak var assetLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var sideLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var stopPriceLabel: UILabel!
    @IBOutlet weak var stopLimitPriceLabel: UILabel!
    @IBOutlet weak var quantityValueLabel: UILabel!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    var orderTypePickerView = ToolbarPickerView()
    var assetPickerView = ToolbarPickerView()
    var currencyPickerView = ToolbarPickerView()
    var sidePickerView = ToolbarPickerView()
    var percentagePickerView = ToolbarPickerView()
    
    let percentValues = ["25","50","75","100"]
    let sideValues = [OrderSide.BUY.rawValue,OrderSide.SELL.rawValue]
    let orderTypeValues = [OrderTypes.LIMIT.rawValue,OrderTypes.MARKET.rawValue,OrderTypes.STOP_LOSS.rawValue,OrderTypes.STOP_LOSS_LIMIT.rawValue,OrderTypes.TAKE_PROFIT.rawValue,OrderTypes.TAKE_PROFIT_LIMIT.rawValue,OrderTypes.LIMIT_MAKER.rawValue,OrderTypes.OCO.rawValue,]
    
    var symbolObjects = [SymbolObject]()
    var symbolsArray = [String]()
    var assetValues = [String]()
    var currencyValues = [String]()
    var textfieldsArray = [UITextField]()
    
    var selectedTypeIndex: Int?
    var selectedAssetIndex: Int?
    var selectedCurrencyIndex: Int?
    var selectedSideIndex: Int?
    var selectedPercentageIndex: Int?
    
    var viewModel: PlaceNewOrderViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = PlaceNewOrderViewModel(viewController: self)
        GeneralServices.shared.exchangeInformation { (result, error) in
            guard error == nil else { return }
            self.symbolObjects = result?.symbols ?? []
            
            for symbol in self.symbolObjects {
                self.assetValues.append(symbol.baseAsset ?? "")
                self.assetValues.sort()
                
                self.currencyValues.append(symbol.quoteAsset ?? "")
                self.currencyValues.sort()
                
                self.symbolsArray.append(symbol.symbol ?? "")
            }
            
            self.assetValues = self.assetValues.unique{ $0 }
            self.currencyValues = self.currencyValues.unique{ $0 }
            
        }
        
        textfieldsArray = [orderTypeTextfield, assetTextfield, currencyTextField, sideTextfield, percentageTextfield, orderTypeTextfield, stopPriceTextfield, stopLimitPriceTextfield, priceTextfield]
        confirmButton.isEnabled = false
        confirmButton.alpha = 0.5
        updateUiInitialState()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOnScreen))
        self.view.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initalTextfields()
        
        
        viewModel.checkQuantityAndPlaceNewOrder(type: .OCO, asset: "ETH", currency: "BTC", side: .SELL, percentage: "50", price: "0.021850", stopPrice: "0.021740", stopLimitPrice: "0.021750") { (responseObject, error) in

            if responseObject != nil {
                AlertUtility.showAlert(title: "Successfully placed new order!")
            } else {
                AlertUtility.showAlert(title: error!)
            }
        }
//
//        viewModel.checkQuantityAndPlaceNewOrder(type: .OCO, asset: "ETH", currency: "BTC", side: .BUY, percentage: "100", price: "0.021700", stopPrice: "0.022000", stopLimitPrice: "0.022010") { (responseObject, error) in
//
//            if responseObject != nil {
//                AlertUtility.showAlert(title: "Successfully placed new order!")
//            } else {
//                AlertUtility.showAlert(title: error!)
//            }
//        }
//        viewModel.checkQuantityAndPlaceNewOrder(type: .OCO, asset: "LINK", currency: "BTC", side: .BUY, percentage: "25", price: "0.00030500") { (responseObject, error) in
//
//            if responseObject != nil {
//                AlertUtility.showAlert(title: "Successfully placed new order!")
//            } else {
//                AlertUtility.showAlert(title: error!)
//            }
//        }
        


    }
    
    func initalTextfields() {
        
        
        orderTypePickerView.delegate = self
        orderTypePickerView.toolbarDelegate = self
        orderTypeTextfield.inputView = orderTypePickerView
        orderTypeTextfield.inputAccessoryView = orderTypePickerView.toolbar
        
        assetPickerView.delegate = self
        assetPickerView.toolbarDelegate = self
        assetTextfield.inputView = assetPickerView
        assetTextfield.inputAccessoryView = assetPickerView.toolbar
        
        currencyPickerView.delegate = self
        currencyPickerView.toolbarDelegate = self
        currencyTextField.inputView = currencyPickerView
        currencyTextField.inputAccessoryView = currencyPickerView.toolbar
        
        sidePickerView.delegate = self
        sidePickerView.toolbarDelegate = self
        sideTextfield.inputView = sidePickerView
        sideTextfield.inputAccessoryView = sidePickerView.toolbar
        
        percentagePickerView.delegate = self
        percentagePickerView.toolbarDelegate = self
        percentageTextfield.inputView = percentagePickerView
        percentageTextfield.inputAccessoryView = percentagePickerView.toolbar
        
        textfieldsArray.forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .allEvents) })
    }
    
    func updateUiInitialState() {
        assetTextfield.alpha = 0
        currencyTextField.alpha = 0
        sideTextfield.alpha = 0
        priceTextfield.alpha = 0
        stopPriceTextfield.alpha = 0
        stopLimitPriceTextfield.alpha = 0
        assetLabel.alpha = 0
        currencyLabel.alpha = 0
        sideLabel.alpha = 0
        priceLabel.alpha = 0
        stopPriceLabel.alpha = 0
        stopLimitPriceLabel.alpha = 0
    }
    
    func updateUi(type: OrderTypes) {
        
        UIView.animate(withDuration: 0.4) {
            self.assetTextfield.alpha = 1
            self.currencyTextField.alpha = 1
            self.sideTextfield.alpha = 1
            self.assetLabel.alpha = 1
            self.currencyLabel.alpha = 1
            self.sideLabel.alpha = 1
        }
        
        switch type {
        case .LIMIT:
            setComponentsAlpha(price: 1, stop: 0, stopLimit: 0)
            break
            
        case .LIMIT_MAKER:
            setComponentsAlpha(price: 1, stop: 0, stopLimit: 0)
            break
            
        case .MARKET:
            setComponentsAlpha(price: 0, stop: 0, stopLimit: 0)
            break
            
        case .STOP_LOSS:
            setComponentsAlpha(price: 0, stop: 1, stopLimit: 0)
            break
            
        case .STOP_LOSS_LIMIT:
            setComponentsAlpha(price: 1, stop: 1, stopLimit: 0)
            break
            
        case .TAKE_PROFIT:
            setComponentsAlpha(price: 0, stop: 1, stopLimit: 0)
            break
            
        case .TAKE_PROFIT_LIMIT:
            setComponentsAlpha(price: 1, stop: 1, stopLimit: 0)
            break
            
        case .OCO:
            setComponentsAlpha(price: 1, stop: 1, stopLimit: 1)
            break
        }
    }
    
    func setComponentsAlpha(price: CGFloat, stop: CGFloat, stopLimit: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            self.priceTextfield.alpha = price
            self.priceLabel.alpha = price
            self.stopPriceLabel.alpha = stop
            self.stopPriceTextfield.alpha = stop
            self.stopLimitPriceTextfield.alpha = stopLimit
            self.stopLimitPriceLabel.alpha = stopLimit
            
            self.priceTextfield.isHidden = !Bool(truncating: price as NSNumber)
            self.priceLabel.isHidden = !Bool(truncating: price as NSNumber)
            self.stopPriceLabel.isHidden = !Bool(truncating: stop as NSNumber)
            self.stopPriceTextfield.isHidden = !Bool(truncating: stop as NSNumber)
            self.stopLimitPriceTextfield.isHidden = !Bool(truncating: stopLimit as NSNumber)
            self.stopLimitPriceLabel.isHidden = !Bool(truncating: stopLimit as NSNumber)
        }
    }
    
    @objc func editingChanged(_ textField: UITextField) {

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for textfield in self.textfieldsArray {
                if textfield.isHidden == false, (textfield.text == nil || textfield.text == "") {
                    self.confirmButton.isEnabled = false
                    return
                }
            }

            self.confirmButton.isEnabled = true
        }
        if textField == currencyTextField || textField == percentageTextfield || textField == priceTextfield || textField == assetTextfield || textField == sideTextfield {
            if let currency = currencyTextField.text, currency.count > 0, let asset = assetTextfield.text, asset.count > 0, let percentage = percentageTextfield.text, percentage.count > 0, let price = priceTextfield.text, price.count > 0, let side = sideTextfield.text, side.count > 0 {
                
                var baseAsset: String = ""
                var quoteAsset: String = ""
                
                if side == OrderSide.BUY.rawValue {
                    baseAsset = asset
                    quoteAsset = currency
                } else {
                    baseAsset = currency
                    quoteAsset = asset
                }
                
                OrderHandler.shared.quantityFor(asset: asset, currency: currency, baseAssset: baseAsset, quoteAsset: quoteAsset, side: OrderSide(rawValue: side)!, percent: percentage, price: price) { (quantity, error) in
                    guard error == nil else { return }
                    self.quantityValueLabel.text = "\(quantity ?? 0)"
                }
            }
        }
        
        
    }
    
    @objc func tappedOnScreen() {
        for textfield in self.textfieldsArray {
            textfield.resignFirstResponder()
        }
    }

    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        
        if !symbolsArray.contains("\(assetTextfield?.text ?? "")\(currencyTextField?.text ?? "")") {
            AlertUtility.showAlert(title: "Not a valid pair!")
            return
        }
                
        viewModel.checkQuantityAndPlaceNewOrder(type: OrderTypes(rawValue: orderTypeTextfield?.text ?? "")!, asset: assetTextfield?.text ?? "", currency: currencyTextField?.text ?? "", side: OrderSide(rawValue: sideTextfield?.text ?? "")!, percentage: percentageTextfield?.text ?? "100", price: priceTextfield.text, stopPrice: stopPriceTextfield.text , stopLimitPrice: stopLimitPriceTextfield?.text) { (responseObject, error) in
            
            if responseObject != nil {
                AlertUtility.showAlert(title: "Successfully placed new order!")
            } else {
                AlertUtility.showAlert(title: error!)
            }
        }
    }
    
}

extension PlaceNewOrderViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension PlaceNewOrderViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView {
        case orderTypePickerView:
            selectedTypeIndex = row
            break
        case assetPickerView:
            selectedAssetIndex = row
            break
        case currencyPickerView:
            selectedCurrencyIndex = row
            break
        case sidePickerView:
            selectedSideIndex = row
            break
        case percentagePickerView:
            selectedPercentageIndex = row
            break
        default:
            break
        }
    }        
    
}


extension PlaceNewOrderViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case orderTypePickerView:
            return orderTypeValues.count
            
        case assetPickerView:
            return assetValues.count
            
        case currencyPickerView:
            return currencyValues.count
           
        case sidePickerView:
            return sideValues.count
            
        case percentagePickerView:
            return percentValues.count
            
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case orderTypePickerView:
            return orderTypeValues[row]
            
        case assetPickerView:
            return assetValues[row]
            
        case currencyPickerView:
            return currencyValues[row]
            
        case sidePickerView:
            return sideValues[row]
            
        case percentagePickerView:
            return percentValues[row]
            
        default:
            return ""
        }
    }
}

extension PlaceNewOrderViewController: ToolbarPickerViewDelegate {
    func didTapDone(pickerView: ToolbarPickerView) {
        switch pickerView {
               case orderTypePickerView:
                   orderTypeTextfield.text = orderTypeValues[selectedTypeIndex ?? 0]
                   orderTypeTextfield.resignFirstResponder()
                   updateUi(type: OrderTypes(rawValue: orderTypeValues[selectedTypeIndex ?? 0])!)
                   break
               case assetPickerView:
                   assetTextfield.text = assetValues[selectedAssetIndex ?? 0]
                   assetTextfield.resignFirstResponder()
                   break
               case currencyPickerView:
                   currencyTextField.text = currencyValues[selectedCurrencyIndex ?? 0]
                   currencyTextField.resignFirstResponder()
                   break
               case sidePickerView:
                   sideTextfield.text = sideValues[selectedSideIndex ?? 0]
                   sideTextfield.resignFirstResponder()
                   break
               case percentagePickerView:
                   percentageTextfield.text = percentValues[selectedPercentageIndex ?? 0]
                   percentageTextfield.resignFirstResponder()
                   break
               default:
                   break
               }
    }
    
    func didTapCancel() {
        
    }
    
    
}

extension Array {
    func unique<T:Hashable>(map: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }

        return arrayOrdered
    }
}
