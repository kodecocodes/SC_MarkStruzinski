# Shared Credentials on iOS

### Approach
To demonstrate the Safari Shared Credentials properly, there are 2 components involved:
1. iOS App
2. Connected web app running over an SSL connection

In order to demonstrate this functionality properly, I have created a local Rails application with the ability to log in. I will commit this entire web app to the repository alongside the iOS app. The proposed idea will be to deploy this app to Heroku on a free account to allow us to get an SSL connection. The Rails app has an `apple-app-site-assocation` file pacckaged with it, which is a requirement for Shared Credentials. After the web app is in place, we can walk the user through the steps to enable Shared Credentials in the iOS app.