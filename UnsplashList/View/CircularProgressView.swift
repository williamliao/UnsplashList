//
//  CircularProgressView.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2024/1/12.
//

import SwiftUI
import Kingfisher

#if canImport(UIKit)
public typealias ViewRepresentable = UIView
#elseif canImport(AppKit)
public typealias ViewRepresentable = NSView
#endif

struct CircularProgressView: View {
  let progress: Progress

  var body: some View {
    ZStack {
      // Background for the progress bar
      Circle()
        .stroke(lineWidth: 20)
        .opacity(0.1)
        .foregroundColor(.blue)

      // Foreground or the actual progress bar
      Circle()
        .trim(from: 0.0, to: progress.fractionCompleted)
        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
        .foregroundColor(.blue)
        .rotationEffect(Angle(degrees: 270.0))
        .animation(.linear, value: progress.fractionCompleted)
    }
  }
}

struct MyIndicator: Indicator {
    let view: ViewRepresentable = ViewRepresentable()
    
    func startAnimatingView() { view.isHidden = false }
    func stopAnimatingView() { view.isHidden = true }
    
    var percentage: Double {
        didSet {
           // update your actual view.
            
            
        }
    }
    
    init(percentage: Double) {
        
        self.percentage = percentage
        
        //view.addSubview(CircularProgressView(progress: percentage))
    }
}

//#Preview {
//    CircularProgressView(progress: 0.5)
//}
