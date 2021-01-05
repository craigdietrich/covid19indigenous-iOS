//
//  ConversationsViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 8/31/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit
import AVKit
import SafariServices

class ConversationsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var refreshView: UIView!
    
    var allArticles: Array<Dictionary<String,String>> = [];
    var articles: Array<Dictionary<String,String>> = [];
    
    var newImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let textAttribNormal = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        let textAttribSelected = [NSAttributedString.Key.foregroundColor: UIColor(red: 45.0/255, green: 162.0/255, blue: 208.0/255, alpha: 1.0)]
        segmentedControl.setTitleTextAttributes(textAttribNormal, for: .normal)
        segmentedControl.setTitleTextAttributes(textAttribSelected, for: .selected)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ConversationsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "conversationsCell")
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        loadData()
        
    }
    
    private func callMeFromPresentedVC() {
        
        loadData()
        
    }
    
    @objc func rotated() {
        
        if newImageView != nil && newImageView.superview != nil {  // The image that pops up when an image is clicked
            newImageView.frame = UIScreen.main.bounds
        }
        
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
            collectionView.superview?.backgroundColor = #colorLiteral(red: 0.3182867765, green: 0.3557572365, blue: 0.4283527732, alpha: 1)
        } else {
            collectionView.superview?.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9529411765, alpha: 1)
        }
        
        collectionView.reloadData()
        
        /*
        collectionView.performBatchUpdates(nil, completion: { (result) in
            self.collectionViewHasLoaded()
        })
        */
        
    }
    
    func loadData() {
        
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videosFolderURL = documentsUrl.appendingPathComponent("content")
        let manifestURL = videosFolderURL.appendingPathComponent("manifest.json")
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: manifestURL.path), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonResult = jsonResult as? Array<Dictionary<String,String>> {
                DispatchQueue.main.async {
                    self.allArticles = jsonResult
                    self.propagateArticles()
                }
            }
        } catch {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConvoDownloadVC") as! ConvoDownloadViewController
            vc.callbackClosure = { [weak self] in
                self?.callMeFromPresentedVC()
            }
            self.definesPresentationContext = true
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }

    }
    
    func propagateArticles() {
        
        articles = []
        collectionView.reloadData()
        let category: String = returnCategoryFromSegmentedControl()
        
        for article in allArticles {
            if (article["category"] != category) {
                continue
            }
            articles.append(article)
        }
        
        collectionView.reloadData()
        
        /*
        collectionView.performBatchUpdates(nil, completion: { (result) in
            self.collectionViewHasLoaded()
        })
        */
        
    }
    
    func returnCategoryFromSegmentedControl() -> String {
        
        var str:String = ""
        switch segmentedControl.selectedSegmentIndex {
          case 0:
              str = "culture"
          case 1:
              str = "resilience"
          default:
              break
        }
        return str
        
    }

    @IBAction func refreshButtonAction(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConvoDownloadVC") as! ConvoDownloadViewController
        vc.callbackClosure = { [weak self] in
            self?.callMeFromPresentedVC()
        }
        self.definesPresentationContext = true
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func segmentedControlAction(_ sender: Any) {
        
        loadData()
        
    }
    
    func collectionViewHasLoaded() {
        
        let collectionWidth = collectionView.frame.width
        
        for row in 0..<collectionView.numberOfItems(inSection: 0){

            let indexPath = NSIndexPath(row:row, section:0)

            let cell:UICollectionViewCell = collectionView.cellForItem(at: indexPath as IndexPath)!

            let width = cell.frame.width
            let height = cell.frame.height
            
            if (width * 2 <= collectionWidth * 1.1) {
                print("Is wide")
            } else {
                print("Is narrow")
            }
            
            // TODO: set height but only if in double orientation
            
        }
        
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
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "conversationsCell", for: [indexPath]) as! ConversationsCollectionViewCell;
        let cell = Bundle.main.loadNibNamed("ConversationsCollectionViewCell", owner: self, options: nil)?.first as! ConversationsCollectionViewCell
        var totalHeight:CGFloat = 0.0;
        
        if let title = row["title"] {
            let titleStyle = NSMutableParagraphStyle()
            titleStyle.lineSpacing = 4
            titleStyle.alignment = .left
            let titleAttrString = NSMutableAttributedString(string: title)
            titleAttrString.addAttribute(.paragraphStyle, value:titleStyle, range:NSMakeRange(0, titleAttrString.length))
            cell.titleLabel.attributedText = titleAttrString;
            let titleNumLines = cell.titleLabel.calculateMaxLines(actualWidth: cellWidth)
            totalHeight = totalHeight + (CGFloat(titleNumLines) * 45.0)
        }
        
        if let description = row["description"] {
            let descStyle = NSMutableParagraphStyle()
            descStyle.lineSpacing = 2
            descStyle.alignment = .left
            let descAttrString = NSMutableAttributedString(string: description)
            descAttrString.addAttribute(.paragraphStyle, value:descStyle, range:NSMakeRange(0, descAttrString.length))
            cell.descriptionLabel.attributedText = descAttrString;
            let descNumLines = cell.descriptionLabel.calculateMaxLines(actualWidth: cellWidth)
            totalHeight = totalHeight + (CGFloat(descNumLines) * 24.0)
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
                 totalHeight = totalHeight + (CGFloat(dateNumLines) * 45.0)
             }
         }
        
        if let youtube = row["url"] {
            if youtube.count > 0 {
                 totalHeight = totalHeight + 45.0  // Requires-internet label
            }
        }
        
        if let linkUrl = row["link"] {
            if linkUrl.count > 0 {
                cell.linkLabel.text = linkUrl;
                let linkNumLines = cell.linkLabel.calculateMaxLines(actualWidth: cellWidth)
                totalHeight = totalHeight + (CGFloat(linkNumLines) * 24.0)
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

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        let article = articles[indexPath.item]
        let youtube = article["url"] ?? ""
        let mp4 = article["mp4_filename"] ?? ""
        let image = article["image_filename"] ?? ""
        
        if (youtube.count > 0) {
            
            if Reachability.isConnectedToNetwork() {
                if let url = URL(string: youtube) {
                    let config = SFSafariViewController.Configuration()
                    config.entersReaderIfAvailable = true
                    let vc = SFSafariViewController(url: url, configuration: config)
                    present(vc, animated: true)
                }
            } else {
                let alertController = UIAlertController(title: "No Connection", message: "Viewing this content requires an Internet connection. Please establish a connection and try again.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("Ok button tapped");
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
            }
            
        } else if (mp4.count > 0) {
            
            let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let contentUrl = URL(fileURLWithPath: documentPath + "/content")
            let filePath = contentUrl.appendingPathComponent(mp4)
            if !FileManager.default.fileExists(atPath: filePath.path) {
                let alertController = UIAlertController(title: "File not found", message: "This content has not been downloaded. Please refresh content and try again.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("Ok button tapped");
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
            } else {
                print(filePath)
                let player = AVPlayer(url: filePath)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                present(playerViewController, animated: true) {
                  player.play()
                }
            }
            
        } else if (image.count > 0) {
               
            let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let contentUrl = URL(fileURLWithPath: documentPath + "/content")
            let filePath = contentUrl.appendingPathComponent(image)
            if !FileManager.default.fileExists(atPath: filePath.path) {
                let alertController = UIAlertController(title: "File not found", message: "This content has not been downloaded. Please refresh content and try again.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("Ok button tapped");
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
            } else {
                let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                let contentUrl = URL(fileURLWithPath: documentPath + "/content")
                let filePath = contentUrl.appendingPathComponent(image)
                let theImage = UIImage(named: filePath.path)
                let imageView = UIImageView(image: theImage!)
                imageTapped(imageView: imageView)
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
        var requiresInternet: Bool = false

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
            let videosUrl = URL(fileURLWithPath: documentPath + "/content")
            let filePath = videosUrl.appendingPathComponent(thumbnail)
            if FileManager.default.fileExists(atPath: filePath.path) {
                do {
                    let imageData = try Data(contentsOf: filePath)
                    cell.imageView.image = UIImage(data: imageData)
                } catch {
                    print("Error loading image : \(error)")
                }
            }
        }
        for constraint in cell.imageView.constraints {
            guard constraint.firstAnchor == cell.imageView.heightAnchor else { continue }
            constraint.isActive = false
            break
        }
        let imageHeight = (cellWidth * 9) / 16
        cell.imageView.heightAnchor.constraint(equalToConstant: CGFloat(imageHeight)).isActive = true
         
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
        
         if let youtube = row["url"] {
            if (youtube.count > 0) {
                requiresInternet = true
            }
         }
        
         if (requiresInternet == true) {
            cell.requiresInternetLabel.isHidden = false
            cell.requiresInternetHeight.constant = 21
            cell.requiresInternetBufferLabel.isHidden = false
            cell.requiresInternetBufferHeight.constant = 12
         } else {
            cell.requiresInternetLabel.isHidden = true
            cell.requiresInternetHeight.constant = 0
            cell.requiresInternetBufferLabel.isHidden = true
            cell.requiresInternetBufferHeight.constant = 0
         }
        
        cell.linkLabel.isHidden = true
         if let linkUrl = row["link"] {
            if (linkUrl.count > 0) {
                cell.linkLabel.isHidden = false
                cell.linkLabel.text = linkUrl
                let linkLabelTap = UITapGestureRecognizer(target: self, action: #selector(linkLabelTapped))
                cell.linkLabel.isUserInteractionEnabled = true
                cell.linkLabel.addGestureRecognizer(linkLabelTap)
            }
         }
        
         return cell;
        
    }
    
    @IBAction func linkLabelTapped(sender: UITapGestureRecognizer) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let view: UILabel = sender.view as! UILabel
        
        let downloadURL = view.text!

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let url = URL(string: downloadURL) {
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                let vc = SFSafariViewController(url: url, configuration: config)
                self.present(vc, animated: true)
            }
        }

        
    }
    
    // https://stackoverflow.com/questions/34694377/swift-how-can-i-make-an-image-full-screen-when-clicked-and-then-original-size
    func imageTapped(imageView: UIImageView) {
        newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
}
