//
//  MainViewController.swift
//  CoinChartView
//
//  Created by 김경훈 on 4/27/24.
//

import UIKit
import SnapKit
import DGCharts

final class MainViewController: UIViewController{
    
    var market: String?
    var marketCode: String?
    var marketData: [MarketModel] = []
    var marketNameArray: [String] = []
    
    private var coinData: [CoinModel] = []
    private var coinPricesArray: [Double] = []
    private var coinTimesArray: [Double] = []
    
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
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16.0, weight: .light)
        return label
    }()
    
    private lazy var chartView: LineChartView = {
       let chartView = LineChartView()
        return chartView
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
        
        [marketLabel, priceLabel, chartView].forEach{
            view.addSubview($0)
        }
        
        let defaultSpacing: CGFloat = 16.0
        
        marketLabel.snp.makeConstraints{
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(defaultSpacing)
            $0.leading.equalToSuperview().offset(defaultSpacing)
        }
        
        priceLabel.snp.makeConstraints{
            $0.top.equalTo(marketLabel.snp.bottom).offset(8.0)
            $0.leading.equalToSuperview().offset(defaultSpacing)
        }
        
        chartView.snp.makeConstraints{
            $0.top.equalTo(priceLabel.snp.bottom).offset(defaultSpacing)
            $0.leading.equalToSuperview().offset(8.0)
            $0.trailing.equalToSuperview().inset(8.0)
            $0.bottom.equalToSuperview().inset(32.0)
        }
    }
    
    private func setupChart(){
        self.chartView.noDataText = "출력 데이터가 없습니다."
        // 기본 문구 폰트
        self.chartView.noDataFont = .systemFont(ofSize: 20)
        // 기본 문구 색상
        self.chartView.noDataTextColor = .lightGray
        // 차트 기본 뒷 배경색
        self.chartView.backgroundColor = .white
        // 구분값 보이기
        let timeStrArray = self.coinTimesArray.map{ convertDoubleToString($0) }
        // x축 제거
        self.chartView.xAxis.enabled = false
        self.chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: timeStrArray)
        // x축 label 위치 아래로 변경
        self.chartView.xAxis.labelPosition = .bottom
        // x축 label의 font와 색상 설정
        self.chartView.xAxis.labelFont = .systemFont(ofSize: 13, weight: .light)
        // x축 세로선 제거
        self.chartView.xAxis.drawGridLinesEnabled = false
        // x축 처음, 마지막 label text 잘리지 않게 수정
        self.chartView.xAxis.avoidFirstLastClippingEnabled = true
        // x축 하단 범례 제거
        self.chartView.legend.enabled = false
        self.chartView.xAxis.setLabelCount(12, force: true)
        // 구분값 모두 보이기
        self.chartView.xAxis.setLabelCount(self.coinPricesArray.count, force: false)
        // 생성한 함수 사용해서 데이터 적용
        self.setLineData(lineChartView: self.chartView, 
                         lineChartDataEntries: self.entryData(values: self.coinPricesArray))
    }
    // MARK: - Chart
    // 데이터 적용하기
    func setLineData(lineChartView: LineChartView, lineChartDataEntries: [ChartDataEntry]) {
        // Entry들을 이용해 Data Set 만들기
        let lineChartdataSet = LineChartDataSet(entries: lineChartDataEntries)
        lineChartdataSet.drawCirclesEnabled = false // 점 제거
        lineChartdataSet.lineWidth = 1.5
        lineChartdataSet.colors = [.systemBlue] // 라인 색상 설정
        // DataSet을 차트 데이터로 넣기
        let lineChartData = LineChartData(dataSet: lineChartdataSet)
        // 데이터 출력
        lineChartView.data = lineChartData
    }
    // entry 만들기
    func entryData(values: [Double]) -> [ChartDataEntry] {
        // entry 담을 array
        var lineDataEntries: [ChartDataEntry] = []
        // 담기
        for i in 0 ..< values.count {
            let lineDataEntry = ChartDataEntry(x: Double(i), y: values[i])
            lineDataEntries.append(lineDataEntry)
        }
        // 반환
        return lineDataEntries
    }
    // TimeStamp to String
    func convertDoubleToString(_ times: Double) -> String{
        let date = Date(timeIntervalSince1970: times)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
    // MARK: - Action
    @objc func didTapSearchBarButton(){
        
    }
    // MARK: - Network
    private func getMarketData(){
        marketManager.fetchMarketData(completionHandler: { result in
            switch(result){
            case .success(let data):
                self.marketData = data
                self.marketNameArray = data.map{ $0.korean_name } // 종목 이름만 배열 추가
                self.market = self.marketData.first?.korean_name
                self.marketCode = self.marketData.first?.market
                DispatchQueue.main.async {
                    self.marketLabel.text = self.marketData.first?.korean_name
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
                self.coinData = data
                self.coinPricesArray = data.map{ $0.price }
                self.coinTimesArray = data.map{ $0.timestamp }
                
                DispatchQueue.main.async {
                    self.priceLabel.text = String(format: "%2.f", self.coinData.first?.price ?? 0.0)
                    self.setupChart()
                }
                
                break
            case .failure(let error):
                print(error)
                break
            }
        })
    }
}
