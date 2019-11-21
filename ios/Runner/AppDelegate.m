#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>


@import UIKit;
@import Firebase;

@implementation AppDelegate

UIImagePickerController *picker;

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FIRApp configure];
    
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    
    FlutterMethodChannel* batteryChannel = [FlutterMethodChannel
                                            methodChannelWithName:@"com.kene.momouusd"
                                            binaryMessenger:controller];
   
    
    __weak typeof(self) weakSelf = self;
    [batteryChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        // Note: this method is invoked on the UI thread.
        if ([@"moMoDialNumber" isEqualToString:call.method]) {
            int batteryLevel = [weakSelf dialNumber:call.arguments[@"code"]];
            
            if (batteryLevel == -1) {
                result([FlutterError errorWithCode:@"UNAVAILABLE"
                                           message:@"Battery info unavailable"
                                           details:nil]);
            } else {
                result(@(batteryLevel));
            }
        }
        else if([@"takePicture" isEqualToString:call.method]){
            [weakSelf takePhotoAndReadText ];
        }
        else {
            result(FlutterMethodNotImplemented);
        }
    }];
    
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (int)dialNumber:(NSString *) number {

    NSString *str = @"telprompt:";
    str = [str stringByAppendingString:number];

    NSString *str1 = str;
    str1 = [str1 stringByAppendingString:@"#"];


    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str1]];
    // NSlog(@"call to channel method on ios");
    return 1;
}

- (int)recogniseImage:(UIImage *)uiImage{
    FIRVision *vision = [FIRVision vision];
    FIRVisionTextRecognizer *textRecognizer = [vision onDeviceTextRecognizer];
    
    FIRVisionImage *image = [[FIRVisionImage alloc] initWithImage:uiImage];
    
    return 1;
}


- (void)tapSelectAd:(id)sender
{
    
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
    picker.allowsEditing = NO;
    
    
//    [self presentModalViewController:picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissModalViewControllerAnimated:YES];
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
//    [takePhotoAndReadText:image]
}


- (int)takePhotoAndReadText
{
    
    UIImage *uiImage;

    FIRVision *vision = [FIRVision vision];
    FIRVisionTextRecognizer *textRecognizer = [vision onDeviceTextRecognizer];
    FIRVisionImage *image = [[FIRVisionImage alloc] initWithImage:uiImage];
    
    [textRecognizer processImage:image
                      completion:^(FIRVisionText *_Nullable result,
                                   NSError *_Nullable error) {
                          if (error != nil || result == nil) {
                              // ...
                              return;
                          }
                          
                          // Recognized text
                          NSString *resultText = result.text;
                          printf("%s", resultText);
                      }];
    
    return 1;
}

@end
