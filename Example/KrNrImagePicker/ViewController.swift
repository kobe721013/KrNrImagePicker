//
//  ViewController.swift
//  KrNrImagePicker
//
//  Created by kobe721013 on 06/17/2021.
//  Copyright (c) 2021 kobe721013. All rights reserved.
//

import UIKit
import KrNrImagePicker
import Photos
class ViewController: UIViewController {

    var highlightAssets:[String]!
  //["7E5F6D7F-E444-482B-8423-53D1C9D724AD/L0/001","C93A4418-ACF5-4B8E-B01D-00B7A87B9DC4/L0/001","C5FEFE60-0ADB-4A7B-9869-69D4A002F28C/L0/001" ]
    var shouldUpdateImage = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let highlighted = UserDefaults.standard.array(forKey: "uploadDone") as? [String]
        {
            highlightAssets = highlighted
            print("highlightAssets=\(highlightAssets)")
        }
        else
        {
            highlightAssets = [String]()
        }
        
        
        guard self.shouldUpdateImage else {
            print("1")
            return
        }
        
        print("2")
//        animateTest()
//        var dict = [String: [Int]]()
//        dict["111"] = [Int]()
//        dict["111"]?.append(1)
//        dict["111"]?.append(2)
//        print("count=\(dict.count)")
        
        //setUpUI()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        UserDefaults.standard.setValue(["7E5F6D7F-E444-482B-8423-53D1C9D724AD/L0/001","C93A4418-ACF5-4B8E-B01D-00B7A87B9DC4/L0/001","C5FEFE60-0ADB-4A7B-9869-69D4A002F28C/L0/001" ], forKey: "uploadDone")
        UserDefaults.standard.synchronize()
        
//        print("viewDidAppear --- button frame=\(button.frame)")
//        print("viewDidAppear --- imageview frame=\(imageView.frame)")
//
//        DispatchQueue.global().async {
//            Thread.sleep(forTimeInterval: 5)
//            DispatchQueue.main.async {
//                UIView.animate(withDuration: 5.0) {
//                    self.imageView.frame = self.view.bounds
//                    self.imageView.alpha = 1.0
//                    self.button.frame = CGRect(x: self.imageView.frame.midX, y: self.imageView.frame.midY, width: self.view.bounds.width * 0.2, height: self.view.bounds.height * 0.2)//CGRect(x: 128, y: 252, width: 64, height: 64)
//                } completion: { (status) in
//                   print("animate DONE")
//                    print("viewDidAppear --- button frame=\(self.button.frame)")
//                    print("viewDidAppear --- imageview frame=\(self.imageView.frame)")
//                    self.imageView.isHidden = true
//                }
//            }
//        }
        

    }
    
    var imageView:UIImageView!
    var button:UIButton!
    func animateTest()
    {
        imageView = UIImageView()
        imageView.alpha = 0.1
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        imageView.backgroundColor = UIColor.green
        imageView.image = UIImage(named: "web_maintenance")
        self.view.addSubview(imageView)
        
        button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.black
        imageView.addSubview(button)
        button.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.2).isActive = true
        button.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.2).isActive = true
        button.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addImage(_ sender: UIButton) {
        let picker = KrNrImagePicker()
        picker.imagepickerDelegate = self
        picker.coustomerViewController = getCustomerViewController()
        picker.highlightAssets = highlightAssets
        present(picker, animated: true, completion: nil)
    }
    
    func getCustomerViewController() -> KrNrCustomizedViewController
    {
        let customerVC = CustomerViewController()
        customerVC.view.backgroundColor = .green
        
        return customerVC
    }
    
   
    override func viewWillLayoutSubviews() {
        
    }

}

extension ViewController: KrNrImagePickerDelegate
{
    func krnrImagePicker(closed: Bool) {
        print("krnrImagePicker closed=\(closed)")
    }
    
    func krnrImagePicker(didSelected assetes: [PHAsset]) {
        
        for asset in assetes
        {
            print("seelcted ID: \(asset.localIdentifier)")
        }
        
    }
    
    
}

