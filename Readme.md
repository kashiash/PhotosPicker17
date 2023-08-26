Rozpoczynając od iOS 16, SwiftUI wprowadza natywny widok wyboru zdjęć znanego jako PhotosPicker. Jeśli Twoja aplikacja wymaga dostępu do biblioteki zdjęć użytkowników, widok PhotosPicker bezproblemowo zarządza procesem wyboru zdjęć. Ten wbudowany widok oferuje niezwykłą prostotę, pozwalając programistom prezentować selektor i obsługiwać wybór obrazu za pomocą zaledwie kilku linii kodu.

Przy prezentacji widoku PhotosPicker, wyświetlany jest on jako oddzielny panel, na górze interfejsu Twojej aplikacji. W wcześniejszych wersjach iOS nie można było dostosować wyglądu widoku wyboru zdjęć, aby pasował do układu Twojej aplikacji. Jednak Apple wprowadziło ulepszenia do widoku PhotosPicker w iOS 17, umożliwiając programistom płynne osadzanie go wewnątrz aplikacji. Dodatkowo masz opcję modyfikowania jego rozmiaru i układu za pomocą standardowych modyfikatorów SwiftUI, takich jak .frame i .padding.

W tym samouczku pokażę Ci, jak zaimplementować wbudowany wybór zdjęć za pomocą ulepszonego widoku PhotosPicker.

Powrót do Wyboru Zdjęć

Aby używać widoku PhotosPicker, możesz najpierw zadeklarować zmienną stanu do przechowywania wyboru zdjęć, a następnie utworzyć widok PhotosPicker, przekazując wiązanie do zmiennej stanu. Oto przykład:

```swift
import SwiftUI
import PhotosUI
 
struct ContentView: View {
 
    @State private var selectedItem: PhotosPickerItem?
 
    var body: some View {
        PhotosPicker(selection: $selectedItem,
                     matching: .images) {
            Label("Wybierz zdjęcie", systemImage: "photo")
        }
    }
}
```

Parametr matching pozwala określić typ zasobu do wyświetlenia. Tutaj wybieramy tylko wyświetlanie obrazów. W zamknięciu tworzymy prosty przycisk z widokiem Label.



![2023-08-26_11-54-04 (1)](2023-08-26_11-54-04%20(1).gif)



Po wybraniu zdjęcia, selektor automatycznie zamyka się, a wybrany element zdjęcia jest przechowywany w zmiennej selectedItem, która jest typu PhotosPickerItem. Aby wczytać obraz z tego elementu, możesz użyć metody loadTransferable(type:completionHandler:). Możesz również użyć modyfikatora onChange, aby nasłuchiwać aktualizacji zmiennej selectedItem. Za każdym razem, gdy zachodzi zmiana, wywołujesz metodę loadTransferable, aby wczytać dane zasobu, w ten sposób:

```swift
@State private var selectedImage: Image?

// ...

.onChange(of: selectedItem) { oldItem, newItem in
    Task {
        if let image = try? await newItem?.loadTransferable(type: Image.self) {
            selectedImage = image
        }
    }
}
```

Podczas korzystania z loadTransferable konieczne jest określenie typu zasobu do pobrania. W tym przypadku używamy typu Image, aby bezpośrednio wczytać obraz. Jeśli operacja zakończy się sukcesem, metoda zwróci widok Image, który można bezpośrednio użyć do wyświetlenia zdjęcia na ekranie.

```swift
if let selectedImage {
    selectedImage
        .resizable()
        .scaledToFit()
        .padding(.horizontal, 10)
}
```