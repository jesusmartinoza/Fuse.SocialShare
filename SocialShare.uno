using Fuse.Scripting;
using Uno.Compiler.ExportTargetInterop;
using Fuse;
using Fuse.Platform;
using Uno.UX;
using Uno;

[Require("Cocoapods.Podfile.Target", "pod 'FBSDKShareKit'")]
[extern(iOS) ForeignInclude(Language.ObjC, "FBSDKShareKit/FBSDKShareKit.h")]
[extern(iOS) ForeignInclude(Language.ObjC, "FBSDKCoreKit/FBSDKCoreKit.h")]

[Require("Gradle.Dependency","compile('com.facebook.android:facebook-android-sdk:4.8.+') { exclude module: 'support-v4' }")]
[Require("Gradle.Repository","mavenCentral()")]
[ForeignInclude(Language.Java, "android.content.pm.ResolveInfo")]
[ForeignInclude(Language.Java, "android.content.Intent")]
[ForeignInclude(Language.Java, "com.fuse.Activity")]
[ForeignInclude(Language.Java, "java.util.List")]
[ForeignInclude(Language.Java, "android.support.v4.app.ActivityCompat")]
[ForeignInclude(Language.Java, "android.net.Uri")]
[ForeignInclude(Language.Java, "java.net.URLEncoder")]
[ForeignInclude(Language.Java, "java.io.UnsupportedEncodingException")]
[ForeignInclude(Language.Java, "com.facebook.share.widget.ShareDialog")]
[ForeignInclude(Language.Java, "com.facebook.share.model.ShareLinkContent")]
[ForeignInclude(Language.Java, "com.facebook.*")]

[UXGlobalModule]
public class SocialShare : NativeModule
{
    static readonly SocialShare _instance;

    public SocialShare()
    {
        if(_instance != null)
            return;

        _instance = this;
        Resource.SetGlobalKey(_instance, "SocialShare");
        AddMember(new NativeFunction("byTwitter", (NativeCallback)byTwitter));
        AddMember(new NativeFunction("byFacebook", (NativeCallback)byFacebook));

        Lifecycle.Started += Started;
    }

    [Foreign(Language.ObjC)]
	extern(iOS) void Started(ApplicationState state)
	@{
		[[FBSDKApplicationDelegate sharedInstance]
			application: [UIApplication sharedApplication]
			didFinishLaunchingWithOptions: nil];
	@}

    [Foreign(Language.Java)]
	extern(Android) void Started(ApplicationState state)
	@{
		FacebookSdk.sdkInitialize(Activity.getRootActivity());
	@}

    extern(!MOBILE) void Started(ApplicationState state)
    {

    }

    /*===========================================*
                    T W I T T E R
     *===========================================*/
    /**
    * Use Tweet Web Intent to share
    * https://dev.twitter.com/web/tweet-button/web-intent
    **/
    internal static object byTwitter(Context c, object[] args)
    {
        var wrapperObject = c.ObjectCreate(args);
        twitterShare(wrapperObject["text"] as string,
                     wrapperObject["via"] as string,
                     wrapperObject["url"] as string);

        return null;
    }

    /**
    * Used by Android's twitterShare() to encode the text.
    **/
    [Foreign(Language.Java)]
    public static extern(Android) string urlEncode(string s)
    @{
        try {
            return URLEncoder.encode(s, "UTF-8");
        }
        catch (UnsupportedEncodingException e) {
            throw new RuntimeException("URLEncoder.encode() failed for " + s);
        }
    @}

    public static extern(!MOBILE)  void twitterShare(string message, string via, string url)
    {
        debug_log "Try on mobile :)";
    }

    /**
    * Android native implementation
    **/
    [Foreign(Language.Java)]
    public static extern(Android) void twitterShare(string message, string via, string url)
    @{
        String tweetUrl = "https://twitter.com/intent/tweet?text=" +
                            @{SocialShare.urlEncode(string):Call(message)};

        if(via != null) {
            tweetUrl += "&via=" + @{SocialShare.urlEncode(string):Call(via)};
        }

        if(url != null) {
            tweetUrl += "&url=" + @{SocialShare.urlEncode(string):Call(url)};
        }

        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(tweetUrl));
        // Narrow down to official Twitter app, if available:
        List<ResolveInfo> matches = Activity.getRootActivity()
            .getPackageManager().queryIntentActivities(intent, 0);
        for (ResolveInfo info : matches) {
            if (info.activityInfo.packageName.toLowerCase().startsWith("com.twitter")) {
                intent.setPackage(info.activityInfo.packageName);
            }
        }

        Activity.getRootActivity().startActivity(intent);
    @}

    /**
    * iOS native implementation
    **/
    [Foreign(Language.ObjC)]
    public static extern(iOS) void twitterShare(string message, string via, string url)
    @{
        NSString *tweetUrl = @"twitter://";
        tweetUrl = [NSString stringWithFormat:@"post?message=%@", message];

        if(via != nil)
            tweetUrl = [NSString stringWithFormat:@"%@&via=%@", tweetUrl, via];

        if(url != nil)
            tweetUrl = [NSString stringWithFormat:@"%@&url=%@", tweetUrl, url];

        tweetUrl = [tweetUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:tweetUrl]];
    @}

    /*===========================================*
                    F A C E B O O K
     *===========================================*/
     /**
     * Use Tweet Web Intent to share
     * https://dev.twitter.com/web/tweet-button/web-intent
     **/
     internal static object byFacebook(Context c, object[] args)
     {
         var wrapperObject = c.ObjectCreate(args);
         facebookShare(wrapperObject["text"] as string,
                      wrapperObject["imageUrl"] as string,
                      wrapperObject["url"] as string);

         return null;
     }

     public static extern(!MOBILE) void facebookShare(string message, string imageUrl, string url)
     {
         debug_log "Try on mobile :)";
     }

     [Foreign(Language.Java)]
     public static extern(Android) void facebookShare(string message, string imageUrl, string url)
     @{
        ShareLinkContent.Builder builder = new ShareLinkContent.Builder();

        if(message != null)
            builder.setContentDescription(message);
        if(imageUrl != null)
            builder.setImageUrl(Uri.parse(imageUrl));
        if(url != null)
            builder.setContentUrl(Uri.parse(url));

        ShareDialog.show(Activity.getRootActivity(),  builder.build());
     @}


     [Foreign(Language.ObjC)]
     public static extern(iOS) void facebookShare(string message, string imageUrl, string url)
     @{
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentDescription = message;

        if(url != nil)
            content.contentURL = [NSURL URLWithString:url];

        if(imageUrl != nil)
            content.imageURL = [NSURL URLWithString:imageUrl];

        FBSDKShareDialog* dialog = [[FBSDKShareDialog alloc] init];
        dialog.shareContent = content;
        dialog.fromViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [dialog show];
     @}
}
