# PersonaBudget Enhancements - Implementation Plan

## Goal Description
Enhance the PersonaBudget app to a production-grade level by implementing a highly polished, modern Material 3 dark theme interface, and a fully functional, data-rich Analytics Tab using fl_chart or custom charting to visualize spending habits.

## Proposed Changes

### 1. Advanced Analytics Tab
- **[MODIFY] `lib/ui/screens/tabs/analytics_tab.dart`**: Implement a rich analytics dashboard.
  - Add a **Bar Chart** showing daily spending over the last 7 days.
  - Add a **Pie/Doughnut Chart** breaking down spending by merchant (e.g., Swiggy vs Zomato).
  - Include summary statistic cards (Top Merchant, Average Daily Spend).
- **[MODIFY] `pubspec.yaml`**: Add `fl_chart: ^0.68.0` for beautiful, interactive charting.

### 2. UI/UX Polish & Refinement
- Improve spacing, typography, and card designs across all tabs.
- Add micro-animations (e.g., list staggering) and sophisticated gradients.

### 1. Main Architecture & Tab Navigation
- **[MODIFY] `lib/main.dart`**: Initialize services and ensure background SMS handler is registered properly.
- **[MODIFY] `lib/ui/screens/home_screen.dart`**: Refactor the current screen into a `MainScreen` holding a `BottomNavigationBar`. The navigation will consist of:
  - **Home Tab**: The current risk meter and transaction list.
  - **Analytics Tab**: A blank or placeholder tab for future charts.
  - **Profile/Settings Tab**: A tab displaying current config.
- **[NEW] `lib/ui/screens/tabs/home_tab.dart`**: Extract the visual body of the current `HomeScreen` into a dedicated tab widget.
- **[NEW] `lib/ui/screens/tabs/analytics_tab.dart`**: Basic placeholder.
- **[NEW] `lib/ui/screens/tabs/profile_tab.dart`**: Basic placeholder for settings.

### 2. UI & UX Enhancements
- **[MODIFY] `lib/ui/theme.dart`**: Enhance the dark theme with refined gradients and typography. Add sweeping gradient utility for the Risk Meter.
- **[Applies to `home_tab.dart`]**: Update the Risk Meter to use a dynamic sweeping gradient `ShaderMask` depending on the risk level score to give it a modern vibrant feel.
- **[Applies to `home_tab.dart`]**: Update the transactions list to be sleek cards. Switch the generic fast-food icon to contextual icons (e.g. Swiggy icon/color if Swiggy, Zomato if Zomato).
- **[MODIFY] `lib/ui/widgets/popups.dart`**: Replace the current `SnackBar` based intervention message with a `showGeneralDialog` custom animated overlay that drops down from the top or pops up smoothly from the bottom.

### 3. Real SMS Integration
- **[MODIFY] `lib/services/sms_service.dart`**: 
  - Enhance the global `backgroundMessageHandler`. To properly manage background processing and Hive, we will add initialization logic to save the transaction to the database directly if the app is closed.
  - Update the regular expression to more aggressively match Indian bank SMS formats: e.g. `RegExp(r'(?:rs\.?|inr)\s*(\d+(?:\.\d{1,2})?)', caseSensitive: false)`.
  - Listen for keywords: Swiggy, Zomato, Domino, Eats, Food, Cafe.

### 4. Ultra-Premium UI Overhaul
- **[MODIFY] `lib/ui/theme.dart`**: Implement a "Glassmorphism" theme system. Use `BackdropFilter` for blur effects and mesh gradients for backgrounds.
- **[MODIFY] `lib/ui/screens/tabs/home_tab.dart`**: 
  - Add Neumorphic depth to the Risk Meter.
  - Implement staggered animations for transaction cards.
  - Add subtle mesh gradients to the background.
- **[MODIFY] `lib/ui/screens/tabs/analytics_tab.dart`**: 
  - Enhance chart aesthetics with smoother curves and tooltips.
  - Use glassmorphic card containers for charts and statistics.
- **[MODIFY] `lib/ui/widgets/popups.dart`**: Add particle effects or more dramatic entry animations for the Emergency Cartoon Modal.

## Verification Plan

### Automated Tests
- `flutter analyze` to ensure code correctness and no lints.

### Manual Verification
1. **[User]** Run the app on a physical Android device using `flutter run -d <device>`.
2. **[User]** Complete the onboarding screens to enter the application.
3. **[User]** Use another phone or an SMS emulator to send an SMS to the device with the text: `"INR 500 debited for Swiggy order"`.
4. **[User]** Verify that the app catches the message (if in foreground), updates the Risk Meter automatically, and shows the custom sliding modal notification.
5. **[User]** Verify tab navigation works properly and displays the sleek UI elements.
