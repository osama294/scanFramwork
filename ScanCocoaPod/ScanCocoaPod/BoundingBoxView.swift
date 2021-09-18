//
//  BoundingBoxView.swift
//  MLModelCamera
//
//  Created by Shuichi Tsutsumi on 2020/03/22.
//  Copyright © 2020 Shuichi Tsutsumi. All rights reserved.
//

import UIKit
import Vision
import AVFoundation.AVUtilities

class BoundingBoxView: UIView {
    public let strokeWidth: CGFloat = 2
    
    public var imageRect: CGRect = CGRect.zero
    var observations: [VNDetectedObjectObservation]!
  
    
    
    func updateSize(for imageSize: CGSize) {
    
        imageRect = AVMakeRect(aspectRatio: imageSize, insideRect: self.bounds)
    }
    
    override func draw(_ rect: CGRect) {
        guard observations != nil && observations.count > 0 else { return }
        subviews.forEach({ $0.removeFromSuperview() })

        let context = UIGraphicsGetCurrentContext()!
        
        //main observation
        if observations.count > 0 {
            
            let observation = observations[0]
            let color = UIColor.blue // UIColor(hue: CGFloat(0) / CGFloat(observations.count), saturation: 1, brightness: 1, alpha: 1)
            if drawBigBoxOnly == false{let rect = drawBoundingBox(context: context, observation: observation, color: color)
            smallBoxFrame = rect
                
            }
//            if #available(iOS 12.0, *), let recognizedObjectObservation = observation as? VNRecognizedObjectObservation {
//                addLabel(on: rect, observation: recognizedObjectObservation, color: color)
//            }
        }
        
        //all observations
//        for i in 0..<observations.count {
//            let observation = observations[i]
//            let color = UIColor(hue: CGFloat(i) / CGFloat(observations.count), saturation: 1, brightness: 1, alpha: 1)
//            let rect = drawBoundingBox(context: context, observation: observation, color: color)
//
//            if #available(iOS 12.0, *), let recognizedObjectObservation = observation as? VNRecognizedObjectObservation {
//                addLabel(on: rect, observation: recognizedObjectObservation, color: color)
//            }
//        }
    }
    
    
    
    public func drawBoundingBox(context: CGContext, observation: VNDetectedObjectObservation, color: UIColor) -> CGRect {
        let convertedRect = VNImageRectForNormalizedRect(observation.boundingBox, Int(imageRect.width), Int(imageRect.height))
        let x = convertedRect.minX + imageRect.minX
        let y = (imageRect.height - convertedRect.maxY) + imageRect.minY
        let rect = CGRect(origin: CGPoint(x: x, y: y), size: convertedRect.size)
        
        // check zoom size of device:
        let zoomRatio = rect.height / screenHeight
        if zoomRatio > 0.14 && zoomRatio < 0.19{
            print("zoom ok: \(zoomRatio)")
            zoomMsg = "HOLD STEADY"
            zoomValue = Double(zoomRatio)
        }else{
            if zoomRatio > 0.19{
                print("zoom OUT: \(zoomRatio)")
                zoomValue = Double(zoomRatio)
                zoomMsg = "TOO CLOSE"
            }
            if zoomRatio < 0.14{
                print("zoom IN: \(zoomRatio)")
                zoomValue = Double(zoomRatio)
                zoomMsg = "TOO FAR"
            }
        }
       

        context.setStrokeColor(color.cgColor)
        
        context.setLineWidth(strokeWidth)
        context.stroke(rect)
        
        
        return rect
    }

    @available(iOS 12.0, *)
    public func addLabel(on rect: CGRect, observation: VNRecognizedObjectObservation, color: UIColor) {
        guard let firstLabel = observation.labels.first?.identifier else { return }
                
        let label = UILabel(frame: .zero)
        label.text = firstLabel
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = UIColor.black
        label.backgroundColor = color
        label.sizeToFit()
        label.frame = CGRect(x: rect.origin.x-strokeWidth/2,
                             y: rect.origin.y - label.frame.height,
                             width: label.frame.width,
                             height: label.frame.height)
        addSubview(label)
    }
}
