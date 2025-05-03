# Children Achievements Tracker

A Flutter mobile app to track daily achievements for three children: Salma, Jana, and Hana.

## Features

- Track achievements for each child
- Each achievement is worth 10 points
- Maximum 5 achievements per child per day
- Congratulatory message when a child reaches 600 points
- Local data storage using SQLite

## Getting Started

1. Make sure you have Flutter installed on your system
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Dependencies

- sqflite: ^2.3.0
- path: ^1.8.3
- intl: ^0.18.1

## Usage

1. The main screen shows each child's total points
2. Tap "Add Achievement" to add a new achievement
3. Enter the achievement description and save
4. The app will automatically track points and show congratulations when a child reaches 600 points
