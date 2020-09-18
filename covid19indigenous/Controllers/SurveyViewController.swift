//
//  SurveyViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 9/18/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit
import WebKit

class SurveyViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       let htmlFile = Bundle.main.path(forResource: "index", ofType: "html")
       let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
       webView.loadHTMLString(html!, baseURL: Bundle.main.bundleURL)
        
    }

}
