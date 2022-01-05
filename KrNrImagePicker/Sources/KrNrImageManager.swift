//
//  File.swift
//  KrNrImagePicker
//
//  Created by 林詠達 on 2021/8/13.
//

import Foundation
import Photos

protocol KrNrImageManagerDelegate {
    func assetsPrepareCompleted(_ assets:[String: [PHAsset]])
}

class KrNrImageManager : PHCachingImageManager
{
    static var staticIntance:KrNrImageManager?
    
    var serialAssets=[PHAsset]()
    var dateGroupAssets = [String:[PHAsset]]()
    var delegate:KrNrImageManagerDelegate?
    var cachImageManager:PHCachingImageManager!
    var from = 0
    var bufferSize = 0
    var to = 0
    private var assetFetchResult : PHFetchResult<PHAsset>!
   
    
    var sortedDate:[String]
    {
        get{
            return (dateGroupAssets.keys.sorted(by: >))
        }
    }
    
    //function
    static func shared() -> KrNrImageManager
    {
        if staticIntance == nil
        {
            staticIntance = KrNrImageManager()
        }
        
        return staticIntance!
    }
    
    func fetchAllPhassets()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        //fetchOptions.includeAssetSourceTypes = PHAssetSourceType.init(rawValue: PHAssetSourceType.typeUserLibrary.rawValue + PHAssetSourceType.typeiTunesSynced.rawValue)
        fetchOptions.includeAssetSourceTypes = PHAssetSourceType.init(rawValue: PHAssetSourceType.typeUserLibrary.rawValue)
        let assets = PHAsset.fetchAssets(with: fetchOptions)
        self.assetFetchResult = assets
        //clear all assets
        dateGroupAssets.removeAll()
        serialAssets.removeAll()
        assets.enumerateObjects({ (asset, count, stop) in
            //ref: https://gist.github.com/jamesrochabrun/1b11601e41573fd935c1d8d7d607e3e1
            //todo...整理code，看怎麼讓取出的資料更容以存取
            self.serialAssets.append(asset)
            let key = dateFormatter.string(from: asset.creationDate!)
            
            if(self.dateGroupAssets.keys.contains(key) == false)
            {
                self.dateGroupAssets[key] = [PHAsset]()
            }
            self.dateGroupAssets[key]?.append(asset)
        })
        
        KrNrLog.track("fetch ALL assets count=\(serialAssets.count)")
        //callback assets was prepared
        delegate?.assetsPrepareCompleted(dateGroupAssets)
    }
}
