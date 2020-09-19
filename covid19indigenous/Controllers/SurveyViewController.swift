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

        webView.isOpaque = false
        webView.backgroundColor = UIColor.darkGray
 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterCodeVC") as! EnterCodeViewController
        vc.callbackClosure = { [weak self] in
            self?.callMeFromPresentedVC()
        }
        self.definesPresentationContext = true
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
        
    }
    
    private func callMeFromPresentedVC() {
         
        launchQuestionnaire()
        
    }
    
    private func launchQuestionnaire() {
        
        let htmlFile = Bundle.main.path(forResource: "index", ofType: "html")
        let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        webView.loadHTMLString(html!, baseURL: Bundle.main.bundleURL)
        
    }

}
