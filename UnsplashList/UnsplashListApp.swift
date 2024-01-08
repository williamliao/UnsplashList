//
//  UnsplashListApp.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import SwiftUI

@main
struct UnsplashListApp: App {
    
    @StateObject var coordinator = HomeCoordinator(imagesService: ImagesService(endPoint: .random))

    var body: some Scene {
        WindowGroup {
            HomeCoordinatorView(coordinator: coordinator)
        }
    }
}
