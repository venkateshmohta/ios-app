//
//  CustomVideoPlayer.swift
//  WebToNative
//
//  Created by Akash Kamati on 13/06/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import SwiftUI
import AVKit

/**
 SwiftUI representation of a custom video player using `AVPlayer`.

 This struct wraps an `AVPlayerViewController` to display and control video playback with customizations.
 */
struct CustomVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer
    let bgColorCode:String

    /**
     Creates and configures an `AVPlayerViewController` with the provided `AVPlayer` instance and background color.

     - Parameter context: The context provided by SwiftUI for creating the view controller.
     - Returns: An `AVPlayerViewController` configured with the provided `AVPlayer` and background color.
     */
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let avPlayerController = AVPlayerViewController()
        avPlayerController.player = player
        avPlayerController.showsPlaybackControls = false
        avPlayerController.view.backgroundColor = UIColor(hexString: bgColorCode)
        avPlayerController.updatesNowPlayingInfoCenter = false
        avPlayerController.restoresFocusAfterTransition = true
        player.isMuted = false
        player.play()
        return avPlayerController
    }
    
    /**
     Creates a coordinator instance to manage events and notifications for the video player.
     
     - Returns: A `Coordinator` instance initialized with this `CustomVideoPlayer`.
     */
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    /**
     Coordinator class that manages events and notifications for the video player.
     */
    class Coordinator: NSObject {
        var parent: CustomVideoPlayer
        
        /**
         Initializes the coordinator with the parent `CustomVideoPlayer`.
         
         - Parameter parent: The `CustomVideoPlayer` instance that owns this coordinator.
         */
        init(parent: CustomVideoPlayer) {
            self.parent = parent
            super.init()
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: .AVPlayerItemDidPlayToEndTime, object: parent.player.currentItem)
        }
        
        /**
         Handles the end of video playback by seeking to the beginning and restarting playback.
         
         - Parameter notification: The notification object that triggers this method.
         */
        @objc func playerItemDidReachEnd(_ notification: Notification) {
            // Handle the end of the video playback
            parent.player.seek(to: .zero)
            parent.player.play()
        }
        /**
         Deinitializes the coordinator and removes any observers.
         */
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    /**
     Updates the `AVPlayerViewController` if necessary (not used in this implementation).
     
     - Parameters:
       - uiViewController: The `AVPlayerViewController` to update.
       - context: The context provided by SwiftUI for updating the view controller.
     */
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // No need to update anything here for now
    }
}
