# 🫧 BubblePop 🫧

BubblePop is an interactive, casual iOS game developed in swift. This game challenges players to pop randomly appearing bubbles of various colors to achieve the highest score within a set timeframe.

## 🎮 Core Gameplay Mechanics
| Color | Point | Chance |
| :--- | :--- | :--- |
| 🔴 Red: | 1 Point | 40% chance |
| 🟣 Pink: | 2 Points | 30% chance |
| 🟢 Green: | 5 Points | 15% chance |
| 🔵 Blue: | 8 Points | 10% chance |
| ⚫ Black: | 10 Points | 5% chance |
- Dynamic Bubble Generation: Bubbles appear at random positions on the screen without overlapping or touching the edges. 
- Scoring System: Each bubble color represents a different point value and probability for appearing:
- Combo Bonus: Popping two or more bubbles of the same color consecutively earns a 1.5x multiplier for the subsequent bubbles.
- Game Loop: The screen refreshes every second, replacing unpopped bubbles with a new set of random colors and positions.  

## ⚙️ Features
- Customizable Settings: Players can adjust the game duration (60 seconds) default and the maximum number of bubbles displayed simultaneously (15 seconds).  
- Persistent Leaderboard: Player names and high scores are saved locally and displayed on a scoreboard at the end of each game.  
- Adaptive Design: Functional across different iOS devices (iPhone/iPad) and screen orientations.  

## 🛠️ Technical Stack
- Language: Swift   
- UI Framework: SwiftUI (Storyboard is strictly prohibited)   
- Persistence: Local file or database for high score storage 
