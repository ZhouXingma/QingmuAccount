//
//  JSONTools.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/11/26.
//

import SwiftUI
enum JSONUtilsError : Error {
    case EncodeError
    case DecodeError
    case OtherError
}


class JSONUtils {
    static func encode2Data<T: Encodable>(_ params: T) throws -> Data? {
        do {
            return try JSONEncoder().encode(params);
        } catch is EncodingError {
            throw JSONUtilsError.EncodeError
        } catch {
            print("JSON encode 出错,未知错误：\(error)")
            throw JSONUtilsError.OtherError
        }
    }
    
    static func encode2String <T: Encodable>(_ params: T) throws -> String {
        let data = try encode2Data(params);
        return String(data: data!, encoding: .utf8)!
    }
    
    static func decode<T: Decodable>(_ params: Data?, _ type:T.Type) throws -> T? {
        if let param = params {
            do {
                let decodeResult = try JSONDecoder().decode(T.self, from: param)
                return decodeResult
            } catch is DecodingError {
                throw JSONUtilsError.DecodeError
            } catch {
                print("JSON decode 出错, 未知错误：\(error)")
                throw JSONUtilsError.OtherError
            }
        }
        return nil;
    }
}
