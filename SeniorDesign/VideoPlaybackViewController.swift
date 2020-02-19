import UIKit
import AVFoundation
import MessageUI

class VideoPlaybackViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBAction func send(_ sender: Any) {
        composeEmail()
    }
    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!

    var videoURL: URL!

    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.addSubview(videoView)

        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = videoView.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.insertSublayer(avPlayerLayer, at: 0)

        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayer.actionAtItemEnd = .none
        let affineTransform = CGAffineTransform(rotationAngle: degreeToRadian(90))
        avPlayerLayer.setAffineTransform(affineTransform)

        
        
        avPlayer.play()

        NotificationCenter.default.addObserver(self, selector: #selector(VideoPlaybackViewController.playerDidFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    func composeEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            do {
                try mail.addAttachmentData(Data.init(contentsOf: videoURL), mimeType: "video/mp4", fileName: "Video!")

            } catch _ {
                print ("error")
            }

            present(mail, animated: true)
        } else {
            
        }
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
