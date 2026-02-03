//
//  PreviewBar.swift
//  WebToNative
//
//  Created by yash saini on 02/09/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//

import SwiftUI
import WebToNativeCore

import SwiftUI
import WebToNativeCore

struct PreviewBar: View{
    var closeClick: () -> Void
    var reloadClick: () -> Void
    @State private var showOptions = false
    
    var body: some View{
        VStack{
            Spacer()
            HStack{
                Spacer()
                if !showOptions {
                    Button(action: {
//                        withAnimation(.easeInOut(duration: 0.2)){
                            showOptions = true
//                        }
                
                    }) {
                        IconView(iconName: "md mi-keyboard-double-arrow-left", iconColor: "#FF4A26", iconSize: 35)
                    }.background(
                        HalfPillShape()
                            .fill(Color.white)
                            .frame(width: 50, height: 50).overlay(
                                HalfPillShape()
                                    .stroke(Color.black.opacity(0.2), lineWidth: 0.25) // ← Border
                            ).shadow(radius: 3)
                    )
                } else {
                    
                    ZStack(alignment: .trailing) {
                        
                        Color.white.opacity(0.1).edgesIgnoringSafeArea(.all).onTapGesture {
                            if showOptions {
//                                withAnimation(.easeInOut(duration: 0.2)){
                                    showOptions = false
//                                } 
                            }
                        }
                        
                               PreviewSettingsMenu(
                                onRefresh: {
                                    reloadClick()
                                    showOptions = false
                                },
                                onClose: {
                                    closeClick()
                                    showOptions = false
                                }
                               )
                    }.frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .trailing)
                    
                }
                
                
            }
            Spacer()

        }.frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .center).ignoresSafeArea(.all)
        
    }
}

struct PreviewSettingsMenu: View {
    var onRefresh: () -> Void = {}
    var onClose: () -> Void = {}
    
    @State private var isRefresh = false
    @State private var isClose = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // App name
            Text(WebToNativeConfig.sharedConfig?.appName ?? "WebToNative")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.top, 8)
            
            // App name
            Text(WebToNativeConfig.sharedConfig?.websiteLink ?? "")
                .font(.caption)
                .lineLimit(1)
                .foregroundColor(.gray)
                .padding(.top, -4)
                .padding(.horizontal, 12)

            Divider()

            // Refresh Button
            Button(action: {
                isRefresh.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                    onRefresh()
                }
            }) {
                HStack(spacing: 8) {
                    IconView(iconName: "md mi-refresh", iconColor: isRefresh ? "#FF4A26" : "#8896A9", iconSize: 25)
                    Text("Refresh").foregroundColor(isRefresh ? Color(UIColor(hex: "#FF4A26")) : Color(UIColor(hex: "#8896A9")))
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .cornerRadius(6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isRefresh ? Color(UIColor(hex: "#FFEBE7")) : Color.clear)
                )
            }
            .buttonStyle(.automatic).frame(maxWidth: .infinity)

            // Close Button
            Button(action: {
                isClose.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                    onClose()
                }
            }) {
                HStack(spacing: 8) {
                    IconView(iconName: "md mi-close", iconColor: isClose ? "#FF4A26" : "#8896A9", iconSize: 25)
                    Text("Close").foregroundColor(isClose ? Color(UIColor(hex: "#FF4A26")) : Color(UIColor(hex: "#8896A9")))
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isClose ? Color(UIColor(hex: "#FFEBE7")) : Color.clear)
                )
            }
            .buttonStyle(.automatic).frame(maxWidth: .infinity)
            Spacer().frame(height: 3)

        }
        .frame(width: 180)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct HalfPillShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let radius = rect.height / 2

        path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.midY),
                    radius: radius,
                    startAngle: .degrees(270),
                    endAngle: .degrees(90),
                    clockwise: true)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()

        return path
    }
}
