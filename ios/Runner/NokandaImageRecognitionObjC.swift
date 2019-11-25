//
//  NokandaImageRecognitionObjC.swift
//  Runner
//
//  Created by Nelson Bassey on 21/11/2019.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation


class NokandaImageRecognitionObjC:NSObject{
    var instance: NokandaImageRecognition = NokandaImageRecognition()
    
    override init() {
        super.init()
        print("init called from NokandaImageRecognition")
        instance.getImage()
        print("after function call")
        
    }
    
    func callGetImage(){
        instance.getImage()
    }
}

