//
//  NetworkManager.swift
//  CatList
//
//  Created by 장근형 on 3/29/25.
//

import Foundation
import Network

class NetworkManager: ObservableObject {
    @Published var isOnline: Bool = false
    private let monitor = NWPathMonitor()
    
    static let shared = NetworkManager()
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
                print("self.monitor.currentPath.status \(path.status)")
                print("[NetworkManager] pathUpdateHandler → isOnline: \(self?.isOnline ?? false)")
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isOnline = self.monitor.currentPath.status == .satisfied
            print("Network manager currentPath.status \(self.isOnline)")
        }
    }
}
