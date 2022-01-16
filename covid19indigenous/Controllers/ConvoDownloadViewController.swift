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
    @IBOutlet weak var downloadVideoButton: UIButton!
    @IBOutlet weak var downloadProgressLabel: UILabel!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    @IBOutlet weak var pauseDownloadButton: UIButton!
    
    var canContinue: Bool = true
    var callbackClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var _isIPhone: Bool = true
        if UIDevice.current.userInterfaceIdiom == .pad {
            _isIPhone = false
        }
        
        if (_isIPhone) {
            contentFromServerLabel.font = .systemFont(ofSize: 24)
            downloadVideoButton.titleLabel?.font = .systemFont(ofSize: 17)
            downloadVideoButton.layer.cornerRadius = 5;
            downloadVideoButton.layer.masksToBounds = true;
        } else {
            contentFromServerLabel.font = .systemFont(ofSize: 36)
            downloadVideoButton.titleLabel?.font = .systemFont(ofSize: 27)
            downloadVideoButton.layer.cornerRadius = 15;
            downloadVideoButton.layer.masksToBounds = true;
        }
        
    }
    
    @IBAction func cancelButtonTouchDown(_ sender: Any) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        canContinue = false
        _finishDownloadContent()
        
    }
    
    @IBAction func downloadButtonTouchDown(_ sender: Any) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
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
        downloadVideoButton.isEnabled = false
        _deleteManifest()
        
        print("Downloading manifest...")
        URLCache.shared.removeAllCachedResponses()
        let url = URL(string: "https://ourdataindigenous.ca/feeds/content/manifest.json?t=" + String(NSDate().timeIntervalSince1970))!
        //let url = URL(string: "https://craigdietrich.com/projects/proxies/covid19indigenous/content/manifest.json?t=" + String(NSDate().timeIntervalSince1970))!
        let downloadTask = URLSession.shared.downloadTask(with: url) {
            urlOrNil, responseOrNil, errorOrNil in
            guard let fileURL = urlOrNil else { return }
            do {
                let documentsURL = try FileManager.default.url(for: .documentDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false)
                let contentFolderUrl = documentsURL.appendingPathComponent("content")
                if !FileManager.default.fileExists(atPath: contentFolderUrl.path) {
                    try FileManager.default.createDirectory(at: contentFolderUrl, withIntermediateDirectories: true, attributes: nil)
                }
                let manifestURL = contentFolderUrl.appendingPathComponent("manifest.json")
                try FileManager.default.moveItem(at: fileURL, to: manifestURL)
                DispatchQueue.main.async {
                    do {
                        let data = try Data(contentsOf: URL(fileURLWithPath: manifestURL.path), options: .mappedIfSafe)
                        let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                        if let jsonResult = jsonResult as? Array<Dictionary<String,String>> {
                            DispatchQueue.main.async {
                                print("Manifest downloaded")
                                self._downloadThumbnail(articles: jsonResult, row: 0)
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self._downloadManifest()
                        }
                    }
                }
            } catch {
                print ("file error: \(error)")
                DispatchQueue.main.async {
                    self._downloadManifest()
                }
            }
        }
        downloadTask.resume()
        
    }
    
    func _downloadThumbnail(articles:Array<Dictionary<String,String>>, row:Int) {
        
        if (row >= articles.count) {
            _finishDownloadContent()
            return
        }
        if (!canContinue) {
            return
        }
        downloadProgressLabel.text = "Downloading thumb " + String(row + 1) + "/" + String(articles.count)
        downloadProgressView.setProgress((Float(row) + 1.0) / Float(articles.count), animated: false)
        
        // Get filename from JSON
        let article = articles[row]
        let thumbnailFilename: String = article["thumbnail_filename"]!
        let urlString:String = "https://ourdataindigenous.ca/feeds/content/" + thumbnailFilename
        //let urlString:String = "https://craigdietrich.com/projects/proxies/covid19indigenous/content/" + thumbnailFilename
        print("Attempting to download thumbnail: " + urlString)
        
        // Check to see if it esists in the filesystem already
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let contentUrl = URL(fileURLWithPath: documentPath + "/content")
        let filePath = contentUrl.appendingPathComponent(thumbnailFilename).path
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
                let contentFolderUrl = documentsURL.appendingPathComponent("content")
                let destinationUrl = contentFolderUrl.appendingPathComponent(thumbnailFilename)
                try FileManager.default.moveItem(at: fileURL, to: destinationUrl)
                DispatchQueue.main.async {
                    print("Thumbnail downloaded")
                    self._downloadVideo(articles: articles, row: row)
                }
            } catch {
                print ("file error: \(error)")
                DispatchQueue.main.async {
                    self._downloadVideo(articles: articles, row: row)
                }
            }
        }
        downloadTask.resume()
        
    }
    
    func _downloadVideo(articles:Array<Dictionary<String,String>>, row:Int) {
        
        if (row >= articles.count) {
            _finishDownloadContent()
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
        if (videoFilename.count == 0) {
            _downloadImage(articles: articles, row: row)
            return
        }
        let urlString:String = "https://ourdataindigenous.ca/feeds/content/" + videoFilename
        //let urlString:String = "https://craigdietrich.com/projects/proxies/covid19indigenous/content/" + videoFilename
        print("Attempting to download video: " + urlString)
        
        // Check to see if it esists in the filesystem already
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let contentUrl = URL(fileURLWithPath: documentPath + "/content")
        let filePath = contentUrl.appendingPathComponent(videoFilename).path
        if FileManager.default.fileExists(atPath: filePath) {
            print("File already exists")
            _downloadImage(articles: articles, row: row)
            return
        }
        
        // Go out and get the file
        let url = URL(string: urlString)!
        print(urlString)
        let downloadTask = URLSession.shared.downloadTask(with: url) {
            urlOrNil, responseOrNil, errorOrNil in
            guard let fileURL = urlOrNil else { return }
            do {
                let documentsURL = try FileManager.default.url(for: .documentDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false)
                let contentFolderUrl = documentsURL.appendingPathComponent("content")
                let destinationUrl = contentFolderUrl.appendingPathComponent(videoFilename)
                try FileManager.default.moveItem(at: fileURL, to: destinationUrl)
                DispatchQueue.main.async {
                    print("Video downloaded")
                    self._downloadImage(articles: articles, row: row)
                }
            } catch {
                print ("file error: \(error)")
                DispatchQueue.main.async {
                    self._downloadImage(articles: articles, row: row)
                }
            }
        }
        downloadTask.resume()
        
    }
    
    func _downloadImage(articles:Array<Dictionary<String,String>>, row:Int) {
        
        if (row >= articles.count) {
            _finishDownloadContent()
            return
        }
        if (!canContinue) {
            return
        }
        downloadProgressLabel.text = "Downloading image " + String(row + 1) + "/" + String(articles.count)
        downloadProgressView.setProgress((Float(row) + 1.0) / Float(articles.count), animated: false)
        
        // Get filename from JSON
        let article = articles[row]
        let imageFilename: String = article["image_filename"]!
        if (imageFilename.count == 0) {
            _downloadThumbnail(articles: articles, row: row + 1)
            return
        }
        let urlString:String = "https://ourdataindigenous.ca/feeds/content/" + imageFilename
        //let urlString:String = "https://craigdietrich.com/projects/proxies/covid19indigenous/content/" + imageFilename
        print("Attempting to download image: " + urlString)
        
        // Check to see if it esists in the filesystem already
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let contentUrl = URL(fileURLWithPath: documentPath + "/content")
        let filePath = contentUrl.appendingPathComponent(imageFilename).path
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
                let contentFolderUrl = documentsURL.appendingPathComponent("content")
                let destinationUrl = contentFolderUrl.appendingPathComponent(imageFilename)
                try FileManager.default.moveItem(at: fileURL, to: destinationUrl)
                DispatchQueue.main.async {
                    print("Image downloaded")
                    self._downloadThumbnail(articles: articles, row: row + 1)
                }
            } catch {
                print ("file error: \(error)")
                DispatchQueue.main.async {
                    self._downloadThumbnail(articles: articles, row: row + 1)
                }
            }
        }
        downloadTask.resume()
        
    }
    
    func _finishDownloadContent() {
        
        downloadProgressLabel.text = ""
        downloadProgressView.setProgress(0.0, animated: false)
        _printContentDirectory()
        downloadVideoButton.isEnabled = true
        
        callbackClosure?()
 
        dismiss(animated: true, completion: nil)
        
    }
    
    func _deleteManifest() {
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let contentFolderUrl = documentsUrl.appendingPathComponent("content")
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: contentFolderUrl, includingPropertiesForKeys: nil)
            let jsonFiles = contents.filter{ $0.pathExtension == "json" }
            for file in jsonFiles {
                try FileManager.default.removeItem(atPath: file.path)
            }
            print("Removed existing manifest file")
        } catch {
            print(error)
        }
        
    }
    
    func _printContentDirectory() {
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let contentFolderUrl = documentsUrl.appendingPathComponent("content")
        do {
            print("All files in content folder      :")
            let contents = try FileManager.default.contentsOfDirectory(at: contentFolderUrl, includingPropertiesForKeys: nil)
            print(contents)
        } catch {
            print(error)
        }
        
    }
    
}
