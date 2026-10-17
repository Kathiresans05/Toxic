# ExpertApp Mobile Specification & Features Guide

## Overview
This document serves as the primary technical and UI reference for **ExpertApp Mobile Application** (Customer App & Professional App).

---

## 🎨 Theme Specifications

### 1. Light Theme
- **Background Color**: `#FFF3EB` (Soft warm peach/cream tint)
- **Card Background**: `#FFFFFF` (Pure white with soft border `#FFE5D4`)
- **Primary Accent**: `#FFC107` / `#FFB800` (Vibrant Gold/Yellow)
- **Text Color Primary**: `#2B201A` (Deep Charcoal)
- **Text Color Secondary**: `#7D6E66` (Warm Muted Brown)

### 2. Dark Theme
- **Background Color**: `#0A0A0A` (Deep Dark)
- **Card Background**: `#1E1E1E` (Dark Grey)
- **Primary Accent**: `#FFC107` (Gold/Yellow)
- **Text Color Primary**: `#FFFFFF` (Pure White)
- **Text Color Secondary**: `#9E9E9E` (Grey)

---

## 📱 Mobile UI Features & Customizations

### 1. Easy 1-Step Auth Flow
- **Bypassed Multi-Screen Onboarding**: Users go straight to `EasyAuthScreen`.
- **Segmented Control Tab Bar**: Single screen with **Login** and **Quick Sign Up** tabs.
- **Quick Guest Mode**: 1-Tap `⚡ Quick Enter to App` button for instant access.

### 2. Calling Only (Chat Removed)
- **Supported Communication Modes**:
  - 📞 **Audio Call** (`CallScreen(callType: 'audio')`)
  - 📹 **Video Call** (`CallScreen(callType: 'video')`)
- **Removed**: Chat / Messaging features removed from Expert list cards and bottom navigation bar.

### 3. Bottom Navigation Bar (4 Mobile Tabs)
1. **Home**: Wallet banner, Special Offer cashback card, Categories, Online Experts horizontal list.
2. **Explore**: Complete expert directory with language, status, category, price, and rating filters.
3. **Wallet**: Balance recharge, Razorpay integration, transaction history.
4. **Profile**: Profile details, VIP pass upgrade, Theme Switcher (Dark 🌙 / Light Cream ☀️).

---

## 🛠️ Testing & Running on Mobile Device

To run the application natively on a physical Android/iOS device or emulator:

```bash
# 1. Connect Android phone via USB (with USB Debugging enabled)
flutter devices

# 2. Run Customer App on Mobile Device
cd expert-customer
flutter run -d <device_id>

# 3. Run Professional App on Mobile Device
cd expert-professional
flutter run -d <device_id>
```

---
*Created on: October 2, 2026*
