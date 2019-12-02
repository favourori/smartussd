//
//  NokandaImageRecViewController.m
//  Runner
//
//  Created by Nelson Bassey on 27/11/2019.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "NokandaImageRecViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>

#import "FLTImagePickerImageUtil.h"
#import "FLTImagePickerMetaDataUtil.h"
#import "FLTImagePickerPhotoAssetUtil.h"

@interface NokandaImageRecViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation NokandaImageRecViewController{
    UIViewController *_viewController;
    UIImagePickerController *_imagePickerController;
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    printf(" === >  >>>init with controller called \n");
    self = [super init];
    if (self) {
        _viewController = viewController;
    }
    return self;
}


-(void)getImage{
    
//    _viewController =
//    [UIApplication sharedApplication].delegate.window.rootViewController;
    
    printf(" ===> calling getImage in ObjC class \n");
    
    
    
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    //    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
    _imagePickerController.allowsEditing = NO;
    
//    UIViewController *currentView = UIApplication.sharedApplication.keyWindow.rootViewController;
    [_viewController presentViewController:_imagePickerController animated:YES completion:nil];
    printf(" === >>> reached here \n");
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    printf(" === >>>>>> image chosen success \n");
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
//    printf("%s", chosenImage);
    
    
    [_imagePickerController dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //release picker
    printf(" ===>>> camera cancelled  \n");
    [picker dismissModalViewControllerAnimated:YES];
}


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel =
    [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/nokanda"
                                binaryMessenger:[registrar messenger]];
    UIViewController *viewController =
    [UIApplication sharedApplication].delegate.window.rootViewController;
    
    

}


@end

