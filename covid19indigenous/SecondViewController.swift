//
//  SecondViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 8/27/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit
import WebKit

class SecondViewController: UIViewController, WKNavigationDelegate, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var articles: Array<Dictionary<String,String>> = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "StoriesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "storiesCell")
        
        collectionView.isHidden = true
        
        webView.isOpaque = false
        webView.backgroundColor = UIColor.darkGray
        let htmlFile = Bundle.main.path(forResource: "about", ofType: "html")
        let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        webView.loadHTMLString(html!, baseURL: Bundle.main.bundleURL)
        
    }
    
    func loadData() {
        
        if let path = Bundle.main.path(forResource: "stories", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Array<Dictionary<String,String>> {
                    DispatchQueue.main.async {
                        self.articles = jsonResult
                        self.collectionView.reloadData()
                    }
                }
            } catch {
                // No error
            }
        }

    }
    
    func returnCategoryFromSegmentedControl() -> String {
        
        var str:String = ""
        switch segmentedControl.selectedSegmentIndex {
          case 0:
              str = "about"
          case 1:
              str = "stories"
          default:
              break
        }
        return str
        
    }

    @IBAction func segmentedControllerChanged(_ sender: Any) {
        
        let category = returnCategoryFromSegmentedControl()
        if (category == "about") {
            collectionView.isHidden = true
        } else {
            collectionView.isHidden = false
            loadData()
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.articles.count;
        
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
  
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
        
        var cellWidth: CGFloat = 0.0
        if (_isIPhone) {
            if (_isVertical) {
                cellWidth = collectionView.frame.size.width
            } else {
                cellWidth = collectionView.frame.size.width / 2.1
            }
        } else {
            if (_isVertical) {
                cellWidth = collectionView.frame.size.width / 2.1
            } else {
                cellWidth = collectionView.frame.size.width / 3.1
            }
        }
        
        let row = articles[indexPath.row];
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storiesCell", for: indexPath) as! StoriesCollectionViewCell;
        var totalHeight:CGFloat = 0.0;
        
        if let title = row["title"] {
            let titleStyle = NSMutableParagraphStyle()
            titleStyle.lineSpacing = 4
            titleStyle.alignment = .left
            let titleAttrString = NSMutableAttributedString(string: title)
            titleAttrString.addAttribute(.paragraphStyle, value:titleStyle, range:NSMakeRange(0, titleAttrString.length))
            cell.titleLabel.attributedText = titleAttrString;
            let titleNumLines = cell.titleLabel.calculateMaxLines(actualWidth: cellWidth)
            totalHeight = totalHeight + (CGFloat(titleNumLines) * 33.0)
        }
        
        let imageHeight = (cellWidth * 9) / 16
        totalHeight = totalHeight + CGFloat(imageHeight)
        
        return CGSize(width: cellWidth, height: totalHeight)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  
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
        
        var cellWidth: CGFloat = 0.0
        if (_isIPhone) {
            if (_isVertical) {
                cellWidth = collectionView.frame.size.width
            } else {
                cellWidth = collectionView.frame.size.width / 2.1
            }
        } else {
            if (_isVertical) {
                cellWidth = collectionView.frame.size.width / 2.1
            } else {
                cellWidth = collectionView.frame.size.width / 3.1
            }
        }
        
        let row = articles[indexPath.row];
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storiesCell", for: indexPath) as! StoriesCollectionViewCell;

        if let title = row["title"] {
            let titleStyle = NSMutableParagraphStyle()
            titleStyle.lineSpacing = 4
            titleStyle.alignment = .left
            let titleAttrString = NSMutableAttributedString(string: title)
            titleAttrString.addAttribute(.paragraphStyle, value:titleStyle, range:NSMakeRange(0, titleAttrString.length))
            cell.titleLabel.attributedText = titleAttrString;
        }
                
        if let imageStr = row["image"] {
            let imageUrl = URL(string: imageStr)
            let data = try? Data(contentsOf: imageUrl!)
            if let imageData = data {
                let image = UIImage(data: imageData)
                cell.imageView.image = image
                for constraint in cell.imageView.constraints {
                    guard constraint.firstAnchor == cell.imageView.heightAnchor else { continue }
                    constraint.isActive = false
                    break
                }
                let imageHeight = (cellWidth * 9) / 16
                cell.imageView.heightAnchor.constraint(equalToConstant: CGFloat(imageHeight)).isActive = true
            }
        }
        
        return cell;
        
    }
    
}

