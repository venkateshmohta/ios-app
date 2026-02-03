//
//  FullScreenOfferCardView.swift
//  WebToNative
//
//  Created by Akash Kamati on 14/06/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import SwiftUI
import AVKit
import Kingfisher

/**
 View for displaying a full-screen offer card based on configuration.
 
 - Parameters:
   - screenWidth: Binding to the width of the screen.
   - screenHeight: Binding to the height of the screen.
   - config: Configuration object defining the properties and content of the offer card (`OfferCardConfig`).
   - onDismiss: Closure to be executed when the offer card is dismissed.
   - onActionButtonClick: Closure to be executed when the action button on the offer card is clicked.
   - onFailedToLoad: Closure to handle the scenario when content fails to load.
 
 This view displays a full-screen offer card with either an image or video content, adjusting its size and appearance based on screen dimensions and configuration settings.
 */
struct FullScreenOfferCardView: View {
    @Binding var screenWidth:CGFloat
    @Binding var screenHeight:CGFloat
    let config:OfferCardConfig
    let onDismiss:()->Void
    let onActionButtonClick:()->Void
    let onFailedToLoad:()->Void
    
    
    @State private var showAlert:Bool = false
    @State private var computedSize:CGSize = CGSize(width: 0, height: 0)
    @State private var originalSize:CGSize = CGSize(width: 0, height: 0)
    @State private var contentUrl:URL? = nil

    
    var body: some View {
        
        ZStack{
            Color(UIColor(hexString: config.card?.bgColor ?? "#000000")).scaledToFill().edgesIgnoringSafeArea([.bottom])
            VStack(spacing: 0){
                if contentUrl != nil{
                    if config.card?.content?.type == .image{
                        KFImage(contentUrl).onSuccess { result in
                            // Extract the image size from the result
                            if let cgImage = result.image.cgImage {
                                originalSize = CGSize(width: cgImage.width, height: cgImage.height)
                                computedSize = getOfferCardSize(
                                    originalSize: originalSize,
                                    screenHeight: screenHeight,
                                    screenWidth: screenWidth,
                                    size: .fullScreen
                                )
                            }
                        }.onFailure{ error in
                            onFailedToLoad()
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: computedSize.width,height: computedSize.height)
                    }
                    
                    if config.card?.content?.type == .video{
                        CustomVideoPlayer(player: AVPlayer(url: contentUrl!), bgColorCode: config.card?.bgColor ?? "#000000")
                            .frame(width: screenWidth, height: screenHeight)
                            .scaledToFit()
                    }
                }
            }
        }.scaledToFill().edgesIgnoringSafeArea([.bottom]).frame(maxWidth: .infinity,maxHeight: .infinity).overlay(
            ActionAndDismissButtonView(
                screenWidth: screenWidth,
                actionBtnData: config.action?.button,
                onDismissButtonClick: onDismiss,
                onActionButtonClick: onActionButtonClick
            ).frame(maxWidth: screenWidth,maxHeight: screenHeight)
        ).onAppear{
            if let urlString = config.card?.content?.url, let url = URL(string: urlString){
                contentUrl = url
                if config.card?.content?.type == .video{
                    if let track =  AVAsset(url: url).tracks(withMediaType: .video).first {
                        let videoSize = track.naturalSize
                        originalSize = CGSize(width: videoSize.width, height: videoSize.height)
                        computedSize = getOfferCardSize(
                            originalSize: computedSize,
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            size: .fullScreen
                        )
                    }else{
                       onFailedToLoad()
                    }
                }
            }else{
                onFailedToLoad()
            }
        }.onChange(of:screenHeight){height in
            computedSize = getOfferCardSize(
                originalSize: CGSize(width: originalSize.width, height: originalSize.height),
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                size: .fullScreen
            )
        }
    }
}
