import Foundation
import UIKit
import JavaScriptCore

internal class ReactBridge {
    private var jsContext: JSContext?
    
    init() {
        setupJSContext()
    }
    
    private func setupJSContext() {
        jsContext = JSContext()
        
        // Load the JavaScript bundle
        guard let bundlePath = getBundlePath(),
              let jsSource = try? String(contentsOfFile: bundlePath) else {
            print("⚠️ Warning: Could not load JavaScript bundle")
            return
        }
        
        // Set up basic React Native polyfills
        setupPolyfills()
        
        // Execute the bundle
        jsContext?.evaluateScript(jsSource)
    }
    
    private func setupPolyfills() {
        guard let context = jsContext else { return }
        
        // Basic console implementation
        let consoleLog: @convention(block) (String) -> Void = { message in
            print("📱 JS: \(message)")
        }
        context.setObject(consoleLog, forKeyedSubscript: "console" as NSString)
        
        // Basic setTimeout/setInterval (simplified)
        let setTimeout: @convention(block) (JSValue, Double) -> Void = { callback, delay in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay / 1000.0) {
                callback.call(withArguments: [])
            }
        }
        context.setObject(setTimeout, forKeyedSubscript: "setTimeout" as NSString)
    }
    
    func createRootView(moduleName: String, props: [String: Any]?) -> UIView {
        // For now, return a simple UIView with our React content
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "SeatClub App\n(React Native bridge ready)"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitle = UILabel()
        subtitle.text = "Framework loaded successfully!"
        subtitle.textAlignment = .center
        subtitle.textColor = .systemBlue
        subtitle.font = UIFont.systemFont(ofSize: 14)
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(label)
        containerView.addSubview(subtitle)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -20),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -20),
            
            subtitle.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            subtitle.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            subtitle.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 20),
            subtitle.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -20)
        ])
        
        return containerView
    }
    
    private func getBundlePath() -> String? {
        // Try to find the bundle in the framework
        let frameworkBundle = Bundle(for: ReactBridge.self)
        
        if let bundlePath = frameworkBundle.path(forResource: "seatclub-app", ofType: "jsbundle") {
            return bundlePath
        }
        
        // Fallback: try main bundle
        if let bundlePath = Bundle.main.path(forResource: "seatclub-app", ofType: "jsbundle") {
            return bundlePath
        }
        
        return nil
    }
}
