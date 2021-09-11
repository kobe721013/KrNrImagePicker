//
//  KrNrSlideViewController.swift
//  KrNrImagePicker
//
//  Created by 林詠達 on 2021/8/19.
//

import UIKit
import Photos
class KrNrSlideViewController: UIViewController {

    private var krnrSlideView:KrNrSlideView!
    
    private var centerIndex:Int = 0
    private var bufferSize = 10
    //var assets:[PHAsset]?
    //var cachImageManager:PHCachingImageManager!
    var imageManager:KrNrImageManager
    
    init(selected centerIndex:Int) {
        self.centerIndex = centerIndex

        imageManager = KrNrImageManager.shared()
        //imageManager.startCachingBigImage(selected: centerIndex, window: bufferSize, options: nil)
       
        krnrSlideView = KrNrSlideView()
        krnrSlideView.startCachingBigImage(serialAssets: imageManager.serialAssets, selected: centerIndex, window: bufferSize, options: nil)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    //這是從storyboard需要的init
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSlideView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        
        //print("(ViewController)-viewWillLayoutSubviews: current bound=\(view.bounds)")
        print("viewWillLayoutSubviews, naviBarHeight=\(self.navigationController?.navigationBar.frame.size.height ?? -1)")
        krnrSlideView.updateFrame(bounds: view.bounds)
    }
    
    override func viewDidLayoutSubviews() {
        print("viewDidLayoutSubviews, naviBarHeight=\(self.navigationController?.navigationBar.frame.size.height ?? -1)")
    }
    
    private func setUpSlideView() {
        self.view.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.2431372549, blue: 0.3137254902, alpha: 1)

        print("viewDidLoad, naviBarHeight=\(self.navigationController?.navigationBar.frame.size.height ?? -1)")
       
        self.krnrSlideView.loadImageToView()
        self.view.addSubview(krnrSlideView)

    }
      
    
    @objc func handleTap()
    {
        print("kobe tap me...")
        //self.navigationController?.barHideOnTapGestureRecognizer = true
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
