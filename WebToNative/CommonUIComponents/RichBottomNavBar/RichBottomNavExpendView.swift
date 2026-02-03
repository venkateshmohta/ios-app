////
////  RichBottomNavExpendView.swift
////  WebToNative
////
////  Created by yash saini on 26/03/25.
////  Copyright © 2025 WebToNative. All rights reserved.
////
import UIKit
import SwiftUI
import WebToNativeCore
import WebToNativeIcons

struct RichBottomNavExpendView: View{
    
    /// Height of the screen.
    @State var screenHeight:CGFloat
    /// Width of the screen.
    @State var screenWidth:CGFloat
    /// list of tabs
    let listOfTabs: [ExpandableIcons?]?

    /// Data containing secondary footer menu items.
    let data: RichBottomBarData
    // hide icons
    let hideIcon: Bool

    /// Closure called when a menu item is tapped.
    let onItemClick:(ExpandableIcons)->Void
    /// Array of grid columns.
    @State var columns:[GridItem] = []
    
    /// Body of the view containing the layout and content.
    var body: some View {
        ScrollView {
            LazyVGrid(columns: hideIcon ? Array(repeating: GridItem(.flexible(),spacing: 10), count: 1) : columns) {
                let color = getBottomNavBarColors(data: data)
                if listOfTabs != nil{
                    
                    let bgColor = Color(
                        data.bgColor == "#000000" ? UIColor(hexString:data.bgColor ?? "").lighter(by:20) : UIColor(hexString:data.bgColor ?? "").darker(by:4) )
                    
                    ForEach(0..<(listOfTabs?.count ?? 0), id: \.self) { index in
                        let item = listOfTabs![index]
                        RichBottomNavVerticalCell(item: item!, bgColor: bgColor, textColor: Color(UIColor(hexString: data.iconColor ?? "")), data: data, color: color, hideIcon: hideIcon).onTapGesture {
                            onItemClick(item!)
                        }
                    }
                }
            }
            .padding(.horizontal,10)
            .padding(.top,10)
            .padding(.bottom, screenHeight < screenWidth ? 90 : 0)
        }.frame(maxWidth: screenWidth,minHeight: screenHeight * 0.40, maxHeight: screenHeight > screenWidth ? screenHeight * 0.50 : screenHeight)
            .onAppear{
                columns = getColumns()
            }
    }
    
    /// Calculates the number of columns for the grid layout based on screen size and number of items.
    private func getColumns()->[GridItem]{
        let maxNum = screenHeight > screenWidth ? 3 : 4
        let minNum = screenHeight > screenWidth ? 2 : 3
        let totalItems = data.tabs?.count ?? 0
        if(totalItems == 0){ return []}
        var totalRowItems = 0
        if(totalItems % maxNum == 0){
            totalRowItems = maxNum
        }else if(totalItems % minNum == 0){
            totalRowItems = minNum
        }else{
            totalRowItems = max(totalItems % maxNum,totalItems % minNum) == totalItems % maxNum ? maxNum : minNum
        }
        
        return Array(repeating: GridItem(.flexible(),spacing: 10), count: totalRowItems)
    }
}

/**
 A SwiftUI view that represents a cell in the secondary navigation expanded view.

 The `RichBottomNavVerticalCell` displays an icon or a text label for a secondary footer menu item.
 */
struct RichBottomNavVerticalCell:View {
    
    /// The secondary footer menu item to display.
    let item: ExpandableIcons
    /// Background color of the cell.
    var  bgColor:Color
    /// Text color of the cell.
    let textColor:Color
    // rich bottom bar data
    let data: RichBottomBarData
    // rich bottom bar colors
    let color: RichBottomNavBarColors
    // hide icons
    let hideIcon: Bool
        
    var body: some View {
        if hideIcon {
            VStack {
                HStack {
                    Text(item.label ?? "")
                        .foregroundColor(textColor)
                }.padding(.horizontal, 5).padding(.vertical, 15).frame(maxWidth: .infinity).background(Color(
                    data.bgColor == "#000000" ? UIColor(hexString:data.bgColor ?? "").lighter(by:20) : UIColor(hexString:data.bgColor ?? "").darker(by:4)
                )).clipShape(RoundedRectangle(cornerRadius: 7))
            }.padding(.all, 5).frame(maxWidth: .infinity)
        }
        else {
            ZStack{
                VStack(alignment: .center) {
                    Spacer().frame(maxWidth: 5)
                    CellIconView(item: item, data: data, color: color)
                    Spacer().frame(maxWidth: 5)
                    Text(item.label ?? "")
                        .foregroundColor(textColor)
                    Spacer(minLength: 0)
                }.frame(height: 80)
            }.frame(minWidth: 0, maxWidth: .infinity, maxHeight: 80).clipShape(RoundedRectangle(cornerRadius: 7))
        }
    }
}

private struct CellIconView: View{
    
    /// The secondary footer menu item to display.
    let item:ExpandableIcons
    let data: RichBottomBarData
    let color: RichBottomNavBarColors
    
    var body: some View {
        let iconForegroundIcon = Color(color.inActiveIconColor)
        let customImage = item.icon?.starts(with: "img-") ?? false
        let iconSize = 30.0
        let imageName = item.icon?.starts(with: "img-") ?? false ? UIImage(named: item.icon!) :
        WebToNativeIcons.imageForIconIdentifier(
            item.icon!,
            size: CGFloat(iconSize),
            color: color.inActiveIconColor
        )
        if let image = imageName{
            if customImage{
                Image(uiImage: image)
                    .resizable()
                    .padding(.all, 2.5)
                    .foregroundColor(iconForegroundIcon)
                    .frame(width: iconSize, height: iconSize, alignment: .center)
                    .frame(maxWidth: iconSize, maxHeight: iconSize)
            }
            else {
                Image(uiImage: image)
                    .foregroundColor(iconForegroundIcon)
                    .frame(width: iconSize, height: iconSize, alignment: .center)
            }
        }
    }
}
