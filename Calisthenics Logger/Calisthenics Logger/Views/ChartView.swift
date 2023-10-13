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
    
    private let userId: String
    private let statId: String
    
    init(userId: String, statId: String) {
        self.userId = userId
        self.statId = statId
        
        self._viewModel = StateObject(
            wrappedValue: ChartViewViewModel(
                userId: userId,
                statId: statId
            )
        )
        
//        self._sampleAnalytics = FirestoreQuery(
//            collectionPath: "users/\(userId)/stats/\(statId)/samples"
//        )
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                chartView
                
                Picker("", selection: $style) {
                    Text("bars")
                        .tag("bars")
                    Text("lines")
                        .tag("lines")
                }
                .pickerStyle(.segmented)
                .frame(width: 365)
                
                Form {
                    HStack {
                        Text("mean")
                        Spacer()
                        Text("\(viewModel.contents.mean())")
                    }
                    HStack {
                        Text("std")
                        Spacer()
                        Text("\(viewModel.contents.std())")
                    }
                    HStack {
                        Text("min")
                        Spacer()
                        Text("\(viewModel.contents.min() ?? 0)")
                    }
                    HStack {
                        Text("max")
                        Spacer()
                        Text("\(viewModel.contents.max() ?? 0)")
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Chart")
        }
        .onChange(of: viewModel.loaded, initial: false) { _, _  in
            animateGraph()
        }
        .onChange(of: style, initial: false) { _, _  in
            viewModel.load()
        }
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
        .frame(height: 200)
        .onAppear {
            animateGraph()
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.white.shadow(.drop(radius: 2)))
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
                .delay(Double(index) * 0.01)
            ) {
                animate[viewModel.sampleAnalytics[index].id] = true
            }
        }
    }
}

#Preview {
    ChartView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        statId: "D5E5E158-856A-45DD-828A-0AB06CD533E9"
    )
}
