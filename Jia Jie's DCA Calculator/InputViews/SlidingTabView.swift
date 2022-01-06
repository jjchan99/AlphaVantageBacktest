import SwiftUI

@available(iOS 13.0, *)
public struct SlidingTabView : View {
    
    // MARK: Internal State
    
    /// Internal state to keep track of the selection index
    @State private var selectionState: Int {
        didSet {
            selection = selectionState
        }
    }
    
    // MARK: Required Properties
    
    /// Binding the selection index which will  re-render the consuming view
    @Binding var selection: Int
    
    /// The title of the tabs
    let tabs: [String]
    
    // Mark: View Customization Properties
    
    /// The font of the tab title
    let font: Font
    
    /// The selection bar sliding animation type
    let animation: Animation
    
    /// The color of the selection bar
    let selectionBarColor: Color
    
    /// The tab color when the tab is not selected
    let inactiveTabColor: Color
    
    /// The tab color when the tab is  selected
    let activeTabColor: Color
    
    /// The height of the selection bar
    let selectionBarHeight: CGFloat
    
    /// The height of the selection bar background
    let selectionBarBackgroundHeight: CGFloat
    
    // MARK: init
    
    public init(selection: Binding<Int>,
                tabs: [String],
                font: Font = .callout,
                animation: Animation = .spring(),
                selectionBarColor: Color = Color(#colorLiteral(red: 1, green: 0, blue: 0.9588134618, alpha: 1)),
                inactiveTabColor: Color = Color(#colorLiteral(red: 0.9092124074, green: 0.9092124074, blue: 0.9092124074, alpha: 1)),
                activeTabColor: Color = Color(#colorLiteral(red: 0.9092124074, green: 0.9092124074, blue: 0.9092124074, alpha: 1)),
                selectionBarHeight: CGFloat = 2,
                selectionBarBackgroundHeight: CGFloat = 1) {
        self._selection = selection
        self.tabs = tabs
        self.font = font
        self.animation = animation
        self.selectionBarColor = selectionBarColor
        self.inactiveTabColor = inactiveTabColor
        self.activeTabColor = activeTabColor
        self.selectionBarHeight = selectionBarHeight
        self.selectionBarBackgroundHeight = selectionBarBackgroundHeight
        
        self.selectionState = selection.wrappedValue
    }
    
    // MARK: View Construction
    
    public var body: some View {
        assert(tabs.count > 1, "Must have at least 2 tabs")
        
        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                ForEach(self.tabs, id:\.self) { tab in
                    Button(action: {
                        let selection = self.tabs.firstIndex(of: tab) ?? 0
                        self.selectionState = selection
                    }) {
                        HStack {
                            Spacer()
                            Text(tab).font(self.font)
                            Spacer()
                        }
                    }
                    .padding(.vertical, 16)
                        .background(
                            self.isSelected(tabIdentifier: tab)
                                ? self.activeTabColor
                                : self.inactiveTabColor)
                }
            }
//            GeometryReader { geometry in
           
                Rectangle()
                    .fill(self.selectionBarColor)
                    .frame(width: self.tabWidth(from: Dimensions.width), height: self.selectionBarHeight, alignment: .leading)
                    .offset(x: self.selectionBarXOffset(from: Dimensions.width), y: 0)
                    .animation(self.animation)
                   
                
//                .fixedSize(horizontal: false, vertical: true)
//            }
//            .fixedSize(horizontal: false, vertical: true)
            
        }
        .background(Color(#colorLiteral(red: 0.9092124074, green: 0.9092124074, blue: 0.9092124074, alpha: 1)))
    }
    
    // MARK: Private Helper
    
    private func isSelected(tabIdentifier: String) -> Bool {
        return tabs[selectionState] == tabIdentifier
    }
    
    private func selectionBarXOffset(from totalWidth: CGFloat) -> CGFloat {
        return self.tabWidth(from: totalWidth) * CGFloat(selectionState)
    }
    
    private func tabWidth(from totalWidth: CGFloat) -> CGFloat {
        return totalWidth / CGFloat(tabs.count)
    }
}
