//
//  CircularProgressBar.swift
//  WebToNative
//
//  Created by Akash Kamati on 29/05/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import SwiftUI

/**
 SwiftUI view representing a circular progress bar.

 - Note: SwiftUI views automatically infer types for parameters based on their assigned values, allowing for concise initialization without explicit type annotations.

 - Parameters:
   - rotation: Initial rotation angle of the progress bar. Default is `0.0`.
   - indicatorColor: Color of the progress indicator in hex format (e.g., "#0029FF"). Default is `#0029FF`.
   - bgColor: Background color of the circular container in hex format (e.g., "#FFFFFF"). Default is `#FFFFFF`.
 */
struct CircularProgressBar: View {
    
    @State var rotation: Double = 0.0
    
    var indicatorColor:String = "#0029FF"
    var bgColor:String = "#FFFFFF"
    var enableShadow: Bool = false
    
    var body: some View {
        ZStack{
            
            if enableShadow {
                Circle()
                    .foregroundColor(Color(UIColor(hexString:  bgColor)))
                    .frame(width: 50, height: 50)
                    .shadow(color: Color.black.opacity(0.3), radius: enableShadow ? 10: 0)
            }
            else {
                Circle()
                    .foregroundColor(Color(UIColor(hexString:  bgColor)))
                    .frame(width: 50, height: 50)
            }
           

            Circle()
                .trim(from: 0.0, to: CGFloat(0.75))
                .stroke(Color(UIColor(hexString:  indicatorColor)), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(rotation))
                .frame(width: 25, height: 25)
                .onAppear {
                    withAnimation(Animation.linear(duration: 0.9).repeatForever(autoreverses: false)){
                        self.rotation = 360
                }
            }
        }
    }
}

