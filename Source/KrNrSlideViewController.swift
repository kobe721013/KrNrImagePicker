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
    private var selectedCellFrame:CGRect = .zero
    private var bufferSize = 10
    //var assets:[PHAsset]?
    //var cachImageManager:PHCachingImageManager!
    var imageManager:KrNrImageManager
    
    init(selected centerIndex:Int, selected cellFrame:CGRect) {
        self.centerIndex = centerIndex
        self.selectedCellFrame = cellFrame
        
        imageManager = KrNrImageManager.shared()
        //imageManager.startCachingBigImage(selected: centerIndex, window: bufferSize, options: nil)
       
        krnrSlideView = KrNrSlideView(selected: selectedCellFrame)
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
        self.view.backgroundColor = .clear
        self.modalPresentationStyle = .custom
        setUpSlideView()
        automaticallyAdjustsScrollViewInsets = false//!!IMPORTANT!!, subView would not push down or drag down, subView can fixed there.
        // Do any additional setup after loading the view.
    }
    
    //give zero frame when init KrNrSliderView, real frame will update at here.
    override func viewWillLayoutSubviews() {
        
        //KrNrLog.track("(ViewController)-viewWillLayoutSubviews: current bound=\(view.bounds)")
        KrNrLog.track("viewWillLayoutSubviews, naviBarHeight=\(self.navigationController?.navigationBar.frame.size.height ?? -1)")
        //krnrSlideView.updateFrame(bounds: view.bounds)
    }
    
    override func viewDidLayoutSubviews() {
        KrNrLog.track("viewDidLayoutSubviews, naviBarHeight=\(self.navigationController?.navigationBar.frame.size.height ?? -1)")
    }
    
    private func setUpSlideView() {
        

        KrNrLog.track("viewDidLoad, naviBarHeight=\(self.navigationController?.navigationBar.frame.size.height ?? -1)")
       
        self.krnrSlideView.loadImageToView()
        self.view.addSubview(krnrSlideView)

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
