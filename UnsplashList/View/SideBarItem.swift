//
//  SideBarItem.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/15.
//

import Foundation
import SwiftUI

struct SideBarItem: Equatable, Identifiable {
    let id: Int
    let name: String
    let icon: String
    var items: [SideBarItem]?

    static let unsplash = SideBarItem(id: 0, name: "Unsplash", icon: "photo", items: [SideBarItem.list, SideBarItem.favorite])
    static let yande = SideBarItem(id: 1, name: "Yande", icon: "photo", items: [SideBarItem.list2, SideBarItem.favorite2])
    
    static let list = SideBarItem(id: 2, name: "List", icon: "list.bullet")
    static let favorite = SideBarItem(id: 3, name: "Favorite", icon: "heart.fill")
    
    static let list2 = SideBarItem(id: 4, name: "List", icon: "list.bullet")
    static let favorite2 = SideBarItem(id: 5, name: "Favorite", icon: "heart.fill")
}

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
