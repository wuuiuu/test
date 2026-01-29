//
//  weatherLabModel.swift
//  test3
//
//  Created by kker on 2026/1/12.
//

import Foundation

enum LabError: Error {
    case invalidCity
    case networkError
}


enum LabState {
    case idle
    case loading
    case success(temp: Int, city: String)
    case failure(LabError)
}

struct WeatherRecord: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    let city: String
    let temperature: Int
    let date: Date
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}


struct RealWeatherResponse: Codable {
    // 1. 根层级的两个分支
    let current_condition: [CurrentCondition]
    let nearest_area: [NearestArea] // 🆕 修改点：类型改为对应的 NearestArea
    
    // 2. 专门处理温度的分支
    struct CurrentCondition: Codable {
        let temp_C: String
    }
    
    // 3. 专门处理城市名的分支（与 CurrentCondition 平级，不要嵌套在里面）
    struct NearestArea: Codable {
        let areaName: [AreaName]
    }
    
    // 4. 最底层的通用值（如果 value 结构都一样，可以共用）
    struct AreaName: Codable {
        let value: String
    }
}
