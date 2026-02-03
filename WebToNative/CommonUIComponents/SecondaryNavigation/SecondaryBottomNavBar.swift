//
//  SecondaryBottomNavBar.swift
//  WebToNative
//
//  Created by Akash Kamati on 10/06/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import SwiftUI
import WebToNativeCore

/**
 A SwiftUI view that displays a secondary bottom navigation bar.

 The `SecondaryBottomNavBar` struct renders a compact bar containing up to three secondary footer menu items. If more than three items are available, it displays an expand button.
 */
struct SecondaryBottomNavBar: View {
    
    /// Data containing secondary footer menu items.
    let data:SecondaryFooterMenu
    /// Binding to the current URL string.
    @Binding var currentUrl:String
    /// Width of the screen.
    var screenWidth:CGFloat
    /// Closure called when a menu item is tapped.
    let onItemClick: (SecondaryFooterMenuItem) -> Void
    /// Closure called when the expand icon is tapped.
    let onExpandIconClick: () -> Void
    
    var body: some View {
            VStack(alignment: .center){
                HStack(alignment: .bottom) {
                    
                    
                    let items = data.items?.prefix(3) ?? []
                    let tabSize = data.items?.count ?? 0 > 3 ? 3 : data.items?.count ?? 0
                      
                    ForEach(0..<tabSize, id: \.self){ index in
                        if let item = data.items?[index]{
                            Text(truncatedLabel(itemsCount: data.items?.count ?? 0, item: item, isPortrait: screenWidth < 500))
                              .frame(height: 30, alignment: .center)
                              .foregroundColor(Color(UIColor(hexString: data.textColor ?? "#DCDDDF")))
                              .font(areUrlsEqual(currentUrl, item.url ?? "") ? .system(size: 16, weight: .bold) : .system(size: 16, weight: .regular))
                              .lineLimit(1)
                              .onTapGesture {
                                  onItemClick(item)
                            }
                        }
                        if index < items.count - 1 {
                            SeparatorView(color: UIColor(hexString: data.bgColor ?? "").lighter(by: 20)).frame( height: 30, alignment: .center)
                        }
                    }
                    if data.items?.count ?? 0 > 3 {
                        SeparatorView(color: UIColor(hexString: data.bgColor ?? "").lighter(by: 20)).frame( height: 30, alignment: .center)
                        
                        ExpandButton(
                            bgColor:Color(UIColor(hexString: data.bgColor ?? "").lighter(by: 20)),
                            chevronColor: Color(UIColor(hexString: data.textColor ?? "#DCDDDF"))
                        ).frame(height: 30,alignment: .center)
                        .onTapGesture {
                            onExpandIconClick()
                        }
                    }
                }.frame(height: 38,alignment: .center).padding(.horizontal,10)
            
            
        }
       
        //.cornerRadius(10)
        .background(Color(UIColor(hexString: data.bgColor ?? "#2A2E37")))
        .clipped()
        .cornerRadius(20)
        .frame(height: 40,alignment: .center)
        .padding(.horizontal, 3)
        .padding(.bottom, 20 + CGFloat(data.bottomMargin ?? 0) / UIScreen.main.scale)
        
        
    }
    

    /// Truncates the label text if necessary based on screen size and item count.
    private func truncatedLabel(itemsCount:Int,item: SecondaryFooterMenuItem?, isPortrait:Bool) -> String {
        var truncatedText = item?.label ?? ""
        let characterLimit = 11
        if let label = item?.label, label.count > characterLimit && isPortrait && itemsCount > 2 {
            truncatedText = String(label.prefix(characterLimit)) + "..."
        }
        return truncatedText
    }
    
}


/**
 A SwiftUI view that displays an expand button with a chevron shape.
  The `ExpandButton` struct renders a circular button with a chevron shape inside.
 */
struct ExpandButton: View {
    /// Background color of the button.
    var bgColor: Color
    /// Color of the chevron shape.
    var chevronColor: Color
    
    var body: some View {
        Circle()
            .fill(bgColor)
            .frame(width: 20, height: 20)
            .overlay(
                ChevronShape()
                    .stroke(chevronColor, lineWidth: 1.4)
            )
    }
}

///A SwiftUI view that displays a vertical separator.
///The `SeparatorView` struct renders a vertical line as a separator.
struct SeparatorView: View {
    var color: UIColor

    var body: some View {
        Rectangle()
            .fill(Color(color))
            .frame(width: 1.5, height: 15)
    }
}


/// A SwiftUI shape representing a chevron.
/// The `ChevronShape` struct defines a shape with two diagonal lines forming a chevron.
struct ChevronShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let topPoint = CGPoint(x: rect.midX, y: rect.minY + 8)
        let startPoint = CGPoint(x: rect.minX + 6, y: rect.maxY - 8)
        let endPoint = CGPoint(x: rect.maxX - 6, y: rect.maxY - 8)
        
        path.move(to: topPoint)
        path.addLine(to: startPoint)
        path.move(to: topPoint)
        path.addLine(to: endPoint)
        
        return path
    }
}

/// Creates the path for the chevron shape.
/// - Parameter rect: The bounding rectangle of the shape.
/// - Returns: The path representing the chevron shape.
func getSecondaryBottomNavData(url:String?) -> SecondaryFooterMenu?{
    if url == nil { return nil }
    let navData = WebToNativeConfig.sharedConfig?.SECONDARY_NAVIGATION?.data
    if navData == nil { return nil}
    
    if(navData?.menus == nil || navData?.menus?.isEmpty == true) { return nil }
    
    var result:SecondaryFooterMenu? = nil
    
    for data in navData?.menus ?? [] {
        if let regexString = data?.regex, let regex = try? NSRegularExpression(pattern: regexString){
            if let _ = regex.firstMatch(in: url!, range: NSRange(url!.startIndex..., in: url!)) {
                //match found continue..
                result = data
                break
            }
        }
    }
    
    return result
    
}
