//
//  FavoriteIconView.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2024/1/9.
//

import Foundation
import SwiftUI

struct FavoriteIconView: View {

    @Binding var currentSideBarItem: SideBarItem
    @State var item: UnsplashModel
    @StateObject private var favoriteVM = FavoriteIconViewModel()
    @AppStorage("favoriteItems") var favoriteItems: [UnsplashModel] = []
    @AppStorage("favoriteItems2") var favoriteItems2: [UnsplashModel] = []
    @AppStorage("favoriteItems3") var favoriteItems3: [UnsplashModel] = []
    
    var body: some View {
        Image(systemName: item.isFavorite ? "heart.fill" : "heart")
            .background(.ultraThinMaterial)
            .font(.system(size: 20))
            .onTapGesture {
                updateFavorite()
            }
    }
    
    private func updateFavorite() {
        favoriteVM.updateFavorite(item: item)
        
        if currentSideBarItem.id == SideBarItemType.yandeList.rawValue ||
            currentSideBarItem.id == SideBarItemType.yandeFavorite.rawValue {
            if item.isFavorite {
                favoriteItems2.append(item)
            } else {
                favoriteItems2.removeAll { model in
                    model.id == item.id
                }
            }
        } else if currentSideBarItem.id == SideBarItemType.unsplashList.rawValue ||
                    currentSideBarItem.id == SideBarItemType.unsplashFavorite.rawValue {
            if item.isFavorite {
                favoriteItems.append(item)
            } else {
                favoriteItems.removeAll { model in
                    model.id == item.id
                }
            }
        } else if currentSideBarItem.id == SideBarItemType.danbooruList.rawValue ||
                    currentSideBarItem.id == SideBarItemType.danbooruFavorite.rawValue {
            if item.isFavorite {
                favoriteItems3.append(item)
            } else {
                favoriteItems3.removeAll { model in
                    model.id == item.id
                }
            }
        }
    }
}
