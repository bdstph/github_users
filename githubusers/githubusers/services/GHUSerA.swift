//
//  GHUserCodable.swift
//  githubusers
//
//  Created by Brylle Seraspe on 12/19/20.
//

import Foundation

fileprivate enum CodingKeys: String, CodingKey {
    case avatar_url, id, login
}

struct GHUSerA: Codable {
    
    public var avatar_url: String?
    public var id: Int64
    public var login: String?
    
}
