//
//  SideBar.swift
//  WebToNative
//
//  Created by yash saini on 18/12/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//
import SwiftUI
import WebToNativeCore

public struct SideBar: View {
    let geometry: GeometryProxy
    @Binding var isSideBarVisible: Bool
    let data: SIDEBAR_NAVIGATION?
    
    var sheetWidth: CGFloat { sideBarSheetWidth(geometry: geometry) }
    var color: String {
        data?.data?.color ?? "#000000"
    }
    var iconColor: Color { Color(UIColor(hex: data?.data?.color ?? "#000000")) }
    var bgColor: Color { Color(UIColor(hex: data?.data?.bgColor ?? "#ffffff")) }
    var showSideBarOnLeft: Bool { data?.data?.sidebarPlacement != "right" }
    @State var anySubMenuVisible: Bool = false

    public var body: some View {
        let bottomSafeAreaPadding = sideBarBottomSafeAreaPadding()
        let sideBarHeader = sideBarHeader(sideBarData: data)

        
        // Outer side bar area
        HStack(spacing: 0){
            if !showSideBarOnLeft {
                Spacer()
            }
            ZStack {
                // SideBar
                VStack(spacing: 0){
                        // HEADER
                    if let sideBarHeader = sideBarHeader {
                        SideBarHeader(data: sideBarHeader,showCrossButton: data?.data?.showCrossButton ?? false, iconColor: iconColor, bgColor: bgColor, showOnLeft: showSideBarOnLeft, colorString: data?.data?.color ?? "#000000", onClick: { url in
                            onClick(url: url) // Handle onClick
                        }, onClose: {
                            closeSideBar() // close SideBar
                        })
                    }
                    
                    // DIVIDER
                    Divider().frame(height: 1)
                    
                    // TABS
                    if #available(iOS 16.4, *) {
                        ScrollView(.vertical, showsIndicators: false) {
                            sideBarTabs
                        }.scrollBounceBehavior(.basedOnSize)
                    } else {
                        // Fallback on earlier versions
                        ScrollView(.vertical, showsIndicators: false) {
                            sideBarTabs
                        }
                    }
                    
                }
                .background(bgColor)
                .frame(width: sheetWidth, alignment: .leading)
                .frame(maxHeight: .infinity)
                .onTapGesture {
                    // block tap on side bar area
                }
            }.frame(width: sheetWidth, alignment: .leading)
                .frame(maxHeight: .infinity)
            
            if showSideBarOnLeft {
                Spacer()
            }

        }
        .onAppear {
            hideIntercomIcon()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, bottomSafeAreaPadding)
        .background(Color.black.opacity(0.3))
        .onTapGesture {
            // close side bar
            closeSideBar()
        }
    }
    
    
    private var sideBarTabs: some View {
        VStack(spacing: 0){
            // TABS
            if let tabs = data?.data?.tabs {
                ForEach(0..<tabs.count, id: \.self){ index in
                    Spacer().frame(maxHeight: 5)
                    //
                    if let tab = tabs[index] {
                        if tab.type == "quickActionCards"{
                            SideBarQuickActionCardView(data: tab, color: iconColor, onClick: { url in
                                onClick(url: url)
                            })
                        }
                        else if tab.type == "menuItems" {
                            SideBarMenuItemsView(data: tab, color: color, onClick: { url in
                                onClick(url: url)
                            })
                        }
                        else if tab.type == "multiLevelMenu" {
                            SideBarMenuLevelItemsUpperView(data: tab,
                                                           color: color, anySubMenuVisible: $anySubMenuVisible, onClick: { url in
                                onClick(url: url)
                            })
                        }
                    }
                }
                Spacer()
            }

            
            
            Spacer()
        }.background(bgColor)
            .ignoresSafeArea(.all)
    }
    
    
    
    private func closeSideBar() {
        W2NSchemeHandler.shared.isSideBarVisible = false
        showIntercomIcon()
    }
    
    private func onClick(url: String?){
        WebToNativeCore.webView.loadUrl(url: url)
        closeSideBar()
    }
}
