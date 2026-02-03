//
//  WebViewAlertsHandler.swift
//  WebToNative
//
//  Created by Akash Kamati on 21/06/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import Foundation
import WebKit
import WebToNativeCore

/**
 Handles JavaScript alert, confirm, and text input panels in a WKWebView by presenting UIAlertControllers.

 This class provides static methods to handle JavaScript alerts, confirmation dialogs, and text input prompts by presenting UIAlertControllers. It ensures seamless interaction between JavaScript prompts and native iOS UIAlertControllers for user interaction and feedback.
 */
class WebViewAlertsHandler{
    
    /// Presents an alert panel with a message and OK button.
    ///
    /// - Parameters:
    ///   - webView: The WKWebView instance where the alert panel is triggered.
    ///   - message: The message to display in the alert.
    ///   - frame: Information about the frame that initiated the alert.
    ///   - completionHandler: A closure to call after the alert is dismissed.
    public static func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
//        let rootController = WebToNativeCore.viewController
        
        var rootController: UIViewController? {
            var root = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController
            while let presentedViewController = root?.presentedViewController {
                root = presentedViewController
            }
            return root
        }

        func presentAlert(title: String, subTitle: String, primaryAction: UIAlertAction, secondaryAction: UIAlertAction? = nil) {
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
                alertController.addAction(primaryAction)
                if let secondary = secondaryAction {
                    alertController.addAction(secondary)
                }
             
                rootController?.present(alertController, animated: true, completion: nil)
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
        }

        let primaryAction = UIAlertAction(title: NSLocalizedString("common.ok", comment: " "), style: .default, handler: { _ in
           
        })

        presentAlert(title: "", subTitle: message, primaryAction: primaryAction)
        
    }
    
    /// Presents a confirmation panel with OK and Cancel buttons.
    ///
    /// - Parameters:
    ///   - webView: The WKWebView instance where the confirmation panel is triggered.
    ///   - message: The message to display in the confirmation panel.
    ///   - frame: Information about the frame that initiated the confirmation.
    ///   - completionHandler: A closure to call with the user's choice (true for OK, false for Cancel).
    public static func webView(_ webView: WKWebView,
                 runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        
        let vc = WebToNativeCore.viewController
        
        // Set the message as the UIAlertController message
        let alertController = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        
        // Add a confirmation action “OK”
        let okAction = UIAlertAction(
            title: NSLocalizedString("common.ok", comment: " "),
            style: .default,
            handler: { _ in
                // Call completionHandler confirming the choice
                completionHandler(true)
            }
        )
        alertController.addAction(okAction)
        
        // Add a cancel action “Cancel”
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("common.cancel", comment: " "),
            style: .cancel,
            handler: { _ in
                // Call completionHandler cancelling the choice
                completionHandler(false)
            }
        )
        alertController.addAction(cancelAction)
        
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = vc?.view
        }
        // Display the NSAlert
        vc?.present(alertController, animated: true, completion: nil)
    }
    
    /// Presents a text input panel with a prompt, default text, and Submit/Cancel buttons.
    ///
    /// - Parameters:
    ///   - webView: The WKWebView instance where the text input panel is triggered.
    ///   - prompt: The prompt message to display in the text input panel.
    ///   - defaultText: The default text pre-filled in the text input field.
    ///   - frame: Information about the frame that initiated the text input.
    ///   - completionHandler: A closure to call with the user's input text or nil if cancelled.
    public static func webView(_ webView: WKWebView,
                 runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        
        let vc = WebToNativeCore.viewController
        
        // Set the prompt as the UIAlertController message
        let alertController = UIAlertController(
            title: nil,
            message: prompt,
            preferredStyle: .alert
        )
        
        // Add a text field to the UIAlertController
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        
        // Add a confirmation action “Submit”
        let submitAction = UIAlertAction(
            title: NSLocalizedString("common.submit", comment: " "),
            style: .default,
            handler: { [unowned alertController] _ in
                // Call completionHandler with the user input
                if let text = alertController.textFields?.first?.text {
                    completionHandler(text)
                } else {
                    completionHandler(defaultText)
                }
            }
        )
        alertController.addAction(submitAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("common.cancel", comment: " "), style: .default, handler: { (action) in
            
            completionHandler(nil)
            
        })
        alertController.addAction(cancelAction)
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = vc?.view
        }
        // Display the NSAlert
        vc?.present(alertController, animated: true, completion: nil)
    }
}
