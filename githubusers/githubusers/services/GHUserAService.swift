//
//  GHUserAService.swift
//  githubusers
//
//  Created by Brylle Seraspe on 12/18/20.
//

import Foundation

protocol GHUserAServiceProtocol {
    
    func didStart()
    func didEnd(success: Bool, message: String?)
    
}

class GHUserAService: NSObject {
    
    static let shared = GHUserAService()
    private var delegate: GHUserAServiceProtocol? = nil
    
    func requestRecords(delegate: GHUserAServiceProtocol, since: Int64 = -1) {
        //
        self.delegate = delegate
        
        //
        let urlSessionConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlSessionConfig,
                                    delegate: self,
                                    delegateQueue: nil)
        
        var url: URL? {
            // https://api.github.com/users?since=46
            var urlStr = "https://api.github.com/users"
            
            if since > 0 {
                urlStr = "\(urlStr)?since=\(since)"
            }
            
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

extension GHUserAService: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let delegate = delegate {
            delegate.didEnd(success: false, message: error?.localizedDescription)
        }
    }
    
}

extension GHUserAService: URLSessionTaskDelegate {
    
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

extension GHUserAService: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            //let str = String(decoding: data, as: UTF8.self)
            
            //
            let decoder = JSONDecoder()
            let ghUserCodableItems: Array<GHUSerA> = try decoder.decode(Array<GHUSerA>.self, from: data)
            
            //
            let coredataStack = CoreDataStack.shared
            
            for ghUserCodable: GHUSerA in ghUserCodableItems {
                let ghUser = GHUser(context: coredataStack.mainContext)
                
                ghUser.avatar_url = ghUserCodable.avatar_url
                ghUser.sortID = ghUserCodable.id
                ghUser.login = ghUserCodable.login
                
                /*ghUser.avatar_url = ghUserCodable.avatar_url
                ghUser.blog = ghUserCodable.blog
                ghUser.company = ghUserCodable.company
                ghUser.followers = ghUserCodable.followers
                ghUser.following = ghUserCodable.following
                ghUser.id = ghUserCodable.id
                ghUser.login = ghUserCodable.login
                ghUser.name = ghUserCodable.name
                ghUser.note = ghUserCodable.note*/
            }
            
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
