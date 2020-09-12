//
//  FirstViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 8/27/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var iPhoneVerticalContainer: UIView!
    @IBOutlet weak var iPhoneHoriztonalContainer: UIView!
    @IBOutlet weak var iPadVerticalContainer: UIView!
    @IBOutlet weak var iPadHoritzontalContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _wipeContentFolder()
        
        doLayout()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }

    @objc func rotated() {
        
        doLayout()
        
    }
    
    func doLayout() {
        
        var _isIPhone: Bool = true
        var _isVertical: Bool = true
        switch UIDevice.current.orientation {
            case .landscapeLeft, .landscapeRight:
                _isVertical = false
            case .portrait, .portraitUpsideDown:
                _isVertical = true
            default:
                _isVertical = true
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            _isIPhone = false
        }
        
        if (_isIPhone) {
            if (_isVertical) {
                iPhoneVerticalContainer.isHidden = false
                iPhoneHoriztonalContainer.isHidden = true
                iPadVerticalContainer.isHidden = true
                iPadHoritzontalContainer.isHidden = true
            } else {
                iPhoneVerticalContainer.isHidden = true
                iPhoneHoriztonalContainer.isHidden = false
                iPadVerticalContainer.isHidden = true
                iPadHoritzontalContainer.isHidden = true
            }
        } else {
            if (_isVertical) {
                iPhoneVerticalContainer.isHidden = true
                iPhoneHoriztonalContainer.isHidden = true
                iPadVerticalContainer.isHidden = false
                iPadHoritzontalContainer.isHidden = true
            } else {
                iPhoneVerticalContainer.isHidden = true
                iPhoneHoriztonalContainer.isHidden = true
                iPadVerticalContainer.isHidden = true
                iPadHoritzontalContainer.isHidden = false
            }
        }
        
    }
    
    func _wipeContentFolder() {
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videosFolderURL = documentsUrl.appendingPathComponent("content")
        do {
            let videosContents = try FileManager.default.contentsOfDirectory(at: videosFolderURL, includingPropertiesForKeys: nil)
            for file in videosContents {
                try FileManager.default.removeItem(atPath: file.path)
            }
            print("Emptied content folder")
        } catch {
            print(error)
        }
        
    }

}

