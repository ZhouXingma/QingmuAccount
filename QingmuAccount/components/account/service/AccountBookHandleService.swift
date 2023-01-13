//
//  AccountBookAddService.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/26.
//

import SwiftUI

enum AccountBookHandleError: Error{
    // 文件已经存在
    case ISEXIT
    // 文件不存在
    case ISNOTEXIT
    // 操作失败
    case TAKEHANLE
}

class AccountBookHandleService {
    public static let DEFAULT_UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    public static let DEFAULT_NAME = "日常账本"
    
    public static let FILE_DIRECTOR =  NSHomeDirectory()+"/Documents/account/"
    
    public static let FILE_NAME = "accountbookInfo.json"
    
    public static let FILE_PATH =  FILE_DIRECTOR + FILE_NAME
    
    public static let DEFALT_ACCOUNT_BOOK = AccountBookModel(id: DEFAULT_UUID, name: DEFAULT_NAME, iconStr: IconFontEnum.icon1.rawValue, bgColor: "")
    
    /**
        移除账本
     */
    public static func removeAccountBook(_ name:String) throws -> [String:AccountBookModel]? {
        if (StringUtils.trimCount(name) <= 0) {
            throw AccountBookHandleError.ISNOTEXIT
        }
        // 1 读取历史账本
        var dbData:[String:AccountBookModel]? = try readAccountBooks()
        dbData?.removeValue(forKey: name)
        do {
            try JSONUtils.encode2String(dbData)
                .write(to: URL(fileURLWithPath: FILE_PATH), atomically: true, encoding: .utf8)
        } catch {
            print("写入文件失败：\(error)")
            throw AccountBookHandleError.TAKEHANLE
        }
        return dbData
    }
    
    /**
     更新账本
     */
    public static func updateAccountBook(id:UUID?, name:String, icon: String, bgColor:String) throws -> [String:AccountBookModel]? {
        if (nil == id) {
            throw AccountBookHandleError.ISNOTEXIT
        }
        // 1 读取历史账本
        let dbData:[String:AccountBookModel]? = try readAccountBooks()
        var tempDbData:[String:AccountBookModel] = [:]
        if var a = dbData {
            for (key,value) in a {
                if (value.id == id) {
                    a.removeValue(forKey: key)
                    value.name = name
                    value.iconStr = icon
                    value.bgColor = bgColor
                    tempDbData[name] = value
                } else {
                    tempDbData[key] = value
                }
            }
            do {
                try JSONUtils.encode2String(tempDbData)
                    .write(to: URL(fileURLWithPath: FILE_PATH), atomically: true, encoding: .utf8)
            } catch {
                print("写入文件失败：\(error)")
                throw AccountBookHandleError.TAKEHANLE
            }
        }
        return tempDbData
    }
    
    /**
     添加账本
     */
    public static func addAccountBook(accountBook:AccountBookModel) throws -> [String:AccountBookModel]? {
        // 1 读取历史账本
        var dbData:[String:AccountBookModel]? = try readAccountBooks()
        // 2 查找账本是否存在
        if  (dbData![accountBook.name]) != nil {
            throw AccountBookHandleError.ISEXIT
        }
        // 3 创建账本信息对象
        dbData![accountBook.name] = accountBook
        // 4 创建账本信息
        do {
            try JSONUtils.encode2String(dbData)
                .write(to: URL(fileURLWithPath: FILE_PATH), atomically: true, encoding: .utf8)
        } catch {
            print("写入文件失败：\(error)")
            throw AccountBookHandleError.TAKEHANLE
        }
        return dbData
    }
    
    /**
     获取账本详细
     */
    public static func getAccountBookDetail(name:String) throws -> AccountBookModel {
        let dbData:[String:AccountBookModel]? = try readAccountBooks()
        if let detail = dbData?[name] {
            return detail
        }
        throw AccountBookHandleError.ISNOTEXIT
    }
    
    /**
     读取历史账本
     */
    public static func readAccountBooks() throws -> [String:AccountBookModel]? {
        isExitFileOrCreateFile(fileDirector: FILE_DIRECTOR, filePath: FILE_PATH)
        let conetntStr = try? String(contentsOfFile: FILE_PATH)
        var content:String = "{}"
        if conetntStr != nil && StringUtils.trimCount(conetntStr!) != 0 {
            content = conetntStr!
        }
        print(content)
        var dbData:[String:AccountBookModel]? = nil
        do {
            dbData = try JSONUtils.decode(content.data(using: .utf8), Dictionary<String,AccountBookModel>.self)
        } catch {
            throw AccountBookHandleError.TAKEHANLE
        }
        return dbData
    }
    
    /**
     存储账本信息的路径，文件是否都存在，不存在进行创建
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
