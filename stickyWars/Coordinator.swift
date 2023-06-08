//
//  Coordinatior.swift
//  stickyWars
//
//  Created by josefin hellgren on 2023-01-19.
//

import Foundation
import ARKit
import RealityKit
import UIKit
import Combine
import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth


class Coordinator : NSObject , ARSessionDelegate, ObservableObject {
    
    @ObservedObject var user = UserModel()
    static let shared = Coordinator()
    weak var view : ARView?
    
    
    @objc func handleTap(recognizer : UITapGestureRecognizer) {
        @ObservedObject var artworkCollection: ArtworkCollection = .shared
        
        guard let view = self.view else {return }
        
        let tapLocation = recognizer.location(in: view)
        if view.entity(at: tapLocation) is ModelEntity {
            user.updateScore()
        }
        
        let results =   view.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .vertical)
        
        if let results = results.first {
            let anchor = ARAnchor(name: "plane anchor" , transform: results.worldTransform)
            view.session.add(anchor: anchor)
            let mesh = MeshResource.generateBox(width: 0.5, height: 0.02, depth: 0.5)
            let box = ModelEntity(mesh: mesh)
            box.generateCollisionShapes(recursive: true)
            
            saveAnchorsToFirestore(anchorID: anchor.identifier, selectedDrawing: artworkCollection.selectedDrawing)
            loadPictureAsTexture(box: box, view: view, anchor: anchor)
        }
    }
    
    func saveAnchorsToFirestore (anchorID : UUID, selectedDrawing : String){
        let anchor = Anchor(identifier: anchorID, image: selectedDrawing)
        let db = Firestore.firestore()
        try? db.collection("Anchors").document(anchorID.uuidString).setData(from: anchor)
    }
    
    
    func loadPictureAsTexture(box : ModelEntity, view: ARView, anchor : ARAnchor){
        @ObservedObject var artworkCollection: ArtworkCollection = .shared
        
        let urlTest = artworkCollection.selectedDrawing
        guard let imageURL = URL(string: urlTest) else { return }
        
        let session = URLSession(configuration: .default).dataTask(with: imageURL) { imageData, response, error in
            
            if let data = imageData {
                
                DispatchQueue.main.async {
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let filePath = documentsDirectory.appendingPathComponent("sky.png")
                    try? data.write(to: filePath)
                    let texture = try? TextureResource.load(contentsOf: filePath)
                    
                    if let texture = texture {
                        var material = UnlitMaterial()
                        material.color = .init(tint: .white, texture : .init(texture))
                        box.model?.materials = [material]
                        
                        let anchorentety = AnchorEntity(anchor: anchor)
                        anchorentety.addChild(box)
                        view.scene.addAnchor(anchorentety)
                        view.installGestures(.all, for: box)
                        view.debugOptions = [.showFeaturePoints]
                        
                    }
                }
            }
        }
        session.resume()
    }
    
    func loadPictureAsTextureOnMap(box : ModelEntity, view: ARView, anchor : ARAnchor, anchorName : String){
        
        let urlTest = anchorName
        
        guard let imageURL = URL(string: urlTest) else { return }
        
        let session = URLSession(configuration: .default).dataTask(with: imageURL) { imageData, response, error in
            
            if let data = imageData {
                
                DispatchQueue.main.async {
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let filePath = documentsDirectory.appendingPathComponent("sky.png")
                    try? data.write(to: filePath)
                    let texture = try? TextureResource.load(contentsOf: filePath)
                    
                    if let texture = texture {
                        
                        var material = UnlitMaterial()
                        material.color = .init(tint: .white, texture : .init(texture))
                        box.model?.materials = [material]
                        let anchorentety = AnchorEntity(anchor: anchor)
                        anchorentety.addChild(box)
                        view.scene.addAnchor(anchorentety)
                        view.installGestures(.all, for: box)
                    }
                }
            }
        }
        session.resume()
    }
    
    func removeAllAnchors(){
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.vertical, .horizontal]
        config.environmentTexturing = .automatic
        config.frameSemantics.insert(.personSegmentationWithDepth)
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh){
            config.sceneReconstruction = .mesh
        }
        ARViewContainer.ARVariables.arView.session.run(config, options: [.removeExistingAnchors, .resetTracking])
    }
}



