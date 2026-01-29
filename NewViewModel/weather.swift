//
//  weather.swift
//  test3
//
//  Created by kker on 2026/1/12.
//


import Foundation
import SwiftUI

class WeatherViewModel: ObservableObject {
    @Published private(set) var state: LabState = .idle
    @Published var inputCity: String = ""
    
    
    @Published private(set) var history: [WeatherRecord] = [] {
        //属性观察器：只要history变了，就自动存入UserDefaults
        didSet {
            saveHistory()
        }
    }
    
    private let historyKey = "weather_history_key"
    
    private let service: WeatherServiceProtocol
    
    init(service: WeatherServiceProtocol = RealWeatherService()) {
        self.service = service
        loadHistory()
    }
    
    func runQuery() {
        let cityToQuery = inputCity.trimmingCharacters(in: .whitespaces)
        guard !inputCity.isEmpty else { return }
        
        state = .loading
        
        service.fetchWeather(for: cityToQuery) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    let finalCituName = cityToQuery
                    //创建一个记录对象
                    let newRecord = WeatherRecord(city: finalCituName, temperature: data.0, date: Date())
                    withAnimation(.spring()) {
                        self.state = .success(temp: data.0, city: finalCituName)
                        self.addToHistory(newRecord)
                    }
                case .failure(let error):
                    self.state = .failure(error)
                }
            }
            
        }
    }
    //辅助方法：处理历史逻辑
    private func addToHistory(_ record: WeatherRecord) {
        //根据城市名排重
        if let index = history.firstIndex(where: { $0.city.lowercased() == record.city.lowercased() }) {
            history.remove(at: index)
        }
        history.insert(record, at: 0)
        
        if history.count > 10 {
            history.removeLast()
        }
    }
    //点击历史记录直接查询
    func selectFromHistory(_ record: WeatherRecord) {
        // 立即加载缓存，让用户看到数据
        self.inputCity = record.city
        self.state = .success(temp: record.temperature, city: record.city)
        
        // 静默发起网络请求，更新数据
        service.fetchWeather(for: record.city) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if case .success(let data) = result {
                    let originalCityName = record.city
                    let newTemp = data.0
                    let updaterecord = WeatherRecord(city: originalCityName, temperature: newTemp, date: Date())
                    
                    self.state = .success(temp: newTemp, city: originalCityName)
                        
                        self.addToHistory(updaterecord)
                    
                }
            }
            
        }
        
    }
    
    //持久化逻辑
    private func saveHistory() {
//        // 将数组直接存入 UserDefaults
//        UserDefaults.standard.set(history, forKey: historyKey)
        // 使用 JSONEncoder 将对象数组转为 Data
        if let encoded = try? JSONEncoder().encode(historyKey) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
    private func loadHistory() {
//        // 读取数据，如果为空则赋予空数组
//        if let saveHistory = UserDefaults.standard.stringArray(forKey: historyKey) {
//            self.history = saveHistory
        //从Data转回对象数组
        if let data = UserDefaults.standard.data(forKey: historyKey), let decode = try? JSONDecoder().decode([WeatherRecord].self, from: data) {
            self.history = decode
        }
    }
}
