//
//  SentMemesViewController.swift
//  MemeImagePicker
//
//  Created by Franziska Kammerl on 4/22/18.
//  Copyright © 2018 Franziska Kammerl. All rights reserved.
//

import Foundation
import UIKit

class SentMemesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var memes: [[String : Any?]]?
    private var selectedImage: UIImage?
    private var isGrid = true {
        didSet {
            guard oldValue != isGrid else { return }
            collectionView.reloadData()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isHidden = false
        
        let flowLayout = UICollectionViewFlowLayout()
        collectionView?.setCollectionViewLayout(flowLayout, animated: true)
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)

        if let memesArr = UserDefaults.standard.array(forKey: "memes") as? [[String : Any?]] {
            memes = memesArr
        }
    }
    
    @IBAction func gridButtonPressed(_ sender: Any) {
        isGrid = true
    }
    
    @IBAction func listButtonPressed(_ sender: Any) {
        isGrid = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let memes = memes else { return UICollectionViewCell() }
        let meme = memes[indexPath.row]
        guard let imageData = meme["imageData"] as? Data else { return UICollectionViewCell() }
        let image = UIImage(data: imageData)
        
        if isGrid {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath as IndexPath) as! ImageCell
            cell.imageView.image = image
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageTitleCell", for: indexPath as IndexPath)
                as! ImageTitleCell
            cell.imageView.image = image
            cell.titleLabel.text = meme["title"] as? String
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = collectionView.bounds.width / 3
        return CGSize(width: isGrid ? cellHeight : collectionView.bounds.width, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0 
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let memes = memes else { return }
        let meme = memes[indexPath.row]
        guard let imageData = meme["imageData"] as? Data else { return }
        let image = UIImage(data: imageData)
        selectedImage = image
        performSegue(withIdentifier: "detail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? MemeDetailViewController else { return }
        vc.image = selectedImage
    }
    
}
