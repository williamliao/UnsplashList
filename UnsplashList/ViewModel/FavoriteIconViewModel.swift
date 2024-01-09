//
//  FavoriteIconViewModel.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2024/1/9.
//

import Foundation
import SwiftUI

class FavoriteIconViewModel : ObservableObject {
 
    func updateFavorite(item: UnsplashModel) {
        item.isFavorite = !item.isFavorite
        self.objectWillChange.send()
    }
}
