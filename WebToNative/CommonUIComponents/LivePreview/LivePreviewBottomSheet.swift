//
//  LivePreviewBottomSheet.swift
//  WebToNative
//
//  Created by yash saini on 12/11/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//

import SwiftUI


struct LivePreviewBottomSheet: View {
    let sheetType: LivePreviewSheetType
    let tryAgain: ()-> Void
    let close: ()-> Void
    
    
    var body: some View {
        let title = sheetType == .noInternet ? "No Internet Connection" : "Preview Disconnect"
        let msg = "Please tap on refresh below to reload the App Preview"
        let primaryColor = Color(UIColor(hex: "#FF4A26"))
        let secondaryColor = Color(UIColor(hex: "#3042591A"))
        let msgColor = Color(UIColor(hex: "#181D27"))
        
        
        VStack {
            Text(title)
                .font(.system(size: isIPad() ? 25 : 20))
                .foregroundColor(.primary)
                .fontWeight(.semibold)
                
            if isIPad() {
                Spacer().frame(minHeight: 10)
            }else {
                Spacer()
            }
            
            Text(msg)
                .font(.system(size: isIPad() ? 20 : 14))
                .multilineTextAlignment(.center)
                .foregroundColor(msgColor)
                .frame(alignment: .center)
                .padding(.horizontal, 20)
            
            Spacer().frame(minHeight: isIPad() ? 120 : 10)

            Button(action: { tryAgain() }) {
                Text("Try again")
                    .font(.system(size: isIPad() ? 18 : 16))
                    .fontWeight(.semibold)
                    .padding(.vertical, 5)
                    .foregroundColor(primaryColor)
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(secondaryColor, lineWidth: 2)
                        )
            }.padding(.horizontal, 15)
            
            Spacer().frame(height: isIPad() ? 15 : 10)
            
            Button(action: { close() }) {
                Text("Close Preview")
                    .font(.system(size: isIPad() ? 18 : 16))
                    .fontWeight(.semibold)
                    .padding(.vertical, 5)
                    .foregroundColor(primaryColor)
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(secondaryColor, lineWidth: 2)
                        )
            }.padding(.horizontal, 15)
        }.frame(maxWidth: .infinity).frame(height: 200).frame(maxHeight: 300)
    }
}

