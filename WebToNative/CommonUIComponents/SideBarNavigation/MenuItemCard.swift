//
//  MenuItems.swift
//  WebToNative
//
//  Created by yash saini on 26/12/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//

import SwiftUI
import WebToNativeCore
import WebToNativeIcons

public struct SideBarMenuItemsView: View {
    let data: SideBarNavigationTab
    let color: String
    let onClick: (String?) -> Void
    
    var titleColor: Color {
        Color(UIColor(hex: color))
    }
    
    public var body: some View {
        VStack(spacing: 0){
            if let title = data.title, title != ""{
                // Title
                HStack(spacing: 0) {
                    Text(title)
                        .foregroundColor(titleColor)
                        .font(.system(size: 16, weight: .medium))
                        .lineLimit(1)
                    Spacer()
                }.padding(.all, 5)
            }
                
            
            // Get All MenuItems
            if let menuItems = data.items {
                ForEach(0..<menuItems.count, id: \.self){ index in
                    
                    if let item = menuItems[index]{
                        SideBarMenuItem(data: data, iconColor: color, item: item, onClick: { url in
                            onClick(url)
                            
                        })
                    }
                }
            }
        }.padding(.all, 10)
        
    }
}

private struct SideBarMenuItem: View {
    let data: SideBarNavigationTab
    let iconColor: String
    let item: SideBarNavigationTabItem
    let onClick: (String?) -> Void
    
    private var iconName: String { item.icon ?? "" }
    private var color: Color { Color(UIColor(hex: iconColor)) }
    private var label: String { item.label ?? "" }
    
    
    public var body: some View {
        Button(action: {
            onClick(item.url)
        }){
            HStack(spacing: 0) {
                // Icon
                IconView(iconName: iconName, iconColor: iconColor, iconSize: 32)
                // Label
                Text(label).foregroundColor(color)
                    .font(.system(size: 16, weight: .regular))
                    .padding(.horizontal, 5)
                
                Spacer()
                
            }
        }.padding(.vertical, 2)
    }
    
}

