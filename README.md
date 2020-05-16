# FishingDaze

### App Description
FishingDaze is a fishing journal app.

It allows you to document your fishing trips, saving information such as:

* date & time
* location
* weather
* pictures of fish caught (if applicable)
* any other additional notes.

This is my capstone project, built as part of my Udacity iOS nanodegree program.

### Download Link
To try the app yourself, you can download it from the [App Store](https://apps.apple.com/us/app/fishingdaze/id1512604599)

### Version Numbers
At the time of my project submission, this app was built on the versions:

- Xcode: 11.3
- Swift: 5
- iOS: 12.2

### Weather API key
Weather data is retrieved from weather.io.

For the app to access weather data, you must get your own API key from [weather.io](https://www.weatherbit.io/) and add it to the APIKeys.swift like below:
- Find the APIKeys.swift file in FishingDaze/FishingDaze/Model/APIKeys.swift
- In the APIKeys.swift file, look for these lines
```
struct APIKeys {
  static let WeatherBitIOKey = "abcdefg"
}
```
- add your real API key to the WeatherBitIOKey in the APIKeys struct

### How to Use the App
The first, or main screen, is the List Screen, which lists the dates of your fishing trips. The very first time you run the app, the list will be blank:

![List Screen Initial](/screenshots/ListScreenBlank.png)

From here, clicking on the "+" sign will take you to the Edit screen, which you can fill out with the details of your latest fishing trip:

![Edit Screen - location part](/screenshots/EditScreen1.png)

Tap on the "Get My Location!" button and make sure location services is on, to get your current location. You may optionally type into the "Body of Water" field after that.

Next, make sure the Date and Time is correct and then scroll the Edit screen up to get to the next part, which is the Weather section:

![Edit Screen - weather part](/screenshots/EditScreen2.png)

Tap on the "Get Current Weather!" button to get the current weather conditions for the location you found earlier.

Finally, scroll the Edit screen up again to get the Photos section.

![Edit screen - photos part](/screenshots/EditScreen3.png)

From here, you can add photos from your phone's Photo Library or Camera; delete existing pictures, or view the pictures in the Scrollable Album (default view) or in the Grid format by clicking on the Grid icon.

Viewing pictures in Grid format looks like this:

![Photo Grid View](/screenshots/PhotoGridScreen.png)

From the Photo Grid screen, tap the "Back" button, which will take you back to the Edit screen. From the Edit screen, tap "Save" and the app will take you back to the initial screen, now with the date of your latest fishing trip added to the list!

![List Screen with 1 entry](/screenshots/ListScreenFilled.png)

Finally, when you tap on the row with your newly added fishing trip, the app will take you to the Detail screen:

![Detail Screen](/screenshots/DetailScreen.png)

From here, you can tap on the "Back" button to see your list again, reminisce about your fishing trip by reading through the details and enjoying the pictures on the Detail screen, or tap on the "Edit" button to make any changes to your fishing journal entry.
