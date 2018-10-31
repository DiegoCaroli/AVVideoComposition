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
        guard let firstVideoAssetTrack = firstAsset
            .tracks(withMediaType: .video).first else { return }
        addAudiovisualData(mutableCompositionTrack: mutableCompositionVideoTrack,
                           start: .zero,
                           duration: firstVideoAssetTrack.timeRange.duration,
                           track: firstVideoAssetTrack,
                           startTime: .zero)

        // Add second video track to the composition.
        guard let secondVideoAssetTrack = secondAsset
            .tracks(withMediaType: .video).first else { return }
        addAudiovisualData(mutableCompositionTrack: mutableCompositionVideoTrack,
                           start: .zero,
                           duration: secondVideoAssetTrack.timeRange.duration,
                           track: secondVideoAssetTrack,
                           startTime: firstVideoAssetTrack.timeRange.duration)

        // Applying the Video Composition Layer Instructions
        let mutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        mutableVideoCompositionInstruction.timeRange = CMTimeRange(
            start: CMTime.zero,
            duration: CMTimeAdd(firstVideoAssetTrack.timeRange.duration,
                                secondVideoAssetTrack.timeRange.duration))
        // setup a backgroud to see if I have left empy frame
        mutableVideoCompositionInstruction.backgroundColor = UIColor.orange.cgColor

        let firstInstruction = videoCompositionLayerInstruction(
            mutableCompositionVideoTrack,
            asset: firstAsset)
        firstInstruction.setOpacity(0.0, at: firstAsset.duration)
        let secondInstruction = videoCompositionLayerInstruction(
            mutableCompositionVideoTrack,
            asset: secondAsset)

        mutableVideoCompositionInstruction.layerInstructions = [
            firstInstruction,
            secondInstruction
        ]

        let videoComposition = AVMutableVideoComposition()
        videoComposition.instructions = [mutableVideoCompositionInstruction]
         // Set the frame duration to an appropriate value (i.e. 30 frames per second for video).
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComposition.renderSize = setupRenderSize(
            firstVideoAssetTrack: firstVideoAssetTrack,
            secondVideoAssetTrack: secondVideoAssetTrack)
        applyWatermark(mutableVideoComposition: videoComposition,
                       text: "bar")

        // Add first audio track to the composition.
        guard let firstAudioAssetTrack = firstAsset
            .tracks(withMediaType: .audio).first else { return }
        addAudiovisualData(mutableCompositionTrack: mutableCompositionAudioTrack,
                           start: .zero,
                           duration: firstAudioAssetTrack.timeRange.duration,
                           track: firstAudioAssetTrack,
                           startTime: .zero)

        // Add second video track to the composition.
        guard let secondAudioAssetTrack = secondAsset
            .tracks(withMediaType: .audio).first else { return }
        addAudiovisualData(mutableCompositionTrack: mutableCompositionAudioTrack,
                           start: .zero,
                           duration: secondAudioAssetTrack.timeRange.duration,
                           track: secondAudioAssetTrack,
                           startTime: firstAudioAssetTrack.timeRange.duration)

        exportComposition(mutableComposition: mutableComposition,
                          videoComposition: videoComposition,
                          completion: completion)
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
                                   videoComposition: AVMutableVideoComposition,
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
        exporter.videoComposition = videoComposition

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
    private func videoCompositionLayerInstruction(
        _ track: AVCompositionTrack,
        asset: AVAsset) ->  AVMutableVideoCompositionLayerInstruction {
        // Set the transform of the layer instruction to the preferred transform of the video track.
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        layerInstruction.setTransform(assetTrack.preferredTransform, at: .zero)

        return layerInstruction
    }

    // Setting the Render Size
    private func setupRenderSize(firstVideoAssetTrack: AVAssetTrack,
                                 secondVideoAssetTrack: AVAssetTrack) -> CGSize {
        var naturalSizeFirst: CGSize
        var naturalSizeSecond: CGSize

         // If the first video asset was shot in portrait mode, then so was the second one if we made it here.
        guard let isFirstVideoAssetPortrait = checkingVideoAssetsPortraitOrientation(
            firstVideoAssetTrack: firstVideoAssetTrack,
            secondVideoAssetTrack: secondVideoAssetTrack) else { return .zero }

        if isFirstVideoAssetPortrait {
            // Invert the width and height for the video tracks to ensure that they display properly.
            naturalSizeFirst = CGSize(width: firstVideoAssetTrack.naturalSize.height,
                                      height: firstVideoAssetTrack.naturalSize.width)
            naturalSizeSecond = CGSize(width: secondVideoAssetTrack.naturalSize.height,
                                       height: secondVideoAssetTrack.naturalSize.width)
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

        return CGSize(width: renderWidth, height: renderHeight)
    }

    // Checking the Video Orientations must be both in the same orientation
    private func checkingVideoAssetsPortraitOrientation(
        firstVideoAssetTrack: AVAssetTrack,
        secondVideoAssetTrack: AVAssetTrack) -> Bool? {
        var isFirstVideoAssetPortrait = false
        let firstTransform = firstVideoAssetTrack.preferredTransform

        if (firstTransform.a == 0 && firstTransform.d == 0 && (firstTransform.b == 1.0 || firstTransform.b == -1.0) && (firstTransform.c == 1.0 || firstTransform.c == -1.0)) {
            isFirstVideoAssetPortrait = true
        }

        var isSecondVideoAssetPortrait = false
        let secondTransform = secondVideoAssetTrack.preferredTransform

        if (secondTransform.a == 0 && secondTransform.d == 0 &&
            (secondTransform.b == 1.0 || secondTransform.b == -1.0) &&
            (secondTransform.c == 1.0 || secondTransform.c == -1.0)) {
            isSecondVideoAssetPortrait = true
        }

        if ((isFirstVideoAssetPortrait && !isSecondVideoAssetPortrait) ||
            (!isFirstVideoAssetPortrait && isSecondVideoAssetPortrait)) {
            return nil
        } else if (isFirstVideoAssetPortrait && isSecondVideoAssetPortrait) {
            return true
        } else {
            return false
        }
    }

    // Add watermark
    private func applyWatermark(mutableVideoComposition: AVMutableVideoComposition,
                                text: String) {
        let parentLayer = CALayer()
        let videoLayer = CALayer()

        parentLayer.frame = CGRect(x: 0,
                                   y: 0,
                                   width: mutableVideoComposition.renderSize.width,
                                   height: mutableVideoComposition.renderSize.height)

        videoLayer.frame = CGRect(x: 0,
                                   y: 0,
                                   width: mutableVideoComposition.renderSize.width,
                                   height: mutableVideoComposition.renderSize.height)
        parentLayer.addSublayer(videoLayer)

        let textLayer = CATextLayer()
        textLayer.foregroundColor = UIColor.cyan.cgColor
        textLayer.string = text
        textLayer.font = "Helvetica" as CFTypeRef
        textLayer.fontSize = 30
        textLayer.alignmentMode = .center
        textLayer.frame = CGRect(x: mutableVideoComposition.renderSize.width / 8,
                                 y: mutableVideoComposition.renderSize.height / 2,
                                 width: 200,
                                 height: 50)
        parentLayer.addSublayer(textLayer)

        mutableVideoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            in: parentLayer)
    }

}
