//
//  LineChart2ViewController.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

#if canImport(UIKit)
    import UIKit
#endif
import Charts

class LineChart2ViewController: BaseChartViewController {

    @IBOutlet var priceChartView: LineChartView!
    @IBOutlet var IndicatorChartView: LineChartView!
    
    private var RSIValues = [Double?]()
    private var stocRSIValues = [Double?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Stochastic RSI"
        
        priceChartView.delegate = self
        
        priceChartView.chartDescription?.enabled = false
        priceChartView.dragEnabled = true
        priceChartView.setScaleEnabled(true)
        priceChartView.pinchZoomEnabled = true
        
        IndicatorChartView.delegate = self
        
        IndicatorChartView.chartDescription?.enabled = false
        IndicatorChartView.dragEnabled = true
        IndicatorChartView.setScaleEnabled(true)
        IndicatorChartView.pinchZoomEnabled = true
        
        let l = priceChartView.legend
        l.form = .line
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.textColor = .black
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        
        let k = IndicatorChartView.legend
        k.form = .line
        k.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        k.textColor = .black
        k.horizontalAlignment = .left
        k.verticalAlignment = .bottom
        k.orientation = .horizontal
        k.drawInside = false
        
        let xAxis = priceChartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 11)
        xAxis.labelTextColor = .white
        xAxis.drawAxisLineEnabled = false
        
        let xsAxis = IndicatorChartView.xAxis
        xsAxis.labelFont = .systemFont(ofSize: 11)
        xsAxis.labelTextColor = .white
        xsAxis.drawAxisLineEnabled = false
        
        let leftAxis = priceChartView.leftAxis
        leftAxis.labelTextColor = UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)
        leftAxis.axisMaximum = 120
        leftAxis.axisMinimum = 0
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        
        let leftsAxis = IndicatorChartView.leftAxis
        leftsAxis.labelTextColor = UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)
        leftsAxis.axisMaximum = 120
        leftsAxis.axisMinimum = 0
        leftsAxis.drawGridLinesEnabled = true
        leftsAxis.granularityEnabled = true
        
        let rightAxis = priceChartView.rightAxis
        rightAxis.labelTextColor = .red
        rightAxis.axisMaximum = 120
        rightAxis.axisMinimum = 0
        rightAxis.granularityEnabled = false

        let rightsAxis = IndicatorChartView.rightAxis
        rightsAxis.labelTextColor = .red
        rightsAxis.axisMaximum = 120
        rightsAxis.axisMinimum = 0
        rightsAxis.granularityEnabled = false
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
            MarketDataServices.shared.fetchSymbolPriceTicker(symbol: self.symbol) { (symbolPrice, error) in
                guard error == nil, symbolPrice != nil else { return }
                
                MarketDataServices.shared.fetchCandlestickData(symbol: self.symbol, interval: self.candleSize.rawValue, limit: self.candlesCount) { (candlesArray, error) in
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
                        samples.append(candle.close?.doubleValue ?? 0)
                        break
                        }
                    }
                    samples.append(symbolPrice?.price?.doubleValue ?? 0)
                                        
                    let rsi = RSI(period: 14)
                    rsi.sampleList = samples
                    let rsiResult = rsi.CalculateNormalRSI()
                    
                    self.RSIValues = rsiResult.RSI
                    self.stocRSIValues = self.candidateRSIValues(samples: samples, symbol: self.symbol)
                    self.updateChartData()
                    self.priceChartView.animate(xAxisDuration: 0.1)
                    self.IndicatorChartView.animate(xAxisDuration: 0.1)
                }
            }
        })
    }
    
    private func candidateRSIValues(samples: [Double?], symbol: String) -> [Double?] {
        
        let rsi = RSI(period: 14)
        rsi.sampleList = samples
        let rsiResult = rsi.CalculateNormalRSI()
        
        let stoRSIResult = StochasticRSI(period: 12).calculateStochasticRSI(list: rsiResult.RSI)
        let smoothedRSI = MovingAverage(period: 3).calculateSimpleMovingAvarage(list: stoRSIResult)
        let finalRSI = MovingAverage(period: 3).calculateSimpleMovingAvarage(list: smoothedRSI)
        
        return finalRSI
    }
    
    override func updateChartData() {
        if self.shouldHideData {
            priceChartView.data = nil
            return
        }
        
        self.setDataCount(RSIValues.count)
    }
    
    func setDataCount(_ count: Int) {
        let rsiValues = (0..<count).map { (i) -> ChartDataEntry in
            let val = RSIValues[i] ?? 0
            return ChartDataEntry(x: Double(i), y: val)
        }
        
        let stocRsiValues = (0..<stocRSIValues.count).map { (i) -> ChartDataEntry in
            let val = stocRSIValues[i] ?? 0
            return ChartDataEntry(x: Double(i), y: val)
        }

        let rsiData = LineChartDataSet(entries: rsiValues, label: "RSI")
        rsiData.axisDependency = .right
        rsiData.setColor(.red)
        rsiData.setCircleColor(.darkGray)
        rsiData.lineWidth = 2
        rsiData.circleRadius = 3
        rsiData.fillAlpha = 65/255
        rsiData.fillColor = UIColor.yellow.withAlphaComponent(200/255)
        rsiData.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        rsiData.drawCircleHoleEnabled = false
        
        let data = LineChartData(dataSets: [rsiData])
        data.setValueTextColor(.clear)
        data.setValueFont(.systemFont(ofSize: 9))
        
        priceChartView.data = data
        
      let stocRsiData = LineChartDataSet(entries: stocRsiValues, label: "Stochastic RSI")
       stocRsiData.axisDependency = .right
        stocRsiData.setColor(UIColor(red: 79/255, green: 143/255, blue: 0/255, alpha: 1))
       stocRsiData.setCircleColor(.darkGray)
       stocRsiData.lineWidth = 2
       stocRsiData.circleRadius = 3
       stocRsiData.fillAlpha = 65/255
       stocRsiData.fillColor = UIColor.yellow.withAlphaComponent(200/255)
       stocRsiData.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
       stocRsiData.drawCircleHoleEnabled = false
        
        let stocData = LineChartData(dataSets: [stocRsiData])
        stocData.setValueTextColor(.clear)
        stocData.setValueFont(.systemFont(ofSize: 9))
        
        IndicatorChartView.data = stocData
    }
    
    override func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        super.chartValueSelected(chartView, entry: entry, highlight: highlight)
        
        self.priceChartView.centerViewToAnimated(xValue: entry.x, yValue: entry.y,
                                            axis: self.priceChartView.data!.getDataSetByIndex(highlight.dataSetIndex).axisDependency,
                                            duration: 1)
    }
}
