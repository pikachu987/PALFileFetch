//Copyright (c) 2021 pikachu987 <pikachu77769@gmail.com>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

import Foundation

// FileDownloader
open class FileDownloader: NSObject {
    private let downloadURL: URL
    private let folderName: String
    private let fileName: String
    private let saveURL: URL
    public var progress: Double = 0

    private var urlSessionDownloadTask: URLSessionDownloadTask?

    open var progressHandler: ((Progress) -> Void)?
    open var completeHandler: ((CompleteData) -> Void)?

    public init(downloadURL: URL, isTempDirectory: Bool = false, folderName: String, fileName: String) {
        self.downloadURL = downloadURL
        self.folderName = folderName
        self.fileName = fileName

        var saveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if isTempDirectory {
            if #available(iOS 10.0, *) {
                saveURL = FileManager.default.temporaryDirectory
            } else {
                saveURL = URL(string: NSTemporaryDirectory())!
            }
        }
        if folderName != "" && fileName != "" {
            saveURL.appendPathComponent("\(self.folderName)/\(self.fileName)")
        }
        self.saveURL = saveURL
    }

    @discardableResult
    open func resume(identifier: String = NSUUID().uuidString) -> FileDownloader {
        let config = URLSessionConfiguration.background(withIdentifier: "\(identifier)_\(self.downloadURL.absoluteString)?t=\(Date().timeIntervalSince1970)")
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        self.urlSessionDownloadTask = session.downloadTask(with: self.downloadURL)
        DispatchQueue.global().async {
            self.urlSessionDownloadTask?.resume()
        }
        return self
    }

    @discardableResult
    open func cancel() -> FileDownloader {
        self.urlSessionDownloadTask?.cancel()
        return self
    }
}

// MARK: URLSessionDownloadDelegate
extension FileDownloader: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        try? FileManager.default.moveItem(at: location, to: self.saveURL)
        DispatchQueue.main.async {
            self.completeHandler?(.init(url: self.saveURL, error: nil))
            self.completeHandler = nil
            self.progressHandler = nil
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.progressHandler?(.init(progress: self.progress, totalSize: Int(totalBytesExpectedToWrite), downloadedSize: Int(totalBytesWritten)))
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
            self.completeHandler?(.init(url: nil, error: error))
            self.completeHandler = nil
            self.progressHandler = nil
        }
    }
}

// MARK: FileDownloader + Progress
extension FileDownloader {
    public struct Progress {
        public var progress: Double
        public var downloadedSize: Int
        public var totalSize: Int

        public init(progress: Double, totalSize: Int, downloadedSize: Int) {
            self.progress = progress
            self.totalSize = totalSize
            self.downloadedSize = downloadedSize
        }
    }
}


// MARK: FileDownloader + CompleteData
extension FileDownloader {
    public struct CompleteData {
        public var url: URL?
        public var error: Error?

        public init(url: URL?, error: Error?) {
            self.url = url
            self.error = error
        }
    }
}
