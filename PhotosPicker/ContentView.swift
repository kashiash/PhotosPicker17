//
//  ContentView.swift
//  PhotosPicker
//
//  Created by Jacek Kosinski U on 25/08/2023.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: Image?


    var body: some View {
        VStack{
            if let selectedImage {
                selectedImage
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 10)
            }
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label ("Wybierz zdjęcie",systemImage: "photo")
            }
            .photosPickerStyle(.inline)
            .photosPickerAccessoryVisibility(.hidden, edges: .bottom)
            .frame(height: 300)
            .ignoresSafeArea()

            .onChange(of: selectedItem) { oldItem,  newItem in
                Task {
                    if let image = try? await
                        newItem?.loadTransferable(type: Image.self) {
                        selectedImage = image
                        
                    }
                }
            }

        }



    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
