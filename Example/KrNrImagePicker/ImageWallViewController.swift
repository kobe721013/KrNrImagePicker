//
//  ImageWallViewController.swift
//  KrNrImagePicker_Example
//
//  Created by 林詠達 on 2021/7/28.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class ImageWallViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ImageWallViewController : UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! KobeCollectionViewCell
          cell.imageview.image = UIImage(named: "web_maintenance")
        
            
       
        
        
          return cell
    }
    
    
}

extension ImageWallViewController : UICollectionViewDelegate
{
    
}
