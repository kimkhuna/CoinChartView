//
//  CustomMarkerView.swift
//  CoinChartView
//
//  Created by 김경훈 on 5/4/24.
//

import UIKit
import SnapKit
import DGCharts

class CustomMarkerView: MarkerView{
    
    let contentView = UIView()
    let priceLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initUI()
    }
    private func initUI() {
        priceLabel.textColor = .black
        addSubview(priceLabel)
        
        priceLabel.snp.makeConstraints{
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }
}
