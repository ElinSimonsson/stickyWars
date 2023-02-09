//
//  ContentView.swift
//  stickyWars
//
//  Created by josefin hellgren on 2023-01-10.
//

import SwiftUI
import RealityKit
import ARKit
import PencilKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import GameController






struct StartView : View {
    
    
    @State var userIsLoggedIn = false
    @State private var showingAlert = false
    @ObservedObject var collection: Collection = .shared
    @State var coordinator = Coordinator()
    // @Published var worldMapisSaved : Bool = false
    @State var showPaintSheet = false
    @State var showPhotoGalleri = false
    @State var showMyCollectionSheet = false
    @State var canvas = PKCanvasView()
    @ObservedObject var sceneManager : SceneManager = .shared
    @ObservedObject var scenePersistenceHelper : ScenePersistenceHelper = .shared
    
    var body: some View{
        if userIsLoggedIn{
            content
        }else{
            LoginView(userIsLoggedIn: $userIsLoggedIn)
        }
        
    }
    
    
    
    var content: some View{
        
        
        
        
        
        ZStack(alignment: .bottom){
            
            
            VStack(){
                HStack{
                    alertForInput()
                    alertForOutput()
                    Button(action: {
                        showPhotoGalleri.toggle()
                    }){
                        Image(systemName: "photo")
                    }.sheet(isPresented: $showPhotoGalleri) {
                        MyPhotoCollectionView()
                    }
                    .foregroundColor(.pink)
                    .frame(width: 40, height: 40, alignment: .center)
                    
                    Button("ARt") {
                        showingAlert = true
                    }
                    .foregroundColor(.pink)
                    .frame(width: 40.0, height: 40.0, alignment: .center)
                    
                    
                    .alert("ARt är en app där du kan skapa dina konstverk och sedan placera ut dom i den virtuella verkligheten med hjälp av Augumented reality", isPresented: $showingAlert) {
                        Button("OK", role: .cancel) { }
                    }
                    Spacer()
                    Button(action: {signOutUser()}){
                        Image(systemName: "person.fill.xmark")
                    }
                    Button(action: {
                        showPaintSheet.toggle()
                        print("go to drawing")
                        
                    }){
                        //change to brush picture
                        Image(systemName: "paintbrush")
                            .cornerRadius(20.0)
                    }.foregroundColor(.pink)
                        .frame(width: 40, height: 40, alignment: .center)
                    
                    
                        .sheet(isPresented: $showPaintSheet) {
                            Home(canvas: $canvas)
                        }
                    
                    Button(action: {
                        showMyCollectionSheet.toggle()
                        print("go to collection")
                        
                    }){
                        //change to brush picture
                        Image(systemName: "backpack")
                    }.foregroundColor(.pink)
                        .frame(width: 40.0, height: 40.0, alignment: .center)
                    
                    
                        .sheet(isPresented: $showMyCollectionSheet) {
                            MyCollectionView()
                        }
                    
                }.padding()
                //Text("\(getEmal())").foregroundColor(.pink)
                //controllButtonBar()
                ARViewContainer()
                    .edgesIgnoringSafeArea(.all)
                
            }
            
            
            
            modelPickerView(showPaintSheet: $showPaintSheet, coordinator: $coordinator, canvas: $canvas)
            
            
        }.onAppear(){
            listenToFirestore()
            listenForPhotosFirebase()
            Auth.auth().addStateDidChangeListener
            {
                auth , user in
                if user != nil{
                    userIsLoggedIn = true
                }
            }
        }
        
    }
    
    
    
    struct alertForInput : View{
        @State var showingAlert = false
        @State var nameOfWorldMap : String = "worldMap"
        var body: some View{
            
            Button("S") {showingAlert = true
                
                
                print("pressed save")
            }
            
            .alert("Name", isPresented: $showingAlert, actions: {
                TextField("your gallery", text: $nameOfWorldMap)
                    .foregroundColor(.pink)
                
                
                Button("Save", action: {
                    
                    
                    saveMapToFirebaseStorage(name: nameOfWorldMap)
                    
                })
                Button("Cancel", role: .cancel, action: {})
            }, message: {
                Text("Please enter a name for your Gallery")
            })
            .buttonStyle(.bordered)
            
        }
        
        
    }
    struct alertForOutput : View{
        @State var showingAlert = false
        @State var nameOfWorldMap : String = "worldMap"
        var body: some View{
            
            Button("L") {showingAlert = true
                
                
                print("pressed save")
            }
            
            .alert("Name", isPresented: $showingAlert, actions: {
                TextField("your gallery", text: $nameOfWorldMap)
                    .foregroundColor(.pink)
                
                
                Button("Load", action: {
                    
                    
                    loadMapFromStorage(name: nameOfWorldMap)
                    
                })
                Button("Cancel", role: .cancel, action: {})
            }, message: {
                Text("What Map do you want to see?")
            })
            .buttonStyle(.bordered)
            
        }
        
        
    }
    
    
    
    func signOutUser(){
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            userIsLoggedIn = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
func listenToFirestore() {
    @ObservedObject var collection: Collection = .shared
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    db.collection("Users").document(user!.uid).collection("Images").addSnapshotListener { snapshot, err in
        guard let snapshot = snapshot else {return}
        
        if let err = err {
            print("Error getting document \(err)")
        } else {
            collection.myCollection.removeAll()
            for document in snapshot.documents {
                
                let result = Result {
                    try document.data(as: Drawing.self)
                }
                switch result  {
                case .success(let drawing)  :
                    collection.myCollection.append(drawing)
                case .failure(let error) :
                    print("Error decoding item: \(error)")
                }
            }
        }
    }
}
func listenForPhotosFirebase(){
    
    @ObservedObject var collection: Collection = .shared
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    db.collection("Users").document(user!.uid).collection("Photos").addSnapshotListener { snapshot, err in
        guard let snapshot = snapshot else {return}
        
        if let err = err {
            print("Error getting document \(err)")
        } else {
            collection.myPhotoAlbum.removeAll()
            for document in snapshot.documents {
                
                let result = Result {
                    try document.data(as: Drawing.self)
                }
                switch result  {
                case .success(let drawing)  :
                    collection.myPhotoAlbum.append(drawing)
                case .failure(let error) :
                    print("Error decoding item: \(error)")
                }
            }
            
        }
        
    }
}
func sSaveWorldMap(nameOfWorldMap : String) {
    // here i should save what images is loaded as texture for the box
    
    ARViewContainer.ARVariables.arView.session.getCurrentWorldMap { (worldMap, _) in
        
        if let map: ARWorldMap = worldMap {
            
            let data = try! NSKeyedArchiver.archivedData(withRootObject: map,
                                                         requiringSecureCoding: true)
            
            
            
            //here we save it to user defaults or core
            print("found a map")
            
            let savedMap = UserDefaults.standard
            //here we chould put a textfield so user can name their worldMap
            savedMap.set(data, forKey: nameOfWorldMap)
            savedMap.synchronize()
            
            print("\(savedMap)")
        }
    }
}
func loadMapFromStorage(name : String){
    
    let storageRef = Storage.storage().reference()
    let path = name
    let fileRef = storageRef.child(path)
    let downLoadTask = fileRef.getData( maxSize: 10000000) { data, error in
        if error == nil && data != nil{
            
            let config = ARWorldTrackingConfiguration()
            
            if let unarchiver = try? NSKeyedUnarchiver.unarchivedObject(
                ofClasses: [ARWorldMap.classForKeyedUnarchiver()],
                from: data!),
               let worldMap = unarchiver as? ARWorldMap {
                print("seems to work")
                
                
                
                for anchor in worldMap.anchors{
                    
                    let anchorEntety = AnchorEntity(anchor: anchor)
                    
                    let mesh = MeshResource.generateBox(width: 0.5, height: 0.02, depth: 0.5)
                    
                    let box = ModelEntity(mesh: mesh)
                    
                    
                    
                    
                    
                    anchorEntety.addChild(box)
                    ARViewContainer.ARVariables.arView.scene.addAnchor(anchorEntety)
                }
                config.initialWorldMap = worldMap
                config.planeDetection = .vertical
                ARViewContainer.ARVariables.arView.session.run(config)
            }
            
            
            
            
            
        }else{
            
            
            
            
            
        }
        
        
        
        
        
    }
    
}

func loadWorldMap(nameOfWorldMap : String) {
    
    
    let config = ARWorldTrackingConfiguration()
    
    
    let storedData = UserDefaults.standard
    
    if let data = storedData.data(forKey: nameOfWorldMap) {
        print("found map")
        
        if let unarchiver = try? NSKeyedUnarchiver.unarchivedObject(
            ofClasses: [ARWorldMap.classForKeyedUnarchiver()],
            from: data),
           let worldMap = unarchiver as? ARWorldMap {
            print("seems to work")
            
            
            
            for anchor in worldMap.anchors{
                
                let anchorEntety = AnchorEntity(anchor: anchor)
                
                let mesh = MeshResource.generateBox(width: 0.5, height: 0.02, depth: 0.5)
                
                let box = ModelEntity(mesh: mesh)
                
                
                
                
                
                anchorEntety.addChild(box)
                ARViewContainer.ARVariables.arView.scene.addAnchor(anchorEntety)
            }
            config.initialWorldMap = worldMap
            config.planeDetection = .vertical
            ARViewContainer.ARVariables.arView.session.run(config)
        }
    }
}


struct modelPickerView : View{
    @ObservedObject var collection: Collection = .shared
    @Binding var showPaintSheet : Bool
    @Binding var coordinator : Coordinator
    @Binding var canvas : PKCanvasView
    
    var body: some View{VStack{
        
        Button {
            
            // Placeholder: take a snapshot
            ARViewContainer.ARVariables.arView.snapshot(saveToHDR: false) { (image) in
                
                // Compress the image
                let compressedImage = UIImage(data: (image?.pngData())!)
                // Save in the photo album¨
                saveToFirebaseStorage(image: compressedImage!)
                
                UIImageWriteToSavedPhotosAlbum(compressedImage!, nil, nil, nil)
            }
            
        } label: {
            Image(systemName: "camera")
                .frame(width:60, height:60)
                .font(.title)
                .background(.white.opacity(0.75))
                .cornerRadius(30)
                .padding()
        }
        ScrollView(.horizontal, showsIndicators: false){
            
            
            
            HStack(){
                ForEach(0..<collection.myCollection.count,id: \.self){
                    index in
                    
                    Button(action: {
                        print("You pressed \(collection.myCollection[index].name)")
                        
                        collection.selectedDrawing = collection.myCollection[index].url
                        
                    }){
                        let url = collection.myCollection[index].url
                        
                        AsyncImage(url: URL(string: url))
                        { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 70, height: 70)
                        .opacity(0.70)
                        
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    .cornerRadius(20.0)
                    .border(Color.green.opacity(0.60), width: collection.selectedDrawing == collection.myCollection[index].url ? 5.0 : 0.0 )
                    
                }
                
                
            }.background(Color.pink.opacity(0.25))
            
            
            
        }
        
    }
        
    }
    
    
    
}
func saveMapToFirebaseStorage(name : String ){
    
    ARViewContainer.ARVariables.arView.session.getCurrentWorldMap { (worldMap, _) in
        
        if let map: ARWorldMap = worldMap {
            
            let data = try! NSKeyedArchiver.archivedData(withRootObject: map,
                                                         requiringSecureCoding: true)
            
            let storageRef = Storage.storage().reference()
            let path = name
            let fileRef = storageRef.child(path)
            
            
            
            let uploadTask = fileRef.putData(data, metadata: nil) { metadata, error in
                if error == nil && metadata != nil{
                    
                    
                }
                
                
                
            }
        }
    }
}
func saveToFirebaseStorage(image : UIImage) {
    
    guard image != nil else {return
    }
    
    let storageRef = Storage.storage().reference()
    let imageData = image.jpegData(compressionQuality: 0.8)
    guard imageData != nil else{return}
    
    
    
    let path = "photo\(UUID().uuidString).jpeg"
    
    
    let fileRef = storageRef.child(path)
    
    let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata, error in
        
        if error == nil && metadata != nil{
            
            
        }
        fileRef.downloadURL {
            url, error in
            
            if let url = url {
                
                let db = Firestore.firestore()
                let urlString = url.absoluteString
                let user = Auth.auth().currentUser
                let drawing = Drawing(url: urlString, name: "photo")
                try? db.collection("Users").document(user!.uid).collection("Photos").addDocument(from : drawing)
                
            }
        }
        
    }
    uploadTask.resume()
    
}


struct saveAndLoadButtons : View{
    @ObservedObject var sceneManager : SceneManager = .shared
    @ObservedObject var scenePersistenceHelper : ScenePersistenceHelper = .shared
    
    var body: some View{
        
        Button(action: {print("you pressed save")
            
            
            
            
            
        }){
            Image(systemName: "icloud.and.arrow.up")
            
        }
        
        
        Button(action: {print("you pressed load")
            
            
            
        }){
            
            Image(systemName: "icloud.and.arrow.down")
        }
        
        
        
        
        
    }
}
struct controllButtonBar : View{
    
    var body: some View{
        
        HStack(alignment: .center){
            
            saveAndLoadButtons()
            
        }.frame(maxWidth:500)
            .padding(30)
            .background(Color.red.opacity(0.25))
    }
    
    
}







