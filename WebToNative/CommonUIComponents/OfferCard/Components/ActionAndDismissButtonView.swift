//
//  ActionAndDismissButtonView.swift
//  WebToNative
//
//  Created by Akash Kamati on 14/06/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import SwiftUI

/**
 View for displaying action and dismiss buttons within an offer card.
 
 - Parameters:
   - screenWidth: Width of the screen.
   - actionBtnData: Data defining the properties of the action button (`OfferCardActionButton`).
   - onDismissButtonClick: Closure to be executed when the dismiss button is clicked.
   - onActionButtonClick: Closure to be executed when the action button is clicked.
 
 This view contains a dismiss button and optionally an action button with customizable text and colors based on the provided data. It handles user interactions to trigger dismiss and action actions within the offer card.
 */
struct ActionAndDismissButtonView: View {
    var screenWidth:CGFloat
    let actionBtnData:OfferCardActionButton?
    let onDismissButtonClick:()->Void
    let onActionButtonClick:()->Void
    var body: some View {
        
        let contentColor = Color(UIColor(hexString: actionBtnData?.textColor ?? "#FFFFFF"))
        let bgColor = Color(UIColor(hexString: actionBtnData?.bgColor ?? "#111111"))
        
        VStack{
            
            HStack{
                Spacer()
                ZStack {
                    Circle()
                        .fill(contentColor)
                        .frame(width: 27, height: 27)
                    
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 13, height: 13)
                        .foregroundColor(bgColor)
                }.padding([.top,.trailing],3)
                .onTapGesture {
                     onDismissButtonClick()
                }
            }
            
            Spacer()
            if let text = actionBtnData?.text,!text.isEmpty{
                ZStack{
                    Text(text)
                        .font(.system(size: 17))
                        .foregroundColor(contentColor)
                        .lineLimit(1)
                        .padding(.horizontal,10)
                        .padding(.vertical,5)
                        .background(bgColor.cornerRadius(6))
                        .cornerRadius(6)
                }
                .padding(.bottom,7)
                .onTapGesture {
                    onActionButtonClick()
                }
            }
        }
    }
}
