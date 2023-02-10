//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didFailWithErrors(error: Error)
    func didGetRate(_ coinManager: CoinManager, coinData: CoinData)
    
}

struct CoinManager {
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "19E58E0E-4B38-4BDF-BA05-3CECD75F00CF"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    
    // - MARK: METHODS
    func getCoinPrice(for currency: String) {
        // final url should look like https://rest.coinapi.io/v1/exchangerate/BTC/{currency}?apikey={apiKey}
        let url = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: url)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) {data, response, error in
                if error != nil {
                    delegate?.didFailWithErrors(error: error!)
//                    print(error!)
                    return
                }
                if let safeData = data {
//                    let dataString = String(data: safeData, encoding: .utf8)
//                    print(dataString!)
                    if let bitcoinData = parseJSON(safeData) {
                        delegate?.didGetRate(self, coinData: bitcoinData)
                    }
                    
                }
            }
            task.resume()
        }
    }
    
    
    func parseJSON(_ data: Data) -> CoinData? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let rate = decodedData.rate
            let currency = decodedData.asset_id_quote
            return CoinData(rate: rate, asset_id_quote: currency)
        } catch {
            print(error)
            return nil
        }
    }
}
