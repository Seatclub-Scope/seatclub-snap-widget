import UIKit
import SwiftUI

public class SeatclubWidget {
    private let reactBridge = ReactBridge()
    
    public init() {}
    
    @objc public func createViewController(theme: String = "light", title: String = "Welcome to SeatClub!") -> UIViewController {
        let props = [
            "theme": theme,
            "title": title
        ]
        
        let rootView = reactBridge.createRootView(moduleName: "SeatclubApp", props: props)
        
        let viewController = UIViewController()
        viewController.view = rootView
        
        // Configure the view controller
        viewController.modalPresentationStyle = .fullScreen
        viewController.title = title
        
        return viewController
    }
    
    @objc public func createViewController(with props: [String: Any]) -> UIViewController {
        let rootView = reactBridge.createRootView(moduleName: "SeatclubApp", props: props)
        
        let viewController = UIViewController()
        viewController.view = rootView
        viewController.modalPresentationStyle = .fullScreen
        
        if let title = props["title"] as? String {
            viewController.title = title
        }
        
        return viewController
    }
}

// MARK: - SwiftUI Support
@available(iOS 13.0, *)
public struct SeatclubWidgetView: UIViewControllerRepresentable {
    let theme: String
    let title: String
    let customProps: [String: Any]?
    
    public init(theme: String = "light", title: String = "Welcome to SeatClub!") {
        self.theme = theme
        self.title = title
        self.customProps = nil
    }
    
    public init(props: [String: Any]) {
        self.theme = props["theme"] as? String ?? "light"
        self.title = props["title"] as? String ?? "Welcome to SeatClub!"
        self.customProps = props
    }
    
    public func makeUIViewController(context: Context) -> UIViewController {
        let widget = SeatclubWidget()
        
        if let customProps = customProps {
            return widget.createViewController(with: customProps)
        } else {
            return widget.createViewController(theme: theme, title: title)
        }
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Updates handled internally
    }
}

// MARK: - Objective-C Compatibility
@objc public class SeatclubWidgetObjC: NSObject {
    @objc public static func createViewController(theme: String, title: String) -> UIViewController {
        let widget = SeatclubWidget()
        return widget.createViewController(theme: theme, title: title)
    }
    
    @objc public static func createViewController(props: [String: Any]) -> UIViewController {
        let widget = SeatclubWidget()
        return widget.createViewController(with: props)
    }
}