//
//  FloatingActionMenu.swift
//  WebToNative
//
//  Created by yash saini on 19/08/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//

import SwiftUI
import WebToNativeCore
import WebToNativeIcons

struct FloatingActionMenuView: View {
    let data: FloatingActionMenuData?
    let richBottomBarAvailable: Bool?
    let bottomBarAvailable: Bool?
    @Binding var showMenu: Bool

    var body: some View {
        let iconSize = 50.0
        let iconBgColor = colorToUIColor(colorCode: data?.bgColor ?? "#000000")
        
        ZStack{
            if showMenu {
                Color.white.opacity(0.001).onTapGesture {
                    showMenu = false
                }
            }
            HStack {
                VStack {
                    Spacer()
                    // FAM Menu
                    if showMenu {
                        GeometryReader { reader in
                            VStack{
                                Spacer()
                                HStack{
                                    if data?.position == "right" {
                                        Spacer()
                                    }
                                    ScrollView(.vertical, showsIndicators: false) {
                                        LazyVStack {
                                            ForEach(0..<(data?.tabs?.count ?? 0), id: \.self){ index in
                                                menuItemView(bgColor: data?.menuBgColor, iconName: data?.tabs![index]?.icon, iconColor: data?.menuTextColor, text: data?.tabs![index]?.label, showLabel: data?.showLabel, leftPosition: data?.position == "left")
                                                    .onTapGesture {
                                                        WebToNativeCore.webView.loadUrl(url: data?.tabs?[index]?.url)
                                                        showMenu = false
                                                    }
                                            }
                                        }
                                    }.frame(maxHeight: reader.size.height)
                                        .fixedSize()
                                    
                                    if data?.position == "left" {
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    Spacer().frame(maxHeight: 20)
                    // FAM main icon
                    HStack {
                        if data?.position == "right" {
                            Spacer()
                        }
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showMenu.toggle()
                            }
                        }) {
                            IconView(iconName: data?.icon ?? "", iconColor: data?.textColor ?? "#ffffff", iconSize: 40.0)
                                .background(Circle().fill(Color(iconBgColor)).frame(width: iconSize, height: iconSize)
                                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                                    .overlay(
                                        Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    ))
                        }
                        
                        if data?.position == "left" {
                            Spacer()
                        }                }
                }.padding(.horizontal, 20)
                
            }
        }
        
    }
}

/**
    Item for floating action menu
 */
private struct menuItemView: View {
    let bgColor: String?
    let iconName: String?
    let iconColor: String?
    let text: String?
    let showLabel: Bool?
    let leftPosition: Bool
    
    var body: some View {
        let menuBgColor = bgColor ?? "#000000"
        let menuForegroundColor = iconColor ?? "#ffffff"
        HStack {
            if !leftPosition {
                Spacer()
    
                if showLabel ?? true && text != nil {
                    menuTextView(bgColor: menuBgColor, textColor: menuForegroundColor, text: text!)
                }
            }
            
            if let icon = iconName {
                menuIconView(bgColor: menuBgColor, iconName: icon, iconColor: menuForegroundColor)
            }
        
            if leftPosition {
                if showLabel ?? true && text != nil {
                    menuTextView(bgColor: menuBgColor, textColor: menuForegroundColor, text: text!)
                }
                Spacer()
            }
        }
    }
}

/**
    Icon View for floating action menu
 */
private struct menuIconView: View {
    let bgColor: String
    let iconSize = 40.0
    let iconName: String
    let iconColor: String
    
    var body: some View {
        ZStack {
            Circle().fill(Color(colorToUIColor(colorCode: bgColor))).frame(width: iconSize, height: iconSize)
            IconView(iconName: iconName, iconColor: iconColor, iconSize: iconSize - 8)
        }
        
    }
}


/**
    Text View for floating action menu
 */
private struct menuTextView: View {
    let bgColor: String
    let iconSize = 30.0
    let textColor: String
    let text: String
    
    var body: some View {
        Text(text)
            .padding(.horizontal, 10)
            .lineLimit(1)
            .frame(height: 36, alignment: .leading)
            .foregroundColor(Color(colorToUIColor(colorCode: textColor)))
            .background(
                Rectangle().fill(Color(colorToUIColor(colorCode: bgColor))).cornerRadius(10)
            )
    }
}
