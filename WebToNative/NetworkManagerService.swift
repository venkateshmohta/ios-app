//
//  NetworkManagerService.swift
//  WebToNative
//
//  Created by Akash Kamati on 24/05/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import Foundation
import Network
import WebToNativeCore

/**
 A service class responsible for monitoring network connectivity status.

 The `NetworkManagerService` class uses `NWPathMonitor` to monitor changes in the network status. It updates an observable property `isConnected` to reflect the current network connectivity status, which can be observed by SwiftUI views or other components.

 - Note: This class conforms to `ObservableObject` to allow SwiftUI views to react to changes in the network status.
 */
class NetworkManagerService: ObservableObject {
    /// The network path monitor instance used to track network status.
    private let networkManagerService = NWPathMonitor()
    /// The dispatch queue used to run the network path monitor.
    private let workerQueue = DispatchQueue(label: "Monitor")
    /// A boolean property indicating whether the device is connected to the network.
    var isConnected = false

    /**
       Initializes the `NetworkManagerService` and starts monitoring the network status.
       
       The network status updates are handled on a background queue, and changes to the `isConnected` property are propagated to the main thread for any UI updates.
       */
    init() {
        networkManagerService.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            WebToNativeCore.isNetworkConnected = self.isConnected
            Task {
                await MainActor.run {
                    self.objectWillChange.send()
                }
            }
        }
        networkManagerService.start(queue: workerQueue)
    }
}
