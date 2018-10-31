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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func loadAssetsNoAudioButtonTapped() {
        guard let firstURLAsset = getURLBundleContainer(for: "timeNoSound1") else { return }
        guard let secondURLAsset = getURLBundleContainer(for: "timeNoSound2") else { return }

        self.firstAsset = AVAsset(url: firstURLAsset)
        self.secondAsset = AVAsset(url: secondURLAsset)

    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        videoManager = VideoManager(firstAsset: firstAsset!,
                                    secondAsset: secondAsset!)
        videoManager?.createComposition()
    }

}

