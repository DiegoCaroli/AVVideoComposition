//
//  FileSystemManager.swift
//  AVVideoComposition
//
//  Created by Diego Caroli on 31/10/2018.
//  Copyright © 2018 Diego Caroli. All rights reserved.
//

import Foundation

enum AppDirectories: String {
    case documents = "Documents"
    case videos = "Videos"
}

protocol AppDirectoryNames {
    var fileManager: FileManager { get }
    var documentsDirectoryURL: URL { get }
    var videosDirectoryURL: URL { get }
    func getURL(for directory: AppDirectories) -> URL
    func buildFullPath(for fileName: String, in directory: AppDirectories) -> URL
    func getURLBundleContainer(for fileName: String) -> URL?
}

extension AppDirectoryNames {
    var fileManager: FileManager {
        return FileManager.default
    }

    var documentsDirectoryURL: URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    var videosDirectoryURL: URL {
        return documentsDirectoryURL.appendingPathComponent(AppDirectories.videos.rawValue)
    }

    func getURL(for directory: AppDirectories) -> URL {
        return videosDirectoryURL
    }

    func buildFullPath(for fileName: String, in directory: AppDirectories) -> URL {
        return getURL(for: .videos).appendingPathComponent(fileName)
    }

    func getURLBundleContainer(for fileName: String) -> URL? {
        let bundle = Bundle(for: VideoManager.self)
        return bundle.url(forResource: fileName, withExtension: "mov")
    }

}
