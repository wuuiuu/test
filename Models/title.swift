//
//  title.swift
//  test3
//
//  Created by kker on 2026/1/8.
//

import Foundation


protocol Favoritable: Identifiable {
    var isFavorite: Bool { get set }
}

struct Article: Favoritable {
    let id: UUID
    let title: String
    let subtitle: String
    var isFavorite: Bool    //收藏状态
}



