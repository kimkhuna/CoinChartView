//
//  MainViewController.swift
//  CoinChartView
//
//  Created by 김경훈 on 4/27/24.
//

import UIKit
import SnapKit
import Charts

final class MainViewController: UIViewController{
    
    var market: String?
    var marketCode: String?
    var marketModel: [MarketModel] = []
    var marketNameArray: [String] = []
    var currentMarket: MarketModel?
    
    private let marketManager = MarketManager()
    private let coinManager = CoinManager()
    
    private lazy var searchButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.addTarget(self, action: #selector(didTapSearchBarButton), for: .touchUpInside)
       return button
    }()
    
    private lazy var marketLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 24.0, weight: .semibold)
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        getMarketData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupViews()
    }
    // MARK: - SetUp
    private func setupViews(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchButton)
        
        [marketLabel].forEach{
            view.addSubview($0)
        }
        
        let defaultSpacing: CGFloat = 16.0
        
        marketLabel.snp.makeConstraints{
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(defaultSpacing)
            $0.leading.equalToSuperview().offset(defaultSpacing)
            
        }
    }
    // MARK: - Action
    @objc func didTapSearchBarButton(){
        
    }
    // MARK: - Network
    private func getMarketData(){
        marketManager.fetchMarketData(completionHandler: { result in
            switch(result){
            case .success(let data):
                self.marketModel = data
                self.marketNameArray = data.map{ $0.korean_name } // 종목 이름만 배열 추가
                self.market = self.marketModel.first?.korean_name
                self.marketCode = self.marketModel.first?.market
                DispatchQueue.main.async {
                    self.marketLabel.text = self.marketModel.first?.korean_name
                }
                self.getChartData(code: self.marketCode)
                break
            case .failure(let error):
                print(error)
                break
            }
        })
    }
    
    private func getChartData(code: String?){
        coinManager.fetchCoinData(market: code, completionHandler: { result in
            switch(result){
            case .success(let data):
                print(data)
                break
            case .failure(let error):
                print(error)
                break
            }
        })
    }
}
