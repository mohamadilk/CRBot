//
//  ActiveOrdersViewController.swift
//  Crypto Bot
//
//  Created by mohamad ilk on 8/21/1398 AP.
//  Copyright © 1398 AP Mohammad Ilkhani. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ActiveOrdersViewController: UIViewController, NVActivityIndicatorViewable {

    var viewModel: ActiveOrdersViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            self.segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ActiveOrdersViewModel(viewController: self)
        tableView.tableFooterView = UIView()
        _ = PumpHandler.shared
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAnimating()
        viewModel.getUserQueuedOrders()
        viewModel.getUserActiveOrders()
        
    }

    @objc func segmentChanged() {
        viewModel.getUserQueuedOrders()
        reloadData()
    }
    
    func checkForEmptyState() {
        stopAnimating()
        if segmentedControl.selectedSegmentIndex == 0 {
            if let orders = viewModel?.ordersArray, orders.count > 0 {
                emptyStateLabel.isHidden = true
            } else {
                emptyStateLabel.text = "You don't have any open order."
                emptyStateLabel.isHidden = false
            }
        } else {
            if let orders = viewModel?.queuedOrdersArray, orders.count > 0 {
                emptyStateLabel.isHidden = true
            } else {
                emptyStateLabel.text = "You don't have any queued order."
                emptyStateLabel.isHidden = false
            }
        }
    }
    
    func reloadData() {
        self.checkForEmptyState()
        self.tableView.reloadData()
    }
}

extension ActiveOrdersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return viewModel?.ordersArray.count ?? 0
        } else {
            return viewModel?.queuedOrdersArray.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if segmentedControl.selectedSegmentIndex == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "ActiveOrderTableViewCell") as! ActiveOrderTableViewCell
            var model: OrderDetailObject!
            model = viewModel.ordersArray[indexPath.row]
            cell.configureWith(model: model)
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "QueuedOrderTableViewCell") as! QueuedOrderTableViewCell
            var model: QueuedOrderObject!
            model = viewModel.queuedOrdersArray[indexPath.row]
            cell.configureWith(model: model)
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        }
    }
    
    
}

extension ActiveOrdersViewController :ActiveOrderTableViewCellDelegate {
    func didCancelOrder(model: OrderDetailObject) {
        let alert = UIAlertController(title: "Are you sure you want to cancel this order?", message: nil, preferredStyle: .alert)
        let delete = UIAlertAction(title: "Yes", style: .destructive) { _ in
            if model.orderListId ?? 0 > 0 {
                AccountHandler.shared.cancelOCOOrder(model: model) { [weak self] (success, error) in
                    guard error == nil else {
                        AlertUtility.showAlert(title: error?.localizedDescription ?? "Failed to cancel order, please try again.")
                        return
                    }
                    self?.viewModel.getUserActiveOrders()
                    self?.viewModel.getUserQueuedOrders()
                }
            } else {
                AccountHandler.shared.cancelOrder(model: model) { [weak self] (order, error) in
                    guard error == nil else {
                        AlertUtility.showAlert(title: error?.localizedDescription ?? "Failed to cancel order, please try again.")
                        return
                    }
                    self?.viewModel.getUserActiveOrders()
                    self?.viewModel.getUserQueuedOrders()
                }
            }
        }
       let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
       
       alert.addAction(delete)
       alert.addAction(cancel)
       
       present(alert, animated: true, completion: nil)
        
    }
}

extension ActiveOrdersViewController :QueuedOrderTableViewCellDelegate {
    func didCancelOrder(model: QueuedOrderObject) {

        let alert = UIAlertController(title: "Are you sure?", message: "By deleting this order, the placed amount will equally be shared between other queued orders if any available.", preferredStyle: .alert)
        
        let delete = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.viewModel.deleteQueuedOrder(model: model)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(delete)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)

    }
}

