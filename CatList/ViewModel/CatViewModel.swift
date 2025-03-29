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

class CatViewModel: ObservableObject {
    @Published var catImages: [CatImage] = []
    
    private var cancellable: Set<AnyCancellable> = []
    
    init () {
        fetchCats()
    }
    
    private func fetchCats() {

    }
    
    private func saveLocalDB(images: [CatImage]) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(images, update: .modified)
        }
    }
    
    private func loadFLocalDB(){
        let realm = try! Realm()
        let objects = realm.objects(CatImage.self)
        catImages = Array(objects).shuffled()
    }
}
