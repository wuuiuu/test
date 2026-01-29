//
//  WeatherService.swift
//  test3
//
//  Created by kker on 2026/1/12.
//

import Foundation
import SwiftUI



protocol WeatherServiceProtocol {
    func fetchWeather(for city: String, completion: @escaping (Result<(Int, String), LabError>) -> Void)
}


class MockWeatherService: WeatherServiceProtocol {
    
    private let cityDatabase: [String: Int] = [
        "北京": 2,
        "上海": 10,
        "广州": 18,
        "深圳": 20,
        "杭州": 6,
        "成都": 8,
        "武汉": 4
    ]
    
    func fetchWeather(for city: String, completion: @escaping (Result<(Int, String), LabError>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) {
            let trimmedCity = city.trimmingCharacters(in: .whitespaces)
            if let temp = self.cityDatabase[trimmedCity] {
                completion(.success((temp, trimmedCity)))
            } else {
                //如果数据库里没有，模拟一个通用的逻辑
                if city.isEmpty {
                    completion(.failure(.invalidCity))
                } else {
                    let fixedTemp = (trimmedCity.count * 3) & 35
                    completion(.success((fixedTemp, trimmedCity)))
                }
            }
        }
        
    }
}


class RealWeatherService: WeatherServiceProtocol {
    func fetchWeather(for city: String, completion: @escaping (Result<(Int, String), LabError>) -> Void) {
        //构造URL
        let urlString = "https://wttr.in/\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")?format=j1"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidCity))
            return
        }
        //发起数据请求
        URLSession.shared.dataTask(with: url) { data, response, error in
            //处理网络错误
            if error != nil {
                completion(.failure(.networkError))
                return
            }
            //解析JSON
            guard let data = data else { return }
            do {
                let decodedData = try JSONDecoder().decode(RealWeatherResponse.self, from: data)
                if let condition = decodedData.current_condition.first,
                   let area = decodedData.nearest_area.first,
                   let tempInt = Int(condition.temp_C),
                   let areaName = area.areaName.first?.value {
                    //成功回调
                    completion(.success((tempInt, areaName)))
                } else {
                    completion(.failure(.networkError))
                }
            } catch {
                print("解码失败详细信息： \(error)")
                completion(.failure(.networkError))
            }
            
        }.resume()  //  必须调用resume() 任务才开始
    }
}
