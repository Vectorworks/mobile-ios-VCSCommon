import SwiftUI

struct FileTypePaginationState: Equatable {
    var currentPage: Int
    var hasMorePages: Bool
}

enum AggregatedState {
    case hasNextPage
    case loading
    case noMorePages
}
