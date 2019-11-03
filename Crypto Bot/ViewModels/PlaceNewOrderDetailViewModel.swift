//
//  PlaceNewOrderDetailViewModel.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/7/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import Foundation

class PlaceNewOrderDetailViewModel: NSObject {
    
    private var viewController: PlaceNewOrderDetailViewController!
    
    var timer: Timer?
    var symbol: SymbolObject?
    
    var latestBidPrice: String?
    var latestAskPrice: String?
    
    var valuesPerIndexDict = [Int: String]()
    
    var account: AccountInformation?
    
    init(viewController: PlaceNewOrderDetailViewController) {
        super.init()
        self.viewController = viewController
        AccountHandler.shared.getCurrentUserCredit { (account, error) in
            self.account = account
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
        
    }
    
}

extension PlaceNewOrderDetailViewModel: BaseTableViewCellDelegate {
    func textfieldValueChanged(index: Int, text: String) {
        addValue(number: text, for: index)
        let cell = viewController.datasource[index]
        switch cell.cellType {
        case .CellType_price:
            validatePriceAndUpdateOtherCells(cell: cell, value: text)
            break
        case .CellType_amount:
            validateAmountAndUpdateOtherCells(cell: cell, value: text)
            break
        case .CellType_addTarget:
            validateTargetFor(cell: cell, value: text)
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
        let priceCells = self.viewController.datasource.filter({ $0.cellType == .CellType_price })
        for cell in priceCells {
            validatePriceAndUpdateOtherCells(cell: cell as! PriceCell, value: (cell as! PriceCell).priceTextfield.text ?? "")
        }
    }
    
    private func validatePriceAndUpdateOtherCells(cell: BaseTableViewCell, value: String) {
        guard value != "" else {
            return
        }
        
        let priceCell = cell as! PriceCell
        
        switch priceCell.priceType {
        case .buyPrice:
            validateBuyPriceAndUpdateOtherCells(cell: priceCell, value: value)
            break
        case .buyStopPrice:
            validateBuyStopPriceAndUpdateOtherCells(cell: priceCell, value: value)
            break
        case .buyLimitPrice, .sellLimitPrice:
            validateLimitPriceAndUpdateOtherCells(cell: priceCell, value: value)
            break
        case .sellPrice:
            validateSellPriceAndUpdateOtherCells(cell: priceCell, value: value)
            break
        case .sellStopPrice:
            validateSellStopPriceAndUpdateOtherCells(cell: priceCell, value: value)
            break
        default:
            break
        }
    }
    
    private func validateBuyPriceAndUpdateOtherCells(cell: PriceCell, value: String) {
        switch self.viewController.orderTpye {
        case .LIMIT:
            self.changeState(cell: cell, isValid: self.valueIsInValidRange(value: value))
            if let amountCell = self.viewController.datasource.filter({ $0.cellType == .CellType_amount }).first as? AmountCell {
                if let amount = amountCell.amountTextfield.text {
                    self.updateTotalPriceCell(value: (value.doubleValue * amount.doubleValue).toString(), isVliad: amountCell.amountTextfield.isValid)
                }
            }
            break
        case .OCO:
            self.changeState(cell: cell, isValid: self.valueIsInValidRangeAndSmallerThanMarket(value: value))
            break
        default:
            break
        }
    }
    
    private func validateBuyStopPriceAndUpdateOtherCells(cell: PriceCell, value: String) {
        switch self.viewController.orderTpye {
        case .STOP_LOSS_LIMIT:
            self.changeState(cell: cell, isValid: self.valueIsInValidRange(value: value))
            break
        case .OCO:
            self.changeState(cell: cell, isValid: self.valueIsInValidRangeAndGraterThanMarket(value: value))
            break
        default:
            break
        }
    }
    
    private func validateLimitPriceAndUpdateOtherCells(cell: PriceCell, value: String) {
        switch self.viewController.orderTpye {
        case .OCO:
            self.changeState(cell: cell, isValid: self.valueIsInValidRange(value: value))
            if self.viewController.orderSide == .BUY {
                if let amountCell = self.viewController.datasource.filter({ $0.cellType == .CellType_amount }).first as? AmountCell {
                    if let amount = amountCell.amountTextfield.text {
                        self.updateTotalPriceCell(value: (value.doubleValue * amount.doubleValue).toString(), isVliad: amountCell.amountTextfield.isValid)
                    }
                }
            }
            break
        case .STOP_LOSS_LIMIT:
            self.changeState(cell: cell, isValid: self.valueIsInValidRange(value: value))
            if let amountCell = self.viewController.datasource.filter({ $0.cellType == .CellType_amount }).first as? AmountCell {
                if let amount = amountCell.amountTextfield.text {
                    self.updateTotalPriceCell(value: (value.doubleValue * amount.doubleValue).toString(), isVliad: amountCell.amountTextfield.isValid)
                }
            }
            break
        default:
            break
        }
    }
    
    private func validateSellPriceAndUpdateOtherCells(cell: PriceCell, value: String) {
        switch self.viewController.orderTpye {
        case .LIMIT:
            self.changeState(cell: cell, isValid: self.valueIsInValidRange(value: value))
            if let amountCell = self.viewController.datasource.filter({ $0.cellType == .CellType_amount }).first as? AmountCell {
                if let amount = amountCell.amountTextfield.text {
                    self.updateTotalPriceCell(value: (value.doubleValue * amount.doubleValue).toString(), isVliad: amountCell.amountTextfield.isValid)
                }
            }
            break
        case .OCO:
            self.changeState(cell: cell, isValid: self.valueIsInValidRangeAndGraterThanMarket(value: value))
            if let amountCell = self.viewController.datasource.filter({ $0.cellType == .CellType_amount }).first as? AmountCell {
                if let amount = amountCell.amountTextfield.text {
                    self.updateTotalPriceCell(value: (value.doubleValue * amount.doubleValue).toString(), isVliad: amountCell.amountTextfield.isValid)
                }
            }
            break
        default:
            break
        }
    }
    
    private func validateSellStopPriceAndUpdateOtherCells(cell: PriceCell, value: String) {
        switch self.viewController.orderTpye {
        case .STOP_LOSS_LIMIT:
            self.changeState(cell: cell, isValid: self.valueIsInValidRange(value: value))
            break
        case .OCO:
            self.changeState(cell: cell, isValid: self.valueIsInValidRangeAndSmallerThanMarket(value: value))
            break
        default:
            break
        }
    }
    
    private func validateAmountAndUpdateOtherCells(cell: BaseTableViewCell, value: String) {
        if self.viewController.orderSide == .SELL {
            changeState(cell: cell as! AmountCell, isValid: value.doubleValue < currentFreeBalance())
        } else {
            switch self.viewController.orderTpye {
            case .MARKET:
                let totalValue = value.doubleValue * (latestBidPrice?.doubleValue ?? 1)
                let isValid = (totalValue <= self.currentFreeBalance() && totalValue > 0)
                changeState(cell: cell as! AmountCell, isValid: isValid)
                updateTotalPriceCell(value: totalValue.toString(), isVliad: isValid)
                
                break
            case .LIMIT:
                if let priceCell = self.viewController.datasource[0] as? PriceCell {
                    let totalValue = value.doubleValue * (priceCell.priceTextfield.text?.doubleValue ?? 1)
                    let isValid = (totalValue <= self.currentFreeBalance() && totalValue > 0)
                    changeState(cell: cell as! AmountCell, isValid: isValid)
                    updateTotalPriceCell(value: totalValue.toString(), isVliad: isValid)
                }
                break
            case .STOP_LOSS_LIMIT:
                if let limitCell = self.viewController.datasource[2] as? PriceCell {
                    let totalValue = value.doubleValue * (limitCell.priceTextfield.text?.doubleValue ?? 1)
                    let isValid = (totalValue <= self.currentFreeBalance() && totalValue > 0)
                    changeState(cell: cell as! AmountCell, isValid: isValid)
                    updateTotalPriceCell(value: totalValue.toString(), isVliad: isValid)
                }
                break
            case .OCO:
                if let limitCell = self.viewController.datasource[4] as? PriceCell {
                    let totalValue = value.doubleValue * (limitCell.priceTextfield.text?.doubleValue ?? 1)
                    let isValid = (totalValue <= self.currentFreeBalance() && totalValue > 0)
                    changeState(cell: cell as! AmountCell, isValid: isValid)
                    updateTotalPriceCell(value: totalValue.toString(), isVliad: isValid)
                }
                break
            default:
                break
            }
        }
    }
    
    private func changeAmountTo(percent: Int) {
        let freeBalance = currentFreeBalance()
        let percentAmount = (freeBalance * Double(percent) / 100)
        
        if let amountCell = self.viewController.datasource.filter({ $0.cellType == .CellType_amount }).first as? AmountCell {
            switch self.viewController.orderSide {
            case .SELL:
                self.setAmountTextfiledTo(value: percentAmount.toString(), cell: amountCell)
                break
            case .BUY:
                switch self.viewController.orderTpye {
                case .MARKET:
                    self.setAmountTextfiledTo(value: (percentAmount / (self.latestAskPrice?.doubleValue ?? 1.0)).toString(), cell: amountCell)
                    break
                case .LIMIT:
                    if let priceCells = self.viewController.datasource.filter({ $0.cellType == .CellType_price }) as? [PriceCell] {
                        if let priceCell = priceCells.filter({ $0.priceType == .buyPrice }).first {
                            if let priceValue = priceCell.priceTextfield.text?.doubleValue, priceValue > 0 {
                                self.setAmountTextfiledTo(value: (percentAmount / priceValue).toString(), cell: amountCell)
                            }
                        }
                    }
                    break
                case .STOP_LOSS_LIMIT:
                    if let priceCells = self.viewController.datasource.filter({ $0.cellType == .CellType_price }) as? [PriceCell] {
                        if let limitCell = priceCells.filter({ $0.priceType == .buyLimitPrice }).first {
                            if let priceValue = limitCell.priceTextfield.text?.doubleValue,  priceValue > 0 {
                                self.setAmountTextfiledTo(value: (percentAmount / priceValue).toString(), cell: amountCell)
                            }
                        }
                    }

                    break
                case .OCO:
                    if let priceCells = self.viewController.datasource.filter({ $0.cellType == .CellType_price }) as? [PriceCell] {
                        if let limitCell = priceCells.filter({ $0.priceType == .buyLimitPrice }).first {
                            if let priceValue = limitCell.priceTextfield.text?.doubleValue,  priceValue > 0 {
                                self.setAmountTextfiledTo(value: (percentAmount / priceValue).toString(), cell: amountCell)
                            } else {
                                if let priceCell = priceCells.filter({ $0.priceType == .buyPrice }).first {
                                    if let priceValue = priceCell.priceTextfield.text?.doubleValue,  priceValue > 0 {
                                        self.setAmountTextfiledTo(value: (percentAmount / priceValue).toString(), cell: amountCell)
                                    }
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
    
    private func setAmountTextfiledTo(value: String, cell: AmountCell) {
        if let symbol = self.symbol?.symbol {
            NumbersUtilities.shared.formatted(quantity: value, for: symbol) { (value, error) in
                if error == nil, value != nil {
                    cell.amountTextfield.text = value
                }
            }
        }
    }
    
    private func updateTotalPriceCell(value: String, isVliad: Bool) {
        let priceCells = self.viewController.datasource.filter({ $0.cellType == .CellType_price }) as! [PriceCell]
        if let totalCell = priceCells.filter({ $0.priceType == .total }).first {
            totalCell.priceTextfield.text = value
            if isVliad {
                totalCell.priceTextfield.showValidState()
            } else {
                totalCell.priceTextfield.showInvalidState()
            }
        }
    }
    
    private func validateTargetFor(cell: BaseTableViewCell, value: String) {
        self.changeState(cell: cell as! AddTargetCell, isValid: self.valueIsInValidRange(value: value), value: value)
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
    
    private func changeState(cell: PriceCell, isValid: Bool) {
        if isValid {
            cell.priceTextfield.showValidState()
        } else {
            cell.priceTextfield.showInvalidState()
        }
    }
    
    private func changeState(cell: AmountCell, isValid: Bool) {
        if isValid {
            cell.amountTextfield.showValidState()
        } else {
            cell.amountTextfield.showInvalidState()
        }
    }
    
    private func changeState(cell: AddTargetCell, isValid: Bool, value: String) {
        if isValid {
            if isRationalTarget(value: value ) {
                cell.priceTextfield.showValidState()
            } else {
                cell.priceTextfield.showWarningState()
            }
        } else {
            cell.priceTextfield.showInvalidState()
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
                    return balance.free?.doubleValue ?? 0
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
