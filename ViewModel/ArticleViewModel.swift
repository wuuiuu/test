//
//  ArticleViewModel.swift
//  test3
//
//  Created by kker on 2026/1/8.
//






//页面功能
//
//页面加载时「模拟网络请求」获取文章列表
//
//支持：
//
//加载中
//
//加载成功
//
//空数据
//
//加载失败
//
//每一篇文章可以 收藏 / 取消收藏
//
//收藏状态变化后：
//
//UI 自动刷新
//
//不重新请求网络
//
//所有状态变化必须通过 ViewModel 驱动


import Foundation

enum ArticleListState {
    case idle
    case loading
    case success([Article])
    case empty
    case failure(String)
}


final class ArticleViewModel: ObservableObject {
    @Published private(set) var state: ArticleListState = .idle
    @Published private(set) var showFavoritesOnly = false
    
    private let service: ArticleService
    private var allAriticles: [Article] = []
    
    init(service: ArticleService = ArticleService()) {
        self.service = service
    }
    
    //加载文章
    func loadArticles() {
        state = .loading
        service.fetchArticle { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.allAriticles = data
                    self.updateState()
                case .failure:
                    self.state = .failure("错误信息")
                }
            }
            
        }
        
        
    }
    //切换收藏
    func toggleFavorite(id: UUID) {
        allAriticles = allAriticles.map { article in
            if article.id == id {
                var newArticle = article
                newArticle.isFavorite.toggle()
                return newArticle
            } else {
                return article
            }
        }
        updateState()
    }
    
    //切换筛选
    func toggleFilter() {
        showFavoritesOnly.toggle()
        updateState()
    }
    //统一刷新state
    private func updateState() {
        let visableArticles = showFavoritesOnly
        ? allAriticles.filter {
            $0.isFavorite
        } : allAriticles
        
        state = visableArticles.isEmpty ? .empty : .success(visableArticles)
    }
}

/*
 Q1:updateState，因为view model是控制状态的
 Q2:因为保证互斥，保证单数据流，不会发生同时修改一种数据的情况
 Q3:因为只是切换页面，修改状态，不需要修改数据源
 Q4：
 
 
 
 
 
 
 
 
 
 
 */
