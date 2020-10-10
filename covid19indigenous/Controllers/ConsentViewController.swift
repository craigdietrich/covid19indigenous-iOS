//
//  ConsentViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 10/10/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit
import WebKit

class ConsentViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    var callbackClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.isOpaque = false
        let htmlFile = Bundle.main.path(forResource: "consent", ofType: "html")
        let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        webView.loadHTMLString(html!, baseURL: Bundle.main.bundleURL)
        
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
