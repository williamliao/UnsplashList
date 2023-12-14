//
//  UnsplashListiOSApp.swift
//  UnsplashListiOS
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/13.
//

import SwiftUI

@main
struct UnsplashListiOSApp: App {
    
    @StateObject var coordinator = HomeCoordinator(imagesService: ImagesService(endPoint: .random))
    @State var index = 0
    
    var body: some Scene {
        WindowGroup {
            HomeCoordinatorView(coordinator: coordinator, currentIndex: $index)
        }
    }
}
