//
//  LiveScanViewController.swift
//  DeviceScan
//
//  Created by Osama's Macbook on 14/09/2021.
//

import UIKit
import UIKit
import CoreML
import Vision
import AVFoundation


open class LiveScanViewController: UIViewController, AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    
    
    
    
    
    @IBOutlet weak var guideLabel: UILabel!
    

    
    @IBOutlet open var previewView: UIView!

    @IBOutlet open weak var resultView: UIView!
    @IBOutlet open weak var resultLabel: UILabel!
    @IBOutlet open weak var othersLabel: UILabel!
    @IBOutlet weak var bbView: BoundingBoxView!
    var ConfidenceCount : Int = 0
    
    var ZoomTowardsDevice = false
    
    @IBOutlet open weak var zoomMag: UILabel!
    @IBOutlet open weak var cancelButton: UIButton!
    @IBOutlet open weak var cropAndScaleOptionSelector: UISegmentedControl!
    
    
    @IBAction func cancelBtn(_ sender: UIButton) {
        print("clicked")
        
//        let vc = (self.storyboard?.instantiateViewController(withIdentifier: "tabbar"))! as UIViewController
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true, completion: nil)
        
        
    }
    

    
     var videoCapture: VideoCapture!
    public let serialQueue = DispatchQueue(label: "com.shu223.coremlplayground.serialqueue")
    
    public let videoSize = CGSize(width: 1280, height: 720)
    public let preferredFps: Int32 = 2
    
    public var modelUrls: [URL]!
    public var selectedVNModel: VNCoreMLModel?
    public var selectedModel: MLModel?
    
    public var cropAndScaleOption: VNImageCropAndScaleOption = .scaleFit
    
    public var result = 0 // + -
    public var avgConfidence = 0
    var imageToServer: UIImage? = nil{
        // image to be sent to server
        
        didSet{
            print("retook imageToServer w. AI conf: \(lastConfidence)")
            if inGuideLoop {
                segueManualVerifyALL()
            }
        }
        
    }
    
    public lazy var myFunction: Void = {
       
    }()
    
   
    
    var bestConfidenceImage: UIImage? = nil{
        didSet{
            print("bestConfidence Image: \(imageConfidence)")
        }
    }
    public var invalidResult = 0
    
    
    var timer: Timer?
    
    var finished = false
    
    
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
        
    }
    
    
    
    
    
    
    public func newCerticate(_ approved: String) {
        if captureImageForCertificate != false{
            
            
            
            DispatchQueue.global(qos: .userInitiated).async { [self] in
//                let AIMsg = approved + " w\(avgConfidence)%"
//                let profile = profileManager()
//                if bestConfidenceImage != nil{
//                    profile.setDeviceImage(self.bestConfidenceImage!)
//                }
//                profile.sendCertToSelectedProfile(AIMessage: AIMsg, AIApproval: approved)
//                //            let BackendController: BackendClass = BackendClass.sharedInstance
//                //            _ = BackendController.setNewCert(usr_id: "",
//                //                                             cert_name: "NEW Image Johnson",
//                //                                             cert_email: "ruben@massolabs.com",
//                //                                             cert_passport: "AB-12VQ34",
//                //                                             cert_country: "UK",
//                //                                             cert_device_id: "COVIDE-DEVICE-00111",
//                //                                             cert_ai_pred: "AI Predicate",
//                //                                             cert_ai_approved: approved,
//                //                                             cert_create: "2021-08-01",
//                //                                             cert_image: self.image)
            }
            
        }
        
    }
    
    
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }

                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
 
    

    
    public func segueManualVerifyALL() {
        
        //        //saves device image but doesnt send cert yet
        //        DispatchQueue.global(qos: .userInitiated).async { [self] in
        //        let profile = profileManager()
        //        profile.setDeviceImage(self.image)
        //
        //        }
        
        if imageToServer == nil{ // keep in same video screen after AI scan, to guide user solely to get an image
            inGuideLoop = true
            return
        }
        //AI checks
        calcAvgConfidence()
        
        // Create New Certificate
//        let approved = "N"
//        newCerticate(approved)
//        let certData = profileManager()
//        if imageToServer !== nil {
//            certData.setDeviceImage(imageToServer!)
//        }
        
        //fullscreen segue
     DispatchQueue.main.async {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "newManualSubmit")
            nextViewController.modalPresentationStyle = .fullScreen
            self.present(nextViewController, animated:true, completion:nil)
        }
        
    }
    

    
    public func calcAvgConfidence() {
        //                print("result: \(Double(abs(result)) / Double(checks) * 100)%")
        var total = 0
        for conf in confidenceArr{
            total += conf
        }
        avgConfidence = total / confidenceArr.count
        print("with avg confidence: \(avgConfidence)")
        print("confidence arr: \(confidenceArr)")
    }
    
    var inGuideLoop = false{
        didSet{
            if inGuideLoop{
                DispatchQueue.main.async {
                    self.resultLabel.text = "Capture Image For Manual Verification"
                }
               
                toggleTorch(on: true)
            }
        }
    }
    var checks = 0 {
        didSet{
            if checks == limit {
                if result > 0 && result > invalidResult {
                    print("Result: positive w/ pos: \(result) and invalid: \(invalidResult)")
                    
                      if captureImageForCertificate == true  {
                        segueManualVerifyALL()
                      }else{
                        inGuideLoop = true
                      }
                }else{
                    if result < 0 && abs(result) > invalidResult {
                        print("NEGATIVE Result w/ neg: \(result) and invalid: \(invalidResult)")
                        
                        //                        segueNegativeResult()
                        if captureImageForCertificate == true  {
                            segueManualVerifyALL()
                            
                        }else{
                            inGuideLoop = true
                          }
                        
                    }else{
                        
                        print("Result: invalid w/ result: \(result) and invalid: \(invalidResult)")
                        if captureImageForCertificate == true  { // positives are invalids also
                            segueManualVerifyALL()
                            
                        }else{
                            inGuideLoop = true
                          }
                    }
                }
                
                
                calcAvgConfidence()
                
            }
            
            if checks < limit{
                let percent = Double(checks) / Double(limit) * 100.0
                DispatchQueue.main.async { [weak self] in
                }
                
            }else{
                finished = true
            }
            //            print("checks \(checks), result \(result)")
        }
    }
    
    
    enum covidIdentifier {
        case POSITIVE
        case NEGATIVE
        case INVALID
        case OTHER
    }
    
    var lastResult = covidIdentifier.OTHER
    var lastConfidence = 0.0
    var imageConfidence = 0.0
    var confidenceArr = [Int]()
    
    
    public func showGuideFrame() {
        // get screen size object.
        let screenSize: CGRect = UIScreen.main.bounds
        
        // get screen width.
        let screenWidth = screenSize.width
        
        // get screen height.
        let screenHeight = screenSize.height * 0.8
        
        // the rectangle top left point x axis position.
        let xPos = 100
        
        // the rectangle top left point y axis position.
        let yPos = 100
        
        // the rectangle width.
        let rectWidth = Int(screenWidth) - 2 * xPos
        
        // the rectangle height.
        let rectHeight = Int(screenHeight) - 2 * yPos
        
        // Create a CGRect object which is used to render a rectangle.
        let rectFrame: CGRect = CGRect(x:CGFloat(xPos), y:CGFloat(yPos), width:CGFloat(rectWidth), height:CGFloat(rectHeight))
        //
        //        // Create a UIView object which use above CGRect object.
        //        let rectView = UIView(frame: rectFrame)
        //
        //        // Set UIView background color.
        //        rectView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        //        rectView.alpha = 0.5
        //
        //
        //        // Add above UIView object as the main view's subview.
        //        //              self.view.addSubview(rectView)
        //        previewView.mask = rectView
        // Step 1
        let overlayView = UIView(frame: CGRect(x: 0, y: view.frame.height * (84/786) , width: view.frame.width, height: view.frame.height))
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        // Step 2
        let path = CGMutablePath()
        //           path.addArc(center: CGPoint(x: xOffset, y: yOffset),
        //                       radius: radius,
        //                       startAngle: 0.0,
        //                       endAngle: 2.0 * .pi,
        //                       clockwise: false)
        path.addRect(rectFrame)
        path.addRect(CGRect(origin: .zero, size: overlayView.frame.size))
        // Step 3
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        // For Swift 4.0
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        // For Swift 4.2
        //           maskLayer.fillRule = .evenOdd
        // Step 4
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        overlayView.bringSubviewToFront(cancelButton)
        view.addSubview(overlayView)
        overlayView.bringSubviewToFront(cancelButton)
        
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        //        showGuideFrame()
        let spec = VideoSpec(fps: preferredFps, size: videoSize)
        let frameInterval = 1.0 / Double(preferredFps)
        
        videoCapture = VideoCapture(cameraType: .back,
                                    preferredSpec: spec,
                                    previewContainer: previewView.layer)
        
        videoCapture.imageBufferHandler = {[unowned self] (imageBuffer, timestamp, outputBuffer) in
            let delay = CACurrentMediaTime() - timestamp.seconds
            if delay > frameInterval {
                return
            }
            
            self.serialQueue.async {
                self.runModel(imageBuffer: imageBuffer)
            }
        }

        selectModel()
        
        // scaleFill
        //        cropAndScaleOptionSelector.selectedSegmentIndex = 2
        updateCropAndScaleOption()
        previewView.bringSubviewToFront(zoomMag)
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let videoCapture = videoCapture else {return}
        videoCapture.startCapture()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        startTimer()
        imageConfidence = 0
        imageToServer = nil
        drawBigBoxOnly = false
        captureImageForCertificate = false
        ConfidenceCount = 0
        drawBigBoxOnly = false
        imageToServer = nil
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let videoCapture = videoCapture else {return}
        videoCapture.resizePreview()
        // TODO: Should be dynamically determined
        
        self.bbView.updateSize(for: CGSize(width: videoSize.height, height: videoSize.width))
        
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        guard let videoCapture = videoCapture else {return}
        videoCapture.stopCapture()
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - public
    public func makeSubmitButton(_ msg: String) {
        
        //        DispatchQueue.main.async {
        //            self.submitBtn.isHidden = false
        //            self.resultLabel.text = msg
        //            //                        self.submitBtn.isHidden = false
        //            let button = UIButton(frame: CGRect(x: 50, y: 100, width: 350, height: 50))
        //            button.backgroundColor = .black
        //            button.setTitle("Test Button", for: .normal)
        ////            button.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        //
        //            self.view.addSubview(button)
        //
        //        }
    }
    
    
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
        
        let vc = (self.storyboard?.instantiateViewController(withIdentifier: "manualReviewVC"))! as UIViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    public func showActionSheet() {
        let alert = UIAlertController(title: "Models", message: "Choose a model", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        for modelUrl in modelUrls {
            let action = UIAlertAction(title: modelUrl.modelName, style: .default) { (action) in
                self.selectModel()
            }
            alert.addAction(action)
        }
        present(alert, animated: true, completion: nil)
    }
    
    public func selectModel() {
        guard let modelURL = Bundle.main.url(forResource: "covidAI", withExtension: "mlmodelc") else {
            return
        }
        
        selectedVNModel = try! VNCoreMLModel(for: MLModel(contentsOf: modelURL))
        //        selectedModel = try! MLModel(contentsOf: url)
        //        do {
        //            selectedVNModel = try VNCoreMLModel(for: selectedModel!)
        ////            modelLabel.text = url.modelName
        //        }
        //        catch {
        //            fatalError("Could not create VNCoreMLModel instance from \(url). error: \(error).")
        //        }
    }
    
    public func runModel(imageBuffer: CVPixelBuffer) {
        guard let model = selectedVNModel else { return }
        let handler = VNImageRequestHandler(cvPixelBuffer: imageBuffer)
        
        //reset bounding boxes- result and deviceDispatchQueue.main.async { [weak self] in
        DispatchQueue.main.async { [weak self] in
            self?.bbView.isHidden = true
        }
        confidentlyFoundDevice = false //reset rectangle frame
        
        
        
        //take image of device
        print("details \(stableCameraFrame) -- \(imageConfidence) -- \(zoomValue) ")
        
        //take image of test device
        if stableCameraFrame && (zoomValue > 0.14 && zoomValue < 0.40)
        {
            
            imageToServer = UIImage(ciImage: CIImage(cvPixelBuffer: imageBuffer)).resizedTo1MB()!
            let imageSize = NSData(data: (imageToServer!).jpegData(compressionQuality: 0.5)!).count
        
            //            print("image resized: \()")
            //            print("actual size of image in KB: %f ", Double(imageSize) / 1000.0)
        }
        
        
        
        let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
            if let results = request.results as? [VNClassificationObservation] {
                self.processClassificationObservations(results)
            } else if #available(iOS 12.0, *), let results = request.results as? [VNRecognizedObjectObservation] {
                self.processObjectDetectionObservations(results)
            }
        })
        
        request.preferBackgroundProcessing = true
        request.imageCropAndScaleOption = cropAndScaleOption
        
        do {
            try handler.perform([request])
        } catch {
            print("failed to perform")
        }
    }
    
    var timerMsgStarted = false
    
    var fireCount = 0
    @objc func test() {
        print("Timer! \(fireCount)")
        if timerMsgStarted {
            if (fireCount % 30 == 0){
                timerMsgStarted = false
                allowedConfidence = allowedUpperConfidence
            }
            
            
            if fireCount > 89 {
          captureImageForCertificate = true
                
            
            }
            //        zoomMag.text = zoomMsg
            if fireCount > 99 {
                stopTimer()
                if captureImageForCertificate == true && imageToServer != nil{
                    segueManualVerifyALL()
                }
                
            
            }
            fireCount += 1
            //animation here to help user movoe phone?
            DispatchQueue.main.async { [weak self] in
                self!.resultLabel.text = "Scanning " + String(self!.fireCount) + "%"
            }
        }
        
    }
    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(test), userInfo: nil, repeats: true)
    }
    func stopTimer() {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
    }
    
    @available(iOS 12.0, *)
    public func processObjectDetectionObservations(_ results: [VNRecognizedObjectObservation]) {
        
        //check result
        if results[0].confidence * 100 < Float(allowedConfidence) {
            confidentlyFoundDevice = false
            return
        }
        
        confidentlyFoundDevice = true // stops from finding random nonDevice rectangles
        
        var firstResult = "confidence \((results[0].labels.first?.identifier)!) \(results[0].confidence * 100)%"
        print(firstResult)
        
        // recieved a result, clear missed frames
        if AIMissedFrames > 30 {
            print("ERROR AIMissedFrames = \(AIMissedFrames)")
            
        }else{
            //            AIMissedFrameTimer?.invalidate()
            //            stopTimer()
        }
        AIMissedFrames = 0
        
        
        if captureImageForCertificate == true{
            trackResult()
        }
        
        bbView.observations = results
        
        
        print("Small Box--->\(smallBoxFrame)")
        print("Large Box===>\(bigBoxFrame)")
        DispatchQueue.main.async {
                      //self.dataLabel.setNeedsDisplay()
                      self.guideLabel?.text =  String("Focus on the device")
                  }
        
        if bigBoxFrame.contains(smallBoxFrame){
            DispatchQueue.main.async {
                          //self.dataLabel.setNeedsDisplay()
                          self.guideLabel?.text =  String("Keep Camera Steady")
                      }
      
            ConfidenceCount = ConfidenceCount + 1
            
            if ConfidenceCount >= 20 && ConfidenceCount <= 60{
              
                print("inside big box")
                drawBigBoxOnly = true
                if ConfidenceCount >= 30 && ConfidenceCount <= 60  {
                    
                    print("second loop")
                    DispatchQueue.main.async {
                                  //self.dataLabel.setNeedsDisplay()
                                  self.guideLabel?.text =  String("Keep Camera Steady")
                              }
                    
                    
                    let ratio = (bigBoxFrame.maxY - bigBoxFrame.minY) // (bigBoxFrame.maxX - bigBoxFrame.minX)/(bigBoxFrame.maxY - bigBoxFrame.minY)
                    let ratioScreen = (UIScreen.main.bounds.height) //(UIScreen.main.bounds.width)/(UIScreen.main.bounds.height)
                    
                    print("Difference---> \(ratio * 100) ---- \(ratioScreen * 100)")
           
                    let ZoomCheck = ratio/ratioScreen
                    print("ZoomCheck ===> \(ZoomCheck)")
                
                    
                    
                    if ZoomCheck > 0.59 && ZoomCheck < 0.80 {
//                        DispatchQueue.main.async {
//                                      //self.dataLabel.setNeedsDisplay()
//                                      self.guideLabel?.text =  String("Keep Camera Steady")
//                                  }
                 
                        print("Ratio is 60%")
                        captureImageForCertificate = true
       
                        
                    }else{
                        if ZoomCheck < 0.59 {
                            DispatchQueue.main.async {
                                          //self.dataLabel.setNeedsDisplay()
                                          self.guideLabel?.text =  String("Bring Closer")
                                      }
                        }else{
                            DispatchQueue.main.async {
                                          //self.dataLabel.setNeedsDisplay()
                                          self.guideLabel?.text =  String("Too close")
                                      }
                        }
                       
                        
                        
                        captureImageForCertificate = true
                    }
                    
             
                }else{
//                    DispatchQueue.main.async {
//                                  //self.dataLabel.setNeedsDisplay()
//                                 // self.guideLabel?.text =  String("Adjust Zoom")
//                              }
                    captureImageForCertificate = true
                }
                
            }else{
                drawBigBoxOnly = false

//                DispatchQueue.main.async {
//                              //self.dataLabel.setNeedsDisplay()
//                              self.guideLabel?.text =  String("Keep Device Farther")
//                          }
                captureImageForCertificate = true
                
            }
            
        }else{
            DispatchQueue.main.async {
                
                          //self.dataLabel.setNeedsDisplay()
                          self.guideLabel?.text =  String("Bring Closer")
                      }
            captureImageForCertificate = true
        }
        
     
        // get the best image with most AI confidence for verificication
        if imageToServer != nil {
            //add auto capture here
               imageToServer = imageFoServer
                
            bestConfidenceImage = imageToServer
        }
        
        // start timer on first confident result
        if !timerMsgStarted  {
            timerMsgStarted = true
            allowedConfidence = allowedLowerConfidence
        }
        
        firstResult = ""
        var others = ""
        
        //main result
        if results.count > 0 {
            let result = results[0]
            let confidence = result.confidence * 100
            if Double(confidence) < allowedConfidence {
                return
            }
            confidenceArr.append(Int(confidence))
            
            lastConfidence = Double(String(format: "%.2f", confidence))!
            switch result.labels.first!.identifier {
            case "POSITIVE":
                lastResult = .POSITIVE
            case "NEGATIVE":
                lastResult = .NEGATIVE
            case "INVALID":
                lastResult = .INVALID
            default:
                lastResult = .OTHER
            }
            
           
            
            //            lastResult = result.labels.first!.identifier
            firstResult = "\((result.labels.first?.identifier)!) \(lastConfidence)"
            print(firstResult)
        }
        

        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            ////            self.resultView.isHidden = true
            //            self.resultView.isHidden = false
            //            self.resultLabel.text = firstResult
            //            self.othersLabel.text = others
            
            self.bbView.isHidden = false
            self.bbView.setNeedsDisplay()
        }
    }
    
    public func processClassificationObservations(_ results: [VNClassificationObservation]) {
        
        
        var firstResult = ""
        var others = ""
        for i in 0...10 {
            guard i < results.count else { break }
            let result = results[i]
            let confidence = String(format: "%.2f", result.confidence * 100)
            if i==0 {
                firstResult = "\(result.identifier) \(confidence)"
                print(firstResult)
            } else {
                others += "\(result.identifier) \(confidence)\n"
            }
        }
        DispatchQueue.main.async(execute: {
            self.bbView.isHidden = false
            self.bbView.isUserInteractionEnabled = true
            self.resultView.isHidden = false
            
            
            //            self.resultLabel.text = firstResult
            self.othersLabel.text = others
        })
    }
    
    public func trackResult() {
        if finished {
            return
        }
        if checks > limit {
            finished = true
            
            if result > 20 { // positive result
                //                formattedString = NSMutableAttributedString(string: String(format: "Positive \nConfidence:  %.2f%%", confidence * 100))
            }else{
                if result < -20{ // negative result
                    //                    formattedString = NSMutableAttributedString(string: String(format: "Negative \nConfidence:  %.2f%%", confidence * 100))
                }else{
                    
                    checks = 0
                }
                
            }
            
        }else{
            if lastResult == .POSITIVE || lastResult == .NEGATIVE{
                if lastConfidence > Double(allowedConfidence){
                    //                    formattedString = NSMutableAttributedString(string: "Scanning...\(checks)%")
                    if lastResult == .POSITIVE {
                        result += 1
                    }else{
                        if lastResult == .NEGATIVE {
                            result -= 1
                        }
                    }
                    
                    checks += 1 //one more check made
                }
                
            }else{
                //                formattedString = NSMutableAttributedString(string: "Searching...")
                invalidResult += 1
                checks += 1 //one more check made
            }
        }
        
        
    }
    
    
    public func updateCropAndScaleOption() {
        //        let selectedIndex = cropAndScaleOptionSelector.selectedSegmentIndex
        //        cropAndScaleOption = VNImageCropAndScaleOption(rawValue: UInt(selectedIndex))!
    }
    
    // MARK: - Actions
    
    @IBAction func modelBtnTapped(_ sender: UIButton) {
        showActionSheet()
    }
    
    @IBAction func cropAndScaleOptionChanged(_ sender: UISegmentedControl) {
        updateCropAndScaleOption()
    }
}

extension LiveScanViewController: UIPopoverPresentationControllerDelegate {
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popover" {
            let vc = segue.destination
            vc.modalPresentationStyle = UIModalPresentationStyle.popover
            vc.popoverPresentationController!.delegate = self
        }
        
        if let modelDescriptionVC = segue.destination as? ModelDescriptionViewController, let model = selectedModel {
            modelDescriptionVC.modelDescription = model.modelDescription
        }
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    
}

extension URL {
    var modelName: String {
        return lastPathComponent.replacingOccurrences(of: ".mlmodelc", with: "")
    }
}

extension UIView {
    func snapshotImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: jpegQuality.rawValue)
    }
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resizedTo1MB() -> UIImage? {
        guard let imageData = self.pngData() else { return nil }
        let megaByte = 1000.0
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / megaByte // ! Or devide for 1024 if you need KB but not kB
        
        while imageSizeKB > megaByte { // ! Or use 1024 if you need KB but not kB
            guard let resizedImage = resizingImage.resized(withPercentage: 0.5),
                  let imageData = resizedImage.pngData() else { return nil }
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / megaByte // ! Or devide for 1024 if you need KB but not kB
        }
        
        return resizingImage
    }
    
    
    
    //usage
    //take image of test device
    //    if checks == 50 {
    //        image = UIImage(ciImage: CIImage(cvPixelBuffer: imageBuffer)).resizedTo1MB()!
    //        let imageSize = NSData(data: UIImageJPEGRepresentation((image), 0.5)!).count
    ////            print("image resized: \()")
    //        print("actual size of image in KB: %f ", Double(imageSize) / 1000.0)
    //    }
}




