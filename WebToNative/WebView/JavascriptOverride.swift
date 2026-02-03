import WebKit
import CoreLocation

/**
 A class responsible for handling JavaScript overrides and location services.

 This class conforms to `WKScriptMessageHandler` and `CLLocationManagerDelegate` protocols.

 */
class JavascriptOverride: NSObject, WKScriptMessageHandler, CLLocationManagerDelegate {
    
    /// The location manager instance for managing location services.
    var locationManager = CLLocationManager();
    
    /// The count of active listeners for location updates.
    var listenersCount = 0;
    
    /// The WKWebView instance to which the JavaScript overrides are applied.
    var webView: WKWebView!;
    
    /**
     Initializes the `JavascriptOverride` class.
     
     This method sets up the location manager delegate.
     */
    override init() {
        super.init();
        locationManager.delegate = self;
    }
    
    /**
     Sets the WKWebView instance for the JavaScript overrides.
     
     - Parameter webView: The WKWebView instance to which the JavaScript overrides are applied.
     */
    func setWebView(webView: WKWebView) {
        let contentController = webView.configuration.userContentController
            
            // 1. Define the names
            let handlerNames = [
                "locationListenerAdded",
                "locationListenerRemoved",
                "printListener"
            ]
            
            // 2. Remove existing handlers with these names
            // It's safe to call removeScriptMessageHandler(forName:) even if no handler
            // with that name exists.
            for name in handlerNames {
                contentController.removeScriptMessageHandler(forName: name)
                print("Removed existing handler for name: \(name)") // Optional log
            }
            
            // 3. Add the new handlers
            // 'self' must conform to WKScriptMessageHandler
            for name in handlerNames {
                contentController.add(self, name: name)
                print("Added new handler for name: \(name)") // Optional log
            }
        
        self.webView = webView;
    }
    
    // MARK: Location Services
      
    /**
     Checks if location services are enabled on the device.
     
     - Returns: A Boolean value indicating whether location services are enabled.
     */
    func locationServicesIsEnabled() -> Bool {
        return (CLLocationManager.locationServicesEnabled()) ? true : false;
    }
    
    /**
      Determines if authorization status needs to be requested.
      
      - Parameter status: The current authorization status.
      - Returns: A Boolean value indicating whether authorization status needs to be requested.
      */
    func authorizationStatusNeedRequest(status: CLAuthorizationStatus) -> Bool {
        return (status == .notDetermined) ? true : false;
    }
    
    /**
     Checks if authorization status is granted.
     
     - Parameter status: The current authorization status.
     - Returns: A Boolean value indicating whether authorization status is granted.
     */
    func authorizationStatusIsGranted(status: CLAuthorizationStatus) -> Bool {
        return (status == .authorizedAlways || status == .authorizedWhenInUse) ? true : false;
    }
    
    /**
     Checks if authorization status is denied.
     
     - Parameter status: The current authorization status.
     - Returns: A Boolean value indicating whether authorization status is denied.
     */
    func authorizationStatusIsDenied(status: CLAuthorizationStatus) -> Bool {
        return (status == .restricted || status == .denied) ? true : false;
    }
    
    /**
     Handles the scenario when location services are disabled.
     */
    func onLocationServicesIsDisabled() {
        webView.evaluateJavaScript("navigator.geolocation.helper.error(2, 'Location services disabled');");
    }
    
    /**
     Requests authorization when authorization status is needed.
     */
    func onAuthorizationStatusNeedRequest() {
        locationManager.requestWhenInUseAuthorization();
    }
    
    /**
     Handles the scenario when authorization status is granted.
     */
    func onAuthorizationStatusIsGranted() {
        locationManager.startUpdatingLocation();
    }
    
    /// Handles the scenario when authorization status is denied.
    func onAuthorizationStatusIsDenied() {
        webView.evaluateJavaScript("navigator.geolocation.helper.error(1, 'App does not have location permission');");
    }
    // MARK: Printing
    
    /**
     Prints the current web page.
     */
    func printCurrentPage() {
        let printController = UIPrintInteractionController.shared
        let printFormatter = self.webView.viewPrintFormatter()
        printController.printFormatter = printFormatter

        printController.present(animated: true, completionHandler: nil)
    }
    // MARK: WKScriptMessageHandler
     
     /**
      A method that receives messages from JavaScript.
      
      - Parameters:
        - userContentController: The user content controller invoking the method.
        - message: The message received from JavaScript.
      */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (message.name == "locationListenerAdded") {
            listenersCount += 1;
            
            if (!locationServicesIsEnabled()) {
                onLocationServicesIsDisabled();
            }
            else if (authorizationStatusIsDenied(status: CLLocationManager.authorizationStatus())) {
                onAuthorizationStatusIsDenied();
            }
            else if (authorizationStatusNeedRequest(status: CLLocationManager.authorizationStatus())) {
                onAuthorizationStatusNeedRequest();
            }
            else if (authorizationStatusIsGranted(status: CLLocationManager.authorizationStatus())) {
                onAuthorizationStatusIsGranted();
            }
        }
        else if (message.name == "locationListenerRemoved") {
            listenersCount -= 1;
            
            // no listener left in web view to wait for position
            if (listenersCount == 0) {
                locationManager.stopUpdatingLocation();
            }
        }else if (message.name == "printListener") {
            printCurrentPage();
        }
    }
    
    // MARK: CLLocationManagerDelegate
      
      /**
       Informs the delegate that the authorization status for the application changed.
       
       - Parameters:
         - manager: The location manager object reporting the event.
         - status: The new authorization status for the application.
       */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // didChangeAuthorization is also called at app startup, so this condition checks listeners
        // count before doing anything otherwise app will start location service without reason
        if (listenersCount > 0) {
            if (authorizationStatusIsDenied(status: status)) {
                onAuthorizationStatusIsDenied();
            }
            else if (authorizationStatusIsGranted(status: status)) {
                onAuthorizationStatusIsGranted();
            }
        }
    }
    
    /**
     Tells the delegate that new location data is available.
     
     - Parameters:
     - manager: The location manager object that generated the update event.
     - locations: An array of CLLocation objects containing the location data.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            webView.evaluateJavaScript("navigator.geolocation.helper.success('\(location.timestamp)', \(location.coordinate.latitude), \(location.coordinate.longitude), \(location.altitude), \(location.horizontalAccuracy), \(location.verticalAccuracy), \(location.course), \(location.speed));");
        }
    }
    
    /**
     Tells the delegate that the location manager was unable to retrieve a location.
     
     - Parameters:
     - manager: The location manager object that was unable to retrieve the location.
     - error: An error object containing the details of the failure.
     */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        webView.evaluateJavaScript("navigator.geolocation.helper.error(2, 'Failed to get position (\(error.localizedDescription))');");
    }
    
    /**
     Generates JavaScript to evaluate for location-related functionality.
     
     - Returns: JavaScript code for handling location-related operations.
     */
    func getJavaScripToEvaluate() -> String {
        let javaScripToEvaluate = """
            // management for success and error listeners and its calling
            navigator.geolocation.helper = {
                listeners: {},
                noop: function() {},
                id: function() {
                    var min = 1, max = 1000;
                    return Math.floor(Math.random() * (max - min + 1)) + min;
                },
                clear: function(isError) {
                    for (var id in this.listeners) {
                        if (isError || this.listeners[id].onetime) {
                            navigator.geolocation.clearWatch(id);
                        }
                    }
                },
                success: function(timestamp, latitude, longitude, altitude, accuracy, altitudeAccuracy, heading, speed) {
                    var position = {
                        timestamp: new Date(timestamp).getTime() || new Date().getTime(), // safari can not parse date format returned by swift e.g. 2019-12-27 15:46:59 +0000 (fallback used because we trust that safari will learn it in future because chrome knows that format)
                        coords: {
                            latitude: latitude,
                            longitude: longitude,
                            altitude: altitude,
                            accuracy: accuracy,
                            altitudeAccuracy: altitudeAccuracy,
                            heading: (heading > 0) ? heading : null,
                            speed: (speed > 0) ? speed : null
                        }
                    };
                    for (var id in this.listeners) {
                        this.listeners[id].success(position);
                    }
                    this.clear(false);
                },
                error: function(code, message) {
                    var error = {
                        PERMISSION_DENIED: 1,
                        POSITION_UNAVAILABLE: 2,
                        TIMEOUT: 3,
                        code: code,
                        message: message
                    };
                    for (var id in this.listeners) {
                        this.listeners[id].error(error);
                    }
                    this.clear(true);
                }
            };
        
            // @override getCurrentPosition()
            navigator.geolocation.getCurrentPosition = function(success, error, options) {
                var id = this.helper.id();
                this.helper.listeners[id] = { onetime: true, success: success || this.noop, error: error || this.noop };
                window.webkit.messageHandlers.locationListenerAdded.postMessage("");
            };
        
            // @override watchPosition()
            navigator.geolocation.watchPosition = function(success, error, options) {
                var id = this.helper.id();
                this.helper.listeners[id] = { onetime: false, success: success || this.noop, error: error || this.noop };
                window.webkit.messageHandlers.locationListenerAdded.postMessage("");
                return id;
            };
        
            // @override clearWatch()
            navigator.geolocation.clearWatch = function(id) {
                var idExists = (this.helper.listeners[id]) ? true : false;
                if (idExists) {
                    this.helper.listeners[id] = null;
                    delete this.helper.listeners[id];
                    window.webkit.messageHandlers.locationListenerRemoved.postMessage("");
                }
            };
        
            window.print = function() { window.webkit.messageHandlers.printListener.postMessage('print') };
        
            window.navigator.share = function (obj) {
                    return new Promise((resolve, reject) => {
                        window.webkit.messageHandlers.webToNativeInterface.postMessage({
                            action: "share",
                            url: obj.url,
                            type: obj.type,
                            text: obj.text,
                            extension: obj.extension
                        });
                        resolve();
                    });
            };
        """;
        
        return javaScripToEvaluate;
    }
}
