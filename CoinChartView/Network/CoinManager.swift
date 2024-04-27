//
//  CoinManager.swift
//  CoinChartView
//
//  Created by 김경훈 on 4/27/24.
//

import Foundation
import Alamofire

struct CoinManager{
    func fetchCoinData(market: String?, completionHandler: @escaping (Result<[CoinModel], Error>) -> Void){
        let url = "https://api.upbit.com/v1/candles/minutes/5"
        
        let params: Parameters = [
            "market" : market!,
            "count" : 200
        ]
        
        AF.request(url, method: .get, parameters: params)
            .responseData(completionHandler: { response in
                switch(response.result){
                case .success(let data):
                    let decoder = JSONDecoder()
                    do{
                        let coins = try decoder.decode([CoinModel].self, from: data)
                        completionHandler(.success(coins))
                    }
                    catch let e{
                        completionHandler(.failure(e))
                    }
                    break
                case .failure(let error):
                    completionHandler(.failure(error))
                    break
                }
            })
    }
}
