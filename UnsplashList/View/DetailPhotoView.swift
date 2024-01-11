//
//  DetailPhotoView.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2024/1/11.
//

import SwiftUI

struct DetailPhotoView: View {
    
    @State var url: URL
    @Binding var navigationPath: [Route]
    @State var id = UUID()
    
    var body: some View {
        CacheAsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                   .clipShape(RoundedRectangle(cornerRadius: 25.0))
                   .padding(.horizontal, 20)
                   .containerRelativeFrame(.horizontal)
                    .scrollTransition(.animated, axis: .horizontal) { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1.0 : 0.8)
                            .scaleEffect(phase.isIdentity ? 1.0 : 0.8)
                    }
                    //.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .onTapGesture {
                        navigationPath.append(.url(url: url))
                    }
                    .id(id)
            case .failure(_):
                Image(systemName: "wifi.exclamationmark")
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        id = UUID()
                    }
                    .id(id)
            @unknown default:
                Image(systemName: "wifi.exclamationmark")
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}

//#Preview {
//    DetailPhotoView()
//}
