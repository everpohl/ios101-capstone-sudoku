Original App Design Project - README
===

# Sudoku

## Table of Contents

1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)

## Overview

### Description

A Sudoku game client for iOS, built with Swift and UIKit. Puzzles are fetched from API Ninjas' Sudoku API, and the experience is meant to be heavily customizable so players can set up Sudoku the way they like to play it: theme colors, app icon, peer highlighting, an optional clock, pencil notes, and more.

> **Status:** this README documents the planning and brainstorming for the app. The project is already well underway, so each item below is marked as built, in progress, or planned.

### App Evaluation

- **Category:** Strategy Game
- **Mobile:** Sudoku is a natural fit for a phone. Play is touch-based (tap a cell, tap a number), sessions are short and can be paused and resumed, and games are saved locally so a player can pick one up anywhere. Mobile also allows per-player customization such as alternate app icons.
- **Story:** Most Sudoku apps are ad-heavy and rigid. This app lets the player decide how the game looks and behaves (theme, helpers, timer, what counts toward progress), so it suits both casual players and people who want a stricter, more traditional experience.
- **Market:** Anyone who enjoys logic puzzles, which is a very wide audience. Customization is the differentiator, and is aimed at people frustrated by the defaults in existing apps. Additionally, I would like to look into various ways to shake up the traditional sudoku format, like possibly 16x16 puzzles or ...
- **Habit:** Moderately-Partially habit-forming. Saved games, per-difficulty leaderboards, and a timer give players reasons to come back for a quick game. Users exclusively consume (via playing the game) rather than creating any kind of content.
- **Scope:** A stripped-down version (fetch a puzzle, play it, save it) is achievable within the course timeline. Customization, notes, leaderboards, and a local puzzle generator are stretch layers that can be dropped without breaking the core app.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* [x] User can start a new game at a chosen difficulty (easy, medium, hard) with puzzles fetched from the API
* [x] User can tap a cell and enter a number from the keypad
* [x] Given (initial) cells cannot be edited
* [x] User can erase a number they entered
* [x] Mistakes are counted when a wrong number is placed
* [x] Games are saved automatically and can be resumed from a list of saved games
* [x] Game clock tracks time spent on a puzzle
* [x] User can view a leaderboard / high scores tab

**Optional Nice-to-have Stories**

* [x] User can customize the app in Settings (theme color, alternate app icon, highlight peers, show/hide clock)
* [x] Settings persist between launches
* [x] User can delete a saved game
* [ ] Pencil/Canidates notes
* [ ] Pause functionality to allow the user to take a break without running up the clock and without closing the app.
* [ ] Leaderboard filtering (by difficulty)
* [ ] Local, offline puzzle generator as an alternative to the API
* [ ] Cut / copy / paste for cell values or notes
* [ ] Hints

### 2. Screen Archetypes

- [x] **Games list** (saved games, "Sudoku Games")
  * User can resume a saved game
  * User can delete a saved game
  * User can start a new game at a chosen difficulty
- [x] **Game screen** ("Sudoku")
  * User can tap cells and place or erase numbers
  * User can see the clock, mistakes, and highlighted peer cells
  * User can pause the game
  * User can toggle pencil mode (in progress)
- [x] **Leaderboard**
  * User can view past results / leaderboard
  * Filter by difficulty
- [x] **Settings**
  * User can pick a theme color and matching app icon
  * User can toggle peer highlighting
  * User can hide the clock, useful for players who don't want to feel rushed
  * User can toggle between using the api or the local generator to fetch new puzzles

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Games
* Leaderboard
* Settings

**Flow Navigation** (Screen to Screen)

- [x] **Games list**
  * Tap a saved game, or create a new game, to open the **Game screen**
- [x] **Game screen**
  * Back button returns to the **Games list**
  * Finishing a game records a result shown on **High Scores**
- [x] **High Scores**
  * Tab only, updates when user finishes a game but does not have any opportunities for direct user input
- [x] **Settings**
  * No other screens; changes take effect immediately across the entire app

## Wireframes

[Add picture of your hand sketched wireframes in this section]
<img src="YOUR_WIREFRAME_IMAGE_URL" width=600>

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema

### Models

### Networking
