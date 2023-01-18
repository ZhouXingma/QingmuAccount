//
//  AccountBookDataService.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/7.
//

import Foundation
import SwiftUI

enum AccountBookDataError: Error{
    // 文件已经存在
    case ISEXIT
    // 文件不存在
    case ISNOTEXIT
    // 操作失败
    case TAKEHANLE
}

class AccountBookDataService {
    public static let FILE_DIRECTOR =  NSHomeDirectory()+"/Documents/account/"
    /**
     更新保存数据
     */
    public static func setData(_ accountBookId:String, accountBookYearData:AccountBookYearData) throws {
        let fileName = getFileName(accountBookYearData.year)
        let filePath = getFilePath(accountBookId, fileName: fileName)
        let fileDirector = getFileDirector(accountBookId)
        isExitFileOrCreateFile(fileDirector: fileDirector, filePath: filePath)
        let dbData:AccountBookYearData = accountBookYearData
        do {
            try JSONUtils.encode2String(dbData)
                .write(to: URL(fileURLWithPath: filePath), atomically: true, encoding: .utf8)
        } catch {
            print("写入文件失败：\(error)")
            throw AccountBookDataError.TAKEHANLE
        }
    }
    
    /**
     读取数据
     */
    public static func readData(_ accountBookId:String, year:Int) throws -> AccountBookYearData? {
        let fileName = getFileName(year)
        let filePath = getFilePath(accountBookId, fileName: fileName)
        let fileDirector = getFileDirector(accountBookId)
        isExitFileOrCreateFile(fileDirector: fileDirector, filePath: filePath)
        let conetntStr = try? String(contentsOfFile: filePath)
        var content:String = ""
        if conetntStr != nil && StringUtils.trimCount(conetntStr!) != 0 {
            content = conetntStr!
        } else {
            return nil
        }
        print(content)
        var dbData:AccountBookYearData? = nil
        do {
            dbData = try JSONUtils.decode(content.data(using: .utf8), AccountBookYearData.self)
        } catch {
            throw AccountBookDataError.TAKEHANLE
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
    /**
     配置文件路径
     */
    public static func getFileDirector(_ accountBookId:String) -> String {
        return String("\(FILE_DIRECTOR)\(accountBookId)/")
    }
    /**
     配置文件
     */
    public static func getFilePath(_ accountBookId:String, fileName:String) -> String {
        return String("\(FILE_DIRECTOR)\(accountBookId)/\(fileName)")
    }
    /**
     文件名字
     */
    public static func getFileName(_ year:Int) -> String {
        return String("ac\(year).json")
    }
}
