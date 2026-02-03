//
//  SecBottomNavExpandedView.swift
//  WebToNative
//
//  Created by Akash Kamati on 12/06/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import SwiftUI
import WebToNativeCore
import Kingfisher

/// A SwiftUI view that displays a scrollable grid of secondary footer menu items.
/// The `SecBottomNavExpandedView` struct renders a list of secondary footer menu items in a scrollable grid layout. Each menu item is represented by a `SecondaryNavExpandedCell`.
struct SecBottomNavExpandedView: View {
    
    /// Height of the screen.
    @State var screenHeight:CGFloat
    /// Width of the screen.
    @State var screenWidth:CGFloat
    /// Data containing secondary footer menu items.
    let data:SecondaryFooterMenu
    /// Closure called when a menu item is tapped.
    let onItemClick:(SecondaryFooterMenuItem)->Void
    /// Array of grid columns.
    @State var columns:[GridItem] = []
    
    /// Body of the view containing the layout and content.
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                if let items = data.items{
                    let itemsWithId = items.map { item in
                        SecondaryFooterMenuItemWithId(item: item)
                    }
                    ForEach(0..<data.items!.count, id: \.self){ index in
                        if let item = data.items?[index]{
                            SecondaryNavExpandedCell(item: item, bgColor:  Color(
                                data.bgColor == "#000000" ? UIColor(hexString:data.bgColor ?? "").lighter(by:20) : UIColor(hexString:data.bgColor ?? "").darker(by:4)
                            ), textColor: Color(UIColor(hexString: data.textColor ?? ""))).onTapGesture {
                                onItemClick(item)
                            }
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
        let totalItems = data.items?.count ?? 0
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

struct SecondaryFooterMenuItemWithId{
    let id =  UUID()
    let item:SecondaryFooterMenuItem?
}

/**
 A SwiftUI view that represents a cell in the secondary navigation expanded view.

 The `SecondaryNavExpandedCell` displays an icon or a text label for a secondary footer menu item.
 */
struct SecondaryNavExpandedCell:View {
    
    /// The secondary footer menu item to display.
    let item:SecondaryFooterMenuItem
    /// Background color of the cell.
    let bgColor:Color
    /// Text color of the cell.
    let textColor:Color
    
    var body: some View {
        ZStack{
            bgColor
            HStack(alignment: .center) {
                // When the live preview is visible, retrieve the image from the file URL.
                let image = WebToNativeCore.isLivePreviewVisible ? item.fileUrl : item.fileName
                Spacer().frame(maxWidth: 4)
                if image?.starts(with: "http") ?? false {
                    if let imageUrl = image, let url = URL(string: imageUrl){
                        KFImage(url).resizable().frame(width: 30, height: 30, alignment: .leading).clipShape(Circle()).aspectRatio(contentMode: .fit)
                    }
                }
                else if let filePath = image, let actualFileName = getFileName(from: filePath),let image = UIImage(named: actualFileName){
                    Image(uiImage: image).resizable().frame(width: 30, height: 30, alignment: .leading).clipShape(Circle()).aspectRatio(contentMode: .fit)
                } else{
                    ZStack(alignment: .center){
                        Circle()
                            .fill(textColor)
                            .frame(width: 30 , height: 30, alignment: .leading)
                        Text(item.label?.prefix(1) ?? "")
                            .font(.system(size: 17,weight: .semibold))
                            .foregroundColor(bgColor)
                    }.frame(alignment: .leading)
                }
                Spacer().frame(maxWidth: 4)
                Text(item.label ?? "")
                    .foregroundColor(textColor)
                Spacer(minLength: 0)
            }.frame(height: 50)
        }.frame(minWidth: 0, maxWidth: .infinity, maxHeight: 50).clipShape(RoundedRectangle(cornerRadius: 7))
    }
}
