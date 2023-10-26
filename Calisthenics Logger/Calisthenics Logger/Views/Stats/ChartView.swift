//
//  ChartView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 11.10.23.
//

import FirebaseFirestoreSwift
import SwiftUI
import Charts

struct ChartView: View {
    @StateObject var viewModel: ChartViewViewModel
//    @FirestoreQuery var sampleAnalytics: [Sample]
//    @State var sampleAnalytics: [Sample] = [
//        Sample(id: "1", date: 1696804925, content: 1),
//        Sample(id: "2", date: 1696804925 + 24*60*60, content: 2.5),
//        Sample(id: "3", date: 1696804925 + 2*24*60*60, content: 3),
//    ]
    @State var currentActiveItem: Sample?
    @State var plotWidth: CGFloat = 0
    @State var style = "bars"
    @State var animate: [String:Bool] = [:]
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var reloadSamples: Int
    
    private let userId: String
    private let statId: String
    
    private let chartYAxisLabel: String
    
    private let lite: Bool
    private let details: Bool
    
    private let decimals: Double = 3
    private let round_factor: Double
    
    init(
        userId: String, statId: String,
        chartYAxisLabel: String = "",
        lite: Bool = false, details: Bool = false,
        reloadSamples: Binding<Int>
    ) {
        self.userId = userId
        self.statId = statId
        
        self.chartYAxisLabel = chartYAxisLabel
        
        self.lite = lite
        self.details = details

        self.round_factor = pow(10, decimals)
        
        self._reloadSamples = reloadSamples
        
        self._viewModel = StateObject(
            wrappedValue: ChartViewViewModel(
                userId: userId,
                statId: statId
            )
        )
    }
    
    var body: some View {
        NavigationStack {
            if lite { chartView } else {
                VStack {
                    Picker("", selection: $style) {
                        Text("bars").tag("bars")
                        Text("lines").tag("lines")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 365)
                    .padding()

                    chartView
                    
                    detailsView
                    
                    Spacer()
                }
            }
        }
        .onChange(
            of: viewModel.loaded,
            perform: { _ in
                animateGraph()
            }
        )
        .onChange(
            of: reloadSamples,
            perform: { _ in
                viewModel.load()
                animateGraph()
            }
        )
    }

    @ViewBuilder
    var chartView: some View {
        let max = viewModel.sampleAnalytics.max { item1, item2 in
            return item2.content > item1.content
        }?.content ?? 0

        Chart {
            ForEach(viewModel.sampleAnalytics) { item in
                if style == "bars" {
                    BarMark(
                        x: .value("Date", Date(timeIntervalSince1970: item.date), unit: .day),
                        y: .value("Content", animate[item.id, default: false] ? item.content : 0)
                    )
                    .foregroundStyle(.blue.gradient)
                }
                if style == "lines" {
                    LineMark(
                        x: .value("Date", Date(timeIntervalSince1970: item.date), unit: .day),
                        y: .value("Content", animate[item.id, default: false] ? item.content : 0)
                    )
                    .foregroundStyle(.blue.gradient)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("date", Date(timeIntervalSince1970: item.date), unit: .day),
                        y: .value("Content", animate[item.id, default: false] ? item.content : 0)
                    )
                    .foregroundStyle(.blue.opacity(0.1))
                    .interpolationMethod(.catmullRom)
                }
            }
        }
        .chartYScale(domain: 0...(max * 1.1))
        .chartYAxisLabel(position: .trailing, alignment: .center) {
            if chartYAxisLabel != "" {
                Text(chartYAxisLabel)
            }
        }
        .frame(width: !lite ? 328 : 280, height: !lite ? 225 : 120)
        .onAppear {
            animateGraph()
        }
        .padding()
        .background {
            if !lite {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        (colorScheme == .light ? Color.white : Color(.systemGray6))
                            .shadow(.drop(radius: 2))
                    )
            }
        }
    }

    func animateGraph() {
        for (index, _) in viewModel.sampleAnalytics.enumerated() {
            withAnimation(
                .interactiveSpring(
                    response: 1,
                    dampingFraction: 1,
                    blendDuration: 1
                )
                .delay(Double(index) * 0.075)
            ) {
                animate[viewModel.sampleAnalytics[index].id] = true
            }
        }
    }
    
    @ViewBuilder
    var detailsView: some View {
        if details {
            let titles: [String] = ["mean", "std", "min", "max", "last"]
            let stats: [Double?] = [
                viewModel.contents.mean(),
                viewModel.contents.std(),
                viewModel.contents.min(),
                viewModel.contents.max(),
                viewModel.contents.last
            ]
            Form {
                ForEach(Array(zip(titles, stats)), id: \.0) { title, stat in
                    HStack {
                        Text(title)
                        Spacer()
                        if let stat = stat {
                            let rounded = round(stat * round_factor) / round_factor
                            Text(String(rounded))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ChartView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        statId: "D5E5E158-856A-45DD-828A-0AB06CD533E9",
        reloadSamples: Binding(
            get: { return 0 },
            set: { _ in }
        )
    )
}
