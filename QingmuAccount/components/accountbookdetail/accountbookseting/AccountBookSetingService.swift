//
//  IconSetingService.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/6.
//

import SwiftUI

enum AccountBookSetingError: Error{
    // 文件已经存在
    case ISEXIT
    // 文件不存在
    case ISNOTEXIT
    // 操作失败
    case TAKEHANLE
}

class AccountBookSetingService {
    public static let FILE_DIRECTOR =  NSHomeDirectory()+"/Documents/account/"
    
    public static let FILE_NAME = "accountbookSeting.json"
    
    public static let DEFAULT_SETING = AccountBookSetingModel()
    
    
    public static func setAccountBookSetting(_ accountBookId:String, _ setting: AccountBookSetingModel) throws {
        let filePath = getFilePath(accountBookId)
        let fileDirector = getFileDirector(accountBookId)
        isExitFileOrCreateFile(fileDirector: fileDirector, filePath: filePath)
        let dbData:AccountBookSetingModel = setting
        do {
            try JSONUtils.encode2String(dbData)
                .write(to: URL(fileURLWithPath: filePath), atomically: true, encoding: .utf8)
        } catch {
            print("写入文件失败：\(error)")
            throw AccountBookSetingError.TAKEHANLE
        }
    }
    
    /**
     读取账本设置
     */
    public static func readAccountBookSetting(_ accountBookId:String) throws -> AccountBookSetingModel? {
        let filePath = getFilePath(accountBookId)
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
        var dbData:AccountBookSetingModel? = nil
        do {
            dbData = try JSONUtils.decode(content.data(using: .utf8), AccountBookSetingModel.self)
        } catch {
            throw AccountBookSetingError.TAKEHANLE
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
    public static func getFileDirector(_ id:String) -> String {
        return String("\(FILE_DIRECTOR)\(id)/")
    }
    /**
     配置文件
     */
    public static func getFilePath(_ id:String) -> String {
        return String("\(FILE_DIRECTOR)\(id)/\(FILE_NAME)")
    }
    
    
}
