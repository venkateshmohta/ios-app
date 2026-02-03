//
//  QuickActionCard.swift
//  WebToNative
//
//  Created by yash saini on 26/12/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//

import SwiftUI
import WebToNativeCore
import WebToNativeIcons


// Quick Action Card
public struct SideBarQuickActionCardView: View {
    let data: SideBarNavigationTab
    let color: Color
    let onClick: (String?) -> Void

    private var bgColor: Color {
        Color(UIColor(hex: data.bgColor ?? "#F3F3F3"))
    }

    private var columns: [GridItem] {
        var count = max(data.itemsPerRow ?? 1, 1)
        count = data.items?.count ?? 1 > count ? count : data.items?.count ?? 1
        return Array(
            repeating: GridItem(.flexible(), spacing: 8),
            count: count
        )
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title = data.title, title != ""{
                // Title
                HStack(spacing: 0) {
                    Text(title)
                        .foregroundColor(color)
                        .font(.system(size: 16, weight: .medium))
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.all, 5)
            }
            
            Spacer().frame(maxHeight: 3)

            // Grid
            if let items = data.items {
                LazyVGrid(columns: columns, spacing: (data.itemsPerRow ?? 1 == 1) ? 2 : 8) {
                    ForEach(items.indices, id: \.self) { index in
                        if let item = items[index] {
                            QuickActionCard(
                                data: data,
                                cardData: item,
                                onClick: onClick
                            )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 10)
    }
}

private struct QuickActionCard: View {
    let data: SideBarNavigationTab
    let cardData: SideBarNavigationTabItem
    let onClick: (String?) -> Void
    
    var maxColumn: Int {
        data.itemsPerRow ?? 1
    }
    var bgColor: Color {
        Color(UIColor(hex: data.bgColor ?? "#F3F3F3"))
    }
    var iconName: String {
        cardData.icon ?? ""
    }
    var label: String {
        cardData.label ?? ""
    }

    var color: Color {
        Color(UIColor(hex: data.color ?? ""))
    }
    

    var body: some View {
        Button(action: {
            onClick(cardData.url)

        }){
            ZStack {
                QuickCardBackground(cardColor: bgColor)
                VStack(spacing: 0) {
                    // Vertical Layout
                    if maxColumn > 1 {
                        // Icon
                        IconView(iconName: iconName, iconColor: data.color ?? "#000000", iconSize: 30)
                        
                        // Label
                        Text(label).foregroundColor(color)
                            .font(.system(size: 14, weight: .regular))
                        
                        
                    } else {
                        // Horizontal Layout
                        HStack(spacing: 0){
                            // Icon
                            IconView(iconName: iconName, iconColor: data.color ?? "#000000", iconSize: 30)
                            
                            // Label
                            Text(label).foregroundColor(color)
                                .font(.system(size: 14, weight: .regular))
                                .padding(.horizontal, 5)
                            Spacer()
                        }.padding(.horizontal, 10)
                    }
                }
            }
        }
    }
}

private struct QuickCardBackground: View {
    let cardColor: Color
    
    private let cardCorner = CGFloat(10)
    private let cardHeight = CGFloat(70)
    public var body: some View {
        Rectangle().fill(cardColor).cornerRadius(cardCorner).frame(height: cardHeight).frame(maxWidth: .infinity).padding(.all, 2)
    }
}
