//
//  WebView.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import SwiftUI

struct WebView: View {
    
    @Binding var navigationPath: [Route]
    var url: URL
    
    var body: some View {
        VStack {
            
            #if canImport(UIKit)
                SafariWebView(url: url)
            #endif
            
            //Text("WebView")
        }
        .navigationBarBackButtonHidden(true)
        #if canImport(UIKit)
        .navigationBarItems(leading: Button(action : {
            navigationPath.removeLast()
        }){
            Image(systemName: "arrow.left")
        })
        #endif
    }
}

#Preview {
    StatefulPreviewWrapper([.url(url: URL(string: "")!)]) { WebView(navigationPath: $0, url: URL(string: "")!) }
}
