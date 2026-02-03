//
//  IconLayer.swift
//  WebToNative
//
//  Created by yash saini on 12/06/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//
import WebToNativeCore
import SwiftUI
import WebToNativeIcons

struct BottomNavAllTab: View {
    let noOfTabs: Int
    var bottomSafeArea: Bool? = true
    let color: RichBottomNavBarColors
    let bottomNavHeight: CGFloat
    var data:RichBottomBarData?
    let curvePosition: String
    let floatingBtnPosition: String
    
    @Binding var selectedTabId: Int

    let onItemClick: (RichBottomBarTab?) -> Void
    let expendView: ([ExpandableIcons?]?, Bool) -> Void
    
    var body: some View {
        let numberOfTabs = data?.tabs?.count ?? -1
        let tabs = numberOfTabs > 5 ? 5 : numberOfTabs
        let curveBg = setCurveBg(tabs: data?.tabs)
        
        ForEach(0..<tabs, id: \.self){ index in
            let tab = data?.tabs?[index]
            if tab?.type == "floating_button"{
                if tab?.floatingBtnPosition == "Inward" {
                        VStack{
                            VStack{
                                ZStack{
//                                    let showShadow = data?.showShadow ?? false
                                    HStack {
                                        createInward(x: curveBg ? 10 : 0, y: curveBg ? 5 : 0).fill(Color(color.backgroundColor))
//                                            .shadow(radius: showShadow ? 7 : 0, x: 0, y: showShadow ? -6 : 0)
                                    }.frame(width: 60, height: 20).padding(.top, -7)
                                    Button {
                                        selectedTabId = index
                                        if tab?.isExpandable ?? false {
                                            expendView(tab?.expandableIcons, tab?.hideIconsOfExpandableOptions ?? false)
                                        }else {
                                            onItemClick(tab)
                                        }
                                    } label: {
                                        ZStack{
                                            VStack {
                                                RoundedRectangle(cornerRadius: CGFloat(50))
                                                    .frame(width: 46,height: 46)
                                                    .foregroundColor(Color(color.floatingBtnIconBgColor))
                                            }
                                            VStack {
                                                if tab?.icon != nil {
                                                    TabIcon(image: tab!.icon!, isActive: false, color: color, data: data, isCenterIcon: true)
                                                }
                                            }
                                            
                                            Text((tab?.label) ?? "")
                                                .font(.system(
                                                    size: CGFloat(12),
                                                    weight: selectedTabId == index ? .bold : .regular
                                                ))
                                                .foregroundColor(selectedTabId == index ? Color(color.activeTextColor): Color(color.inActiveTextColor))
                                                .fontWeight(selectedTabId == index ? .bold : .regular)
                                                .padding(.top, 76)
                                                .lineLimit(1)
                                        }
                                    }
                                }.padding(.top, -(bottomNavHeight - 45))
                                Spacer()
                                
                            }
                        }.frame(maxWidth: .infinity)
                }
                else {
                    VStack{
                        ZStack {
                            Button {
                                selectedTabId = index
                                if tab?.isExpandable ?? false {
                                    expendView(tab?.expandableIcons, tab?.hideIconsOfExpandableOptions ?? false)
                                }else {
                                    onItemClick(tab)
                                }
                            } label: {
                                VStack{
                                    ZStack{
                                        RoundedRectangle(cornerRadius: CGFloat(50))
                                            .frame(width: 44,height: 44)
                                            .foregroundColor(Color(color.floatingBtnIconBgColor))
                                            .padding(.top, 50)
                                        if tab?.icon != nil {
                                            TabIcon(image: tab!.icon!, isActive: false, color: color, data: data, isCenterIcon: true)
                                                .padding(.top, 50)
                                        }
                                        
                                        Text((tab?.label) ?? "")
                                            .font(.system(
                                                size: CGFloat(12),
                                                weight: selectedTabId == index ? .bold : .regular
                                            ))
                                            .foregroundColor(selectedTabId == index ? Color(color.activeTextColor): Color(color.inActiveTextColor))
                                            .fontWeight(selectedTabId == index ? .bold : .regular)
                                            .padding(.top, 150)
                                            .lineLimit(1)
                                    }.frame(height: 240).padding(.top, bottomSafeArea ?? false || bottomNavHeight == 65 ? -115 : -130)
                                }
                            }
                        }.frame(maxWidth: .infinity)
                    }
                }
                    
            }
            else {
                BottomNavButtonView(selectedTabId: $selectedTabId, noOfTabs: noOfTabs, data: data, tabId: index, color: color, floatingButtonType: floatingBtnPosition, onItemClick: { selectedTab in
                    if tab?.isExpandable ?? false {
                        selectedTabId = index
                        expendView(tab?.expandableIcons, tab?.hideIconsOfExpandableOptions ?? false)
                    }else {
                        onItemClick(selectedTab)
                    }
                }).frame(maxWidth: .infinity, maxHeight: bottomNavHeight)
            }
        }
    }
}


struct BottomNavButtonView: View {
    @Binding var selectedTabId: Int
    let noOfTabs: Int
    let data: RichBottomBarData?
    let tabId: Int
    let color: RichBottomNavBarColors
    let floatingButtonType: String
    let onItemClick: (RichBottomBarTab?) -> Void
    
    var body: some View {
        Button {
            selectedTabId = tabId
            onItemClick(data?.tabs?[tabId])
        } label: {

            BottomBarButtonView(image: data?.tabs?[tabId]?.icon, text: data?.tabs?[tabId]?.label, isActive: selectedTabId == tabId, color: color, data: data, floatingBtnType: floatingButtonType)
        }
    }
}

struct IconLayer: View {
    let bottomNavHeight: CGFloat
    var bottomSafeArea: Bool? = true
    var data:RichBottomBarData?
    let screenWidth:CGFloat
    let curvePosition: String
    let floatingBtnPosition: String
    
    @Binding var currentUrl:String
    let onItemClick: (RichBottomBarTab?) -> Void
    let expendView: ([ExpandableIcons?]?, Bool) -> Void
    @State var selectedTabId = -1
    
    var body: some View {
        let color = getBottomNavBarColors(data: data!)
        let noOfTabs = data?.tabs?.count ?? 0
        
        HStack{
            HStack(spacing: 0) {
                BottomNavAllTab(noOfTabs: noOfTabs, bottomSafeArea: bottomSafeArea, color: color, bottomNavHeight: CGFloat(bottomNavHeight), data: data, curvePosition: curvePosition, floatingBtnPosition: floatingBtnPosition, selectedTabId: $selectedTabId, onItemClick: { selectedTab in
                       onItemClick(selectedTab)
                        
                    }, expendView: { list, hideIcon in
                        expendView(list, hideIcon)
                    })
                }
                .onAppear{
                    let matchIndex = matchCurrentUrl(data: data,url: currentUrl)
                        selectedTabId = matchIndex ?? -1
                }
                .onChange(of: currentUrl){ url in
                    let rbData = getRichBottomBarData(url: url)
                    let matchIndex = matchCurrentUrl(data: rbData, url: url)
                    selectedTabId = matchIndex ?? -1
                }
                .frame(maxWidth: 500)
        }.frame(maxWidth: .infinity)
    }
}

struct TabIcon: View{
    var image:String
    var isActive:Bool
    var color: RichBottomNavBarColors
    var data: RichBottomBarData?
    var isCenterIcon: Bool = false
    
    var body: some View {
        let iconForegroundIcon = isCenterIcon ? color.floatingBtnIconColor : isActive ? color.activeIconColor : color.inActiveIconColor
        let customImage = image.starts(with: "img-")
        let iconSize = 30.0
        let imageName = image.starts(with: "img-") ? UIImage(named: image) :
        WebToNativeIcons.imageForIconIdentifier(
            image,
            size: CGFloat(iconSize),
            color: iconForegroundIcon
        )
        if let image = imageName{
            if customImage{
                Image(uiImage: image)
                    .resizable()
                    .padding(.all, 2.5)
                    .foregroundColor(Color(iconForegroundIcon))
                    .frame(width: iconSize, height: iconSize, alignment: .center)
                    .frame(maxWidth: iconSize, maxHeight: iconSize)
            }
            else {
                Image(uiImage: image)
                    .foregroundColor(Color(iconForegroundIcon))
                    .frame(width: iconSize, height: iconSize, alignment: .center)
            }
        }
    }
}
