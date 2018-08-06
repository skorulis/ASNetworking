//  Created by Alexander Skorulis on 16/12/16.
//  Copyright © 2016 Alexander Skorulis. All rights reserved.

import UIKit
import PromiseKit

extension URL {
    
    func appendQuery(query:String) -> URL? {
        let all = self.absoluteString
        let sep = all.contains("?") ? "&" : "?"
        let changed = String(format: "%@%@%@", all,sep,query)
        return URL(string: changed)
    }
    
}

public protocol NetAPITokenWriter: class {
    
    var bearerToken:String? { get }
    var bearerExpiry:Double? { get }
    func saveToken(token:String?,expiry:Double?)
    
}

open class JSONAPIService: BaseAPIService {

    public var tokenWriter: NetAPITokenWriter?
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public func jsonPostRequest<T : Encodable>(path:String,obj: T) -> URLRequest {
        let data:Data = try! encoder.encode(obj)
        return jsonPostRequest(path: path, data: data )
    }
    
    public func doRequest<T: Decodable>(req:URLRequest) -> Promise<T> {
        let p = dataPromise(req: req)
        p.catch { error in
            print(error)
        }
        return self.handleResponse(dataPromise: p)
    }
    
    public func handleResponse<T: Decodable>(dataPromise:URLDataPromise) -> Promise<T> {
        let dp:Promise<T> = dataPromise.then {[unowned self] data -> Promise<T> in
            return self.parseData(data: data.data, connectionError: nil)
        }
        
        return dp
    }
    
    open func parseData<T: Decodable>(data:Data?,connectionError:Error?) -> Promise<T> {
        do {
            if let d = data {
                if logResponses {
                    let text = String(data:d, encoding:String.Encoding.utf8) ?? "UTF conversion error"
                    print("Got DATA: \(text)")
                }
                let result:T? = try decoder.decode(T.self, from: d)
                print("Got response \(String(describing: result))")
                if let r = result {
                    return Promise.value(r)
                } else {
                    let error = NSError(domain: "net", code: 34, userInfo: [:])
                    return Promise(error: error)
                }
            } else {
                print("Connection error \(String(describing: connectionError))")
                return Promise(error: connectionError!)
            }
        } catch let error as NSError {
            print("Details of JSON parsing error:\n \(error)")
            return Promise(error: error)
        }
    }

    
}
