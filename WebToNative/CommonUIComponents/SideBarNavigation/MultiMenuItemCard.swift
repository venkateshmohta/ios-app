//
//  MultiMenuItemCard.swift
//  WebToNative
//
//  Created by yash saini on 26/12/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//

import SwiftUI
import WebToNativeCore
import WebToNativeIcons


public struct SideBarMenuLevelItemsUpperView: View {
    let data: SideBarNavigationTab
    let color: String
    @Binding var anySubMenuVisible: Bool
    let onClick: (String?) -> Void
    
    
    var titleColor: Color {
        Color(UIColor(hex: color))
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {

            if let title = data.title, title != ""{
                Spacer().frame(maxHeight: 10)
                // Title
                Text(title)
                    .foregroundColor(titleColor)
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(1)
                    .padding(.horizontal, 5)
            }

            // Menu items
            if let menuItems = data.items {
                ForEach(menuItems.indices, id: \.self) { index in
                    if let item = menuItems[index] {
                        SideBarMultiLevelMenuItemView(
                            data: data,
                            colorString: color,
                            item: item,
                            anySubMenuVisible: $anySubMenuVisible,
                            onClick: onClick
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 10)
    }
}


public struct SideBarMultiLevelMenuItemView: View {
    let data: SideBarNavigationTab
    let colorString: String
    let item: SideBarNavigationTabItem
    @Binding var anySubMenuVisible: Bool
    let onClick: (String?) -> Void

    // MARK: - Derived properties
    private var iconName: String { item.icon ?? "" }
    private var label: String { item.label ?? "" }
    private var color: Color { Color(UIColor(hex: colorString)) }

    private let iconSize: CGFloat = 32
    private let subMenuIconSize: CGFloat = 25
    private let subMenuLeftPadding: CGFloat = 37
    @State private var storeLocalMenuState: Bool? = nil

    @State private var isMenuOpen = false

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            // Main row
            HStack {
                IconView(
                    iconName: iconName,
                    iconColor: colorString,
                    iconSize: iconSize
                )

                Text(label)
                    .foregroundColor(color)
                    .font(.system(size: 16, weight: .regular))
                    .padding(.horizontal, 6)

                Spacer()

                if hasSubMenu {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            subMenuVisibility()
                        }
                    } label: {
                        IconView(
                            iconName: "fas fa-angle-down",
                            iconColor: colorString,
                            iconSize: subMenuIconSize
                        )
                        .rotationEffect(.degrees(isMenuOpen ? 180 : 0))
                        .animation(.easeInOut(duration: 0.25), value: isMenuOpen)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.25)) {
                    subMenuVisibility()
                }
            }
            .onChange(of: anySubMenuVisible){ value in
                if value != storeLocalMenuState {
                    isMenuOpen = false
                    storeLocalMenuState = false
                }
            }

            // Sub menu
            if isMenuOpen {
                subMenuView
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .top)),
                            removal: .opacity
                        )
                    )
                    .animation(.easeInOut(duration: 0.25), value: isMenuOpen)
            }
        }
    }
    
    private func subMenuVisibility() {
        if isMenuOpen {
            isMenuOpen.toggle()
            storeLocalMenuState = nil
            
        }else {
            isMenuOpen.toggle()
            storeLocalMenuState = anySubMenuVisible ? false : true
            anySubMenuVisible = storeLocalMenuState ?? false
        }
        
    }

    // MARK: - Sub Menu
    @ViewBuilder
    private var subMenuView: some View {
        if let subMenu = item.subMenu {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(subMenu.indices, id: \.self) { index in
                    if let subItem = subMenu[index] {
                        Button {
                            onClick(subItem.url)
                        } label: {
                            Text(subItem.label ?? "")
                                .foregroundColor(color)
                                .font(.system(size: 15, weight: .regular))
                        }
                        .padding(.leading, subMenuLeftPadding)
                        .padding(.vertical, 5)
                        .transition(.opacity)
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }

    private var hasSubMenu: Bool {
        !(item.subMenu?.isEmpty ?? true)
    }
}

