//
//  RichBottomNavBarUtil.swift
//  WebToNative
//
//  Created by yash saini on 26/03/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//


import UIKit
import WebToNativeCore
import Foundation
import SwiftUI

/**
function to retrieve color configurations for the bottom navigation bar based on `StickyFooterData`.

 This function determines the active and inactive colors for icons and text based on the provided `StickyFooterData`.

 - Parameter data: The `StickyFooterData` object containing color configurations.
 - Returns: A `BottomNavBarColors` object representing active and inactive icon and text colors.
 */
func getBottomNavBarColors(data:RichBottomBarData) -> RichBottomNavBarColors{
    var inactiveIconColor = colorToUIColor(colorCode: data.iconColor ?? "#000000")
    var activeIconColor:UIColor
    var backgroundColor:UIColor
    var floatingBtnIconColor:UIColor
    var floatingBtnIconBgColor:UIColor
    
    if(data.activeColor != nil){
        activeIconColor = colorToUIColor(colorCode: data.activeColor!)
    }else{
        activeIconColor = inactiveIconColor
        inactiveIconColor = inactiveIconColor.withAlphaComponent(0.5)
    }

    var inactiveTextColor = colorToUIColor(colorCode: data.iconColor ?? "#000000")
    var activeTextColor:UIColor
    if(data.activeColor != nil){
        activeTextColor = colorToUIColor(colorCode: data.activeColor!)
    }else{
        activeTextColor = inactiveTextColor
        inactiveTextColor = inactiveTextColor.withAlphaComponent(0.5)
    }
    
    backgroundColor = colorToUIColor(colorCode: data.bgColor ?? "#ffffff")
    floatingBtnIconColor = colorToUIColor(colorCode: data.floatingBtnIconColor ?? "#ffffff")
    floatingBtnIconBgColor = colorToUIColor(colorCode: data.floatingBtnBgColor ?? "#fcfcfc")
    
    
    
    return RichBottomNavBarColors(activeIconColor: activeIconColor, inActiveIconColor: inactiveIconColor, activeTextColor: activeTextColor, inActiveTextColor: inactiveTextColor,backgroundColor: backgroundColor, floatingBtnIconColor: floatingBtnIconColor, floatingBtnIconBgColor: floatingBtnIconBgColor)
    
}

func getIconLayerPadding(tabs: Int, width: CGFloat, floatingBtnPosition: String?, floatingButtonIndex: Int) -> CGFloat {
    if floatingBtnPosition == nil || (floatingBtnPosition != nil && floatingButtonIndex == 2 && tabs == 5) {
        return 0
    }
    else if tabs != 5 || width > 500 || floatingBtnPosition != "Outward" || (floatingBtnPosition == "Outward" && tabs == 5 && (floatingButtonIndex == 1 || floatingButtonIndex == 3)){
        return 20.0
    }
    else {
        let iconLayerWidth = width - 40
        let tabWidth = iconLayerWidth / CGFloat(tabs)
        if tabWidth < 90 {
            return (90.0 - tabWidth) / 2 + 22
        }
    }
    return 20.0
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
struct RichBottomNavBarColors{
    let activeIconColor:UIColor
    let inActiveIconColor:UIColor
    let activeTextColor:UIColor
    let inActiveTextColor:UIColor
    let backgroundColor: UIColor
    let floatingBtnIconColor: UIColor
    let floatingBtnIconBgColor: UIColor
}


/**
 Retrieves the sticky footer data based on the provided URL.

 This function checks if the URL matches any regular expressions defined in the sticky footer configuration. If a match is found, it returns the corresponding `StickyFooterData`.

 - Parameter url: The URL to match against the sticky footer configuration.
 - Returns: A `StickyFooterData` object if a match is found, otherwise `nil`.
 */
func getRichBottomBarData(url:String?) -> RichBottomBarData?{
    if url == nil { return nil }
    let navData = WebToNativeConfig.sharedConfig?.ADVANCED_BOTTOM_NAVIGATION
    if navData == nil { return nil}
    
    if(navData?.data == nil || navData?.data?.isEmpty == true ) { return nil }
    
    var result:RichBottomBarData? = nil
    
    for data in navData?.data ?? [] {
        if let regex = try? NSRegularExpression(pattern: data!.regex!){
            if let _ = regex.firstMatch(in: url!, range: NSRange(url!.startIndex..., in: url!)) {
                //match found continue..
                result = data
                break
            }
        }
    }
    return result
}


/**
 This function match current webView Url to bottom nav tabs. if url match then return index of matching url else return -1
 */
func matchCurrentUrl(data: RichBottomBarData?, url:String?) -> Int?{
    if url == nil { return nil }
    if data == nil { return nil}
            
    var index = 0
    var matchUrlIndex = -1
    
    for tab in data?.tabs ?? [] {
        let isEqual = areUrlsEqual(url, tab?.url)
        if isEqual {
            matchUrlIndex = index
            break
        }
        index += 1
    }
    
    return matchUrlIndex
        
}



func getFloatingBtnPosition(list: [RichBottomBarTab?]?) -> (String?, Int){
    if list != nil {
        for i in 0..<list!.count {
            if list?[i]?.type == "floating_button" {
                return (list?[i]?.floatingBtnPosition , i)
            }
        }
    }
    return (nil, -1)
}

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}

class ImageLoaderService: ObservableObject {
    @Published var image: UIImage = UIImage()
    
    func loadImage(for urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                if UIImage(data: data) != nil {
                    self.image = UIImage(data: data)!
                }
            }
        }
        task.resume()
    }
    
}

func getBgLeftAreaWidth(bgAreaWidth: CGFloat, noOfTabs: Int, floatingBtnIndex: Int, outwardCurveWidth: CGFloat) -> CGFloat {
    let a = bgAreaWidth / CGFloat(noOfTabs)
    let b = a * (CGFloat(floatingBtnIndex) + 0.5)
    return b - outwardCurveWidth / 2
}


func getComponentBottomMargin(tabs: [RichBottomBarTab?]?, cornerRadius: CGFloat) -> CGFloat {
    let (floatingBtnPosition, _) = getFloatingBtnPosition(list: tabs)
    if floatingBtnPosition == "Outward" {
        return 27.0
    }else {
        return cornerRadius
    }
    
}

func setCurveBg(tabs: [RichBottomBarTab?]?) -> Bool {
    if tabs?.count == 5 && (tabs?[0]?.type == "floating_button" || tabs?[4]?.type == "floating_button"){
        return true
    }
    return false
}

func getBottomNavHeight(bottomSafeArea: Bool) -> CGFloat {
    let navHeight = CGFloat(65)
    if bottomSafeArea == true {
        return navHeight
    }
    else {
        let bottomNotchAreaSize = UIApplication.shared.windows.first { $0.isKeyWindow }?.safeAreaInsets.bottom ?? 10
        if bottomNotchAreaSize == 0 {
            if isIPad(){
                return CGFloat(80)
            }
            else {
                return navHeight + CGFloat(0)
            }
        }
        else {
            return navHeight + 15
        }
    }
}

// Inward Curve 
struct createInward: Shape {
    let x: CGFloat
    let y: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let height: CGFloat = 30.0
        let path = UIBezierPath()
        let centerWidth = CGFloat(30)


        path.move(to: CGPoint(x: 0, y: 0)) // start top left
        path.addLine(to: CGPoint(x: (centerWidth - height * 2 + x), y: y)) // the beginning of the trough
        
        // first curve down
        path.addCurve(to: CGPoint(x: centerWidth, y: -16.5),
                      controlPoint1: CGPoint(x: (centerWidth - 15), y: 0), controlPoint2: CGPoint(x: centerWidth - 25, y: -16))
        // second curve up
        path.addCurve(to: CGPoint(x: (centerWidth + height * 2 - x), y: y),
                      controlPoint1: CGPoint(x: centerWidth + 25, y: -16), controlPoint2: CGPoint(x: (centerWidth + 15), y: 0))
        path.close()

       return Path(path.cgPath)
    }
}


struct outwardCurve: Shape {
    let width = CGFloat(90)
    
    func path(in rect: CGRect) -> Path {
        let height: CGFloat = 27.0
        let path = UIBezierPath()
        let centerWidth = width / 2

        path.move(to: CGPoint(x: 0, y: 0)) // start top left
//        path.addLine(to: CGPoint(x: (centerWidth - height * 2), y: 0)) // the beginning of the trough

        // first curve down
        path.addCurve(to: CGPoint(x: centerWidth, y: height),
                      controlPoint1: CGPoint(x: (centerWidth - 18), y: 0), controlPoint2: CGPoint(x: centerWidth - 25, y: height))
        // second curve up
        path.addCurve(to: CGPoint(x: (centerWidth + height * 2 - 10), y: 0),
                      controlPoint1: CGPoint(x: centerWidth + 25, y: height), controlPoint2: CGPoint(x: (centerWidth + 18), y: 0))

        // complete the rect
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.close()

        return Path(path.cgPath)
    }
    
    
}
