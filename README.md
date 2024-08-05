# FRAME Pong Game

## Overview

This project implements a classic Pong game for the FRAME device by Brilliant. The game utilizes the FRAME's display, IMU (Inertial Measurement Unit), and tap detection capabilities to create an interactive gaming experience.

## Features

- Classic Pong gameplay
- Single-player mode against an AI opponent
- Tilt controls for paddle movement
- Tap controls for game state management
- Dynamic ball physics
- Score tracking
- Game states: Menu, Playing, Paused, and Game Over

## Requirements

- FRAME device by Brilliant
- Python 3.7+
- `frameutils` library

## Installation

1. Clone this repository or download the `main.lua` file.
2. Ensure you have Python 3.7 or later installed on your system.
3. Install the `frameutils` library:
   ```
   pip install frameutils
   ```

## Usage

1. Connect your FRAME device to your computer.
2. Run the Python script to upload and start the game:
   ```python
   import asyncio
   from frameutils import Bluetooth

   async def main():
       b = Bluetooth()
       await b.connect(print_response_handler=lambda x: print(x))
       await b.upload_file('./main.lua', 'main.lua')
       await b.send_lua("require('main')")
       await asyncio.sleep(1)
       await b.disconnect()
       print("Disconnected from Frame device.")

   if __name__ == "__main__":
       asyncio.run(main())
   ```
3. The game will start on your FRAME device.

## How to Play

- **Start Game**: Tap the screen when on the menu.
- **Move Paddle**: Tilt the FRAME device left or right.
- **Pause/Resume**: Tap the screen during gameplay.
- **Restart**: Tap the screen when the game is over.

## Game Rules

- The game is played against an AI opponent.
- Use your paddle to hit the ball back to your opponent.
- Score points when your opponent misses the ball.
- First player to reach 11 points wins the game.

## Customization

You can modify various game parameters in the `main.lua` file:
- Screen dimensions
- Paddle size
- Ball speed
- Winning score
- AI difficulty

## Troubleshooting

If you encounter any issues:
1. Ensure your FRAME device is properly connected.
2. Check that you have the latest version of the `frameutils` library.
3. Verify that the `main.lua` file is in the same directory as your Python script.

## Contributing

Contributions to improve the game or add new features are welcome. Please feel free to submit pull requests or open issues for bugs and feature requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
Acknowledgments

Brilliant for creating the FRAME device
The Pong game, originally created by Atari