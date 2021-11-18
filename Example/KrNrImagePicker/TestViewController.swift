//
//  TestViewController.swift
//  KrNrImagePicker_Example
//
//  Created by 林詠達 on 2021/9/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var scrollview: UIView!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var testview: UIView!
    
    var viewFrame:CGRect!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewFrame = self.view.frame
        //scrollview.backgroundColor = UIColor.clear
        //view.backgroundColor = UIColor.red
        //testview.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        //imageview.frame = CGRect(x: 0, y: view.frame.height / 2, width: 200, height: 200)
        

        
//        UIView.animate(withDuration: 3.0) {
//            self.imageview.frame = self.view.frame
//            //self.testview.backgroundColor = UIColor.white.withAlphaComponent(1.0)
//        } completion: { (status) in
//            //let viewController = UIViewController()
//            //viewController.view.backgroundColor =  UIColor.red//UIColor.white.withAlphaComponent(0.3)
//            //self.present(viewController, animated: false, completion: nil)
//            //self.navigationController?.pushViewController(viewController, animated: false)
//        }
        
        navigationController?.navigationBar.isTranslucent = true
        //navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 200.0, alpha: 0.3)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        // Do any additional setup after loading the view.
    }
    
    private let navigationBar:UINavigationBar = {
        
        let bar = UINavigationBar()
        
        bar.frame = CGRect(x: 0, y: 0, width: 320 , height: 44)
        //bar.translatesAutoresizingMaskIntoConstraints = false
        let navItem = UINavigationItem(title: "1111")
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonClick))
        
        navItem.rightBarButtonItem = doneButton
        bar.setItems([navItem], animated: false)
        
        bar.isTranslucent = true
        //bar.setBackgroundImage(UIImage(), for: .default)
        //bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        return bar
    }()
    @objc func doneButtonClick()
    {
        print("iamdone, who call me...")
    }
    
    @IBAction func buttonclick(_ sender: Any) {
        
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        view.frame = self.view.frame
        
        view.addSubview(navigationBar)
        
        self.view.addSubview(view)
        
    }
    override func viewDidLayoutSubviews() {
        print("toplayoutGuide=\(self.topLayoutGuide)")
        print("screen.bounds=\(UIScreen.main.bounds)")
        print("nva Bar=\(self.navigationController?.navigationBar.frame)")
        print("status bar=\(UIApplication.shared.statusBarFrame)")
    }
    
    override func viewWillLayoutSubviews() {
        print("toplayoutGuide=\(self.topLayoutGuide)")
        print("screen.bounds=\(UIScreen.main.bounds)")
        print("nva Bar=\(self.navigationController?.navigationBar.frame)")
        print("status bar=\(UIApplication.shared.statusBarFrame)")
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
