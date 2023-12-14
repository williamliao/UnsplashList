//
//  Favorite.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/22.
//

#if canImport(UIKit)
import UIKit
#else
import Cocoa
#endif

struct Favorite {
    let isFavorite: Bool
    let url: Urls
}
