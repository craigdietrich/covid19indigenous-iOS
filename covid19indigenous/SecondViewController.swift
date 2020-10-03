//
//  SecondViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 8/27/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit
import WebKit
import AVKit
import SafariServices

class SecondViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet var webViewWrapper: UIView!
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        let textAttribNormal = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        let textAttribSelected = [NSAttributedString.Key.foregroundColor: UIColor(red: 45.0/255, green: 162.0/255, blue: 208.0/255, alpha: 1.0)]
        segmentedControl.setTitleTextAttributes(textAttribNormal, for: .normal)
        segmentedControl.setTitleTextAttributes(textAttribSelected, for: .selected)
        
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

        let htmlFile = Bundle.main.path(forResource: "aboutProject", ofType: "html")
        let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        webView.loadHTMLString(html!, baseURL: Bundle.main.bundleURL)
        
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        guard let response = message.body as? String else { return }
        switch (response) {
            case "takeSurvey":
                tabBarController?.selectedIndex = 2
                break;
            case "goToWebsite":
                if let url = URL(string: "https://covid19indigenous.ca") {
                    let config = SFSafariViewController.Configuration()
                    config.entersReaderIfAvailable = true
                    let vc = SFSafariViewController(url: url, configuration: config)
                    present(vc, animated: true)
                }
            case "conversations":
                tabBarController?.selectedIndex = 3
            default:
                if let url = URL(string: response) {
                    let config = SFSafariViewController.Configuration()
                    config.entersReaderIfAvailable = true
                    let vc = SFSafariViewController(url: url, configuration: config)
                    present(vc, animated: true)
                }
        }
        
    }
    
    func returnCategoryFromSegmentedControl() -> String {
        
        var str:String = ""
        switch segmentedControl.selectedSegmentIndex {
          case 0:
              str = "about-project"
          case 1:
              str = "about-us"
          default:
              break
        }
        return str
        
    }

    @IBAction func segmentedControllerChanged(_ sender: Any) {
        
        let category = returnCategoryFromSegmentedControl()
        if (category == "about-project") {
             let htmlFile = Bundle.main.path(forResource: "aboutProject", ofType: "html")
             let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
             webView.loadHTMLString(html!, baseURL: Bundle.main.bundleURL)
        } else {
             let htmlFile = Bundle.main.path(forResource: "aboutUs", ofType: "html")
             let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
             webView.loadHTMLString(html!, baseURL: Bundle.main.bundleURL)
        }
        
    }
    
}

