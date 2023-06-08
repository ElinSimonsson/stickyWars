//
//  MainView.swift
//  stickyWars
//
//  Created by Elin Simonsson on 2023-06-08.
//

import SwiftUI

import PencilKit


struct MainView: View {
    
    @ObservedObject var artworkCollection: ArtworkCollection = .shared
    @ObservedObject var userModel: UserModel = .shared
    @ObservedObject var locationManager : LocationManager = .shared
    @State var coordinator = Coordinator()
    @State var showMapSheet = false
    @State var showPaintSheet = false
    @State var showPhotoGallery = false
    @State var showMyCollectionSheet = false
    @State var showUserInfoSheet = false
    @State var canvas = PKCanvasView()
    @State private var isDarkMode = false
    
    var body: some View {
    
        ZStack(alignment: .bottom){
            VStack(){
                HStack{
                    VStack{
                        HStack{
                            TopTapButton( imageName: "person", actionClosure: {showUserInfoSheet.toggle()})
                                .sheet(isPresented: $showUserInfoSheet, content: { UserInfoView()})
                            TopTapButton(imageName: "paintbrush", actionClosure:{ showPaintSheet.toggle()})
                                .sheet(isPresented: $showPaintSheet, content: {DrawingView(canvas: $canvas)})
                            TopTapButton(imageName: "map", actionClosure: {showMapSheet.toggle()})
                                .sheet(isPresented: $showMapSheet, content: {MapView()})
                            TopTapButton(imageName: "backpack", actionClosure: {showMyCollectionSheet.toggle()})
                                .sheet(isPresented: $showMyCollectionSheet, content: {MyArtworkCollectionView()})
                            TopTapButton( imageName: "photo", actionClosure: {showPhotoGallery.toggle()})
                                .sheet(isPresented: $showPhotoGallery, content: {MyPhotoCollectionView()})
                            
                            Button(action: {userModel.signOutUser()}){
                                Image(systemName: "person.fill.xmark")
                            }
                            .foregroundColor(.black)
                            .frame(width: 50, height: 50, alignment: .center)
                            Toggle("", isOn: $isDarkMode)
                            
                        }
                        .background(Color.yellow.opacity(0.200))
                        .cornerRadius(30)
                        
                        HStack{
                            ArtworkSaveAlertView()
                            ArtworkLoaderAlertButton()
                            Button(action: {
                                coordinator.removeAllAnchors()
                            })
                            {
                                Image(systemName: "trash")
                                    .resizable()
                                    .frame(width: 50.0, height: 50.0, alignment: .center)
                                    .foregroundColor(Color.purple)
                            }
                            .buttonStyle(.bordered)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.black, lineWidth: 1)
                        )
                    }
                }
                
                ARViewContainer()
                    .edgesIgnoringSafeArea(.all)
                    .cornerRadius(30)
                    .padding()
                    .background(LinearGradient(colors: [Color.yellow, Color.white.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing) )
                    .background(LinearGradient(colors: [Color.yellow.opacity(0.4), Color.pink.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .background(Color.white.opacity(0.2))
            }
            
            .background(LinearGradient(colors: [Color.orange.opacity(0.4), Color.yellow.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .background(LinearGradient(colors: [Color.orange.opacity(0.5), Color.yellow], startPoint: .topLeading, endPoint: .bottomTrailing))
            .preferredColorScheme(isDarkMode ? .dark : .light)
            
            ArtworkPickerScrollView()
        }
        .onAppear() {
            artworkCollection.listenForImagesToFirestore()
            artworkCollection.listenForPhotosFirebase()
            locationManager.startLocationUpdates()
        }
    }
}


struct TopTapButton : View {
    let imageName : String
    var actionClosure : () -> Void
    
    var body: some View {
        
        Button(action: actionClosure)
        {
            Image(systemName: imageName)
                .cornerRadius(20.0)
        }
        .foregroundColor(.black)
        .frame(width: 50, height: 50, alignment: .center)
    }
}

struct ArtworkSaveAlertView : View {
    @ObservedObject var gallerys: Gallerys = .shared
    @State var showingAlert = false
    @State var nameOfWorldMap = ""
    @State var descriptionOfPlacement = ""
    
    var body: some View {
        
        Button {
            showingAlert = true
        } label: {
            VStack{
                Image(systemName: "mappin.and.ellipse")
                    .resizable()
                    .frame(width: 50.0, height: 50.0, alignment: .center)
                    .foregroundColor(Color.purple)
            }
        }
        .alert("Save Artwork", isPresented: $showingAlert, actions: {
            TextField("your artwork", text: $nameOfWorldMap)
                .foregroundColor(.black)
            TextField("description of placement", text: $descriptionOfPlacement)
            
            Button("Save", action: {
                gallerys.saveARWorldMapToFirebaseStorage(name: nameOfWorldMap)
                gallerys.saveInfoAboutMapToFirestore(descriptionOfPlacement: descriptionOfPlacement, nameOfWorldMap: nameOfWorldMap)
            })
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Choose a name for the artwork you placed at this location")
        }).buttonStyle(.bordered)
    }
}

struct ArtworkLoaderAlertButton : View {
    @State var showingAlert = false
    @State var nameOfWorldMap : String = ""
    
    var body: some View {
        
        Button {
            showingAlert = true
        } label: {
            VStack{
                Image(systemName: "binoculars.fill")
                    .resizable()
                    .frame(width: 50.0, height: 50.0, alignment: .center)
                    .foregroundColor(Color.purple)
            }
        }
        .alert("Load Artwork", isPresented: $showingAlert, actions: {
            TextField("Artwork name", text: $nameOfWorldMap)
                .foregroundColor(.black)
            Button("Load", action: {
                Anchor.loadAnchorFromStorage(name: nameOfWorldMap)
                
            })
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Write the name of the artwork you wanna load, be sure to be at the same location and read the description of where the artist placed the art.")
        })
        .buttonStyle(.bordered)
    }
}

struct Snapshot: View {
    @ObservedObject var artworkCollection: ArtworkCollection = .shared
    
    var body: some View {
        
        Button {
            ARViewContainer.ARVariables.arView.snapshot(saveToHDR: false) { (image) in
                guard let snapshotImage = image else {
                    return
                }
                
                if let compressedImageData = snapshotImage.pngData() {
                    let compressedImage = UIImage(data: compressedImageData)
                    if let compressedImage = compressedImage {
                        artworkCollection.savePhotoToFirebaseStorage(image: compressedImage)
                        UIImageWriteToSavedPhotosAlbum(compressedImage, nil, nil, nil)
                    }
                }
            }
        } label: {
            Image(systemName: "camera")
                .frame(width: 60, height: 60)
                .font(.title)
                .background(Color.white.opacity(0.75))
                .cornerRadius(30)
                .padding()
        }
    }
}

struct ArtworkPickerScrollView : View {
    @ObservedObject var artworkCollection: ArtworkCollection = .shared
    
    var body: some View{
        
        VStack{
            Snapshot()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(){
                    ForEach(0..<artworkCollection.myDrawings.count,id: \.self) {
                        index in
                        
                        Button(action: {
                            artworkCollection.selectedDrawing = artworkCollection.myDrawings[index].url
                        }){
                            let url = artworkCollection.myDrawings[index].url
                            
                            AsyncImage(url: URL(string: url))
                            { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 80, height: 80)
                            .opacity(0.70)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        .cornerRadius(20.0)
                        .border(Color.pink.opacity(0.60), width: artworkCollection.selectedDrawing == artworkCollection.myDrawings[index].url ? 5.0 : 0.0 )
                        .cornerRadius(20.0)
                    }
                }
                .background(Color.white.opacity(0.25))
                .padding()
            }
        }
    }
}



