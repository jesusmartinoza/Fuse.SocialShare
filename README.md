# Fuse.SocialShare
Library to use social share options in [Fuse](http://www.fusetools.com/)

## Installation
#### fusepm
[fusepm](https://github.com/bolav/fusepm) is a dependency manager for Fuse projects.
    $ fusepm install https://github.com/jesusmartinoza/Fuse.SocialShare

### Manually
Copy the SocialShare.uno, FacebookShare.uxl and FacebookAppId.uxl to your project

## Setup
You will need to register for a Facebook App ID and fill it in as Facebook.AppID in FacebookAppId.uxl.

## Usage
```javascript
    var SocialShare = require("SocialShare");

    // Create your post or tweet using JSON
    var myTweet = {
        text: "This is a tweet from a Fuse app :D",
        // url : "https://www.fusetools.com",
        via : "fusetools"
    }
    var fbPost = {
        text: "This is a post from a Fuse app :D",
        imageUrl: "https://www.fusetools.com/assets/dist/images/frontpage/showcases@2x.png",
        url : "https://www.fusetools.com"
    }

    // Show the social share dialog.
    SocialShare.byTwitter(myTweet);
    SocialShare.byFacebook(fbPost);
```
A more complete example in MainView.ux

## TODO
* iOS facebook share.
* Standard Share sheet with picture.
