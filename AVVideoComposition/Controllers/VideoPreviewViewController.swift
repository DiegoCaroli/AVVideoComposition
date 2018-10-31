//
//  VideoPreviewViewController.swift
//  AVVideoComposition
//
//  Created by Diego Caroli on 31/10/2018.
//  Copyright © 2018 Diego Caroli. All rights reserved.
//

import UIKit
import AVKit

class VideoPreviewViewController: UIViewController {

    var fileURL: URL!
    var playerLayer: AVPlayerLayer!
    var playerLooper: AVPlayerLooper!

    override func viewDidLoad() {
        super.viewDidLoad()

        let playerItem = AVPlayerItem(url: fileURL)
        let queuePlayer = AVQueuePlayer(items: [playerItem])
        playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLooper = AVPlayerLooper(player: queuePlayer,
                                      templateItem: playerItem)

        view.layer.addSublayer(playerLayer)
        playerLayer.frame = view.bounds
        queuePlayer.play()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        playerLayer.frame = view.bounds
    }

}
