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
    case webView(url: URL)
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
    
    @State private var searchText = ""

    let sideBarItem: [SideBarItem] = [.unsplash, .yande, .danbooru]
    @State private var selectedItem: SideBarItem?
    @State var currentItem: SideBarItem?
    @State private var flags: [Bool] = [true, true]
   
    // MARK: Views

    var body: some View {
        
        NavigationSplitView(columnVisibility: $columnVisibility) {

            List {
                ForEach(mainMenuItems) { menuItem in

                    Section(header:
                        HStack {

                            Text(menuItem.name)
                                .font(.title3)
                                .fontWeight(.heavy)

                            Image(menuItem.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)

                        }
                        .padding(.vertical)

                    ) {
                        OutlineGroup(menuItem.items ?? [SideBarItem](), id: \.id, children: \.items) {  item in
                            SideBarRow(title: item, selectedTitle: self.$selectedItem)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .toolbar(removing: .sidebarToggle)
            
            .modify {
                if #available(iOS 17.0, *) {
                    $0.onChange(of: selectedItem) { oldValue, newValue in
                        
                        currentItem = newValue
                        
                        coordinator.gridCoordinator.gridViewModel.currentDataItem = newValue!
                        
                        if navigationPath.count > 0 {
                            navigationPath.removeLast()
                        }
                    
                        if currentItem!.id != 1 {
                            coordinator.gridCoordinator.gridViewModel.change(currentItem!)
                        }
                    }
                } else {
                    $0.onChange(of: selectedItem, perform: { newValue in
                        currentItem = newValue
                        
                        coordinator.gridCoordinator.gridViewModel.currentDataItem = newValue!
                        
                        if navigationPath.count > 0 {
                            navigationPath.removeLast()
                        }
                    
                        if currentItem!.id != 1 {
                            Task {
                                await coordinator.gridCoordinator.gridViewModel.change(currentItem!)
                            }
                        }
                    })
                }
            }
            
            
            
        } detail: {
            
            NavigationStack(path: $navigationPath) {
                GridCoordinatorView(coordinator: coordinator.gridCoordinator, navigationPath: $navigationPath)
                    .transition(AnyTransition.move(edge: .leading))
                    .animation(.default, value: navigationPath)
                    .navigationTitle("GridView")
                
                    #if canImport(UIKit)
                        .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search...")
                    #elseif canImport(AppKit)
                        .searchable(text:$searchText, placement: .sidebar, prompt: "Search...")
                    #endif
                
                    .onSubmit(of: .search) {
                        Task {
                            coordinator.gridCoordinator.gridViewModel.removeAll()
                            await coordinator.gridCoordinator.gridViewModel.loadSearchData(searchText, "10", "1")
                        }
                    }
                   // .navigationSplitViewColumnWidth(min: 200, ideal: 300, max: 400)
                
                    .navigationDestination(for: Route.self) { route in
                        
                        switch route {
                            
                            case let .webView(url):
                                WebDisPlayView(navigationPath: $navigationPath, url: url)
                                    .transition(AnyTransition.move(edge: .leading))
                                    .animation(.default, value: navigationPath)
                                    .navigationTitle("WebView")
                            
                            case .detail:
                                DetailCoordinatorView(coordinator: coordinator.gridCoordinator.detailViewCoordinator, navigationPath: $navigationPath)
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
