//
//  Drawings.swift
//  stickyWars
//
//  Created by josefin hellgren on 2023-01-26.
//

import Foundation
import SwiftUI
import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class Artwork : Encodable, Decodable, ObservableObject {

    let url : String
    let name : String
    let id : String
    
    init(url : String, name : String, id : String){
        self.url = url
        self.name = name
        self.id = id
    }
}



