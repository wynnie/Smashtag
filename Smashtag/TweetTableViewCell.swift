//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Vinod Ananth on 3/1/15.
//  Copyright (c) 2015 Vinod Ananth. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    var tweet: Tweet? { //Table view controller sets this when dequeueing a cell
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenName: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!  //set lines=0 in IB to get wrap text
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    private struct Constants {
        static let hashTagColor = UIColor.greenColor()
        static let mentionColor = UIColor.orangeColor()
        static let urlColor = UIColor.blueColor()
    }
    
    func updateUI() {
        tweetProfileImageView?.image = nil
        tweetScreenName?.text = nil
        tweetTextLabel?.text = nil
        
        if let tweet = self.tweet {
            
            var attributedText = NSMutableAttributedString(string: tweet.text)
            attributedText.setKeywordColor(tweet.hashtags, color: Constants.hashTagColor)
            attributedText.setKeywordColor(tweet.userMentions, color: Constants.mentionColor)
            attributedText.setKeywordColor(tweet.urls,color: Constants.urlColor)
            tweetTextLabel?.attributedText = attributedText
            
            if tweetTextLabel?.text != nil {
                for _ in tweet.media {
                    tweetTextLabel.text! += " 📷"
                }
            }
            tweetScreenName?.text = "\(tweet.user)" //tweet user.description
            if let profileImageURL = tweet.user.profileImageURL {
                if let imageData = NSData(contentsOfURL: profileImageURL) { //blocks main thread!
                    tweetProfileImageView?.image = UIImage(data: imageData)
                }
            }
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
        }
    }
    
}

private extension NSMutableAttributedString {
    func setKeywordColor(keywords: [Tweet.IndexedKeyword], color:UIColor) {
        for keyword in keywords {
            addAttribute(NSForegroundColorAttributeName, value: color, range: keyword.nsrange)
        }
    }
}
