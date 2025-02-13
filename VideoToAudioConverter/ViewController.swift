//
//  ViewController.swift
//  VideoToAudioConverter
//
//  Created by Atik Hasan on 2/14/25.
//

import UIKit
import AVFoundation
import MobileCoreServices

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var player: AVPlayer?
    var audioURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func selectVideo(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    
    // MARK: - Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        dismiss(animated: true)
        
        guard let videoURL = info[.mediaURL] as? URL else { return }
        print("🎥 Selected video: \(videoURL)")
        extractAudioAndExport(sourceUrl: videoURL)
        
    }
    
    
    // MARK: - Show Alert
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
    // MARK: - Convert video to audio file
    func extractAudioAndExport(sourceUrl: URL) {
        // Create a composition
        let composition = AVMutableComposition()
        do {
            let asset = AVURLAsset(url: sourceUrl)
            guard let audioAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else { return }
            guard let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
            try audioCompositionTrack.insertTimeRange(audioAssetTrack.timeRange, of: audioAssetTrack, at: CMTime.zero)
        } catch {
            print(error)
        }
        
        // Get url for output
        let outputUrl = URL(fileURLWithPath: NSTemporaryDirectory() + "output_Atik.m4a")
        if FileManager.default.fileExists(atPath: outputUrl.path) {
            try? FileManager.default.removeItem(atPath: outputUrl.path)
        }
        
        // Create an export session
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough)!
        exportSession.outputFileType = AVFileType.m4a
        exportSession.outputURL = outputUrl
        
        // Export file
        exportSession.exportAsynchronously {
            guard case exportSession.status = AVAssetExportSession.Status.completed else { return }
            
            DispatchQueue.main.async { [self] in
                showAlert(message: "Audio export successfully completed!")
                guard let outputURL = exportSession.outputURL else {
                    showAlert(message: "Audio export failed")
                    return }
                print("outputURL: ",outputURL)             /// Here yout audio URL
                let activityViewController = UIActivityViewController(activityItems: [outputURL], applicationActivities: [])
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
}
