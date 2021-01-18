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

// FileUploader
open class FileUploader: NSObject {
    private let request: URLRequest
    private let data: Data
    private var recievedData = Data()
    public var progress: Double = 0

    private var urlSessionUploadTask: URLSessionUploadTask?

    open var progressHandler: ((Progress) -> Void)?
    open var completeHandler: ((CompleteData) -> Void)?

    public init(request: URLRequest, data: Data) {
        self.request = request
        self.data = data
    }

    @discardableResult
    open func resume(identifier: String = NSUUID().uuidString) -> FileUploader {
        let config = URLSessionConfiguration.background(withIdentifier: "\(identifier)_?t=\(Date().timeIntervalSince1970)")
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        self.urlSessionUploadTask = session.uploadTask(with: self.request, from: self.data)
        DispatchQueue.global().async {
            self.urlSessionUploadTask?.resume()
        }
        return self
    }

    @discardableResult
    open func cancel() -> FileUploader {
        self.urlSessionUploadTask?.cancel()
        return self
    }
}

// MARK: URLSessionTaskDelegate
extension FileUploader: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
            self.completeHandler?(.init(data: self.recievedData, response: task.response, error: error))
            self.completeHandler = nil
            self.progressHandler = nil
            self.recievedData = Data()
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.recievedData.append(data)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        self.progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        DispatchQueue.main.async {
            self.progressHandler?(.init(progress: self.progress, totalSize: Int(totalBytesExpectedToSend), uploadedSize: Int(totalBytesSent)))
        }
    }
}

// MARK: FileUploader + Progress
extension FileUploader {
    public struct Progress {
        public var progress: Double
        public var uploadedSize: Int
        public var totalSize: Int

        public init(progress: Double, totalSize: Int, uploadedSize: Int) {
            self.progress = progress
            self.totalSize = totalSize
            self.uploadedSize = uploadedSize
        }
    }
}

// MARK: FileUploader + CompleteData
extension FileUploader {
    public struct CompleteData {
        public var data: Data?
        public var response: URLResponse?
        public var error: Error?

        public init(data: Data?, response: URLResponse?, error: Error?) {
            self.data = data
            self.response = response
            self.error = error
        }
    }
}
