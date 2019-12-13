//
//  CandleStickChartViewController.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

#if canImport(UIKit)
    import UIKit
#endif
import Charts

class CandleStickChartViewController: BaseChartViewController {

    @IBOutlet var priceChartView: CandleStickChartView!
    @IBOutlet weak var rsiChartView: LineChartView!
    @IBOutlet weak var stocRSICahrtView: LineChartView!
    
    
    
    @IBOutlet weak var rsiLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var stocLeftConstraint: NSLayoutConstraint!
    private var RSIValues = [Double?]()
    private var stocRSIValues = [Double?]()
    private var stocRSISmoothD = [Double?]()
    private var stocRSISmoothK = [Double?]()
    private var stocRSISmoothT = [Double?]()

    var MACrossShort: Int?
    var MACrossLong: Int?
    var RSILenth: Int?
    var StochRSILenthRSI: Int?
    var StochRSILenthStock: Int?
    var SmoothK: Int?
    var SmoothD: Int?
    var SmoothT: Int?
    var IchimokuConversionLinePeriod: Int?
    var IchimokuBaseLinePeriod: Int?
    var IchimokuLaggingSpan2Period: Int?
    var IchimokuDisplacement: Int?
    var BBLength: Int?
    var BBMult: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "\(symbol)"
        
        priceChartView.delegate = self
        
        priceChartView.chartDescription?.enabled = false
        
        priceChartView.dragEnabled = false
        priceChartView.setScaleEnabled(true)
        priceChartView.maxVisibleCount = 1
        priceChartView.pinchZoomEnabled = true
        
        priceChartView.legend.horizontalAlignment = .right
        priceChartView.legend.verticalAlignment = .top
        priceChartView.legend.orientation = .vertical
        priceChartView.legend.drawInside = false
        priceChartView.legend.font = UIFont(name: "HelveticaNeue-Light", size: 10)!
        
        priceChartView.leftAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 10)!
        priceChartView.leftAxis.spaceTop = 0
        priceChartView.leftAxis.spaceBottom = 0
        priceChartView.leftAxis.axisMinimum = 1000000
        priceChartView.leftAxis.axisMaximum = 0

        priceChartView.rightAxis.enabled = false
        
        priceChartView.xAxis.labelPosition = .bottom
        priceChartView.xAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 10)!
        
        rsiChartView.delegate = self
        
        rsiChartView.chartDescription?.enabled = false
        rsiChartView.dragEnabled = true
        rsiChartView.setScaleEnabled(true)
        rsiChartView.pinchZoomEnabled = true
        
        let k = rsiChartView.legend
        k.form = .line
        k.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        k.textColor = .black
        k.horizontalAlignment = .left
        k.verticalAlignment = .bottom
        k.orientation = .horizontal
        k.drawInside = false
        
        let xsAxis = rsiChartView.xAxis
        xsAxis.labelFont = .systemFont(ofSize: 11)
        xsAxis.labelTextColor = .white
        xsAxis.drawAxisLineEnabled = false
        
        let leftsAxis = rsiChartView.leftAxis
         leftsAxis.labelTextColor = UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)
         leftsAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 10)!
         leftsAxis.axisMaximum = 110
         leftsAxis.axisMinimum = -10
         leftsAxis.drawGridLinesEnabled = true
         leftsAxis.granularityEnabled = true
//        rsiChartView.rightAxis.enabled = false

        stocRSICahrtView.delegate = self
        
        stocRSICahrtView.chartDescription?.enabled = false
        stocRSICahrtView.dragEnabled = true
        stocRSICahrtView.setScaleEnabled(true)
        stocRSICahrtView.pinchZoomEnabled = true
        
        let r = stocRSICahrtView.legend
        r.form = .line
        r.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        r.textColor = .black
        r.horizontalAlignment = .left
        r.verticalAlignment = .bottom
        r.orientation = .horizontal
        r.drawInside = false
        
        let xrAxis = stocRSICahrtView.xAxis
        xrAxis.labelFont = .systemFont(ofSize: 11)
        xrAxis.labelTextColor = .white
        xrAxis.drawAxisLineEnabled = false
        
        let leftrAxis = stocRSICahrtView.leftAxis
         leftrAxis.labelTextColor = UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)
         leftrAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 10)!
         leftrAxis.axisMaximum = 110
         leftrAxis.axisMinimum = -10
         leftrAxis.drawGridLinesEnabled = true
         leftrAxis.granularityEnabled = true
//        stocRSICahrtView.rightAxis.enabled = false
        
        let rightAxis = rsiChartView.rightAxis
        rightAxis.labelTextColor = .red
        rightAxis.axisMaximum = 110
        rightAxis.axisMinimum = -10
        rightAxis.granularityEnabled = false
        
        let rightsAxis = stocRSICahrtView.rightAxis
        rightsAxis.labelTextColor = .red
        rightsAxis.axisMaximum = 110
        rightsAxis.axisMinimum = -10
        rightsAxis.granularityEnabled = false
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
            MarketDataServices.shared.fetchCandlestickData(symbol: self.symbol, interval: self.candleSize.rawValue, limit: self.candlesCount) { (candlesArray, error) in
                guard error == nil, candlesArray != nil else { return }
                self.candlesArray = candlesArray!
                var samples = [Double?]()
                for candle in candlesArray ?? [] {
                    switch self.priceType {
                    case .close:
                        samples.append(candle.close?.doubleValue ?? 0)
                        break
                    case .open:
                        samples.append(candle.open?.doubleValue ?? 0)
                        break
                    case .high:
                        samples.append(candle.high?.doubleValue ?? 0)
                        break
                    case .low:
                        samples.append(candle.low?.doubleValue ?? 0)
                        break
                    }
                }

                let rsi = RSI(period: self.StochRSILenthRSI ?? 14)
                rsi.sampleList = samples
                let rsiResult = rsi.CalculateNormalRSI()
                
                self.RSIValues = rsiResult.RSI
                self.candidateRSIValues(samples: samples, symbol: self.symbol)
                self.updateChartData()
                self.priceChartView.animate(xAxisDuration: 0.1)
                self.rsiChartView.animate(xAxisDuration: 0.1)
                self.stocRSICahrtView.animate(xAxisDuration: 0.1)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func candidateRSIValues(samples: [Double?], symbol: String) {
        
        let rsi = RSI(period: self.StochRSILenthRSI ?? 14)
        rsi.sampleList = samples
        let rsiResult = rsi.CalculateNormalRSI()
        
        let stoRSIResult = StochasticRSI(period: self.StochRSILenthStock ?? 12).calculateStochasticRSI(list: rsiResult.RSI)
        if SmoothD != nil {
            stocRSISmoothD = MovingAverage(period: SmoothD!).calculateSimpleMovingAvarage(list: stoRSIResult)
            if SmoothK != nil {
                stocRSISmoothK = MovingAverage(period: SmoothK!).calculateSimpleMovingAvarage(list: stocRSISmoothD)
                if SmoothT != nil {
                    stocRSISmoothT = MovingAverage(period: SmoothT!).calculateSimpleMovingAvarage(list: stocRSISmoothK)
                }
            }
        }
    }
    
    override func updateChartData() {
        if self.shouldHideData {
            priceChartView.data = nil
            return
        }
        
        self.setDataCount(candlesArray.count)
    }
    
    func setDataCount(_ count: Int) {
        
        let yVals1 = (0..<count).map { (i) -> CandleChartDataEntry in
            let candle = candlesArray[i]
            updateMaxAndMin(candle: candle)
            return CandleChartDataEntry(x: Double(i), shadowH: candle.high?.doubleValue ?? 0.0, shadowL: candle.low?.doubleValue ?? 0.0, open: candle.open?.doubleValue ?? 0.0, close: candle.close?.doubleValue ?? 0.0)
        }
        
        updateLeftConstraint()
        
        let set1 = CandleChartDataSet(entries: yVals1, label: "Data Set")
        set1.axisDependency = .left
        set1.setColor(UIColor(white: 80/255, alpha: 1))
        set1.drawIconsEnabled = false
        set1.shadowColor = .darkGray
        set1.shadowWidth = 0.7
        set1.decreasingColor = .red
        set1.decreasingFilled = true
        set1.increasingColor = UIColor(red: 122/255, green: 242/255, blue: 84/255, alpha: 1)
        set1.increasingFilled = true
        set1.neutralColor = .blue
        
        let data = CandleChartData(dataSet: set1)
        priceChartView.data = data
        
        let rsiValues = (0..<count).map { (i) -> ChartDataEntry in
            if i < (count - RSIValues.count) {
                return ChartDataEntry(x: Double(i), y: 50)
            }
            let val = RSIValues[i - (count - RSIValues.count)] ?? 0
            return ChartDataEntry(x: Double(i), y: val)
        }
        
        var smoothD = [ChartDataEntry]()
        var smoothK = [ChartDataEntry]()
        var smoothT = [ChartDataEntry]()

        if stocRSISmoothD.count > 0 {
            let stocRsiValues = (0..<count).map { (i) -> ChartDataEntry in
                if i < (count - stocRSISmoothD.count) {
                    return ChartDataEntry(x: Double(i), y: 50)
                }
                let val = stocRSISmoothD[i - (count - stocRSISmoothD.count)] ?? 0
                return ChartDataEntry(x: Double(i), y: val)
            }
            smoothD = stocRsiValues
        }

        if stocRSISmoothK.count > 0 {
            let stocRsiValues = (0..<count).map { (i) -> ChartDataEntry in
                if i < (count - stocRSISmoothK.count) {
                    return ChartDataEntry(x: Double(i), y: 50)
                }
                let val = stocRSISmoothK[i - (count - stocRSISmoothK.count)] ?? 0
                return ChartDataEntry(x: Double(i), y: val)
            }
            smoothK = stocRsiValues
        }
        
        if stocRSISmoothT.count > 0 {
            let stocRsiValues = (0..<count).map { (i) -> ChartDataEntry in
                if i < (count - stocRSISmoothT.count) {
                    return ChartDataEntry(x: Double(i), y: 50)
                }
                let val = stocRSISmoothT[i - (count - stocRSISmoothT.count)] ?? 0
                return ChartDataEntry(x: Double(i), y: val)
            }
            smoothT = stocRsiValues
        }
        
        let rsiData = LineChartDataSet(entries: rsiValues, label: "")
        rsiData.setColor(.red)
        rsiData.setCircleColor(.clear)
        rsiData.lineWidth = 2
        rsiData.circleRadius = 3
        rsiData.fillAlpha = 150/255
        rsiData.fillColor = UIColor.yellow.withAlphaComponent(200/255)
        rsiData.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        rsiData.drawCircleHoleEnabled = false
        
        let rdata = LineChartData(dataSets: [rsiData])
        rdata.setValueTextColor(.clear)
        rdata.setValueFont(.systemFont(ofSize: 9))
        
        rsiChartView.data = rdata
        
        let smoothDstocRsiData = LineChartDataSet(entries: smoothD, label: "")
        smoothDstocRsiData.setColor(UIColor(red: 79/255, green: 7/255, blue: 96/255, alpha: 1))
        smoothDstocRsiData.setCircleColor(.clear)
        smoothDstocRsiData.lineWidth = 2
        smoothDstocRsiData.circleRadius = 3
        smoothDstocRsiData.fillAlpha = 65/255
        smoothDstocRsiData.fillColor = UIColor.yellow.withAlphaComponent(200/255)
        smoothDstocRsiData.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        smoothDstocRsiData.drawCircleHoleEnabled = false
        
        let smoothKstocRsiData = LineChartDataSet(entries: smoothK, label: "")
        smoothKstocRsiData.setColor(UIColor(red: 79/255, green: 143/255, blue: 0/255, alpha: 1))
        smoothKstocRsiData.setCircleColor(.clear)
        smoothKstocRsiData.lineWidth = 2
        smoothKstocRsiData.circleRadius = 3
        smoothKstocRsiData.fillAlpha = 65/255
        smoothKstocRsiData.fillColor = UIColor.yellow.withAlphaComponent(200/255)
        smoothKstocRsiData.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        smoothKstocRsiData.drawCircleHoleEnabled = false
        
        let smoothTstocRsiData = LineChartDataSet(entries: smoothT, label: "")
        smoothTstocRsiData.setColor(UIColor(red: 180/255, green: 60/255, blue: 28/255, alpha: 1))
        smoothTstocRsiData.setCircleColor(.clear)
        smoothTstocRsiData.lineWidth = 2
        smoothTstocRsiData.circleRadius = 3
        smoothTstocRsiData.fillAlpha = 65/255
        smoothTstocRsiData.fillColor = UIColor.yellow.withAlphaComponent(200/255)
        smoothTstocRsiData.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        smoothTstocRsiData.drawCircleHoleEnabled = false
        
        let stocData = LineChartData(dataSets: [smoothDstocRsiData, smoothKstocRsiData, smoothTstocRsiData])
        stocData.setValueTextColor(.clear)
        stocData.setValueFont(.systemFont(ofSize: 9))
        
        stocRSICahrtView.data = stocData
    }
    
    func updateMaxAndMin(candle: CandleObject) {
        if (candle.high?.doubleValue ?? 0.0) > priceChartView.leftAxis.axisMaximum {
            priceChartView.leftAxis.axisMaximum = (candle.high?.doubleValue ?? 0.0)
        } else if (candle.low?.doubleValue ?? 0.0) < priceChartView.leftAxis.axisMinimum {
            priceChartView.leftAxis.axisMinimum = (candle.low?.doubleValue ?? 0.0)
        }
    }
    
    func updateLeftConstraint() {
//        var minPrice = priceChartView.chartYMin.toString()
//        var maxPrice = priceChartView.chartYMax.toString()
//        while minPrice.last == "0" {
//            minPrice.removeLast()
//        }
//
//        while maxPrice.last == "0" {
//            maxPrice.removeLast()
//        }
//
//        while minPrice.count < maxPrice.count {
//            minPrice.append("0")
//        }
//
        guard let symbolObject = ExchangeHandler.shared.getSyncSymbol(symbol: symbol) else { return }
        guard let priceFilter = symbolObject.filters?.filter({ $0.filterType == .PRICE_FILTER }) else { return }
        guard var tickSize = priceFilter.first?.tickSize else { return }
        
        while tickSize.last == "0" {
            tickSize.removeLast()
        }
        
        if let font = UIFont(name: "HelveticaNeue-Light", size: 10) {
            let size = textWidth(text: tickSize, font: font)
            rsiLeftConstraint.constant = CGFloat(size - 18)
            stocLeftConstraint.constant = CGFloat(size - 18)
        }
    }
    
    func textWidth(text: String, font: UIFont?) -> CGFloat {
        let attributes = font != nil ? [NSAttributedString.Key.font: font] : [:]
        return text.size(withAttributes: attributes as [NSAttributedString.Key : Any]).width
    }
    
    @IBAction func showRSISwitchValueChanged(_ sender: UISwitch) {
        rsiChartView.isHidden = !sender.isOn
    }
    
    @IBAction func showStochasticSwitchValueChanged(_ sender: UISwitch) {
        stocRSICahrtView.isHidden = !sender.isOn
    }
}
