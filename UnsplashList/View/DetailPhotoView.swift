//
//  DetailPhotoView.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2024/1/11.
//

import SwiftUI
import Kingfisher

struct DetailPhotoView: View {
    
    @State var url: URL?
    @State var lowResolutionURL: URL?
    @State var fullResolutionURL: URL?
    @Binding var navigationPath: [Route]
    @State var id = UUID()
    @EnvironmentObject var downloadManager: DownloadManager
    
    var body: some View {
       
        KFImage(url)
            .placeholder {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.red))
            }
            .memoryCacheAccessExtending(ExpirationExtending.cacheTime)
            .memoryCacheExpiration(StorageExpiration.seconds(600))
            .diskCacheExpiration(StorageExpiration.days(30))
            .cancelOnDisappear(true)
            .diskStoreWriteOptions(.atomic)
            //.retry(maxCount: 3, interval: .seconds(5))
            .onSuccess { r in
                //print("success: \(r)")
                downloadManager.downloadFileWithKingfisher(for: fullResolutionURL)
            }
            .onFailure { e in
                print("failure: \(e)")
            }
            .lowDataModeSource(.network(handleLowResolutionURL(lowResolutionURL)))
            .cacheOriginalImage()
            .resizable()
            .loadDiskFileSynchronously()
            .fade(duration: 0.25)
            .resizable()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
           .clipShape(RoundedRectangle(cornerRadius: 25.0))
           .padding(.horizontal, 20)
        
           .modify {
               if #available(iOS 17.0, *) {
                   $0.containerRelativeFrame(.horizontal)
                       .scrollTransition(.animated, axis: .horizontal) { content, phase in
                           content
                               .opacity(phase.isIdentity ? 1.0 : 0.8)
                               .scaleEffect(phase.isIdentity ? 1.0 : 0.8)
                    }
               }
           }
            .onTapGesture {
                navigationPath.append(.webView(url: handleFullResolutionURL(fullResolutionURL)))
            }
    }
    
    private func handleLowResolutionURL(_ lowResolutionURL: URL?) -> URL
    {
       if let unwrappedURL = lowResolutionURL {
           return unwrappedURL
       } else {
           return URL(string: "https://example.com")!
       }
    }
    
    private func handleFullResolutionURL(_ fullResolutionURL: URL?) -> URL
    {
       if let unwrappedURL = fullResolutionURL {
           return unwrappedURL
       } else {
           return URL(string: "https://example.com")!
       }
    }
}

//#Preview {
//    DetailPhotoView()
//}
