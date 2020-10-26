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
        _wipeQuestionnaireFolder()
        _wipeUserDefaults()
        
        doLayout()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        UITabBar.appearance().tintColor = #colorLiteral(red: 0.1764705882, green: 0.6352941176, blue: 0.8156862745, alpha: 1)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (_answersExist() && Reachability.isConnectedToNetwork()) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SaveAnswersVC") as! SaveAnswersViewController
            self.definesPresentationContext = true
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }
        
    }

    @objc func rotated() {
        
        doLayout()
        
    }
    
    public func switchTabBar(to: Int) {
        
        self.tabBarController!.selectedIndex = to
        
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
    
    func _answersExist() -> Bool {
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let contentFolderUrl = documentsUrl.appendingPathComponent("questionnaire")
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: contentFolderUrl, includingPropertiesForKeys: nil)
            for file in contents {
                if file.path.contains("answers_") {
                    return true
                }
            }
        } catch {
            print(error)
        }
        return false
        
    }
    
    func _wipeContentFolder() {
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let contentFolderUrl = documentsUrl.appendingPathComponent("content")
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: contentFolderUrl, includingPropertiesForKeys: nil)
            for file in contents {
                print("Removing " + file.path)
                try FileManager.default.removeItem(atPath: file.path)
            }
            print("Emptied content folder")
        } catch {
            print(error)
        }
        
    }
    
    func _wipeQuestionnaireFolder() {
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let contentFolderUrl = documentsUrl.appendingPathComponent("questionnaire")
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: contentFolderUrl, includingPropertiesForKeys: nil)
            for file in contents {
                print("Removing " + file.path)
                try FileManager.default.removeItem(atPath: file.path)
            }
            print("Emptied questionnaire folder")
        } catch {
            print(error)
        }
        
    }
    
    func _wipeUserDefaults() {
        
        UserDefaults.standard.removeObject(forKey: "SurveyHasConsented")
        print("Wiped user defaults")
        
    }

}

