//
//  ViewController.swift
//  MemeImagePicker
//
//  Created by Franziska Kammerl on 3/18/18.
//  Copyright © 2018 Franziska Kammerl. All rights reserved.
//

import UIKit

struct Meme {
    let topText: String?
    let bottomText: String?
    let originalImage: UIImage
    
    func memedImage(from view: UIView, with size: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

class ViewController: UIViewController {

// BUTTON OUTLETS
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var PickButton: UIBarButtonItem!
    @IBOutlet weak var CameraPicker: UIBarButtonItem!
    @IBOutlet weak var TopText: UITextField!
    @IBOutlet weak var BottomText: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    let pickerController = UIImagePickerController()
    private var image: UIImage? {
        didSet {
            imagePickerView.image = image
            saveButton.isEnabled = image != nil
            shareButton.isEnabled = image != nil
        }
    }
    var memedImage: UIImage?
    
    let memeTextAttributes:[String: Any] = [
        NSAttributedStringKey.strokeColor.rawValue: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
        NSAttributedStringKey.foregroundColor.rawValue: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: 3.0
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
        TopText.text = "Top Text"
        BottomText.text = "Bottom Text"
        [TopText, BottomText].forEach { button in
            button!.textAlignment = .center
            button!.defaultTextAttributes = memeTextAttributes
        }
    }
    
    private func setupImagePicker() {
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        pickerController.allowsEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        CameraPicker.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        view.frame.origin.y = -getKeyboardHeight(notification)
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
    
    // BUTTON ACTIONS
    
    @IBAction func PickButtonPressed(_ sender: Any) {
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func CameraPickerPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        save()
        UIImageWriteToSavedPhotosAlbum(memedImage!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
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
        save()
        let activityView = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        self.present(activityView, animated: true, completion: nil)
        
        activityView.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            self.toolBar.isHidden = false
            self.navigationController?.navigationBar.isHidden = false
            if !completed {
                self.dismiss(animated: true, completion: nil)
                return
            }
        }
    }
    
    private func save() {
        toolBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        guard let image = image else { return }
        let meme = Meme(topText: TopText.text, bottomText: BottomText.text, originalImage: image)
        memedImage = meme.memedImage(from: view, with: view.frame.size)
    }
}

// MARK: IMAGE PICKER
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
