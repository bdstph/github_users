//
//  GHUserBService.swift
//  githubusers
//
//  Created by Brylle Seraspe on 12/18/20.
//

import Foundation

protocol GHUserBServiceProtocol {
    
    func didStart()
    func didEnd(success: Bool, message: String?)
    
}

class GHUserBService: NSObject {
    
    static let shared = GHUserBService()
    private var delegate: GHUserBServiceProtocol? = nil
    
    func requestRecord(delegate: GHUserBServiceProtocol, login: String) {
        //
        self.delegate = delegate
        
        //
        let urlSessionConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlSessionConfig,
                                    delegate: self,
                                    delegateQueue: nil)
        
        var url: URL? {
            // https://api.github.com/users/jnewland
            let urlStr = "https://api.github.com/users/\(login)"
            return URL(string: urlStr)
        }
        
        if let url = url {
            let task = urlSession.downloadTask(with: url)
            task.resume()
            
            delegate.didStart()
        }
        else {
            delegate.didEnd(success: false, message: nil)
        }
    }
    
}

extension GHUserBService: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let delegate = delegate {
            delegate.didEnd(success: false, message: error?.localizedDescription)
        }
    }
    
}

extension GHUserBService: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            if let delegate = delegate {
                delegate.didEnd(success: false, message: error.localizedDescription)
            }
        }
        else {
            if let delegate = delegate {
                delegate.didEnd(success: true, message: nil)
            }
        }
    }
}

extension GHUserBService: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            //let str = String(decoding: data, as: UTF8.self)
            
            //
            let decoder = JSONDecoder()
            let ghUserCodable: GHUSerB = try decoder.decode(GHUSerB.self, from: data)
            
            //
            let coredataStack = CoreDataStack.shared
            
            let ghUser = GHUser(context: coredataStack.mainContext)
            
            ghUser.avatar_url = ghUserCodable.avatar_url
            ghUser.blog = ghUserCodable.blog
            ghUser.company = ghUserCodable.company
            ghUser.followers = ghUserCodable.followers
            ghUser.following = ghUserCodable.following
            ghUser.sortID = ghUserCodable.id
            ghUser.login = ghUserCodable.login
            ghUser.name = ghUserCodable.name
            
            coredataStack.saveContext()
            
            if let delegate = delegate {
                delegate.didEnd(success: true, message: nil)
            }
        }
        catch {
            if let delegate = delegate {
                delegate.didEnd(success: false, message: error.localizedDescription)
            }
        }
    }
    
}
