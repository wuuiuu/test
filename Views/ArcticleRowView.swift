//
//  ArcticleRowView.swift
//  test3
//
//  Created by kker on 2026/1/9.
//

import SwiftUI

struct ArcticleRowView: View {
    let article: Article
    let onFavoriteTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(article.title).font(.headline)
                Text(article.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: onFavoriteTap) {
                Image(systemName: article.isFavorite ? "star.fill" : "star")
                    .foregroundColor(.yellow)
            }
        }
    }
}
