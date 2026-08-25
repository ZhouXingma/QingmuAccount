//
//  AccountBookAddService.swift
//  QingmuAccount
//  账本的增删改查（SQLite 实现）。
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

    public static let DEFALT_ACCOUNT_BOOK = AccountBookModel(id: DEFAULT_UUID, name: DEFAULT_NAME, iconStr: IconFontEnum.icon1.getUnicodeValue(), bgColor: "")

    /**
        移除账本
     */
    public static func removeAccountBook(_ name:String) throws -> [String:AccountBookModel]? {
        if (StringUtils.trimCount(name) <= 0) {
            throw AccountBookHandleError.ISNOTEXIT
        }
        // 级联删除会清空该账本的记录、预算、图标设置
        try SQLiteManager.shared.execute("DELETE FROM account_book WHERE name=?", [name])
        return try readAll()
    }

    /**
     更新账本
     */
    public static func updateAccountBook(id:UUID?, name:String, icon: String, bgColor:String, description:String? = nil, defaultAssetAccountId:String = "", defaultCurrency:String = "CNY") throws -> [String:AccountBookModel]? {
        if (nil == id) {
            throw AccountBookHandleError.ISNOTEXIT
        }
        do {
            try SQLiteManager.shared.execute(
                "UPDATE account_book SET name=?, iconStr=?, bgColor=?, description=?, default_asset_account_id=?, default_currency=? WHERE id=?",
                [name, icon, bgColor, description, defaultAssetAccountId, defaultCurrency, id!.uuidString]
            )
        } catch {
            // 名称撞唯一约束视为账本已存在
            throw AccountBookHandleError.ISEXIT
        }
        return try readAll()
    }

    /**
     添加账本
     */
    public static func addAccountBook(accountBook:AccountBookModel) throws -> [String:AccountBookModel]? {
        let exists = try SQLiteManager.shared.query("SELECT 1 FROM account_book WHERE name=?", [accountBook.name])
        if (exists.count > 0) {
            throw AccountBookHandleError.ISEXIT
        }
        try SQLiteManager.shared.execute(
            "INSERT INTO account_book(id,name,iconStr,bgColor,description,default_asset_account_id,default_currency,gmtCreated) VALUES(?,?,?,?,?,?,?,?)",
            [accountBook.id.uuidString, accountBook.name, accountBook.iconStr, accountBook.bgColor, accountBook.description, accountBook.defaultAssetAccountId, accountBook.defaultCurrency, Int64(accountBook.gmtCreated.timeIntervalSince1970)]
        )
        return try readAll()
    }

    /**
     获取账本详细
     */
    public static func getAccountBookDetail(name:String) throws -> AccountBookModel {
        let rows = try SQLiteManager.shared.query("SELECT * FROM account_book WHERE name=?", [name])
        guard let row = rows.first, let model = rowToModel(row) else {
            throw AccountBookHandleError.ISNOTEXIT
        }
        return model
    }

    /**
     读取所有账本
     */
    public static func readAccountBooks() throws -> [String:AccountBookModel]? {
        return try readAll()
    }

    // MARK: - 私有

    private static func readAll() throws -> [String:AccountBookModel]? {
        let rows = try SQLiteManager.shared.query("SELECT * FROM account_book")
        var result: [String: AccountBookModel] = [:]
        for row in rows {
            if let model = rowToModel(row) {
                result[model.name] = model
            }
        }
        return result
    }

    private static func rowToModel(_ row: [String: Any?]) -> AccountBookModel? {
        guard let id = row["id"] as? String,
              let name = row["name"] as? String,
              let iconStr = row["iconStr"] as? String,
              let bgColor = row["bgColor"] as? String,
              let gmtCreated = row["gmtCreated"] as? Int64 else { return nil }
        let description = row["description"] as? String
        return AccountBookModel(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            iconStr: iconStr,
            bgColor: bgColor,
            description: description,
            defaultAssetAccountId: row["default_asset_account_id"] as? String ?? "",
            defaultCurrency: row["default_currency"] as? String ?? "CNY",
            gmtCreated: Date(timeIntervalSince1970: TimeInterval(gmtCreated))
        )
    }
}
