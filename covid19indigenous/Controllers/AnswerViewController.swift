//
//  AnswerViewController.swift
//  covid19indigenous
//
//  Created by Jalpesh Rajani on 16/09/24.
//  Copyright © 2024 craigdietrich.com. All rights reserved.
//

import UIKit
import WebKit

class AnswerViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var answer: [[String: Any]] = []
    var titleHeader: String = ""
    var date: String = ""
    var file: URL? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.navigationItem.title = date
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isTranslucent = false
        
        let image = UIImage(systemName: "arrowshape.turn.up.forward")?.withRenderingMode(.alwaysOriginal)
        let shareButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(shareBtnTapped(_:)))
        self.navigationItem.rightBarButtonItem = shareButton
        
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: answer, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Error serializing answers")
            return
        }
        
        let script = "var answers = \(jsonString);"
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        userContentController.addUserScript(userScript)
        configuration.userContentController = userContentController
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        view = webView
        
        if let localFilePath = Bundle.main.url(forResource: "preview_past_submission", withExtension: "html") {
            let request = URLRequest(url: localFilePath)
            webView.load(request)
        }
    }

    
    @objc func shareBtnTapped(_ sender: UIBarButtonItem) {
        if let filePath = file {
            let activityVC = UIActivityViewController(activityItems: [filePath], applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view
                self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("WebView finished loading")
        
        // Pass the title to JavaScript
        let sanitizedTitle = sanitizeForJavaScript(titleHeader)
        let setTitleScript = "document.title = '\(sanitizedTitle)';"
        webView.evaluateJavaScript(setTitleScript) { (result, error) in
            if let error = error {
                print("Error setting title: \(error)")
            } else {
                print("Title set successfully")
            }
        }
        
        
        let setDataScript = "setData(answers);"
        webView.evaluateJavaScript(setDataScript) { (result, error) in
            if let error = error {
                print("Error setting data: \(error)")
            } else {
                print("Data set successfully")
            }
        }
        
        func sanitizeForJavaScript(_ string: String) -> String {
            var sanitized = string.replacingOccurrences(of: "'", with: "\\'")
            sanitized = sanitized.replacingOccurrences(of: "\n", with: "\\n")
            return sanitized
        }
        
        func readFile(fileName: String) -> Data? {
            if let fileURL = Bundle.main.url(forResource: fileName, withExtension: "json") {
                do {
                    return try Data(contentsOf: fileURL)
                } catch {
                    print("Error reading file: \(error)")
                    return nil
                }
            }
            return nil
        }
    }
}





