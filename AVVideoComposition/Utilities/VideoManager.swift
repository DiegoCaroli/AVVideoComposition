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

    private func createComposition() -> AVMutableComposition? {
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

        // Get the video tracks from each asset.
        guard let firstVideoAssetTrack = firstAsset.tracks(withMediaType: .video).first else { return nil }
        guard let secondVideoAssetTrack = secondAsset.tracks(withMediaType: .video).first else { return nil }

        // Add video tracks to the composition.
        do {
            try mutableCompositionVideoTrack
                .insertTimeRange(CMTimeRange(start: .zero,
                                             duration: firstVideoAssetTrack.timeRange.duration),
                                 of: firstVideoAssetTrack,
                                 at: .zero)
        } catch {
            print("🔴 failed to load the first track")
        }

        do {
            try mutableCompositionVideoTrack
                .insertTimeRange(CMTimeRange(start: .zero,
                                             duration: secondVideoAssetTrack.timeRange.duration),
                                 of: secondVideoAssetTrack,
                                 at: firstVideoAssetTrack.timeRange.duration)
        } catch {
            print("🔴 failed to load the second track")
        }

        // Get the audio tracks from each asset.
        guard let firstAudioAssetTrack = firstAsset.tracks(withMediaType: .audio).first else { return nil }
        guard let secondAudioAssetTrack = secondAsset.tracks(withMediaType: .audio).first else { return nil }

        // Add audio track to the composition
        do  {
            try mutableCompositionAudioTrack
                .insertTimeRange(CMTimeRange(
                    start: .zero,
                    duration: firstAudioAssetTrack.timeRange.duration),
                                 of: firstAudioAssetTrack,
                                 at: .zero)
        } catch {
            print("🔴 failed to load the audio track")
        }

        do  {
            try mutableCompositionAudioTrack
                .insertTimeRange(CMTimeRange(
                    start: .zero,
                    duration: secondAudioAssetTrack.timeRange.duration),
                                 of: secondAudioAssetTrack,
                                 at: firstAudioAssetTrack.timeRange.duration)
        } catch {
            print("🔴 failed to load the audio track")
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

    private func exportDidFinish(_ session: AVAssetExportSession,
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
