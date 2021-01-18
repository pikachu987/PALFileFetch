//
//  ViewController.swift
//  PALFileFetch
//
//  Created by pikachu987 on 01/16/2021.
//  Copyright (c) 2021 pikachu987. All rights reserved.
//

import UIKit
import PALFileFetch

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let task = BackgroundFetch.beginBackgroundTask()
        if let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") {
            let fileDownload = FileDownloader(downloadURL: url, isTempDirectory: true, folderName: "test", fileName: "ForBiggerBlazes.mp4")
            fileDownload.progressHandler = { (progress) in
                print("1 progress: \(progress.progress), progress: \(progress)")
            }
            fileDownload.completeHandler = { (response) in
                print("1: \(response)")
                task.endBackgroundTask()
            }
            fileDownload.resume()
        }
        
        let task2 = BackgroundFetch.beginBackgroundTask()
        if let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4") {
            let fileDownload = FileDownloader(downloadURL: url, isTempDirectory: true, folderName: "test", fileName: "BigBuckBunny.mp4")
            fileDownload.progressHandler = { (progress) in
                print("2 progress: \(progress.progress), progress: \(progress)")
            }
            fileDownload.completeHandler = { (response) in
                print("2: \(response)")
                task2.endBackgroundTask()
            }
            fileDownload.resume()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

