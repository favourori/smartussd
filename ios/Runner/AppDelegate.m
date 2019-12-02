#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import "Runner-Swift.h"
#import "NokandaImageRecViewController.h"



@import UIKit;
@import Firebase;

@interface AppDelegate() <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end
@implementation AppDelegate

UIImagePickerController *_imagePickerController;


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
            
//            NokandaImageRecognitionObjC *nokandaImageRecognition = [NokandaImageRecognitionObjC new];
            
//            NokandaImageRecognitionObjC *nokanda = [NokandaImageRecognitionObjC new];
            
            
//            NokandaImageRecViewController *nokand = [NokandaImageRecViewController alloc];
            
//            [nokand getImage];
            [weakSelf takeImage];
            
            
            
//            void callImage = [nokandaImageRecognition callGetImage];
            
//            [nokandaImageRecognition callGetImage]
            
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
    return 1;
}

- (void)recogniseImage:(UIImage *)uiImage{
    printf(" === >>>>>recognise text called \n");
    FIRVision *vision = [FIRVision vision];
    FIRVisionTextRecognizer *textRecognizer = [vision onDeviceTextRecognizer];
    
    FIRVisionImage *image = [[FIRVisionImage alloc] initWithImage:uiImage];
    
    [textRecognizer processImage:image
                      completion:^(FIRVisionText *_Nullable result,
                                   NSError *_Nullable error) {
                          if (error != nil || result == nil) {
                              // ...
                              printf("===>>>> reuslt is nil \n");
                              return;
                          }
                          
                          // Recognized text
                          NSString *resultText = result.text;
                          printf("%s \n", resultText);
                          for (FIRVisionTextBlock *block in result.blocks) {
                              NSString *blockText = block.text;
//                              printf("%s \n", blockText);
                              NSNumber *blockConfidence = block.confidence;
                              printf("%i", blockConfidence);
                              NSArray<FIRVisionTextRecognizedLanguage *> *blockLanguages = block.recognizedLanguages;
                              NSArray<NSValue *> *blockCornerPoints = block.cornerPoints;
                              CGRect blockFrame = block.frame;
                              for (FIRVisionTextLine *line in block.lines) {
                                  NSString *lineText = line.text;
//                                  printf("lines are");
//                                  printf("%s", lineText);
                                  NSNumber *lineConfidence = line.confidence;
                                  NSArray<FIRVisionTextRecognizedLanguage *> *lineLanguages = line.recognizedLanguages;
                                  NSArray<NSValue *> *lineCornerPoints = line.cornerPoints;
                                  CGRect lineFrame = line.frame;
                                  for (FIRVisionTextElement *element in line.elements) {
                                      NSString *elementText = element.text;
                                      NSNumber *elementConfidence = element.confidence;
                                      NSArray<FIRVisionTextRecognizedLanguage *> *elementLanguages = element.recognizedLanguages;
                                      NSArray<NSValue *> *elementCornerPoints = element.cornerPoints;
                                      CGRect elementFrame = element.frame;
                                  }
                              }
                          }
                          
                          printf(" === >>>> done printing text \n");

                      }];
    
//    return 1;
}


- (void)takeImage
{
    printf(" ===> calling getImage in ObjC class \n");
    
    
    
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePickerController.allowsEditing = NO;
    
   FlutterViewController* _viewController = (FlutterViewController*)self.window.rootViewController;
    [_viewController presentViewController:_imagePickerController animated:YES completion:nil];
    printf(" === >>> reached here \n");

}

- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    printf("==>>> take image controller completed \n");
    [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    [self recogniseImage:image];

}



@end
