# myHueApp
a simple finding bridge and pairing app

## Overview

This app demonstrates finding the Hue Bridge, Establishing a connection to it either remembering its key via `NSUserDeafaults` or it allows you to pair to it.

The UI was lightweight in this app as it was more focused on my code design. I build a few objects that fucntioned with procols in order to disconnect the work load and simplify the approach.

## Right this way

![Alt Text](https://github.com/jmade/jmade.github.io/blob/master/alreadyconnected.gif?raw=true)

A very simple basic Interface, an outline of the hue bridge in a ring that should be the color of your iOS Device! **Shhh... don't tell!**

Tap the hue-hub-outlined view and it will try to shake hands with the hub.

## Link To Bridge

If You're not able to connect you can ping the bride, once you press the link button on the bridge you have about 30 seconds the tap on the app, otherwise youll need to tap the bridge link button again.

![Alt Text](https://github.com/jmade/jmade.github.io/blob/master/linkingtobridge.gif?raw=true)

