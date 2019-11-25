//
//  NokandaImageRecognition.swift
//  Runner
//
//  Created by Nelson Bassey on 21/11/2019.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import UIKit
import Firebase

@objc class NokandaImageRecognition: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var imagePicker: UIImagePickerController!
    
    
    //get image from source type
    func getImage() {
        
        print("get image called")
        //Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker = UIImagePickerController();
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil);
            
        }
    }
    func readTextOnImage(uiimage:UIImage){
        print("image recognition called");
        print(uiimage.imageOrientation);
        let vision = Vision.vision();
        let textRecognizer = vision.onDeviceTextRecognizer();
        let visionImage = VisionImage(image: uiimage);
        
        textRecognizer.process(visionImage) { result, error in
            guard error == nil, let result = result else {
                // ...
                return
            }
            
            // Recognized text
            
            let resultText = result.text;
            print(resultText);
            for block in result.blocks {
                let blockText = block.text
                //                let blockConfidence = block.confidence
                let blockLanguages = block.recognizedLanguages
                print(blockText)
                //                print(blockConfidence)
                print(blockLanguages)
                
                for line in block.lines {
                    let lineText = line.text
                    print(lineText)
                    for element in line.elements {
                        let elementText = element.text
                        let elementLanguages = element.recognizedLanguages
                        print(elementText);
                        print(elementLanguages);
                    }
                }
            }
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            readTextOnImage(uiimage:pickedImage);
        }
        picker.dismiss(animated: true, completion: nil);
        
    }
}
