import React from "react";
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  View,
  useColorScheme,
  TouchableOpacity,
  Alert,
} from "react-native";

export default function SeatclubApp({
  theme = "light",
  title = "Welcome to SeatClub!",
  onAction = null,
}) {
  const isDarkMode = useColorScheme() === "dark" || theme === "dark";

  const backgroundStyle = {
    backgroundColor: isDarkMode ? "#000000" : "#FFFFFF",
    flex: 1,
  };

  const handleAction = (action) => {
    if (onAction) {
      onAction(action);
    } else {
      Alert.alert("Action", `You tapped: ${action}`);
    }
  };

  return (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar
        barStyle={isDarkMode ? "light-content" : "dark-content"}
        backgroundColor={backgroundStyle.backgroundColor}
      />
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={backgroundStyle}
      >
        <View style={styles.container}>
          <Text style={[styles.title, { color: isDarkMode ? "#FFF" : "#333" }]}>
            {title}
          </Text>
          <Text
            style={[
              styles.description,
              { color: isDarkMode ? "#CCC" : "#666" },
            ]}
          >
            This is your SeatClub React Native app running inside any iOS app.
          </Text>

          <View style={styles.section}>
            <Text
              style={[
                styles.sectionTitle,
                { color: isDarkMode ? "#FFF" : "#333" },
              ]}
            >
              Features:
            </Text>
            <Text
              style={[styles.feature, { color: isDarkMode ? "#DDD" : "#555" }]}
            >
              ✅ Self-contained CocoaPods framework
            </Text>
            <Text
              style={[styles.feature, { color: isDarkMode ? "#DDD" : "#555" }]}
            >
              ✅ Easy integration with one pod line
            </Text>
            <Text
              style={[styles.feature, { color: isDarkMode ? "#DDD" : "#555" }]}
            >
              ✅ Customizable themes and props
            </Text>
            <Text
              style={[styles.feature, { color: isDarkMode ? "#DDD" : "#555" }]}
            >
              ✅ Production-ready distribution
            </Text>
          </View>

          <View style={styles.buttonContainer}>
            <TouchableOpacity
              style={[styles.button, { backgroundColor: "#007AFF" }]}
              onPress={() => handleAction("primary")}
            >
              <Text style={styles.buttonText}>Primary Action</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.button, { backgroundColor: "#34C759" }]}
              onPress={() => handleAction("secondary")}
            >
              <Text style={styles.buttonText}>Secondary Action</Text>
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 24,
    justifyContent: "center",
  },
  title: {
    fontSize: 24,
    fontWeight: "bold",
    textAlign: "center",
    marginBottom: 16,
  },
  description: {
    fontSize: 16,
    textAlign: "center",
    marginBottom: 32,
    lineHeight: 24,
  },
  section: {
    backgroundColor: "rgba(128, 128, 128, 0.1)",
    padding: 16,
    borderRadius: 8,
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: "bold",
    marginBottom: 12,
  },
  feature: {
    fontSize: 16,
    marginBottom: 8,
  },
  buttonContainer: {
    gap: 12,
  },
  button: {
    padding: 16,
    borderRadius: 8,
    alignItems: "center",
  },
  buttonText: {
    color: "white",
    fontSize: 16,
    fontWeight: "600",
  },
});
