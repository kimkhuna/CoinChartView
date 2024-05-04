//
//  MarketListViewController.swift
//  CoinChartView
//
//  Created by 김경훈 on 5/4/24.
//

import UIKit
import SnapKit

final class MarketListViewController: UIViewController{
    
    var marketData: [MarketModel] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews(){
        [tableView].forEach{
            view.addSubview($0)
        }
        
        tableView.snp.makeConstraints{
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        tableView.reloadData()
    }
}

extension MarketListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = marketData[indexPath.row].korean_name
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return marketData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mainViewController = self.navigationController?.viewControllers.first as? MainViewController {
                mainViewController.currentMarket = marketData[indexPath.row]
            }
            self.navigationController?.popToRootViewController(animated: true)
    }
}
