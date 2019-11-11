//
//  PlaceNewOrderDetailViewModel.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/7/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation

enum ValidityState {
    case valid
    case invalid
    case warning
}
class PlaceNewOrderDetailViewModel: NSObject {
    
    private var viewController: PlaceNewOrderDetailViewController!
    
    var timer: Timer?
    var symbol: SymbolObject?
    
    var latestBidPrice: String?
    var latestAskPrice: String?
    
    var valitityPerIndexDict = [Int: ValidityState]()
    
    var account: AccountInformation?
    
    init(viewController: PlaceNewOrderDetailViewController) {
        super.init()
        self.viewController = viewController
        self.updateUserBalance(response: { _ in })
    }
    
    func updateUserBalance(response: @escaping(_ success: Bool) -> Void) {
        AccountHandler.shared.getCurrentUserCredit { (account, error) in
            self.account = account
            response(error == nil)
        }
    }
    
    func initialUpdatePrices(symbol: SymbolObject) {
        self.symbol = symbol
        self.updateLatestPrice()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLatestPrice), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc func updateLatestPrice() {
        if let symbol = symbol {
            MarketDataHandler.shared.getLatestOrder(symbol: symbol) { (order, error) in
                if let order = order {
                    self.latestAskPrice = order.askPrice
                    self.latestBidPrice = order.bidPrice
                    
                    self.viewController.updateLatestDataWith(order: order)
                    self.validatePriceTextfields()
                }
            }
        }
    }
    
    func stopUpdatePrices() {
        timer?.invalidate()
    }
    
    private func addValue(number: String, for index: Int) {
        viewController.datasource[index].value = number
    }
    
    func validityStateFor(index: Int) -> ValidityState {
        return valitityPerIndexDict[index] ?? .invalid
    }
    
}

extension PlaceNewOrderDetailViewModel: BaseTableViewCellDelegate {
    func textfieldValueChanged(index: Int, text: String) {
        addValue(number: text, for: index)
        let cellModel = viewController.datasource[index]
        switch cellModel.cellType {
        case .CellType_price:
            validatePriceAndUpdateOtherCells(model: cellModel, value: text)
            break
        case .CellType_amount:
            validateAmountAndUpdateOtherCells(model: cellModel, value: text)
            break
        case .CellType_addTarget:
            validateTargetFor(model: cellModel, value: text)
            break
        default:
            break
        }
    }
    
    func amountChangedTo(percent: Int) {
        changeAmountTo(percent: percent)
    }
    
    
}

extension PlaceNewOrderDetailViewModel { //Validations
    
    func validatePriceTextfields() {
        let priceModels = self.viewController.datasource.filter({ $0.cellType == .CellType_price })
        for cellModel in priceModels {
            validatePriceAndUpdateOtherCells(model: cellModel, value: cellModel.value ?? "")
        }
    }
    
    private func validatePriceAndUpdateOtherCells(model: CellModel, value: String) {
        guard value != "" else {
            return
        }
        
        switch model.priceType {
        case .buyPrice:
            validateBuyPriceAndUpdateOtherCells(model: model, value: value)
            break
        case .buyStopPrice:
            validateBuyStopPriceAndUpdateOtherCells(model: model, value: value)
            break
        case .buyLimitPrice, .sellLimitPrice:
            validateLimitPriceAndUpdateOtherCells(model: model, value: value)
            break
        case .sellPrice:
            validateSellPriceAndUpdateOtherCells(model: model, value: value)
            break
        case .sellStopPrice:
            validateSellStopPriceAndUpdateOtherCells(model: model, value: value)
            break
        default:
            break
        }
    }
    
    private func validateBuyPriceAndUpdateOtherCells(model: CellModel, value: String) {
        switch self.viewController.orderTpye {
        case .LIMIT:
            self.changePriceState(model: model, isValid: self.valueIsInValidRange(value: value))
            let amountModels = self.viewController.datasource.filter({ $0.cellType == .CellType_amount })
            if let amount = amountModels.first?.value {
                self.updateTotalPriceCell(value: (value.doubleValue * amount.doubleValue).toString(), isVliad: amountModels.first?.isValid ?? false)
            }
            
            break
        case .OCO:
            self.changePriceState(model: model, isValid: self.valueIsInValidRangeAndSmallerThanMarket(value: value))
            let limitModels = self.viewController.datasource.filter({ $0.priceType == .buyLimitPrice })
            if limitModels.count > 0 {
                let limitModel = limitModels[0]
                if value.doubleValue > limitModel.value?.doubleValue ?? 0 {
                    let amountModels = self.viewController.datasource.filter({ $0.cellType == .CellType_amount })
                    if let amount = amountModels.first?.value {
                        self.updateTotalPriceCell(value: (value.doubleValue * amount.doubleValue).toString(), isVliad: amountModels.first?.isValid ?? false)
                    }
                }
            } else {
                let amountModels = self.viewController.datasource.filter({ $0.cellType == .CellType_amount })
                if let amount = amountModels.first?.value {
                    self.updateTotalPriceCell(value: (value.doubleValue * amount.doubleValue).toString(), isVliad: amountModels.first?.isValid ?? false)
                }
            }
            break
        default:
            break
        }
    }
    
    private func validateBuyStopPriceAndUpdateOtherCells(model: CellModel, value: String) {
        switch self.viewController.orderTpye {
        case .STOP_LOSS_LIMIT:
            self.changePriceState(model: model, isValid: self.valueIsInValidRange(value: value))
            break
        case .OCO:
            self.changePriceState(model: model, isValid: self.valueIsInValidRangeAndGraterThanMarket(value: value))
            break
        default:
            break
        }
    }
    
    private func validateLimitPriceAndUpdateOtherCells(model: CellModel, value: String) {
        switch self.viewController.orderTpye {
        case .OCO:
            self.changePriceState(model: model, isValid: self.valueIsInValidRange(value: value))
            if self.viewController.orderSide == .BUY {
                
                let priceModels = self.viewController.datasource.filter({ $0.priceType == .buyPrice })
                if priceModels.count > 0 {
                    let priceModel = priceModels[0]
                    if value.doubleValue > priceModel.value?.doubleValue ?? 0 {
                        let amountModels = self.viewController.datasource.filter({ $0.cellType == .CellType_amount })
                        if let amount = amountModels.first?.value {
                            self.updateTotalPriceCell(value: (value.doubleValue * amount.doubleValue).toString(), isVliad: amountModels.first?.isValid ?? false)
                        }
                    }
                } else {
                    let amountModels = self.viewController.datasource.filter({ $0.cellType == .CellType_amount })
                    if let amount = amountModels.first?.value {
                        self.updateTotalPriceCell(value: (value.doubleValue * amount.doubleValue).toString(), isVliad: amountModels.first?.isValid ?? false)
                    }
                }
            }
            break
        case .STOP_LOSS_LIMIT:
            self.changePriceState(model: model, isValid: self.valueIsInValidRange(value: value))
            let amountModels = self.viewController.datasource.filter({ $0.cellType == .CellType_amount })
            
            if let amount = amountModels.first?.value {
                self.updateTotalPriceCell(value: (value.doubleValue * amount.doubleValue).toString(), isVliad: amountModels.first?.isValid ?? false)
            }
            break
        default:
            break
        }
    }
    
    private func validateSellPriceAndUpdateOtherCells(model: CellModel, value: String) {
        switch self.viewController.orderTpye {
        case .LIMIT:
            self.changePriceState(model: model, isValid: self.valueIsInValidRange(value: value))
            let amountModels = self.viewController.datasource.filter({ $0.cellType == .CellType_amount })
            
            if let amount = amountModels.first?.value {
                self.updateTotalPriceCell(value: (value.doubleValue * amount.doubleValue).toString(), isVliad: amountModels.first?.isValid ?? false)
            }
            break
        case .OCO:
            self.changePriceState(model: model, isValid: self.valueIsInValidRangeAndGraterThanMarket(value: value))
            let amountModels = self.viewController.datasource.filter({ $0.cellType == .CellType_amount })
            
            if let amount = amountModels.first?.value {
                self.updateTotalPriceCell(value: (value.doubleValue * amount.doubleValue).toString(), isVliad: amountModels.first?.isValid ?? false)
            }
            break
        default:
            break
        }
    }
    
    private func validateSellStopPriceAndUpdateOtherCells(model: CellModel, value: String) {
        switch self.viewController.orderTpye {
        case .STOP_LOSS_LIMIT:
            self.changePriceState(model: model, isValid: self.valueIsInValidRange(value: value))
            break
        case .OCO:
            self.changePriceState(model: model, isValid: self.valueIsInValidRangeAndSmallerThanMarket(value: value))
            break
        default:
            break
        }
    }
    
    private func validateAmountAndUpdateOtherCells(model: CellModel, value: String) {
        if self.viewController.orderSide == .SELL {
            changeAmountState(model: model, isValid: value.doubleValue < currentFreeBalance())
        } else {
            switch self.viewController.orderTpye {
            case .MARKET:
                let totalValue = value.doubleValue * (latestBidPrice?.doubleValue ?? 1)
                let isValid = (totalValue <= self.currentFreeBalance() && totalValue > 0)
                changeAmountState(model: model, isValid: isValid)
                updateTotalPriceCell(value: totalValue.toString(), isVliad: isValid)
                
                break
            case .LIMIT:
                let priceModel = self.viewController.datasource[0]
                let totalValue = value.doubleValue * (priceModel.value?.doubleValue ?? 1)
                let isValid = (totalValue <= self.currentFreeBalance() && totalValue > 0)
                changeAmountState(model: model, isValid: isValid)
                updateTotalPriceCell(value: totalValue.toString(), isVliad: isValid)
                break
            case .STOP_LOSS_LIMIT:
                let limitModel = self.viewController.datasource[2]
                let totalValue = value.doubleValue * (limitModel.value?.doubleValue ?? 1)
                let isValid = (totalValue <= self.currentFreeBalance() && totalValue > 0)
                changeAmountState(model: model, isValid: isValid)
                updateTotalPriceCell(value: totalValue.toString(), isVliad: isValid)
                break
            case .OCO:
                let priceModel = self.viewController.datasource[0]
                let limitModel = self.viewController.datasource[4]

                if limitModel.value?.doubleValue ?? 0 > priceModel.value?.doubleValue ?? 0 {
                    let totalValue = value.doubleValue * (limitModel.value?.doubleValue ?? 1)
                    let isValid = (totalValue <= self.currentFreeBalance() && totalValue > 0)
                    changeAmountState(model: model, isValid: isValid)
                    updateTotalPriceCell(value: totalValue.toString(), isVliad: isValid)
                } else {
                    if priceModel.value?.doubleValue ?? 0 > 0 {
                        let totalValue = value.doubleValue * (priceModel.value?.doubleValue ?? 1)
                        let isValid = (totalValue <= self.currentFreeBalance() && totalValue > 0)
                        changeAmountState(model: model, isValid: isValid)
                        updateTotalPriceCell(value: totalValue.toString(), isVliad: isValid)
                    }
                }

                break
            default:
                break
            }
        }
    }
    
    private func changeAmountTo(percent: Int) {
        let freeBalance = currentFreeBalance()
        let percentAmount = (freeBalance * Double(percent)  * 0.999 / 100)
        if let amountModel = self.viewController.datasource.filter({ $0.cellType == .CellType_amount }).first {
            switch self.viewController.orderSide {
            case .SELL:
                self.setAmountTextfiledTo(value: percentAmount.toString(), index: amountModel.index)
                break
            case .BUY:
                switch self.viewController.orderTpye {
                case .MARKET:
                    self.setAmountTextfiledTo(value: (percentAmount / (self.latestAskPrice?.doubleValue ?? 1.0)).toString(), index: amountModel.index)
                    break
                case .LIMIT:
                    let priceModels = self.viewController.datasource.filter({ $0.cellType == .CellType_price })
                    if let priceModel = priceModels.filter({ $0.priceType == .buyPrice }).first {
                        if let priceValue = priceModel.value?.doubleValue, priceValue > 0 {
                            self.setAmountTextfiledTo(value: (percentAmount / priceValue).toString(), index: amountModel.index)
                        }
                    }
                    
                    break
                case .STOP_LOSS_LIMIT:
                    let priceModels = self.viewController.datasource.filter({ $0.cellType == .CellType_price })
                    if let priceModel = priceModels.filter({ $0.priceType == .buyLimitPrice }).first {
                        if let priceValue = priceModel.value?.doubleValue, priceValue > 0 {
                            self.setAmountTextfiledTo(value: (percentAmount / priceValue).toString(), index: amountModel.index)
                        }
                    }
                    
                    break
                case .OCO:
                    let priceModels = self.viewController.datasource.filter({ $0.cellType == .CellType_price })
                    if let priceModel = priceModels.filter({ $0.priceType == .buyLimitPrice }).first {
                        if let priceValue = priceModel.value?.doubleValue, priceValue > 0 {
                            self.setAmountTextfiledTo(value: (percentAmount / priceValue).toString(), index: amountModel.index)
                        } else {
                            if let priceModel = priceModels.filter({ $0.priceType == .buyPrice }).first {
                                if let priceValue = priceModel.value?.doubleValue, priceValue > 0 {
                                    self.setAmountTextfiledTo(value: (percentAmount / priceValue).toString(), index: amountModel.index)
                                }
                            }
                        }
                        
                    }
                    
                    break
                default:
                    break
                }
                break
            default:
                break
            }
        }
    }
    
    private func setAmountTextfiledTo(value: String, index: Int) {
        if let symbol = self.symbol?.symbol {
            NumbersUtilities.shared.formatted(quantity: value, for: symbol) { [weak self] (value, error) in
                if error == nil, value != nil {
                    if let amountCell =  self?.viewController.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? AmountCell {
                        amountCell.amountTextfield.text = value
                        
                    }
                    self?.addValue(number: value!, for: index)
                    self?.validateAmountAndUpdateOtherCells(model: (self?.viewController.datasource[index])!, value: value!)
                }
            }
        }
    }
    
    private func updateTotalPriceCell(value: String, isVliad: Bool) {
        let priceCells = self.viewController.datasource.filter({ $0.cellType == .CellType_price })
        if let totalModel = priceCells.filter({ $0.priceType == .total }).first {
            let totalCell = self.viewController.tableView.cellForRow(at: IndexPath(row: totalModel.index, section: 0)) as? PriceCell
            NumbersUtilities.shared.formatted(price: value, for: self.symbol!.symbol!, result: { [weak self] (totalVlaue, error) in
                DispatchQueue.main.async {
                    totalCell?.priceTextfield.text =  totalVlaue
                    
                    self?.addValue(number: value, for: totalModel.index)
                    totalModel.isValid = isVliad
                    if isVliad {
                        totalCell?.priceTextfield.showValidState()
                        self?.valitityPerIndexDict[totalModel.index] = .valid
                    } else {
                        totalCell?.priceTextfield.showInvalidState()
                        self?.valitityPerIndexDict[totalModel.index] = .invalid
                    }
                }
            })
        }
    }
    
    private func validateTargetFor(model: CellModel, value: String) {
        self.changeAddTargetState(model: model, isValid: self.valueIsInValidRange(value: value), value: value)
    }
    
    private func valueIsInValidRange(value: String) -> Bool {
        guard let percentFilter = self.symbol?.filters?.filter({ $0.filterType == .PERCENT_PRICE }).first else {
            return true
        }
        
        if value.doubleValue > ((percentFilter.multiplierDown?.doubleValue ?? 1) * (self.latestBidPrice?.doubleValue ?? 1)) &&
            value.doubleValue < ((percentFilter.multiplierUp?.doubleValue ?? 1) * (self.latestBidPrice?.doubleValue ?? 1)) {
            return true
        }
        return false
    }
    
    private func valueIsInValidRangeAndGraterThanMarket(value: String) -> Bool {
        guard let percentFilter = self.symbol?.filters?.filter({ $0.filterType == .PERCENT_PRICE }).first else {
            return true
        }
        if value.doubleValue < ((percentFilter.multiplierUp?.doubleValue ?? 1) * (self.latestBidPrice?.doubleValue ?? 1)) && value.doubleValue > (self.latestBidPrice?.doubleValue ?? 1)  {
            return true
        }
        return false
    }
    
    private func valueIsInValidRangeAndSmallerThanMarket(value: String) -> Bool {
        guard let percentFilter = self.symbol?.filters?.filter({ $0.filterType == .PERCENT_PRICE }).first else {
            return true
        }
        if value.doubleValue > ((percentFilter.multiplierDown?.doubleValue ?? 1) * (self.latestBidPrice?.doubleValue ?? 1)) && value.doubleValue < (self.latestBidPrice?.doubleValue ?? 1)  {
            return true
        }
        return false
    }
    
    private func changePriceState(model: CellModel, isValid: Bool) {
        let cell = viewController.tableView.cellForRow(at: IndexPath(row: model.index, section: 0)) as? PriceCell
        model.isValid = isValid
        if isValid {
            cell?.priceTextfield.showValidState()
            valitityPerIndexDict[model.index] = .valid
        } else {
            cell?.priceTextfield.showInvalidState()
            valitityPerIndexDict[model.index] = .invalid
        }
    }
    
    private func changeAmountState(model: CellModel, isValid: Bool) {
        let cell = viewController.tableView.cellForRow(at: IndexPath(row: model.index, section: 0)) as? AmountCell
        model.isValid = isValid
        if isValid {
            cell?.amountTextfield.showValidState()
            valitityPerIndexDict[model.index] = .valid
        } else {
            cell?.amountTextfield.showInvalidState()
            valitityPerIndexDict[model.index] = .invalid
        }
    }
    
    private func changeAddTargetState(model: CellModel, isValid: Bool, value: String) {
        let cell = viewController.tableView.cellForRow(at: IndexPath(row: model.index, section: 0)) as? AddTargetCell
        model.isValid = isValid
        if isValid {
            if isRationalTarget(value: value ) {
                cell?.priceTextfield.showValidState()
                valitityPerIndexDict[model.index] = .valid
            } else {
                cell?.priceTextfield.showWarningState()
                valitityPerIndexDict[model.index] = .warning
            }
        } else {
            cell?.priceTextfield.showInvalidState()
            valitityPerIndexDict[model.index] = .invalid
        }
    }
    
    private func isRationalTarget(value: String) -> Bool {
        if value.doubleValue > latestBidPrice?.doubleValue ?? 0 {
            return true
        }
        return false
    }
    
    private func currentFreeBalance() -> Double {
        if let account = self.account {
            if self.viewController.orderSide == .SELL {
                if let balance = account.balances?.filter({ $0.asset == self.symbol?.baseAsset ?? "" }).first {
                    return balance.free?.doubleValue ?? 0
                }
            } else {
                if let balance = account.balances?.filter({ $0.asset == self.symbol?.quoteAsset ?? "" }).first {
                    return (balance.free?.doubleValue ?? 0) * 0.999
                }
            }
        }
        return 0
    }
    
}

extension PlaceNewOrderDetailViewModel { //Place Order
    
    func setTargetsAndPlaceNewOrder(targets: [String]?, type: OrderTypes, asset: String, currency: String, side: OrderSide, amount: String, price: String? = nil, buyStopPrice: String? = nil, buyStopLimitPrice: String? = nil, sellStopPrice: String? = nil, sellStopLimitPrice: String? = nil, response: @escaping(_ order: OrderResponseObject?, _ error: String?) -> Swift.Void) {
        
        OrderHandler.shared.addPricesForSymbol(symbol: "\(asset)\(currency)", targetsArray: targets, stopPrice: sellStopPrice, stopLimitPrice: sellStopLimitPrice)
        
        OrderHandler.shared.placeNewOrderWith(type: type, asset: asset, currency: currency, side: side, amount: amount, price: price, stopPrice: (side == .SELL) ? sellStopPrice : buyStopPrice, stopLimitPrice: (side == .SELL) ? sellStopLimitPrice : buyStopLimitPrice) { (result, error) in
            response(result, error)
            AccountHandler.shared.getCurrentUserCredit { (account, error) in
                self.account = account
            }
        }
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

extension String {
    static let numberFormatter = NumberFormatter()
    var doubleValue: Double {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        return 0
    }
    
    var decimalValue: String {
        return self.replacingOccurrences(of: ",", with: ".")
    }
}
