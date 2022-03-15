//
//  CustomerViewController.swift
//  KrNrImagePicker_Example
//
//  Created by 林詠達 on 2022/3/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import KrNrImagePicker


class CustomerViewController: KrNrCustomizedViewController {

    override func viewDidLoad() {
        print("KrNrCustomizedViewController viewDidLoad")
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upload", style: .plain, target: self, action: #selector(barButtonCustomPressed))
        
        
        // Do any additional setup after loading the view.
    }
    
    @objc func barButtonCustomPressed()
    {
        print("Done button clicked...")
        self.dismiss(animated: false, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let assets = delegate?.krnrCustomerVCDidSelectedAssets()
        {
            for asset in assets
            {
                print("CustomerViewController Got asset ID=\(asset.localIdentifier)")
            }
        }
        
        setupUi()
    }
    
    var textView:UITextView!
    func setupUi()
    {
        textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .red
        
        view.addSubview(textView)
        NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: textView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
    
        NSLayoutConstraint(item: textView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.2, constant: 0.0).isActive = true
        
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
