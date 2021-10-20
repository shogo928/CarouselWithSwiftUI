//
//  SampleCollectionView.swift
//  CarouselWithSwiftUI
//
//  Created by sakumashogo on 2021/10/20.
//

import SwiftUI

struct CalendarView: UIViewRepresentable {
    @Binding var latestMonthArray: [Int]

    init(_ latestMonthArray: Binding<[Int]>) {
        self._latestMonthArray = latestMonthArray
    }
    
    class Coordinator: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
        var weekArray: [String] = ["日","月","火","水","木","金","土"]
        @Binding var latestMonthArray: [Int]

        init(_ latestMonthArray: Binding<[Int]>) {
            self._latestMonthArray = latestMonthArray
        }

        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 2
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            switch section {
            case 0:
                return weekArray.count
            case 1:
                return latestMonthArray.count
            default:
                return 0
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell

            switch indexPath.section {
            case 0:
                switch weekArray[indexPath.item] {
                case "日":
                    cell.customView?.rootView = Text("\(weekArray[indexPath.item])").foregroundColor(.red)
                case "土":
                    cell.customView?.rootView = Text("\(weekArray[indexPath.item])").foregroundColor(.blue)
                default :
                    cell.customView?.rootView = Text("\(weekArray[indexPath.item])").foregroundColor(.gray)
                }
            case 1:
                switch latestMonthArray[indexPath.item] {
                case 0:
                    cell.customView?.rootView = Text("")
                default :
                    cell.customView?.rootView = Text("\(latestMonthArray[indexPath.item])").foregroundColor(.gray)
                }
            default:
                cell.customView?.rootView = Text("").foregroundColor(.gray)
            }
            
            
            return cell
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator($latestMonthArray)
    }
    
    func makeUIView(context: UIViewRepresentableContext<CalendarView>) -> UICollectionView {
        let itemSizeWidth: CGFloat = UIScreen.main.bounds.width / 7
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSizeWidth, height: 40)
        layout.headerReferenceSize = CGSize(width: 0, height: 0)
        layout.footerReferenceSize = CGSize(width: 0, height: 0)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = true
        collectionView.register(Cell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = .white
        
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        return collectionView
    }
    
    func updateUIView(_ uiView: UICollectionView, context : UIViewRepresentableContext<CalendarView>) {
        uiView.reloadData()
    }
    
    final class Cell: UICollectionViewCell {
        fileprivate var textView = Text("")
        fileprivate var customView: UIHostingController<Text>?
        
        fileprivate override init(frame: CGRect) {
            super.init(frame: frame)
            
            customView = UIHostingController(rootView: textView)
            customView!.view.frame = CGRect(origin: .zero, size: contentView.bounds.size)
            customView!.view.backgroundColor = .clear
            contentView.addSubview(customView!.view)
        }
        
        internal required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}


