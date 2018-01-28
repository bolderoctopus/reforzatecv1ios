//
//  EjercicioVozVC.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 11/3/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import UIKit
import Speech

// TODO: Posible bug, si la respuesta correcta es 900, aceptar tambien novecientos

class EjercicioVozVC: UIViewController, SFSpeechRecognizerDelegate {    
    
    @IBOutlet weak var BotonMicrofonoMute: UIBarButtonItem!
    @IBOutlet weak var PretuntaTextView: UITextView!
    @IBOutlet weak var BotonRevisar: UIButton!
    @IBOutlet weak var BotonMicrofono: UIButton!
    @IBOutlet weak var EntradaField: UITextField!
    @IBOutlet weak var CalificacionImagenView: UIImageView!
    @IBOutlet weak var AlturaDeImagenConstraint: NSLayoutConstraint!
    @IBOutlet weak var IndicadorDeActividad: UIActivityIndicatorView!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "es-MX"))
    private var solicitudDeReconocimiento: SFSpeechAudioBufferRecognitionRequest?
    private var tareaDeReconocimiento: SFSpeechRecognitionTask?
    private let motorDeAudio = AVAudioEngine()
    
    private var RespuestaCorrecta:String!
    
    var color: UIColor! = UIColor.cyan
    var Ejercicios: [Ejercicio]!
    var EjercicioActual: Ejercicio!
    var yaFueRevisado = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        EjercicioActual = Ejercicios.removeFirst()
        RespuestaCorrecta = EjercicioActual.respuestas!
        PretuntaTextView.text = EjercicioActual.textos!
        

        BotonMicrofonoMute.tintColor = color
        IndicadorDeActividad.tintColor = color
        IndicadorDeActividad.alpha = 0
        
        EntradaField.text = ""
        // para evitar que se muesre un teclado en el cmapo de texto
        EntradaField.inputView = UIView()

        // iniciando boton
        BotonRevisar.backgroundColor = UIColor.white
        BotonRevisar.addTarget(self, action: #selector(accionDelBotonRevisar), for: .touchDown)
        BotonRevisar.layer.cornerRadius = 10
        BotonRevisar.layer.borderWidth = 1.5
        BotonRevisar.layer.borderColor = color.cgColor
        BotonRevisar.setTitleColor( #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1), for: .disabled)
        BotonRevisar.isEnabled = false
        
        
        // Ocultando la imagen
        AlturaDeImagenConstraint.constant = 0
        CalificacionImagenView.alpha = 0
        

        BotonMicrofono.isEnabled = false
        
        speechRecognizer?.delegate = self
        SFSpeechRecognizer.requestAuthorization({(estadoAutorizacion) in
            var habilitarBoton = false
            switch estadoAutorizacion{
            case .authorized:
//                print("autorizaos!")
                habilitarBoton = true
            case .denied:
                print("denegados")
                habilitarBoton = false
            case .notDetermined:
                print("no determinado")
                habilitarBoton = false
            case .restricted:
                print("restringidos")
                habilitarBoton = false
            }
            OperationQueue.main.addOperation {
                self.BotonMicrofono.isEnabled = habilitarBoton
            }
        })
        let ejercicioString = NSLocalizedString("Exercise", comment: "")
        let numero = " \(5 - Ejercicios.count)/5"
        self.title = ejercicioString + numero
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        revisarConexion()
    }
    @objc func accionDelBotonRevisar(sender: UIButton) {
        if yaFueRevisado{
            siguienteEjercicio()
        } else {
            mostrarCalificacion()
        }
    }
  
    @IBAction func accionDelBotonGrabar(_ sender: Any) {
        // habilitar el boton revisar
        BotonRevisar.isEnabled = true
        
        if motorDeAudio.isRunning{
            motorDeAudio.stop()
            solicitudDeReconocimiento?.endAudio()
            print("terminando solicitud de reconocimiento")
            // bloquear boton en lo que la solicitud de reconocmiento entrga su resultado final
            BotonMicrofono.isEnabled = false // ??
        } else{
            iniciarGrabacion()
            
        }
    }
    
    @IBAction func MuteMicrofono(_ sender: Any) {
        if(motorDeAudio.isRunning){
            detenerGrabacion()
        }
        BotonMicrofono.isEnabled = false
        BotonRevisar.isEnabled = true
        self.BotonRevisar.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        yaFueRevisado = true
    }
    
    
    
    func respondioBien() -> Bool{
        if let respuestaDelUsuario = EntradaField.text{
            if(respuestaDelUsuario == RespuestaCorrecta){
                return true
            }
        }
        return false
    }
    
    func mostrarCalificacion() {
        if(respondioBien()){
             CalificacionImagenView.image = #imageLiteral(resourceName: "correcto")
        }else{
             CalificacionImagenView.image = #imageLiteral(resourceName: "equivocado")
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.AlturaDeImagenConstraint.constant = 64
            self.CalificacionImagenView.alpha = 1
            self.BotonRevisar.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
            self.yaFueRevisado = true
        })
    }
    
    func siguienteEjercicio() {
        if let siguienteE = Ejercicios.first{
            let storyBoard: UIStoryboard = (self.navigationController?.storyboard)!
            var siguienteViewController: UIViewController?
            switch siguienteE.tipo! {
            case "Voz":
                let eVoz = storyBoard.instantiateViewController(withIdentifier: "EjercicioVozVC") as! EjercicioVozVC
                eVoz.color = self.color
                eVoz.Ejercicios = Ejercicios
                siguienteViewController = eVoz
            case "Opcion multiple":
                let eOpMul = storyBoard.instantiateViewController(withIdentifier: "EjercicioOpMulVC") as! EjercicioOpMulVC
                eOpMul.color = self.color
                eOpMul.Ejercicios = Ejercicios
                siguienteViewController = eOpMul
            case "Ordenar oracion":
                let eOrOr = storyBoard.instantiateViewController(withIdentifier: "EjercicioOrdenarVC") as! EjercicioOrdenarVC
                eOrOr.color = self.color
                eOrOr.Ejercicios = Ejercicios
                siguienteViewController = eOrOr
            case "Escritura":
                let eEs = storyBoard.instantiateViewController(withIdentifier: "EjercicioEscrituraVC") as! EjercicioEscrituraVC
                eEs.color = self.color
                eEs.Ejercicios = Ejercicios
                siguienteViewController = eEs
            default:
                print("Tipo de ejercicio desconocido: \(siguienteE.tipo!)")
            }
            if let sViewC = siguienteViewController{
                var stack = self.navigationController!.viewControllers
                stack.popLast()
                stack.append(sViewC)
                self.navigationController?.setViewControllers(stack, animated: true)
            }
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK:- Voz
    
    func iniciarGrabacion(){
        if tareaDeReconocimiento != nil {
            tareaDeReconocimiento?.cancel()
            tareaDeReconocimiento = nil
        }
        let sesionDeAudio = AVAudioSession.sharedInstance()
        do {
            try sesionDeAudio.setCategory(AVAudioSessionCategoryRecord)
            try sesionDeAudio.setMode(AVAudioSessionModeMeasurement)
            try sesionDeAudio.setActive(true, with: .notifyOthersOnDeactivation)
        } catch{
            print("Error al ponerle las propiedades a la sesion de audio")
        }
        solicitudDeReconocimiento = SFSpeechAudioBufferRecognitionRequest()
        let nodoEntrada = motorDeAudio.inputNode

        
        solicitudDeReconocimiento!.shouldReportPartialResults = true
        tareaDeReconocimiento = speechRecognizer?.recognitionTask(with: solicitudDeReconocimiento!, resultHandler: { (resultado, error) in
            var yaTermino = false
            if resultado != nil{
                self.EntradaField.text = resultado?.bestTranscription.formattedString
                yaTermino = (resultado?.isFinal)!
            }
            
            if error != nil || yaTermino || self.respondioBien(){
                self.detenerGrabacion()
                nodoEntrada.removeTap(onBus: 0)
                self.mostrarCalificacion()
                
            }
            
        })
        let formatoGrabacion = nodoEntrada.outputFormat(forBus: 0)
        nodoEntrada.installTap(onBus: 0, bufferSize: 1024, format: formatoGrabacion, block: {(buffer, when) in
            self.solicitudDeReconocimiento?.append(buffer)
        })
        
        motorDeAudio.prepare()
        do {
            try 	motorDeAudio.start()
            self.IndicadorDeActividad.startAnimating()
            UIView.animate(withDuration: 0.3, animations: {
                self.IndicadorDeActividad.alpha = 1
            })
            print("grabacion iniciada")
        }catch{
            print("no se pudo arrancar el motor de audio debido a un error")
        }
        //EntradaField.text = "...";
    }
    
    func detenerGrabacion() {
        motorDeAudio.stop()
        solicitudDeReconocimiento = nil
        tareaDeReconocimiento  = nil
        print("grabacion detenida")
        BotonMicrofono.isEnabled = true
        IndicadorDeActividad.alpha = 0
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available{
            BotonMicrofono.isEnabled = true
        }
        else {
            BotonMicrofono.isEnabled = false
        }
    }
    
    func revisarConexion() {
        if (currentReachabilityStatus == .notReachable) {
            print("No hay conexion a internet")
            let titulo = NSLocalizedString("No Internet connection detected", comment: "")
            let mensaje = NSLocalizedString("Voice exercises requiere an Internet connection.", comment: "")
            
            let alerta = UIAlertController.init(title: titulo, message: mensaje, preferredStyle: .alert)
            alerta.addAction(UIAlertAction.init(title: NSLocalizedString("Dismiss", comment:""), style: .default, handler: nil))
            MuteMicrofono(self)
            self.present(alerta, animated: true)
        }else{
            print("si hay conexion a internet")
        }
    }
}
