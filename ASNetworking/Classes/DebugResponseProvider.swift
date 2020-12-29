//  Created by Alexander Skorulis on 29/12/20.

import Foundation

public struct DebugResponse {
    public let data: Data
    public var httpStatus: Int = 200
}

public protocol DebugResponseProvider {
    func getResponse(request: AppRequest) -> DebugResponse?
}

public struct EmptyDebugResponseProvider: DebugResponseProvider {
    
    public func getResponse(request: AppRequest) -> DebugResponse? {
        return nil
    }
    
}

public struct RollingDebugResponseProvider: DebugResponseProvider {
    
    public func getResponse(request: AppRequest) -> DebugResponse? {
        guard let stubPath = request.stubPath else {
            return nil
        }
        guard let url = Bundle.main.url(forResource: stubPath, withExtension: nil) else {
            return nil
        }
        
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        return DebugResponse(data: data)
        
    }
    
}
