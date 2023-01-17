//
//  AccountBookHandleOfCacheService.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/7.
//

import Foundation
import SwiftUI

class AccountBookHandleOfCacheService {
    /**
     初始化账本
     */
    public static func initAcountBook(selectAccountBookName:String, cache:GlobalModel)  throws {
        do {
            let _ = try addAccountBook(accountBook: AccountBookHandleService.DEFALT_ACCOUNT_BOOK, cache: cache)
        } catch AccountBookHandleError.ISEXIT {
            
        }
        let _ = try changeSelectAccountBook(name:selectAccountBookName,cache: cache)
    }
    
    /**
      获取所有的账本
     */
    public static func getAccountBooks(cache:GlobalModel) throws -> [String:AccountBookModel]? {
        if nil != cache.accountBooks {
            return cache.accountBooks
        }
        let accountbooks = try AccountBookHandleService.readAccountBooks()
        cache.refreshAccountBooks(accountbooks)
        return cache.accountBooks
    }
    
    /**
     获取某个账本
     */
    public static func getAccountBook(name:String, cache:GlobalModel) throws -> AccountBookModel? {
        if nil != cache.accountBooks {
            return cache.accountBooks![name]
        }
        let accountbooks = try AccountBookHandleService.readAccountBooks()
        cache.refreshAccountBooks(accountbooks)
        return cache.accountBooks![name]
    }
    
    /**
     切换账本
     */
    public static func changeSelectAccountBook(name:String,cache:GlobalModel) throws -> AccountBookModel? {
        var selectAccountBook = try getAccountBook(name: name, cache: cache)
        if nil == selectAccountBook {
            // 如果这个名字的账本不存在，则使用缓存的账本
            selectAccountBook = try getAccountBook(name: AccountBookHandleService.DEFAULT_NAME, cache: cache)
        }
        cache.refreshAccountBook(selectAccountBook)
        return selectAccountBook
    }
    /**
     添加账本
     */
    public static func addAccountBook(name:String, icon: String, bgColor:String, cache:GlobalModel) throws -> [String:AccountBookModel]? {
        let accountBook = AccountBookModel(name: name, iconStr: icon, bgColor: bgColor)
        let accountBooks = try AccountBookHandleService.addAccountBook(accountBook: accountBook)
        cache.refreshAccountBooks(accountBooks)
        return accountBooks
    }
    
    /**
     添加账本
     */
    public static func addAccountBook(accountBook:AccountBookModel, cache:GlobalModel) throws -> [String:AccountBookModel]? {
        let accountBooks = try AccountBookHandleService.addAccountBook(accountBook: accountBook)
        cache.refreshAccountBooks(accountBooks)
        return accountBooks
    }
    
    /**
     修改账本
     */
    public static func updateAccountBook(id:UUID, name:String, icon: String, bgColor:String, cache:GlobalModel) throws -> [String:AccountBookModel]? {
        let accountBooks = try AccountBookHandleService.updateAccountBook(id: id, name: name, icon: icon, bgColor: bgColor)
        cache.refreshAccountBooks(accountBooks)
        if nil != cache.accountBook && cache.accountBook!.id.description == id.description {
            // 如果更新的对象是选择的对象，那么同时更新选择的对象
            let accountBook = AccountBookModel(id:id, name: name, iconStr: icon, bgColor: bgColor)
            cache.refreshAccountBook(accountBook)
        }
        return accountBooks
    }
    
    /**
     删除账本
     */
    public static func deleteAccountBook(_ name:String, cache:GlobalModel) throws -> [String:AccountBookModel]? {
        let accountBooks = try AccountBookHandleService.removeAccountBook(name)
        cache.refreshAccountBooks(accountBooks)
        if nil != cache.accountBook && cache.accountBook!.name == name {
            // 如果删除的对象是选择的对象，那么同时更新选择的对象
            let accountBook = try getAccountBook(name: name, cache: cache)
            cache.refreshAccountBook(accountBook)
        }
        return accountBooks
    }
}
