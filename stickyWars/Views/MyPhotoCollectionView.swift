//
//  MyPhotoCollectionView.swift
//  stickyWars
//
//  Created by josefin hellgren on 2023-02-06.
//

import SwiftUI

struct MyPhotoCollectionView: View {
    
    @ObservedObject var artworkCollection: ArtworkCollection = .shared
    @State var mySelectedPhoto = String()
    @State var showBigPic : Bool = false
    var gridItemLayout = Array(repeating: GridItem(.flexible(), spacing: 30), count: 2)
    
    
    var body: some View {
        ZStack{
            VStack{
                ScrollView(.vertical, showsIndicators: false){
                    LazyVGrid(columns: gridItemLayout, spacing: 4){
                        ForEach(0..<artworkCollection.myPhotoAlbum.count,id: \.self){ index in
                            
                            Button(action: {
                                artworkCollection.selectedPhoto = artworkCollection.myPhotoAlbum[index].url
                                showBigPic = true
                                mySelectedPhoto = artworkCollection.myPhotoAlbum[index].url
                            }){
                                let url = artworkCollection.myPhotoAlbum[index].url
                                
                                AsyncImage(url: URL(string: url)) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 200, height: 200)
                            }.sheet(isPresented: $showBigPic) {
                                BigDrawingPreview(image: $mySelectedPhoto)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .cornerRadius(20.0)
                            .border(Color.green.opacity(0.60), width: artworkCollection.selectedPhoto == artworkCollection.myPhotoAlbum[index].url ? 5.0 : 0.0 )
                        }
                        .padding(15)
                    }
                }
            }
        }
        .background(LinearGradient(colors: [Color.blue.opacity(0.3), Color.green.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .background(LinearGradient(colors: [Color.yellow.opacity(0.4), Color.blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .background(LinearGradient(colors: [Color.white.opacity(0.4), Color.yellow.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
    }
}
