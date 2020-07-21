# 8 Puzzle Game with AI

The 8 Puzzle game was built with **Flutter** to suit both mobile phones and the browser. it's providing to the user to play the game typically also in case of needing help, the game implements a hint button that moves the tiles one movement to bring it closer to the target in addition to the solve button moves the tiles to solve the entire game step by step until the goal reached.

## User Interface
Landing Page  | Home Page
------------- | -------------
![Landing page](https://lh3.google.com/u/0/d/1tdDgqG-aLY77uJ9Z-Ym3g1T5NayMl0Md=w1920-h913-iv1) | ![Home page](https://lh4.googleusercontent.com/gMrLJZrabVh4jRAFAZOozGHX1lp5EMSAG94i7-vBUeofm4cpMZOFKu7-Li573wXwtgsoaZROzNRVL7FvUSDA=w1920-h913-rw)
| 

## Program Properties

 - The game works in both web browser and mobile devices.
 - The user is free to choose the size of the board.
 - The game provides the user with the ability to choose one or two different goals.
 - The game can be solved using A * algorithm.
 - The user is free to choose the heuristics functions.

## ٍSolving Problem Implementation
The game provides hints and solving the game using the **A*** **algorithm**, also the user can choose between several heuristics functions, such as **tiles difference** and **Manhattan distance**.
# Getting Started

> Before you need to ensure that flutter environment is installed in your device if not you can install it from [Install Flutter.](https://flutter.dev/docs/get-started/install)
## Android device
`$ flutter run`
## Web application
```
flutter upgrade
flutter config --enable-web

# run the project
flutter run -d chrome
```
