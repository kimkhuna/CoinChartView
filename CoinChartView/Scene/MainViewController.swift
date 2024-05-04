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
    
    var currentMarket: MarketModel? // 현재 종목
    
    private var coinData: [CoinModel] = []
    private var coinPricesArray: [Double] = []
    private var coinTimesArray: [Double] = []
    
    private let marketManager = MarketManager()
    private let coinManager = CoinManager()
    
    let markerView = CustomMarkerView()
    
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
        chartView.delegate = self
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
        // 차트에 데이터가 없을 경우
        self.chartView.noDataText = "출력 데이터가 없습니다."
        self.chartView.noDataFont = .systemFont(ofSize: 20)
        self.chartView.noDataTextColor = .lightGray
        // Chart Configuration
        self.chartView.backgroundColor = .white // 차트 기본 뒷 배경색
        self.chartView.legend.enabled = false   // x축 세로선 제거
        self.markerView.chartView = self.chartView // marker에 chart 등록
        self.chartView.marker = markerView // chart에 marker등록
        // 왼쪽 축 제거
        self.chartView.leftAxis.enabled = false
        // 오른쪽 축 제거
        self.chartView.rightAxis.enabled = false
        // x축
        self.chartView.xAxis.enabled = true
        self.chartView.xAxis.labelFont = .systemFont(ofSize: 11, weight: .light)
        // x축 처음, 마지막 label text 잘리지 않게 수정
        self.chartView.xAxis.avoidFirstLastClippingEnabled = true
        // x축 Label
        self.chartView.xAxis.labelPosition = .bottom // Label 위치
        self.chartView.xAxis.setLabelCount(6, force: true) // Label 개수
        self.chartView.xAxis.valueFormatter = CustomAxisFormatter() // Label Formatter
        // 생성한 함수 사용해서 데이터 적용
        self.setLineData(lineChartView: self.chartView, 
                         lineChartDataEntries: self.entryData(x: self.coinTimesArray, y: self.coinPricesArray))
    }
    // MARK: - Chart
    // 데이터 적용하기
    func setLineData(lineChartView: LineChartView, lineChartDataEntries: [ChartDataEntry]) {
        // Entry들을 이용해 Data Set 만들기
        let lineChartdataSet = LineChartDataSet(entries: lineChartDataEntries)
        lineChartdataSet.drawCirclesEnabled = false // 점 제거
        lineChartdataSet.highlightEnabled = true
        lineChartdataSet.highlightLineWidth = 1.0
        lineChartdataSet.highlightColor = .orange
        lineChartdataSet.lineWidth = 1.5
        lineChartdataSet.colors = [.systemBlue] // 라인 색상 설정
        // DataSet을 차트 데이터로 넣기
        let lineChartData = LineChartData(dataSet: lineChartdataSet)
        // 데이터 출력
        lineChartView.data = lineChartData
    }
    // entry 만들기
    func entryData(x: [Double], y: [Double]) -> [ChartDataEntry] {
        // entry 담을 array
        var lineDataEntries: [ChartDataEntry] = []
        // 담기
        for i in 0 ..< x.count {
            let lineDataEntry = ChartDataEntry(x: x[i], y: y[i])
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
        let marketListViewController = MarketListViewController()
        marketListViewController.marketData = self.marketData
        self.navigationController?.pushViewController(marketListViewController, animated: true)
    }
    // MARK: - Network
    private func getMarketData(){
        marketManager.fetchMarketData(completionHandler: { result in
            switch(result){
            case .success(let data):
                self.marketData = data
                self.marketNameArray = data.map{ $0.korean_name } // 종목 이름만 배열 추가
                // 현재 종목이 없을 경우(배열의 첫번째 값(비트코인)으로 설정)
                if(self.currentMarket == nil){
                    self.market = self.marketData.first?.korean_name
                    self.marketCode = self.marketData.first?.market
                    self.getChartData(code: self.marketCode)
                    DispatchQueue.main.async {
                        self.marketLabel.text = self.marketData.first?.korean_name
                    }
                }
                else{
                    self.market = self.currentMarket?.korean_name
                    self.marketCode = self.currentMarket?.market
                    self.getChartData(code: self.currentMarket?.market)
                    DispatchQueue.main.async {
                        self.marketLabel.text = self.currentMarket?.korean_name
                    }
                }
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
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    formatter.minimumFractionDigits = 0 // 최소 소수점 자릿수
                    formatter.maximumFractionDigits = 5 // 최대 소수점 자릿수
                    // 숫자를 문자열로 변환
                    if let price =  self.coinData.first?.price,
                       let formattedNumberString = formatter.string(from: NSNumber(value: price)) {
                        self.priceLabel.text = formattedNumberString.insertComma()
                    }
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
// MARK: - Chart Delegate
extension MainViewController: ChartViewDelegate{
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("y : \(entry.y)")
        self.markerView.priceLabel.text = "\(entry.y)"
    }
}

// AxisValueFormatter 채택하여 Axis Label 설정
class CustomAxisFormatter: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        
        return dateFormatter.string(from: date)
    }
}
