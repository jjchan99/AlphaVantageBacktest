//
//  GraphView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 2/10/21.
//

import SwiftUI
import Combine
import Foundation

struct GraphView: View {
    
    @EnvironmentObject var viewModel: GraphViewModel
    
    @State var mode: Mode = .gain

    @ViewBuilder var body: some View {
        if viewModel.shouldDrawGraph ?? false {
            ZStack {
            VStack {
                HStack {
                    SwitchModeButton(mode: $mode, left: true)
                VStack {
                    Text("\(mode.getTitle())")
                        .font(.system(size: CGFloat(15).hScaled()))
                    HStack {
                    let data = viewModel.results.last!
                        let dataMode = data.mode(mode: mode)
                    let image: String = dataMode < 0 ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill"
                        Image(systemName: image).foregroundColor(dataMode < 0 ? .red : .green)
                        Text("\(data.format(mode: mode))")
                            .font(.system(size: CGFloat(25).hScaled()).bold())
                    }
                }
                    SwitchModeButton(mode: $mode, left: false)
                }.padding()
                VStack(spacing: 0) {
                YAxisView(mode: $mode, min: false)
                    .padding(.init(top: 0, leading: 0, bottom: CGFloat(15).hScaled(), trailing: 0))
                    LineGraphView(mode: $mode)
                    .environmentObject(viewModel)
                    .overlay(ZeroLineView( mode: $mode).environmentObject(viewModel))
                    .frame(width: viewModel.width, height: viewModel.height)
                    HStack {
                YAxisView(mode: $mode, min: true)
                DateIndicatorView()
                .environmentObject(viewModel)
                }
                .padding(.init(top: CGFloat(15).hScaled(), leading: 0, bottom: 0, trailing: 0))
                }
            }
            }
        }
    }
    }


