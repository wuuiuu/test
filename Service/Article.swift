//
//  Article.swift
//  test3
//
//  Created by kker on 2026/1/8.
//

import Foundation

enum ArticleServiceError: Error {
    case netWorkFailed
}

final class ArticleService {
    func fetchArticle(complention: @escaping (Result<[Article], ArticleServiceError>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.2) {
            let isSuccess = Bool.random()
            if isSuccess {
                let articles = (1...10).map {
                    Article(id: UUID(), title: "文章 \($0)", subtitle: "这是第 \($0)篇文章", isFavorite: false)
                }
                complention(.success(articles))
            } else {
                complention(.failure(.netWorkFailed))
            }
        }
    }
}

