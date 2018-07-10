// Copyright 2017, Ralf Ebert
// License   https://opensource.org/licenses/MIT
// Source    https://www.ralfebert.de/snippets/ios/urlsession-background-downloads/
// Modified by Andrew Liakh, 2018

import Foundation

class FileDownloader : NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
    typealias ProgressHandler = (Float) -> Void
    typealias CompletionHandler = (Bool, String?) -> Void
    
    var onProgress : ProgressHandler?
    var onCompletion : CompletionHandler?
    
    func activate() -> URLSession {
        let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
        
        // Warning: If an URLSession still exists from a previous download, it doesn't create a new URLSession object but returns the existing one with the old delegate object attached!
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    }
    
    private func calculateProgress(session : URLSession, completionHandler : @escaping (Float) -> ()) {
        session.getTasksWithCompletionHandler { (tasks, uploads, downloads) in
            let bytesReceived = downloads.map{ $0.countOfBytesReceived }.reduce(0, +)
            let bytesExpectedToReceive = downloads.map{ $0.countOfBytesExpectedToReceive }.reduce(0, +)
            let progress = bytesExpectedToReceive > 0 ? Float(bytesReceived) / Float(bytesExpectedToReceive) : 0.0
            completionHandler(progress)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        if totalBytesExpectedToWrite > 0 {
            if let onProgress = onProgress {
                calculateProgress(session: session, completionHandler: onProgress)
            }
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            debugPrint("Progress \(downloadTask) \(progress)")
            
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        debugPrint("Download finished: \(location)")
        onCompletion?(true, location.absoluteString)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        debugPrint("Task completed: \(task), error: \(error?.localizedDescription ?? "none")")
        onCompletion?(false, nil)
    }
    
}
