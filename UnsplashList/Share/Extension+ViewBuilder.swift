//
//  Extension+ViewBuilder.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2024/3/6.
//

import Foundation
import SwiftUI

public extension View {
    func modify<Content>(@ViewBuilder _ transform: (Self) -> Content) -> Content {
        transform(self)
    }
    
    @ViewBuilder
    func modify(@ViewBuilder _ transform: (Self) -> (some View)?) -> some View {
        if let view = transform(self), !(view is EmptyView) {
            view
        } else {
            self
        }
    }
}

