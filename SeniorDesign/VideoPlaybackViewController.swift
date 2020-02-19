import UIKit
import AVFoundation
import MessageUI

class VideoPlaybackViewController: UIViewController, MFMailComposeViewControllerDelegate {

    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    var videoURL: URL!

    @IBOutlet weak var videoView: UIView!
    
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
        avPlayer.play()

        NotificationCenter.default.addObserver(self, selector: #selector(VideoPlaybackViewController.playerDidFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    func composeEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            do {
                let formatter = DateFormatter()
                //2016-12-08 03:37:22 +0000
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let now = Date()
                let dateString = formatter.string(from:now)
                try mail.addAttachmentData(Data.init(contentsOf: videoURL), mimeType: "video/mp4", fileName: dateString)

            } catch _ {
                print ("There was an error with sending the email.")
            }

            present(mail, animated: true)
        } else {
            
        }
    }
    
    @IBAction func send(_ sender: Any) {
        composeEmail()
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
