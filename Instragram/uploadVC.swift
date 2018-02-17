//
//  uploadVC.swift
//  Instragram
//
//  Created by Ahmad Idigov on 15.12.15.
//  Copyright © 2015 Akhmed Idigov. All rights reserved.
//

import UIKit
import Parse
import Photos
import MobileCoreServices


class uploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FusumaDelegate, UITextViewDelegate {

	
	@IBOutlet weak var addImageBtn: UIButton!
	@IBOutlet weak var addVideoBtn: UIButton!
	@IBOutlet weak var addVineButton: UIButton!
	
    // UI objects
    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var titleTxt: UITextView!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
	
	var videoView: UIView?
	var selectedImage: UIImage?
	var selectedVideoURL: String?
	var fusuma: FusumaViewController?
	
	fileprivate let itemsPerRow: CGFloat = 5
	fileprivate let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
	
	var duration = 0.0
	
	var totalImageCountNeeded: Int! // <-- The number of images to fetch

	var popupController: CNPPopupController?
	
	var hasMedia = false
	var loop = false
	
	
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
		
        titleTxt.becomeFirstResponder()
        titleTxt.text = "Write a caption it's optional!"
        titleTxt.delegate = self

		self.navigationController?.navigationBar.isHidden = true 
        
        // hide remove button
        removeBtn.isHidden = true
		
        
        // hide kyeboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // select image tap
        let picTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.showFusuma))
        picTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(picTap)
    }
	
    func updateViews() {
		
		if self.hasMedia {
			
			//A video or image exists, so no add buttons.
			self.addVideoBtn.isHidden = true
			self.addImageBtn.isHidden = true
			self.addVineButton.isHidden = true
		
			self.removeBtn.isHidden = false
			
			publishBtn.isEnabled = true
			publishBtn.backgroundColor = UIColor(red: 52.0/255.0, green: 169.0/255.0, blue: 255.0/255.0, alpha: 1)
			
			self.picImg.isHidden = false
			
			self.addVineButton.alpha = 1
			self.addImageBtn.alpha = 1
			self.addVideoBtn.alpha = 1
			
			UIView.animate(withDuration: 0.4, animations: {
	
				self.addVineButton.alpha = 0
				self.addImageBtn.alpha = 0
				self.addVideoBtn.alpha = 0
			})
			
		} else {
			
			self.addVideoBtn.isHidden = false
			self.addImageBtn.isHidden = false
			self.addVineButton.isHidden = false
		
			self.removeBtn.isHidden = true
			
			publishBtn.isEnabled = false
        	publishBtn.backgroundColor = .lightGray
			
        	self.picImg.isHidden = true
			
        	self.addVineButton.alpha = 0
			self.addImageBtn.alpha = 0
			self.addVideoBtn.alpha = 0
			
			UIView.animate(withDuration: 0.4, animations: {
	
				self.addVineButton.alpha = 1
				self.addImageBtn.alpha = 1
				self.addVideoBtn.alpha = 1
			})
		}
	}
    
    
    // preload func
    override func viewWillAppear(_ animated: Bool) {
		
		
		
		
		if self.selectedImage == nil && self.selectedVideoURL == nil {
		
			fusuma = FusumaViewController()
			fusuma?.delegate = self
			fusuma?.availableModes = [.library, .camera, .video]
			fusuma?.cropHeightRatio = 0.6
			fusuma?.allowMultipleSelection = false
			
			self.addVideoBtn.isHidden = false
			self.addImageBtn.isHidden = false
			
			
			if self.videoView != nil {
				
				if self.view.subviews.contains(self.videoView!) {
				
					self.videoView?.removeFromSuperview()
				}
			}
			
			self.hasMedia = false
			updateViews()
		} else {
		
		
			self.hasMedia = true
		
			updateViews()
			
			if (self.selectedVideoURL != nil) {
			
			
				let player = AVPlayer(url: URL(fileURLWithPath: selectedVideoURL!))
				
				let layer: AVPlayerLayer = AVPlayerLayer(player: player)
				layer.backgroundColor = UIColor.gray.cgColor
				layer.frame = CGRect(x: 0.0, y: 0.0, width: self.picImg.frame.size.width, height: self.picImg.frame.size.height)
				layer.videoGravity = .resizeAspect
			
				let r = self.picImg.frame
				self.videoView = UIView(frame: r)
				self.videoView?.layer.addSublayer(layer)
			
				self.picImg.isHidden = true
				self.view.addSubview(self.videoView!)
	
				player.play()
				self.loop = true
				loopVideo(videoPlayer: player)
				
			}
			
			
			
			
			//Already has image, don't change.
			// call alignment function
        		//alignment()
		}
	}
	
	func scaleUIImageToSize(image: UIImage, size: CGSize) -> UIImage {

		let hasAlpha = false
		let scale: CGFloat = 0.0 // Automatically use scale factor of main screen

		UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
		image.draw(in: CGRect(origin: CGPoint.zero, size: size))

		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return scaledImage!
	}
	
	func loopVideo(videoPlayer: AVPlayer) {
		
		print("will loop: \(self.loop)")


		NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
	
			if self.loop == true {

				videoPlayer.seek(to: kCMTimeZero)
				videoPlayer.play()
			} else {
				
				NotificationCenter.default.removeObserver(self, name: notification.name, object: nil)
			}
		}
    }
	
	
	@IBAction func addImg(_ sender: Any) {
	
		showFusuma()
	}
	
	
	@IBAction func addVid(_ sender: Any) {
	
	
		let videoPicker = UIImagePickerController()
		videoPicker.delegate = self
		videoPicker.sourceType = .photoLibrary
		videoPicker.mediaTypes = [kUTTypeMovie as String]
		self.present(videoPicker, animated: true, completion: nil)
	
		
	}
	
	
	@IBAction func addVine(_ sender: Any) {
	
	

		let vc = storyboard?.instantiateViewController(withIdentifier: "VineVC") as! VineVC
		vc.uploadVC = self
		self.present(vc, animated: true, completion: nil)
		self.loop = true
		
//		let videoPicker = UIImagePickerController()
//		videoPicker.delegate = self
//		videoPicker.sourceType = .photoLibrary
//		videoPicker.mediaTypes = [kUTTypeMovie as String]
//		videoPicker.videoMaximumDuration = 7.0
//		self.present(videoPicker, animated: true, completion: nil)
	}
	
	
	@objc func showFusuma() {
	
		self.present(fusuma!, animated: true, completion: nil)
	}
		
	func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {

		// enable publish btn
        publishBtn.isEnabled = true
        publishBtn.backgroundColor = UIColor(red: 52.0/255.0, green: 169.0/255.0, blue: 255.0/255.0, alpha: 1)
		
        // unhide remove button
        removeBtn.isHidden = false
		
        // implement second tap for zooming image
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.zoomImg))
        zoomTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(zoomTap)

		self.selectedImage = image
		
		//self.selectedImage = self.selectedImage//self.scaleUIImageToSize(image: self.selectedImage!, size: self.picImg.frame.size)
		self.picImg.image = self.selectedImage
		self.picImg.contentMode = .scaleAspectFill
		self.fusuma?.dismiss(animated: true, completion: nil)
	}
	
	func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
		
	}
	
	func fusumaVideoCompleted(withFileURL fileURL: URL) {
		
		//selectedVideoURL = fileURL.path
	}
	
	func fusumaCameraRollUnauthorized() {
		
		self.showPopupWithStyle(.centered, titleText: "Access Denied", bodyText: "Camera Roll access denied. Please go to settings and allow access.")
	}
		
    
    
    // hide kyeboard function
    @objc func hideKeyboardTap() {
        self.view.endEditing(true)
    }
    
	
    /*
    // func to cal pickerViewController
    @objc func selectImg() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
	
    
    
    // hold selected image in picImg object and dissmiss PickerController()
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        // enable publish btn
        publishBtn.isEnabled = true
        publishBtn.backgroundColor = UIColor(red: 52.0/255.0, green: 169.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        // unhide remove button
        removeBtn.isHidden = false
        
        // implement second tap for zooming image
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.zoomImg))
        zoomTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(zoomTap)
    }

    */
    
    
    // zooming in / out function
    @objc func zoomImg() {
        
        // define frame of zoomed image
        let zoomed = CGRect(x: 0, y: self.view.center.y - self.view.center.x - self.tabBarController!.tabBar.frame.size.height * 1.5, width: self.view.frame.size.width, height: self.view.frame.size.width)
        
        // frame of unzoomed (small) image
        let unzoomed = CGRect(x: 15, y: 15, width: self.view.frame.size.width / 4.5, height: self.view.frame.size.width / 4.5)
        
        // if picture is unzoomed, zoom it
        if picImg.frame == unzoomed {
            
            // with animation
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                // resize image frame
                self.picImg.frame = zoomed
                
                // hide objects from background
                self.view.backgroundColor = .black
                self.titleTxt.alpha = 0
                self.publishBtn.alpha = 0
                self.removeBtn.alpha = 0
            })
            
        // to unzoom
        } else {
            
            // with animation
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                // resize image frame
                self.picImg.frame = unzoomed
                
                // unhide objects from background
                self.view.backgroundColor = .white
                self.titleTxt.alpha = 1
                self.publishBtn.alpha = 1
                self.removeBtn.alpha = 1
            })
        }
        
    }
    
    
    // alignment
    func alignment() {
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        picImg.frame = CGRect(x: 15, y: 15, width: width / 4.5, height: width / 4.5)
        titleTxt.frame = CGRect(x: picImg.frame.size.width + 25, y: picImg.frame.origin.y, width: width / 1.488, height: picImg.frame.size.height)
        publishBtn.frame = CGRect(x: 0, y: height / 1.09, width: width, height: width / 8)
        removeBtn.frame = CGRect(x: picImg.frame.origin.x, y: picImg.frame.origin.y + picImg.frame.size.height, width: picImg.frame.size.width, height: 20)
    }
    
    
    // clicked publish button
    @IBAction func publishBtn_clicked(_ sender: AnyObject) {
        
        // dissmiss keyboard
        self.view.endEditing(true)
		
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.backgroundColor = UIColor.gray
        indicator.frame = self.view.frame
        indicator.startAnimating()
		self.navigationController?.view.addSubview(indicator)
        
        // send data to server to "posts" class in Parse
        let object = PFObject(className: "posts")
        object["username"] = PFUser.current()!.username
        object["ava"] = PFUser.current()!.value(forKey: "ava") as! PFFile
        
        let uuid = UUID().uuidString
        object["uuid"] = "\(PFUser.current()!.username!) \(uuid)"
        
        if titleTxt.text.isEmpty {
            object["title"] = ""
        } else {
            object["title"] = titleTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
		
        if self.selectedImage != nil {
			
        	// send pic to server after converting to FILE and comprassion
        	let imageData = UIImageJPEGRepresentation(picImg.image!, 0.5)
        	let imageFile = PFFile(name: "post.jpg", data: imageData!)
        	object["media"] = imageFile
        	object["type"] = "image"
			object["contentType"] = "tma"
			
		} else if self.selectedVideoURL != nil {
		
			//Video.
			let videoData = NSData(contentsOfFile: self.selectedVideoURL!)
			let videoFile = PFFile(name: "post.mov", data: videoData! as Data)
			object["media"] = videoFile
			object["type"] = "video"
			object["duration"] = self.duration
			
			if duration > 7.0 {
				
				object["contentType"] = "tma"
			} else {
				
				object["contentType"] = "vine"
			}
			
		} else { print("no image or video") }
		
		
		
		
		
		
		
        
        
        // send #hashtag to server
        let words:[String] = titleTxt.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        // define taged word
        for var word in words {
            
            // save #hasthag in server
            if word.hasPrefix("#") {
                
                // cut symbold
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let hashtagObj = PFObject(className: "hashtags")
                hashtagObj["to"] = "\(PFUser.current()!.username!) \(uuid)"
                hashtagObj["by"] = PFUser.current()?.username
                hashtagObj["hashtag"] = word.lowercased()
                hashtagObj["comment"] = titleTxt.text
                hashtagObj.saveInBackground(block: { (success, error) -> Void in
                    if success {
                        print("hashtag \(word) is created")
                    } else {
                        print(error!.localizedDescription)
                        indicator.removeFromSuperview()
                    }
                })
            }
        }
        
        
        // finally save information
        object.saveInBackground (block: { (success, error) -> Void in
            if error == nil {
                
                // send notification wiht name "uploaded"
                NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)
                
                // switch to another ViewController at 0 index of tabbar
                self.tabBarController!.selectedIndex = 0
                
                // reset everything
                self.viewDidLoad()
                self.titleTxt.text = ""
				
				indicator.removeFromSuperview()
				
				
				
            } else { indicator.removeFromSuperview() }
        })
        
    }
    
    
    // clicked remove button
    @IBAction func removeBtn_clicked(_ sender: AnyObject) {
		
		
        self.selectedVideoURL = nil
        self.selectedImage = nil
		self.loop = false
		
		for v in self.view.layer.sublayers! {
			
			if v.classForCoder == AVPlayer.classForCoder() {
				
				v.removeFromSuperlayer()
			}
		}
		
        self.viewWillAppear(false)
    }
	
	
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
			viewController.navigationItem.title = "Choose Video"
	}
    
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		
		let url = info[UIImagePickerControllerMediaURL] as! URL
		self.selectedVideoURL = url.path
	
		publishBtn.isEnabled = true
        publishBtn.backgroundColor = UIColor(red: 52.0/255.0, green: 169.0/255.0, blue: 255.0/255.0, alpha: 1)
		
        removeBtn.isHidden = false
		
		
		let asset = AVURLAsset(url: url, options: nil)
		let durationInSeconds = asset.duration.seconds
		self.duration = durationInSeconds
		
		picker.dismiss(animated: true, completion: nil)
		
	}

	//MARK:
	//MARK: Animation
	
	func showPopupWithStyle(_ popupStyle: CNPPopupStyle, titleText: String, bodyText: String) {
		
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.alignment = NSTextAlignment.center
		
        let title = NSAttributedString(string: titleText, attributes: [NSAttributedStringKey.font:UIFont(name: "AvenirNext-Bold", size: 20)!, NSAttributedStringKey.paragraphStyle: paragraphStyle, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)])
        let description = NSAttributedString(string: bodyText, attributes: [NSAttributedStringKey.font:UIFont(name: "AvenirNext-Bold", size: 14)!, NSAttributedStringKey.paragraphStyle: paragraphStyle, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 1)])
		
		
        let button = CNPPopupButton.init(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 20)!
        button.setTitle("Okay", for: UIControlState())
		
        button.backgroundColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
		
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
		
		
            self.popupController?.dismiss(animated: true)
        }
		
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0;
        titleLabel.attributedText = title
		
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.attributedText = description;
		
        let popupController = CNPPopupController(contents:[titleLabel, descriptionLabel, button])
        popupController.theme = .default()
        popupController.theme.popupStyle = popupStyle
        popupController.delegate = self
        self.popupController = popupController
        popupController.present(animated: true)
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
	
		self.titleTxt.text = ""
	}
}

extension uploadVC : UICollectionViewDelegateFlowLayout {
  //1
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
    //2
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow

    return CGSize(width: widthPerItem, height: widthPerItem)
  }
	
  //3
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                             insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }

  // 4
  func collectionView(_ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
}

extension uploadVC : CNPPopupControllerDelegate {
	
    func popupControllerWillDismiss(_ controller: CNPPopupController) {
        //print("Popup controller will be dismissed")
    }
	
    func popupControllerDidPresent(_ controller: CNPPopupController) {
        //print("Popup controller presented")
    }
}
