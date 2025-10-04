//
//  CalorieCalculatorViewController.swift
//  NutriCheckProject
//
//  Created by Miguel Angel Hernandez Barcenas on 04/10/25.
//

import UIKit

class CalorieCalculatorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Calculadora de Calorías"
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "Aquí iría la lógica de la calculadora."
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
