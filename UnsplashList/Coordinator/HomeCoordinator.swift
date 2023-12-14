//
//  HomeCoordinator.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#else
import Cocoa
#endif

enum Route {
    case detail
    case url(url: URL)
}

extension Route: Hashable {
    
}

class HomeCoordinator: ObservableObject {
    
    //@Published var tab = Route.grid
    @Published var gridCoordinator: GridViewCoordinator!
    private let imagesService: ImagesService
    
    // MARK: Initialization

    init(imagesService: ImagesService) {
        self.imagesService = imagesService
        
        self.gridCoordinator = .init(
            imagesService: imagesService,
            parent: self
        )

    }
}

struct HomeCoordinatorView: View {

    // MARK: Stored Properties
    @State var navigationPath: [Route] = []
    @ObservedObject var coordinator: HomeCoordinator
   
    @Binding var currentIndex: Int
    @State private var columnVisibility =
        NavigationSplitViewVisibility.automatic
    
    // MARK: Views

    var body: some View {
        
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(1..<3) { i in
                Button {
                    
                    if navigationPath.count > 0 {
                        navigationPath.removeLast()
                    }
              
                    currentIndex = i
                
                } label: {
                    Text("Data Source \(i)")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
            .navigationSplitViewColumnWidth(150)
            .onChange(of: currentIndex) { oldValue, newValue in
                currentIndex = newValue
                
                if currentIndex != 1 {
                    coordinator.gridCoordinator.gridViewModel.change(currentIndex)
                }
            }
            
        } detail: {
            
            NavigationStack(path: $navigationPath) {
                GridCoordinatorView(coordinator: coordinator.gridCoordinator, navigationPath: $navigationPath)
                    .transition(AnyTransition.move(edge: .leading))
                    .animation(.default, value: navigationPath)
                    .navigationTitle("GridView")
                   // .navigationSplitViewColumnWidth(min: 200, ideal: 300, max: 400)
                
                    .navigationDestination(for: Route.self) { route in
                        
                        switch route {
                            
                            case let .url(url):
                                    WebView(navigationPath: $navigationPath, url: url)
                                    .transition(AnyTransition.move(edge: .leading))
                                    .animation(.default, value: navigationPath)
                                    .navigationTitle("WebView")
                            
                            case .detail:
                                DetailCoordinatorView(coordinator: coordinator.gridCoordinator.detailViewCoordinator!, navigationPath: $navigationPath)
                                    .transition(AnyTransition.move(edge: .leading))
                                    .animation(.default, value: navigationPath)
                                    .navigationTitle("DetailView")
                        }
                    }
            }
            
        }
        
    }

    func close() {
        navigationPath.removeLast()
    }
}
