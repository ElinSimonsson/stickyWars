//
//  Users.swift
//  stickyWars
//
//  Created by josefin hellgren on 2023-02-20.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class User: Encodable, Decodable, Identifiable {

    var id = UUID()
    var name: String = "John Doe"
    var score : Int = 0
    var email : String = "a@gmail.com"
    
    init(name : String, email : String, score : Int){
        self.name = name
        self.email = email
        self.score = score
    }
}
