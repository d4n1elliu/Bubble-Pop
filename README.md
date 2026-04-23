<h1 align="center">BubblePop</h1>

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

## Demo

![ScreenRecording2026-04-10at2 59 16am-ezgif com-video-to-gif-converter](https://github.com/user-attachments/assets/f9863258-cb43-4fe9-bd7a-91ef0846aaea)

## User Login Screen 
<img width="500" height="500" alt="Screenshot 2026-04-23 at 9 19 36 pm" src="https://github.com/user-attachments/assets/2741670e-4ac9-4a6b-9bd8-fc727d4b2288" />

<br>

Players are required to enter a name before initiating the game and progress to gameplay scene. 

## Gameplay Screen
<img width="500" height="500" alt="Screenshot 2026-04-23 at 9 22 17 pm" src="https://github.com/user-attachments/assets/9b6326dc-3881-4e13-a342-85adec2c1b68" />

<br>

Players need to pop spawned bubbles under a set 60 seconds time limit and there is a HUD tracking provided at the top for live performance metrics.

## Scoreboard Screen 
<img width="500" height="500" alt="Screenshot 2026-04-23 at 9 23 19 pm" src="https://github.com/user-attachments/assets/38c43a76-88f8-4a8b-ad6e-9d33170257f6" />

<br>

A final results overlay will displays player's overall performance and include a direct path to return back to main menu for a new game run.

## AI Usage
This README file was created by Google Gemini. Swift code was written by me and reviewed/edited by Google Gemini & Claude. 
