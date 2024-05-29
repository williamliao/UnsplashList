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
import WebKit

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
}

struct WebView: UIViewRepresentable {
 
    let url: URL
    @Binding var isLoading: Bool
    @Binding var error: Error?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView  {
        let wkwebView = WKWebView()
        //wkwebView = context.coordinator
        wkwebView.load(URLRequest(url: url))
        return wkwebView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("loading error: \(error)")
            parent.isLoading = false
            parent.error = error
        }
    }
}
#elseif canImport(Cocoa)
import WebKit
struct WebView: NSViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var error: Error?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> WKWebView  {
        var wkwebView = WKWebView()
       // wkwebView = context.coordinator
        wkwebView.load(URLRequest(url: url))
        return wkwebView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        init(_ parent: WebView) {
            self.parent = parent
        }
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("loading error: \(error)")
            parent.isLoading = false
            parent.error = error
        }
    }
}

#endif
