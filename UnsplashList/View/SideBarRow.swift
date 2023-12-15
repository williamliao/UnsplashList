//
//  SideBarRow.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/15.
//

import SwiftUI

struct SideBarRow: View {

    let title: SideBarItem
    @Binding var selectedTitle: SideBarItem?

    var body: some View {
        HStack {
            Image(systemName: title.icon)
            Text(title.name)
            Spacer()
           
            if title == selectedTitle {
                
                if title.name == "Unsplash" || title.name == "Yande" {
                    
                } else {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
            
            if selectedTitle == nil {
                
                if title.id == 2 {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }

            }
        }
        .onTapGesture {
            self.selectedTitle = self.title
        }
    }
}


