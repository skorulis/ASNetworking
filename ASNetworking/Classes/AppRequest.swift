//  Created by Alexander Skorulis on 29/12/20.

import Foundation

public struct AppRequest {
    
    public var urlRequest: URLRequest
    public var stubPath: String?
    
    public init(url: URL) {
        self.urlRequest = URLRequest(url: url)
    }
    
}
