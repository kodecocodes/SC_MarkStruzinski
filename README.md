## Introduction

Hey what's up everybody, this is ___. In today's screencast, I'm going to introduce you to Shared Web Credentials. Shared Web Credentials is a technology Apple has introduced which allows seamless login into your iOS app after a user has logged into your website using Safari.

Before we begin, I just want to give a shout out to the the Tech Editor of this content, David Worsham. 

Ok, back to it. Shared Web Credentials works using iCloud Keychain, and establishes trust between your site and your app via the site association file. This is a file Apple requires you to host on your domain. If your user has opted into iCloud Keychain and has elected to store their credentials for your domain there, you will be able to present UI that allows them to use those same credentials to log in to your app without the need to type a username or password.

There are 2 components that come together to ensure Shared Web Credentials can offer login functionality:

(Display keynote slide here)

#### Your Web Server
From your domain, you must be able to serve up a file named **`apple-app-site-association`** from either the root of the domain or from a directory named **`.well-known`**. 

The following criteria must be met for the Shared Web Credentials functionality to work:

- The file must be hosted over SSL with a valid signed certificate
- The file cannot use any redirects
- The file cannot be larger than 128KB uncompressed
- The file must hame MIME type `application/json`
- The file must not have an extension
- The json payload in the file must contain a `webcredentials` object
- Inside the `webcredentials` object of this file, there has to be an array of bundle identifiers with the full team prefix. One of these identifiers has to match the one for your app.

To easily meet those requirements for this demo, we're going to use the free Heroku web service to establish a domain.

#### Your iOS App
Your app's bundle id has to match the one being referenced by the **`apple-app-site-assocation`** file on your web server. Your app must also enable the **Associated Domains** capability, and you have to add your site domain to the domain list with a **`webcredentials`** prefix.

As you can see, there are some setup steps that need to be satisfied before we can start coding our iOS app, so let's get started!

## Demo

We'll have to set up 2 components to make Shared Credentials work - the iOS app and a web app. We'll start by configuring the web app, move over and configure the iOS app, then wrap up with some code in the iOS app to make everything work together.

#### Web App Setup

Our next step is to set up our web server. Since Shared Web Credentials requires a functioning domain set up over SSL, we will use a free [Heroku](https://www.heroku.com) account. Heroku offers up to 5 free domains, and will satisfy this Apple requirement.

1. Head on over to the [Heroku Site](https://www.heroku.com). Setup a free account if you don't already have one, and log in.
2. Set up the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) following the instructions for macOS using either homebrew or the native installer
3. Open Terminal, and enter `heroku login`
4. Enter your Heroku credentials
5. Clone the web app repository to a local folder on your mac by running `git clone git@github.com:raywenderlich/shared-credentials.git`. This web app is written in Ruby on Rails, but you won't need to know any implementation details to get this demo up and running!
6. Inside the base folder of the newly cloned repository, open the `apple-app-site-association.rb` file located at `shared-credentials/config/initializers/apple-app-site-association.rb` in a plain text editor such as [Atom](https://atom.io) or [Visual Studio Code](https://code.visualstudio.com).
7. In the `apps` array, update the bundle identifier to match the one you just created on the Apple Dev Portal. Replace `MX49LZU2AV.com.example.test.sharedcredentials` with your team prefix and bundle id and save the file.
![rails site association](images/rails-site-association.png)
8. Back in Terminal, cd into the base folder of the web app and stage the changes by typing `git add .`
9. Commit the changes by typing git commit -m "Adding bundle id"
10. Type `heroku create` to create a new Heroku app. This will create a new remote on your git repo named `heroku`. This will take a bit, so I'm going to skip ahead to the end. Make note of the new domain Heroku has assigned for you.
11. Push your web app up to Heroku by running `git push heroku master` from the terminal. This should make your web app live. Go to the Heroku domain in the previous step and verify your web app is up and running. You should see a blank page with a Log In button on the top right of the nav bar.

That's it for this section. On to the iOS app!

#### iOS App Setup

This app was created from the single view Xcode template. It is a single ViewController wrapped inside a NavigationController. All button actions and element outlets are wired up already, and we'll just be implementing the logic to enable the Shared Web Credentials functionality.

##### App Capabilities Setup

First we'll need to configure the app to use the Associated Domains capability:

1. Open the starter app, and click the blue Project node in the File Navigator
2. Select the General tab in the center pane
3. Select the app target in the left pane under the Targets heading.
4. Enter a Bundle Id in the Bundle Identifier field here. This bundle id will match the one you set up on the web app (minus the team id prefix) next
![bundle id](images/bundle-id.png)
5. Select the Capabilties tab, scroll to the Associated Domains section, and click the switch to turn it on
6. Click the **+** in this section, and enter your bundle id prefixed by `webcredentials:`. Example:  `webcredentials:com.test.shared-credentials`

![Associated Domain Capability](images/associated-domains-capability.png)

This will set up the trust relationship with your new domain. Next we need to set up the web app.

##### Setting up the App to Store Credentials in iCloud

The first thing we'll need to do is open our newly created domain and attempt a login. This will get Safari to prompt us to store the credentials used for the site, and we can use them later to log the user into the app.

First, we'll need to do some brief setup inside the iOS Simulator.

1. Open the simulator via Xcode's Developer Tool menu. After it's open, go to the Settings app. Verify you are logged in under your iCloud account. 
2. After you're signed in, still inside the Settings app, navigate to Safari => Autofill, and turn on Names and Passwords. This will allow mobile Safari to prompt you to save your passwords on new sites.

Now, we can add the code that will set up Shared Credentials

1. Back in Xcode, open `LoginViewController.swift`
2. At the top of the file, under all the `@IBOutlet` declarations, update the `websiteURLString` variable to match the homepage of your new domain that you got during the web app setup.
3. Now we can run the app and store our credentials in iCloud Keychain. Run the app.  
4. Before you open the site, you need to login to iCloud inside the simulator. If you're not logged into iCloud, shared credentials can't be stored to your iCloud keychain. Navigate to the Settings app and ensure you're logged into your iCloud account.
5. Now navigate back to the iOS app and tap on the Open Website bar button.
6. Once Mobile Safari opens to the webpage, click Login in the header (You might have to scroll horizontally to get there)
7. Enter any email address and password (it doesn't matter which, the site will accept any properly formatted email address and any password)
8. Once you tap Login or hit the Enter key, you should be prompted by Mobile Safari to Save Password. Accept this prompt. 
  
**Accessing Shared Credentials From Your App**

We now have stored credentials for your new domain in iCloud Keychain. The final step will be to set the app up to read them, and we'll be able to use them to log your user in without having to enter them manually

1. Stop the app, and go back to `LoginViewController`
2. We'll need to add a utility function to request the user's permission to use credentials from iCloud Keychain. Add the following function:

```
  private func attemptLoginFromSharedCredentials() {

  }
```

3. Next we'll show some mocked up UI to simulate a network event. Add this to your new method:
```
updateUIForNetworkCall(inProgress: true)
```

4. Now we'll call the system API `SecRequestSharedWebCredentials` to request permission to the stored iCloud credentials for our site. We could request credentials for only our domain, and even a specific user account, but we won't get that specific here. We'll pass `nil` for those 2 parameters. Add this code next:

```
SecRequestSharedWebCredential(nil, nil) { [weak self] (results, error) in

}
```

5. The first thing we'll do after the request completes is to guard against any errors. If the error parameter on the completion block is not nil, then something has failed. We'll log it and exit. We'll also grab a strong reference to the viewcontroller from the capture list above to prevent any retain cycles. Add this code first right inside the completion block:
```
guard error == nil,
  let strongSelf = self else {
  print("Error encountered: \(error!)")
  return
}
```

6. Next we'll perform a count on the `CFArray` parameter returned in the completion block. If the array is not nil, and the count is larger than 0, we got a match back that we can work with. Add this code right below the error `guard`:
```
guard let credentials = results,
  CFArrayGetCount(credentials) > 0 else {
  return
}
```

7. Next we need to get a pointer to the response object returned in the array. Since we know it's the first object in the array, we grab the one at index 0 and cast it to a `CFDictionary`. Add this code next:

```
let unsafeCredentials = CFArrayGetValueAtIndex(credentials, 0)
let credentialsDict = unsafeBitCast(unsafeCredentials, to: CFDictionary.self)
```

8. After we have a reference to the `CFDictionary`, we use a convenience method to retrieve pointers to the username and password values, and make sure we have valid objects back. Add this under the 2 variables you just created:

```
let unsafeLoginValue = strongSelf.unsafeValue(from: credentialsDict, for: kSecAttrAccount)
let unsafePasswordValue = strongSelf.unsafeValue(from: credentialsDict, for: kSecSharedPassword)

guard let unsafeLogin = unsafeLoginValue,
  let unsafePassword = unsafePasswordValue else {
  return
}
```

9. Finally, we turn these into Swift strings with another convenience method. Add this set of calls to `unsafeBitcastToString:` next:

```
let username = strongSelf.unsafeBitcastToString(from: unsafeLogin)
let password = strongSelf.unsafeBitcastToString(from: unsafePassword)
```

10. After all that, we finally have a reference to our username and password! We use those newly created values to populate the username and password fields on the login screen, and invoke the login sequence for the user. In this app, the network request is simulated, but in your production app, you would obviously connect this up to a live API request. Add this code to make the login request:

```
strongSelf.fillCredentialsAndLogin(withUserName: username,
                                    password: password)
```

11. Finally, inside `requestSharedCredentialsTapped(_:)`, make a call to `attemptLoginFromSharedCredentials()`. Normally you would initiate this immediately when the Login screen comes into view, but since this is a single view app, we needed a way to trigger it manually.

##### Testing Your Shared Credentials
1. Now, run the app in the simulator again.
2. Tap the **Request Login with Shared Credentials** button.
3. You should receive a system `UIAlert` that allows you to tap the email address you used on the web login from earlier.
4. Tap that entry, and see that the credentials are populated for you, and Login sequence begins with no further interaction.
  
## Closing 

Ok, that was a lot, but I think it was worth it! The setup is a bit complicated, but once your domain is set up properly, the code to implement this in an iOS app is pretty minimal, and worth the effort for your users. Having a site association file in place also enables some other cool features, such as **Universal Links** and **NSUserActivity** continuation.

At this point, you should understand how to set up your app and your domain to work with Shared Credentials, and how to use Shared Credentials inside your app to log a user in seamlessly.

Thanks for watching, and I hope this helps you get your users logged in a little bit easier!