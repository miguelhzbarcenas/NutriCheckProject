//
//  WaterCalculatorViewController.swift
//  NutriCheckProject
//
//  Created by Miguel Angel Hernandez Barcenas on 24/11/25.
//

import UIKit

class WaterCalculatorViewController: UIViewController {

    // MARK: - Properties
    var patient: Patient?
    
    // Factores de cálculo (ml por kg de peso)
    let factors: [Double] = [30.0, 35.0, 40.0, 45.0]
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "drop.fill")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemCyan
        iv.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return iv
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Hidratación Diaria"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .systemCyan
        return label
    }()

    private lazy var factorSegmentedControl: UISegmentedControl = {
        let items = ["30ml", "35ml", "40ml", "45ml"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 1 
        sc.backgroundColor = .systemCyan.withAlphaComponent(0.1)
        sc.selectedSegmentTintColor = .white
        sc.addTarget(self, action: #selector(calculateWater), for: .valueChanged)
        return sc
    }()
    
    private let factorDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Recomendación estándar para adultos saludables."
        label.font = .italicSystemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var totalLitersLabel = createResultCard(title: "Total Litros", color: .systemCyan)
    private lazy var totalGlassesLabel = createResultCard(title: "Vasos (250ml)", color: .systemBlue)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        calculateWater()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        title = "Calculadora de Agua"
        view.backgroundColor = .white
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(headerLabel)
        
        if let p = patient {
            let weightLabel = UILabel()
            weightLabel.text = "Peso del Paciente: \(p.weight) kg"
            weightLabel.textAlignment = .center
            weightLabel.font = .systemFont(ofSize: 16, weight: .medium)
            stackView.addArrangedSubview(weightLabel)
        }
        
        addSeparator()
        
        let factorTitle = UILabel()
        factorTitle.text = "Factor Hídrico (ml/kg)"
        factorTitle.font = .systemFont(ofSize: 16, weight: .semibold)
        factorTitle.textAlignment = .center
        
        stackView.addArrangedSubview(factorTitle)
        stackView.addArrangedSubview(factorSegmentedControl)
        stackView.addArrangedSubview(factorDescriptionLabel)
        
        addSeparator()
        
        stackView.addArrangedSubview(totalLitersLabel)
        stackView.addArrangedSubview(totalGlassesLabel)
    }
    
    private func addSeparator() {
        let line = UIView()
        line.backgroundColor = .systemGray5
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stackView.addArrangedSubview(line)
    }
    
    // MARK: - Logic
    @objc private func calculateWater() {
        guard let p = patient, p.weight > 0 else {
            updateResult(card: totalLitersLabel, value: "N/A")
            return
        }
        
        let index = factorSegmentedControl.selectedSegmentIndex
        let factor = factors[index]
        
        switch index {
        case 0: factorDescriptionLabel.text = "Sedentario / Adulto Mayor"
        case 1: factorDescriptionLabel.text = "Adulto Promedio (Estándar)"
        case 2: factorDescriptionLabel.text = "Activo / Clima Cálido"
        case 3: factorDescriptionLabel.text = "Atleta de Alto Rendimiento / Pérdida excesiva"
        default: break
        }
        
        let totalMl = p.weight * factor
        let totalLiters = totalMl / 1000.0
        let glasses = totalMl / 250.0
        
        updateResult(card: totalLitersLabel, value: String(format: "%.2f L", totalLiters))
        updateResult(card: totalGlassesLabel, value: String(format: "%.0f Vasos", glasses))
    }
    
    private func updateResult(card: UIView, value: String) {
        if let label = card.viewWithTag(100) as? UILabel {
            label.text = value
        }
    }
    
    // MARK: - UI Helpers
    private func createResultCard(title: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.1)
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = title.uppercased()
        titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel.textColor = color.withAlphaComponent(0.8) // Un poco más oscuro
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.tag = 100
        valueLabel.text = "--"
        valueLabel.font = .systemFont(ofSize: 32, weight: .bold)
        valueLabel.textColor = color
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 15),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: 10),
            valueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        
        return container
    }
}
