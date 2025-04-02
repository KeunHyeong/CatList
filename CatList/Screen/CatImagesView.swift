//
//  ContentView.swift
//  thecat
//
//  Created by 장근형 on 3/27/25.
//

import SwiftUI
import Combine

struct CatImagesView: View {
    @StateObject var vm = CatImageViewModel()
    
    var body: some View {
        CatListView<CatImageViewModel>(vm: vm)
            .navigationTitle("Cat Images")
    }
}

struct CatListView<VM: CatImageViewModelProtocol>: View {
    @ObservedObject var vm: CatImageViewModel
    
    var body: some View {
        GeometryReader { proxy in
            let isLandscape = proxy.size.width > proxy.size.height
            
            if isLandscape {
                NavigationStack {
                    LandscapeGridView(vm: vm)
                        .navigationTitle("Cat Images")
                }
                
            } else {
                NavigationStack {
                    PortraitListView(vm: vm)
                        .navigationTitle("Cat Images")
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct PortraitListView: View {
    @ObservedObject var vm: CatImageViewModel
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(vm.catImages, id: \.id) { image in
                    NavigationLink(destination: CatDetailView(catImage: image)) {
                        CatImageItemView(catImage: image)
                            .frame(width: 300, height: 300)
                        
                    }
                }
                
                if let lastImage = vm.catImages.last {
                    Color.clear
                        .frame(height: 10)
                        .onAppear {
                            vm.fetchMoreIfNeeded(currentItem: lastImage)
                        }
                }
            }
        }
    }
}

struct LandscapeGridView: View {
    @ObservedObject var vm: CatImageViewModel
    @State private var cancellable: AnyCancellable?
    @State private var offsetSubject = PassthroughSubject<CGFloat, Never>()
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                ScrollView(.horizontal) {
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(300), spacing: 10), count: 5)) {
                        ForEach(vm.catImages, id: \.id) { image in
                            NavigationLink(destination: CatDetailView(catImage: image)) {
                                CatImageItemView(catImage: image)
                                    .frame(width:300, height:120)
                                    .clipped()
                            }
                        }
                        
                        if let _ = vm.catImages.last {
                            LastItemView()
                        }
                    }
                }
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                offsetSubject.send(value)
            }
            .onAppear {
                cancellable = offsetSubject
                    .removeDuplicates()
                    .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
                    .sink { value in
                        let screenHeight = UIScreen.main.bounds.height
                        if value < screenHeight + 100 {
                            vm.fetchMoreIfNeeded(currentItem: vm.catImages.last)
                        }
                    }
            }
            .onDisappear {
                cancellable?.cancel()
            }
        }
    }
}

struct LastItemView: View {
    var body: some View {
        GeometryReader { geo in
            Color.clear
                .preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geo.frame(in: .global).minY
                )
        }
        .frame(height: 10)
        .frame(maxWidth: .infinity)
    }
}

struct CatImageItemView: View {
    @StateObject private var loader = ImageLoader()
    let catImage: CatImage
    
    var body: some View {
        VStack {
            if let uiImage = loader.image {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                Rectangle().fill(Color.gray.opacity(0.3))
                    .overlay(ProgressView())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if loader.image == nil {
                loader.load(urlString: catImage.url, id: catImage.id)
            }
        }
    }
}

struct CatDetailView: View {
    let catImage: CatImage
    @StateObject private var loader = ImageLoader()
    @State private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    
    var body: some View {
        VStack {
            if let uiImage = loader.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(currentScale * finalScale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                currentScale = value
                            }
                            .onEnded { value in
                                finalScale = min(finalScale * value, 3.0)
                                currentScale = 1.0
                            }
                    )
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .navigationTitle(catImage.id)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loader.load(urlString: catImage.url, id: catImage.id)
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

