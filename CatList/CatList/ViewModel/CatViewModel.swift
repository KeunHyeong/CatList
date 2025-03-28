//
//  CatViewModel.swift
//  thecat
//
//  Created by 장근형 on 3/27/25.
//

import Foundation
import Combine
import SwiftUI

class CatViewModel: ObservableObject {
    @Published var cats: [CatImage] = []
    
    private var cancellable: Set<AnyCancellable> = []
    
    init () {
        fetchCats()
    }
    
    private func fetchCats() {
//        SearchClient.fetchTestData()
//            .sink(receiveCompletion: { _ in },
//                  receiveValue: { [weak self] cats in
//                self?.cats = cats
//            })
//            .store(in: &cancellable)
    }
}
