//
//  ArtcileListView.swift
//  test3
//
//  Created by kker on 2026/1/8.
//

import SwiftUI

struct ArtcileListView: View {
    @StateObject private var viewModel = ArticleViewModel()
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("文章列表")
                .toolbar {
                    Button {
                        viewModel.toggleFilter()
                    } label: {
                        Text(viewModel.showFavoritesOnly ? "全部" : "收藏")
                    }
                }
                .onAppear {
                    viewModel.loadArticles()
                }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
            
        case .success(let articles):
            List(articles) { article in
                ArcticleRowView(article: article, onFavoriteTap: { viewModel.toggleFavorite(id: article.id)
                               }
                )
                
            }
            
        case .empty:
            Text("赞无内容")
                .foregroundColor(.gray)
            
        case .failure(let message):
            VStack(spacing: 16) {
                Text(message).foregroundColor(.red)
                Button("重试") {
                    viewModel.loadArticles()
                }
            }
        }
        
        
    }
    
}
