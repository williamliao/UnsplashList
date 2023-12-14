//
//  PhotoInfo.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/27.
//

#if canImport(UIKit)
import UIKit
#else
import Cocoa
#endif

struct PhotoInfo:Codable {
    let id: String
    var title:String
    let url: Urls
    let profile_image: Profile_image
    let width: CGFloat
    let height: CGFloat
}

extension PhotoInfo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension PhotoInfo: Equatable {
    static func == (lhs: PhotoInfo, rhs: PhotoInfo) -> Bool {
        return lhs.title == rhs.title && lhs.id == rhs.id
    }
}
