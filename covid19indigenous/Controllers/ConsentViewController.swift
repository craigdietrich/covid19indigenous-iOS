//
//  ConsentViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 10/10/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class ConsentViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {

    @IBOutlet weak var webViewWrapper: UIView!
    var webView: WKWebView!
    
    var callbackClosure: (() -> Void)?
    
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
        let htmlFile = Bundle.main.path(forResource: "consent" + fileExtension, ofType: "html")
        let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        webView.loadHTMLString(html!, baseURL: Bundle.main.bundleURL)
        
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        guard let response = message.body as? String else { return }
        switch (response) {
            default:
                if let url = URL(string: response) {
                    let config = SFSafariViewController.Configuration()
                    config.entersReaderIfAvailable = true
                    let vc = SFSafariViewController(url: url, configuration: config)
                    present(vc, animated: true)
                }
        }
        
    }
    
    @IBAction func consentButtonTouchDown(_ sender: Any) {
        
        UserDefaults.standard.set(true, forKey: "SurveyHasConsented")
        
        dismiss(animated: true, completion: nil)
        
        callbackClosure?()
        
    }
    
    @IBAction func cancelButtonTouchDown(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
        callbackClosure?()
        
    }
    
}
