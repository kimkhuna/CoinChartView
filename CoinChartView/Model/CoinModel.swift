//
//  CoinModel.swift
//  CoinChartView
//
//  Created by 김경훈 on 4/27/24.
//

import Foundation

struct CoinModel: Decodable{
    let market: String
    let timestamp: Double
    let price: Double
    
    enum CodingKeys: String, CodingKey{
        case market
        case timestamp
        case price = "trade_price"
    }
}
