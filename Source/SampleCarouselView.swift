//
//  SampleCarouselView.swift
//  CarouselWithSwiftUI
//
//  Created by sakumashogo on 2021/10/20.
//

import SwiftUI

class SampleDataCompornent: ObservableObject {
    @Published var isLatestMonthArray: [Int] = []
    @Published var isWhatMonth: Int = 0
    @Published var isWhatToday: Int = 0
    @Published var isYearAndMonthString: String = ""
    
    @Published var isScrollOffset: Double = 0.0
    @Published var isCalendarViewHeight: Int = 0

    let date: Date
    let dateFormatter: DateFormatter
    var calendar: Calendar
    var dateComponents: DateComponents
    
    init() {
        date = Date()
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月"
        
        calendar = Calendar(identifier: .gregorian)
        dateComponents = Calendar.current.dateComponents([.year], from: date)
        dateComponents.calendar = calendar
        dateComponents.month = calendar.component(.month, from: date)
        
        isWhatMonth = calendar.component(.month, from: date)
        isWhatToday = calendar.component(.day, from: date)
        
        calendarDateGenerater()
        calendarSizeGenerater()
    }
    
    func calendarDateGenerater() {
        dateComponents.month = isWhatMonth

        guard let yMDateComponent = calendar.date(from: dateComponents) else { return }
        isYearAndMonthString = dateFormatter.string(from: yMDateComponent)

        guard let daysDateComponent = calendar.date(from: dateComponents),
              let daysDateComponentRange = calendar.range(of: .day, in: .month, for: daysDateComponent)
        else { return }
        
        for _ in 1..<Calendar.current.component(Calendar.Component.weekday, from: daysDateComponent) {
            isLatestMonthArray += [0]
        }
        
        isLatestMonthArray += daysDateComponentRange
    }
    
    func calendarSizeGenerater() {
        let weekOfMonthDouble: Double = Double(isLatestMonthArray.count) / 7.0
        let weekOfMonthInt: Int = isLatestMonthArray.count / 7

        if weekOfMonthDouble - Double(weekOfMonthInt) > 0 {
            isCalendarViewHeight = (weekOfMonthInt + 1) * 40 + 40
        } else if weekOfMonthDouble - Double(weekOfMonthInt) == 0 {
            isCalendarViewHeight = (weekOfMonthInt) * 40 + 40
        }
    }
}

struct SampleCarouselView: View {
    @ObservedObject var sampleDataCompornent: SampleDataCompornent
    
    init() {
        self.sampleDataCompornent = SampleDataCompornent()
    }
    
    var body: some View {
        ZStack {
            Color(.darkGray).edgesIgnoringSafeArea(.all)
            
            VStack {
                yMText
                calendarView
            }
        }
    }
}

extension SampleCarouselView {
    var yMText: some View {
        HStack {
            Text("\(sampleDataCompornent.isYearAndMonthString)")
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {
                sampleDataCompornent.isLatestMonthArray.removeAll()
                sampleDataCompornent.isWhatMonth += 1
                sampleDataCompornent.calendarDateGenerater()
            }, label: {
                Text("＜")
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .foregroundColor(.white)
            })
            
            Button(action: {
                sampleDataCompornent.isLatestMonthArray.removeAll()
                sampleDataCompornent.isWhatMonth -= 1
                sampleDataCompornent.calendarDateGenerater()
            }, label: {
                Text("＞")
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .foregroundColor(.white)
            })
        }.padding(.top, 10)
    }
    
    var calendarView: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top) {
                        CalendarView($sampleDataCompornent.isLatestMonthArray)
                    }
                }.content.offset(x: CGFloat(sampleDataCompornent.isScrollOffset))
                .gesture(DragGesture()
                            .onChanged { value in
                                sampleDataCompornent.isScrollOffset = Double(value.translation.width)
                            }
                            .onEnded { value in
                                if value.predictedEndTranslation.width > geometry.size.width / 2 {
                                    sampleDataCompornent.isLatestMonthArray.removeAll()
                                    sampleDataCompornent.isWhatMonth -= 1
                                    sampleDataCompornent.calendarDateGenerater()
                                    
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        sampleDataCompornent.isScrollOffset = Double(geometry.size.width)
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        sampleDataCompornent.isScrollOffset = -Double(geometry.size.width)
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.21) {
                                        withAnimation(.easeOut(duration: 0.2)) {
                                            sampleDataCompornent.isScrollOffset = 0.0
                                        }
                                    }

                                } else if value.predictedEndTranslation.width < -geometry.size.width / 2 {
                                    sampleDataCompornent.isLatestMonthArray.removeAll()
                                    sampleDataCompornent.isWhatMonth += 1
                                    sampleDataCompornent.calendarDateGenerater()
                                    
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        sampleDataCompornent.isScrollOffset = -Double(geometry.size.width)
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        sampleDataCompornent.isScrollOffset = Double(geometry.size.width)
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.21) {
                                        withAnimation(.easeOut(duration: 0.2)) {
                                            sampleDataCompornent.isScrollOffset = 0.0
                                        }
                                    }
                                }
                                
                                if value.predictedEndTranslation.width > -geometry.size.width / 2 && value.predictedEndTranslation.width < geometry.size.width / 2 {
                                    withAnimation {
                                        sampleDataCompornent.isScrollOffset = 0.0
                                    }
                                }
                            }
                )
            }
        }.frame(height: CGFloat(sampleDataCompornent.isCalendarViewHeight))
        .padding(.bottom, 10)
        .onChange(of: sampleDataCompornent.isLatestMonthArray) { _ in
            withAnimation {
                sampleDataCompornent.calendarSizeGenerater()
            }
        }
    }
}

struct SampleCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        SampleCarouselView()
    }
}
