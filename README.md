# EmoRecApp

## Authors
* Katherine Chen (kathchen@stanford.edu)
* Flora Huang (flora221@stanford.edu)

## Overview
EmoRec is an iOS mobile app for interpreting human emotions from static images captured by the camera or uploaded from the phone’s storage. The app has two modes: 1) a detection mode that interprets emotions from the uploaded images and 2) a practice mode that enables users to practice expressing and recognizing emotions. The app is intended to help people with autism, related disorders, or social anxiety to practice recognizing emotions better and expressing themselves more accurately, thereby improving social skills.

To build the app, first, we trained and tested a CNN model using TensorFlow, and saved the model to a file. Next, we converted the trained model to a format that is compatible with iOS devices using Apple’s Core ML framework. Then, we integrated the converted Core ML model into an iOS app using Xcode and Swift, and used it to make predictions on images captured by the phone’s camera or uploaded from storage. For gamification in the practice mode, our model scores users based on how well they express specific emotions.

## Figma Prototype
https://www.figma.com/proto/bHq12ujvPEVR0dRLmib6WH/EmoRec?node-id=37-2&starting-point-node-id=37%3A2

## Screenshots of Task Flows
* Detection mode
![detect](https://github.com/katchen1/EmoRecApp/assets/59420335/a452a2b9-4403-4cdc-a3d3-cf8abca2c96b)
* Practice mode
![practice](https://github.com/katchen1/EmoRecApp/assets/59420335/c7487ce4-89bd-4824-a474-71abea44ea79)

## Video Demo
https://github.com/katchen1/EmoRecApp/assets/59420335/2037d433-7dea-48dc-80f0-6d94ed7920cf

## Links
* [Final report (PDF)](https://github.com/katchen1/EmoRecApp/files/12387378/CS231N_final.3.pdf)
* [Code](https://github.com/flowers-huang/cs231n-project)

