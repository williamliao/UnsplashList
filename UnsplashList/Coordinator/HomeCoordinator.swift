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
   
    
    @State private var columnVisibility =
        NavigationSplitViewVisibility.automatic
    
    var rowText = ["List", "Search", "Favorite"]
    @State var showingSection1 = false
    @State var showingSection2 = false
    
    
    @State private var searchText = ""

    let sideBarItem: [SideBarItem] = [.unsplash, .yande]
    @State private var selectedItem: SideBarItem?
    @State var currentItem: SideBarItem?
 
    // MARK: Views

    var body: some View {
        
        NavigationSplitView(columnVisibility: $columnVisibility) {
            
            List(sideBarItem, children: \.items, selection: $selectedItem) { row in
                HStack {
                    SideBarRow(title: row, selectedTitle: self.$selectedItem)
                }
            }
            .navigationSplitViewColumnWidth(200)
            .onChange(of: selectedItem) { oldValue, newValue in
                currentItem = newValue
                
                coordinator.gridCoordinator.gridViewModel.currentDataItem = newValue!
                
                if navigationPath.count > 0 {
                    navigationPath.removeLast()
                }
            
                if currentItem!.id != 1 {
                    coordinator.gridCoordinator.gridViewModel.change(currentItem!)
                }
                
            }
            
        } detail: {
            
            NavigationStack(path: $navigationPath) {
                GridCoordinatorView(coordinator: coordinator.gridCoordinator, navigationPath: $navigationPath)
                    .transition(AnyTransition.move(edge: .leading))
                    .animation(.default, value: navigationPath)
                    .navigationTitle("GridView")
                    .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search...")
                    .onSubmit(of: .search) {
                        coordinator.gridCoordinator.gridViewModel.items.removeAll()
                        coordinator.gridCoordinator.gridViewModel.loadSearchData(searchText, "10", "1")
                    }
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
    
    func chageSection(_ i: Int) {
        if navigationPath.count > 0 {
            navigationPath.removeLast()
        }

       // currentIndex = i
    }

    func close() {
        navigationPath.removeLast()
    }
}
