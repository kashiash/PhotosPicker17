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

![2023-08-26_12-51-07 (1)](2023-08-26_12-51-07%20(1).gif)

### Implementacja wbudowanego selektora zdjęć (PhotosPicker)

Teraz, gdy już rozumiesz, jak pracować z PhotosPicker, zobaczmy, jak go osadzić w naszej aplikacji demonstracyjnej. To, co zamierzamy zrobić, to zastąpić przycisk "Wybierz zdjęcie" wbudowanym selektorem zdjęć. Zaktualizowana wersja PhotosPicker zawiera nowy modyfikator o nazwie photosPickerStyle. Poprzez ustawienie wartości .inline, selektor zdjęć zostanie automatycznie osadzony w aplikacji:

```swift
.photosPickerStyle(.inline)
```

Możesz również używać standardowych modyfikatorów, takich jak .frame i .padding, aby dostosować rozmiar selektora.



![2023-08-26_13-02-23 (1)](2023-08-26_13-02-23%20(1).gif)



Domyślnie, w górnym dodatku selektora jest pasek nawigacji, a w dolnym paskiem narzędzi. Aby wyłączyć oba paski, możesz zastosować modyfikator photosPickerAccessoryVisibility:

```swift
.photosPickerAccessoryVisibility(.hidden)
```

Opcjonalnie, możesz ukryć jeden z nich, np. dolny pasek:

```swift
.photosPickerAccessoryVisibility(.hidden, edges: .bottom)
```





### Obsługa Wyboru Wielu Zdjęć

Obecnie selektor Photos pozwala użytkownikom wybrać tylko pojedyncze zdjęcie. Aby umożliwić wybór wielu zdjęć, możesz włączyć zachowanie ciągłego wyboru, ustawiając selectionBehavior na .continuous lub .continuousAndOrdered:

```swift
PhotosPicker(selection: $selectedItems, 
             maxSelectionCount: 5, 
             selectionBehavior: .continuousAndOrdered,
             matching: .images) {
    Label("Wybierz zdjęcie", systemImage: "photo")
}
```

Jeśli chcesz ograniczyć liczbę elementów dostępnych do wyboru, możesz określić maksymalną ilość za pomocą parametru maxSelectionCount.

Po tym, jak użytkownik wybierze zestaw zdjęć, zostaną one przechowywane w tablicy selectedItems. Tablica selectedItems została zmodyfikowana, aby pomieścić wiele elementów i jest teraz typu PhotosPickerItem.

```swift
@State private var selectedItems: [PhotosPickerItem] = []
```

Aby wczytać wybrane zdjęcia, możesz zaktualizować zamknięcie onChange w ten sposób:

```swift
.onChange(of: selectedItems) { oldItems, newItems in
 
    selectedImages.removeAll()
 
    newItems.forEach { newItem in
 
        Task {
            if let image = try? await newItem.loadTransferable(type: Image.self) {
                selectedImages.append(image)
            }
        }
 
    }
}
```

Użyłem tablicy Image do przechowywania wczytanych obrazów.

```swift
@State private var selectedImages: [Image] = []
```

Aby wyświetlić wybrane obrazy, możesz użyć widoku poziomego przewijania (ScrollView). Oto przykładowy kod, który można umieścić na początku widoku VStack:

```swift
if selectedImages.isEmpty {
    ContentUnavailableView("Brak Zdjęć", systemImage: "photo.on.rectangle", description: Text("Aby rozpocząć, wybierz zdjęcia poniżej"))
        .frame(height: 300)
} else {
 
    ScrollView(.horizontal) {
        LazyHStack {
            ForEach(0..<selectedImages.count, id: \.self) { index in
                selectedImages[index]
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                    .padding(.horizontal, 20)
                    .containerRelativeFrame(.horizontal)
            }
 
        }
    }
    .frame(height: 300)
}
```

Jeśli chcesz dowiedzieć się więcej na temat tworzenia karuzel obrazów, możesz sprawdzić ten samouczek. W iOS 17 wprowadzono nowy widok o nazwie ContentUnavailableView. Widok ten jest zalecany do użycia w scenariuszach, w których zawartość widoku nie może być wyświetlana. Dlatego, gdy nie jest wybrane żadne zdjęcie, używamy ContentUnavailableView, aby przedstawić zwięzłą i informacyjną wiadomość.



![2023-08-26_16-05-18 (1)](2023-08-26_16-05-18%20(1).gif)



### Podsumowanie

W iOS 17 Apple wprowadziło ulepszenia w natywnym selektorze zdjęć (Photos picker). Teraz możesz łatwo osadzić go wewnątrz swojej aplikacji zamiast korzystać z osobnego panelu. Ten samouczek wyjaśnia nowe modyfikatory, które są dostępne w zaktualizowanym widoku PhotosPicker, i pokazuje, jak stworzyć wbudowany selektor zdjęć.