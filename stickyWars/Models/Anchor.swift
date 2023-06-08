//
//  Anchors.swift
//  stickyWars
//
//  Created by josefin hellgren on 2023-02-09.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseFirestore
import Firebase
import ARKit
import RealityKit

struct Anchor : Encodable, Decodable, Identifiable {
    
    @DocumentID var id: String?
    var identifier : UUID
    var image : String
    var points : Int = 2
    
    static func loadAnchorFromStorage(name : String) {
        let coordinator : Coordinator = .shared
        
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference()
        let path = name
        let fileRef = storageRef.child(path)
        _ = fileRef.getData( maxSize: 10000000) { data, error in
            if error == nil && data != nil{
                
                let config = ARWorldTrackingConfiguration()
                
                if let unarchiver = try? NSKeyedUnarchiver.unarchivedObject(
                    ofClasses: [ARWorldMap.classForKeyedUnarchiver()],
                    from: data!),
                   let worldMap = unarchiver as? ARWorldMap {
                    
                    for anchor in worldMap.anchors {
                        db.collection("Anchors").document(anchor.identifier.uuidString).getDocument() { document, error in
                            
                            let result = Result {
                                try document!.data(as: Anchor.self)
                            }
                            
                            switch result  {
                            case .success(let document)  :
                                print(document.identifier)
                                let mesh = MeshResource.generateBox(width: 0.5, height: 0.02, depth: 0.5)
                                let box = ModelEntity(mesh: mesh)
                                box.generateCollisionShapes(recursive: true)
                                
                                coordinator.loadPictureAsTextureOnMap(box: box, view: ARViewContainer.ARVariables.arView, anchor: anchor, anchorName: document.image)
                                
                                config.initialWorldMap = worldMap
                                config.planeDetection = .vertical
                                ARViewContainer.ARVariables.arView.session.run(config)
                                
                            case .failure(let error) :
                                print("Error decoding item: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
}



