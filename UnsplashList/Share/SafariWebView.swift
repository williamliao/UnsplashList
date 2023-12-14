//
//  SafariWebView.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/14.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
import SafariServices

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
}
#endif

