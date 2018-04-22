//
//  MemeEditorViewController.swift
//  MemeImagePicker
//
//  Created by Franziska Kammerl on 3/18/18.
//  Copyright © 2018 Franziska Kammerl. All rights reserved.
//

import UIKit

struct Meme {
    let image: UIImage
    let topText: String?
    let bottomText: String?
    
    func memedImage(from view: UIView, with size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

class MemeEditorViewController: UIViewController {

// BUTTON OUTLETS
    
    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var pickButton: UIBarButtonItem!
    
    @IBOutlet weak var cameraPicker: UIBarButtonItem!
    
    @IBOutlet weak var topText: UITextField!
    
    @IBOutlet weak var bottomText: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    private var meme: Meme?

    
    let pickerController = UIImagePickerController()
    private var image: UIImage? {
        didSet {
            imagePickerView.image = image
            saveButton.isEnabled = image != nil
            shareButton.isEnabled = image != nil
        }
    }
    
    let memeTextAttributes:[String: Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -3.0
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        shareButton.isEnabled = false
        setupTextFields()
        setupImagePicker()
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(didTapView))
        view.addGestureRecognizer(gesture)
    }
    
    @objc func didTapView() {
        view.endEditing(true)
        toolBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
    }
   
    private func setupTextFields() {
        [topText, bottomText].forEach { textField in
            textField!.defaultTextAttributes = memeTextAttributes
            textField!.textAlignment = .center
            textField?.delegate = self
        }
    }
    
    private func setupImagePicker() {
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        pickerController.allowsEditing = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        cameraPicker.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    private var memedImage: UIImage {
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let bottomEditing = bottomText.isEditing
        if bottomEditing == true {
            view.frame.origin.y = -getKeyboardHeight(notification)
        } else { return }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat  {
        let userInfo = notification.userInfo
        let keyboardSize = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    private func presentPicker(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    // BUTTON ACTIONS
    
    @IBAction func pickButtonPressed(_ sender: Any) {
        presentPicker(sourceType: .photoLibrary)
    }
    
    @IBAction func cameraPickerPressed(_ sender: Any) {
        presentPicker(sourceType: .camera)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        save()
    }
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        changeChrome(isHidden: true)
        let activityView = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityView.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            self.changeChrome(isHidden: false)
            if completed {
                self.save()
            } else {
                self.dismiss(animated: true, completion: nil)
                return
            }
        }
    
        self.present(activityView, animated: true, completion: nil)
    }
    
    private func save() {
        guard let image = image else { return }
        changeChrome(isHidden: true)
        let meme = Meme(image: image, topText: topText.text, bottomText: bottomText.text)
        let memedImage = meme.memedImage(from: view, with: view.frame.size)
        UIImageWriteToSavedPhotosAlbum(memedImage, self, nil, nil)
        changeChrome(isHidden: false)
    }
    
    private func changeChrome(isHidden: Bool) {
        toolBar.isHidden = isHidden
        navigationController?.navigationBar.isHidden = isHidden
    }
}

// MARK: IMAGE PICKER
extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


// MARK: TEXTFIELD DELEGATE
extension MemeEditorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
