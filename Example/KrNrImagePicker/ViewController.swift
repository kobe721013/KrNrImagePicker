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

  
    var shouldUpdateImage = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        present(picker, animated: true, completion: nil)
        
        
    }
    override func viewWillLayoutSubviews() {
        
        //print("(ViewController)-viewWillLayoutSubviews: current bound=\(view.bounds)")
        //krnrSlideView.updateFrame(bounds: view.bounds)
    }
    
//    private func setUpUI() {
//        self.view.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.2431372549, blue: 0.3137254902, alpha: 1)
//
//        krnrSlideView = KrNrSlideView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
//        self.view.addSubview(krnrSlideView)
//
//        //bannerView.backgroundColor = UIColor.green
//       // krnrSlideView.reloadData()
//    }
    

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

