//
//  MyCollectionView.swift
//  stickyWars
//
//  Created by josefin hellgren on 2023-02-01.
//

import SwiftUI
// here we have a grid page with all your creations and also a upload button for own pictures and in that function also enable camera function.

struct MyArtworkCollectionView: View {
    
    @ObservedObject var artworkCollection: ArtworkCollection = .shared
    @State var showPicker = false
    @State var selectedImage : UIImage?
    @State var mySelectedImage = String()
    @State var showBigDrawingPreview : Bool = false
    var gridItemLayout = Array(repeating: GridItem(.flexible(), spacing: 40), count: 2)
    
    var body: some View {
        ZStack{
            VStack{
                Button(action: {print("upload picture")
                    showPicker = true
                }){
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .foregroundColor(Color.white)
                        .frame(width: 70, height: 70, alignment: .center)
                }
                .sheet(isPresented: $showPicker){
                    ImagePicker(selectedImage: $selectedImage, showPicker : $showPicker)
                }
                Text("DRAWINGS")
                    .foregroundColor(Color.white)
                    .font(.largeTitle)
                
                ScrollView(.vertical, showsIndicators: false){
                    LazyVGrid(columns: gridItemLayout, spacing: 15){
    
                        ForEach(0..<artworkCollection.myDrawings.count,id: \.self){ index in
                            
                            Button(action: {
                                artworkCollection.selectedDrawing = artworkCollection.myDrawings[index].url
                                showBigDrawingPreview = true
                                mySelectedImage = artworkCollection.myDrawings[index].url
                            }) {
                                let url = artworkCollection.myDrawings[index].url
                                
                                AsyncImage(url: URL(string: url))
                                { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 200, height: 200)
                                
                                
                            }.sheet(isPresented: $showBigDrawingPreview) {
                                BigDrawingPreview(image: $mySelectedImage)
                            }
                            
                            .buttonStyle(PlainButtonStyle())
                            
                            .cornerRadius(20.0)
                            .border(Color.green.opacity(0.60), width: artworkCollection.selectedDrawing == artworkCollection.myDrawings[index].url ? 5.0 : 0.0 )
                        }
                    }
                }
            }
        }
        .background(LinearGradient(colors: [Color.purple.opacity(0.5), Color.yellow.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .background(LinearGradient(colors: [Color.pink.opacity(0.5), Color.yellow.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .background(LinearGradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
    }
}

struct BigDrawingPreview : View {
    @Binding var image : String
    
    var body: some View{
        ZStack{
            AsyncImage(url: URL(string: image))
            { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
        }
    }
}
