//
//  PostVC.swift
//  ParseStarterProject-Swift
//
//  Created by Jason Ngo on 2016-12-10.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class PostVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imagePosted: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postBtn.layer.cornerRadius = postBtn.frame.size.height / 2
        postBtn.clipsToBounds = true
        
        resetBtn.layer.cornerRadius = resetBtn.frame.size.height / 2
        resetBtn.clipsToBounds = true
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(PostVC.imageTapped))
        imagePosted.isUserInteractionEnabled = true
        imagePosted.addGestureRecognizer(tapGR)
    }
    
    func imageTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePosted.image = image
            picker.dismiss(animated: true, completion: nil)
        } else {
            print("Error choosing a picture")
        }
    }
    
    func resetToDefaultState() {
        imagePosted.image = UIImage(named: "person.png")
        captionTextField.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func postBtnPressed(_ sender: Any) {
        let post = PFObject(className: "Posts")
        
        post["caption"] = captionTextField.text
        post["userid"] = PFUser.current()?.objectId
        
        if imagePosted.image != UIImage(named: "person.png") && captionTextField.text != "" {
            let imageData = UIImagePNGRepresentation(imagePosted.image!)
            let imageFIle = PFFile(name: "image.png", data: imageData!)
            
            post["image"] = imageFIle
            
            self.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            post.saveInBackground(block: { (success, error) in
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()

                if success {
                    self.createAlertWith(title: "Image posted successfully", message: "")
                    self.resetToDefaultState()
                } else {
                    self.createAlertWith(title: "Image unsuccessfully posted", message: "")
                }
            })
        }
    }
    
    @IBAction func resetBtnPressed(_ sender: Any) {
        resetToDefaultState()
    }
    
    func createAlertWith(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
            print("OK button pressed")
        })
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
