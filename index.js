import React from "react";
import { AppRegistry, Platform } from "react-native";
import App from "./src/App";

// Ensure console logging works
console.log("🚀 Starting SeatclubApp initialization...");
console.log("📱 Platform:", Platform.OS);
console.log("🔍 React version:", React.version);

// Register the app component with AppRegistry
AppRegistry.registerComponent("SeatclubApp", () => App);

// For debugging - log that registration happened
console.log("✅ SeatclubApp registered with AppRegistry");

// Verify registration worked
if (AppRegistry._registry && AppRegistry._registry["SeatclubApp"]) {
  console.log("✅ Registration verified successfully");
} else {
  console.log("❌ Registration verification failed");
}

// Log available AppRegistry methods
console.log("📋 AppRegistry methods:", Object.keys(AppRegistry));

// Export the App for direct use if needed
export default App;
