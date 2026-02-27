# PersonaBudget - Real-time Budget Nudge Agent

PersonaBudget is an ultra-premium, production-grade AI-powered financial intervention agent designed to help users curb excessive food delivery spending.

## 🚀 Key Features

### 💎 Ultra-Premium UI/UX
- **Glassmorphic Aesthetics**: Modern design with frosted glass effects and deep blurs.
- **Mesh Gradients**: Stunning indigo and purple animated backgrounds.
- **Interactive Risk Meter**: Real-time rotating and glowing meter that calculates budget safety.
- **Staggered Animations**: Fluid list transitions and tactile feedback.

### 📱 Intelligent Interceptor
- **Real-time SMS Reading**: Headless background service that monitors bank debit messages (Swiggy, Zomato, etc.) using the `telephony` plugin.
- **Risk Engine**: Dynamically calculates a risk score (0-100) based on spending velocity, budget limits, and ordering patterns.
- **Custom Notifications**: Moving beyond simple SnackBars into premium sliding dropdown alerts.

### 📊 Deep Analytics
- **Data Visualizations**: Beautiful bar and pie charts powered by `fl_chart`.
- **Spending Breakdown**: Tracking Top Merchants, Average Daily Spend, and 7-day trailing history.

## 🛠 Tech Stack
- **Framework**: Flutter (Material 3)
- **Local Database**: Hive (for encrypted, fast local persistence)
- **State Management**: Provider
- **Animations**: Flutter Animate
- **Charts**: fl_chart
- **Fonts**: Google Fonts (Outfit & Inter)

## 📖 Project Documentation
More detailed information can be found in the [docs](./docs) folder:
- [Features Walkthrough](./docs/features_walkthrough.md)
- [Implementation Details](./docs/implementation_details.md)

---

Developed for the Hackathon by [Sravya Somineni](https://github.com/sravyasomineni-ux).
