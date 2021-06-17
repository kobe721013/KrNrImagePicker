//
//  ViewController.swift
//  KrNrImagePicker
//
//  Created by kobe721013 on 06/17/2021.
//  Copyright (c) 2021 kobe721013. All rights reserved.
//

import UIKit
import KrNrImagePicker
class ViewController: UIViewController {

    private var krnrSlideView:KrNrSlideView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillLayoutSubviews() {
        
        print("(ViewController)-viewWillLayoutSubviews: current bound=\(view.bounds)")
        krnrSlideView.updateFrame(bounds: view.bounds)
    }
    
    private func setUpUI() {
        self.view.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.2431372549, blue: 0.3137254902, alpha: 1)
        
        krnrSlideView = KrNrSlideView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.view.addSubview(krnrSlideView)
       
        //bannerView.backgroundColor = UIColor.green
       // krnrSlideView.reloadData()
    }
    

}

