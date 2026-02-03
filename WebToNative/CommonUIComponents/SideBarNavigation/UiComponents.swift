//
//  UiComponents.swift
//  WebToNative
//
//  Created by yash saini on 19/12/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//
import SwiftUI
import WebToNativeCore
import WebToNativeIcons

public struct SideBarHeader: View {
    let data: SideBarNavigationTab
    let showCrossButton: Bool
    let iconColor: Color
    let bgColor: Color
    let showOnLeft: Bool
    let colorString: String
    let onClick: (String?) -> Void
    let onClose: () -> Void
    
    var showHeaderOnLeft: Bool {
        data.headerPlacement != "right"
    }
    
    
    public var body: some View {
        HStack(spacing: 0) {
            
            if !showHeaderOnLeft {
                Spacer()
            }
            if !showOnLeft && showCrossButton {
                // Close Button
                SideBarCloseButton(colorString: colorString, bgColor: bgColor, showOnLeft: showOnLeft, onClose: {
                    // close SideBar
                    onClose()
                })
            }
            
            // App Icon
            if data.showAppIcon ?? false, let image = UIImage(named: "icon.png") {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
    
            }
            
            // Label
            Text(data.label ?? "")
                .lineLimit(1)
                .font(.system(size: 16, weight: .medium, design: .default))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(iconColor)
                .fixedSize()
                .padding(.horizontal, 5)
            
            
            if showHeaderOnLeft {
                Spacer()
            }
            
            if showOnLeft && showCrossButton {
                // Close Button
                SideBarCloseButton(colorString: colorString, bgColor: bgColor, showOnLeft: showOnLeft, onClose: {
                    // close SideBar
                    onClose()
                })            }

        }.padding(.horizontal, 10)
            .frame(height: 60)
        .onTapGesture {
            onClick(data.url)
        }
    }
}


/// SideBar Close Button
public struct SideBarCloseButton: View {
    let colorString: String
    let bgColor: Color
    let showOnLeft: Bool
    let onClose: () -> Void

    private let iconSize: CGFloat = 30
    private let padding: CGFloat = 5
    private let borderColor = Color(UIColor(hex: "#E6E9EE"))

    private var arrowSize: CGFloat {
        showOnLeft ? (isIPad() ? 30 : 20): 30
    }

    private var iconIdentifier: String {
        showOnLeft
        ? "md mi-arrow-back-ios-new"
        : "md mi-keyboard-arrow-right"
    }

    private var iconImage: UIImage? {
        WebToNativeIcons.imageForIconIdentifier(
            iconIdentifier,
            size: arrowSize,
            color: UIColor(hex: colorString)
        )
    }

    private var iconColor: Color {
        Color(UIColor(hex: colorString))
    }

    // close button padding base on direction
    private var leadingPadding: CGFloat {
        showOnLeft ? 0 : -30
    }

    // close button padding base on direction
    private var trailingPadding: CGFloat {
        showOnLeft ? -30 : 0
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0){
                closeButton
            }
        }
    }

    private var closeButton: some View {
        Group {
            if let image = iconImage {
                Image(uiImage: image)
                    .frame(width: iconSize, height: iconSize)
                    .background(circleBackground)
                    .padding(padding)
                    .padding(.leading, leadingPadding)
                    .padding(.trailing, trailingPadding)
                    .onTapGesture(perform: onClose)
            }
        }
    }

    private var circleBackground: some View {
        Circle()
            .fill(bgColor)
            .overlay(
                Circle().stroke(borderColor, lineWidth: 1)
            )
    }
}

// Disable Bouns effect of Scroll View
//struct NoBounceScrollView<Content: View>: UIViewRepresentable {
//    let content: Content
//
//    init(@ViewBuilder content: () -> Content) {
//        self.content = content()
//    }
//
//    func makeUIView(context: Context) -> UIScrollView {
//        let scrollView = UIScrollView()
//        scrollView.bounces = false
//
//        // ✅ Hide indicators
//        scrollView.showsVerticalScrollIndicator = false
//        scrollView.showsHorizontalScrollIndicator = false
//
//        let hosting = UIHostingController(rootView: content)
//        hosting.view.translatesAutoresizingMaskIntoConstraints = false
//
//        scrollView.addSubview(hosting.view)
//
//        NSLayoutConstraint.activate([
//            hosting.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            hosting.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            hosting.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            hosting.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            hosting.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
//        ])
//
//        return scrollView
//    }
//
//    func updateUIView(_ uiView: UIScrollView, context: Context) {}
//}
