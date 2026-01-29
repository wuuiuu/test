import SwiftUI
import Foundation

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // --- 1. 输入区 ---
                VStack(spacing: 10) {
                    TextField("输入城市名 （如：北京）", text: $viewModel.inputCity)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                    
                    Button("查询") {
                        viewModel.runQuery()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
                
                // --- 2. 状态展示区 (ZStack) ---
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue.opacity(0.1))
                        .frame(height: 150)
                    
                    switch viewModel.state {
                    case .idle:
                        Text("准备好搜索天气了吗？").foregroundColor(.gray)
                    case .loading:
                        VStack {
                            ProgressView()
                            Text("正在穿越云层...").font(.caption).padding(.top)
                        }
                    case .success(let temp, let city):
                        VStack {
                            Text(city).font(.title).bold()
                            Text("\(temp)°C").font(.system(size: 50, weight: .thin))
                        }
                        .transition(.scale.combined(with: .opacity))
                    case .failure(let error):
                        VStack {
                            // 修正拼写：triangle
                            Image(systemName: "exclamationmark.triangle").foregroundColor(.red)
                            // 修正括号：网络不给力
                            Text("查询失败: \(error == .networkError ? "网络不给力" : "找不到该城市")")
                                .font(.caption)
                            Button("重试") {
                                viewModel.runQuery()
                            }
                            .padding(.top, 5)
                        }
                    }
                }
                .padding(.horizontal)
                
                // --- 3. 历史记录列表 ---
                // 调用内部定义的计算属性视图
                historySection
                
                Spacer()
            }
            .navigationTitle("Weather Lab")
        }
    }
    
    // 把 historySection 放在 WeatherView 的大括号内，作为计算属性
    private var historySection: some View {
        VStack(alignment: .leading) {
            if !viewModel.history.isEmpty {
                Text("最近搜索")
                    .font(.caption).bold().padding(.leading)
                
                List(viewModel.history) { record in
                    Button(action: {
                        viewModel.selectFromHistory(record)
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(record.city).font(.body)
                                Text("更新于 \(record.timeString)").font(.system(size: 10)).foregroundColor(.gray)
                            }
                            Spacer()
                            Text("\(record.temperature)°").foregroundColor(.blue)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}
