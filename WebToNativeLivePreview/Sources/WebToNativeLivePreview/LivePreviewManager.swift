//
//  LivePreviewManager.swift
//  WebToNativeLivePreview
//
//  Created by yash saini on 13/10/25.
//


// Manage Live Preview
class LivePreviewManager {
    private var configDataManager: ConfigDataManager?
    private let livePreviewWebSocket: NewLivePreviewSocket
    private let screenManager: ScreenManager
   
    init(livePreviewWebSocket: NewLivePreviewSocket) {
        do {
            try self.configDataManager = ConfigDataManager()
        }catch {
            print("Error: \(error)")
        }
        self.livePreviewWebSocket = livePreviewWebSocket
        self.screenManager = ScreenManager()
    }
    
    
    func initializeLivePreview(data: [String: AnyObject], previewRefresh: Bool = false) {
        /// Set Initial Preview Config Data
        configDataManager?.initializeLivePreviewData(data: data, onSuccess: {
            /// Show Live Preview screen
            ScreenManager().showLivePreviewScreen()
            ///Retrieve socket URL and connect with the server
            self.retrieveSocketUrl(data: data, previewRefresh: previewRefresh)
            
        },
        onFailure: { error in
            print("Error: \(error)")
        })
        
    }
    
    /// Call generate token api and get socket url & connect with server
    private func retrieveSocketUrl(data: [String: AnyObject], previewRefresh: Bool) {
        if let requestId = data["requestId"] as? String, let previewId = data["previewId"] as? String, let userId = data["userId"] as? String{
            //retrieve socket url
            ApiManager().callApi(api: ApiManager().generateTokenApi, requestId: requestId, previewId: previewId, userId: userId, onSuccess: { socketData in
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: socketData, options: []) as? [String: Any],
                        let socketUrl = jsonObject["url"] as? String{
                        print("Api2 Data: \(socketUrl)")

                        if !previewRefresh{
                            // Connect with server
                            self.connectToServer(urlString: socketUrl)
                        }
                        
                    }
                }catch {
                    print("Error: \(error)")
                }
                
            }, onFailure: { error in
                print("Error: \(error)")
            })
            
        }
    }
    
    /// Connect socket with server
    private func connectToServer(urlString: String) {
        if let url = URL(string: urlString){
            if configDataManager != nil {
                // set socket url
                livePreviewWebSocket
                    .initialize(socketURL: url, cm: configDataManager!)
                // connect
                livePreviewWebSocket.connect()
            }
        }
        
    }
    
}
