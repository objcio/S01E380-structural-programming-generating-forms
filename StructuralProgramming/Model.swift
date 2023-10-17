//

import Foundation
import Structural

@Structural
struct Book {
    var title: String
    var published: Date
    var authors: String
    var updated: Bool
    var description: String = "My book description"
    var lastUpdate: Date = .distantPast
}

@Structural
struct BookUpdate {
    var description: String
    var date: Date
}
