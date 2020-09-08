//
//  ConvoDownloadViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 9/1/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit

class ConvoDownloadViewController: UIViewController {

    @IBOutlet weak var contentFromServerLabel: UILabel!
    @IBOutlet weak var downloadVideosButton: UIButton!
    @IBOutlet weak var downloadProgressLabel: UILabel!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    @IBOutlet weak var pauseDownloadButton: UIButton!
    
    var canContinue: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var _isIPhone: Bool = true
        if UIDevice.current.userInterfaceIdiom == .pad {
            _isIPhone = false
        }
        
        if (_isIPhone) {
            contentFromServerLabel.font = .systemFont(ofSize: 24)
            downloadVideosButton.titleLabel?.font = .systemFont(ofSize: 17)
            downloadVideosButton.layer.cornerRadius = 5;
            downloadVideosButton.layer.masksToBounds = true;
        } else {
            contentFromServerLabel.font = .systemFont(ofSize: 36)
            downloadVideosButton.titleLabel?.font = .systemFont(ofSize: 27)
            downloadVideosButton.layer.cornerRadius = 15;
            downloadVideosButton.layer.masksToBounds = true;
        }
        
    }
    
    @IBAction func pauseDownloadButtonAction(_ sender: Any) {
        
        canContinue = false
        if let parent = self.parent as? ConversationsViewController {
            parent.closeDownloadScreen()
        }
        
    }
    
    @IBAction func downloadVideosButtonTouchDown(_ sender: Any) {
        
        canContinue = true
        if Reachability.isConnectedToNetwork() { 
            _downloadManifest()
        } else {
            let alertController = UIAlertController(title: "No Connection", message: "Your device does not appear to have an Internet connection. Please establish a connection and try again.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                print("Ok button tapped");
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)
        }
        
    }
    
    func _downloadManifest() {
        
        downloadProgressLabel.text = "Downloading manifest"
        downloadProgressView.setProgress(0.0, animated: false)
        downloadVideosButton.isEnabled = false
        _cleanupVideosFolder()
        
        print("Downloading manifest...")
        let url = URL(string: "https://craigdietrich.com/tmp/feeds/videos/manifest.json")!
        let downloadTask = URLSession.shared.downloadTask(with: url) {
            urlOrNil, responseOrNil, errorOrNil in
            guard let fileURL = urlOrNil else { return }
            do {
                let documentsURL = try FileManager.default.url(for: .documentDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false)
                let videosFolderURL = documentsURL.appendingPathComponent("videos")
                if !FileManager.default.fileExists(atPath: videosFolderURL.path) {
                    try FileManager.default.createDirectory(at: videosFolderURL, withIntermediateDirectories: true, attributes: nil)
                }
                let manifestURL = videosFolderURL.appendingPathComponent("manifest.json")
                try FileManager.default.moveItem(at: fileURL, to: manifestURL)
                DispatchQueue.main.async {
                    do {
                        let data = try Data(contentsOf: URL(fileURLWithPath: manifestURL.path), options: .mappedIfSafe)
                        let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                        if let jsonResult = jsonResult as? Array<Dictionary<String,String>> {
                            DispatchQueue.main.async {
                                print("Downloaded manifest.")
                                self._downloadThumbnail(articles: jsonResult, row: 0)
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            } catch {
                print ("file error: \(error)")
            }
        }
        downloadTask.resume()
        
    }
    
    func _downloadThumbnail(articles:Array<Dictionary<String,String>>, row:Int) {
        
        if (row >= articles.count) {
            _finishDownloadVideos()
            return
        }
        if (!canContinue) {
            return
        }
        downloadProgressLabel.text = "Downloading thumbnail " + String(row + 1) + "/" + String(articles.count)
        downloadProgressView.setProgress((Float(row) + 1.0) / Float(articles.count), animated: false)
        
        // Get filename from JSON
        let article = articles[row]
        let thumbnailFilename: String = article["thumbnail_filename"]!
        let urlString:String = "https://craigdietrich.com/tmp/feeds/videos/" + thumbnailFilename
        print("Attempting to download: " + urlString)
        
        // Check to see if it esists in the filesystem already
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let videosUrl = URL(fileURLWithPath: documentPath + "/videos")
        let filePath = videosUrl.appendingPathComponent(thumbnailFilename).path
        if FileManager.default.fileExists(atPath: filePath) {
            print("File already exists")
            _downloadVideo(articles: articles, row: row)
            return
        }
        
        // Go out and get the file
        let url = URL(string: urlString)!
        let downloadTask = URLSession.shared.downloadTask(with: url) {
            urlOrNil, responseOrNil, errorOrNil in
            guard let fileURL = urlOrNil else { return }
            do {
                let documentsURL = try FileManager.default.url(for: .documentDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false)
                let videosFolderURL = documentsURL.appendingPathComponent("videos")
                if !FileManager.default.fileExists(atPath: videosFolderURL.path) {
                    try FileManager.default.createDirectory(at: videosFolderURL, withIntermediateDirectories: true, attributes: nil)
                }
                let destinationUrl = videosFolderURL.appendingPathComponent(thumbnailFilename)
                try FileManager.default.moveItem(at: fileURL, to: destinationUrl)
                DispatchQueue.main.async {
                    self._downloadVideo(articles: articles, row: row)
                }
            } catch {
                print ("file error: \(error)")
                self._downloadVideo(articles: articles, row: row)
            }
        }
        downloadTask.resume()
        
    }
    
    func _downloadVideo(articles:Array<Dictionary<String,String>>, row:Int) {
        
        if (row >= articles.count) {
            _finishDownloadVideos()
            return
        }
        if (!canContinue) {
            return
        }
        downloadProgressLabel.text = "Downloading video " + String(row + 1) + "/" + String(articles.count)
        downloadProgressView.setProgress((Float(row) + 1.0) / Float(articles.count), animated: false)
        
        // Get filename from JSON
        let article = articles[row]
        let videoFilename: String = article["mp4_filename"]!
        let urlString:String = "https://craigdietrich.com/tmp/feeds/videos/" + videoFilename
        print("Attempting to download: " + urlString)
        
        // Check to see if it esists in the filesystem already
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let videosUrl = URL(fileURLWithPath: documentPath + "/videos")
        let filePath = videosUrl.appendingPathComponent(videoFilename).path
        if FileManager.default.fileExists(atPath: filePath) {
            print("File already exists")
            _downloadThumbnail(articles: articles, row: row + 1)
            return
        }
        
        // Go out and get the file
        let url = URL(string: urlString)!
        let downloadTask = URLSession.shared.downloadTask(with: url) {
            urlOrNil, responseOrNil, errorOrNil in
            guard let fileURL = urlOrNil else { return }
            do {
                let documentsURL = try FileManager.default.url(for: .documentDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false)
                let videosFolderURL = documentsURL.appendingPathComponent("videos")
                if !FileManager.default.fileExists(atPath: videosFolderURL.path) {
                    try FileManager.default.createDirectory(at: videosFolderURL, withIntermediateDirectories: true, attributes: nil)
                }
                let destinationUrl = videosFolderURL.appendingPathComponent(videoFilename)
                try FileManager.default.moveItem(at: fileURL, to: destinationUrl)
                DispatchQueue.main.async {
                    self._downloadThumbnail(articles: articles, row: row + 1)
                }
            } catch {
                print ("file error: \(error)")
                self._downloadThumbnail(articles: articles, row: row + 1)
            }
        }
        downloadTask.resume()
        
    }
    
    func _finishDownloadVideos() {
        
        downloadProgressLabel.text = ""
        downloadProgressView.setProgress(0.0, animated: false)
        _printVideosDirectory()
        downloadVideosButton.isEnabled = true
        if let parent = self.parent as? ConversationsViewController {
            parent.closeDownloadScreenAndReloadData()
        }
        
    }
    
    func _cleanupVideosFolder() {
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videosFolderURL = documentsUrl.appendingPathComponent("videos")
        do {
            let videosContents = try FileManager.default.contentsOfDirectory(at: videosFolderURL, includingPropertiesForKeys: nil)
            let jsonFiles = videosContents.filter{ $0.pathExtension == "json" }
            for file in jsonFiles {
                try FileManager.default.removeItem(atPath: file.path)
            }
        } catch {
            print(error)
        }
        
    }
    
    func _printVideosDirectory() {
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videosFolderURL = documentsUrl.appendingPathComponent("videos")
        do {
            print("All files in videosFolderURL:")
            let videosContents = try FileManager.default.contentsOfDirectory(at: videosFolderURL, includingPropertiesForKeys: nil)
            print(videosContents)
        } catch {
            print(error)
        }
        
    }
    
}
