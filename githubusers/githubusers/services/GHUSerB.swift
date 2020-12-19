//
//  GHUSerB.swift
//  githubusers
//
//  Created by Brylle Seraspe on 12/19/20.
//

import Foundation

fileprivate enum CodingKeys: String, CodingKey {
    case avatar_url, blog, company, followers, following, id, login, name
}

struct GHUSerB: Codable {
    
    public var avatar_url: String?
    public var blog: String?
    public var company: String?
    public var followers: Int64
    public var following: Int64
    public var id: Int64
    public var login: String?
    public var name: String?
    
}
