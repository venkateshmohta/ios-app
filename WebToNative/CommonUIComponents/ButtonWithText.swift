//
//  ButtonWithText.swift
//  WebToNative
//
//  Created by Akash Kamati on 23/05/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import SwiftUI

/**
 SwiftUI view representing a button with text and customizable styling.

 This view combines a button with a custom text view to create a button with specified text, colors, corner radius, background color, border color, and border width.

 - Parameters:
   - text: The text displayed on the button.
   - textColor: The color of the text.
   - roundedCornerPercent: The percentage value for rounding the button's corners.
   - btnBGColor: The background color of the button.
   - borderColor: The color of the button's border.
   - borderWidth: The width of the button's border.
   - screenWidth: The width of the screen, used to determine maximum button width.
   - action: The action closure to execute when the button is tapped.

 - Note: The button's appearance is determined by the provided parameters, including text color, background color, corner radius, border color, and border width.

 - Important: SwiftUI views use a declarative syntax to define UI elements, making it easier to create and maintain complex interfaces.
 */
struct ButtonWithText: View {
    
    let text:String
    let textColor:String
    let roundedCornerPercent: Int
    let btnBGColor:String
    let borderColor:String
    let borderWidth:Int
    let screenWidth:CGFloat
    let action:() ->Void
    
    var body: some View {
        Button{
            action()
        }
        label: {
            CustomTextView(textColor: textColor, text: text, fontWeight: 400 , fontSize: 18)
                .padding()
        }
        .frame(maxWidth: screenWidth >= 500 ? 400 : .infinity,maxHeight: 45)
        .background(Color(UIColor(hexString: btnBGColor)))
        .cornerRadius(CGFloat(Double(roundedCornerPercent) * 45.0 * 0.01))
        .overlay(
            RoundedRectangle(cornerRadius:CGFloat(Double(roundedCornerPercent) * 45.0 * 0.01))
                .stroke(Color(UIColor(hexString: borderColor.isEmpty ? btnBGColor : borderColor)), lineWidth: CGFloat(borderWidth))
        ).onTapGesture{
            action()
        }
        //.padding(.horizontal)
        
    }
    
}

