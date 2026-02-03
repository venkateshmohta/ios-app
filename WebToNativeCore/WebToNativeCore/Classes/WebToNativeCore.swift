import WebKit
import CoreLocation

///  A subclass of `WKWebView` designed to display a web view in full screen without considering safe area insets.
class FullScreenWKWebView: WKWebView {
    override var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

/// Core class responsible for handling communication with the web view in the WebToNative application.
public class WebToNativeCore{

    /// The shared instance of `WebToNativeCore`.
    public static let shared = WebToNativeCore()
    /// The shared instance of websiteLink
    public static var openUrl: String? = nil
    // store live preview url
    public static var storeLivePreviewUrl: String? = nil
    /// The shared main web view used in the application.
    /// o
    public static var objserverAvailable = false
    public static var webView: WKWebView!
    /// the shared popwebview used in the application
    public static var popWebView: WKWebView?
    /// The shared view controller that contains the web view.
    public static var viewController: UIViewController!
    /// The shared instance of device token (APNs token)
    public static var deviceToken: Data? = nil
    /// The shared instance of notification response
    public static var unNotificationResponse: UNNotificationResponse? = nil
    /// The shared instance of launch options
    public static var launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    /// The shared instance of bannerAdView
    public static var bannerAdView: UIView? = nil
    /// The  shared instance of UIApplication
    public static var application: UIApplication? = nil
    /// flag for check fun first call when app started
    public static var funFirstCallWhenAppStarted: Bool = true
    /// flag for checking HTTP authentication request
    public static var httpAuthenticationComplete: Bool = true
    /// show open app ad flag
    public static var showAppOpenAd = true
    /// Key to auto-dismiss JS Alert when showCustomAlert is enabled based on regex matching
    public static var autoDismiss = false
    /// key to check if app is redirected to settings for permission handling
    public static var openSettingCallback = ""
    /// key to disable screenshot for the page
    public static var disableScreenshot = false
    /// key to check if app is launched for the first time
    public static var isOpenedFirstTime = true
    /// Shared location manager for Beacon initialised in App Delegate
    public static var locationManager: CLLocationManager? = nil
    /// key for visibility of live preview
    public static var isLivePreviewVisible: Bool = false
    /// Store App webview
    public static var storeAppWebView: WKWebView? = nil
    /// Store Preview screen webview
    public static var storePreviewWebView: WKWebView? = nil
    /// Store default Uesr Agent
    public static var defaultUserAgent: String? = nil
    /// Store Last Screen
    public static var lastScreen: String? = nil
    /// Store Network Connection
    public static var isNetworkConnected : Bool? = false

    /**
      Returns the web view associated with the provided view controller and configuration.

      - Parameters:
         - viewController: The view controller where the web view will be displayed.
         - configuration: The configuration for the web view.
      - Returns: The web view instance.
      */
    public static func getWebView(viewController:UIViewController, configuration: WKWebViewConfiguration) -> WKWebView{
        WebToNativeCore.viewController = viewController
        let view = viewController.view as UIView
        if(WebToNativeCore.webView == nil){
            let webView = FullScreenWKWebView(frame: view.bounds, configuration: configuration)
            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            WebToNativeCore.webView = webView
            webView.scrollView.showsVerticalScrollIndicator = false
            webView.scrollView.showsHorizontalScrollIndicator = false
        }
        return WebToNativeCore.webView;
        
    }
    
    /**
       Returns the main web view used in the application.

       - Returns: The main web view instance.
       */
    public static func getMainWebView() -> WKWebView{
        return WebToNativeCore.webView;
    }
    
    /**
     Converts a JSON object to a string.

     - Parameters:
        - json: The JSON object to be converted.
        - prettyPrinted: A boolean indicating whether the JSON output should be formatted for readability.
     - Returns: The string representation of the JSON object.
     */
    public static func stringify(json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
          options = JSONSerialization.WritingOptions.prettyPrinted
        }

        do {
          let data = try JSONSerialization.data(withJSONObject: json, options: options)
          if let string = String(data: data, encoding: String.Encoding.utf8) {
              return string.escaped
          }
        } catch {
          print(error)
        }

        return ""
    }
    
    /**
      Sends data to the web view for processing.

      - Parameters:
         - data: The data to be sent to the web view.
      */
    public static func sendDataToWebView(data: [String : Any]){
        let message = WebToNativeCore.stringify(json: data,prettyPrinted:false);
        let javaScriptString = "iosCBHook(\""+message+"\");"
        webView.evaluateJavaScript(javaScriptString, completionHandler: nil)
    }
    
    /**
     Notifies that a URL has been opened by posting a notification with the URL information.

     - Parameter openUrl: The URL that was opened.
     */
    public static func notifyOpenUrl(openUrl:String){
        WebToNativeCore.openUrl = openUrl
        NotificationCenter.default.post(name: .openUrl, object: nil, userInfo: ["openUrl": openUrl])
    }
    
    /// publishes banner ad display event
    public static func notifyDisplayBannerAd(){
        NotificationCenter.default.post(name: .displayBannerAd, object: nil)
    }
    
    /// publishes banner ad dismiss btn visibility
    public static func notifyShowBannerDismissBtn(){
        NotificationCenter.default.post(name: .showBannerDismissBtn, object: nil)
    }
    
    /// Publishes webviewNavigationEvent
    public static func notifyWebviewNavigation(url:String){
        NotificationCenter.default.post(name: .onWebViewNavigation, object: nil,
        userInfo: ["action": "addCalenderEvents","url":url])
    }
    
    /**
     Notifies that a JavaScript interface call has occurred by posting a notification with the provided data.

     - Parameter data: The data associated with the JavaScript interface call.
     */
    public static func notifyJSInterfaceCall(data:[String:AnyObject]){
        NotificationCenter.default.post(name: .webToNativeInterface, object: nil, userInfo: data)
    }
    
    /**
     Notifies that an application delegate event has occurred by posting a notification with the event information.

     - Parameter event: The application delegate event that occurred.
     */
    public static func notifyApplicationDelegates(event:ApplicationDelegatesEvent){
        let eventValue:String = event.rawValue
        NotificationCenter.default.post(name: .applicationDelegates, object: nil, userInfo: ["event": eventValue])
    }
    
    /**
     Enum representing various application delegate events.
     */
    public enum ApplicationDelegatesEvent: String {
        /// Event for when the user notification center is called.
        case userNotificationCenter = "userNotificationCenter"
        
        /// Event for when the application becomes active.
        case applicationDidBecomeActive = "applicationDidBecomeActive"
        
        /// Event for when the application finishes launching with options.
        case applicationDidFinishLaunchingWithOptions = "applicationDidFinishLaunchingWithOptions"
        
        /// Event for when the application fails to register for remote notifications with an error.
        case applicationDidFailToRegisterForRemoteNotificationsWithError = "applicationDidFailToRegisterForRemoteNotificationsWithError"
        
        /// Event for when the application registers for remote notifications with a device token.
        case applicationDidRegisterForRemoteNotificationsWithDeviceToken = "applicationDidRegisterForRemoteNotificationsWithDeviceToken"
        /// Event for when the application come to foreground from recent app section
        case didBecomeActiveNotification = "didBecomeActiveNotification"
        
        /// Event For When Main Screen is Visible
        case mainScreenAvailable = "mainScreenAvailable"
        case webviewCrossed90 = "webviewCrossed90"
    }
}
