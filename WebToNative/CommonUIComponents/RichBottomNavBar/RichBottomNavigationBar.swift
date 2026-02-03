//
//  RichBottomNavigationBar.swift
//  WebToNative
//
//  Created by yash saini on 26/03/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//

import WebToNativeCore
import SwiftUI
import WebToNativeIcons


struct RichBottomNavigationBar: View {
    var bottomSafeArea: Bool? = true
    var data:RichBottomBarData?
    let screenWidth:CGFloat
    
    @Binding var currentUrl:String
    let onItemClick: (RichBottomBarTab?) -> Void
    let expendView: ([ExpandableIcons?]?, Bool) -> Void
    
    var body: some View {
        let color = getBottomNavBarColors(data: data!)
        let bottomNavHeight = getBottomNavHeight(bottomSafeArea: bottomSafeArea ?? false)
        let cornerRadius = CGFloat(data?.cornerRadius ?? 0)
        let (floatingBtnPosition, floatingBtnIndex) = getFloatingBtnPosition(list: data?.tabs)
        let bottomNavTopPadding = getComponentBottomMargin(tabs: data?.tabs, cornerRadius: cornerRadius)
        let curvePosition = if data!.tabs!.count > 1 && data?.tabs?.count == floatingBtnIndex + 1 {
            "right"
        }
        else if data!.tabs!.count > 1 && 0 == floatingBtnIndex {
            "left"
        }
        else {
            "middle"
        }
        let iconLayerPadding = getIconLayerPadding(tabs: data?.tabs?.count ?? 0, width: screenWidth, floatingBtnPosition: floatingBtnPosition, floatingButtonIndex: floatingBtnIndex)
        let showShadow =  data?.showShadow ?? false

        ZStack {
            // bottom nav background (simple, outward)
            BackgroundLayer(floatingBtnPosition: floatingBtnPosition, bottomNavHeight: bottomNavHeight, bgColor: color.backgroundColor, cornerRadius: cornerRadius, screenWidth: screenWidth, tabs: data?.tabs, floatingBtnIndex: floatingBtnIndex, curvePosition: curvePosition, bottomNavSideCurveRadius: data?.cornerRadius ?? 0)
                .shadow(radius: showShadow ? 6.5 : 0, x: 0, y: showShadow ? -6 : 0)
            
            // show Rectangle for hide extra shadow(only for outward)
            if showShadow && floatingBtnPosition == "Outward" {
                Rectangle().fill(Color(color.backgroundColor)).frame(height: 40).frame(maxWidth: .infinity).padding(.bottom, -28)
            }
            
            // show all icons
            IconLayer(bottomNavHeight: bottomNavHeight, bottomSafeArea: bottomSafeArea, data: data, screenWidth: screenWidth, curvePosition: curvePosition, floatingBtnPosition: floatingBtnPosition ?? "", currentUrl: $currentUrl, onItemClick: { selectedTab in
                                onItemClick(selectedTab)
                            }, expendView: { (list, hideIcon) in
                                expendView(list, hideIcon)
                            }).padding(.vertical, 5).padding(.horizontal, iconLayerPadding).frame(height: bottomNavHeight)
            
        }.frame(height: bottomNavHeight)
            .padding(.top, -bottomNavTopPadding)
            .background(Color(color.backgroundColor))

    }
}


struct BottomBarButtonView: View {
    var image:String?
    var text:String?
    var isActive:Bool
    var color: RichBottomNavBarColors
    var data: RichBottomBarData?
    var floatingBtnType: String

    
    var body: some View {
        VStack{
            HStack {
                GeometryReader{
                    geo in
                    VStack {
                        Rectangle()
                            .frame(height: 0)
                        if image != nil {
                            TabIcon(image: image!, isActive: isActive, color: color, data: data)
                        }
                    
                        if text != nil {
                            Text(text!)
                                .font(.system(
                                    size: CGFloat(12),
                                    weight: isActive ? .bold : .regular
                                ))
                                .foregroundColor(isActive ? Color(color.activeTextColor): Color(color.inActiveTextColor))
                                .fontWeight(isActive ? .bold : .regular)
                                .lineLimit(1)
                                .padding(.top, floatingBtnType == "Inward" ? 5 : 0)
                        }
                    }
                }
            }
        }
    }
}
