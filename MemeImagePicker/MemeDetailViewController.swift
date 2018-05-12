//
//  MemeDetailViewController.swift
//  MemeImagePicker
//
//  Created by Franziska Kammerl on 5/12/18.
//  Copyright © 2018 Franziska Kammerl. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    var image: UIImage?
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
}
