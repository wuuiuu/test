//
//  test.swift
//  test3
//
//  Created by kker on 2026/1/30.
//

// 练习：最基础的网络请求
// 目标：理解URL Session的基本用法
import Foundation


struct User: Codable{
    let id: Int
    let name: String
    let email: String
}
enum NetworkError: Error {
    case invalidURL
    case noData
}
class NetworkBasics {
    // 练习1: 最简单的get请求
    //GET 请求用于获取数据，比如获取用户列表，获取文章等
    func fetchUserList(completion: @escaping (Result<[User], Error>) -> Void) {
        // 创建URL
        guard let url = URL(string: "https://jsonplaceholder.typicode.cpm/users") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // 创建请求任务
        // URLSession.shared 是系统提供的共享会话，适合简单请求
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // 这个闭包在请求完成后被调用（在后台线程）
            
            // 错误处理
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            // 检查是否有数据
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            //解析 JSON 数据
            do {
                let users = try JSONDecoder().decode([User].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(users))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
        }
        // 发起请求
        task.resume()
    }
    
    
}

struct LoginResponse: Codable {
    let token: String
    let userId: Int
}



// 练习2：POST请求
//POST 请求用于发送数据给服务器，比如登录，注册，提交表单等
func login(username: String, password: String, completion: @escaping (Result<[LoginResponse], Error>) -> Void) {
    // 构建URL
    guard let url = URL(string: "https://your-api.com/login") else {
        completion(.failure(NetworkError.invalidURL))
        return
    }
    
    //创建请求对象
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    // 设置请求头
    // Content-Type 告诉服务器我们发送的数据格式
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // 构建请求体(要发送的数据)
    let body = ["username": username, "password": password]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    
    // 发起请求
    URLSession.shared.dataTask(with: request) { data, response, error in
        // 处理响应
        
    }.resume()
}


// 练习3: 使用async/await  异步代码
// 让异步代码看起来像同步代码一样简单
func fetchUserListAsync() async throws -> [User] {
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else {
        throw NetworkError.invalidURL
    }
    // 一行代码完成请求
    let (data, _) = try await URLSession.shared.data(from: url)
    
    // 解析数据
    let users = try JSONDecoder().decode([User].self, from: data)
    return users
}


// 调用方式
func loadUser() {
    Task {
        do {
            let users = try await fetchUserListAsync()
            //更新 UI
            print("获取到 \(users.count) 个用户")
        } catch {
            print("错误： \(error)")
        }
    }
}


import Combine

//练习4: Combine方式
// 当你需要处理复杂的数据流时，Combine会很有用

class CombineNetworkService {
    private var cancellables = Set<AnyCancellable>()
    
    func fetchUsers() -> AnyPublisher<[User], Error> {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)    // 只取data部分
            .decode(type: [User].self, decoder: JSONDecoder()) // 解析JSON
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // 使用示例
    func loadUser() {
        fetchUsers()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("错误: \(error)")
                }
            },
                  receiveValue: { users in
                print("获取到： \(users.count) 个用户")
                
            }).store(in: &cancellables)
    }
}
