//
//  DetailsViewController.swift
//  NisNews
//
//  Created by К&К on 07.03.2020.
//  Copyright © 2020 KK. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    var item: Article?
    var newsImage: UIImage?
    var offsetOn = true

    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private let containerManager = ContainerManager()
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentInset.top = offsetOn ? -44 - UIApplication.shared.statusBarFrame.height : 0
        
        DispatchQueue(label: "Background", qos: .background).async {
            let text = self.containerManager.getArticleById(Int64(self.item?.title.hashValue ?? 0))?.descriptionNews
            if let text = text, !text.isEmpty {
                DispatchQueue.main.async {
                    self.detailsLabel.text = text
                }
            }
        }
        
        if let item = item {
            detailsLabel.text = item.description
            
            AllServices.newsService.getFullDescription(item.description) { s in
                if let str = s {
                    self.containerManager.changeArticleById(Int64(item.title.hashValue)) { a in
                        if let article = a {
                            article.descriptionNews = str
                        }
                    }
                    UIView.animate(withDuration: 0.5, animations: {
                        self.detailsLabel.alpha = 0
                        self.activityIndicator.alpha = 0
                    }) {f in
                        self.detailsLabel.text = str
                        self.activityIndicator.stopAnimating()
                        UIView.animate(withDuration: 0.5) {
                            self.detailsLabel.alpha = 1
                        }
                    }
                } else {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        
        imageView.image = newsImage
    }
}
