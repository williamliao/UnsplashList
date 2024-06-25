//
//  SideBarItem.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/15.
//

import Foundation
import SwiftUI

enum SideBarItemType:Int {
    case unsplashList = 3
    case unsplashFavorite = 4
    case yandeList = 5
    case yandeFavorite = 6
    case danbooruList = 7
    case danbooruFavorite = 8
}

struct SideBarItem: Equatable, Identifiable {
    let id: Int
    let name: String
    let icon: String
    var items: [SideBarItem]?

    static let unsplash = SideBarItem(id: 0, name: "Unsplash", icon: "photo", items: [SideBarItem.list, SideBarItem.favorite])
    static let yande = SideBarItem(id: 1, name: "Yande", icon: "photo", items: [SideBarItem.list2, SideBarItem.favorite2])
    static let danbooru = SideBarItem(id: 2, name: "Danbooru", icon: "photo", items: [SideBarItem.list3, SideBarItem.favorite3])
    
    static let list = SideBarItem(id: 3, name: "List", icon: "list.bullet")
    static let favorite = SideBarItem(id: 4, name: "Favorite", icon: "heart.fill")
    
    static let list2 = SideBarItem(id: 5, name: "List", icon: "list.bullet")
    static let favorite2 = SideBarItem(id: 6, name: "Favorite", icon: "heart.fill")
    
    static let list3 = SideBarItem(id: 7, name: "List", icon: "list.bullet")
    static let favorite3 = SideBarItem(id: 8, name: "Favorite", icon: "heart.fill")
}

let mainMenuItems = [ SideBarItem(id: 0, name: "unsplash", icon: "photo", items:           [SideBarItem.list, SideBarItem.favorite]),
                      SideBarItem(id: 1,name: "yande", icon: "photo", items: [SideBarItem.list2, SideBarItem.favorite2]),
                      SideBarItem(id: 2,name: "danbooru", icon: "photo", items: [SideBarItem.list3, SideBarItem.favorite3])
                    ]


extension SideBarItem {
    static func == (lhs: SideBarItem, rhs: SideBarItem) -> Bool {
        return lhs.id == rhs.id
    }
}

extension SideBarItem:Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
