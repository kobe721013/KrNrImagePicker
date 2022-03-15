//
//  KrNrCustomerViewController.swift
//  KrNrImagePicker
//
//  Created by 林詠達 on 2022/3/4.
//

import UIKit
import Photos

public protocol KrNrCustomizedViewControllerDelegate {
    func krnrCustomerVCDidSelectedAssets() -> [PHAsset]
}

open class KrNrCustomizedViewController: UIViewController {

    open var isOK = false//for access level testing
    open var delegate:KrNrCustomizedViewControllerDelegate?
  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
