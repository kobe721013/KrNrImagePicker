//
//  KrNrExtensionUtility.swift
//  KrNrImagePicker
//
//  Created by 林詠達 on 2021/12/20.
//

import Foundation
import CoreMedia

extension TimeInterval
{
    func toHumanFormat() -> String
    {
        let duration = self
        //let durationTime = CMTimeGetSeconds(duration)
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        let videoDuration = "\(minutes):\(String(format: "%02d", seconds))"
        //KrNrLog.track("minutes=\(minutes), seconds=\(seconds), videoDuration=\(videoDuration)")
        return videoDuration
    }
}
