//
//  KrNrImagePickerViewController.swift
//  KrNrImagePicker
//
//  Created by 林詠達 on 2021/7/23.
//

import UIKit

open class KrNrImagePicker: UINavigationController {

//    private var krnrSlideView:KrNrSlideView!
    
   
    private let picker: KrNrImagePickerVC!
    /// Get a YPImagePicker with the specified configuration.
    public required init() {
    
        picker = KrNrImagePickerVC()
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen // Force .fullScreen as iOS 13 now shows modals as cards by default.
        //picker.imagePickerDelegate = self
        navigationBar.tintColor = .red
        
        
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
            KrNrLog.track("Picker deinited 👍")
    }
        
    
    open override func viewDidLoad()
    {
        super.viewDidLoad()
        viewControllers = [picker]
        navigationBar.isTranslucent = true//!!IMPORTANT!!, view will extends to full screen, not under navigation bar
    }
    
    
//    open override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setUpUI()
//        // Do any additional setup after loading the view.
//    }
//

//    open override func viewWillLayoutSubviews() {
//
//        KrNrLog.track("(ViewController)-viewWillLayoutSubviews: current bound=\(view.bounds)")
//        krnrSlideView.updateFrame(bounds: view.bounds)
//    }
    
//    private func setUpUI() {
//        self.view.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.2431372549, blue: 0.3137254902, alpha: 1)
//
//        krnrSlideView = KrNrSlideView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
//        self.view.addSubview(krnrSlideView)
//
//        //bannerView.backgroundColor = UIColor.green
//       // krnrSlideView.reloadData()
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
