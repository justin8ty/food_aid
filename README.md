# FoodBank Detective

A Flutter web app that helps users locate nearby food banks and restaurants and coordinates distribution of food aid from NGOs to people in need.

## Prerequisites

Ensure Flutter SDK, a browser, and Android Studio toolchain are properly installed. For guidance:

https://docs.flutter.dev/get-started/install/windows/web

Check that all dependencies are installed:

```
flutter doctor
```

## Setup

```
git clone https://github.com/justin8ty/food_aid.git
cd food_aid
flutter run
```

## Features

**Interactive Map**: View food banks and your current location on a map

**State Urgency Visualization**: Color-coded state polygons show food insecurity levels

**Role Selection**: Choose between Provider/NGO or Receiver roles

**Receiver Form**: A form for people in need to register their details

**Responsive Design**: Works on both mobile and desktop screens

**Search Functionality**: Find food banks by name or location

**Location Services**: Automatic detection of user's current location

## Technical Stack

We use a suite of third-party libraries to develop.

Flutter: Cross-platform mobile framework

Google Maps API: For map display and location services

Riverpod: State management solution

Geolocator: For device location services

Material Design: UI components and theming

Vertex AI: For Gemini Chatbot and Regression Model

Firebase: For storage and authentication

## Reference

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
