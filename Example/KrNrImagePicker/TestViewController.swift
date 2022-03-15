//
//  TestViewController.swift
//  KrNrImagePicker_Example
//
//  Created by 林詠達 on 2021/9/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

   
    override func viewDidLoad() {
        super.viewDidLoad()
        
   
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upload", style: .plain, target: self, action: #selector(barButtonCustomPressed))
    }
    
    @objc func barButtonCustomPressed()
    {
        print("Done button clicked...")
        self.dismiss(animated: false, completion: nil)
    }
    
   
   
    override func viewDidLayoutSubviews() {
        
    }
    
    override func viewWillLayoutSubviews() {
        
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
