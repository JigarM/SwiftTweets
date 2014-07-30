//
//  ViewController.swift
//  SwiftTweets
//
//  Created by Jigar M on 30/07/14.
//  Copyright (c) 2014 Jigar M. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    let kAPIKey = "XXXXXXXXXX" //Type API Key
    let kAPISecret = "XXXXXXXX" //Type API Secret Key
    let kPostMethod = "POST"
    let kGetMethod = "GET"
    let kContentTypeHeader = "Content-Type"
    let kAuthorizationHeader = "Authorization"
    let kOAuthRootURL = "https://api.twitter.com/oauth2/token"
    let kTimelineRootURL = "https://api.twitter.com/1.1/statuses/user_timeline.json?count=30&screen_name="
    let kAuthorizationBody = "grant_type=client_credentials"
    let kAuthorizationContentType = "application/x-www-form-urlencoded;charset=UTF-8"
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var tweetsTableViewDelegate = TweetsTableviewDelegate()
    
    @IBOutlet var textField : UITextField
    @IBOutlet var button : UIButton
    @IBOutlet var tableView : UITableView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = tweetsTableViewDelegate;
        tableView.dataSource = tweetsTableViewDelegate;
        textField.delegate = self;
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow(), animated: animated)
        if textField.text.isEmpty {
            textField.becomeFirstResponder()
        }
    }

    @IBAction func buttonWasTapped(sender : AnyObject) {
        textField.resignFirstResponder()
        spinner.startAnimating()
        if AppDelegate.shared().authorizationToken? {
            fetchTweets()
        } else {
            fetchAuthorizationToken()
        }
    }

    func fetchAuthorizationToken() {
        var tokenRequest = kOAuthRootURL.createURL().createMutableRequest()
        tokenRequest.HTTPMethod = kPostMethod
        tokenRequest.HTTPBody = kAuthorizationBody.data()
        tokenRequest.addValue(kAuthorizationContentType, forHTTPHeaderField: kContentTypeHeader)
        tokenRequest.addValue("Basic " + (kAPIKey + ":" + kAPISecret).base64Encoded(), forHTTPHeaderField: kAuthorizationHeader)
        
        NSURLConnection.sendAsynchronousRequest(tokenRequest, queue: NSOperationQueue.mainQueue(), completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if response.isHTTPResponseValid() {
                if let token = data.json()["access_token"] as? String {
                    AppDelegate.shared().authorizationToken = token
                    self.fetchTweets()
                }
            } else {
                self.showAlertViewWithMessage("Something went wrong getting token.")
            }
            
            })
        spinner.stopAnimating()
    }
    
    func fetchTweets() {
        var tweetRequest = (kTimelineRootURL + textField.text).createURL().createMutableRequest()
        tweetRequest.HTTPMethod = kGetMethod
        tweetRequest.addValue("Bearer " + AppDelegate.shared().authorizationToken!, forHTTPHeaderField: kAuthorizationHeader)
        
        NSURLConnection.sendAsynchronousRequest(tweetRequest, queue: NSOperationQueue.mainQueue(), completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if response.isHTTPResponseValid() {
                self.tweetsTableViewDelegate.tweets = data.json() as Array
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
                self.tableView.scrollToTop(animated: true)
            } else {
                self.showAlertViewWithMessage("Something went wrong getting tweets.")
            }
            })
        spinner.stopAnimating()
    }
}

