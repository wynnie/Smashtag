//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Vinod Ananth on 3/1/15.
//  Copyright (c) 2015 Vinod Ananth. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    //Set property refreshing = enabled in IB
    
    var tweets = [[Tweet]]()  //Array of array of tweets. First array is a section and each section has many tweets
    var searchText: String? = "#stanford" {
        didSet {
            lastSuccessfulRequest = nil  //As soon as something new, this should be nil
            searchTextField?.text = searchText
            tweets.removeAll()
            tableView.reloadData()
            refresh()
        }
    }

    //MARK: - View controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight //Height coming out of storyboard
        tableView.rowHeight = UITableViewAutomaticDimension //Variable from super
        refresh()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    var lastSuccessfulRequest: TwitterRequest?
    var nextRequestToAttempt: TwitterRequest? {
        if lastSuccessfulRequest == nil {
            if searchText != nil {
                return TwitterRequest(search: searchText!, count: 100)
            } else {
                return nil
            }
        } else {
            return lastSuccessfulRequest!.requestForNewer
        }
    }
    
    func refresh () {
        if refreshControl != nil {
            refreshControl?.beginRefreshing()
        }
        refresh(refreshControl)
    }

    @IBAction func refresh(sender: UIRefreshControl?) {
        if searchText != nil {
            if let request = nextRequestToAttempt {
                //fetchTweets is an asynchronous API. So we cannot do UI stuff unless we dispatch_async to main queue
                request.fetchTweets { (newTweets) -> Void in //function handler as closure
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        if newTweets.count > 0 {
                            self.tweets.insert(newTweets, atIndex: 0)
                            self.tableView.reloadData()
                            sender?.endRefreshing()
                        }
                    }
                }
            }
        } else {
            sender?.endRefreshing()
        }
        
    }
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //Set keyboard type in this text field to be a "Twitter" keyboard
        if textField == searchTextField {
            textField.resignFirstResponder() //remove keyboard
            searchText = textField.text
        }
        return true
    }
    
    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    private struct Storyboard {
        static let CellReuseIdentifier = "Tweet"  //This is the same identifier used in the prototype TableViewCell in the storyboard, needed for the reuse Q
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as TweetTableViewCell

        // Configure the cell...
        cell.tweet = tweets[indexPath.section][indexPath.row]
        return cell
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
        if let mtvc = segue.destinationViewController as? MentionsTableViewController { //dont forget this step
            if let identifier = segue.identifier { //dont forget this step
                if identifier == "TweetMention" {
                    if let tweetCell = sender as? TweetTableViewCell {
                        mtvc.tweet = tweetCell.tweet
                    }
                }
            }
        }
    }
    @IBAction func newSearchFromMention(segue:UIStoryboardSegue) { //For unwind segue, must have only one argument and should be IBAction
        
    }
    

}
