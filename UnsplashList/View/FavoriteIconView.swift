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
    @State var item: ImageModel
    @StateObject private var favoriteVM = FavoriteIconViewModel()
    @AppStorage("favoriteItems") var favoriteItems: [ImageModel] = []
    @AppStorage("favoriteItems2") var favoriteItems2: [ImageModel] = []
    @AppStorage("favoriteItems3") var favoriteItems3: [ImageModel] = []
    
    var body: some View {
        Image(systemName: item.isFavorite ? "heart.fill" : "heart")
            .inverseMask(Image(systemName: item.isFavorite ? "heart.fill" : "heart"))
            .shadow(color: Color.black, radius: 1, x: 0, y: 1)
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

extension View {
    // https://www.raywenderlich.com/7589178-how-to-create-a-neumorphic-design-with-swiftui
    func inverseMask<Mask>(_ mask: Mask) -> some View where Mask: View {
        self.mask(mask
            .foregroundColor(.white)
            .background(Color.black)
            .compositingGroup()
            .luminanceToAlpha()
        )
    }
}
