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
        //!!IMPORTANT!!, view will extends to full screen, not under navigation bar
        navigationBar.isTranslucent = true
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
