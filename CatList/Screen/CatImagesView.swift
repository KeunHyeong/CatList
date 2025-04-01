//
//  ContentView.swift
//  thecat
//
//  Created by 장근형 on 3/27/25.
//

import SwiftUI

struct CatImagesView: View {
    @StateObject var vm = CatImageViewModel()
    
    var body: some View {
        CatListView(vm: vm)
            .navigationTitle("Cat Images")
    }
}

struct CatListView: View {
    @ObservedObject var vm: CatImageViewModel
    
    var body: some View {
        GeometryReader { proxy in
            let isLandscape = proxy.size.width > proxy.size.height
            
            if isLandscape {
                NavigationStack {
                    LandscapeGridView(vm: vm)
                }
                
            } else {
                NavigationStack {
                    PortraitListView(vm: vm)
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
                    NavigationLink(destination: CatDetailView()) {
                        CatImageItemView(url: image.url)
                            .frame(width:CGFloat(image.width), height:CGFloat(image.height))
                        
                    }
                }
            }
        }
    }
}

struct LandscapeGridView: View {
    @ObservedObject var vm: CatImageViewModel
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                ScrollView(.horizontal) {
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(300), spacing: 10), count: 5)) {
                        ForEach(vm.catImages, id: \.id) { image in
                            NavigationLink(destination: CatDetailView()) {
                                CatImageItemView(url: image.url)
                                    .frame(width:300, height:120)
                                    .clipped()
                            }
                            
                        }
                    }
                }
            }
        }
    }
}

struct CatImageItemView: View {
    var url: String = ""
    
    var body: some View {
        VStack{
            AsyncImage(url: URL(string: url))
                .frame(width: 300, height: 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CatDetailView: View {
    var body: some View {
        VStack {
            
        }
    }
}

//#Preview {
//    CatImagesView()
//}
