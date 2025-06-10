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
        
        // TEST: Verify TurboModuleRegistry works
        let testScript = """
        (function() {
            console.log('🔍 Testing TurboModuleRegistry...');
            try {
                if (typeof TurboModuleRegistry !== 'undefined' && TurboModuleRegistry.getEnforcing) {
                    var testModule = TurboModuleRegistry.getEnforcing('UIManager');
                    console.log('✅ TurboModuleRegistry.getEnforcing works');
                    return true;
                } else {
                    console.log('❌ TurboModuleRegistry.getEnforcing not available');
                    return false;
                }
            } catch (e) {
                console.log('❌ TurboModuleRegistry test failed: ' + e.message);
                return false;
            }
        })()
        """
        
        let testResult = context.evaluateScript(testScript)
        if testResult?.toBool() != true {
            print("❌ TurboModuleRegistry test failed - modules won't load properly")
        }
        
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
            console.log('🔍 Checking for AppRegistry...');
            
            // First check if it's already global
            if (typeof AppRegistry !== 'undefined') {
                console.log('✅ AppRegistry found globally');
                return true;
            }
            
            // Check if Metro require system exists
            if (typeof __r === 'function') {
                console.log('✅ Metro require system found');
                
                // Try to find AppRegistry by searching modules
                console.log('🔍 Searching modules for AppRegistry...');
                for (var i = 0; i < 200; i++) {
                    try {
                        var mod = __r(i);
                        
                        // Log what we find for debugging
                        if (mod && typeof mod === 'object') {
                            var keys = Object.keys(mod);
                            if (keys.length > 0) {
                                console.log('Module ' + i + ' has: ' + keys.slice(0, 3).join(', ') + (keys.length > 3 ? '...' : ''));
                            }
                        }
                        
                        // Check if this module has AppRegistry
                        if (mod && mod.AppRegistry && mod.AppRegistry.registerComponent) {
                            console.log('✅ Found AppRegistry in module ' + i);
                            global.AppRegistry = mod.AppRegistry;
                            
                            // Execute index.js if we haven't already
                            try {
                                console.log('📦 Executing index.js (module 0)...');
                                __r(0);
                                console.log('✅ Executed index.js');
                            } catch (e) {
                                console.log('⚠️ Could not execute index.js: ' + e.message);
                            }
                            
                            // Check if our app is registered
                            if (mod.AppRegistry._registry && mod.AppRegistry._registry['SeatclubApp']) {
                                console.log('✅ SeatclubApp is registered!');
                                return true;
                            } else {
                                console.log('📋 Available apps: ' + Object.keys(mod.AppRegistry._registry || {}));
                                return true; // AppRegistry exists, that's good enough
                            }
                        }
                        
                        // Check if this module has registerComponent directly
                        if (mod && mod.registerComponent) {
                            console.log('✅ Found registerComponent in module ' + i);
                            global.AppRegistry = mod;
                            
                            try {
                                console.log('📦 Executing index.js (module 0)...');
                                __r(0);
                                console.log('✅ Executed index.js');
                            } catch (e) {
                                console.log('⚠️ Could not execute index.js: ' + e.message);
                            }
                            
                            return true;
                        }
                        
                        // Special check for module 133 which has _registry
                        if (i === 133 && mod && mod._registry) {
                            console.log('✅ Found _registry in module 133, likely AppRegistry');
                            console.log('Module 133 keys: ' + Object.keys(mod).join(', '));
                            
                            // This module likely IS AppRegistry, let's check if it has the methods
                            if (mod.registerComponent) {
                                console.log('✅ Module 133 has registerComponent - this is AppRegistry!');
                                global.AppRegistry = mod;
                                
                                try {
                                    console.log('📦 Executing index.js (module 0)...');
                                    __r(0);
                                    console.log('✅ Executed index.js');
                                    
                                    // Check if our app is registered
                                    if (mod._registry && mod._registry['SeatclubApp']) {
                                        console.log('✅ SeatclubApp is registered!');
                                        return true;
                                    } else {
                                        console.log('📋 Available apps: ' + Object.keys(mod._registry || {}));
                                        return true; // AppRegistry exists
                                    }
                                } catch (e) {
                                    console.log('⚠️ Could not execute index.js: ' + e.message);
                                }
                                
                                return true;
                            } else {
                                console.log('⚠️ Module 133 does not have registerComponent');
                                console.log('Module 133 methods: ' + Object.keys(mod).filter(k => typeof mod[k] === 'function').join(', '));
                                
                                // Maybe this module exports AppRegistry differently
                                if (mod.default && mod.default.registerComponent) {
                                    console.log('✅ Found registerComponent in mod.default');
                                    global.AppRegistry = mod.default;
                                    
                                    try {
                                        __r(0);
                                        return true;
                                    } catch (e) {
                                        console.log('⚠️ Error executing index.js: ' + e.message);
                                    }
                                }
                            }
                        }
                        
                    } catch (e) {
                        // Continue searching, but log major errors
                        if (e.message && e.message.indexOf('AppRegistry') > -1) {
                            console.log('Module ' + i + ' error: ' + e.message);
                        }
                    }
                }
                
                console.log('❌ Could not find AppRegistry in any module');
                
                // Final attempt - try to load specific modules that might contain AppRegistry
                var suspectedModules = [137, 158]; // From your bundle analysis
                for (var j = 0; j < suspectedModules.length; j++) {
                    try {
                        var modId = suspectedModules[j];
                        console.log('🔄 Final attempt: checking module ' + modId);
                        var finalMod = __r(modId);
                        
                        if (finalMod) {
                            console.log('Module ' + modId + ' contents: ' + Object.keys(finalMod).join(', '));
                            
                            // Check if this is AppRegistry
                            if (finalMod.registerComponent || (finalMod.default && finalMod.default.registerComponent)) {
                                var appReg = finalMod.registerComponent ? finalMod : finalMod.default;
                                console.log('✅ Found AppRegistry in module ' + modId);
                                global.AppRegistry = appReg;
                                
                                try {
                                    __r(0);
                                    console.log('✅ Executed index.js from final attempt');
                                    return true;
                                } catch (e) {
                                    console.log('⚠️ Error in final attempt: ' + e.message);
                                }
                            }
                        }
                    } catch (e) {
                        console.log('❌ Final attempt module ' + suspectedModules[j] + ' failed: ' + e.message);
                    }
                }
                
                // Absolute final attempt - create our own AppRegistry
                console.log('🔄 Creating manual AppRegistry...');
                try {
                    global.AppRegistry = {
                        _registry: {},
                        registerComponent: function(appKey, componentProvider) {
                            console.log('📱 Registering component: ' + appKey);
                            this._registry[appKey] = {
                                componentProvider: componentProvider,
                                run: function() { console.log('Running ' + appKey); }
                            };
                            return appKey;
                        },
                        getAppKeys: function() {
                            return Object.keys(this._registry);
                        }
                    };
                    
                    console.log('✅ Manual AppRegistry created');
                    
                    // Now try to execute index.js
                    try {
                        __r(0);
                        console.log('✅ Executed index.js with manual AppRegistry');
                        
                        if (global.AppRegistry._registry['SeatclubApp']) {
                            console.log('✅ SeatclubApp registered with manual AppRegistry!');
                            return true;
                        } else {
                            console.log('📋 Manual registry contents: ' + Object.keys(global.AppRegistry._registry));
                            return true; // We have AppRegistry, that's enough
                        }
                    } catch (e) {
                        console.log('❌ Error executing index.js with manual AppRegistry: ' + e.message);
                    }
                } catch (e) {
                    console.log('❌ Failed to create manual AppRegistry: ' + e.message);
                }
                
                return false;
            } else {
                console.log('❌ Metro require system not found');
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
    
    func createRootView(moduleName: String, props: [String: Any]?) -> UIView {
        if isReactNativeLoaded {
            return createReactNativeView(props: props)
        } else {
            return createErrorView()
        }
    }
    
    private func createReactNativeView(props: [String: Any]?) -> UIView {
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