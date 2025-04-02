//
//  ImageLoader.swift
//  CatList
//
//  Created by 장근형 on 4/2/25.
//

import Foundation
import SwiftUI
import Alamofire
import Combine

class ImageLoader: ObservableObject {
    @Published var image: UIImage? = nil
    private var imageLoadCancellable: AnyCancellable?
    private static let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 100 * 1024 * 1024
        return cache
    }()
    
    func load(urlString: String, id: String) {
        //캐시에 있다면 그걸 사용
        if let cachedImage = Self.cache.object(forKey: id as NSString) {
            self.image = cachedImage
            return
        }
        
        // 로컬 파일 비동기 로드
        let fileURL = getFileURL(for: id)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            imageLoadCancellable = Just(fileURL)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .tryMap { try Data(contentsOf: $0) }
                .map { UIImage(data: $0) }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] uiImage in
                    guard let uiImage = uiImage else { return }
                    self?.image = uiImage
                    Self.cache.setObject(uiImage, forKey: id as NSString)
                })
            return
        }
        
        //이미지 다운로드
        guard let url = URL(string: urlString) else { return }
        imageLoadCancellable = AF.request(url)
            .publishData()
            .subscribe(on: DispatchQueue.global(qos: .background))
            .tryMap { $0.data ?? Data() }
            .map { UIImage(data: $0) }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] uiImage in
                guard let self = self, let uiImage = uiImage else { return }
                self.image = uiImage
                Self.cache.setObject(uiImage, forKey: id as NSString)
                self.saveImage(image: uiImage, for: id)
            })
    }
    
    private func saveImage(image: UIImage, for id: String) {
        let fileURL = getFileURL(for: id)
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            if let data = image.jpegData(compressionQuality: 0.5) {
                try? data.write(to: fileURL, options: .atomic)
            }
        }
    }
    
    private func getFileURL(for id: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(id).jpg")
    }
}
