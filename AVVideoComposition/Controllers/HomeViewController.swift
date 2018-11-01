//
//  HomeViewController.swift
//  AVVideoComposition
//
//  Created by Diego Caroli on 31/10/2018.
//  Copyright © 2018 Diego Caroli. All rights reserved.
//

import UIKit
import AVKit

class HomeViewController: UIViewController, AppDirectoryNames {

    var firstAsset: AVAsset?
    var secondAsset: AVAsset?
    var videoManager: VideoManager?
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var loadButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        doneButton.isEnabled = false

//        let files = try? FileManager.default.contentsOfDirectory(atPath: videosDirectoryURL.path)
//
//        print("DIRECTORY: \(videosDirectoryURL.path)")
//        print("\n")
//        files.forEach { print("File: \($0.debugDescription)") }
    }

    @IBAction func loadAssetsNoAudioButtonTapped() {
        guard let firstURLAsset = getURLBundleContainer(for: "frame1",
                                                        withExtension: "mov") else { return }
        guard let secondURLAsset = getURLBundleContainer(for: "frame2",
                                                         withExtension: "mov") else { return }

        self.firstAsset = AVAsset(url: firstURLAsset)
        self.secondAsset = AVAsset(url: secondURLAsset)

        doneButton.isEnabled = true
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        activityIndicator.startAnimating()
        loadButton.isHidden = true

        guard let firstAsset = firstAsset,
            let secondAsset = secondAsset else {
                print("🔴 load asset before")
                return
        }

        videoManager = VideoManager(firstAsset: firstAsset,
                                    secondAsset: secondAsset)
        videoManager?.composition { [weak self] (url, error) in
            self?.activityIndicator.stopAnimating()
            self?.loadButton.isHidden = false

            guard error == nil else {
                print("🔴 error \(error!)")
                return
            }

            guard let videoPreviewVC = UIStoryboard(
                name: "Main",
                bundle: Bundle(for: HomeViewController.self))
                .instantiateViewController(
                    withIdentifier: "videoPreviewVC") as? VideoPreviewViewController else { return }

            videoPreviewVC.fileURL = url!

            self?.navigationController?
                .pushViewController(videoPreviewVC,
                                    animated: true)

        }
    }

}

