//
//  UsersTableVC.swift
//  ParseStarterProject-Swift
//
//  Created by Jason Ngo on 2016-12-09.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class UsersTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var usernames = [String]()
    var userIDs = [String]()
    var isFollowing = [String : Bool]()
    
    @IBOutlet var tableView: UITableView!
    
    var refreshController: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        
        refreshController = UIRefreshControl()
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshController.addTarget(self, action: #selector(UsersTableVC.refresh), for: .valueChanged)
        tableView.addSubview(refreshController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logoutBtnPressed(_ sender: Any) {
        PFUser.logOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    func refresh() {
        let usersQuery = PFUser.query()
        
        usersQuery?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print("Error querying users")
            } else {
                if let users = objects {
                    self.usernames.removeAll()
                    self.userIDs.removeAll()
                    self.isFollowing.removeAll()
                    
                    for object in users {
                        if let user = object as? PFUser {
                            if user.objectId != PFUser.current()?.objectId {
                                let usernameArray = user.username!.components(separatedBy: "@")
                                
                                self.usernames.append(usernameArray[0])
                                self.userIDs.append(user.objectId!)
                                
                                let followingQuery = PFQuery(className: "Followers")
                                
                                followingQuery.whereKey("follower", equalTo: (PFUser.current()?.objectId)!)
                                followingQuery.whereKey("following", equalTo: user.objectId!)
                                
                                followingQuery.findObjectsInBackground(block: { (objects, error) in
                                    if error != nil {
                                        print("There was an error grabbing the following relationships")
                                    } else {
                                        if objects != nil {
                                            self.isFollowing[user.objectId!] = objects!.count > 0 ? true : false
                                        }
                                        
                                        if self.isFollowing.count == self.usernames.count {
                                            self.tableView.reloadData()
                                            self.refreshController.endRefreshing()
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            }
        })
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath)
        
        cell.textLabel?.text = usernames[indexPath.row]
        
        if isFollowing[userIDs[indexPath.row]] == true {
            cell.accessoryType = .checkmark
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if isFollowing[userIDs[indexPath.row]]! == true {
                
                isFollowing[userIDs[indexPath.row]]! = false
                cell.accessoryType = .none
                
                let followingQuery = PFQuery(className: "Followers")
                
                followingQuery.whereKey("follower", equalTo: (PFUser.current()?.objectId)!)
                followingQuery.whereKey("following", equalTo: userIDs[indexPath.row])
                
                followingQuery.findObjectsInBackground(block: { (objects, error) in
                    if error != nil {
                        print("There was an error grabbing the following relationships")
                    } else {
                        if let objects = objects {
                            for object in objects {
                                object.deleteInBackground()
                            }
                        }
                    }
                })
            } else {
                
                isFollowing[userIDs[indexPath.row]]! = true
                
                cell.accessoryType = .checkmark
                
                let followingObject = PFObject(className: "Followers")
                
                followingObject["follower"] = PFUser.current()?.objectId
                followingObject["following"] = userIDs[indexPath.row]
                
                followingObject.saveInBackground(block: { (success, error) in
                    if error != nil {
                        print("Following relationship not saved")
                    } else {
                        print("Following relationship: \(PFUser.current()!.objectId)) is following \(self.userIDs[indexPath.row])")
                    }
                })
            }
        }
    }

}
