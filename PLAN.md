# Add layered iOS 26 app icon from Icon Composer

**What's changing:**

- Download and extract your Icon Composer `.icon` file from the provided zip
- Place it as `AppIcon.icon` in the project root (`ios/RedfinClone/`) so Xcode picks it up automatically
- The existing flat icon in the asset catalog will serve as the fallback for iOS 18 and earlier, while the new layered `.icon` file will be used on iOS 26+ for the Liquid Glass treatment

**Result:**
- On iOS 26+, your app icon will display with Apple's new layered glass effect using the layers you designed in Icon Composer
- On iOS 18 and earlier, the existing flat icon will continue to be used as a fallback
