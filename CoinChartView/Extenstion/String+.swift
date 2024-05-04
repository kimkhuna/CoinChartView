//
//  String+.swift
//  CoinChartView
//
//  Created by 김경훈 on 4/27/24.
//

import Foundation

extension String{
    func insertComma() -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        if let value = Float(self){
            let result = numberFormatter.string(from: NSNumber(value: value))
            return "₩ " + result!
        }
        else{
            return "₩ " + self
        }
    }
}
