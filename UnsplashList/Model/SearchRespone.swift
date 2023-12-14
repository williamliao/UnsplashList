//
//  SearchRespone.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

struct SearchRespone: Codable {
    var total: NSInteger
    var total_pages: NSInteger
    var results: [Results]
}

extension SearchRespone: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(total)
        hasher.combine(total_pages)
        hasher.combine(results)
    }

    public static func == (lhs: SearchRespone, rhs: SearchRespone) -> Bool {
        return lhs.total == rhs.total && lhs.total_pages == rhs.total_pages && lhs.results == rhs.results
    }
}
