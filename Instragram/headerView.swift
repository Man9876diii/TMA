//
//  headerView.swift
//  Instragram
//
//  Created by Ahmad Idigov on 10.12.15.
//  Copyright © 2015 Akhmed Idigov. All rights reserved.
//

import UIKit
import Parse


class headerView: UICollectionReusableView {
    
    // UI objects
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var fullnameLbl: UILabel!
    @IBOutlet weak var webTxt: UITextView!
    @IBOutlet weak var bioLbl: UILabel!
    
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var followings: UILabel!
	
    @IBOutlet weak var followersTitle: UILabel!
    @IBOutlet weak var followingsTitle: UILabel!
    
    @IBOutlet weak var button: UIButton!
	@IBOutlet weak var tapBar: UISegmentedControl!
	
    
    // default func
    override func awakeFromNib() {
        super.awakeFromNib()
		
		
		

		
        // alignment
        let width = UIScreen.main.bounds.width
        
        avaImg.frame = CGRect(x: (width / 2) - ((width / 4) / 2), y: width / 16, width: width / 4, height: width / 4)
		
		var fx1 = 25.5
		var fx2 = width - 75.0
		
		followers.frame = CGRect(x: CGFloat(fx1), y: avaImg.frame.origin.y + 30, width: 50, height: 30)
        followings.frame = CGRect(x: CGFloat(fx2), y: avaImg.frame.origin.y + 30, width: 50, height: 30)
        
        followersTitle.center = CGPoint(x: followers.center.x, y: followers.center.y + 20)
        followingsTitle.center = CGPoint(x: followings.center.x, y: followings.center.y + 20)
		
		tapBar.center = CGPoint(x: avaImg.center.x, y: bioLbl
		.center.y + 65)
		
        button.frame = CGRect(x: (width / 2) - 50.0, y: avaImg.frame.origin.y + avaImg.frame.size.height, width: 100, height: 30)
        button.layer.cornerRadius = button.frame.size.width / 50
        
        fullnameLbl.frame = CGRect(x: 0.0, y: avaImg.frame.origin.y + avaImg.frame.size.height + 30.0, width: width, height: 30)
        fullnameLbl.textAlignment = .center
		
		
        //webTxt.frame = CGRect(x: avaImg.frame.origin.x - 5, y: fullnameLbl.frame.origin.y + 15, width: width - 30, height: 30)
		webTxt.isHidden = true
        bioLbl.frame = CGRect(x: 0.0, y: fullnameLbl.frame.origin.y + fullnameLbl.frame.size.height + 10, width: width, height: 30)
        bioLbl.textAlignment = .center 
        
        // round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
	
		
	
    }
    
    @IBAction func block(sender: AnyObject) {
//        let blockQuery = PFQuery(className: "blocked")
//        blockQuery.whereKey("by", equalTo: "currentUsername")
//        blockQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
//            var blockedUsernames: Set<String> = []
//            if let objects = objects {
//                for object in objects {
//                    blockedUsernames.append(object.valueForKey("blocked") as! String)
//                }
//            }
//            
//            /// Now we get all the names of the users the current user is following
//            let followingQuery = PFQuery(className: "follow")
//            followingQuery.whereKey("follower", equalTo: "currentUsername")
//            followingQuery.orderByAscending("createdAt")
//            followingQuery.findObjectsInBackgroundWithBlock { (objects: [PFObjects]?, error: NSError?) in
//                var usernamesFollowing: Set<String> = []
//                if let objects = objects {
//                    for object in objects {
//                        usernamesFollowing.append(object.valueForKey("following") as! String)
//                    }
//                }
//                
//                /// Finally we subtract all the blockedUsernames from usernames we are following, remember to add the currentUsername into this
//                let usernamesToLoad = usernamesFollowing.subtract(blockedUsernames)
//                
//            }
//        }

    }
    
    // clicked follow button from GuestVC
    @IBAction func followBtn_clicked(_ sender: AnyObject) {
        
        let title = button.title(for: UIControlState())
        
        // to follow
        if title == "FOLLOW" {
            let object = PFObject(className: "follow")
            object["follower"] = PFUser.current()?.username
            object["following"] = guestname.last!
            object.saveInBackground(block: { (success, error) -> Void in
                if success {
                    self.button.setTitle("FOLLOWING", for: UIControlState())
                    self.button.backgroundColor = .green
                    
                    // send follow notification
                    let newsObj = PFObject(className: "news")
                    newsObj["by"] = PFUser.current()?.username
                    newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                    newsObj["to"] = guestname.last
                    newsObj["owner"] = ""
                    newsObj["uuid"] = ""
                    newsObj["type"] = "follow"
                    newsObj["checked"] = "no"
                    newsObj.saveEventually()
					
                    //Now append the # of followers for the guest obj.
					
                    let query = PFQuery(className: "_User")
                    query.whereKey("username", equalTo: guestname.last!)
                    query.limit = 1
                    query.findObjectsInBackground(block: { (objects, error) in
	
						if error == nil && objects?.count != 0 {
						
							let user = objects?.first!
							let request: [AnyHashable:Any] = ["displayedUserId":user?.objectId!]

							PFCloud.callFunction(inBackground: "addFollower", withParameters: request, block: { (obj, error) in
							
								if error == nil {
									
									
								} else { print(error!) }
							})
							
						} else {
							
							print(error!)
						}
					})
                    
                } else {
                    print(error?.localizedDescription ?? String())
                }
            })
            
            // unfollow
        } else {
            let query = PFQuery(className: "follow")
            query.whereKey("follower", equalTo: PFUser.current()!.username!)
            query.whereKey("following", equalTo: guestname.last!)
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    for object in objects! {
                        object.deleteInBackground(block: { (success, error) -> Void in
                            if success {
                                self.button.setTitle("FOLLOW", for: UIControlState())
                                self.button.backgroundColor = .lightGray
                                
                                
                                // delete follow notification
                                let newsQuery = PFQuery(className: "news")
                                newsQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                newsQuery.whereKey("to", equalTo: guestname.last!)
                                newsQuery.whereKey("type", equalTo: "follow")
                                newsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                                    if error == nil {
                                        for object in objects! {
                                            object.deleteEventually()
                                        }
                                    }
                                })
                                
                                
                            } else {
                                print(error?.localizedDescription ?? String())
                            }
                        })
                    }
                    
                } else {
                    print(error?.localizedDescription ?? String())
                }
            })
            
        }
		
        //Now append the # of followers for the guest obj.
		
		let equery = PFQuery(className: "_User")
		equery.whereKey("username", equalTo: guestname.last!)
		equery.limit = 1
		equery.findObjectsInBackground(block: { (objects, error) in

			if error == nil && objects?.count != 0 {
			
				let user = objects?.first!
				let request: [AnyHashable:Any] = ["displayedUserId":user?.objectId!]

				PFCloud.callFunction(inBackground: "removeFollower", withParameters: request, block: { (obj, error) in
				
					if error == nil {
						
						
					} else { print(error!) }
				})
				
			} else {
				
				print(error!)
			}
		})
        
    }
   
}
