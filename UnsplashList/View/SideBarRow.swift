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
            Button(action: {
                
                self.selectedTitle = self.title
                
            }) {
                HStack {
                    Image(systemName: title.icon)
                    Text(title.name)
                            .font(Font.system(size: 17))
                }
            }
            .buttonStyle(ClearButtonStyle())
            .padding(.top, 8)
            .padding(.bottom, 8)
            Spacer()
           
            if title == selectedTitle {
                
                if title.name == SideBarItem.unsplash.name || title.name == SideBarItem.yande.name || title.name == SideBarItem.danbooru.name {
                    
                } else {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}


struct ClearButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color.blue : Color.white)
            .background(Color.clear)
    }
}
