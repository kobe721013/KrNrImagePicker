//
//  KrNrImagePickerViewController.swift
//  KrNrImagePicker
//
//  Created by 林詠達 on 2021/7/23.
//

import UIKit
import Photos

//callback for users. told them, which assets be selected.
public protocol KrNrImagePickerDelegate
{
    func krnrImagePicker(didSelected assetes:[PHAsset])
    func krnrImagePicker(closed:Bool)
}

open class KrNrImagePicker: UINavigationController {
  
    public var imagepickerDelegate:KrNrImagePickerDelegate?
    {
        didSet{
            picker.imagepickerDelegate = imagepickerDelegate
        }
    }
    
    public var coustomerViewController:KrNrCustomizedViewController?
    {
        didSet{
            picker.customizedViewController = coustomerViewController
        }
    }
    
    private let picker: KrNrImagePickerVC!
    
   
    public required init() {
    
        picker = KrNrImagePickerVC()
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen // Force .fullScreen as iOS 13 now shows modals as cards by default.
        navigationBar.tintColor = .purple
        toolbar.tintColor = .purple
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        picker.callBackDidSelectedAssets()
        KrNrLog.track("Picker deinited 👍")
    }
        
    
    open override func viewDidLoad()
    {
        super.viewDidLoad()
        viewControllers = [picker]
        //!!IMPORTANT!!, view will extends to full screen, not under navigation bar
        navigationBar.isTranslucent = true
        
        //setup delegate
        //picker.imagepickerDelegate = imagepickerDelegate
        
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
