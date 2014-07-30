//
//  TweetsTableviewDelegate.swift
//  SwiftTweets
//
//  Created by Jigar M on 30/07/14.
//  Copyright (c) 2014 Jigar M. All rights reserved.
//

import UIKit

class TweetsTableviewDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
    var tweets = Array<AnyObject>()
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        let tweet = tweets[indexPath.row] as NSDictionary
        
        cell.textLabel.text = tweet["text"] as String
        cell.detailTextLabel.text = tweet["created_at"] as String
        return cell
    }
}
