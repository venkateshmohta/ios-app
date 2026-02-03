//
//  CustomTextView.swift
//  WebToNative
//
//  Created by Akash Kamati on 22/05/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import SwiftUI

/**
 SwiftUI view representing a customizable text view.

 This view displays text with specified attributes such as text color, font weight, font size, opacity, and text alignment.

 - Parameters:
   - textColor: The color of the text. Default is white (#FFFFFF).
   - text: The actual text content to display.
   - fontWeight: The weight of the text font. Default is 500.
   - fontSize: The size of the text font. Default is 15.
   - textColorOpacity: The opacity of the text color. Default is 1.0 (fully opaque).
   - multilineTextAlignment: The alignment for multiline text. Default is center alignment.

 - Note: This view provides flexibility in customizing text appearance, including color, font characteristics, and alignment.

 - Important: SwiftUI views use a declarative syntax to define UI elements, making it easier to create and maintain complex interfaces.
 */
struct CustomTextView:View {
    
    let textColor:String?
    let text:String
    let fontWeight:Int?
    let fontSize:Int?
    var textColorOpacity:CGFloat? = 1.0
    var multilineTextAlignment:TextAlignment = .center
    
    var body: some View {
        Text(text)
            .frame(alignment: .center)
            .multilineTextAlignment(multilineTextAlignment)
            .font(.system(size: CGFloat(fontSize ?? 15), weight: WebToNative.fontWeight(for: fontWeight ?? 500)))
            .foregroundColor(Color(UIColor(hexString: textColor ?? "#FFFFFF")).opacity(textColorOpacity!))
            
    }
}
