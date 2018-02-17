//
//  postCell.swift
//  Instragram
//
//  Created by Ahmad Idigov on 17.12.15.
//  Copyright © 2015 Akhmed Idigov. All rights reserved.
//

import UIKit
import Parse
import AVFoundation


class postCell: UITableViewCell {

    // header objects
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    
    // main picture
    @IBOutlet weak var picImg: UIImageView!
    
    // buttons
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    
    // labels
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var titleLbl: KILabel!
    @IBOutlet weak var uuidLbl: UILabel!
	
    var isImage = false
    var player: AVPlayer?
	
	
    func animateViews() {
		
    	self.avaImg.alpha = 0
    	self.usernameBtn.alpha = 0
    	self.dateLbl.alpha = 0
    	self.picImg.alpha = 0
    	self.likeBtn.alpha = 0
    	self.commentBtn.alpha = 0
    	self.moreBtn.alpha = 0
    	self.likeBtn.alpha = 0
    	self.titleLbl.alpha = 0
    	self.uuidLbl.alpha = 0
		
    	UIView.animate(withDuration: 0.4) {

			self.avaImg.alpha = 1
    		self.usernameBtn.alpha = 1
			self.dateLbl.alpha = 1
    		self.picImg.alpha = 1
    		self.likeBtn.alpha = 1
    		self.commentBtn.alpha = 1
    		self.moreBtn.alpha = 1
    		self.likeBtn.alpha = 1
    		self.titleLbl.alpha = 1
    		self.uuidLbl.alpha = 1
		}
	}
	
    
    // default func
    override func awakeFromNib() {
        super.awakeFromNib()
		
		
		
        // clear like button title color
		likeBtn.setTitleColor(UIColor.clear, for: .normal)
		
        // double tap to like
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(postCell.likeTap))
        likeTap.numberOfTapsRequired = 2
		picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(likeTap)
		
		print("awake from nib")
		
       align()
        
    }
	
    func align() {
		
    	// alignment
		let width = UIScreen.main.bounds.width
		
        // allow constraints
        avaImg.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
		
        picImg.translatesAutoresizingMaskIntoConstraints = false
		
        likeBtn.translatesAutoresizingMaskIntoConstraints = false
        commentBtn.translatesAutoresizingMaskIntoConstraints = false
        moreBtn.translatesAutoresizingMaskIntoConstraints = false
		
        likeLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        uuidLbl.translatesAutoresizingMaskIntoConstraints = false
		
        let pictureWidth = width
		
		
		
		let avax = (width / 2) - (75 / 2)
		print("avax \(avax)")
		
        // constraints
		self.contentView.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "V:|-5-[ava(75)]-10-[username]-10-[pic(\(pictureWidth))]-5-[like(30)]",
			options: [], metrics: nil, views: ["ava":avaImg, "pic":picImg, "like":likeBtn, "username":usernameBtn]))
	
		
	
		self.contentView.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "V:[pic]-5-[comment(30)]",
		options: [], metrics: nil, views: ["pic":picImg, "comment":commentBtn]))
	
		self.contentView.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "V:|-15-[date]",
		options: [], metrics: nil, views: ["date":dateLbl]))
	
		self.contentView.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "V:[like]-5-[title]-5-|",
		options: [], metrics: nil, views: ["like":likeBtn, "title":titleLbl]))
	
		self.contentView.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "V:[pic]-5-[more(30)]",
		options: [], metrics: nil, views: ["pic":picImg, "more":moreBtn]))
	
		self.contentView.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "V:[pic]-10-[likes]",
		options: [], metrics: nil, views: ["pic":picImg, "likes":likeLbl]))
	
		self.contentView.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "H:|-\(avax)-[ava(75)]",
		options: [], metrics: nil, views: ["ava":avaImg]))
		
		let x = (self.frame.size.width / 2) - 25
		print(x)
		
		self.contentView.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "H:|-100-[username]-100-|",
		options: [], metrics: nil, views: ["username":usernameBtn]))
	
		
	
		self.contentView.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "H:|-0-[pic]-0-|",
		options: [], metrics: nil, views: ["pic":picImg]))
	
		self.contentView.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "H:|-15-[like(30)]-10-[likes]-20-[comment(30)]",
		options: [], metrics: nil, views: ["like":likeBtn, "likes":likeLbl, "comment":commentBtn]))
	
		self.contentView.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "H:[more(30)]-15-|",
		options: [], metrics: nil, views: ["more":moreBtn]))
	
		self.contentView.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "H:|-15-[title]-15-|",
		options: [], metrics: nil, views: ["title":titleLbl]))
	
		self.contentView.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "H:|[date]-10-|",
		options: [], metrics: nil, views: ["date":dateLbl]))
		
        // round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
	}
    
    
    // double tap to like
    @objc func likeTap() {
        
        // create large like gray heart
        let likePic = UIImageView(image: UIImage(named: "unlike.png"))
        likePic.frame.size.width = picImg.frame.size.width / 1.5
        likePic.frame.size.height = picImg.frame.size.width / 1.5
        likePic.center = picImg.center
        likePic.alpha = 0.8
        self.addSubview(likePic)
        
        // hide likePic with animation and transform to be smaller
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            likePic.alpha = 0
            likePic.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) 
        
        // declare title of button
        let title = likeBtn.title(for: UIControlState())
        
        if title == "unlike" {
            
            let object = PFObject(className: "likes")
            object["by"] = PFUser.current()?.username
            object["to"] = uuidLbl.text
            object.saveInBackground(block: { (success, error) -> Void in
                if success {
                    print("liked")
                    self.likeBtn.setTitle("like", for: UIControlState())
                    self.likeBtn.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState())
                    
                    // send notification if we liked to refresh TableView
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "liked"), object: nil)
                    
                    
                    // send notification as like
                    if self.usernameBtn.titleLabel?.text != PFUser.current()?.username {
                        let newsObj = PFObject(className: "news")
                        newsObj["by"] = PFUser.current()?.username
                        newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                        newsObj["to"] = self.usernameBtn.titleLabel!.text
                        newsObj["owner"] = self.usernameBtn.titleLabel!.text
                        newsObj["uuid"] = self.uuidLbl.text
                        newsObj["type"] = "like"
                        newsObj["checked"] = "no"
                        newsObj.saveEventually()
                    }
                    
                }
            })
            
        }
        
    }
    
    
    // clicked like button
    @IBAction func likeBtn_click(_ sender: AnyObject) {
        
        // declare title of button
        let title = sender.title(for: UIControlState())
        
        // to like
        if title == "unlike" {
            
            let object = PFObject(className: "likes")
            object["by"] = PFUser.current()?.username
            object["to"] = uuidLbl.text
            object.saveInBackground(block: { (success, error) -> Void in
                if success {
                    print("liked")
                    self.likeBtn.setTitle("like", for: UIControlState())
                    self.likeBtn.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState())
                    
                    // send notification if we liked to refresh TableView
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "liked"), object: nil)
                    
                    // send notification as like
                    if self.usernameBtn.titleLabel?.text != PFUser.current()?.username {
                        let newsObj = PFObject(className: "news")
                        newsObj["by"] = PFUser.current()?.username
                        newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                        newsObj["to"] = self.usernameBtn.titleLabel!.text
                        newsObj["owner"] = self.usernameBtn.titleLabel!.text
                        newsObj["uuid"] = self.uuidLbl.text
                        newsObj["type"] = "like"
                        newsObj["checked"] = "no"
                        newsObj.saveEventually()
                    }
                    
                }
            })
            
        // to dislike
        } else {
            
            // request existing likes of current user to show post
            let query = PFQuery(className: "likes")
            query.whereKey("by", equalTo: PFUser.current()!.username!)
            query.whereKey("to", equalTo: uuidLbl.text!)
            query.findObjectsInBackground { (objects, error) -> Void in
                
                // find objects - likes
                for object in objects! {
                    
                    // delete found like(s)
                    object.deleteInBackground(block: { (success, error) -> Void in
                        if success {
                            print("disliked")
                            self.likeBtn.setTitle("unlike", for: UIControlState())
                            self.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState())
                            
                            // send notification if we liked to refresh TableView
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "liked"), object: nil)
                            
                            
                            // delete like notification
                            let newsQuery = PFQuery(className: "news")
                            newsQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                            newsQuery.whereKey("to", equalTo: self.usernameBtn.titleLabel!.text!)
                            newsQuery.whereKey("uuid", equalTo: self.uuidLbl.text!)
                            newsQuery.whereKey("type", equalTo: "like")
                            newsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                                if error == nil {
                                    for object in objects! {
                                        object.deleteEventually()
                                    }
                                }
                            })
                            
                            
                        }
                    })
                }
            }
            
        }
        
    }
    
    
}
