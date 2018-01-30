//
//  EjercicioEscrituraVC.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 11/3/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import UIKit

/**
 Ejercicio no implementado.
 */
class EjercicioEscrituraVC: UIViewController {
    
    @IBOutlet weak var RevisarButton: UIButton!
    @IBOutlet weak var PreguntaTextView: UITextView!
    @IBOutlet weak var EntradaTextField: UITextField!
    @IBOutlet weak var CalificacionImagenView: UIImageView!
    @IBOutlet weak var AlturaDeImagenConstraint: NSLayoutConstraint!
    
    var ejercicios: [Ejercicio]!
    var ejercicioActual: Ejercicio!
    var color: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ejercicioActual = ejercicios.removeFirst()
        PreguntaTextView.text = ejercicioActual.textos!
       
        RevisarButton.backgroundColor = UIColor.white
        RevisarButton.addTarget(self, action: #selector(accionDelBoton), for: .touchDown)
        RevisarButton.layer.cornerRadius = 10
        RevisarButton.layer.borderWidth = 1.5
        RevisarButton.layer.borderColor = color.cgColor
        RevisarButton.setTitleColor( #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1), for: .disabled)
        RevisarButton.isEnabled = true
        
        // ocultando la imagen de la calificacion
        AlturaDeImagenConstraint.constant = 0
        CalificacionImagenView.alpha = 0
    }

    @objc func accionDelBoton(sender: UIButton){
        // no implementado
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // no implementado
    }
    
    func revisarEjercicio(){
        UIView.animate(withDuration: 0.5, animations: {
            self.AlturaDeImagenConstraint.constant = 64
            self.CalificacionImagenView.alpha = 1
            self.RevisarButton.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        })
        
    }
    
    func siguienteEjercicio() {
      
    }

}
