# bear

Client to consume Bear challenge in flutter

# Getting Started

Pre-requisites: Backend running on port 3000. 

Run flutter pub get to initialize libraries used 

Run the app with flutter run -d Chrome

# App logic 

The app consumes our backend using REST API queries. 
It caches the last queries for a faster reload. 
It caches the filter parameters that have been used as well to reinitiate the page in the previous state it was left in. 
It uses one unified main page where everything is handled with sheets and such. 

# remaining to be done 

Tests.
