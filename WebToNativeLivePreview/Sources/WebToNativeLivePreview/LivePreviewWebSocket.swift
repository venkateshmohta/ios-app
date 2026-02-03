//
//  LivePreviewWebSocket.swift
//  WebToNative
//
//  Created by yash saini on 08/09/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//

import Foundation
import WebToNativeCore
import WebKit

/**
    This class manage Liver Preview config data using websocket
 */
//class LivePreviewWebSocket {
//    private var webSocketTask: URLSessionWebSocketTask?
//    private var url: URL?
//    private let background = DispatchQueue(label: "WebSocketQueue", qos: .background)
//    var configManager: ConfigDataManager? = nil
//    var enableToConnect = true
//    var connectLost: Bool = false
//    var isConnectWithServer = true
//    var retryAttempts: Int = 0
//    
//    // Set Websocket url
//    func initialize(socketUrl: URL, cm: ConfigDataManager){
//        url = socketUrl
//        configManager = cm
//    }
//    
//    // Connect to websocket server
//    func connect(){
//        enableToConnect = true
//        isConnectWithServer = true
//        background.async {
//            
//            if let url = self.url {
//                let session = URLSession(configuration: .default)
//                self.webSocketTask = session.webSocketTask(with: url)
//                self.webSocketTask?.resume()
//                self.receivePreviewConfigData()
//            }
//            else {
//                print("socket123: url is nil")
//            }
//        }
//        sendPing()
//    }
//    
//    
//    private func sendPing(){
//        if isConnectWithServer {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 7 * 60) {
//                self.webSocketTask?.sendPing { error in
//                    if let error = error {
//                        print("socket123: Error sending ping: \(error)")
//                    }
//                    else {
//                        print("socket123: Ping sent successfully")
//                        self.sendPing()
//                    }
//                }
//            }
//        }
//    }
//    
//    
//    // Disconnect from server
//    func disconnect(calledByModule: Bool = false){
//        enableToConnect = !calledByModule
//        isConnectWithServer = false
//        background.async { [weak self] in
//            self?.webSocketTask?.cancel(with: .goingAway, reason: nil)
//        }
//    }
//    
//    // Reconnect to websocket server
//    private func reconnect() {
//        print("socket123: Attempting to reconnect...")
//        disconnect()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.connect()
//        }
//    }
//    
//    // Receive Live Preview Configuration Data from websocket server
//    private func receivePreviewConfigData() {
//        webSocketTask?.receive { [weak self] result in
//
//            guard let self = self else { return }
//
//            switch result {
//                
//            case .failure(let error):
//                connectLost = true
//                retryAttempts += 1
//                if retryAttempts == 5 {
//                    NotificationCenter.default.post(name: .livePreviewDataUpdated, object: nil, userInfo: ["isSocketConnected": false])
//                }
//                print("socket123: error: \(error)")
//                // retry or handle disconnection here
//                if enableToConnect {
//                    self.reconnect()
//                }
//
//            case .success(let message):
//                if connectLost {
//                    NotificationCenter.default.post(name: .livePreviewDataUpdated, object: nil, userInfo: ["isSocketConnected": true])
//                    // After the socket connects, the server resets retryAttempts and connectLost.
//                    connectLost = false
//                    retryAttempts = 0
//                }
//                
//                
//                switch message {
//                case .string(let text):
//                    print("socket123:  Received text message: \(text)")
//                    if let text = text.data(using: .utf8){
//                         configManager?.updateLivePreviewData(config: text, isSocketCalled: true)
//                    }
//                case .data(let data):
//                    configManager?.updateLivePreviewData(config: data, isSocketCalled: true)
//
//                @unknown default:
//                    print("socket123: Received unknown message type")
//                }
//
//                // Continue receiving messages
//                self.receivePreviewConfigData()
//            }
//        }
//    }
//    
//}

final class NewLivePreviewSocket {
    private var webSocketURL = URL(string: "wss://echo.websocket.org")!
    private var options = NWProtocolWebSocket.Options()
    private let background = DispatchQueue(label: "WebSocketQueue", qos: .background)
    private var configManager: ConfigDataManager?
    private var parameters: NWParameters
    private var enableToConnect = true
    private var connection: NWConnection?
    private var pingTimer: DispatchSourceTimer?
    private var reconnectWorkItem: DispatchWorkItem?

    // state flags (kept from your original)
    var connectLost: Bool = false
    var isConnectWithServer = true
    var retryAttempts: Int = 0

    // ping interval: 7 minutes
    private let pingInterval: TimeInterval = 7 * 60

    init() {
        parameters = NWParameters(tls: .init())
        options.autoReplyPing = true
        parameters.defaultProtocolStack.applicationProtocols.insert(options, at: 0)
    }

    // --- keep your original function name
    func initialize(socketURL: URL, cm: ConfigDataManager) {
        webSocketURL = socketURL
        configManager = cm
    }

    // --- keep your original function name
    func connect() {
        if webSocketURL.scheme != "ws" && webSocketURL.scheme != "wss" { return }

        enableToConnect = true

        // Cancel any scheduled reconnect to avoid duplicate connects
        reconnectWorkItem?.cancel()
        reconnectWorkItem = nil

        // If there's a live connection, don't create another
        if connection != nil {
            log("connect() called but connection already exists")
            return
        }

        connection = NWConnection(to: .url(webSocketURL), using: parameters)

        connection?.stateUpdateHandler = { [weak self] state in
            self?.stateUpdateHandler(state: state)
        }
        connection?.start(queue: background)
    }

    // --- keep your original function name (exact signature)
    private func stateUpdateHandler(state: NWConnection.State) {
        switch state {
        case .setup:
            log("setup")
        case .preparing:
            log("preparing")
        case .ready:
            log("✅ ready")
            // begin receiving and start ping timer
            if connectLost {
                NotificationCenter.default.post(name: .livePreviewDataUpdated, object: nil, userInfo: ["isSocketConnected": true])
                // After the socket connects, the server resets retryAttempts and connectLost.
                connectLost = false
                retryAttempts = 0
            }
            receiveMessage()
            startPingTimerIfNeeded()
        case .waiting(let error):
            log("⏸ waiting - \(error.localizedDescription)")
        case .failed(let error):
            log("❌ failed - \(error.localizedDescription)")
            connectLost = true
            retryAttempts += 1
            if retryAttempts == 5 {
                NotificationCenter.default.post(name: .livePreviewDataUpdated, object: nil, userInfo: ["isSocketConnected": false])
            }
            print("socket123: error: \(error)")
            stopPingTimer()
            cleanupConnection()
            if enableToConnect { scheduleReconnect() }
        case .cancelled:
            log("🛑 cancelled")
            stopPingTimer()
            cleanupConnection()
            if enableToConnect { scheduleReconnect() }
        @unknown default:
            log("unknown state")
        }
    }

    // --- keep your original function name
    private func receiveMessage() {
        connection?.receiveMessage { [weak self] data, context, isComplete, error in
            guard let self = self else { return }

            if let error = error {
                self.log("❌ Receive error: \(error)")
                // on receive errors, reconnect
                self.stopPingTimer()
                self.cleanupConnection()
                if self.enableToConnect { self.scheduleReconnect() }
                return
            }

            if let data, let context {
                self.handleReceivedMessage(data: data, context: context)
            }

            // continue listening
            self.receiveMessage()
        }
    }

    // --- keep your original function name (exact signature)
    private func handleReceivedMessage(data: Data, context: NWConnection.ContentContext) {
        guard !data.isEmpty,
              let metadata = context.protocolMetadata.first as? NWProtocolWebSocket.Metadata else { return }

        switch metadata.opcode {
        case .text:
            let message = String(data: data, encoding: .utf8) ?? "(binary)"
            log("📩 Received text: \(message)")
            configManager?.updateLivePreviewData(config: data, isSocketCalled: true)
        case .binary:
            log("📦 Binary data (\(data.count) bytes)")
        case .pong:
            log("↩️ Received PONG (payload size: \(data.count))")
        default:
            log("🛈 Received opcode: \(metadata.opcode)")
        }
    }

    // --- keep your original function name
    func sendText(_ text: String) {
        guard let connection = connection else { return }
        let data = text.data(using: .utf8) ?? Data()
        let metadata = NWProtocolWebSocket.Metadata(opcode: .text)
        let context = NWConnection.ContentContext(identifier: "text", metadata: [metadata])

        connection.send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed { [weak self] error in
            if let e = error {
                self?.log("sendText error: \(e.localizedDescription) — as NSError: \((e as NSError).code)")
                if (e as NSError).code == Int(ECANCELED) {
                    self?.log("sendText failed with ECANCELED — reconnecting")
                    self?.cleanupConnection()
                    if self?.enableToConnect == true { self?.scheduleReconnect() }
                }
            } else {
                self?.log("text sent")
            }
        })
    }

    // --- keep your original function name
    func disconnect(calledByModule: Bool = false) {
        log("disconnect called")
        enableToConnect = !calledByModule
        stopPingTimer()
        connection?.cancel()
        cleanupConnection()
    }

    // --- keep your original function name
    private func reconnect() {
        log("attempting reconnect...")
        // use scheduleReconnect to centralize logic and avoid races
        disconnect()
        scheduleReconnect()
    }

    // -----------------------
    // Helpers (internal, added)
    // -----------------------

    private func cleanupConnection() {
        connection?.stateUpdateHandler = nil
        connection = nil
    }

    private func scheduleReconnect(after delay: TimeInterval = 2.0) {
        reconnectWorkItem?.cancel()

        let item = DispatchWorkItem { [weak self] in
            guard let self = self, self.enableToConnect else { return }
            self.connect()
        }
        reconnectWorkItem = item
        background.asyncAfter(deadline: .now() + delay, execute: item)
        log("scheduling reconnect in \(delay)s")
    }

    private func startPingTimerIfNeeded() {
        guard pingTimer == nil else { return }

        let timer = DispatchSource.makeTimerSource(queue: background)
        timer.schedule(deadline: .now() + pingInterval, repeating: pingInterval, leeway: .seconds(5))
        timer.setEventHandler { [weak self] in
            self?.sendWebSocketPing()
        }
        timer.resume()
        pingTimer = timer
        log("ping timer started (every \(Int(pingInterval))s)")
    }

    private func stopPingTimer() {
        if let timer = pingTimer {
            timer.setEventHandler {}
            timer.cancel()
            pingTimer = nil
            log("ping timer stopped")
        }
    }

    private func sendWebSocketPing() {
        guard let conn = connection else {
            log("No connection - cannot send ping")
            return
        }

        let stateSnapshot = conn.state
        let pathSatisfied = conn.currentPath?.status == .satisfied

        guard case .ready = stateSnapshot, pathSatisfied else {
            log("Not ready to ping: state=\(stateSnapshot) path=\(String(describing: conn.currentPath?.status))")

            switch stateSnapshot {
            case .failed, .cancelled:
                cleanupConnection()
                if enableToConnect { scheduleReconnect() }
            default:
                break
            }

            return
        }

        // Proper WebSocket ping (empty payload)
        let pingPayload = Data()
        let metadata = NWProtocolWebSocket.Metadata(opcode: .ping)
        let context = NWConnection.ContentContext(identifier: "ping", metadata: [metadata])

        conn.send(content: pingPayload, contentContext: context, isComplete: true, completion: .contentProcessed { [weak self] error in
            if let error = error {
                self?.log("ping send error: \(error.localizedDescription) — code: \((error as NSError).code)")
                // handle ECANCELED or IO errors: cleanup and reconnect
                if (error as NSError).code == Int(ECANCELED) || (error as NSError).code == 5 {
                    self?.log("ping failed with cancel/io error — cleaning up and reconnecting")
                    self?.stopPingTimer()
                    self?.cleanupConnection()
                    if self?.enableToConnect == true { self?.scheduleReconnect() }
                }
            } else {
                self?.log("ping sent")
            }
        })
    }

    private func log(_ msg: String) {
        NSLog("[NewLivePreviewSocket] \(msg)")
    }
}
