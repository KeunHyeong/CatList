//
//  CatAPIService.swift
//  CatList
//
//  Created by 장근형 on 3/28/25.
//

import Alamofire
import Combine
import Foundation

class CatAPIService {
    static let shared = CatAPIService()
    private let baseURL: URL = URL(string:"https://api.thecatapi.com/v1/images/search")!
    
    func fetchCatImages(limit: Int = 10) -> AnyPublisher<[CatImage], Error> {
        let url = baseURL.appending(queryItems: [URLQueryItem(name: "limit", value: String(limit))])
        print("api count \(limit)")
        return AF.request(url)
            .publishData()
            .tryMap { $0.data ?? Data() }
            .decode(type: [CatImage].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
