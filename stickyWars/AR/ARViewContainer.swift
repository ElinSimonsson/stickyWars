//
//  ARViewContainer.swift
//  stickyWars
//
//  Created by josefin hellgren on 2023-01-25.
//

import Foundation
import SwiftUI
import RealityKit
import ARKit


struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var collection: ArtworkCollection = .shared
    
    func makeUIView(context: Context) -> ARView {
        @ObservedObject var collection: ArtworkCollection = .shared
        
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            fatalError("People occlusion is not supported on this device.")
        }
    
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.vertical, .horizontal]
        config.environmentTexturing = .automatic
        config.frameSemantics.insert(.personSegmentationWithDepth)
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh){
            config.sceneReconstruction = .mesh
        }
        
        ARVariables.arView = ARView(frame: .zero)
        ARVariables.arView.addCoaching()
        ARVariables.arView.debugOptions = [.showFeaturePoints]
        ARVariables.arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap)))

        context.coordinator.view = ARVariables.arView
        ARVariables.arView.session.delegate = context.coordinator
        ARVariables.arView.session.run(config)
        
        return ARVariables.arView
    }
    
    func makeCoordinator() -> Coordinator{
        Coordinator( )
    }
    
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
    
    struct ARVariables{
        static var arView: ARView!
    }
}
