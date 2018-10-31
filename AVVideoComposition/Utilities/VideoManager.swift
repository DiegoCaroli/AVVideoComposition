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


    @IBAction func merge(_ sender: AnyObject) {


//        // 3 - Audio track
//        if let loadedAudioAsset = audioAsset {
//            let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: 0)
//            do {
//                try audioTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration)),
//                                                of: loadedAudioAsset.tracks(withMediaType: .audio)[0] ,
//                                                at: kCMTimeZero)
//            } catch {
//                print("Failed to load Audio track")
//            }
//        }
//
//        // 4 - Get path
//        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .long
//        dateFormatter.timeStyle = .short
//        let date = dateFormatter.string(from: Date())
//        let url = documentDirectory.appendingPathComponent("mergeVideo-\(date).mov")
//
//        // 5 - Create Exporter
//        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
//        exporter.outputURL = url
//        exporter.outputFileType = AVFileType.mov
//        exporter.shouldOptimizeForNetworkUse = true
//        exporter.videoComposition = mainComposition
//
//        // 6 - Perform the Export
//        exporter.exportAsynchronously() {
//            DispatchQueue.main.async {
//                self.exportDidFinish(exporter)
//            }
//        }
    }

    func createComposition() -> AVMutableComposition? {
        let mutableComposition = AVMutableComposition()

        // Create the video composition track.
        guard let mutableCompositionVideoTrack = mutableComposition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid) else { return nil }

//        // Create the audio composition track.
//        guard let mutableCompositionAudioTrack = mutableComposition.addMutableTrack(
//            withMediaType: .audio,
//            preferredTrackID: kCMPersistentTrackID_Invalid) else { return nil }


        //Adding Audiovisual Data

        // Get the first video track from each asset.
        guard let firstAssetTrack = firstAsset.tracks(withMediaType: .video).first else { return nil }
        guard let secondAssetTrack = secondAsset.tracks(withMediaType: .video).first else { return nil }

        // Add them both to the composition.
        do {
            try mutableCompositionVideoTrack
                .insertTimeRange(CMTimeRange(start: .zero,
                                             duration: firstAssetTrack.timeRange.duration),
                                 of: firstAssetTrack,
                                 at: .zero)
        } catch {
            print("🔴 failed to load the first track")
        }

        do {
            try mutableCompositionVideoTrack
                .insertTimeRange(CMTimeRange(start: .zero,
                                             duration: secondAssetTrack.timeRange.duration),
                                 of: secondAssetTrack,
                                 at: firstAssetTrack.timeRange.duration)
        } catch {
            print("🔴 failed to load the second track")
        }

        return mutableComposition
    }

    func exportComposition(completion: @escaping ((URL?, Error?) -> ())) {
        guard let mutableComposition = createComposition() else { return }

        // Create the export session with the composition and set the preset to the highest quality.
        guard let exporter = AVAssetExportSession(
            asset: mutableComposition,
            presetName: AVAssetExportPresetHighestQuality) else { return }

        let uid = UUID().uuidString

        // Set the desired output URL for the file created by the export process.
        exporter.outputURL = documentsDirectoryURL.appendingPathComponent("\(uid).mov")
        // Set the output file type to be a QuickTime movie.
        exporter.outputFileType = .mov
        exporter.shouldOptimizeForNetworkUse = true
//        export.videoComposition = mainComposition

        // Asynchronously export the composition to a video file and save this file to the camera roll once export completes.
        exporter.exportAsynchronously {
            DispatchQueue.main.async { [weak self] in
                self?.exportDidFinish(exporter, completion: completion)
            }
        }
    }

    func exportDidFinish(_ session: AVAssetExportSession,
                         completion: @escaping ((URL?, Error?) -> ())) {
        let status = session.status
        switch status {
        case .completed:
            let outputURL = session.outputURL
            completion(outputURL, nil)
        case .failed:
            completion(nil, session.error)
        default:
            break
        }
    }

}
