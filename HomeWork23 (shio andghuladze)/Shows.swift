//
//  Shows.swift
//  HomeWork23 (shio andghuladze)
//
//  Created by shio andghuladze on 16.08.22.
//

import Foundation

struct Shows: Decodable {
    let results: [Show]
}

struct Show: Decodable{
    let id: Int
}

struct ShowDetails: Decodable{
    enum CodingKeys: String, CodingKey{
        case name
        case numberOfEpisodes = "number_of_episodes"
    }
    
    let name: String
    let numberOfEpisodes: Int
}
