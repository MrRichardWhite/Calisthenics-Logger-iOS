//
//  StatView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 08.10.23.
//

import FirebaseFirestoreSwift
import SwiftUI
import Charts

struct StatView: View {
    @StateObject var viewModel: StatViewViewModel
    @FirestoreQuery var exerciseTemplates: [ExerciseTemplate]
    @FirestoreQuery var metadateTemplates: [MetadateTemplate]
    
    @State var sampleAnalytics: [SiteView] = sample_analytics
    @State var currentActiveItem: SiteView?
    @State var plotWidth: CGFloat = 0
    @State var style = "bars"
    
    private let userId: String
    private let statId: String
    
    init(userId: String, statId: String) {
        self.userId = userId
        self.statId = statId
        
        self._exerciseTemplates = FirestoreQuery(
            collectionPath: "users/\(userId)/exerciseTemplates"
        )
        self._metadateTemplates = FirestoreQuery(
            collectionPath: "users/\(userId)/metadateTemplates"
        )
        self._viewModel = StateObject(
            wrappedValue: StatViewViewModel(
                userId: userId,
                statId: statId
            )
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                chartView()
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.white.shadow(.drop(radius: 2)))
                    }
                
                Picker("", selection: $style) {
                    Text("bars")
                        .tag("bars")
                    Text("lines")
                        .tag("lines")
                }
                .pickerStyle(.segmented)
                
                Form {
                    Section {
                        Picker("Exercise", selection: $viewModel.exerciseTemplateId) {
                            ForEach(viewModel.exerciseTemplateIds(exerciseTemplates: exerciseTemplates), id: \.self) { exerciseTemplateId in
                                let text = viewModel.id2name(
                                    exerciseTemplates: exerciseTemplates,
                                    id: exerciseTemplateId
                                )
                                Text(text)
                            }
                        }

                        Picker("Metdate", selection: $viewModel.metadateTemplateId) {
                            ForEach(viewModel.metadateTemplateIds(metadateTemplates: metadateTemplates), id: \.self) { exerciseTemplateId in
                                let text = viewModel.id2name(
                                    metadateTemplates: metadateTemplates,
                                    id: exerciseTemplateId
                                )
                                Text(text)
                            }
                        }
                        
                        CLButton(title: "Save", background: viewModel.background) {
                            if !viewModel.dataIsInit {
                                viewModel.save()
                            } else {
                                viewModel.alertTitle = "Warning"
                                viewModel.alertMessage = "Data was not changed!"
                                viewModel.showAlert = true
                            }
                        }
                        .padding()
                    }
                    
                    Section {
                        NavigationLink(
                            destination: filtersView
                        ) {
                            VStack(alignment: .leading) {
                                Text("Filters")
                            }
                        }
                    }
                }
                .frame(width: 400)
                .alert(isPresented: $viewModel.showAlert) {
                    Alert(
                        title: Text(viewModel.alertTitle),
                        message: Text(viewModel.alertMessage)
                    )
                }
            }
            .padding()
            .navigationTitle("Stats")
            .onChange(of: style, initial: false) { _, _  in
                sampleAnalytics = sample_analytics
                animateGraph(fromChange: true)
            }
        }
    }
    
    @ViewBuilder
    func chartView() -> some View {
        let max = sampleAnalytics.max { item1, item2 in
            return item2.views > item1.views
        }?.views ?? 0
        
        Chart {
            ForEach(sampleAnalytics) { item in
                if style == "bars" {
                    BarMark(
                        x: .value("Hour", item.hour, unit: .hour),
                        y: .value("Views", item.animate ? item.views : 0)
                    )
                    .foregroundStyle(.blue.gradient)
                }
                if style == "lines" {
                    LineMark(
                        x: .value("Hour", item.hour, unit: .hour),
                        y: .value("Views", item.animate ? item.views : 0)
                    )
                    .foregroundStyle(.blue.gradient)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Hour", item.hour, unit: .hour),
                        y: .value("Views", item.animate ? item.views : 0)
                    )
                    .foregroundStyle(.blue.opacity(0.1))
                    .interpolationMethod(.catmullRom)
                }
                
                if let currentActiveItem, currentActiveItem .id == item.id {
                    RuleMark(x: .value("Hour", currentActiveItem.hour))
                        .lineStyle(.init(lineWidth: 2, miterLimit: 2, dash: [2], dashPhase: 5))
                        .offset(x: (plotWidth / CGFloat(sampleAnalytics.count)) / 2)
                        .annotation(position: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                let text = String(currentActiveItem.views)
                                Text(text)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(.white.shadow(.drop(radius: 2)))
                        }
                    }
                }
            }
        }
        .chartYScale(domain: 0...(max * 1.1))
        .chartOverlay { proxy in
            GeometryReader { innerProxy in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let location = value.location
                                if let date: Date = proxy.value(atX: location.x) {
                                    let calendar = Calendar.current
                                    let hour = calendar.component(.hour, from: date)
                                    if let currentItem = sampleAnalytics.first(
                                        where: { item in
                                            calendar.component(.hour, from: item.hour) == hour
                                        }
                                    ) {
                                        self.currentActiveItem = currentItem
                                        self.plotWidth = proxy.plotSize.width
                                    }
                                }
                            }
                            .onEnded { value in
                                self.currentActiveItem = nil
                            }
                    )
            }
        }
        .frame(height: 200)
        .onAppear {
            animateGraph()
        }
    }
    
    func animateGraph(fromChange: Bool = false) {
        for (index, _) in sampleAnalytics.enumerated() {
            withAnimation(
                .interactiveSpring(
                    response: 1,
                    dampingFraction: 1,
                    blendDuration: 1
                )
                .delay(Double(index) * (fromChange ? 0 : 0.01))
            ) {
                sampleAnalytics[index].animate = true
            }
        }
    }
    
    @ViewBuilder
    func filtersView() -> some View {
        Text("Hello World!")
    }
}

#Preview {
    StatView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        statId: "D5E5E158-856A-45DD-828A-0AB06CD533E9"
    )
}
