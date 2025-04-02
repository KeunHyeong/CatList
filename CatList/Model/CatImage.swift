//
//  Cat.swift
//  thecat
//
//  Created by 장근형 on 3/27/25.
//

import Foundation
import Alamofire
import RealmSwift

class CatImage: Object, Codable {
    @objc dynamic var id: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var width: Int = 0
    @objc dynamic var height: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, url, width, height
    }
}
