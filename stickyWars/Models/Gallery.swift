//
//  Gallery.swift
//  stickyWars
//
//  Created by josefin hellgren on 2023-02-07.
//

import Foundation
import UIKit
import ARKit
import FirebaseStorage
import FirebaseFirestore


class Gallery : Encodable, Identifiable, Decodable{
    
    var id = UUID()
    var worldMap : String
    var latitude : Double
    var longitude : Double
    var descriptonOfPlacement: String
    var userName : String

    
    init(worldMap : String, longitude : Double, latitude : Double , descriptionOfPlacement : String, userName : String){
        self.worldMap = worldMap
        self.longitude = longitude
        self.latitude = latitude
        self.descriptonOfPlacement = descriptionOfPlacement
        self.userName = userName
    }
}
