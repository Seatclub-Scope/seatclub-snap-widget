import React from "react";
import { View, Text, StyleSheet, TouchableOpacity, Alert } from "react-native";

export default function App() {
  const handlePress = () => {
    Alert.alert("Success!", "React Native is working! 🎉");
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>🎯 SeatClub App</Text>
      <Text style={styles.subtitle}>React Native is running!</Text>

      <TouchableOpacity style={styles.button} onPress={handlePress}>
        <Text style={styles.buttonText}>Test React Native</Text>
      </TouchableOpacity>

      <View style={styles.infoBox}>
        <Text style={styles.infoText}>✅ JavaScript Bundle Loaded</Text>
        <Text style={styles.infoText}>✅ React Components Working</Text>
        <Text style={styles.infoText}>✅ Touch Events Working</Text>
        <Text style={styles.infoText}>✅ Alert Module Working</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#f5f5f5",
    padding: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: "bold",
    color: "#333",
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 18,
    color: "#666",
    marginBottom: 30,
  },
  button: {
    backgroundColor: "#007AFF",
    paddingHorizontal: 30,
    paddingVertical: 15,
    borderRadius: 8,
    marginBottom: 30,
  },
  buttonText: {
    color: "white",
    fontSize: 16,
    fontWeight: "600",
  },
  infoBox: {
    backgroundColor: "white",
    padding: 20,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: "#ddd",
  },
  infoText: {
    fontSize: 14,
    color: "#333",
    marginBottom: 5,
  },
});
