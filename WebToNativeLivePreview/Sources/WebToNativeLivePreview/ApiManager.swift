//
//  ApiManager.swift
//  WebToNativeLivePreview
//
//  Created by yash saini on 13/10/25.
//

class ApiManager {
    let getDataApi = "https://www.webtonative.com/api/v1/get-ios-data-for-preview"
    let generateTokenApi = "https://www.webtonative.com/api/v1/generate-preview-token"
    
    func callApi(api: String, requestId: String, previewId: String, userId: String, onSuccess: @escaping (Data) -> Void, onFailure: @escaping (String) -> Void) {
        var components = URLComponents(string: api)!
        // Add query parameters
        components.queryItems = [
            URLQueryItem(name: "requestId", value: requestId),
            URLQueryItem(name: "previewId", value: previewId),
            URLQueryItem(name: "userId", value: userId),
            URLQueryItem(name: "platform", value: "ios"),
            URLQueryItem(name: "deviceType", value: "IOS")
        ]
        // Create the URL
        if let url = components.url {
            
            // Create the URLRequest
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // Create the data task
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    onFailure(error.localizedDescription)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    onFailure("SERVER_ERROR")
                    return
                }
                
                if let data = data {
                    do {
                        // Parse JSON
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        print("Response JSON: \(json)")
                        onSuccess(data)
                    } catch {
                        onFailure(error.localizedDescription)
                    }
                }
            }
            
            task.resume()
        }
        else {
            onFailure("INVALID_URL")
        }
    }
}
