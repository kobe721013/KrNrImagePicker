//
//  KrNrLog.swift
//  KrNrImagePicker
//
//  Created by 林詠達 on 2021/12/9.
//

import Foundation

class KrNrLog {

    static public func track(_ message: String, function: String = #function, line: Int = #line, fileID: String = #fileID, column: Int = #column)
    {
        //print("\(message) --- [\(function)] (\(fileID) at \(line)(\(column))) ")
        print("\(message)")
    }
}
