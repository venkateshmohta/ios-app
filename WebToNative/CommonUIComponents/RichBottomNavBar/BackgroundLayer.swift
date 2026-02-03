//
//  BackgroundLayer.swift
//  WebToNative
//
//  Created by yash saini on 12/06/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//
import WebToNativeCore
import SwiftUI
import WebToNativeIcons


struct BackgroundLayer: View{
    let floatingBtnPosition: String?
    let bottomNavHeight: CGFloat
    let bgColor: UIColor
    let cornerRadius: CGFloat
    let screenWidth: CGFloat
    let tabs: [RichBottomBarTab?]?
    let floatingBtnIndex: Int
    let curvePosition: String
    let bottomNavSideCurveRadius: Int
    
    var body: some View{
        let curveSize = bottomNavSideCurveRadius == 0 ? 0.0 : CGFloat(bottomNavSideCurveRadius - 4)
        ZStack {
            // bottom nav side corners
            HStack {
                LeftCurveShape(curveSize: curveSize)
                            .fill(Color(bgColor))
                            .frame(width: 20, height: bottomNavHeight)
                Spacer()
                RightCurveShape(curveSize: curveSize)
                            .fill(Color(bgColor))
                            .frame(width: 20, height: bottomNavHeight)
            }
            if floatingBtnPosition == "Outward" {
                GeometryReader { geometry in
                    if curvePosition == "middle"{
                        let outwardCurveWidth = CGFloat(90)
                        let extraBgSize = geometry.size.width > 500 ? (geometry.size.width - 500)/2 : 0
                        
                        let leftPadding = extraBgSize > 20 && floatingBtnIndex == 0 ? outwardCurveWidth / 2 - (500.0 / CGFloat(tabs!.count)) * 0.5 : 0
                        let rightPadding = extraBgSize > 20 && floatingBtnIndex + 1 == tabs?.count ? outwardCurveWidth / 2 - (500.0 / CGFloat(tabs!.count)) * 0.5 : 0
                        
                        let leftAreaPadding = CGFloat(rightPadding)  - CGFloat(leftPadding)
                        let rightAreaPadding = CGFloat(leftPadding) - CGFloat(rightPadding)
                        
                        HStack(spacing: 0){
                            Rectangle().foregroundColor(Color(bgColor)).frame(width: extraBgSize + leftAreaPadding)
                                GeometryReader { geo in
                                    HStack(spacing: 0){
                                        let leftAreaWidth = getBgLeftAreaWidth(bgAreaWidth: geo.size.width, noOfTabs: tabs!.count, floatingBtnIndex: floatingBtnIndex, outwardCurveWidth: outwardCurveWidth)
                                        let rightAreaWidth = geo.size.width - leftAreaWidth - outwardCurveWidth
                                        Rectangle().foregroundColor(Color(bgColor)).frame(maxWidth: leftAreaWidth)
                                        HStack {
                                            outwardCurve().fill(Color(bgColor))
                                            
                                        }.frame(maxWidth: outwardCurveWidth).frame(width: outwardCurveWidth)
                                        
                                        Rectangle().foregroundColor(Color(bgColor)).frame(maxWidth: rightAreaWidth)
                                    }
                                }.frame(maxWidth: 500)
                            Rectangle().foregroundColor(Color(bgColor)).frame(width: extraBgSize + rightAreaPadding)
                        }
                        
                    }
                    else {
                        let outwardCurveWidth = CGFloat(90)
                        let extraBgSize = geometry.size.width > 500 ? (geometry.size.width - 500)/2 : 0
                        
                        let leftPadding = extraBgSize > 20 && floatingBtnIndex == 0 ? outwardCurveWidth / 2 - (500.0 / CGFloat(tabs!.count)) * 0.5 : 0
                        let rightPadding = extraBgSize > 20 && floatingBtnIndex + 1 == tabs?.count ? outwardCurveWidth / 2 - (500.0 / CGFloat(tabs!.count)) * 0.5 : 0
                        
                        let leftAreaPadding = CGFloat(rightPadding)  - CGFloat(leftPadding)
                        let rightAreaPadding = CGFloat(leftPadding) - CGFloat(rightPadding)
                        
                        HStack(spacing: 0){
                            Rectangle().foregroundColor(Color(bgColor)).frame(width: extraBgSize)
                                GeometryReader { geo in
                                    HStack(spacing: 0){
                                        let leftAreaWidth = getBgLeftAreaWidth(bgAreaWidth: geo.size.width, noOfTabs: tabs!.count, floatingBtnIndex: floatingBtnIndex, outwardCurveWidth: outwardCurveWidth)
                                        let rightAreaWidth = geo.size.width - leftAreaWidth - outwardCurveWidth
                                            Rectangle().foregroundColor(Color(bgColor)).frame(maxWidth: leftAreaWidth)
                                        HStack {
                                            outwardCurve().fill(Color(bgColor))
                                            
                                        }.frame(maxWidth: outwardCurveWidth).frame(width: outwardCurveWidth)
                                            Rectangle().foregroundColor(Color(bgColor)).frame(maxWidth: rightAreaWidth)
                                    }
                                }.frame(maxWidth: 500)
                            Rectangle().foregroundColor(Color(bgColor)).frame(width: extraBgSize)
                        }
                        
                    }
                    
                }.padding(.horizontal, 20)
            }
            else {
                Rectangle().foregroundColor(Color(bgColor)).frame(maxWidth: .infinity).padding(.horizontal, 20)
            }
        }.shadow(radius: 0)
        
    }
}


struct SimpleNavBg: View {
    let bgColor: UIColor

    var body: some View {
        HStack{
            Color(bgColor)
        }
    }
}


struct LeftCurveShape: Shape {
    let curveSize: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: width, y: 0))

        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))

        // Draw a curve from bottom to top along left side
        path.addQuadCurve(
            to: CGPoint(x: curveSize, y: 0),
            control: CGPoint(x: -width + 10, y: 5)
        )

        return path
    }
}

struct RightCurveShape: Shape {
    let curveSize: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        path.move(to: CGPoint(x: 0, y: 0))
        // Draw a line to the bottom left corner
        path.addLine(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: width, y: height))
        // Draw a curve from bottom to top along right side
        path.addQuadCurve(
            to: CGPoint(x: width - curveSize, y: 0),
            control: CGPoint(x: width + width - 10, y: 5)
        )
        return path
    }
}
