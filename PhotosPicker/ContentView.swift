//
//  ContentView.swift
//  PhotosPicker
//
//  Created by Jacek Kosinski U on 25/08/2023.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [Image] = []


    var body: some View {
        VStack{
            if selectedImages.isEmpty {
                ContentUnavailableView("Brak zdjęć", systemImage: "photo.on.rectangle", description: Text("To get started, select some photosd below"))
                    .frame(height: 300)
            } else {
                
                ScrollView(.horizontal){
                    LazyHStack{
                        ForEach(0..<selectedImages.count, id: \.self) { index in
                            selectedImages[index]
                                .resizable()
                                .scaledToFit()
                                .padding(.horizontal, 10)
                                .containerRelativeFrame(.horizontal)

                        }
                    }
                }
                .scrollTargetBehavior(.paging)
            }

                        PhotosPicker(selection: $selectedItems,
                                     maxSelectionCount: 5,
                                     selectionBehavior: .continuousAndOrdered,
                                     matching: .images) {
                            Label("Wybierz zdjęcie",systemImage: "photo")
                        }

//            PhotosPicker(selection: $selectedItems,
//                         maxSelectionCount: 5,
//                         selectionBehavior: .continuousAndOrdered,
//                         matching: .images) {
//                Label("Select a photo", systemImage: "photo")
//            }
                         .photosPickerStyle(.inline)
                         .photosPickerAccessoryVisibility(.hidden, edges: .bottom)
                         .frame(height: 300)
                         .ignoresSafeArea()
                         .onChange(of: selectedItems) { oldItems,  newItems in
                             selectedImages.removeAll()
                             newItems.forEach { newItem in
                                 Task {
                                     if let image = try? await
                                            newItem.loadTransferable(type: Image.self) {
                                         selectedImages.append(image)
                                     }
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
