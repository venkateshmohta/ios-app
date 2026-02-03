//
//  BottomNavigationBar.swift
//  WebToNative
//
//  Created by Akash Kamati on 30/05/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import SwiftUI
import WebToNativeCore
import WebToNativeIcons

/**
 SwiftUI representation of a bottom navigation bar with tabs.
 This struct displays a set of tabs based on provided data (`StickyFooterData`). Each tab consists of an icon and label, with customizable colors for active and inactive states.
 - Parameters:
     - data: Optional StickyFooterData containing configuration for the bottom navigation bar.
     - screenWidth: The width of the screen where the navigation bar is displayed.
     - currentUrl: Binding to the current URL or identifier associated with the selected tab.
     - onItemClick: Closure called when a tab item is tapped, providing the selected StickyFooterButton.
 - Note: This struct dynamically adjusts its layout based on the screen width and tab configurations from StickyFooterData.
 - SeeAlso: `StickyFooterData`
 */
 
struct BottomNavigationBar: View {
    var bottomSafeArea: Bool? = true
    var data:StickyFooterData?
    let screenWidth:CGFloat
    
    @Binding var currentUrl:String
    let onItemClick: (StickyFooterButton) -> Void
    
    var body: some View {
        
        let colors = getBottomNavBarColors(data: data!)
        let bottomNotchAreaSize = UIApplication.shared.windows.first { $0.isKeyWindow }?.safeAreaInsets.bottom ?? 0
        let footerHeight: CGFloat = bottomSafeArea ?? false ? 50 : 50+bottomNotchAreaSize
        let noOfTabs = data?.tabs.count ?? 0
        
        ZStack(alignment: .center){
            
            Color(colorToUIColor(colorCode: data?.bgColor ?? "#FFFFFF"))
            Spacer()
            HStack(alignment: .bottom, spacing: 0){
                
                
                ForEach(data!.tabs ,id:\.icon){tab in
                    
                    let isActive = areUrlsEqual(currentUrl, tab.link)
                    let iconColor = Color(isActive ? colors.activeIconColor : colors.inActiveIconColor)
                    let textColor = Color(isActive ? colors.activeTextColor : colors.inActiveTextColor)
                    
                    
                    let image = tab.icon.contains("/") ?
                    UIImage(named: String(tab.icon.split(separator: "/").last ?? "")) :
                    WebToNativeIcons.imageForIconIdentifier(
                        tab.icon,
                        size: CGFloat(data!.iconFontSize ?? 25),
                        color: isActive ? colors.activeIconColor : colors.inActiveIconColor
                    )
                    
                    VStack(alignment: .center,spacing: 4){

                        if let image = image{
                            Image(uiImage: image)
                                .resizable()
                                .foregroundColor(iconColor)
                                .frame(width: 25, height: 25, alignment: .center)
                        }
                        
                        if let label = tab.label {
                            
                            Text(label)
                                .font(.system(
                                    size: CGFloat(data!.fontSize ?? 15),
                                    weight: isActive ? .bold : .regular)
                                )
                                .foregroundColor(textColor)
                                .fontWeight(isActive ? .bold : .regular)
                        }
                    }
                    .frame(width: screenWidth > 500 ? CGFloat(500/noOfTabs) : screenWidth/CGFloat(noOfTabs))
                    .onTapGesture {
                        onItemClick(tab)
                    }
                }
                
            }.padding(.top, 8).frame(width: screenWidth > 500 ? 500 : screenWidth, height: 50)
           
        }.frame(height: footerHeight)
        
        
    }
}

/**
 Private function to retrieve color configurations for the bottom navigation bar based on `StickyFooterData`.

 This function determines the active and inactive colors for icons and text based on the provided `StickyFooterData`.

 - Parameter data: The `StickyFooterData` object containing color configurations.
 - Returns: A `BottomNavBarColors` object representing active and inactive icon and text colors.
 */
private func getBottomNavBarColors(data:StickyFooterData) -> BottomNavBarColors{
    var inactiveIconColor = colorToUIColor(colorCode: data.iconColor ?? "#000000")
    var activeIconColor:UIColor
    if(data.activeIconColor != nil){
        activeIconColor = colorToUIColor(colorCode: data.activeIconColor!)
    }else{
        activeIconColor = inactiveIconColor
        inactiveIconColor = inactiveIconColor.withAlphaComponent(0.5)
    }

    var inactiveTextColor = colorToUIColor(colorCode: data.textColor ?? "#000000")
    var activeTextColor:UIColor
    if(data.activeIconColor != nil){
        activeTextColor = colorToUIColor(colorCode: data.activeTextColor!)
    }else{
        activeTextColor = inactiveTextColor
        inactiveTextColor = inactiveTextColor.withAlphaComponent(0.5)
    }
    
    return BottomNavBarColors(activeIconColor: activeIconColor, inActiveIconColor: inactiveIconColor, activeTextColor: activeTextColor, inActiveTextColor: inactiveTextColor)
    
}

/**
 Structure representing colors for active and inactive states of icons and text in a bottom navigation bar.

 This struct holds UIColor objects for active and inactive states of icon and text colors.

 - Parameters:
   - activeIconColor: The color for active icons.
   - inActiveIconColor: The color for inactive icons.
   - activeTextColor: The color for active text.
   - inActiveTextColor: The color for inactive text.
 */
struct BottomNavBarColors{
    let activeIconColor:UIColor
    let inActiveIconColor:UIColor
    let activeTextColor:UIColor
    let inActiveTextColor:UIColor
}

/**
 Retrieves the sticky footer data based on the provided URL.

 This function checks if the URL matches any regular expressions defined in the sticky footer configuration. If a match is found, it returns the corresponding `StickyFooterData`.

 - Parameter url: The URL to match against the sticky footer configuration.
 - Returns: A `StickyFooterData` object if a match is found, otherwise `nil`.
 */
func getBottomNavData(url:String?) -> StickyFooterData?{
    if url == nil { return nil }
    let navData = WebToNativeConfig.sharedConfig?.bottomNavigation
    if navData == nil { return nil}
    
    if( navData?.data == nil || navData?.data?.isEmpty ?? true) { return nil }
    
    var result:StickyFooterData? = nil
    
    for data in navData?.data ?? [] {
        if let regex = try? NSRegularExpression(pattern: data.regEx){
            if let _ = regex.firstMatch(in: url!, range: NSRange(url!.startIndex..., in: url!)) {
                //match found continue..
                result = data
                break
            }
        }
    }
    
    return result
        
}
