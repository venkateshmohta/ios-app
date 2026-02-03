import WebKit
import AppTrackingTransparency


/**
 The `WebToNativeBridge` class is a singleton that manages the registration of modules for the web-to-native bridge.

 This class provides methods to register and manage modules that can interact with native code from web views.
 */
public class WebToNativeBridge {

    /// The shared singleton instance of `WebToNativeBridge`.
    public static let shared = WebToNativeBridge()
    
    /// An array to store registered modules.
    private var modules: [AnyObject] = []
    
    /**
     Registers a module to the web-to-native bridge.

     This method initializes the provided module class and appends it to the internal modules array.

     - Parameter moduleClass: The module class to be registered.
     */
    public func registerModule(moduleClass: AnyObject) {
        print("Initializing", String(describing: moduleClass))
        modules.append(moduleClass)
    }
}
