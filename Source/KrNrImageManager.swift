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
    
    //init
//    init() {
//        cachImageManager = PHCachingImageManager()
//    }
    
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
        //clear assets
        dateGroupAssets.removeAll()
        serialAssets.removeAll()
        assets.enumerateObjects({ (asset, count, stop) in
            
            //ref: https://gist.github.com/jamesrochabrun/1b11601e41573fd935c1d8d7d607e3e1
            //todo...整理code，看怎麼讓取出的資料更容以存取
            self.serialAssets.append(asset)
            //if object.mediaType == .image {
                //self.localPhotos.append(object)
                let key = dateFormatter.string(from: asset.creationDate!)
                //KrNrLog.track("key=\(key)")
            
            if(self.dateGroupAssets.keys.contains(key) == false)
            {
                self.dateGroupAssets[key] = [PHAsset]()
            }
                
            self.dateGroupAssets[key]?.append(asset)
            //} else if object.mediaType == .video {
                //self.localVideos.append(object)
            //    self.localVideosDic[object.localIdentifier] = object
            //
        })
        
        KrNrLog.track("fetch ALL assets count=\(serialAssets.count)")
        //callback
        delegate?.assetsPrepareCompleted(dateGroupAssets)
    }
    
//    func startCachingBigImage(selected centerIndex: Int, window bufferSize: Int, options: PHImageRequestOptions?)
//    {
//        let assetsCount = serialAssets.count
//        self.bufferSize = bufferSize
//        
//        KrNrLog.track("centerIndex=\(centerIndex), bufferSize=\(bufferSize), assetsCOumt=\(assetsCount)")
//        from = centerIndex - bufferSize / 2
//        if from < 0
//        {
//            from = 0
//        }
//        to = from + bufferSize
//        if to >= assetsCount
//        {
//            to = assetsCount - 1
//        }
//        
//        KrNrLog.track("startCachingBigImage, from(\(from)) ~ to(\(to))")
//        var waitAssets = [PHAsset]()
//        //waitAssets.append(serialAssets[centerIndex])
//        for i in from...to
//        {
//            waitAssets.append(serialAssets[i])
//        }
//        
//        var myoptions = options
//        if myoptions == nil
//        {
//            myoptions = PHImageRequestOptions()
//            myoptions!.resizeMode = .fast
//            myoptions!.deliveryMode = .highQualityFormat
//        }
//        
////        let options = PHImageRequestOptions()
////        options.resizeMode = .fast
////        options.deliveryMode = .highQualityFormat
//        startCachingImages(for: waitAssets, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: myoptions)
//    }
}
