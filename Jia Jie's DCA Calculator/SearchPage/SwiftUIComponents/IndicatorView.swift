//
//  IndicatorView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 14/10/21.
//

//MARK: SO YOU SINK IT IS EASY TO WIN TROPHIES?
//MARK: Man United 0-5 Liverpool

import SwiftUI

struct IndicatorView: View {
    
    @State var showPlot: Bool = false
    @State var currentPlot: String?
    @Binding var mode: Mode
    @Binding var graphPoints: [CGPoint]
    @Binding var spec: Specifications<Double>
    @State var selectedYPos: CGFloat?
    @State var selectedIndex: Int = 0
    @State var labelOffset: CGFloat = 0
    
    init(mode: Binding<Mode>, graphPoints: Binding<[CGPoint]>, spec: Binding<Specifications<Double>>) {
        self._mode = mode
        self._graphPoints = graphPoints
        self._spec = spec
    }
    
    @EnvironmentObject var viewModel: GraphViewModel
    
    @ViewBuilder var body: some View {
        if viewModel.results.count != 0 && graphPoints.count != 0 {
            let defaultPositionForLabel: CGFloat = (viewModel.width * 0.05)
            ZStack {
                Text(currentPlot ?? "0.0")
                .font(.caption.bold())
                .foregroundColor(.white)
                .padding(.vertical,6)
                .padding(.horizontal,10)
                .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
                .clipShape(Capsule())
                .position(x: (labelOffset == 0 ? defaultPositionForLabel : labelOffset), y: ((selectedYPos ?? graphPoints[0].y) - 30))
//                .offset(x: labelOffset)
            Circle()
                .fill(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
                .frame(width: 22, height: 22)
                .position(x: 0, y: selectedYPos ?? graphPoints[0].y)
                .overlay(
                    Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .position(x: 0, y: selectedYPos ?? graphPoints[0].y)
                )
                .offset(x: viewModel.offset)
        }
        .frame(width: viewModel.width, height: viewModel.height)
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 0)
                    .onChanged({ touch in
                        let xPos = touch.location.x
                        guard xPos >= 0 && xPos <= viewModel.width else {
                            return
                        }

                        showPlot = true
                        viewModel.offset = xPos
                        
                        let leftExtreme = viewModel.width * 0.1
                        let rightExtreme = viewModel.width * 0.9
                        if xPos <= leftExtreme {
                            labelOffset = (xPos + viewModel.width * 0.05)
                        } else if xPos >= rightExtreme {
                            labelOffset = (xPos - viewModel.width * 0.05)
                        } else if xPos > leftExtreme && xPos < rightExtreme {
                            labelOffset = xPos
                        }
                    
                        let indicator = YDragGesture(graphPoints: graphPoints, spec: spec)

                        let result: (selectedIndex: Int, currentPlot: CGFloat, selectedYPos: CGFloat) = indicator.updateIndicator(xPos: xPos)
                        self.currentPlot = "\(result.currentPlot)"
                        self.selectedYPos = result.selectedYPos
                        viewModel.selectedIndex = result.selectedIndex
//                        print("Y is at: \(currentPlot!) X is at: \(xPos)")
//                        print("evaluate this: \(indicator.updateIndicator(xPos: viewModel.width))")
//                        print("evaluate this: \(indicator.updateIndicator(xPos: 0))")
                        
                        //DONE
                    }).onEnded({ touch in
                        withAnimation {
                            showPlot = false
                        }
                    }))
        .frame(width: viewModel.width, height: viewModel.height)
            .onChange(of: mode) { _ in
                viewModel.id = UUID()
            }
            .onChange(of: viewModel.id) { _ in
                selectedYPos = graphPoints[0].y
                viewModel.offset = .zero
                currentPlot = "0.0"
                labelOffset = defaultPositionForLabel
            }
            .onChange(of: viewModel.shouldDrawGraph) { _ in
                selectedYPos = graphPoints[0].y
                viewModel.offset = .zero
                currentPlot = "0.0"
                labelOffset = defaultPositionForLabel
            }
    }
}
}

