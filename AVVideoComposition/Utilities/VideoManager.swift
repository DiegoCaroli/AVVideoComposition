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
    var videoComposition: AVMutableVideoComposition!

    init(firstAsset: AVAsset, secondAsset: AVAsset) {
        self.firstAsset = firstAsset
        self.secondAsset = secondAsset
    }

    func composition(completion: @escaping ((URL?, Error?) -> ())) {
        let mutableComposition = AVMutableComposition()

        // Create the video composition track.
        guard let mutableCompositionVideoTrack = mutableComposition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid) else { return }

        // Create the audio composition track.
        guard let mutableCompositionAudioTrack = mutableComposition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid) else { return }

         // Add first video track to the composition.
        guard let firstVideoAssetTrack = firstAsset.tracks(withMediaType: .video).first else { return }
        addAudiovisualData(mutableCompositionTrack: mutableCompositionVideoTrack,
                           start: .zero,
                           duration: firstVideoAssetTrack.timeRange.duration,
                           track: firstVideoAssetTrack,
                           startTime: .zero)

        // Add second video track to the composition.
        guard let secondVideoAssetTrack = secondAsset.tracks(withMediaType: .video).first else { return }
        addAudiovisualData(mutableCompositionTrack: mutableCompositionVideoTrack,
                           start: .zero,
                           duration: secondVideoAssetTrack.timeRange.duration,
                           track: secondVideoAssetTrack,
                           startTime: firstVideoAssetTrack.timeRange.duration)

        // Add first audio track to the composition.
        guard let firstAudioAssetTrack = firstAsset.tracks(withMediaType: .audio).first else { return }
        addAudiovisualData(mutableCompositionTrack: mutableCompositionAudioTrack,
                           start: .zero,
                           duration: firstAudioAssetTrack.timeRange.duration,
                           track: firstAudioAssetTrack,
                           startTime: .zero)

        // Add second video track to the composition.
        guard let secondAudioAssetTrack = secondAsset.tracks(withMediaType: .audio).first else { return }
        addAudiovisualData(mutableCompositionTrack: mutableCompositionAudioTrack,
                           start: .zero,
                           duration: secondAudioAssetTrack.timeRange.duration,
                           track: secondAudioAssetTrack,
                           startTime: firstAudioAssetTrack.timeRange.duration)

        exportComposition(mutableComposition: mutableComposition, completion: completion)
    }

    //Adding Audiovisual Data
    private func addAudiovisualData(mutableCompositionTrack: AVMutableCompositionTrack,
                            start: CMTime,
                            duration: CMTime,
                            track: AVAssetTrack,
                            startTime: CMTime) {
        do  {
            try mutableCompositionTrack
                .insertTimeRange(CMTimeRange(
                    start: start,
                    duration: duration),
                                 of: track,
                                 at: startTime)
        } catch {
            print("🔴 failed to load the track")
        }
    }

    private func exportComposition(mutableComposition: AVMutableComposition,
                           completion: @escaping ((URL?, Error?) -> ())) {
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
        #warning("doesn't work for the moment")
//        exporter.videoComposition = self.videoComposition

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


    // Applying the Video Composition Layer Instructions
    // Once you know the video segments have compatible orientations, you can apply the necessary layer instructions to each one and add these layer instructions to the video composition.

    private func videoCompositionLayerInstructions() ->  AVMutableVideoComposition {
         guard let firstVideoAssetTrack = firstAsset.tracks(withMediaType: .video).first else { fatalError() }
         guard let secondVideoAssetTrack = secondAsset.tracks(withMediaType: .video).first else { fatalError() }

         // Set the time range of the first instruction to span the duration of the first video track.
//        let firstVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
//        firstVideoCompositionInstruction.timeRange = CMTimeRange(start: .zero, duration: firstVideoAssetTrack.timeRange.duration)

        // Set the time range of the second instruction to span the duration of the second video track.
//        let secondVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
//        secondVideoCompositionInstruction.timeRange = CMTimeRange(start: firstVideoCompositionInstruction.timeRange.duration, duration: CMTimeAdd(firstVideoAssetTrack.timeRange.duration, secondVideoAssetTrack.timeRange.duration))

//        // Set the transform of the first layer instruction to the preferred transform of the first video track.
//        let firstVideoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: firstVideoAssetTrack)
//        firstVideoLayerInstruction.setTransform(firstVideoAssetTrack.preferredTransform, at: .zero)
//
//        // Set the transform of the second layer instruction to the preferred transform of the second video track.
//        let secondVideoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: secondVideoAssetTrack)
//        secondVideoLayerInstruction.setTransform(secondVideoAssetTrack.preferredTransform, at: firstVideoAssetTrack.timeRange.duration)
//
//        firstVideoCompositionInstruction.layerInstructions = [firstVideoLayerInstruction]
//        secondVideoCompositionInstruction.layerInstructions = [secondVideoLayerInstruction]
//
        let mutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.instructions = []
//            firstVideoCompositionInstruction,
//            secondVideoCompositionInstruction
//        ]

        setupRenderSizeAndFrameDuration(firstVideoAssetTrack: firstVideoAssetTrack,
                                        secondVideoAssetTrack: secondVideoAssetTrack,
                                        mutableVideoComposition: mutableVideoComposition)

        return mutableVideoComposition
    }

    // Setting the Render Size and Frame Duration
    private func setupRenderSizeAndFrameDuration(firstVideoAssetTrack: AVAssetTrack,
                                                 secondVideoAssetTrack: AVAssetTrack,
                                                 mutableVideoComposition: AVMutableVideoComposition) {
        var naturalSizeFirst: CGSize
        var naturalSizeSecond: CGSize

         // If the first video asset was shot in portrait mode, then so was the second one if we made it here.
        guard let isFirstVideoAssetPortrait = checkingVideoAssetsPortraitOrientation(firstVideoAssetTrack: firstVideoAssetTrack,
                                                         secondVideoAssetTrack: secondVideoAssetTrack) else { return }

        if isFirstVideoAssetPortrait {
            // Invert the width and height for the video tracks to ensure that they display properly.
            naturalSizeFirst = CGSize(width: firstVideoAssetTrack.naturalSize.height,
                                      height: firstVideoAssetTrack.naturalSize.width)
            naturalSizeSecond = CGSize(width: secondVideoAssetTrack.naturalSize.height,
                                       height: secondVideoAssetTrack.naturalSize.width);
        } else {
            // If the videos weren't shot in portrait mode, we can just use their natural sizes.
            naturalSizeFirst = firstVideoAssetTrack.naturalSize
            naturalSizeSecond = secondVideoAssetTrack.naturalSize
        }
        var renderWidth: CGFloat
        var renderHeight: CGFloat

        // Set the renderWidth and renderHeight to the max of the two videos widths and heights.
        if naturalSizeFirst.width > naturalSizeSecond.width {
            renderWidth = naturalSizeFirst.width
        } else {
            renderWidth = naturalSizeSecond.width
        }

        if naturalSizeFirst.height > naturalSizeSecond.height {
            renderHeight = naturalSizeFirst.height
        } else {
            renderHeight = naturalSizeSecond.height
        }

        mutableVideoComposition.renderSize = CGSize(width: renderWidth, height: renderHeight)
        // Set the frame duration to an appropriate value (i.e. 30 frames per second for video).
        mutableVideoComposition.frameDuration = CMTime(value: 1, timescale: 30)
    }

    // Checking the Video Orientations must be both in the same orientation
    private func checkingVideoAssetsPortraitOrientation(firstVideoAssetTrack: AVAssetTrack,
                                                        secondVideoAssetTrack: AVAssetTrack) -> Bool? {
        var isFirstVideoAssetPortrait = false
        let firstTransform = firstVideoAssetTrack.preferredTransform

        if (firstTransform.a == 0 && firstTransform.d == 0 && (firstTransform.b == 1.0 || firstTransform.b == -1.0) && (firstTransform.c == 1.0 || firstTransform.c == -1.0)) {
            isFirstVideoAssetPortrait = true
        }

        var isSecondVideoAssetPortrait = false
        let secondTransform = secondVideoAssetTrack.preferredTransform

        if (secondTransform.a == 0 && secondTransform.d == 0 && (secondTransform.b == 1.0 || secondTransform.b == -1.0) && (secondTransform.c == 1.0 || secondTransform.c == -1.0)) {
            isSecondVideoAssetPortrait = true
        }

        if ((isFirstVideoAssetPortrait && !isSecondVideoAssetPortrait) || (!isFirstVideoAssetPortrait && isSecondVideoAssetPortrait)) {
            return nil
        } else if (isFirstVideoAssetPortrait && isSecondVideoAssetPortrait) {
            return true
        } else {
            return false
        }
    }

}
