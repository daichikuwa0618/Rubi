//
//  RecordingViewController.swift
//  Rubi
//
//  Created by 佐川晴海 on 2019/10/20.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit
import Lottie

class RecordingViewController: UIViewController {

    @IBOutlet weak var descriptionBaseView: UIView! {
        didSet {
            descriptionBaseView.layer.cornerRadius = descriptionBaseView.frame.height/2
        }
    }
    @IBOutlet weak var animationView: AnimationView! {
        didSet {
            animationView.animation = Animation.named("microphone")
            animationView.loopMode = .loop
        }
    }
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var recordingLabel: UILabel!
    var dismissHandler: ((String) -> Void)?
    var recordText:String = ""
    var isStarting: Bool = false
    
    lazy var presentor: RecordingPresenter = {
        return RecordingPresentorImpl(output: self)
    }()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentor.checkMicrophonePermission()
        
        NotificationCenter.default.addObserver(self, selector: #selector(viewWillEnterForeground(
            notification:
        )), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    // MARK: - Event

    
    @IBAction func recordingStart(_ sender: Any) {
    //ボタン外でtouchEndedされた際にイベントを検知できずrecordingが２回走ってしまうのでflugで管理
        if isStarting {
            presentor.stopRecording()
            dismissHandler?(self.recordText)
            return
        }
        
        animationView.play()
        recordingLabel.text = "手を離すと録画が止まります"
        presentor.startRecording()
        isStarting = true
    }
    
    @IBAction func recordingStop(_ sender: Any) {
        animationView.stop()
        recordingLabel.text = "タップすると録画が始まります"
        presentor.stopRecording()
        //Google翻訳のような音を鳴らしたい
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false){_ in
            self.dismissHandler?(self.recordText)
        }
        
         isStarting = false
    }
    
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - PrivateMethod
    @objc func viewWillEnterForeground(notification: Notification) {
        presentor.checkMicrophonePermission()
    }
    
}

// MARK: - RecordingPresentorOutput
extension RecordingViewController: RecordingPresentorOutput {
    func permissionState(permissin: Bool) {
        if !permissin {
            self.showInformation(message: "音声入力が許可されていません\n設定画面で許可してください", buttonText: "許可する"){
                if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                   UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    
    func recordingText(text: String) {
        recordText = text
        resultLabel.text = text
    }
    
    
}

