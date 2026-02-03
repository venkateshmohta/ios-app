import Foundation


/**
 Utility class for making HTTP POST requests to a specified URL with JSON data.
 */
public class WebToNativeApiController {
        
    /**
     Sends a POST request to the specified URL with JSON data.
     
     - Parameters:
        - url: The URL to which the request is sent.
        - json: The JSON data to be sent in the request body.
        - successHandler: A closure to be executed upon successful completion of the request. It takes the response data as a parameter.
        - failureHandler: A closure to be executed if the request fails. It takes the error as a parameter.
     */
    public static func post(url: String, json : [String: Any], successHandler: @escaping (Any) -> (), failureHandler: @escaping (Error) -> ()) {
        let Url = String(format: url)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    successHandler(json)
                } catch {
                    failureHandler(error)
                }
            }
        }.resume()
    }
}
