//
//  WebView.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import SwiftUI

struct WebDisPlayView: View {
    
    @Binding var navigationPath: [Route]
    @State private var isLoading = true
    @State private var error: Error? = nil
    let url: URL?
    
    var body: some View {
        ZStack {
            if let error = error {
                Text(error.localizedDescription)
                    .foregroundColor(.pink)
            } else if let url = url {
                WebView(url: url,
                         isLoading: $isLoading,
                         error: $error)
                if isLoading {
                    ProgressView()
                }
            } else {
                Text("Sorry, we could not load this url.")
            }
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
    StatefulPreviewWrapper([.webView(url: URL(string: "")!)]) { WebDisPlayView(navigationPath: $0, url: URL(string: "")!) }
}
