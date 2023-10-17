//

import SwiftUI
import Structural

var initial = Book(title: "Thinking in SwiftUI", published: .now, authors: "Florian and Chris", updated: true)

struct ContentView: View {
    @State private var book = initial
    @State private var update = BookUpdate(description: "foo", date: .now)

    var body: some View {
        VStack {
            book.view
            Form {
                book.edit($book)
                update.edit($update)
            }
        }
            .padding()
    }
}

#Preview {
    ContentView()
}
