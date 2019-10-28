//
//  TargetsCell.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/28/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import UIKit

class TargetsCell: UITableViewCell {

    var targetsArray = ["0.00000345", "0.00000346", "0.00000347", "0.00000348"]
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "TargetCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TargetCollectionViewCell")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 115, height: 30)
        flowLayout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = flowLayout
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func addNewTarget(price: String) {
        targetsArray.append(price)
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
        cell.priceLabel.text = targetsArray[indexPath.row]
        cell.delegate = self
        return cell
    }
}

extension TargetsCell: TargetCollectionViewCellDelegate {
    func didRemove(target: String) {
        targetsArray = targetsArray.filter({ $0 != target })
        collectionView.reloadData()
    }
}
