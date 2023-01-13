//
//  AssertsDataService.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/29.
//

import Foundation

enum AssertsDataError: Error{
    // 文件已经存在
    case ISEXIT
    // 文件不存在
    case ISNOTEXIT
    // 操作失败
    case TAKEHANLE
}

class AssertsDataService {
    public static let FILE_DIRECTOR =  NSHomeDirectory()+"/Documents/account/"
    public static let FILE_NAME = "asserts.json"
    
    public static let DEFAULT_ASSERTS = AssertsData()
    /**
     更新保存数据
     */
    public static func setData(assertsData:AssertsData) throws {
        let filePath = FILE_DIRECTOR+FILE_NAME
        isExitFileOrCreateFile(fileDirector: FILE_DIRECTOR, filePath: filePath)
        let dbData:AssertsData = assertsData
        do {
            try JSONUtils.encode2String(dbData)
                .write(to: URL(fileURLWithPath: filePath), atomically: true, encoding: .utf8)
        } catch {
            print("写入文件失败：\(error)")
            throw AssertsDataError.TAKEHANLE
        }
    }
    
    /**
     读取数据
     */
    public static func readData() throws -> AssertsData? {
        let filePath = FILE_DIRECTOR+FILE_NAME
        isExitFileOrCreateFile(fileDirector: FILE_DIRECTOR, filePath: filePath)
        let conetntStr = try? String(contentsOfFile: filePath)
        var content:String = ""
        if conetntStr != nil && StringUtils.trimCount(conetntStr!) != 0 {
            content = conetntStr!
        } else {
            return nil
        }
        print(content)
        var dbData:AssertsData? = nil
        do {
            dbData = try JSONUtils.decode(content.data(using: .utf8), AssertsData.self)
        } catch {
            throw AssertsDataError.TAKEHANLE
        }
        return dbData
    }
    
    /**
     存储账本设置信息的路径，文件是否都存在，不存在进行创建
     */
    private static func isExitFileOrCreateFile(fileDirector:String, filePath:String) {
        if (!FilesUtils.isExit(filePath: fileDirector)) {
            FilesUtils.createDirector(directorPath: fileDirector)
        }
        if (!FilesUtils.isExit(filePath: filePath)) {
            FilesUtils.createFile(filePath: filePath)
        }
    }
}
