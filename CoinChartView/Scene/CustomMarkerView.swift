//
//  CustomMarkerView.swift
//  CoinChartView
//
//  Created by 김경훈 on 5/4/24.
//

import UIKit
import DGCharts

class CustomMarkerView: MarkerView{
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initUI()
    }
    private func initUI() {
        Bundle.main.loadNibNamed("CustomMarkerView", owner: self, options: nil)
        self.addSubview(contentView)
    }
}
