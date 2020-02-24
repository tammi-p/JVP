import UIKit
import AVFoundation
import MessageUI

class VideoPlaybackViewController: UIViewController, MFMailComposeViewControllerDelegate {

    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    var videoURL: URL!
    var finalDegree: Double!
    var nameEntered: String!

    @IBOutlet weak var videoView: PassThroughView!
    
    @IBOutlet weak var sendButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = videoView.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspect

        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayer.actionAtItemEnd = .none
        let affineTransform = CGAffineTransform(rotationAngle: degreeToRadian(90))
        avPlayerLayer.setAffineTransform(affineTransform)
        
        videoView.layer.addSublayer(avPlayerLayer)
        videoView.addSubview(sendButton)
        avPlayer.play()
        
        view.addSubview(sendButton)

        NotificationCenter.default.addObserver(self, selector: #selector(VideoPlaybackViewController.playerDidFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    func composeEmail(name: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            do {
                let formatter = DateFormatter()
                //2016-12-08 03:37:22 +0000
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let now = Date()
                let dateString = formatter.string(from:now)
                mail.setToRecipients(["venous.jvp@gmail.com"]) 
                
                let dateOnly = dateString.prefix(10) // 2016-12-08
                mail.setSubject("\(name)" + " " + dateOnly)
                
                // mail.setMessageBody("Degree: " + String(finalDegree), isHTML: false)
                try mail.addAttachmentData(Data.init(contentsOf: videoURL), mimeType: "video/mp4", fileName: dateString)

            } catch _ {
                print ("There was an error with sending the email.")
            }

            present(mail, animated: true)
        } else {
            
        }
    }
    
    @IBAction func send(_ sender: Any) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Enter Name", message: nil, preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.font = UIFont.systemFont(ofSize: 18.0)
            textField.placeholder = "Please enter your name"
            textField.autocapitalizationType = UITextAutocapitalizationType.words
        }
        
        // 3a. Add a Cancel action.
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // 3b. Grab the value from the text field, and compose email when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0].text // Force unwrapping because we know it exists.
            if textField != "" {
                self.composeEmail(name: textField!)
            }
        }))

        // 4. Present the alert.
        self.present(alert, animated: true)
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        // Used for looping the video infinitely. 
        if let playerItem = note.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler:nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func degreeToRadian(_ x: CGFloat) -> CGFloat {
        return .pi * x / 180.0
    }
}

class PassThroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
}
