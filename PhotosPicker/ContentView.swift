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

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Label ("Wybrane zdjęcie",systemImage: "photo")
        }
    }
}

#Preview {
    ContentView()
}
