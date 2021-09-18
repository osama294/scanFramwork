//
//  framworkState.swift
//  DeviceScan
//
//  Created by Osama's Macbook on 18/09/2021.
//

import Foundation
import UIKit

var debugMode = false
let fakeServerProfiles = false
var activeCerts = 2

//live scan monitor
var AIMissedFrames = 0
var allowedConfidence = 30.0
var allowedUpperConfidence = 60.0
var allowedLowerConfidence = 30.0
let startingConfidence = 20.0
var stableCameraFrame = false
var bigBoxFrame = CGRect()
var smallBoxFrame =  CGRect()
var drawBigBoxOnly = false

var profileEditingBit = false
var captureImageForCertificate = false {
    didSet{
        if captureImageForCertificate {
            print("********** did get image **********")
        }
    }
}

var limit = 100 // 100 AI results
var confidentlyFoundDevice = false

//zoomed device
let screenSize = UIScreen.main.bounds
let screenWidth = screenSize.width
let screenHeight = screenSize.height
var zoomMsg = ""
var zoomValue : Double = 0.0
var imageFoServer = UIImage()

import Foundation
import UIKit

class appConstant {
//
//    static let widthRatio = UIScreen.main.bounds.width/414.0
//    static let heightRatio = UIScreen.main.bounds.height/746.0
    
    
    static let widthRatio = UIScreen.main.bounds.width/414.0
    static let heightRatio = UIScreen.main.bounds.height/746.0
    public static func screenWidth()->CGFloat{
        var width: CGFloat = 0
        if let window = UIApplication.shared.keyWindow{
            width = window.frame.width
        }
        return width
    }
    
}
