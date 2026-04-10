# BubblePop 🫧

BubblePop is an interactive, casual iOS game developed in swift. This game challenges players to pop randomly appearing bubbles of various colors to achieve the highest score within a set timeframe.

## Core Gameplay Mechanics
| Color | Point | Chance |
| :--- | :--- | :--- |
| 🔴 Red: | 1 Point | 40% chance |
| 🟣 Pink: | 2 Points | 30% chance |
| 🟢 Green: | 5 Points | 15% chance |
| 🔵 Blue: | 8 Points | 10% chance |
| ⚫ Black: | 10 Points | 5% chance |

- Dynamic Bubble Generation: Bubbles appear at random positions on the screen without overlapping or touching the edges. 
- Score System: Each bubble color represents a different point value and probability for appearing.
- Combo Bonus: Popping two or more bubbles of the same color consecutively will earn a 1.5x multiplier for the subsequent bubbles.

## Features
- Customisable Settings: Players can adjust the game duration (60 seconds) default and the maximum number of bubbles displayed simultaneously (15 seconds).  
- Persistent Leaderboard: Player names and high scores are saved locally and displayed on a scoreboard at the end of each game.  
- Adaptive Design: Functional across different iOS devices (iPhone/iPad) and screen orientations.  

## Tech Stack
- Language: Swift   
- UI Framework: SwiftUI (Storyboard is strictly prohibited)   
- Persistence: Local file or database for high score storage

## DEMO

![ScreenRecording2026-04-10at2 59 16am-ezgif com-video-to-gif-converter](https://github.com/user-attachments/assets/f9863258-cb43-4fe9-bd7a-91ef0846aaea)

## User Login Screen 
<img width="250" height="500" alt="Adobe Express - file" src="https://github.com/user-attachments/assets/60dc785e-0fda-4a10-a37a-09265da1e231" />

Players are required to enter a name before initiating the game and progress to gameplay scene. 

## Gameplay Screen
<img width="250" height="500" alt="Untitled" src="https://github.com/user-attachments/assets/2bde0505-58d2-45c4-b496-856086887908" />

Players need to pop spawned bubbles under a set 60 seconds time limit and there is a HUD tracking provided at the top for live performance metrics. 

## Scoreboard Screen 
<img width="250" height="500" alt="Untitled (1)" src="https://github.com/user-attachments/assets/fa93fa7f-e676-4be4-add8-107da7dc71af" />

A final results overlay will displays player's overall performance and include a direct path to return back to main menu for a new game run.

## AI Usage
This README file was created by Google Gemini. Swift code was written by me and reviewed/edited by Google Gemini. 
