## Introduction

Hey what's up everybody, this is <Instructor Name>. In today's screencast, I'm going to introduce you to Shared Web Credentials. Shared Web Credentials allows you to easily log you user into your app if they have already logged into your website via Safari or mobile Safari. 

Before we begin, I just want to give a shout out to the author of this content, Mark Struzinski, and the Tech Editor, David Worsham. 

Ok, back to Shared Credentials. Shared Web Credentials is a technology Apple has introduced to allow seamless login to your iOS app once a user has logged into your website using Safari. Shared Web Credentials works using iCloud Keychain, and establishes trust between your site and your app via the site association file. If your user is opted into iCloud Keychain and has elected to store their credentials in iCloud Keychain, you will be able to present UI that allows them to use those same credentials to log in to your  app, without the need to type a username or password.

There are 3 components that come together to ensure Shared Web Credentials can offer login functionality:

#### Apple Developer Portal
In the Apple Dev Portal, you set up a new iOS app with a valid bundle identifier. You also enable the Associated Domains capability.

#### Your Web Server
You must have a valid domain set up. At this domain, you must be able to serve up a file named `apple-app-site-association` from either the root of the domain or from a directory named .well-known. The following criteria must be met for the Shared Web Credentials functionality to work:

- The file must be hosted over SSL with a valid signed certificate
- The file cannot use any redirects
- The file cannot be larger than 128KB uncompressed
- The file must hame MIME type `application/json`
- The file must not contain have an extension
- The file must be available at the root of the domain or in the `.well-known` directory
- The json object inside the file must contain a `webcredentials` object
- Inside the `webcredentials` object of this file, there has to be an array of bundle identifiers with the full team prefix. One of these identifiers has to match the one set up on the portal

To easily meet all of these requirements for this demom, we will use the free Heroku web service.

#### Your iOS App
Your app's bundle id has to match the one you set up on the Apple dev portal, and the one being referenced by the `apple-app-site-assocation` file on your web server. Your app must also enable the Associated Domains capability, and add your site domain to the doamin list with a `webcredentials` prefix.

As you can see, there are a few setup steps that need to be satisfied before we can start coding our iOS app, so let's get started!

## Demo 1

To start, let's go to the [Apple Developer Portal Account section](https://developer.apple.com/account/) to register our new app. 

1. Click the Certificates, Identifiers, and Profiles section
2. In the left sidebar, under the Identifiers section, click the App IDs entry
3. Click the **+** button at the top.
4. Give your app a name, select a team identifier, and create an explicit bundle id.
5. Make note of the team identifier you used in step 4, you will need it in a future step
6. Under App Services, make sure Associated Domains is selected, then click Continue.
7. On the next screen, ensure Associated Domains is enabled, then click Register

Our next step is to set up our web server. Since Shared Web Credentials requires a functioning domain set up over SSL, we will use a free Heroku account. Heroku offers up to 5 free domains, and will satisfy this Apple requirement.

1. Head on over to the [Heroku Site](https://www.heroku.com). Setup a free account if you don't already have one, and log in.
2. Set up the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) following the instructions for macOS using either homebrew or the native installer
3. Open Terminal, and enter `heroku login`
4. Enter your Heroku credentials
5. Clone the web app repository to a local folder on your mac by running `git clone git@github.com:ski081/shared-credentials.git`. This web app is written in Ruby on Rails, but you won't need to know any implementation details to get this demo up and running!
6. Inside the base folder of the newly cloned repository, open the `apple-app-site-association.rb` file located at `shared-credentials/config/initializers/apple-app-site-association.rb` in a plain text editor such as [Atom](https://atom.io) or [Visual Studio Code](https://code.visualstudio.com).
7. In the `apps` array, update the single bundle identifier to match the one you just created on the Appl Dev Portal. Replace `MX49LZU2AV.com.example.test.sharedcredentials` with your team prefix and bundle id and save the file.
8. Back in Terminal, cd into the base folder of the web app
9. Type `heroku create` to create a new Heroku app. This will create a new remote on your git repo named `heroku`. Make note of the new domain Heroku has assigned for you.
10. Push your web app up to Heroku by running `git push heroku master` from the terminal. This should make your web app live. Go to the Heroku domain in the previous step and verify your web app is up and running. You should see a blank page with a Log In button on the top right of the nav bar.

That's it for this section. On to the iOS app!


I'm on a Mac, and I've already have Swift 3 installed. I'll check my installation by running the handy check.vapor.sh script.

```
curl -sL check.vapor.sh | bash
```

Allright - seems to be OK. The next step is to install the Vapor toolbox. This is a command line utility that makes it easy to generate Vapor projects, deploy your code to a web server, and more. To do this, I'll simply run the toolbox.vapor.sh script.

```
curl -sL toolbox.vapor.sh | bash
```

Next I can check that this has installed correctly by running vapor help:

```
vapor --help
```

Now I'll create a project with Vapor, by runining run vapor new. I'll call this project hello-vapor, and switch to the newly created directory.

Vapor is built on top of the Swift package manager, so U could build it using swift build, or through vapor build, or through vapor build, which is a wrapper around that, but personally I find it easier to work with an Xcode project - that way I can see all my files and use auto-completion, which once you get used to it is hard to live without. To create a new Xcode project file, I'll simply run vapor xcode.

```
vapor new hello-vapor
cd hello-vapor
vapor xcode
```

To build it, I need to switch to the app target, then build and run. Note that the web server runs by default on port 8080, so I'll open up a web browser - and nice, it works!

```
http://localhost:8080/
```

## Interlude

The first class you need to understand with Vapor is called Droplet. This is the class that you use to handle GET and POST reqeusts, register routes, configure the server, and more. It's pretty easy to use, so let's just give it a try.

## Demo 2

To have a fresh starting point, I'm going to delete all of the code in main.swift. Then I'll import Vapor and create a new instance of the Droplet class we spoke about. To run the web server, you just need to call run on the droplet.

But we want the server to actually respond to a GET request on the index. That's easy - simply run drop.get and pass a closure. The closure takes a single parameter - an object for the HTTP request. And you need to return an object that conforms to ResourceRepresntable, which a fancy way of saying it can convert itself to a response. Luckily Vapor has made String conform to this protocol, so we can simply return the string "Hello, Vapor.'" If we build and run, test this out in my web browser - it works!

```
import Vapor

let drop = Droplet()

drop.get { request in
  return "Hello, Vapor!"
}

drop.run()
```

Often when you're writing a web API, you want to respond with JSON, and Vapor makes that extremely easy. Simply create a new JSON object - note that it can throw an exception so we need a try - and pass in a dictionary of the data that you want to return. If I build and run, and this out in my web browser - we've got JSON!

```
drop.get { req in
  // return "Hello, Vapor!"
  return try JSON(node: [
    "message": "Hello, Vapor!"
  ])
}
```

When you're designing a web site, or a web API, you often want different things to happen when you arrive at different URLs. For example, let's say we want to have something different appear when we go to /hello. To do this, we can simply pass in the path we want to use as a paramter to drop.get. Let's test this out - it works!

Add routing example:

```
drop.get("hello") { request in
  return try JSON(node: [
    "message": "Hello, again!"
  ])
}
```

You can also nest paths by passing in multiple parameters like this. And here's what it looks like in the browser.

```
drop.get("hello", "there") { request in
  return try JSON(node: [
    "message": "I am tired of saying hello!"
  ])
}
```

Also, you can configure paths that take parameters. For example, let's say we want to go to /beers/number and use whatever number of beers the user passes into that URL as a parameter. 

To do this, simply pass in your path as usual, but for any path you want to use as a parameter, put the type that you are expecting. In this case, we want an int so we just put Int.self. If we try this out, we see it works, and even better - if we try to put something that isn't an Int, Vapor will automatically detect this and throw an error, saving us from having to do that type checking.

```
drop.get("beers", Int.self) { request, beers in
  return try JSON(node: [
    "message": "Take one down, pass it around, \(beers - 1) bottles of beer on the wall..."
  ])
}
```

In addition to GET requests, Vapor can handle all the other HTTP methods, like put, patch, delete, etc. For example, you can simply call drop.post, pass in the path we want to run this on, and our closure as usual.

To get a parameter passed in by the HTTP post, you can simply use the request.data dictionary. I'll access the name parameter here, and convert it to a string using the .string property. Note that if it's not a string this would return nil, so I'll guard against that and return an error if so.

Now let's just return out a message including this name and build and run. I'll use the Rested app to test out the post - and it works! Note it works whether it's form-encoded or JSON-encoded - that's the great thing about request.data.

```
drop.post("post") { request in
  guard let name = request.data["name"]?.string else {
    throw Abort.badRequest
  }
  return try JSON(node: [
    "message": "Hello, \(name)!"
  ])
}
```

## Interlude

At this point evertything is working on your local machine, but the whole point of developing a web app is to release it to the public. Luckily, Vapor this easy.

Vapor supports easy deployments via Docker, or Heroku. In this screencast, we're going to Heroku, which is platform that makes it really easy to deploy your apps. And the best part is, if you're just experimenting with stuff, like we're doing here, it's free.

Let's try this out.

## Demo 3

First, we have to create a local git repository and commit all our code:

`git init`

`git add`

`git commit`

To deploy to Heroku you need a Heroku account. If you don't have one, you can get one for free at heroku.com.

```
https://signup.heroku.com/dc
```

Once you've done that, be sure to install the Heroku toolbox, which is a command line tool to work with Heroku. You can this at toolbelt.heroku.com:

```
https://toolbelt.heroku.com
```

I've already done that, so I can test out my Heroku installation and login on the command line.

```
heroku --version
heroku login`
```

Now to deploy to Heroku, all I need to do is run vapor heroku init.

```
vapor heroku init
```

At this point you usually have to wait a very long time, but I'll skip ahead - and boom it's deployed! We can test this out by loading the URLs in a browser, and even have a beer to celebrate.

```
https://xxx.herokuapp.com/
https://xxx.herokuapp.com/beers/50
```

## Closing 

Allright, that's everything I'd like to cover in this screencast. 

At this point, you should understand how to create a basic Vapor app, handle GET and POST http requests, configure routing, and how to deploy your app using Heroku.

There's a lot more to Vapor - including templating, persitence, authentication, and more which I'll be covering in other screencasts, so be sure to keep an eye out for those.

Thanks for watching - and I look forward to seeing your servers getting Swifty. I'm out!
