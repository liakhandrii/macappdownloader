//
//  InstallationManager.swift
//  MacAppDownloader
//
//  Created by Andrew Liakh on 7/10/18.
//  Copyright © 2018 Twopeople Software. All rights reserved.
//

import Foundation
import ZIPFoundation

/// This class handles downloading, unzipping and proper location of the app
class InstallationManager {
    
    /**
     Does everything needed to install an app using the configuration from the Config.swift
     
     - parameters:
     - progress: Gets called multiple times and indicates the percentage (0-1) and the current operation.
     - completion: Gets called once, when the installation finishes or fails.
     */
    func installApp(progress: ((Float, String) -> Void)?, completion: ((Bool) -> Void)?) {
        progress?(0, "Starting download...".localized)
        downloadAppFrom(link: Config.appZipUrl, progress: { (downloadProgress) in
            debugPrint("Download progress: \(downloadProgress * 100)")
            progress?(downloadProgress * 0.8, "Downloading...".localized)
        }) { (success, filePath) in
            if success && filePath != nil {
                debugPrint("Downloaded to: \(filePath!)")
                progress?(0.8, "Extracting...".localized)
                if let paths = self.unzip(file: filePath!) {
                    progress?(0.9, "Installing...".localized)
                    if self.move(apps: paths, toFolder: Config.installationPath) {
                        progress?(1, "Installed".localized)
                        self.launch(apps: paths)
                        completion?(true)
                    } else {
                        progress?(1, "Installation failed".localized)
                        completion?(false)
                    }
                } else {
                    progress?(1, "Extracting failed".localized)
                    completion?(false)
                }
            } else {
                progress?(1, "Download failed".localized)
                completion?(false)
            }
        }
    }
    
    /**
     Downloads an archive with the app into a temporary folder.
     
     - parameters:
        - progress: Gets called multiple times and indicates the percentage of the operation (0-1).
        - link: An absolute web url of the .zip package.
        - completion: A string with an absolute path to a downloaded file.
     */
    private func downloadAppFrom(link: String, progress: @escaping ((Float) -> Void), completion: @escaping ((Bool, String?) -> Void)) {
        let url = URL(string: Config.appZipUrl)!
        let downloader = FileDownloader()
        downloader.onProgress = progress
        downloader.onCompletion = completion
        downloader.download(file: url.absoluteString)
    }
    
    /**
     Unzips the contents of the .zip package
     
     - parameters:
        - file: An absolute local path of a .zip package.
     
     - returns:
     Absolute local paths to all .app packages that were present in the original .zip.
     */
    private func unzip(file: String) -> [String]? {
        let fileManager = FileManager()
        let fileURL = URL(string: file)!
        let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("unzipped_files")
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: fileURL, to: destinationURL)
            
            let contents = try fileManager.contentsOfDirectory(atPath: destinationURL.path)
            
            var appFiles = [String]()
            for file in contents {
                if file.hasSuffix(".app") {
                    appFiles.append(destinationURL.appendingPathComponent(file).path)
                }
            }
            return appFiles
        } catch let error {
            debugPrint("Unzipping error: \(error.localizedDescription)")
            return nil
        }
    }
    
    /**
     Moves all the specified .app packages to a desired folder
     
     - parameters:
        - apps: Absolute local paths to all .app packages.
        - folder: An absolute local path to a desired installation folder
     
     - returns:
     A boolean value indicationg if the installation was successful
     */
    private func move(apps: [String], toFolder folder: String) -> Bool {
        let fileManager = FileManager()
        do {
            for appPath in apps {
                if let appUrl = URL(string: appPath),
                    let folderUrl = URL(string: folder) {
                    let destination = folderUrl.appendingPathComponent(appUrl.lastPathComponent)
                    if fileManager.fileExists(atPath: destination.path) {
                        try fileManager.removeItem(at: destination)
                    }
                }
                try fileManager.moveItem(atPath: appPath, toPath: folder)
            }
            return true
        } catch let error {
            debugPrint("Files placing error: \(error.localizedDescription)")
            return false
        }
    }
    
    /**
     Launches all the apps, though it's would probably be better to launch only one.
     
     - parameters:
     - apps: Absolute local paths to all .app packages. Only the last path component is used from each one.
     */
    private func launch(apps: [String]) {
        for app in apps {
            let installationFolder = URL(string: Config.installationPath)!
            let appUrl = URL(string: app)!
            
            NSWorkspace.shared.open(installationFolder.appendingPathComponent(appUrl.lastPathComponent))
        }
    }
    
}
