//
//  ConversationsViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 8/31/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit
import AVKit

class ConversationsViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var downloadContainerView: UIView!
    
    var allArticles: Array<Dictionary<String,String>> = [];
    var articles: Array<Dictionary<String,String>> = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ConversationsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "conversationsCell")
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //_wipeVideosFolder()
        loadData()
        
    }
    
    @objc func rotated() {
        
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
        if (_isIPhone && !_isVertical) {
            collectionView.superview?.backgroundColor = UIColor.darkGray
        } else {
            collectionView.superview?.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        }
        
        collectionView.reloadData()
        
    }
    
    public func closeDownloadScreenAndReloadData() {
        
        downloadContainerView.isHidden = true
        loadData()
        
    }
    
    public func closeDownloadScreen() {
        
        downloadContainerView.isHidden = true
        
    }
    
    func loadData() {
        
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videosFolderURL = documentsUrl.appendingPathComponent("videos")
        let manifestURL = videosFolderURL.appendingPathComponent("manifest.json")
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: manifestURL.path), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonResult = jsonResult as? Array<Dictionary<String,String>> {
                DispatchQueue.main.async {
                    self.allArticles = jsonResult
                    let category:String = self.returnCategoryFromSegmentedControl()
                    self.propagateArticles(category: category)
                }
            }
        } catch {
            downloadContainerView.isHidden = false
        }

    }
    
    func propagateArticles(category:String) {
        
        articles = []
        collectionView.reloadData()
        
        for article in allArticles {
            if (article["category"] != category) {
                continue
            }
            articles.append(article)
        }
        
        collectionView.reloadData()
        
        if (articles.count > 0) {
            downloadContainerView.isHidden = true
        } else {
            downloadContainerView.isHidden = false
        }
        
    }
    
    func returnCategoryFromSegmentedControl() -> String {
        
        var str:String = ""
        switch segmentedControl.selectedSegmentIndex {
          case 0:
              str = "kahkakiw"
          case 1:
              str = "webinars"
          default:
              break
        }
        return str
        
    }

    @IBAction func refreshButtonAction(_ sender: Any) {
        
        downloadContainerView.isHidden = false
        
    }
    
    @IBAction func segmentedControlAction(_ sender: Any) {
        
        loadData()
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
        
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "conversationsCell", for: indexPath) as! ConversationsCollectionViewCell;
        var totalHeight:CGFloat = 0.0;
        
        if let title = row["title"] {
            let titleStyle = NSMutableParagraphStyle()
            titleStyle.lineSpacing = 4
            titleStyle.alignment = .left
            let titleAttrString = NSMutableAttributedString(string: title)
            titleAttrString.addAttribute(.paragraphStyle, value:titleStyle, range:NSMakeRange(0, titleAttrString.length))
            cell.titleLabel.attributedText = titleAttrString;
            let titleNumLines = cell.titleLabel.calculateMaxLines(actualWidth: cellWidth)
            totalHeight = totalHeight + (CGFloat(titleNumLines) * 32.0)
        }
        
        if let description = row["description"] {
            let descStyle = NSMutableParagraphStyle()
            descStyle.lineSpacing = 2
            descStyle.alignment = .left
            let descAttrString = NSMutableAttributedString(string: description)
            descAttrString.addAttribute(.paragraphStyle, value:descStyle, range:NSMakeRange(0, descAttrString.length))
            cell.descriptionLabel.attributedText = descAttrString;
            let descNumLines = cell.descriptionLabel.calculateMaxLines(actualWidth: cellWidth)
            totalHeight = totalHeight + (CGFloat(descNumLines) * 25.0) + 10
        }
        
        if let publishedDate = row["date"] {
             let dbDateFormatter = DateFormatter()
             dbDateFormatter.dateFormat = "yyyy-MM-dd"
             if let date = dbDateFormatter.date(from: publishedDate){
                 let dateFormatter = DateFormatter()
                 dateFormatter.dateFormat = "MMM dd, yyyy"
                 let todaysDate = dateFormatter.string(from: date)
                 cell.publishedLabel.text = "Published: " + todaysDate
                 let dateNumLines = cell.publishedLabel.calculateMaxLines(actualWidth: cellWidth)
                 totalHeight = totalHeight + (CGFloat(dateNumLines) * 25.0) + 10
             }
         }
        
        let imageHeight = (cellWidth * 9) / 16
        totalHeight = totalHeight + CGFloat(imageHeight)
        
        return CGSize(width: cellWidth, height: totalHeight)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.articles.count;
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let article = articles[indexPath.item]
        let category = returnCategoryFromSegmentedControl()
        
        if (category == "webinars") {
            
            if Reachability.isConnectedToNetwork() {
                let url = article["youtube_url"]
                if let url = URL(string: url!) {
                    UIApplication.shared.open(url)
                }
            } else {
                let alertController = UIAlertController(title: "No Connection", message: "Viewing webinars requires an Internet connection. Please establish a connection and try again.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("Ok button tapped");
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
            }
            
        } else {
            
            let filename = article["mp4_filename"]!
            if (filename.count <= 0) {
                print("Empty filename")
                return
            }
            
            let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let videosUrl = URL(fileURLWithPath: documentPath + "/videos")
            let filePath = videosUrl.appendingPathComponent(filename)
            if !FileManager.default.fileExists(atPath: filePath.path) {
                print("File doesn't exist")
                return
            }
            print("filePath: " + filePath.path)
            
            let player = AVPlayer(url: filePath)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            present(playerViewController, animated: true) {
              player.play()
            }
            
        }
        
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "conversationsCell", for: indexPath) as! ConversationsCollectionViewCell;

        if let title = row["title"] {
            let titleStyle = NSMutableParagraphStyle()
            titleStyle.lineSpacing = 4
            titleStyle.alignment = .left
            let titleAttrString = NSMutableAttributedString(string: title)
            titleAttrString.addAttribute(.paragraphStyle, value:titleStyle, range:NSMakeRange(0, titleAttrString.length))
            cell.titleLabel.attributedText = titleAttrString;
        }
        
        if let description = row["description"] {
            let descStyle = NSMutableParagraphStyle()
            descStyle.lineSpacing = 2
            descStyle.alignment = .left
            let descAttrString = NSMutableAttributedString(string: description)
            descAttrString.addAttribute(.paragraphStyle, value:descStyle, range:NSMakeRange(0, descAttrString.length))
            cell.descriptionLabel.attributedText = descAttrString;
        }
        
        if let thumbnail = row["thumbnail_filename"] {
            let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let videosUrl = URL(fileURLWithPath: documentPath + "/videos")
            let filePath = videosUrl.appendingPathComponent(thumbnail)
            if FileManager.default.fileExists(atPath: filePath.path) {
                do {
                    let imageData = try Data(contentsOf: filePath)
                    cell.imageView.image = UIImage(data: imageData)!
                    for constraint in cell.imageView.constraints {
                        guard constraint.firstAnchor == cell.imageView.heightAnchor else { continue }
                        constraint.isActive = false
                        break
                    }
                    let imageHeight = (cellWidth * 9) / 16
                    cell.imageView.heightAnchor.constraint(equalToConstant: CGFloat(imageHeight)).isActive = true
                } catch {
                    print("Error loading image : \(error)")
                }
            }
        }
         
        if let publishedDate = row["date"] {
             let dbDateFormatter = DateFormatter()
             dbDateFormatter.dateFormat = "yyyy-MM-dd"
             if let date = dbDateFormatter.date(from: publishedDate){
                 let dateFormatter = DateFormatter()
                 dateFormatter.dateFormat = "MMM dd, yyyy"
                 let todaysDate = dateFormatter.string(from: date)
                 cell.publishedLabel.text = "Published: " + todaysDate
             }
         }
        
         return cell;
    }
    
    func _wipeVideosFolder() {
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videosFolderURL = documentsUrl.appendingPathComponent("videos")
        do {
            let videosContents = try FileManager.default.contentsOfDirectory(at: videosFolderURL, includingPropertiesForKeys: nil)
            for file in videosContents {
                try FileManager.default.removeItem(atPath: file.path)
            }
        } catch {
            print(error)
        }
        
    }
    
}

extension UILabel {
    func calculateMaxLines(actualWidth: CGFloat?) -> Int {
        var width = frame.size.width
        if let actualWidth = actualWidth {
            width = actualWidth - 40  // Add padding here if needed
        }
        let maxSize = CGSize(width: width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font!], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}
