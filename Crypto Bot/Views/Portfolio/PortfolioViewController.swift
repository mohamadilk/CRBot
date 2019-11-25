//
//  PortfolioViewController.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 9/3/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import UIKit
import PieCharts
import Kingfisher

class PortfolioViewController: UIViewController {

    var viewModel: PortfolioViewModel?
    
    @IBOutlet weak var chartView: PieChart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = PortfolioViewModel(viewController: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        chartView.layers = [createCustomViewsLayer(), createTextLayer()]
        chartView.delegate = self
    }
    
    func reloadData() {
        chartView.models = createModels()
    }
        
        // MARK: - Models
        
        fileprivate func createModels() -> [PieSliceModel] {
            
            let alpha: CGFloat = 0.5
            var slicesArray = [PieSliceModel]()
            var colorNum = 0
            
            let colorsArray = [
            UIColor.brown.withAlphaComponent(alpha),
            UIColor.yellow.withAlphaComponent(alpha),
            UIColor.red.withAlphaComponent(alpha),
            UIColor.gray.withAlphaComponent(alpha),
            UIColor.green.withAlphaComponent(alpha),
            UIColor.blue.withAlphaComponent(alpha),
            UIColor.brown.withAlphaComponent(alpha),
            UIColor.darkGray.withAlphaComponent(alpha),
            UIColor.orange.withAlphaComponent(alpha),
            UIColor.cyan.withAlphaComponent(alpha)]
            
            for balance in viewModel?.datasource ?? [] {
                if (balance.free?.doubleValue ?? 0) + (balance.locked?.doubleValue ?? 0) > 0.01 {
                    let slice = PieSliceModel(value: (balance.free?.doubleValue ?? 0) + (balance.locked?.doubleValue ?? 0), color: colorsArray[colorNum], obj: balance.asset)
                    slicesArray.append(slice)
                    colorNum = (colorNum + 1) % 10
                }
            }
            return slicesArray
        }
        
        // MARK: - Layers
        
        fileprivate func createCustomViewsLayer() -> PieCustomViewsLayer {
            let viewLayer = PieCustomViewsLayer()
            
            let settings = PieCustomViewsLayerSettings()
            settings.viewRadius = 135
            settings.hideOnOverflow = false
            viewLayer.settings = settings
            
            viewLayer.viewGenerator = createViewGenerator()
            
            return viewLayer
        }
        
        fileprivate func createTextLayer() -> PiePlainTextLayer {
            let textLayerSettings = PiePlainTextLayerSettings()
            textLayerSettings.viewRadius = 75
            textLayerSettings.hideOnOverflow = true
            textLayerSettings.label.font = UIFont.systemFont(ofSize: 12)
            
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 1
            textLayerSettings.label.textGenerator = {slice in
                return formatter.string(from: slice.data.percentage * 100 as NSNumber).map{"\($0)%"} ?? ""
            }
            
            let textLayer = PiePlainTextLayer()
            textLayer.settings = textLayerSettings
            return textLayer
        }
        
        fileprivate func createViewGenerator() -> (PieSlice, CGPoint) -> UIView {
            return {slice, center in
                
                let asset = slice.data.model.obj as? String ?? ""
                
                let container = UIView()
                container.frame.size = CGSize(width: 60, height: 15)
                container.center = center
                let view = UIImageView()
                view.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
                container.addSubview(view)
                
                let specialTextLabel = UILabel()
                specialTextLabel.textAlignment = .left
                specialTextLabel.text = asset
                specialTextLabel.font = UIFont.systemFont(ofSize: 11)
                specialTextLabel.sizeToFit()

                specialTextLabel.sizeToFit()
                specialTextLabel.frame = CGRect(x: 20, y: 0, width: 40, height: 15)
                container.addSubview(specialTextLabel)
                container.frame.size = CGSize(width: 60, height: 15)
                
    //            if slice.data.id == 3 || slice.data.id == 0 {
    //
    //            }
                
                let builder = CryptoIconURLBuilder(style: .color, code: asset, size: 45)
                let url = builder.url
                
                view.kf.setImage(with: url)
                            
                return container
            }
        }
        
    
}

extension PortfolioViewController: PieChartDelegate {
    func onSelected(slice: PieSlice, selected: Bool) {
        print("Selected: \(selected), slice: \(slice)")
    }
}
