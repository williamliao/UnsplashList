//
//  Cursor.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/22.
//

import Foundation

struct Cursor {
    let query: String?
    let page: Int
    let perPage: Int
    let parameters: [String: Any]?
}
