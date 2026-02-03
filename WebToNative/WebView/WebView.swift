//
//  WebView.swift
//  WebToNative
//
//  Created by Akash Kamati on 22/05/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import SwiftUI
import WebKit

/**
 Represents a SwiftUI view that wraps a WKWebView instance, facilitating communication and interaction with web content.
 */
struct WebView: UIViewRepresentable{
    // MARK: - Properties
        
    /// Binding to the WKWebView instance to manage its state.
    @Binding var webView: WKWebView
    
    /// Coordinator object that manages interactions and events between the WKWebView and the native application.
    @ObservedObject var coordinator: WebViewCoordinator

    // MARK: - UIViewRepresentable Protocol Methods
    
    /**
     Creates and configures the WKWebView when the SwiftUI view is created.
     
     - Parameter context: The context in which this view is being created.
     - Returns: An initialized WKWebView instance.
     */
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    /**
     Provides the coordinator instance to manage interactions with the WKWebView.
     
     - Returns: A WebViewCoordinator instance initialized for managing the WKWebView.
     */
    func makeCoordinator() -> WebViewCoordinator {
        coordinator
    }
    
    /**
     Updates the WKWebView when the SwiftUI view's state changes.
     
     - Parameter webView: The WKWebView instance to update.
     - Parameter context: The context in which this view is being updated.
     */
    func updateUIView(_ webView: WKWebView, context: Context) {
        
    }
}
