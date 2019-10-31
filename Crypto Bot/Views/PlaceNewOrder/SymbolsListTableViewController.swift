//
//  SymbolsListTableViewController.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/31/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import UIKit

protocol SymbolsListTableViewControllerDelegate {
    
    func didSelect(symbol: SymbolObject)
}

class SymbolsListTableViewController: UITableViewController {

    var viewModel: SymbolsListViewModel!
    var datasource = [SymbolObject]()
    var filteredDatasource = [SymbolObject]()
    var isSearchMode = false
    
    var delegate: SymbolsListTableViewControllerDelegate?
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            self.searchBar.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        viewModel = SymbolsListViewModel(viewController: self)
        viewModel.getSymbolsArray { (symbolsArray, error) in
            guard error == nil, symbolsArray != nil else {
                AlertUtility.showAlert(title: "Something went wrong, pull down to retry.")
                return
            }
            
            self.datasource = symbolsArray!
            self.tableView.reloadData()
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchMode {
            return filteredDatasource.count
        } else {
            return datasource.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "symbolCell", for: indexPath)
        let symbol: SymbolObject!
        if isSearchMode {
            symbol = filteredDatasource[indexPath.row]
        } else {
            symbol = datasource[indexPath.row]
        }
        cell.textLabel?.text = "\(symbol.baseAsset ?? "") / \(symbol.quoteAsset ?? "")"
        return cell
    }
    
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let symbol: SymbolObject!
        if isSearchMode {
            symbol = filteredDatasource[indexPath.row]
        } else {
            symbol = datasource[indexPath.row]
        }
        delegate?.didSelect(symbol: symbol)
        dismiss(animated: true, completion: nil)
    }

}

extension SymbolsListTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            filteredDatasource = datasource
        } else {
            filteredDatasource = datasource.filter({ ($0.symbol?.lowercased().contains(searchText.lowercased()) ?? false) })
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        filteredDatasource = datasource
        isSearchMode = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearchMode = false
    }
}
