//
//  FilesUtils.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/26.
//

import SwiftUI
class FilesUtils {
    public static let fileManager = FileManager.init()
    
    /**
        文件或者文件夹是否存在
     */
    static func isExit(filePath:String) -> Bool {
        return fileManager.fileExists(atPath: filePath)
    }
    /**
        创建一个文件
     */
    static func createFile(filePath:String) {
        fileManager.createFile(atPath: filePath, contents: nil)
    }
    
    static func createDirector(directorPath:String) {
        try? fileManager.createDirectory(at: URL(fileURLWithPath: directorPath), withIntermediateDirectories: true)
    }
    
    
}
