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

import UIKit

open class BackgroundFetch: NSObject {
    public static let shared = BackgroundFetch()
    open var taskList = [BackgroundTask]()

    private override init() {
        super.init()
    }
    
    @discardableResult
    open class func beginBackgroundTask(_ callback: ((BackgroundTask) -> Void)? = nil) -> BackgroundTask {
        return BackgroundFetch.shared.beginBackgroundTask(callback)
    }

    open class func endAllBackgroundTask() {
        BackgroundFetch.shared.endAllBackgroundTask()
    }
    
    open class func endBackgroundTask(task: BackgroundTask) {
        BackgroundFetch.shared.endBackgroundTask(task: task)
    }
    
    open class func endBackgroundTask(identifier: UIBackgroundTaskIdentifier) {
        BackgroundFetch.shared.endBackgroundTask(identifier: identifier)
    }

    @discardableResult
    open func beginBackgroundTask(_ callback: ((BackgroundTask) -> Void)? = nil) -> BackgroundTask {
        var identifier = UIBackgroundTaskIdentifier.invalid
        identifier = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask(identifier: identifier)
        }
        let task = BackgroundTask(identifier: identifier)
        self.taskList.append(task)
        callback?(task)
        return task
    }
    
    open func endAllBackgroundTask() {
        let identifiers = self.taskList
        self.taskList.removeAll()
        identifiers.forEach({ UIApplication.shared.endBackgroundTask($0.identifier) })
    }
    
    open func endBackgroundTask(task: BackgroundTask) {
        if let index = self.taskList.firstIndex(where: { $0.identifier == task.identifier }) {
            self.taskList.remove(at: index)
        }
        UIApplication.shared.endBackgroundTask(task.identifier)
    }
    
    open func endBackgroundTask(identifier: UIBackgroundTaskIdentifier) {
        if let index = self.taskList.firstIndex(where: { $0.identifier == identifier }) {
            self.taskList.remove(at: index)
        }
        UIApplication.shared.endBackgroundTask(identifier)
    }
}

extension UIBackgroundTaskIdentifier {
    public func endBackgroundTask() {
        BackgroundFetch.shared.endBackgroundTask(identifier: self)
    }
}
