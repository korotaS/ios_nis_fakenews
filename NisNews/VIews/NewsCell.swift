//
//  NewsCell.swift
//  NisNews
//
//  Created by К&К on 14.03.2020.
//  Copyright © 2020 KK. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {
    
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 5
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler))
        gesture.cancelsTouchesInView = false
        gesture.minimumPressDuration = 0.2
        gesture.delegate = self
        
        self.addGestureRecognizer(gesture)
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    @objc func longPressHandler(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            UIView.animate(withDuration: 0.3) {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        case .ended:
            UIView.animate(withDuration: 0.3) {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        default:
            return
        }
    }

}
