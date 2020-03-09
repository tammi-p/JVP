import UIKit

import AVFoundation
import CoreMotion

struct EmailData {
    var outputURL: URL!
    var degree: Double!
}

struct Screen {
    static var screenWidth: CGFloat = UIScreen.main.bounds.width
    static var screenHeight: CGFloat = UIScreen.main.bounds.height
}

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet weak var camPreview: UIView!

    @IBOutlet weak var cameraButton: UIView!

    @IBOutlet weak var degreeLabel: UILabel!

    @IBOutlet weak var recordingLabel: UILabel!
    
    let captureSession = AVCaptureSession()
    
    let movieOutput = AVCaptureMovieFileOutput()
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var activeInput: AVCaptureDeviceInput!
    
    var outputURL: URL!
    
    var manager : CMMotionManager!
    
    var timer = Timer()
    
    var finalDegree : Double! = 0;
    var allowClick : Bool! = true
    var firstClick: Bool! = true // If first click is true, that means the final degree is set
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set camPreview frame width and height
        camPreview.frame.size.width = Screen.screenWidth - 2*8
        camPreview.frame.size.height = Screen.screenHeight - 5*8 - cameraButton.frame.size.height
        
        // Camera
        if setupSession() {
            setupPreview()
            startSession()
        }
        
        self.camPreview.translatesAutoresizingMaskIntoConstraints = false
        self.camPreview.addSubview(recordingLabel)
        recordingLabel.isHidden = true
        
        // Camera Button
        cameraButton.isUserInteractionEnabled = true
        
        let cameraButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.startCapture))
        
        cameraButton.addGestureRecognizer(cameraButtonRecognizer)
        
        cameraButton.backgroundColor = UIColor.red
        
        self.cameraButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Gyroscope
        self.manager = CMMotionManager()
        self.manager!.gyroUpdateInterval = 0.1
        
        // remember to stop it.. with:      self.manager?.stopGyroUpdates()
        self.manager?.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: { [weak self] (motion, error) -> Void in
            
            // Get the attitude of the device
            if let attitude = motion?.attitude {
                // Get the pitch (in radians) and convert to degrees.
                // Import Darwin to get M_PI in Swift
                // print(attitude.pitch * 180.0/M_PI)
                
                DispatchQueue.main.async {
                    let degree = attitude.pitch * 180 / Double.pi
                    if (self!.firstClick) {
                        self!.finalDegree = (degree*100).rounded()/100 // round to 2 decimal places
                    }
                    self?.degreeLabel.text = "Angle: \(String(format: "%.0f",self!.finalDegree))°" // display angle as integer
                    
                    if ((self!.finalDegree >= 30 && self!.finalDegree <= 45) && self!.allowClick) {
                        self?.cameraButton.backgroundColor = UIColor.green
                        self?.cameraButton.isUserInteractionEnabled = true
                    } else {
                        self?.cameraButton.backgroundColor = UIColor.red
                        self?.cameraButton.isUserInteractionEnabled = false
                    }
                }
            }
        })
    }
    
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = camPreview.frame
        // print("Preview Layer Frame: \(previewLayer.frame)")
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        camPreview.layer.addSublayer(previewLayer)
    }
    
    //MARK:- Setup Camera
    
    func setupSession() -> Bool {
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        // Setup Camera
        let camera = AVCaptureDevice.default(for: AVMediaType.video)! // rear camera
        // let camera = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: .video, position: AVCaptureDevice.Position.front)! // front camera
        if (camera.isFocusModeSupported(.continuousAutoFocus)) {
            try! camera.lockForConfiguration()
            camera.focusMode = .continuousAutoFocus
            camera.unlockForConfiguration()
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        // Setup Microphone
        let microphone = AVCaptureDevice.default(for: AVMediaType.audio)!
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
        
        
        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        return true
    }
    
    func setupCaptureMode(_ mode: Int) {
        // Video Mode
        
    }
    
    
    //MARK:- Camera Session
    func startSession() {
        
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
//    func currentVideoOrientation() -> AVCaptureVideoOrientation {
//        var orientation: AVCaptureVideoOrientation
//
//        switch UIDevice.current.orientation {
//        case .portrait:
//            orientation = AVCaptureVideoOrientation.portrait
//        case .landscapeRight:
//            orientation = AVCaptureVideoOrientation.landscapeLeft
//        case .portraitUpsideDown:
//            orientation = AVCaptureVideoOrientation.portraitUpsideDown
//        default:
//            orientation = AVCaptureVideoOrientation.landscapeRight
//        }
//
//        return orientation
//    }
    
    @objc func startCapture() {
        // When gesture recognizer is pressed, if not recording, first time pressing states the final degree is set, second time pressing causes 5s time delay then start recording
        if movieOutput.isRecording == false {
            if (firstClick) {
                firstClick = false
                allowClick = true
            } else {
                allowClick = false
                recordingLabel.isHidden = false
                recordingLabel.text = "Starting..."
                recordingLabel.backgroundColor = .orange
                camPreview.alpha = 0.8
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.startRecording()
                }
            }
        }
        else {
            stopRecording()
        }
    }
    
    //EDIT 1: I FORGOT THIS AT FIRST
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! VideoPlaybackViewController
        let data: EmailData = sender as! EmailData
        
        vc.videoURL = data.outputURL as URL
        vc.finalDegree = data.degree as Double
        vc.screenHeight = Screen.screenHeight
        vc.screenWidth =  Screen.screenWidth
    }
    
    func startRecording() {
        self.recordingLabel.text = "Recording"
        self.recordingLabel.backgroundColor = .red
        camPreview.alpha = 1
        allowClick = true
        
        // self.cameraButton.isUserInteractionEnabled = true
        
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(stopRecording), userInfo: nil, repeats: false)
        
        if movieOutput.isRecording == false {
            
            let connection = movieOutput.connection(with: AVMediaType.video)
            
//            if (connection?.isVideoOrientationSupported)! {
//                connection?.videoOrientation = currentVideoOrientation()
//            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            let device = activeInput.device
            
            if (device.isSmoothAutoFocusSupported) {
                
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
                
            }
            
            //EDIT2: And I forgot this
            outputURL = tempURL()
            
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            
        }
        else {
            stopRecording()
        }
        
    }
    
    @objc func stopRecording() {
        
        timer.invalidate()
        recordingLabel.isHidden = true
        
        if movieOutput.isRecording == true {
            cameraButton.backgroundColor = UIColor.red
            movieOutput.stopRecording()
        }
        
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if (error != nil) {
            
            print("Error recording movie: \(error!.localizedDescription)")
            
        } else {
            let videoRecorded = outputURL! as URL
            
            let data = EmailData(outputURL: videoRecorded, degree: self.finalDegree)
            performSegue(withIdentifier: "showVideo", sender: data)
            
            self.firstClick = true
            self.allowClick = true
            self.finalDegree = 0
        }
    
    }

}
