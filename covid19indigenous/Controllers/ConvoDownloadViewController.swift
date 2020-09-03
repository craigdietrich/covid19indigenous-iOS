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
    
    @IBAction func downloadVideosButtonTouchDown(_ sender: Any) {
        
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
        
        downloadVideosButton.isEnabled = false
        _cleanupVideosFolder()
        
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
                    self._downloadVideos()
                }
            } catch {
                print ("file error: \(error)")
            }
        }
        downloadTask.resume()
        
    }
    
    func _downloadVideos() {
        
        _printVideosDirectory()
        downloadVideosButton.isEnabled = true
        
    }
    
    func _cleanupVideosFolder() {
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videosFolderURL = documentsUrl.appendingPathComponent("videos")
        do {
            let videosContents = try FileManager.default.contentsOfDirectory(at: videosFolderURL, includingPropertiesForKeys: nil)
            for file in videosContents {
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
            /*
            let mp3Files = directoryContents.filter{ $0.pathExtension == "json" }
            print("json urls:",mp3Files)
            let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
            print("mp3 list:", mp3FileNames)
            */
        } catch {
            print(error)
        }
        
    }
    
}
