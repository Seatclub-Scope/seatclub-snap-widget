import UIKit
import SwiftUI

public class SeatclubWidget {
    private let reactBridge = ReactBridge()
    
    public init() {}
    
    @objc public func createViewController(title: String = "Welcome to SeatClub!") -> UIViewController {
        let rootView = reactBridge.createRootView()
        
        let viewController = UIViewController()
        viewController.view = rootView
        
        // Configure the view controller
        viewController.modalPresentationStyle = .fullScreen
        viewController.title = title
        
        return viewController
    }
    
    @objc public func createViewController(with props: [String: Any]) -> UIViewController {
        let rootView = reactBridge.createRootView()
        
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
@available(iOS 17.0, *)
public struct SeatclubWidgetView: UIViewControllerRepresentable {
    let title: String
    let customProps: [String: Any]?
    
    public init(title: String = "Welcome to SeatClub!") {
        self.title = title
        self.customProps = nil
    }
    
    public init(props: [String: Any]) {
        self.title = props["title"] as? String ?? "Welcome to SeatClub!"
        self.customProps = props
    }
    
    public func makeUIViewController(context: Context) -> UIViewController {
        let widget = SeatclubWidget()
        
        if let customProps = customProps {
            return widget.createViewController(with: customProps)
        } else {
            return widget.createViewController(title: title)
        }
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Updates handled internally
    }
}

// MARK: - Objective-C Compatibility
@objc public class SeatclubWidgetObjC: NSObject {
    @objc public static func createViewController(title: String) -> UIViewController {
        let widget = SeatclubWidget()
        return widget.createViewController(title: title)
    }
    
    @objc public static func createViewController(props: [String: Any]) -> UIViewController {
        let widget = SeatclubWidget()
        return widget.createViewController(with: props)
    }
}
