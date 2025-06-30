# Tic Tac Two

A high intensity turn-based multiplayer strategy game leveraging:
- firebase firestore realtime database
- firebase cloud functions
- firebase authentication
- firebase emulaton
- flame engine
- flutter

## Setup
1. Install Flutter Sdk
2. Install Npm
3. Install Visual Studio (optional)
4. Run ```flutter doctor``` and fix any problems
5. Install firebase CLI via ```npm install -g firebase-tools```
6. Run ```firebase login```
7. Install Node.js for emulated function capabilities
8. Clone repo ```cd ./tic_tac_two```
9. Run ```npm install -g flutterfire_cli```
10. Run ```flutterfire configure```
    - Select a firebase project from your console!
    -  if you don't see yours, use ```firebase logout```, then ```firebase login```
    -  Repeat above step 
  
11. Run ```firebase init emulators```
    - Select Auth, Functions, Firestore emulators
12. type ```code .``` in root dir to open visual studio (if installed)
13. navigate to ```lib\main.dart``` and set ```USE_EMULATORS=true```
14. Run ```firebase emulators:start --import=.\emulator-data\basic-display-name-sample\```
    - I've provided an emulator with a firestore database with a single documenet and a display_name field for testing
15. In a separate terminal run ```flutter run -d windows``` or desired platform from ```flutter devices```    