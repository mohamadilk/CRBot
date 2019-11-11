//
//  TargetsCell.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/28/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import UIKit

protocol TargetsCellDelegate {
    
    func didRemove(target: String)
}

class TargetsCell: BaseTableViewCell {

    var targetsArray = [String]()
    var targetsDelegate: TargetsCellDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "TargetCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TargetCollectionViewCell")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 115, height: 50)
        flowLayout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = flowLayout
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func addNewTarget(price: String) {
        if targetsArray.contains(price) { return }
        if targetsArray.count >= 5 {
            AlertUtility.showAlert(title: "You have reached the maximum number of targets!")
            return
        }
        targetsArray.append(price)
        collectionView.reloadData()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        targetsArray = []
    }
    
}

extension TargetsCell: UICollectionViewDelegate {
    
}

extension TargetsCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        targetsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TargetCollectionViewCell", for: indexPath) as! TargetCollectionViewCell
//        let cell = TargetCollectionViewCell(frame: CGRect(x: 0, y: 0, width: 115, height: 50))
        cell.priceLabel?.text = targetsArray[indexPath.row]
        cell.delegate = self
        return cell
    }
}

extension TargetsCell: TargetCollectionViewCellDelegate {
    func didRemove(target: String) {
        targetsArray = targetsArray.filter({ $0 != target })
        targetsDelegate?.didRemove(target: target)
        collectionView.reloadData()
    }
}
