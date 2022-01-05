//
//  Resources.swift
//  KrNrImagePicker
//
//  Created by 林詠達 on 2021/12/30.
//

import Foundation

public class Resources {
    public static var podBundle: Bundle {
        let path = Bundle(for: self).resourcePath! + "/KrNrImagePicker.bundle"
        
        //print("KrNrImagePicker.bundle PATH=\(path)")
        return Bundle(path: path)!
    }
    
    public static func podImage(named: String) -> UIImage?
    {
        let image = UIImage(named: named, in: Resources.podBundle, compatibleWith: nil)
        return image
    }
}
