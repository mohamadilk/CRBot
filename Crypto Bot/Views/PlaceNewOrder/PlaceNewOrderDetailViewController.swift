//
//  PlaceNewOrderDetailViewController.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/28/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import UIKit

class PlaceNewOrderDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton! {
        didSet {
            self.submitButton.clipsToBounds = true
            self.submitButton.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var bidPrice: UILabel! {
        didSet {
            self.bidPrice.textColor = UIColor.binanceGreenColor()
        }
    }
    @IBOutlet weak var askPrice: UILabel! {
        didSet {
            self.askPrice.textColor = UIColor.binanceRedColor()
        }
    }
    
    @IBOutlet weak var bidQuantity: UILabel!
    @IBOutlet weak var askQuantity: UILabel!
    
    @IBOutlet weak var loadingView: AMDots!
    
    var datasource = [BaseTableViewCell]()
    var orderTpye: OrderTypes!
    var orderSide: OrderSide!
    var symbol: SymbolObject!
    
    let priceDescriptionsDic = [PriceCellTypes.buyPrice: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud adipiscing elit, exercitation",
                                PriceCellTypes.sellPrice: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud adipiscing elit, exercitation",
                                PriceCellTypes.total: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud adipiscing elit, exercitation",
                                PriceCellTypes.buyStopPrice: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud adipiscing elit, exercitation",
                                PriceCellTypes.sellStopPrice: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud adipiscing elit, exercitation",
                                PriceCellTypes.buyLimitPrice: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud adipiscing elit, exercitation",
                                PriceCellTypes.sellLimitPrice: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud adipiscing elit, exercitation",]
    
    
    var descriptionsDic = [CellType.CellType_switch: "Lorem ipsum dolor sit amet, consectetur sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation",
                           CellType.CellType_amount: "Lorem ipsum dolor sit amet, quis nostrud exercitation, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation",
                           CellType.CellType_addTarget: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"]
    
    var viewModel: PlaceNewOrderDetailViewModel!
    
    let numberFormatter = NumberFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = PlaceNewOrderDetailViewModel(viewController: self)
        registerCells()
        prepareDataSource()
        setNavigationTitle()
        setSubmitButton()
        
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingView.start()
        viewModel.initialUpdatePrices(symbol: symbol)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopUpdatePrices()
    }
    
    private func registerCells() {
        tableView.register(UINib(nibName: "PriceCell", bundle: nil), forCellReuseIdentifier: "PriceCell")
        tableView.register(UINib(nibName: "AmountCell", bundle: nil), forCellReuseIdentifier: "AmountCell")
        tableView.register(UINib(nibName: "SwitchCell", bundle: nil), forCellReuseIdentifier: "SwitchCell")
        tableView.register(UINib(nibName: "DescriptionCell", bundle: nil), forCellReuseIdentifier: "DescriptionCell")
        tableView.register(UINib(nibName: "AddTargetCell", bundle: nil), forCellReuseIdentifier: "AddTargetCell")
        tableView.register(UINib(nibName: "TargetsCell", bundle: nil), forCellReuseIdentifier: "TargetsCell")
    }
    
    private func setNavigationTitle() {
        switch orderTpye {
        case .MARKET:
            self.title = "Market Order"
            break
        case .LIMIT:
            self.title = "Limit Order"
            break
        case .STOP_LOSS_LIMIT:
            self.title = "Stop Limit Order"
            break
        case .OCO:
            self.title = "OCO Order"
            break
        default:
            break
        }
    }
    
    private func setSubmitButton() {
        
        if (orderSide == .SELL) {
            submitButton.backgroundColor = UIColor.binanceRedColor()
            submitButton.setTitle("Sell \(symbol.baseAsset ?? "")", for: .normal)
        } else {
            submitButton.backgroundColor = UIColor.binanceGreenColor()
            submitButton.setTitle("Buy \(symbol.baseAsset ?? "")", for: .normal)
        }
    }
    
    @IBAction func submitOrder(_ sender: UIButton) {
        var targetsArray: Array<String>?
        
        var amount = "0"
        var price: String?
        var buyStopPrice: String?
        var buyStopLimitPrice: String?
        var sellStopPrice: String?
        var sellStopLimitPrice: String?

        for cell in self.datasource {
            switch cell.cellType {
            case .CellType_price:
                let priceCell = cell as! PriceCell
                switch priceCell.priceType {
                case .buyPrice, .sellPrice:
                    price = priceCell.priceTextfield.text ?? "0"
                    break
                case .buyStopPrice:
                    buyStopPrice = priceCell.priceTextfield.text ?? "0"
                    break
                case .buyLimitPrice:
                    buyStopLimitPrice = priceCell.priceTextfield.text ?? "0"
                    break
                case .sellStopPrice:
                    sellStopPrice = priceCell.priceTextfield.text ?? "0"
                    break
                case .sellLimitPrice:
                    sellStopLimitPrice = priceCell.priceTextfield.text ?? "0"
                    break
                default:
                    break
                }
                break
            case .CellType_amount:
                let amountCell = cell as! AmountCell
                amount = amountCell.amountTextfield.text ?? "0"
                break
            default:
                break
            }
        }
        
        if let targetsCell = self.datasource.filter({ $0.cellType == .CellType_targets }).first as? TargetsCell {
            if targetsCell.targetsArray.count > 0 {
                targetsArray = targetsCell.targetsArray
            }
        }
        
        self.viewModel.setTargetsAndPlaceNewOrder(targets: targetsArray, type: orderTpye, asset: symbol.baseAsset!, currency: symbol.quoteAsset!, side: orderSide, amount: amount, price: price, buyStopPrice: buyStopPrice, buyStopLimitPrice: buyStopLimitPrice, sellStopPrice: sellStopPrice, sellStopLimitPrice: sellStopLimitPrice) { (response, error) in
            if error != nil {
                AlertUtility.showAlert(title: error!)
                return
            }
            
            AlertUtility.showAlert(title: String(format: "Successfully placed %@ order", self.orderTpye.rawValue))
            print(response as Any)
        }
        
        if self.orderSide == .BUY {

        } else {
            
        }
    }
    
}

extension PlaceNewOrderDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = datasource[indexPath.row]
        cell.delegate = self.viewModel
        cell.symbol = self.symbol
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = datasource[indexPath.row]
        switch cell.cellType {
        case .CellType_price, .CellType_switch, .CellType_targets:
            return 55
        case .CellType_addTarget:
            return 90
        case .CellType_amount:
            return 90
        case .CellType_description:
            if let cell = cell as? DescriptionCell {
                return 20 + (cell.descriptionLabel.text?.height(withConstrainedWidth: cell.descriptionLabel.frame.size.width, font: UIFont.systemFont(ofSize: 11)) ?? 28)
            }
            return 50
        case .none:
            return 50
        }
    }
    
    private func prepareDataSource() {
        
        switch orderTpye {
        case .MARKET:
            prepareMarketOrderDetail()
            break
        case .LIMIT:
            prepareLimitOrderDetail()
            break
        case .STOP_LOSS_LIMIT:
            prepareStopLimitOrderDetail()
            break
        case .OCO:
            prepareOCOOrderDetail()
            break
        default:
            break
        }
    }
    
    private func prepareMarketOrderDetail() {
        
        let amountCell = tableView.dequeueReusableCell(withIdentifier: "AmountCell") as! AmountCell
        amountCell.cellType = .CellType_amount
        amountCell.index = 0
        
        let amountDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
        amountDescriptionCell.descriptionLabel.text = descriptionsDic[amountCell.cellType]
        amountDescriptionCell.cellType = .CellType_description
        amountDescriptionCell.index = 1
        
        let switchCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchCell
        switchCell.switchDelegate = self
        switchCell.cellType = .CellType_switch
        switchCell.index = 2
        
        let autoSellDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
        amountDescriptionCell.descriptionLabel.text = descriptionsDic[switchCell.cellType]
        autoSellDescriptionCell.cellType = .CellType_description
        autoSellDescriptionCell.index = 3
        
        switch orderSide {
        case .SELL:
            datasource.append(amountCell)
            datasource.append(amountDescriptionCell)
            break
        case .BUY:
            datasource.append(amountCell)
            datasource.append(amountDescriptionCell)
//            datasource.append(switchCell)
//            datasource.append(autoSellDescriptionCell)
            break
        default:
            break
        }
        
    }
    
    private func prepareLimitOrderDetail() {
        
        let priceCell = tableView.dequeueReusableCell(withIdentifier: "PriceCell") as! PriceCell
        priceCell.cellType = .CellType_price
        priceCell.titleLabel.text = "Price:"
        priceCell.index = 0
        
        let priceDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
        priceDescriptionCell.cellType = .CellType_description
        priceDescriptionCell.index = 1
        
        let amountCell = tableView.dequeueReusableCell(withIdentifier: "AmountCell") as! AmountCell
        amountCell.cellType = .CellType_amount
        amountCell.index = 2
        
        let amountDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
        amountDescriptionCell.descriptionLabel.text = descriptionsDic[amountCell.cellType]
        amountDescriptionCell.cellType = .CellType_description
        amountDescriptionCell.index = 3
        
        let totalCell = tableView.dequeueReusableCell(withIdentifier: "PriceCell") as! PriceCell
        totalCell.priceType = .total
        totalCell.cellType = .CellType_price
        totalCell.titleLabel.text = "Total:"
        totalCell.index = 4
        totalCell.stepperView.isHidden = true
        totalCell.priceTextfield.isUserInteractionEnabled = false
        
        let totalDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
        totalDescriptionCell.descriptionLabel.text = priceDescriptionsDic[totalCell.priceType]
        totalDescriptionCell.cellType = .CellType_description
        totalDescriptionCell.index = 5
        
        let switchCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchCell
        switchCell.switchDelegate = self
        switchCell.cellType = .CellType_switch
        switchCell.index = 6
        
        let autoSellDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
        amountDescriptionCell.descriptionLabel.text = descriptionsDic[switchCell.cellType]
        autoSellDescriptionCell.cellType = .CellType_description
        autoSellDescriptionCell.index = 7
        
        switch orderSide {
        case .SELL:
            priceCell.priceType = .sellPrice
            priceDescriptionCell.descriptionLabel.text = priceDescriptionsDic[priceCell.priceType]
            
            datasource.append(priceCell)
            datasource.append(priceDescriptionCell)
            datasource.append(amountCell)
            datasource.append(amountDescriptionCell)
            datasource.append(totalCell)
            datasource.append(totalDescriptionCell)
            break
        case .BUY:
            priceCell.priceType = .buyPrice
            priceDescriptionCell.descriptionLabel.text = priceDescriptionsDic[priceCell.priceType]
            
            datasource.append(priceCell)
            datasource.append(priceDescriptionCell)
            datasource.append(amountCell)
            datasource.append(amountDescriptionCell)
            datasource.append(totalCell)
            datasource.append(totalDescriptionCell)
//            datasource.append(switchCell)
//            datasource.append(autoSellDescriptionCell)
            break
        default:
            break
        }
        
    }
    
    private func prepareStopLimitOrderDetail() {
        
        let stopPriceCell = tableView.dequeueReusableCell(withIdentifier: "PriceCell") as! PriceCell
        stopPriceCell.cellType = .CellType_price
        stopPriceCell.titleLabel.text = "Stop:"
        stopPriceCell.index = 0
        
        let stopPriceDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
        stopPriceDescriptionCell.cellType = .CellType_description
        stopPriceDescriptionCell.index = 1
        
        let limitPriceCell = tableView.dequeueReusableCell(withIdentifier: "PriceCell") as! PriceCell
        limitPriceCell.cellType = .CellType_price
        limitPriceCell.titleLabel.text = "Limit:"
        limitPriceCell.index = 2
        
        let limitPriceDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
        limitPriceDescriptionCell.cellType = .CellType_description
        limitPriceDescriptionCell.index = 3
        
        let amountCell = tableView.dequeueReusableCell(withIdentifier: "AmountCell") as! AmountCell
        amountCell.cellType = .CellType_amount
        amountCell.index = 4
        
        let amountDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
        amountDescriptionCell.descriptionLabel.text = descriptionsDic[amountCell.cellType]
        amountDescriptionCell.cellType = .CellType_description
        amountDescriptionCell.index = 5
        
        let totalCell = tableView.dequeueReusableCell(withIdentifier: "PriceCell") as! PriceCell
        totalCell.priceType = .total
        totalCell.cellType = .CellType_price
        totalCell.titleLabel.text = "Total:"
        totalCell.index = 6
        totalCell.stepperView.isHidden = true
        totalCell.priceTextfield.isUserInteractionEnabled = false
        
        let totalDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
        totalDescriptionCell.descriptionLabel.text = priceDescriptionsDic[totalCell.priceType]
        totalDescriptionCell.cellType = .CellType_description
        totalDescriptionCell.index = 7
        
        let switchCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchCell
        switchCell.switchDelegate = self
        switchCell.cellType = .CellType_switch
        switchCell.index = 8
        
        let autoSellDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
        amountDescriptionCell.descriptionLabel.text = descriptionsDic[switchCell.cellType]
        autoSellDescriptionCell.cellType = .CellType_description
        autoSellDescriptionCell.index = 9
        
        switch orderSide {
        case .SELL:
            stopPriceCell.priceType = .sellStopPrice
            stopPriceDescriptionCell.descriptionLabel.text = priceDescriptionsDic[stopPriceCell.priceType]
            limitPriceCell.priceType = .sellLimitPrice
            limitPriceDescriptionCell.descriptionLabel.text = priceDescriptionsDic[limitPriceCell.priceType]
            
            datasource.append(stopPriceCell)
            datasource.append(stopPriceDescriptionCell)
            datasource.append(limitPriceCell)
            datasource.append(limitPriceDescriptionCell)
            datasource.append(amountCell)
            datasource.append(amountDescriptionCell)
            datasource.append(totalCell)
            datasource.append(totalDescriptionCell)
            break
        case .BUY:
            stopPriceCell.priceType = .buyStopPrice
            stopPriceDescriptionCell.descriptionLabel.text = priceDescriptionsDic[stopPriceCell.priceType]
            limitPriceCell.priceType = .buyLimitPrice
            limitPriceDescriptionCell.descriptionLabel.text = priceDescriptionsDic[limitPriceCell.priceType]
            
            datasource.append(stopPriceCell)
            datasource.append(stopPriceDescriptionCell)
            datasource.append(limitPriceCell)
            datasource.append(limitPriceDescriptionCell)
            datasource.append(amountCell)
            datasource.append(amountDescriptionCell)
            datasource.append(totalCell)
            datasource.append(totalDescriptionCell)
            datasource.append(switchCell)
            datasource.append(autoSellDescriptionCell)
            break
        default:
            break
        }
        
    }
    
    private func prepareOCOOrderDetail() {
        
        let priceCell = tableView.dequeueReusableCell(withIdentifier: "PriceCell") as! PriceCell
        priceCell.cellType = .CellType_price
        priceCell.titleLabel.text = "Price:"
        priceCell.index = 0
        
        let priceDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
        priceDescriptionCell.cellType = .CellType_description
        priceDescriptionCell.index = 1
        
        let stopPriceCell = tableView.dequeueReusableCell(withIdentifier: "PriceCell") as! PriceCell
        stopPriceCell.cellType = .CellType_price
        stopPriceCell.titleLabel.text = "Stop:"
        stopPriceCell.index = 2
        
        let stopPriceDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
        stopPriceDescriptionCell.cellType = .CellType_description
        stopPriceDescriptionCell.index = 3
        
        let limitPriceCell = tableView.dequeueReusableCell(withIdentifier: "PriceCell") as! PriceCell
        limitPriceCell.cellType = .CellType_price
        limitPriceCell.titleLabel.text = "Limit:"
        limitPriceCell.index = 4
        
        let limitPriceDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
        limitPriceDescriptionCell.cellType = .CellType_description
        limitPriceDescriptionCell.index = 5
        
        let amountCell = tableView.dequeueReusableCell(withIdentifier: "AmountCell") as! AmountCell
        amountCell.cellType = .CellType_amount
        amountCell.index = 6
        
        let amountDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
        amountDescriptionCell.descriptionLabel.text = descriptionsDic[amountCell.cellType]
        amountDescriptionCell.cellType = .CellType_description
        amountDescriptionCell.index = 7
        
        let totalCell = tableView.dequeueReusableCell(withIdentifier: "PriceCell") as! PriceCell
        totalCell.priceType = .total
        totalCell.cellType = .CellType_price
        totalCell.titleLabel.text = "Total:"
        totalCell.index = 8
        totalCell.stepperView.isHidden = true
        totalCell.priceTextfield.isUserInteractionEnabled = false
        
        let totalDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
        totalDescriptionCell.descriptionLabel.text = priceDescriptionsDic[totalCell.priceType]
        totalDescriptionCell.cellType = .CellType_description
        totalDescriptionCell.index = 9
        
        let switchCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchCell
        switchCell.switchDelegate = self
        switchCell.cellType = .CellType_switch
        switchCell.index = 10
        
        let autoSellDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
        amountDescriptionCell.descriptionLabel.text = descriptionsDic[switchCell.cellType]
        autoSellDescriptionCell.cellType = .CellType_description
        autoSellDescriptionCell.index = 11
        
        switch orderSide {
        case .SELL:
            priceCell.priceType = .sellPrice
            priceDescriptionCell.descriptionLabel.text = priceDescriptionsDic[priceCell.priceType]
            stopPriceCell.priceType = .sellStopPrice
            stopPriceDescriptionCell.descriptionLabel.text = priceDescriptionsDic[stopPriceCell.priceType]
            limitPriceCell.priceType = .sellLimitPrice
            limitPriceDescriptionCell.descriptionLabel.text = priceDescriptionsDic[limitPriceCell.priceType]
            
            datasource.append(priceCell)
            datasource.append(priceDescriptionCell)
            datasource.append(stopPriceCell)
            datasource.append(stopPriceDescriptionCell)
            datasource.append(limitPriceCell)
            datasource.append(limitPriceDescriptionCell)
            datasource.append(amountCell)
            datasource.append(amountDescriptionCell)
            datasource.append(totalCell)
            datasource.append(totalDescriptionCell)
            break
        case .BUY:
            priceCell.priceType = .buyPrice
            priceDescriptionCell.descriptionLabel.text = priceDescriptionsDic[priceCell.priceType]
            stopPriceCell.priceType = .buyStopPrice
            stopPriceDescriptionCell.descriptionLabel.text = priceDescriptionsDic[stopPriceCell.priceType]
            limitPriceCell.priceType = .buyLimitPrice
            limitPriceDescriptionCell.descriptionLabel.text = priceDescriptionsDic[limitPriceCell.priceType]
            
            datasource.append(priceCell)
            datasource.append(priceDescriptionCell)
            datasource.append(stopPriceCell)
            datasource.append(stopPriceDescriptionCell)
            datasource.append(limitPriceCell)
            datasource.append(limitPriceDescriptionCell)
            datasource.append(amountCell)
            datasource.append(amountDescriptionCell)
            datasource.append(totalCell)
            datasource.append(totalDescriptionCell)
            datasource.append(switchCell)
            datasource.append(autoSellDescriptionCell)
            break
        default:
            break
        }
        
    }
    
    func updateLatestDataWith(order: SymbolOrderBookObject) {
        NumbersUtilities.shared.formatted(price: order.askPrice ?? "", for: order.symbol!, result: { (price, error) in
            self.askPrice.text = price!
        })
        NumbersUtilities.shared.formatted(quantity: order.askQty ?? "", for: order.symbol!, result: { (quantity, error) in
            self.askQuantity.text = quantity
        })
        NumbersUtilities.shared.formatted(price: order.bidPrice ?? "", for: order.symbol!, result: { (price, error) in
            self.bidPrice.text = price!
        })
        NumbersUtilities.shared.formatted(quantity: order.bidQty ?? "", for: order.symbol!, result: { (quantity, error) in
            self.bidQuantity.text = quantity
        })
    }
    
    func update(value: String, index: Int) {
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? BaseTableViewCell {
            cell.set(value: value, index: index)
        }
    }
}

extension PlaceNewOrderDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil);
    }
}

extension PlaceNewOrderDetailViewController: SwitchCellDelegate {
    func autoSellSwitchValueChanged(isEnable: Bool, cellIndex: Int) {
        if isEnable {

            for cell in datasource {
                if cell.index > cellIndex {
                    cell.index = cell.index + 3
                }
            }
            
            let sellStopPriceCell = tableView.dequeueReusableCell(withIdentifier: "PriceCell") as! PriceCell
            sellStopPriceCell.priceType = .sellStopPrice
            sellStopPriceCell.cellType = .CellType_price
            sellStopPriceCell.titleLabel.text = "Sell Stop:"
            sellStopPriceCell.index = cellIndex + 1
            
            let sellLimitPriceCell = tableView.dequeueReusableCell(withIdentifier: "PriceCell") as! PriceCell
            sellLimitPriceCell.priceType = .sellLimitPrice
            sellLimitPriceCell.cellType = .CellType_price
            sellLimitPriceCell.titleLabel.text = "Sell Limit:"
            sellLimitPriceCell.index = cellIndex + 2
            
            let addTargetCell = tableView.dequeueReusableCell(withIdentifier: "AddTargetCell") as! AddTargetCell
            addTargetCell.addTargetDelegate = self
            addTargetCell.cellType = .CellType_addTarget
            addTargetCell.index = cellIndex + 3
            
            datasource.insert(sellStopPriceCell, at: sellStopPriceCell.index)
            datasource.insert(sellLimitPriceCell, at: sellLimitPriceCell.index)
            datasource.insert(addTargetCell, at: addTargetCell.index)
            
        } else {
            datasource = datasource.filter({ $0.cellType != CellType.CellType_addTarget && $0.cellType != CellType.CellType_targets })
            var tempDatasource = [BaseTableViewCell]()
            for cell in datasource {
                if cell.cellType == .CellType_price {
                    if (cell as! PriceCell).priceType != .sellStopPrice && (cell as! PriceCell).priceType != .sellLimitPrice {
                        tempDatasource.append(cell)
                    }
                } else {
                    tempDatasource.append(cell)
                }
            }
            datasource = tempDatasource
        }
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: datasource.count - 1, section: 0), at: .top, animated: true)
    }
    
    
}

extension PlaceNewOrderDetailViewController: AddTargetCellDelegate {
    func targetAddedWith(price: String, cellIndex: Int) {
        let sourceArray = datasource.filter({ $0.cellType == CellType.CellType_targets })
        if sourceArray.count > 0 {
            let cell = sourceArray[0] as! TargetsCell
            cell.addNewTarget(price: price)
        } else {
            let targetsCell = tableView.dequeueReusableCell(withIdentifier: "TargetsCell") as! TargetsCell
            targetsCell.targetsDelegate = self
            targetsCell.cellType = .CellType_targets
            targetsCell.index = cellIndex + 1
            targetsCell.addNewTarget(price: price)
            
            for cell in datasource {
                if cell.index > cellIndex {
                    cell.index = cell.index + 1
                }
            }
            
            datasource.insert(targetsCell, at: targetsCell.index)
        }
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: datasource.count - 1, section: 0), at: .top, animated: true)
    }
    
    
}

extension PlaceNewOrderDetailViewController: TargetsCellDelegate {
    func didRemoveAllTargets() {
        datasource = datasource.filter({ $0.cellType != CellType.CellType_targets })
        tableView.reloadData()
    }
}

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
