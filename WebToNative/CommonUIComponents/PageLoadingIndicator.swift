//
//  PageLoadingIndicator.swift
//  WebToNative
//
//  Created by Akash Kamati on 29/05/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import SwiftUI
import WebToNativeCore
import Lottie

/**
 SwiftUI view representing a page loading indicator.

 - Note: SwiftUI views automatically infer types for parameters based on their assigned values, allowing for concise initialization without explicit type annotations.

 - Parameters:
   - data: NavigationLoader object containing configuration data for the loading indicator.
   - progress: Binding to the current progress value. Used in the progress bar type.
   - screenHeight: Height of the screen where the loading indicator is displayed.
   - screenWidth: Width of the screen where the loading indicator is displayed.
 */
struct PageLoadingIndicator: View {
    
    let data: NavigationLoader
    @Binding var progress:Double
    @State var screenHeight:CGFloat
    @State var screenWidth:CGFloat
    @State var rotation: Double = 0.0
    @State var animation: LottieAnimation?
    @State var showLoaderScreen: Bool
    @State var dummyProgress: Double = 0.0
    @State var stopeDummyProgress: Bool = false
    
    var body: some View {
        
        switch data.type!{
        case .ProgressBar:
            
            VStack(alignment: .center){
                Color(UIColor(hexString: data.bgColor ?? "#FFFFFF")).frame(height: 4)
                Spacer()
            }.onAppear{
                stopeDummyProgress = false
                dummyProgressLoader()
            }.onDisappear{
                stopeDummyProgress = true
            }
            
            VStack(alignment: .center){
                ProgressView(value: showLoaderScreen ? dummyProgress : progress)
                    .progressViewStyle(LinearProgressViewStyle(
                        tint: Color(UIColor(hexString: data.loaderColor ?? "#0029FF")))
                    )
                Spacer()
            }
            
        case .LottieAnimation:
            LottieLoaderView(data: data,screenHeight: screenHeight,screenWidth: screenWidth, animation: animation)
            
        case .CircularLoader:
         
            CircularProgressBar(indicatorColor: data.loaderColor ?? "#0029FF",bgColor: data.bgColor ?? "#FFFFFF", enableShadow: data.enableShadow ?? false)
            
        @unknown default:
            EmptyView().frame(width: 0,height: 0)
        }
    }
    
    
    private func dummyProgressLoader(){
        if !stopeDummyProgress {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                if dummyProgress >= 1.0 {
                    dummyProgress = 0.0
                }
                dummyProgress += 0.03
                dummyProgressLoader()
            }
        }
    }
}

/**
 SwiftUI view displaying a Lottie animation loader.

 - Note: SwiftUI views automatically infer types for parameters based on their assigned values, allowing for concise initialization without explicit type annotations.

 - Parameters:
   - data: NavigationLoader object containing configuration data for the Lottie animation loader.
   - screenHeight: Height of the screen where the Lottie animation loader is displayed.
   - screenWidth: Width of the screen where the Lottie animation loader is displayed.
 */
struct LottieLoaderView: View {
    
    
    let data: NavigationLoader
    let screenHeight:CGFloat
    let screenWidth:CGFloat
    @State var animation: LottieAnimation?
    @State var lottieLoopMode : LottieLoopMode = .repeat(1)

    var loaderWidthHeight: (CGFloat,CGFloat) {
        switch data.animationSize ?? .MEDIUM {
         case .FULL:
             return (310,310)
        case .LARGE:
            return (300,300)
        case .MEDIUM:
            return (170,170)
        case .SMALL:
             return (90,90)
        case .FIXED_SIZE:
            return (CGFloat(data.height ?? 0) - 100, CGFloat(data.width ?? 0) - 100)
        @unknown default:
            return (0,0)
        }
     }
    
    var loaderBGWidthHeight:(CGFloat,CGFloat) {
        switch data.animationSize ?? .MEDIUM {
         case .FULL:
             return (screenWidth,screenHeight)
        case .LARGE:
            return (350,350)
        case .MEDIUM:
            return (200,200)
        case .SMALL:
             return (100,100)
        case .FIXED_SIZE:
            return (CGFloat(data.height ?? 0), CGFloat(data.width ?? 0))
        @unknown default:
            return (0,0)
        }
    }
    
    var loaderShape: CGFloat {
        switch data.animationShape ?? .RECTANGLE {
        case .RECTANGLE:
            return loaderBGWidthHeight.0 / 10
        case .CIRCULAR:
            if data.animationSize == .MEDIUM || data.animationSize == .SMALL {
                return loaderBGWidthHeight.0 / 2.0
            } else {
                return loaderBGWidthHeight.0 / 10
            }
        @unknown default:
            return 0
        }
    }
    

    
    var body: some View {
        ZStack(alignment: .center){
            if data.animationBgColor != "#00000000" {
                if(data.animationSize == .FULL){
                    Color(UIColor(hexString: data.animationBgColor ?? "#FFFFFF"))

                }else{
                    let enableShadow = data.enableShadow ?? false
                    let shadowRadius: CGFloat = enableShadow ? 5 : 0
                    let shadowColor =  if  enableShadow {  Color.black.opacity(0.3) } else {
                        Color(UIColor(hexString: data.animationBgColor ?? "#FFFFFF"))
                    }
                    
                    Color(UIColor(hexString: data.animationBgColor ?? "#FFFFFF"))
                        .frame(
                            width:loaderBGWidthHeight.0,
                            height:loaderBGWidthHeight.1,
                            alignment: .center
                        ).clipShape(RoundedRectangle(cornerRadius: loaderShape))
                        .shadow(color: shadowColor, radius: shadowRadius)
                }
                
            }
                    
            VStack(alignment: .center){
                let animationData = WebToNativeCore.isLivePreviewVisible && animation != nil ? animation :  .named("LottieLoader")
                LottieView(animation: animationData)
                    .looping()
                    .frame(
                        width: loaderWidthHeight.0,
                        height: loaderWidthHeight.1,
                        alignment:.center
                    )
             
            }
        }
    }
}
