## Fuse.SocialShare
Library to use social share options in [Fuse](http://www.fusetools.com/)

## Installation
    1. Copy the SocialShare.uno, FacebookShare.uxl and FacebookAppId.uxl to your project
    2. Change AppID in the FacebookAppId.uxl file

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
A complete more complete example in MainView.ux

## TODO
    - iOS facebook share.
    - Standard Share sheet with picture.
