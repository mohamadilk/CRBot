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
        
    var refreshControl: UIRefreshControl?
    
    var datasource = [CellModel]()
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
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshBalance), for: .valueChanged)
        tableView.refreshControl = refreshControl
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
        
        for model in self.datasource {
            switch model.cellType {
            case .CellType_price:
                switch model.priceType {
                case .buyPrice, .sellPrice:
                    price = model.value ?? "0"
                    break
                case .buyStopPrice:
                    buyStopPrice = model.value ?? "0"
                    break
                case .buyLimitPrice:
                    buyStopLimitPrice = model.value ?? "0"
                    break
                case .sellStopPrice:
                    sellStopPrice = model.value ?? "0"
                    break
                case .sellLimitPrice:
                    sellStopLimitPrice = model.value ?? "0"
                    break
                default:
                    break
                }
                break
            case .CellType_amount:
                amount = model.value ?? "0"
                break
            default:
                break
            }
        }
        
        if let targetsModel = self.datasource.filter({ $0.cellType == .CellType_targets }).first {
            if targetsModel.targetsArray?.count ?? 0 > 0 {
                targetsArray = targetsModel.targetsArray
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
    
    @objc func refreshBalance() {
        viewModel.updateUserBalance { success in
            self.refreshControl?.endRefreshing()
            if(!success) {
                AlertUtility.showAlert(title: "Falied to update balance")
            }
        }
    }
}

extension PlaceNewOrderDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = datasource[indexPath.row]
        var cell: BaseTableViewCell!
        
        switch cellModel.cellType {
        case .CellType_price:
            let priceCell = tableView.dequeueReusableCell(withIdentifier: "PriceCell") as? PriceCell
            priceCell?.priceType = cellModel.priceType
            if cellModel.priceType == .total {
                priceCell?.stepperView.isHidden = true
                priceCell?.priceTextfield.isUserInteractionEnabled = false
            } else {
                priceCell?.stepperView.isHidden = false
                priceCell?.priceTextfield.isUserInteractionEnabled = true
            }
            
            if let title = cellModel.title {
                priceCell?.titleLabel.text = title
            }
            priceCell?.updateValidity(state: viewModel.validityStateFor(index: indexPath.row))
            priceCell?.priceTextfield.text = cellModel.value
            cell = priceCell
            break
        case .CellType_amount:
            let amountCell = tableView.dequeueReusableCell(withIdentifier: "AmountCell") as? AmountCell
            if let title = cellModel.title {
                amountCell?.titleLabel.text = title
            }
            amountCell?.updateValidity(state: viewModel.validityStateFor(index: indexPath.row))
            amountCell?.amountTextfield.text = cellModel.value
            cell = amountCell
            break
        case .CellType_switch:
            let switchCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as? SwitchCell
            switchCell?.switchDelegate = self
            cell = switchCell
            break
        case .CellType_targets:
            let targetsCell = tableView.dequeueReusableCell(withIdentifier: "TargetsCell") as? TargetsCell
            targetsCell?.targetsArray = cellModel.targetsArray ?? []
            targetsCell?.targetsDelegate = self
            cell = targetsCell
            break
        case .CellType_addTarget:
            let addTargetCell = tableView.dequeueReusableCell(withIdentifier: "AddTargetCell") as? AddTargetCell
            addTargetCell?.addTargetDelegate = self
            if let title = cellModel.title {
                addTargetCell?.titleLabel.text = title
            }
            addTargetCell?.updateValidity(state: viewModel.validityStateFor(index: indexPath.row))
            addTargetCell?.priceTextfield.text = cellModel.value
            cell = addTargetCell
            break
        case .CellType_description:
            let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as? DescriptionCell
            if let title = cellModel.title {
                descriptionCell?.descriptionLabel.text = title
            }
            cell = descriptionCell
            break
        }
        cell.delegate = self.viewModel
        cell.symbol = self.symbol
        cell.index = cellModel.index
        cell.cellType = cellModel.cellType
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let targetsCell = cell as? TargetsCell {
            targetsCell.collectionView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellModel = datasource[indexPath.row]
        switch cellModel.cellType {
        case .CellType_price, .CellType_switch, .CellType_targets:
            return 55
        case .CellType_addTarget:
            return 90
        case .CellType_amount:
            return 90
        case .CellType_description:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as? DescriptionCell {
                return 20 + (cell.descriptionLabel.text?.height(withConstrainedWidth: cell.descriptionLabel.frame.size.width, font: UIFont.systemFont(ofSize: 11)) ?? 28)
            }
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
        datasource.append(CellModel(cellType: .CellType_amount, title: "Amount:", index: 0))
        datasource.append(CellModel(cellType: .CellType_description, title: descriptionsDic[.CellType_amount], index: 1))
    }
    
    private func prepareLimitOrderDetail() {
        
        switch orderSide {
        case .SELL:
            datasource.append(CellModel(priceType: .sellPrice, cellType: .CellType_price, title: "Price:", index: 0))
            datasource.append(CellModel(cellType: .CellType_description, title: priceDescriptionsDic[.sellPrice], index: 1))
            break
        case .BUY:
            datasource.append(CellModel(priceType: .buyPrice, cellType: .CellType_price, title: "Price:", index: 0))
            datasource.append(CellModel(cellType: .CellType_description, title: priceDescriptionsDic[.buyPrice], index: 1))
            break
        default:
            break
        }
        
        datasource.append(CellModel(cellType: .CellType_amount, title: "Amount:", index: 2))
        datasource.append(CellModel(cellType: .CellType_description, title: descriptionsDic[.CellType_amount], index: 3))
        datasource.append(CellModel(priceType: .total ,cellType: .CellType_price, title: "Total:", index: 4))
        datasource.append(CellModel(cellType: .CellType_description, title: priceDescriptionsDic[.total], index: 5))
    }
    
    private func prepareStopLimitOrderDetail() {
        switch orderSide {
        case .SELL:
            datasource.append(CellModel(priceType: .sellStopPrice, cellType: .CellType_price, title: "Stop Price:", index: 0))
            datasource.append(CellModel(cellType: .CellType_description, title: priceDescriptionsDic[.sellStopPrice], index: 1))
            datasource.append(CellModel(priceType: .sellLimitPrice, cellType: .CellType_price, title: "Limit Price:", index: 2))
            datasource.append(CellModel(cellType: .CellType_description, title: priceDescriptionsDic[.sellLimitPrice], index: 3))
            datasource.append(CellModel(cellType: .CellType_amount, title: "Amount:", index: 4))
            datasource.append(CellModel(cellType: .CellType_description, title: descriptionsDic[.CellType_amount], index: 5))
            datasource.append(CellModel(priceType: .total ,cellType: .CellType_price, title: "Total:", index: 6))
            datasource.append(CellModel(cellType: .CellType_description, title: priceDescriptionsDic[.total], index: 7))
            
            break
        case .BUY:
            datasource.append(CellModel(priceType: .buyStopPrice, cellType: .CellType_price, title: "Stop Price:", index: 0))
            datasource.append(CellModel(cellType: .CellType_description, title: priceDescriptionsDic[.buyStopPrice], index: 1))
            datasource.append(CellModel(priceType: .buyLimitPrice, cellType: .CellType_price, title: "Limit Price:", index: 2))
            datasource.append(CellModel(cellType: .CellType_description, title: priceDescriptionsDic[.buyLimitPrice], index: 3))
            datasource.append(CellModel(cellType: .CellType_amount, title: "Amount:", index: 4))
            datasource.append(CellModel(cellType: .CellType_description, title: descriptionsDic[.CellType_amount], index: 5))
            datasource.append(CellModel(priceType: .total ,cellType: .CellType_price, title: "Total:", index: 6))
            datasource.append(CellModel(cellType: .CellType_description, title: priceDescriptionsDic[.total], index: 7))
            datasource.append(CellModel(cellType: .CellType_switch, index: 8))
            datasource.append(CellModel(cellType: .CellType_description, title: descriptionsDic[.CellType_switch], index: 9))
            break
        default:
            break
        }
        
    }
    
    private func prepareOCOOrderDetail() {
        switch orderSide {
        case .SELL:
            datasource.append(CellModel(priceType: .sellPrice, cellType: .CellType_price, title: "Price:", index: 0))
            datasource.append(CellModel(cellType: .CellType_description, title: priceDescriptionsDic[.sellPrice], index: 1))
            datasource.append(CellModel(priceType: .sellStopPrice, cellType: .CellType_price, title: "Stop Price:", index: 2))
            datasource.append(CellModel(cellType: .CellType_description, title: priceDescriptionsDic[.sellStopPrice], index: 3))
            datasource.append(CellModel(priceType: .sellLimitPrice, cellType: .CellType_price, title: "Limit Price:", index: 4))
            datasource.append(CellModel(cellType: .CellType_description, title: priceDescriptionsDic[.sellLimitPrice], index: 5))
            datasource.append(CellModel(cellType: .CellType_amount, title: "Amount:", index: 6))
            datasource.append(CellModel(cellType: .CellType_description, title: descriptionsDic[.CellType_amount], index: 7))
            datasource.append(CellModel(priceType: .total ,cellType: .CellType_price, title: "Total:", index: 8))
            datasource.append(CellModel(cellType: .CellType_description, title: priceDescriptionsDic[.total], index: 9))
            
            break
        case .BUY:
            datasource.append(CellModel(priceType: .buyPrice, cellType: .CellType_price, title: "Price:", index: 0))
            datasource.append(CellModel(cellType: .CellType_description, title: priceDescriptionsDic[.buyPrice], index: 1))
            datasource.append(CellModel(priceType: .buyStopPrice, cellType: .CellType_price, title: "Stop Price:", index: 2))
            datasource.append(CellModel(cellType: .CellType_description, title: priceDescriptionsDic[.buyStopPrice], index: 3))
            datasource.append(CellModel(priceType: .buyLimitPrice, cellType: .CellType_price, title: "Limit Price:", index: 4))
            datasource.append(CellModel(cellType: .CellType_description, title: priceDescriptionsDic[.buyLimitPrice], index: 5))
            datasource.append(CellModel(cellType: .CellType_amount, title: "Amount:", index: 6))
            datasource.append(CellModel(cellType: .CellType_description, title: descriptionsDic[.CellType_amount], index: 7))
            datasource.append(CellModel(priceType: .total ,cellType: .CellType_price, title: "Total:", index: 8))
            datasource.append(CellModel(cellType: .CellType_description, title: priceDescriptionsDic[.total], index: 9))
            datasource.append(CellModel(cellType: .CellType_switch, index: 10))
            datasource.append(CellModel(cellType: .CellType_description, title: descriptionsDic[.CellType_switch], index: 11))
            break
        default:
            break
        }
        
    }
    
    func updateLatestDataWith(order: SymbolOrderBookObject) {
        NumbersUtilities.shared.formatted(price: order.askPrice ?? "", for: order.symbol!, completion: { (price, error) in
            self.askPrice.text = price!
        })
        NumbersUtilities.shared.formatted(quantity: order.askQty ?? "", for: order.symbol!, completion: { (quantity, error) in
            self.askQuantity.text = quantity
        })
        NumbersUtilities.shared.formatted(price: order.bidPrice ?? "", for: order.symbol!, completion: { (price, error) in
            self.bidPrice.text = price!
        })
        NumbersUtilities.shared.formatted(quantity: order.bidQty ?? "", for: order.symbol!, completion: { (quantity, error) in
            self.bidQuantity.text = quantity
        })
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
            
            datasource.insert(CellModel(priceType: .sellStopPrice, cellType: .CellType_price, title: "Sell Stop:", index: cellIndex + 1), at: cellIndex + 1)
            datasource.insert(CellModel(priceType: .sellLimitPrice, cellType: .CellType_price, title: "Sell Limit:", index: cellIndex + 2), at: cellIndex + 2)
            datasource.insert(CellModel(cellType: .CellType_addTarget, index: cellIndex + 3), at: cellIndex + 3)
            
        } else {
            datasource = datasource.filter({ $0.cellType != CellType.CellType_addTarget && $0.cellType != CellType.CellType_targets })
            var tempDatasource = [CellModel]()
            for cellModel in datasource {
                if cellModel.cellType == .CellType_price {
                    if cellModel.priceType != .sellStopPrice && cellModel.priceType != .sellLimitPrice {
                        tempDatasource.append(cellModel)
                    }
                } else {
                    tempDatasource.append(cellModel)
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
        let cellModels = datasource.filter({ $0.cellType == CellType.CellType_targets })
        if cellModels.count > 0 {
            let model = cellModels.first
            if model?.targetsArray == nil {
                model?.targetsArray = [price]
            } else {
                if model?.targetsArray?.count ?? 0 >= 5 {
                    AlertUtility.showAlert(title: "You have reached the maximum number of targets!")
                    return
                }
                if !(model?.targetsArray?.contains(price) ?? false) {
                    model?.targetsArray?.append(price)
                }
            }
            if let cell = tableView.cellForRow(at: IndexPath(row: model?.index ?? 0, section: 0)) as? TargetsCell{
                cell.addNewTarget(price: price)
            }
        } else {
            
            for cell in datasource {
                if cell.index > cellIndex {
                    cell.index = cell.index + 1
                }
            }
            
            let targetsModel = CellModel(cellType: .CellType_targets, index: cellIndex + 1, targetsArray: [price])
            datasource.insert(targetsModel, at: cellIndex + 1)
        }
        
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: datasource.count - 1, section: 0), at: .top, animated: true)
    }
 
}

extension PlaceNewOrderDetailViewController: TargetsCellDelegate {
    func didRemove(target: String) {
        for model in datasource {
            if model.cellType == CellType.CellType_targets {
                if var targets = model.targetsArray {
                    if targets.contains(target) {
                        targets.removeAll(where: {
                            $0 == target
                        })
                        model.targetsArray = targets
                        if model.targetsArray?.count == 0 {
                            didRemoveAllTargets()
                        }
                    }
                }
            }
        }
    }
    
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
