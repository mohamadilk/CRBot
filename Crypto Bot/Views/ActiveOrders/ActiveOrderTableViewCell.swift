//
//  ActiveOrderTableViewCell.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/21/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import UIKit
import UICircularProgressRing

protocol ActiveOrderTableViewCellDelegate {
    
    func didCancelOrder(model: OrderDetailObject)
}

class ActiveOrderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var orderTypeLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel! {
        didSet {
            self.symbolLabel.textColor = UIColor.darkGray
        }
    }
    @IBOutlet weak var progressRing: UICircularProgressRing! {
        didSet {
            self.progressRing.style = .inside
            self.progressRing.startAngle = 270
            self.progressRing.font = UIFont.systemFont(ofSize: 12)
        }
    }
    @IBOutlet weak var conditionsLabel: UILabel!
    @IBOutlet weak var amountValueLabel: UILabel!
    @IBOutlet weak var priceValueLabel: UILabel!
    @IBOutlet weak var conditionsValueLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            self.cancelButton.tintColor = UIColor.binanceYellowColor()
            self.cancelButton.layer.borderColor = UIColor.binanceYellowColor().cgColor
            self.cancelButton.layer.borderWidth = 1
        }
    }
    
    var delegate: ActiveOrderTableViewCellDelegate?
    var model: OrderDetailObject!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureWith(model: OrderDetailObject) {
        
        self.model = model
        orderTypeLabel.text = orderType(for: model.type)
        let percent = ((model.cummulativeQuoteQty?.doubleValue ?? 1) / (model.origQty?.doubleValue ?? 1))
        progressRing.value = CGFloat(round(percent))
        timeLabel.text = timeString(for: model.time ?? 0)
        
        ExchangeHandler.shared.getSymbol(symbol: model.symbol ?? "") { [weak self] (symbol, error) in
            guard error == nil else { return }
            DispatchQueue.main.async {
                self?.symbolLabel.text = (symbol?.baseAsset ?? "") + " / " + (symbol?.quoteAsset ?? "")
            }
        }
        
        if model.side == .BUY {
            orderTypeLabel.textColor = UIColor.binanceDarkGreenColor()
            progressRing.innerRingColor = UIColor.binanceDarkGreenColor()
            progressRing.fontColor = UIColor.binanceDarkGreenColor()
        } else {
            orderTypeLabel.textColor = UIColor.binanceRedColor()
            progressRing.innerRingColor = UIColor.binanceRedColor()
            progressRing.fontColor = UIColor.binanceRedColor()
        }
        
        if model.stopPrice?.doubleValue ?? 0 > 0.0 {
            conditionsValueLabel.isHidden = false
            conditionsLabel.isHidden = false
            
            NumbersUtilities.shared.formatted(price: model.stopPrice ?? "", for: model.symbol ?? "") { [weak self] (price, error) in
                DispatchQueue.main.async {
                    if model.side == .BUY {
                        self?.conditionsValueLabel.text = ">= \(price ?? "0")"
                    } else {
                        self?.conditionsValueLabel.text = "=< \(price ?? "0")"
                    }
                }
            }
        } else {
            conditionsValueLabel.isHidden = true
            conditionsLabel.isHidden = true
        }
        
        NumbersUtilities.shared.formatted(price: model.price ?? "", for: model.symbol ?? "") { [weak self] (price, error) in
            DispatchQueue.main.async {
                self?.priceValueLabel.text = price
            }
        }
        
        NumbersUtilities.shared.formatted(quantity: model.cummulativeQuoteQty ?? "", for: model.symbol ?? "") { [weak self] (cumQty, error) in
            guard error == nil else { return }
            
            let finalStr = NSMutableAttributedString(string: cumQty ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
            finalStr.append(NSAttributedString(string: " / ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.borderGrayColor(),
                                                                           NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11)]))
            
            NumbersUtilities.shared.formatted(quantity: model.origQty ?? "", for: model.symbol ?? "") { (origQty, error) in
                guard error == nil else { return }

                finalStr.append(NSAttributedString(string: origQty ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.borderGrayColor(),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11)]))
                
                DispatchQueue.main.async {
                    self?.amountValueLabel.attributedText = finalStr
                }
            }
        }
    }
    
    private func timeString(for timeStamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeStamp / 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: TimeZone.current.abbreviation() ?? "")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //Specify your format that you want
        return dateFormatter.string(from: date)
    }
    
    @IBAction func pressedCancelOrder(_ sender: UIButton) {
        delegate?.didCancelOrder(model: self.model)
    }
}

extension ActiveOrderTableViewCell {
    func orderType(for type: OrderTypes?) -> String {
        guard type != nil else { return "" }
        switch type! {
        case .LIMIT:
            return "Limit"
            
        case .LIMIT_MAKER:
            return "Limit-Maker"
            
        case .MARKET:
            return "Market"
            
        case .STOP_LOSS:
            return "Stop-Loss"
            
        case .OCO:
            return "OCO"
            
        case .STOP_LOSS_LIMIT:
            return "Stop-Limit"
            
        case .TAKE_PROFIT:
            return "Take-Profit"

        case .TAKE_PROFIT_LIMIT:
            return "Profit-Limit"
        }
    }
}
