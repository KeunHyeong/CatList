//
//  CatViewModel.swift
//  CatList
//
//  Created by 장근형 on 3/27/25.
//
import Foundation
import Combine
import RealmSwift

protocol CatImageViewModelProtocol: ObservableObject {
    var catImages: [CatImage] { get set }
    
    func fetchMoreIfNeeded(currentItem: CatImage?)
}

final class CatImageViewModel: CatImageViewModelProtocol {
    @Published var catImages: [CatImage] = []
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadFromLocalDB()
        NetworkManager.shared.$isOnline
            .sink { [weak self] isOnline in
                if isOnline {
                    self?.fetchCatImages()
                }
            }
            .store(in: &cancellables)
    }
}

extension CatImageViewModel {
    func fetchMoreIfNeeded(currentItem: CatImage?) {
        guard !isLoading, let currentItem = currentItem else { return }
        guard let index = catImages.firstIndex(where: { $0.id == currentItem.id }) else { return }
        
        if index == catImages.count - 1 {
            fetchCatImages()
        }
    }
    
    private func fetchCatImages() {
        guard !isLoading else { return }
        if NetworkManager.shared.isOnline {
            isLoading = true
            CatAPIService.shared.fetchCatImages()
                .sink(receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure = completion {
                        self?.loadFromLocalDB()
                    }
                }, receiveValue: { [weak self] images in
                    guard let self = self else { return }
                    let existingIds = Set(self.catImages.map{$0.id})
                    let newImages = images.filter { !existingIds.contains($0.id) }
                    self.catImages.append(contentsOf: newImages)
                    self.saveToLocalDB(images: newImages)
                })
                .store(in: &cancellables)
        } else {
            loadFromLocalDB()
        }
    }
    
    private func saveToLocalDB(images: [CatImage]) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(images, update: .modified)
        }
    }
    
    private func loadFromLocalDB() {
        let realm = try! Realm()
        let objects = realm.objects(CatImage.self)
        catImages = Array(objects).shuffled()
    }
}
