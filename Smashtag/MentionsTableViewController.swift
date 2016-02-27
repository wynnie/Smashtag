//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by Vinod Ananth on 3/13/15.
//  Copyright (c) 2015 Vinod Ananth. All rights reserved.
//

import UIKit

class MentionsTableViewController: UITableViewController {

    var tweet: Tweet? {
        didSet {
            var count = 0
            if (tweet!.media.count>0) {
                tweetMention.append(tweet!.media.map({MentionItem.media($0)}))
                sections[count++] = "Image"
            }
            if tweet!.hashtags.count>0 {
                tweetMention.append(tweet!.hashtags.map({MentionItem.text($0)}))
                sections[count++] = "Hashtags"
            }
            if tweet!.userMentions.count>0 {
                tweetMention.append(tweet!.userMentions.map({MentionItem.text($0)}))
                sections[count++] = "User Mentions"
            }
            if tweet!.urls.count>0 {
                tweetMention.append(tweet!.urls.map({MentionItem.text($0)}))
                sections[count++] = "URLs"
            }
        }
    }
    private var tweetMention : [[MentionItem]] = [[]]
    private var sections = [Int:String]()
    
    private struct Storyboard {
        static let ImageCellReuseIdentifier = "ImageMention"  //This is the same identifier used in the prototype TableViewCell in the storyboard, needed for the reuse Q
        static let TextCellReuseIdentifier = "TextMention"
        static let TextSearchIdentifier = "TextSearchUnwind"
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.estimatedRowHeight = tableView.rowHeight //Height coming out of storyboard
        //tableView.rowHeight = UITableViewAutomaticDimension //Variable from super
        
    }

    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return tweetMention.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return tweetMention[section].count

    }
    
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //if tweetMention![indexPath.section][indexPath.row] != nil {
            switch tweetMention[indexPath.section][indexPath.row] {
            case .media(let media): return (tableView.bounds.width / CGFloat(media.aspectRatio))
            case .text(let _): return UITableViewAutomaticDimension
                
            }
        //} else {
        //    return UITableViewAutomaticDimension
        //}
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (tweetMention[indexPath.section][indexPath.row]) {
        case .media(let media):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ImageCellReuseIdentifier, forIndexPath: indexPath) as ImageMentionTableViewCell
            cell.imageURL = media.url
            return cell
        case .text(let text):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TextCellReuseIdentifier, forIndexPath: indexPath) as TextMentionTableViewCell
            cell.textLabel?.text = text.keyword
            cell.mentionType = sections[indexPath.section-1]
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section-1]
    }
    
   

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier { //dont forget this step
            if identifier == Storyboard.TextSearchIdentifier {
                if let ttvc = segue.destinationViewController as? TweetTableViewController { //dont forget this step
                    if let cell = sender as? TextMentionTableViewCell {
                        if let mention = cell.mentionType {
                            if mention == "Hashtags" || mention == "User Mentions" {
                                ttvc.searchText = cell.textLabel?.text
                            } else if mention == "URLs" {
                                UIApplication.sharedApplication().openURL(NSURL(string: cell.textLabel!.text!)!)
                            }
                        }
                    }
                }
            }
        }
    }
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool { //Cancel segue if needed
        if let id = identifier {
            if id == Storyboard.TextSearchIdentifier {
                if let cell = sender as? TextMentionTableViewCell {
                    if let mention = cell.mentionType {
                        if mention == "Hashtags" || mention == "User Mentions" {
                            return true
                        } else if mention == "URLs" {
                            UIApplication.sharedApplication().openURL(NSURL(string: cell.textLabel!.text!)!)
                            return false
                        }
                    }
                }
            }
        }
        return false
    }
}
