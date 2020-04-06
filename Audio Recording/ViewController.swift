//
//  ViewController.swift
//  Audio Recording
//
//  Created by Awais on 06/04/2020.
//  Copyright © 2020 Awais. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
  
  @IBOutlet weak var recordButton: UIButton!
  @IBOutlet weak var descriptionLabel: UILabel!
  
  var recordingSession: AVAudioSession!
  var audioRecorder: AVAudioRecorder!
  var audioPlayer = AVAudioPlayer()
  
  var audioFileUrl: URL? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupRecorderAndAskPermissions()
  }
  
  func setupRecorderAndAskPermissions() {
    recordingSession = AVAudioSession.sharedInstance()
    do {
      try recordingSession.setCategory(.playAndRecord, mode: .default)
      try recordingSession.setActive(true)
      recordingSession.requestRecordPermission() { [unowned self] allowed in
        DispatchQueue.main.async {
          if !allowed {
            self.presentAlertWith(title: "Recording Persmission", message: "You did not allow to record audio")
          }
        }
      }
    } catch {
      // failed to record!
      let title = "Failed to Record"
      let message = "Unable to set audio session category and mode"
      presentAlertWith(title: title, message: message)
      
    }
  }
  
  func startRecording() {
    audioFileUrl = getDocumentsDirectory().appendingPathComponent("recording.m4a")
    print("Audio file name : \(audioFileUrl as Any)")
    let settings = [
      AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
      AVSampleRateKey: 12000,
      AVNumberOfChannelsKey: 1,
      AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    do {
      audioRecorder = try AVAudioRecorder(url: audioFileUrl!, settings: settings)
      audioRecorder.delegate = self
      audioRecorder.record()
        
      descriptionLabel.text = "Recording your voice"
      recordButton.alpha = 0.5
      
    } catch {
      finishRecording(success: false)
    }
  }
  
  func finishRecording(success: Bool) {
    audioRecorder.stop()
    recordButton.alpha = 1
    descriptionLabel.text = "Stopped Recording. Tap on Play to hear your recording"
    if success {
        recordButton.setTitle("Tap to Re-record", for: .normal)
    } else {
        recordButton.setTitle("Tap to Record", for: .normal)
        // recording failed :(
    }
  }
  
  func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }
  
  func presentAlertWith(title: String, message: String) {
    let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
    self.present(alert, animated: true, completion: nil)
  }
  
  @IBAction func recordButtonTapped(_ sender: UIButton) {
    if audioRecorder != nil && audioRecorder.isRecording {
      finishRecording(success: true)
    } else {
      startRecording()
    }
  }
  
  @IBAction func playButtonTapped(_ sender: UIButton) {
    guard let fileUrl = audioFileUrl else { return }
    if audioRecorder.isRecording {
      descriptionLabel.text = "A Recording is in progress. Play stop it before playing"
    }
    else {
      do {
        audioPlayer = try AVAudioPlayer.init(contentsOf: fileUrl)
        audioPlayer.delegate = self
        audioPlayer.play()
        audioPlayer.volume = 1
        descriptionLabel.text = "Playing recording"
      }
      catch {
        print("Could not make audio player with url, error: \(error)")
      }
    }
  }
  
  @IBAction func stopButtonTapped(_ sender: UIButton) {
    finishRecording(success: true)
  }
  
  
}

extension ViewController: AVAudioRecorderDelegate {
  func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    if !flag {
      finishRecording(success: false)
    }
  }
}

extension ViewController: AVAudioPlayerDelegate {
  
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    descriptionLabel.text = "Finished Playing your recording."
  }
  
  func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
    descriptionLabel.text = "Could not play your recording, error: \(error as Any)"
  }
}

