//
//  LoadingView.swift
//  WebToNative
//
//  Created by yash saini on 17/09/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//

import SwiftUI
import Lottie
import WebToNativeCore

struct PreviewLoadingView: View {
    let appConfig: WebToNativeConfigData?

    var body: some View {
        VStack{
            Text("Loading Preview")
                .foregroundColor(Color.black)
            
            CircularProgressBar(indicatorColor: "#ff0000", bgColor: "#ffffff", enableShadow: false)
            
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .ignoresSafeArea(.all)
    }
}
