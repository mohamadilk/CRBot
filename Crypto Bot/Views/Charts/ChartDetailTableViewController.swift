//
//  ChartDetailTableViewController.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 13.12.2019.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import UIKit

enum IndicatorType: String {
    case MA = "Moving Average"
    case RSI = "RSI"
    case StochasticRSI = "Stochastic RSI"
    case BB = "bollinger bands"
    case Ichimoku = "Ichimoku"
}

enum PriceType: String {
    case open = "Open"
    case close = "Close"
    case high = "High"
    case low = "Low"
}

class ChartDetailTableViewController: UITableViewController {
    
    private var symbol: String?
    private var MA_Cross_Short: Int?
    private var MA_Cross_Long: Int?
    private var RSI_Lenth: Int?
    private var Stoch_RSI_Lenth_RSI: Int?
    private var Stoch_RSI_Lenth_Stock: Int?
    private var Smooth_K: Int?
    private var Smooth_D: Int?
    private var Smooth_T: Int?
    private var Ichimoku_Conversion_Line_Period: Int?
    private var Ichimoku_Base_Line_Period: Int?
    private var Ichimoku_Lagging_Span_2_Period: Int?
    private var Ichimoku_Displacement: Int?
    private var BB_Length: Int?
    private var BB_Mult: Int?
    private var Number_of_Candles: Int?
    private var Candle_Size: CandlestickChartIntervals?
    private var Price_Type: PriceType?
    
    var pickerView = ToolbarPickerView() {
        didSet {
            
        }
    }
    
    var selectedIndex: IndexPath?
    let textField = UITextField(frame: .zero)
    
    var pickerIndex: Int?
    var pickerDatasouce = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chart Detail"
        view.addSubview(textField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 18 {
            showChartView()
            return
        }
        selectedIndex = indexPath
        pickerDatasouce.removeAll()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.toolbarDelegate = self
        textField.inputView = pickerView
        textField.inputAccessoryView = pickerView.toolbar
        
        switch indexPath.row {
        case 0:
            if let symbolsListView = self.storyboard?.instantiateViewController(withIdentifier: "SymbolsListTableViewController") as? SymbolsListTableViewController {
                symbolsListView.delegate = self
                present(symbolsListView, animated: true, completion: nil)
            }
            return
        case 1...15:
            for i in 1...500 {
                pickerDatasouce.append(i)
            }
            textField.becomeFirstResponder()
            return
        case 16:
            pickerDatasouce = [CandlestickChartIntervals.oneMin.rawValue,CandlestickChartIntervals.threeMin.rawValue,CandlestickChartIntervals.fiveMin.rawValue,CandlestickChartIntervals.fifteenMin.rawValue,CandlestickChartIntervals.thirtyMin.rawValue,CandlestickChartIntervals.oneHour.rawValue,CandlestickChartIntervals.twoHour.rawValue,CandlestickChartIntervals.fourHour.rawValue,CandlestickChartIntervals.sixHour.rawValue,CandlestickChartIntervals.eightHour.rawValue,CandlestickChartIntervals.twelveHour.rawValue,CandlestickChartIntervals.oneDay.rawValue,CandlestickChartIntervals.threeDay.rawValue,CandlestickChartIntervals.oneWeek.rawValue,CandlestickChartIntervals.oneMonth.rawValue]
            textField.becomeFirstResponder()
        case 17:
            pickerDatasouce = [PriceType.open.rawValue,PriceType.close.rawValue,PriceType.high.rawValue,PriceType.low.rawValue]
            textField.becomeFirstResponder()
            return
        default:
            return
        }
    }
    
    func updateValuesWithPickerSelectedIndex() {
        if let index = selectedIndex, let cell = tableView.cellForRow(at: index) {
            if let pickerIndex = self.pickerIndex {
                cell.detailTextLabel?.text = "\(pickerDatasouce[pickerIndex])"
                tableView.reloadRows(at: [index], with: .none)
                
                switch index.row {
                case 1:
                    MA_Cross_Short = pickerDatasouce[pickerIndex] as? Int
                    break
                case 2:
                    MA_Cross_Long = pickerDatasouce[pickerIndex] as? Int
                    break
                case 3:
                    RSI_Lenth = pickerDatasouce[pickerIndex] as? Int
                    break
                case 4:
                    Stoch_RSI_Lenth_RSI = pickerDatasouce[pickerIndex] as? Int
                    break
                case 5:
                    Stoch_RSI_Lenth_Stock = pickerDatasouce[pickerIndex] as? Int
                    break
                case 6:
                    Smooth_K = pickerDatasouce[pickerIndex] as? Int
                    break
                case 7:
                    Smooth_D = pickerDatasouce[pickerIndex] as? Int
                    break
                case 8:
                    Smooth_T = pickerDatasouce[pickerIndex] as? Int
                    break
                case 9:
                    Ichimoku_Conversion_Line_Period = pickerDatasouce[pickerIndex] as? Int
                    break
                case 10:
                    Ichimoku_Base_Line_Period = pickerDatasouce[pickerIndex] as? Int
                    break
                case 11:
                    Ichimoku_Lagging_Span_2_Period = pickerDatasouce[pickerIndex] as? Int
                    break
                case 12:
                    Ichimoku_Displacement = pickerDatasouce[pickerIndex] as? Int
                    break
                case 13:
                    BB_Length = pickerDatasouce[pickerIndex] as? Int
                    break
                case 14:
                    BB_Mult = pickerDatasouce[pickerIndex] as? Int
                    break
                case 15:
                    Number_of_Candles = pickerDatasouce[pickerIndex] as? Int
                    break
                case 16:
                    Candle_Size =  CandlestickChartIntervals(rawValue: "\(pickerDatasouce[pickerIndex])")
                    break
                case 17:
                    Price_Type = PriceType(rawValue: "\(pickerDatasouce[pickerIndex])")
                    break
                default:
                    break
                }
            }
        }
    }
}

extension ChartDetailTableViewController {
    private func showChartView() {
        let def = ItemDef(title: "Line Chart (Dual YAxis)",
        subtitle: "Demonstration of the linechart with dual y-axis.",
        class: CandleStickChartViewController.self)

        let vcClass = def.class as! UIViewController.Type
        let vc = vcClass.init() as! CandleStickChartViewController

        vc.MACrossLong = MA_Cross_Long
        vc.MACrossShort = MA_Cross_Short
        vc.RSILenth = RSI_Lenth
        vc.StochRSILenthRSI = Stoch_RSI_Lenth_RSI
        vc.StochRSILenthStock = Stoch_RSI_Lenth_Stock
        vc.SmoothD = Smooth_D
        vc.SmoothK = Smooth_K
        vc.SmoothT = Smooth_T
        vc.IchimokuDisplacement = Ichimoku_Displacement
        vc.IchimokuBaseLinePeriod = Ichimoku_Base_Line_Period
        vc.IchimokuLaggingSpan2Period = Ichimoku_Lagging_Span_2_Period
        vc.IchimokuConversionLinePeriod = Ichimoku_Conversion_Line_Period
        vc.BBMult = BB_Mult
        vc.BBLength = BB_Length
        if Number_of_Candles != nil { vc.candlesCount = Number_of_Candles! }
        if Candle_Size != nil { vc.candleSize = Candle_Size! }
        if Price_Type != nil { vc.priceType = Price_Type! }
        if symbol != nil { vc.symbol = symbol! }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ChartDetailTableViewController: SymbolsListTableViewControllerDelegate {
    func didSelect(symbol: SymbolObject) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            cell.detailTextLabel?.text = symbol.symbol
            self.symbol = symbol.symbol
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
}

extension ChartDetailTableViewController: ToolbarPickerViewDelegate {
    func didTapDone(pickerView: ToolbarPickerView) {
        updateValuesWithPickerSelectedIndex()
        pickerIndex = nil
        textField.resignFirstResponder()
    }
    
    func didTapCancel() {
        pickerIndex = nil
        textField.resignFirstResponder()
    }
}

extension ChartDetailTableViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerIndex = row
    }
}

extension ChartDetailTableViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDatasouce.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerDatasouce[row])"
    }
}
