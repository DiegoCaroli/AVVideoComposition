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
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        playerLayer = AVPlayerLayer()
        playerLayer.frame = view.bounds

        player = AVPlayer(url: fileURL)

        player.actionAtItemEnd = .none
        playerLayer.player = player
        view.layer.addSublayer(playerLayer)

        player.play()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        playerLayer.frame = view.bounds
    }

}
