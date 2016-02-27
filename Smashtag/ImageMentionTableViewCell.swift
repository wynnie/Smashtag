//
//  ImageMentionTableViewCell.swift
//  Smashtag
//
//  Created by Vinod Ananth on 3/13/15.
//  Copyright (c) 2015 Vinod Ananth. All rights reserved.
//

import UIKit

class ImageMentionTableViewCell: UITableViewCell {

 
    @IBOutlet weak var tweetImage: UIImageView!
    @IBOutlet weak var loadingActivity: UIActivityIndicatorView! //Set hides when stopped property in IB
    
    var imageURL: NSURL? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        if let url = imageURL {
            loadingActivity.startAnimating()
            let qos = Int(QOS_CLASS_USER_INITIATED.value)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { () -> Void in
                let imageData = NSData(contentsOfURL:url)
                dispatch_async(dispatch_get_main_queue()) {
                    if url == self.imageURL { //Need this check since the user may have moved on by the time NSData returns.
                        if imageData != nil {
                            self.tweetImage.image = UIImage(data: imageData!)
                        } else {
                            self.tweetImage = nil
                        }
                    }
                    self.loadingActivity.stopAnimating()
                }
            }
        }
    } //func updateUI
    

}
