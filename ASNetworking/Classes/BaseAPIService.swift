//
//  BaseAPIService.swift
//  SKSwiftLib
//
//  Created by Alexander Skorulis on 31/12/17.
//

import UIKit
import PromiseKit

public typealias URLData = (data: Data, response: URLResponse)
public typealias URLDataPromise = Promise<URLData>

open class BaseAPIService: NSObject {

    public var logResponses:Bool = true
    
    let baseURL:String?
    let session:URLSession
    var activeRequests = [URLRequest:URLDataPromise]()
    
    public init(baseURL:String?) {
        let config = URLSessionConfiguration.default
        self.baseURL = baseURL
        self.session = URLSession(configuration: config)
    }
    
    public func urlForPath(path:String) -> URL? {
        if let b = baseURL {
            return URL(string:b)?.appendingPathComponent(path)
        } else {
            return URL(string: path)
        }
    }
    
    public func urlForPath(path:String,query:String) -> URL? {
        return urlForPath(path: path)?.appendQuery(query: query)
    }
    
    public func urlForPath(path:String,queryParams:[String:String]) -> URL? {
        return queryParams.reduce(urlForPath(path: path), { (result, p:(key: String, value: String)) -> URL? in
            return result?.appendQuery(query: String(format: "%@=%@", p.key,p.value))
        })
    }
    
    public func request(path:String) -> URLRequest {
        var req = URLRequest(url: self.urlForPath(path: path)!)
        req.httpMethod = "GET"
        return req
    }
    
    public func jsonPostRequest(path:String,dict:[String:Any?]) -> URLRequest {
        var req = request(path: path)
        req.httpMethod = "POST"
        req.httpBody = data(dict: dict)
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return req
    }
    
    public func jsonPostRequest(path:String,data:Data) -> URLRequest {
        var req = request(path: path)
        req.httpMethod = "POST"
        req.httpBody = data
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return req
    }
    
    public func formPostRequst(path:String,dict:[String:Any]) -> URLRequest {
        var req = request(path: path)
        req.httpMethod = "POST"
        req.httpBody = data(dict: dict)
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return req
    }
    
    public func data(dict:[String:Any?]) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: dict, options: [])
        } catch {
            print("error creating JSON data \(error)")
        }
        return nil
    }
    
    public func matching(req:URLRequest) -> URLDataPromise? {
        return self.activeRequests[req]
    }
    
    public func dataPromise(req:URLRequest) -> URLDataPromise {
        var p:URLDataPromise? = matching(req: req)
        if p == nil {
            p = self.session.dataTask(.promise, with: req)
            self.activeRequests[req] = p
            _ = p?.ensure {
                self.activeRequests.removeValue(forKey: req)
            }
        }
        return p!
    }
    
    public func doImageRequest(req:URLRequest) -> Promise<UIImage?> {
        let p = dataPromise(req: req)
        p.catch { error in
            print(error)
        }
        return p.map { (result:URLData) -> UIImage? in
            return UIImage(data: result.data)
        }
    }
    
}
