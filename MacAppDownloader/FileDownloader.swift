//
//  InstallationManager.swift
//  MacAppDownloader
//
//  Created by Andrew Liakh on 7/10/18.
//  Copyright © 2018 Twopeople Software. All rights reserved.
//

import Foundation
import Alamofire

class FileDownloader {
    
    typealias ProgressHandler = (Float) -> Void
    typealias CompletionHandler = (Bool, String?) -> Void
    
    var onProgress : ProgressHandler?
    var onCompletion : CompletionHandler?
    
    func download(file: String) {
        let path = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(Bundle.main.bundleIdentifier!).appendingPathComponent("package.zip")
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (path, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        let utilityQueue = DispatchQueue.global(qos: .utility)
        
        Alamofire.download(file, to: destination)
            .downloadProgress(queue: utilityQueue) { progress in
                self.onProgress?(Float(progress.fractionCompleted))
            }
            .responseData { response in
                if response.error == nil {
                    self.onCompletion?(true, path.absoluteString)
                } else {
                    self.onCompletion?(false, nil)
                }
        }
    }
    
}
