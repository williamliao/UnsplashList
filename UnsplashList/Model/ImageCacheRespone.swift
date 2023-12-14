//
//  ImageCacheRespone.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/27.
//

import Foundation

struct ImageCacheRespone {
    var httpResponse : HTTPURLResponse
    var data : Data
    var date : String
    var etag : String
    var lastModified: String
}
