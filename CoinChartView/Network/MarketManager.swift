//
//  MarketManager.swift
//  CoinChartView
//
//  Created by 김경훈 on 4/27/24.
//

import Foundation
import Alamofire

struct MarketManager{
    
    func fetchMarketData(completionHandler: @escaping ((Result<[MarketModel], Error>) -> Void)){
        let url = "https://api.upbit.com/v1/market/all"
        AF.request(url, method: .get)
            .responseData(completionHandler: { response in
                switch(response.result){
                case .success(let data):
                    let decoder = JSONDecoder()
                    do{
                        let market = try decoder.decode([MarketModel].self, from: data)
                        completionHandler(.success(market))
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
            .resume()
    }
}
