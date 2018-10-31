//
//  VideoManager.swift
//  AVVideoComposition
//
//  Created by Diego Caroli on 31/10/2018.
//  Copyright © 2018 Diego Caroli. All rights reserved.
//

import UIKit
import AVFoundation

class VideoManager: AppDirectoryNames {

    var firstAsset: AVAsset
    let secondAsset: AVAsset

    init(firstAsset: AVAsset, secondAsset: AVAsset) {
        self.firstAsset = firstAsset
        self.secondAsset = secondAsset
    }

    func createComposition() -> AVMutableComposition? {
        let mutableComposition = AVMutableComposition()

        // Create the video composition track.
        guard let mutableCompositionVideoTrack = mutableComposition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid) else { return nil }

        // Create the audio composition track.
        guard let mutableCompositionAudioTrack = mutableComposition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid) else { return nil }

        //Adding Audiovisual Data

        // Get the first video track from each asset.
        guard let firstAssetTrack = firstAsset.tracks(withMediaType: .video).first else { return nil }
//        guard let secondAssetTrack = secondAsset.tracks(withMediaType: .video).first else { return nil }

        // Add them both to the composition.
        do {
            try mutableCompositionVideoTrack
                .insertTimeRange(CMTimeRange(start: .zero,
                                             duration: firstAssetTrack.timeRange.duration),
                                 of: firstAssetTrack,
                                 at: .zero)
        } catch {
            print("failed to load the first track")
        }

//        do {
//            try mutableCompositionVideoTrack
//                .insertTimeRange(CMTimeRange(start: .zero,
//                                             duration: secondAssetTrack.timeRange.duration),
//                                 of: secondAssetTrack,
//                                 at: .zero)
//        } catch {
//            print("failed to load the second track")
//        }

        return mutableComposition
    }

    func exportComposition() {
        guard let mutableComposition = createComposition() else { return }

        // Create the export session with the composition and set the preset to the highest quality.
        guard let export = AVAssetExportSession(
            asset: mutableComposition,
            presetName: AVAssetExportPresetHighestQuality) else { return }




        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(start: .zero, duration: CMTimeAdd(firstAsset.duration, secondAsset.duration))

        // 2.2
//        let firstInstruction = VideoHelper.videoCompositionInstruction(firstTrack, asset: firstAsset)
//        firstInstruction.setOpacity(0.0, at: firstAsset.duration)
//        let secondInstruction = VideoHelper.videoCompositionInstruction(secondTrack, asset: secondAsset)

        // 2.3
//        mainInstruction.layerInstructions = [firstInstruction, secondInstruction]
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mainComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

        let uid = UUID().uuidString
        // Set the desired output URL for the file created by the export process.
        export.outputURL = buildFullPath(for: "\(uid).mov", in: .videos)
        // Set the output file type to be a QuickTime movie.
        export.outputFileType = .mov
        export.shouldOptimizeForNetworkUse = true
        export.videoComposition = mainComposition

        // Asynchronously export the composition to a video file and save this file to the camera roll once export completes.
        export.exportAsynchronously {
            DispatchQueue.main.async { [weak self] in
                self?.exportDidFinish(export)
            }
        }
    }

    func exportDidFinish(_ session: AVAssetExportSession) {
        let status = session.status
        switch status {
        case .completed:
            let outputURL = session.outputURL
            print(outputURL)
        case .failed:
            print("failed error \(session.error)")
        default:
            break
        }
    }
//
//    func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//
//        alert.addAction(okAction)
//
//        present(alert, animated: true, completion: nil)
//    }

}
