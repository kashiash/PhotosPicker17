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
                ContentUnavailableView("Brak zdjęć", systemImage: "photo.on.rectangle", description: Text("wybierz jakieś z poniżej listy"))
                    .frame(height: 300)
            } else {
                
                ScrollView(.horizontal){
                    LazyHStack{
                        ForEach(0..<selectedImages.count, id: \.self) { index in
                            selectedImages[index]
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/))
                                .padding(.horizontal,20)
                                .containerRelativeFrame(.horizontal)
                                .scrollTransition(.animated ) { content , phase in
                                    content
                                        .opacity(phase.isIdentity ? 1.0 : 0.8)
                                        .scaleEffect(phase.isIdentity ? 1.0 : 0.8)
                                }
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
