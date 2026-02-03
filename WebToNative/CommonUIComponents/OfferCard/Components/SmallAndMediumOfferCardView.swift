//
//  SmallAndMediumOfferCardView.swift
//  WebToNative
//
//  Created by Akash Kamati on 14/06/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import SwiftUI
import AVKit
import Kingfisher

/**
 View for displaying small and medium-sized offer cards based on configuration.
 
 - Parameters:
   - screenWidth: Binding to the width of the screen.
   - screenHeight: Binding to the height of the screen.
   - config: Configuration object defining the properties and content of the offer card (`OfferCardConfig`).
   - onDismiss: Closure to be executed when the offer card is dismissed.
   - onActionButtonClick: Closure to be executed when the action button on the offer card is clicked.
   - onFailedToLoad: Closure to handle the scenario when content fails to load.
 
 This view displays offer cards with video or image content, adjusting their size and position based on screen dimensions and configuration settings.
 */
struct SmallAndMediumOfferCardView: View {
    @Binding var screenWidth:CGFloat
    @Binding var screenHeight:CGFloat
    
    let config:OfferCardConfig
    let onDismiss:()->Void
    let onActionButtonClick:()->Void
    let onFailedToLoad:()->Void


    @State private var computedSize:CGSize = CGSize(width: 0, height: 0)
    @State private var originalSize:CGSize = CGSize(width: 0, height: 0)
    @State private var contentUrl:URL? = nil
   
    
    var body: some View {
        VStack{
            Spacer()
            HStack{
                if contentUrl != nil{
                    if config.card?.size == .small && config.card?.position == .right{
                        Spacer()
                    }
                    if config.card?.content?.type == .video{
                        CustomVideoPlayer(player: AVPlayer(url: contentUrl!), bgColorCode: config.card?.bgColor ?? "#111111")
                            .frame(width: computedSize.width,height: computedSize.height)
                            .overlay(
                                ActionAndDismissButtonView(
                                    screenWidth: screenWidth,
                                    actionBtnData: config.action?.button,
                                    onDismissButtonClick: onDismiss,
                                    onActionButtonClick: onActionButtonClick
                                )
                            )
                            .scaledToFit()
                            .cornerRadius(20)
                            .clipped()
                        
                    }
                    
                    if config.card?.content?.type == .image{
                        KFImage(contentUrl)
                            .onSuccess { result in
                                if let cgImage = result.image.cgImage {
                                    originalSize = CGSize(width: cgImage.width, height: cgImage.height)
                                    computedSize = getOfferCardSize(
                                        originalSize: originalSize,
                                        screenHeight: screenHeight, screenWidth:  screenWidth, size: config.card?.size ?? .small
                                    )
                                }
                            }.onFailure{ error in
                                onFailedToLoad()
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: computedSize.width,height: computedSize.height)
                            .overlay(
                                ActionAndDismissButtonView(
                                    screenWidth: screenWidth,
                                    actionBtnData: config.action?.button,
                                    onDismissButtonClick: onDismiss,
                                    onActionButtonClick: onActionButtonClick
                                )
                            )
                            .background(Color(UIColor(hexString: config.card?.bgColor ?? "#111111")))
                            .cornerRadius(20)
                            .clipped()
                    }
                    if config.card?.size == .small && config.card?.position == .left{
                        Spacer()
                    }
                }
            }.padding([.horizontal],screenWidth>screenHeight ? 10 : 3).padding(.bottom)
            
        }.onAppear{
            if let urlString = config.card?.content?.url, let url = URL(string: urlString){
                contentUrl = url
                if config.card?.content?.type == .video{
                    if let track =  AVAsset(url: url).tracks(withMediaType: .video).first {
                        let videoSize = track.naturalSize
                        originalSize = CGSize(width: videoSize.width, height: videoSize.height)
                        computedSize = getOfferCardSize(
                            originalSize: originalSize,
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            size: config.card?.size ?? .small
                        )
                    }else{
                        onFailedToLoad()
                    }
                }
            }else{
                onFailedToLoad()
            }
        }.onChange(of: screenHeight){ value in
            computedSize = getOfferCardSize(
                originalSize: originalSize,
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                size: config.card?.size ?? .small
            )
        }
        
    }
}
