//
//  ConnectionManager.swift
//  iphoneapp
//
//  Created by mac on 12/20/24.
//
//
//  ConnectionManager.swift
//  iphoneapp
//
//  Created by mac on 12/20/24.
//

import Foundation
import Alamofire

class ConnectionManager {
    static func Call(tail: String,
                     param: Parameters? = nil,
                     data: Data? = nil,
                     connectionMethod: HTTPMethod = .post,
                     completion: @escaping (Data?) -> Void) {
        let urlString = "https://burningrank-87049884043.asia-northeast3.run.app/"//"http://192.168.10.112:5000/"
        
        guard let url = URL(string: urlString+tail) else {
            print("❌ URL string is not valid")
            return
        }
        
        var headerData: HTTPHeaders?
        headerData = ["Content-Type": "application/json"]
        
        // GET 요청일 경우, 쿼리 매개변수를 URL에 추가
        if connectionMethod == .get {
            AF.request(url,
                       method: .get,
                       parameters: param, // URL 쿼리 매개변수로 추가
                       encoding: URLEncoding.default,
                       headers: headerData)
                .validate(statusCode: [200, 400, 403, 500])
                .response { responseData in
                    switch responseData.result {
                    case .success(let resData):
                        completion(resData)
                    case .failure(let error):
                        print(error.localizedDescription)
                        completion(nil)
                    }
                }
        } else {
            // POST, PUT 등 다른 요청은 본문 데이터를 포함
            let requestData = data ?? Data()
            AF.request(url,
                       method: connectionMethod,
                       parameters: try? JSONSerialization.jsonObject(with: requestData, options: []) as? Parameters,
                       encoding: JSONEncoding.default,
                       headers: headerData)
                .validate(statusCode: [200, 400, 403, 500])
                .response { responseData in
                    switch responseData.result {
                    case .success(let resData):
                        completion(resData)
                    case .failure(let error):
                        print(error.localizedDescription)
                        completion(nil)
                    } 
                }
        }
    }
}
