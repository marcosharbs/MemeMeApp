//
//  ViewController.swift
//  MemeMe
//
//  Created by Marcos Harbs on 02/04/18.
//  Copyright © 2018 Marcos Harbs. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var topTextView: UITextField!
    @IBOutlet weak var bottomTextView: UITextField!
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var cameraItem: UIBarButtonItem!
    @IBOutlet weak var shareItem: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    let memeTextAttributes:[String:Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -4.0]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraItem.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField(textField: topTextView, text: "TOP")
        configureTextField(textField: bottomTextView, text: "BOTTOM")
        shareItem.isEnabled = false;
    }
    
    func configureTextField(textField: UITextField, text: String) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = text
        textField.delegate = self
    }
    
    @IBAction func onAlbumClicked(_ sender: Any) {
        pickImage(sourceType: .photoLibrary)
    }
    
    @IBAction func onCameraClicked(_ sender: Any) {
        pickImage(sourceType: .camera)
    }
    
    func pickImage(sourceType: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        self.present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func onShareMeme(_ sender: Any) {
        let memedImage = generateMemedImage()
        let imageToShare = [memedImage]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {activity, success, items, error in
            if success {
                self.save(memedImage: memedImage)
            }
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        topTextView.text = "TOP"
        bottomTextView.text = "BOTTOM"
        memeImageView.image = nil
        shareItem.isEnabled = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func save(memedImage: UIImage) {
        // MARK: - Create the meme
        let meme = Meme(topText: topTextView.text!, bottomText: bottomTextView.text!, originalImage: memeImageView.image!, memedImage: memedImage)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
        self.dismiss(animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        configureBarVisibility(hidden: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        configureBarVisibility(hidden: false)
        
        return memedImage
    }
    
    func configureBarVisibility(hidden: Bool) {
        topToolbar.isHidden = hidden
        bottomToolbar.isHidden = hidden
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            shareItem.isEnabled = true;
            memeImageView.image = image
            memeImageView.contentMode = UIViewContentMode.scaleAspectFit
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let id = textField.restorationIdentifier {
            if id == "topTextView" && textField .text == "TOP" {
                textField.text = ""
            } else if id == "bottomTextView" && textField .text == "BOTTOM" {
                textField.text = ""
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        let empty = textField.text?.isEmpty
        let id = textField.restorationIdentifier
        
        if empty! {
            if id == "topTextView" {
                textField.text = "TOP"
            } else if id == "bottomTextView" {
                textField.text = "BOTTOM"
            }
        }
        
        return true;
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextView.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
}


