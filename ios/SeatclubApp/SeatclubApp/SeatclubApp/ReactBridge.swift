import Foundation
import UIKit
import JavaScriptCore

internal class ReactBridge {
    private var jsContext: JSContext?
    private var isReactNativeLoaded = false
    
    init() {
        print("🚀 ReactBridge initialized")
        setupJSContext()
    }
    
    private func setupJSContext() {
        jsContext = JSContext()
        
        // Basic error handling
        jsContext?.exceptionHandler = { context, exception in
            print("❌ JavaScript Error: \(exception?.toString() ?? "Unknown error")")
        }
        
        // Set up minimal environment
        setupMinimalEnvironment()
        
        // Load and execute the bundle
        guard let bundlePath = getBundlePath(),
              let jsSource = try? String(contentsOfFile: bundlePath) else {
            print("⚠️ Warning: Could not load JavaScript bundle")
            return
        }
        
        print("📱 Loading JavaScript bundle (\(jsSource.count) characters)")
        
        // Execute the bundle
        jsContext?.evaluateScript(jsSource)
        print("📱 JavaScript bundle executed")
        
        // Check what we got
        checkReactNative()
    }
    
    private func setupMinimalEnvironment() {
        guard let context = jsContext else { return }
        
        print("🔧 Setting up minimal environment...")
        
        // Global object
        context.setObject(context.globalObject, forKeyedSubscript: "global" as NSString)
        
        // Basic console
        let console = JSValue(newObjectIn: context)
        let log: @convention(block) (JSValue) -> Void = { message in
            print("📱 JS: \(message.toString())")
        }
        
        console?.setObject(log, forKeyedSubscript: "log" as NSString)
        console?.setObject(log, forKeyedSubscript: "warn" as NSString)
        console?.setObject(log, forKeyedSubscript: "error" as NSString)
        console?.setObject(log, forKeyedSubscript: "info" as NSString)
        
        context.setObject(console, forKeyedSubscript: "console" as NSString)
        
        // Simple TurboModuleRegistry that returns basic modules
        let turboModuleProxy: @convention(block) (String) -> JSValue = { moduleName in
            print("🔍 TurboModule requested: \(moduleName)")
            
            let module = JSValue(newObjectIn: context)!
            
            // Special handling for UIManager
            if moduleName == "UIManager" {
                let getConstants: @convention(block) () -> [String: Any] = {
                    return [
                        "Dimensions": [
                            "window": ["width": 375, "height": 812, "scale": 3.0],
                            "screen": ["width": 375, "height": 812, "scale": 3.0]
                        ]
                    ]
                }
                module.setObject(getConstants, forKeyedSubscript: "getConstants" as NSString)
            } else {
                // For other modules, just return empty getConstants
                let getConstants: @convention(block) () -> [String: Any] = {
                    return [:]
                }
                module.setObject(getConstants, forKeyedSubscript: "getConstants" as NSString)
            }
            
            return module
        }
        
        // Set up TurboModuleRegistry object with the proxy function
        let registry = JSValue(newObjectIn: context)
        registry?.setObject(turboModuleProxy, forKeyedSubscript: "getEnforcing" as NSString)
        registry?.setObject(turboModuleProxy, forKeyedSubscript: "get" as NSString)
        context.setObject(registry, forKeyedSubscript: "TurboModuleRegistry" as NSString)
        
        // Also set up the function directly for different calling patterns
        context.setObject(turboModuleProxy, forKeyedSubscript: "turboModuleProxy" as NSString)
        
        // Basic timing
        let setTimeout: @convention(block) (JSValue, Double) -> Void = { callback, delay in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay / 1000.0) {
                callback.call(withArguments: [])
            }
        }
        context.setObject(setTimeout, forKeyedSubscript: "setTimeout" as NSString)
        
        // Mock batched bridge with proper config
        let batchedBridge = JSValue(newObjectIn: context)
        
        let callFunctionReturnFlushedQueue: @convention(block) (String, String, JSValue) -> JSValue? = { module, method, args in
            print("🔄 Bridge call: \(module).\(method)")
            return JSValue(nullIn: context)
        }
        
        batchedBridge?.setObject(callFunctionReturnFlushedQueue, forKeyedSubscript: "callFunctionReturnFlushedQueue" as NSString)
        context.setObject(batchedBridge, forKeyedSubscript: "__fbBatchedBridge" as NSString)
        
        // CRITICAL: Set up __fbBatchedBridgeConfig
        let bridgeConfig: [String: Any] = [
            "moduleConfig": [],
            "lazyModuleNames": []
        ]
        context.setObject(bridgeConfig, forKeyedSubscript: "__fbBatchedBridgeConfig" as NSString)
        
        print("✅ Minimal environment setup complete")
    }
    
    private func checkReactNative() {
        guard let context = jsContext else { return }
        
        let checkScript = """
        (function() {
            // Check if AppRegistry is already global
            if (typeof AppRegistry !== 'undefined') {
                return true;
            }
            
            // Check if Metro require system exists
            if (typeof __r === 'function') {
                // Search modules for AppRegistry
                for (var i = 0; i < 200; i++) {
                    try {
                        var mod = __r(i);
                        
                        // Check if this module has AppRegistry
                        if (mod && mod.AppRegistry && mod.AppRegistry.registerComponent) {
                            global.AppRegistry = mod.AppRegistry;
                            
                            try {
                                __r(0);
                            } catch (e) {
                                // Could not execute index.js
                            }
                            
                            return true;
                        }
                        
                        // Check if this module has registerComponent directly
                        if (mod && mod.registerComponent) {
                            global.AppRegistry = mod;
                            
                            try {
                                __r(0);
                            } catch (e) {
                                // Could not execute index.js
                            }
                            
                            return true;
                        }
                        
                    } catch (e) {
                        // Continue searching
                    }
                }
                
                return false;
            } else {
                return false;
            }
        })()
        """
        
        let result = context.evaluateScript(checkScript)
        isReactNativeLoaded = result?.toBool() ?? false
        
        if isReactNativeLoaded {
            print("✅ React Native loaded successfully")
        } else {
            print("❌ React Native not loaded properly")
        }
    }
    
    func createRootView() -> UIView {
        if isReactNativeLoaded {
            return createReactNativeView()
        } else {
            return createErrorView()
        }
    }
    
    private func createReactNativeView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.text = "🎉 React Native Working!"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .systemGreen
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let messageLabel = UILabel()
        messageLabel.text = "Your React Native bridge is working!\nBundle loaded and AppRegistry found."
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .label
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -30),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            messageLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -20)
        ])
        
        return containerView
    }
    
    private func createErrorView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "❌ React Native Setup Issue\n\nCould not find AppRegistry.\nCheck your React Native bundle."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -20)
        ])
        
        return containerView
    }
    
    private func getBundlePath() -> String? {
        print("🔍 Looking for JavaScript bundle...")
        
        let frameworkBundle = Bundle(for: ReactBridge.self)
        let possibleNames = ["seatclub-app", "main", "index", "SeatclubApp"]
        
        for name in possibleNames {
            if let bundlePath = frameworkBundle.path(forResource: name, ofType: "jsbundle") {
                print("✅ Found bundle '\(name).jsbundle'")
                return bundlePath
            }
        }
        
        print("❌ JavaScript bundle not found")
        return nil
    }
}
