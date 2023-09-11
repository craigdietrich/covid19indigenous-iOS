//
//  AboutSurveyViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 10/4/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class AboutSurveyViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {

    @IBOutlet weak var webViewWrapper: UIView!
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let contentController = WKUserContentController();
        contentController.add(self, name: "buttonAction")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        webView = WKWebView(frame: webViewWrapper.bounds, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webViewWrapper.addSubview(webView)
         
        webView.leadingAnchor.constraint(equalTo: webViewWrapper.leadingAnchor, constant: 0).isActive = true
        webView.trailingAnchor.constraint(equalTo: webViewWrapper.trailingAnchor, constant: 0).isActive = true
        webView.topAnchor.constraint(equalTo: webViewWrapper.topAnchor, constant: 0).isActive = true
        webView.bottomAnchor.constraint(equalTo: webViewWrapper.bottomAnchor, constant: 0).isActive = true
        webView.isOpaque = false

        let fileExtension = getHtmlPageExtension()
        let htmlFile = Bundle.main.path(forResource: "aboutSurvey" + fileExtension, ofType: "html")
        let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        webView.loadHTMLString(html!, baseURL: Bundle.main.bundleURL)
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (_answersExist() && Reachability.isConnectedToNetwork()) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SaveAnswersVC") as! SaveAnswersViewController
            self.definesPresentationContext = true
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
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

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        guard let response = message.body as? String else { return }
        switch (response) {
            case "takeSurvey":
                let parentVC = self.parent as! SurveyViewController
                parentVC.switchSegmentedControl(to: 1)
                break;
            case "deleteUserData":
                let refreshAlert = UIAlertController(title: NSLocalizedString("reset_data", comment: ""), message: NSLocalizedString("reset_data_text", comment: ""), preferredStyle: UIAlertController.Style.alert)
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    self._wipeContentFolder()
                    self._wipeQuestionnaireFolder()
                    self._wipeUserDefaults()
                }))
                refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: { (action: UIAlertAction!) in
                    // Nothing
                }))
                present(refreshAlert, animated: true, completion: nil)
                break;
            default:
                if let url = URL(string: response) {
                    let config = SFSafariViewController.Configuration()
                    config.entersReaderIfAvailable = true
                    let vc = SFSafariViewController(url: url, configuration: config)
                    present(vc, animated: true)
                }
        }
        
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
