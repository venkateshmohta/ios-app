//
//  OfferCardView.swift
//  WebToNative
//
//  Created by Akash Kamati on 14/06/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import SwiftUI

/**
 
 SwiftUI view for displaying an offer card based on provided configuration and screen dimensions.
 The `OfferCardView` struct renders either a full-screen offer card or a small/medium offer card based on the configuration's `size` property.


 - Parameters:
   - screenWidth: Binding to the width of the screen where the offer card is displayed.
   - screenHeight: Binding to the height of the screen where the offer card is displayed.
   - config: Configuration object (`OfferCardConfig`) that defines the content and behavior of the offer card.
   - onDismiss: Closure called when the offer card is dismissed.
   - loadActionUrl: Closure to load a specified URL when the offer card's action button is clicked.
   - onFailedToLoad: Closure to handle scenarios where loading the action URL fails.

 This view manages the presentation of different sizes of offer cards (`FullScreenOfferCardView` or `SmallAndMediumOfferCardView`) based on the configuration's `size` property. It provides overlays with appropriate backgrounds and handles user interactions such as dismissal and action button clicks.

 */
struct OfferCardView: View {
    @Binding var screenWidth:CGFloat
    @Binding var screenHeight:CGFloat
    let config:OfferCardConfig
    let onDismiss:()->Void
    let loadActionUrl:(String)->Void
    let onFailedToLoad:()->Void
    
    var body: some View {
        
        ZStack{
            if config.card?.size == .fullScreen {
                Color.black.opacity(0.5).edgesIgnoringSafeArea([.all])
                    .overlay(
                        FullScreenOfferCardView(
                            screenWidth: $screenWidth,
                            screenHeight: $screenHeight,
                            config: config,
                            onDismiss: onDismiss,
                            onActionButtonClick: {
                                onDismiss()
                                if let url = config.action?.url{
                                    loadActionUrl(url)
                                }
                            },
                            onFailedToLoad: onFailedToLoad
                        )
                    )
            }else{
                Color.black.opacity(0.5).edgesIgnoringSafeArea(.bottom)
                    .overlay(
                        SmallAndMediumOfferCardView(
                            screenWidth: $screenWidth,
                            screenHeight: $screenHeight,
                            config: config,
                            onDismiss: onDismiss,
                            onActionButtonClick: {
                                onDismiss()
                                if let url = config.action?.url{
                                    loadActionUrl(url)
                                }
                            },
                            onFailedToLoad: onFailedToLoad
                        )
                    )
            }
        }
    }
}
