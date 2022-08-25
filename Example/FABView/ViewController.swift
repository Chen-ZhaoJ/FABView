//
//  ViewController.swift
//  FABView
//
//  Created by Chen-ZhaoJ on 08/25/2022.
//  Copyright (c) 2022 Chen-ZhaoJ. All rights reserved.
//

import UIKit
import FABView
class ViewController: UIViewController {

    let Floaty = FloatingActionButtonView(collapseImage: UIImage(), expandImage: UIImage())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemGray2
        testLable()
        addFloatingActionButtonView()
    }
    
    func addFloatingActionButtonView(){
        Floaty.createFAB(image: UIImage())
        Floaty.createFAB(image: UIImage(), title: "collapse FAB", target: #selector(collapseFAB(_:)), atVC: self)
        Floaty.createFAB(image: UIImage(), title: "no collapse", target: #selector(noCollapse(_:)), atVC: self)
        
        //layoutFloaty
        view.addSubview(Floaty)
        Floaty.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([Floaty.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0),
                                     Floaty.heightAnchor.constraint(equalTo: view.heightAnchor, constant: 0)])
    }
    
    func testLable(){
        let testlable:UILabel = UILabel()
        testlable.text = "testtesttest"
        testlable.textColor = .systemYellow
        view.addSubview(testlable)
        testlable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([testlable.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     testlable.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController {
    @IBAction func collapseFAB (_ sender: UIButton){
        print("one Button Clicked")
        Floaty.collapseFAB()
    }
    
    @IBAction func noCollapse (_ sender: UIButton){
        print("two Button Clicked")
    }
}
