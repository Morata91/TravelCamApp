//
//  ContentView.swift
//  TravelCamApp
//
//  Created by 村田航希 on 2024/02/21.
//

import SwiftUI
import MapKit

struct JapanMapView: View {
    var body: some View {
        NavigationView {
            MapView()
                .ignoresSafeArea()
                .navigationBarTitle(Text("Map"), displayMode: .inline)
        }
    }
}

struct MapView: UIViewRepresentable {
    
    // 東京タワーの緯度経度
    let tokyoTowerCoordinate = CLLocationCoordinate2D(latitude: 35.658581, longitude: 139.745433)
    
    
    func makeUIView(context: Context) -> MKMapView {
        return MKMapView()
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 東京タワーの位置にピンを追加
        let annotation = MKPointAnnotation()
        annotation.coordinate = tokyoTowerCoordinate
        annotation.title = "東京タワー"
        uiView.addAnnotation(annotation)
        
        let coordinate = CLLocationCoordinate2D(latitude: 36.2048, longitude: 138.2529) // Japan's coordinates
        let span = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10) // Zoom level
        let region = MKCoordinateRegion(center: coordinate, span: span)
        uiView.setRegion(region, animated: true)
    }
}

public struct CameraView: UIViewControllerRepresentable {
    @Binding private var image: UIImage?
    
    @Environment(\.dismiss) private var dismiss
    
    public init(image: Binding<UIImage?>) {
        self._image = image
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let viewController = UIImagePickerController()
        viewController.delegate = context.coordinator
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            viewController.sourceType = .camera
        }
        
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

extension CameraView {
    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                self.parent.image = uiImage
            }
            self.parent.dismiss()
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.dismiss()
        }
    }
}

struct CapturedImageView: View {
    let image: UIImage?
    
    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Text("No image captured yet")
        }
    }
}



struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isPresentedCameraView = false
    @State private var image: UIImage?
    
    var body: some View {
        TabView(selection: $selectedTab) {
            VStack {
                Button {
                    isPresentedCameraView = true
                } label: {
                    Text("カメラ表示")
                }
                
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                }
            }
            .tabItem {
                Label("Camera", systemImage: "camera")
            }
            .tag(0)
            
            CapturedImageView(image: image)
                .tabItem {
                    Label("Captured", systemImage: "photo.on.rectangle")
                }
                .tag(1)
            
            VStack { // マップを上に移動
                JapanMapView()
                    .ignoresSafeArea()
                Spacer() // マップの下端を上に移動
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }
            .tag(2)
            
            // Add more tabs as needed
            
        }
        .fullScreenCover(isPresented: $isPresentedCameraView) {
            CameraView(image: $image).ignoresSafeArea()
        }
        .accentColor(.blue) // タブバーの色を青色に設定
        .background(Color.gray) // タブバーの背景色を灰色に設定
    }
    
}


#Preview {
    ContentView()
}
