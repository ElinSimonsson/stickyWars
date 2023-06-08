//
//  Collection.swift
//  stickyWars
//
//  Created by josefin hellgren on 2023-01-24.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import ARKit
import RealityKit

class ArtworkCollection : ObservableObject {
    
    static let shared = ArtworkCollection()
    
    @Published var myDrawings : [Artwork] = []
    @Published var myPhotoAlbum : [Artwork] = []
    @Published var selectedDrawing : String = "https://firebasestorage.googleapis.com:443/v0/b/streetgallery-cd734.appspot.com/o/Bj%C3%B6rn0AC0B1F9-430D-490E-BB59-A071E25E3325.jpeg?alt=media&token=449857e1-5a42-41fe-b2fc-baccfc571569"
    @Published var selectedPhoto : String = ""
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    
    
    func listenForImagesToFirestore() {
        
        let user = Auth.auth().currentUser
        db.collection("Users").document("images").collection("Images").addSnapshotListener { snapshot, err in
            guard let snapshot = snapshot else {return}
            
            if let err = err {
                print("Error getting document \(err)")
            } else {
                self.myDrawings.removeAll()
                for document in snapshot.documents {
                    
                    let result = Result {
                        try document.data(as: Artwork.self)
                    }
                    switch result  {
                    case .success(let drawing)  :
                        if drawing.id == user?.uid{
                            self.myDrawings.append(drawing)}
                    case .failure(let error) :
                        print("Error decoding item: \(error)")
                    }
                }
            }
        }
    }
    
    func listenForPhotosFirebase() {

        let user = Auth.auth().currentUser
        db.collection("Users").document("photos").collection("Photos").addSnapshotListener { snapshot, err in
            guard let snapshot = snapshot else {return}
            
            if let err = err {
                print("Error getting document \(err)")
            } else {
                self.myPhotoAlbum.removeAll()
                for document in snapshot.documents {
                    
                    let result = Result {
                        try document.data(as: Artwork.self)
                    }
                    switch result  {
                    case .success(let drawing)  :
                        if drawing.id == user?.uid{
                        self.myPhotoAlbum.append(drawing)
                        }
                    case .failure(let error) :
                        print("Error decoding item: \(error)")
                    }
                }
            }
        }
    }
    
    func savePhotoToFirebaseStorage(image : UIImage) {
        let user = Auth.auth().currentUser
        let imageData = image.jpegData(compressionQuality: 0.8)
        guard imageData != nil else{return}
        let path = "photo\(UUID().uuidString).jpeg"
        let fileRef = storageRef.child(path)
        
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata, error in

            fileRef.downloadURL {
                url, error in
                
                if let url = url, let user = user {
                    let urlString = url.absoluteString
                    
                    let drawing = Artwork(url: urlString, name: "photo", id: user.uid)
                    do {
                        try self.db.collection("Users").document("photos").collection("Photos").addDocument(from : drawing)
                    } catch {
                        print("failed to save artwork to firebase")
                    }
                }
            }
        }
        uploadTask.resume()
    }
    
    func saveImageToFirebaseStorage(nameOfDrawing : String, image : UIImage) {
    
        let storageRef = Storage.storage().reference()
        let imageData = image.jpegData(compressionQuality: 0.8)
        guard imageData != nil else{return}
        let path = "\(nameOfDrawing)\(UUID().uuidString).jpeg"
        let fileRef = storageRef.child(path)
    
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata, error in
    
            fileRef.downloadURL {
                url, error in
    
                if let url = url {
    
                    let db = Firestore.firestore()
                    let user = Auth.auth().currentUser
                    let urlString = url.absoluteString
                    let drawing = Artwork(url: urlString, name: nameOfDrawing, id: user!.uid)
                    
                    do {
                        try db.collection("Users").document("images").collection("Images").addDocument(from : drawing)
                    } catch {
                        print("fail to save drawing to storage")
                    }
                }
            }
    
        }
        uploadTask.resume()
    }
}




    



