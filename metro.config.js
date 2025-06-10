const { getDefaultConfig, mergeConfig } = require("@react-native/metro-config");

/**
 * Metro configuration
 * https://facebook.github.io/metro/docs/configuration
 */
const config = {
  transformer: {
    getTransformOptions: async () => ({
      transform: {
        experimentalImportSupport: false,
        inlineRequires: true,
      },
    }),
  },
  resolver: {
    // Ensure React Native modules are resolved properly
    alias: {
      "react-native": "react-native",
    },
  },
  serializer: {
    // Include all modules in the bundle
    getModulesRunBeforeMainModule: () => [
      // Ensure React Native polyfills are included
      require.resolve("react-native/Libraries/Core/InitializeCore"),
    ],
  },
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
