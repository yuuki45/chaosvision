# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CHAOS VISION (中二スキャナー) is a Flutter AR camera app that scans real-world objects and generates dramatic "chuuni" (middle school syndrome) style alternate names and backstories using AI. The app provides an entertaining way to view everyday objects through a fantastical lens.

## Planned Architecture

### Core Components
- **AR Camera Scanner**: Real-time object detection using Google ML Kit/Vision API
- **AI Story Generator**: GPT API integration for generating dramatic object descriptions
- **Collection System**: Local storage for scanned items with attributes and descriptions  
- **AR UI Effects**: Magic circle animations and attribute-based visual effects
- **Social Sharing**: Export scan results as shareable images

### Technology Stack
- **Framework**: Flutter (iOS/Android cross-platform)
- **Object Detection**: Google ML Kit, Vision API, or TensorFlow Lite
- **AI Generation**: OpenAI GPT API (Chat Completions)
- **Backend**: Supabase or Firebase (user data, collections)
- **Animations**: Lottie, Custom Animation, or Flame engine
- **Image Generation**: Flutter Screenshot capabilities

## Key Features to Implement

1. **Real-time Object Scanning**: Camera-based object recognition with AR overlay
2. **Dynamic Content Generation**: AI-powered dramatic names and backstories
3. **Visual Effects System**: Attribute-based animations (fire, dark, wind, etc.)
4. **Collection Management**: Save and categorize scanned items
5. **Social Integration**: Share results to social platforms
6. **Special Events**: Time/location-based rare item appearances

## Development Commands (When Project Structure Exists)

```bash
# Initial Flutter setup
flutter create . --project-name chaos_vision
flutter pub get

# Development
flutter run                    # Run app on connected device
flutter run -d chrome         # Run on web (for testing)
flutter hot-reload            # Hot reload during development

# Testing and Quality
flutter test                  # Run unit tests
flutter integration_test      # Run integration tests
flutter analyze              # Static analysis
flutter format .             # Format code

# Build
flutter build apk            # Android APK
flutter build ipa            # iOS IPA (requires Xcode)
flutter build web            # Web build
```

## Critical Implementation Notes

### Object Detection Integration
- Implement camera stream processing with ML Kit
- Create object category mapping system (refrigerator → "Ice Prison Core", etc.)
- Handle detection confidence thresholds and error states

### AI Integration Patterns
- Design prompt templates for consistent character generation
- Implement response caching to avoid duplicate API calls for same objects
- Create fallback content for offline scenarios
- Manage API rate limits and error handling

### AR/Camera Architecture  
- Separate camera controller from detection logic
- Implement overlay rendering system for magic circle effects
- Handle device orientation and camera permissions
- Optimize performance for real-time processing

### Data Architecture
- Local SQLite/Hive storage for collections
- User preference management
- Image caching for generated content
- Sync logic for cloud backup (if using Firebase/Supabase)

### Performance Considerations
- Optimize ML model loading and inference speed
- Implement efficient image processing pipelines
- Memory management for camera streams and generated content
- Battery usage optimization for continuous camera use

## UI/UX Implementation Focus

- Dark theme with mystical color schemes (black + gold/purple)
- Animated magic circle overlays during scanning
- Attribute-based visual effects (fire, lightning, darkness)
- Smooth transitions between scan states
- Responsive design for various screen sizes

## Current State

This project is in the specification phase. The Flutter project structure needs to be initialized before development can begin. Refer to readme.md for complete feature specifications and requirements.