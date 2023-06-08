//
//  Gallerys.swift
//  stickyWars
//
//  Created by josefin hellgren on 2023-02-07.
//

import Foundation
import UIKit
import ARKit
import FirebaseStorage
import Firebase


class Gallerys : ObservableObject, Identifiable {
    
    static let shared = Gallerys()
    @Published var myGalleries : [Gallery] = []
    @Published var selectedGallery : Gallery = Gallery(worldMap: "Sten", longitude: 37.3323341, latitude: -122.0312186, descriptionOfPlacement: "Somewhere wierd", userName: "Josefin")

    
    
    
    func saveARWorldMapToFirebaseStorage(name : String ) {
        
        ARViewContainer.ARVariables.arView.session.getCurrentWorldMap { (worldMap, _) in
            if let map: ARWorldMap = worldMap {
                let data = try! NSKeyedArchiver.archivedData(withRootObject: map,
                                                             requiringSecureCoding: true)
                
                let storageRef = Storage.storage().reference()
                let path = name
                let fileRef = storageRef.child(path)
                
                _ = fileRef.putData(data, metadata: nil) { metadata, error in
                    if let error = error {
                        print("failed to save data to storage,", error.localizedDescription )
                    }
                }
            }
        }
    }
    
    func saveInfoAboutMapToFirestore( descriptionOfPlacement : String , nameOfWorldMap : String) {
        let locationManager : LocationManager = .shared
        let db = Firestore.firestore()
        
        //create GalleryObject
        //users current location
        
        let usersEmail = Auth.auth().currentUser?.email ?? "generic email adress"
        
        locationManager.startLocationUpdates()
        
        let map = Gallery(worldMap: nameOfWorldMap, longitude: locationManager.location?.longitude ??  18.0371209, latitude: locationManager.location?.latitude ??     59.34222, descriptionOfPlacement: descriptionOfPlacement, userName: usersEmail)
        
        do {
            _ = try db.collection("WorldMaps").addDocument(from: map)
        } catch {
            print("Error saving to DB")
        }
    }
    
    func listenToFirestoreForMaps() {
        let db = Firestore.firestore()
        db.collection("WorldMaps").addSnapshotListener { snapshot, err in
            guard let snapshot = snapshot else {return}
            
            if let err = err {
                print("Error getting document \(err)")
            } else {
                self.myGalleries.removeAll()
                for document in snapshot.documents {
                    
                    let result = Result {
                        try document.data(as: Gallery.self)
                    }
                    switch result  {
                    case .success(let gallery)  :
                        self.myGalleries.append(gallery)
                    case .failure(let error) :
                        print("Error decoding item: \(error)")
                    }
                }
            }
        }
    }
}

