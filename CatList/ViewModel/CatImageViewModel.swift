//
//  CatViewModel.swift
//  thecat
//
//  Created by 장근형 on 3/27/25.
//

import Foundation
import Combine
import SwiftUI
import RealmSwift

class CatImageViewModel: ObservableObject {
    @Published var catImages: [CatImage] = []
    @Published var isLoading: Bool = false
    private var apiService: CatAPIService
    
    private var cancellable: Set<AnyCancellable> = []
    
    init (apiService: CatAPIService = .init()) {
        self.apiService = apiService
        
        loadFromLocalDB()
    }
    
    func fetchCatImages() {
        guard !isLoading else { return }
        if NetworkManager.shared.isOnline {
            isLoading = true
            apiService.fetchCatImages()
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("에러: \(error)")
                    }
                }, receiveValue: { [weak self] images in
                    self?.catImages.append(contentsOf: images)
                    self?.saveToLocalDB(images: images)
                })
                .store(in: &cancellable)
        }else {
            loadFromLocalDB()
        }
    }
    
    private func saveToLocalDB(images: [CatImage]) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(images, update: .modified)
        }
    }
    
    private func loadFromLocalDB(){
        let realm = try! Realm()
        let objects = realm.objects(CatImage.self)
        catImages = Array(objects).shuffled()
    }
}
