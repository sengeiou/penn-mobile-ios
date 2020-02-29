//
//  VariableStepLineGraphView.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/28/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13, *)
struct VariableStepLineGraphView: View {
    
    private let graphHeight: CGFloat = 160.0
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @State private var trimEnd: CGFloat = 0.0
    @GestureState private var dragActive = false
    @State var data: [PredictionsGraphView.YXDataPoint]
    @State var lastPointPosition: CGFloat = 0.0
    @State var xAxisLabels: [String]
    @State var yAxisLabels: [String]
    var lineColor: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: 20)
            HStack {
                // Y-Axis labels
                VStack(alignment: .leading) {
                    ForEach(0 ..< yAxisLabels.count) { num in
                        if num != 0 { Spacer() }
                        Text(self.yAxisLabels[num])
                            .font(.subheadline)
                            .opacity(0.5)
                    }
                }
                .frame(width: 40, height: self.graphHeight)
                
                GeometryReader { geometry in
                    
                    ZStack {
                        
                        VariableStepGraphPath(data: self.data).trim(from: 0, to: self.trimEnd).stroke(
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                        )
                            .foregroundColor(self.lineColor)
                            .frame(height: self.graphHeight)
                            .animation(.default)
                            .onAppear {
                                self.trimEnd = 1.0
                        }
                        
                        
                        PredictionSlopePath(data: self.data.last!, predictionSlope: -0.2).stroke(
                            style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round, dash: [5], dashPhase: 5)
                        )
                            .foregroundColor(.gray)
                            .frame(height: self.graphHeight)
                            .animation(.default)
                            .onAppear {
                                self.trimEnd = 1.0
                        }
                        .clipped()
                        
                        Group {
                            Group {
                                HStack(alignment: .center) {
                                    Spacer()
                                    Text("Today")
                                    Image(systemName: "circle.fill")
                                }
                                .foregroundColor(.white)
                                .font(.caption)
                            }
                            .frame(width: 140)
                            .offset(x: -70 + 5.5 + ((self.lastPointPosition - 0.5) * geometry.size.width), y: -6 - geometry.size.height/2)
                            
                            GraphEndpointPath(x: self.lastPointPosition).stroke(
                                style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round)
                            )
                                .foregroundColor(.white)
                                .frame(height: self.graphHeight)
                        }
                        
                        Group {
                            Group {
                                HStack(alignment: .center) {
                                    Spacer()
                                    Text("End of Term")
                                    Image(systemName: "circle.fill")
                                }
                                .foregroundColor(.red)
                                .font(.caption)
                            }
                            .frame(width: 140)
                            .offset(x: -70 + 5.5 + ((1.0 - 0.5) * geometry.size.width), y: -6 - geometry.size.height/2)
                            
                            GraphEndpointPath(x: 1.0).stroke(
                                style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round)
                            )
                                .foregroundColor(.red)
                                .frame(height: self.graphHeight)
                        }
                    }
                }
                .frame(height: graphHeight)
            }
            // X-Axis labels
            HStack {
                Spacer()
                    .frame(width: 40)
                ForEach(0 ..< xAxisLabels.count) { num in
                    if num != 0 { Spacer() }
                    Text(self.xAxisLabels[num])
                        .font(.subheadline)
                        .opacity(0.5)
                }
            }
            .frame(height: 20)
        }
    }
}
