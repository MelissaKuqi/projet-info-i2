
//
//  EFOpenGLView.swift
//  TestSwiftOsXApp
//
//  Created on 27/02/2015.

import Cocoa
import GLKit

// 25-01-2017
import OpenGL_239 // <<< accès au framework des primitives OpenGL

// Classe qui permet de réaliser le tracé dans la vue OpenGL
class EFOpenGLView: NSOpenGLView
{
    // décl. de la matrice Modèle-Vue-Projection pour la visualisation des objets en 3D
    var _mvpMatrice: GLKMatrix4 = GLKMatrix4Identity
    // idem matrice des normales
    var _normaleMatrice: GLKMatrix3 = GLKMatrix3Identity
    // matrice de projection et de visualisation
    var projMat, viewMat: GLKMatrix4!
    
    var locUniformMat: GLint = 0
    var locUniformNormaleMat: GLint = 0
    
    var locUniformDiffuseCoul: GLint = 0
    var locUniformSpeculaireCoul: GLint = 0
    var locUniformBrillance: GLint = 0
    
    var locUniformVectLumiere: GLint = 0
    
    var rotation: Float = 0.0

    fileprivate var uneSphere: Sphere!
    fileprivate var unCylindre: Cylindre!
    fileprivate var uneLigne: Ligne!
    fileprivate var unRectangle : Rectangle!
    fileprivate var uneImage : Image!
    fileprivate var unTriangle : Triangle!
    
    fileprivate var monProgShad : ShaderProgObj!
    
    fileprivate var leOwner : Document!
    
    // 25-03-2017 : pour accepter les keyDown
    override var acceptsFirstResponder: Bool { return true }
    
    // appelée lors du chargement de l'openGLView
    override func awakeFromNib()
    {
        NSLog("%@ %@", #function, self.className)

        // Attributs pour le contexte de travail OpenGL
        // - double buffer pour l'animation 3D
        // - 24 bits de profondeur pour les couleurs
        // - 8 bits pour le canal de transparence (alpha)
        // - sélection de la version OpenGL 3.2
        // - carac. du buffer de profondeur (gestion du masquage mutuel des objets selon la profondeur)
        let attribs = [
            NSOpenGLPixelFormatAttribute(NSOpenGLPFADoubleBuffer),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAColorSize), 24,
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAAlphaSize), 8,
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAOpenGLProfile),
            NSOpenGLPixelFormatAttribute(NSOpenGLProfileVersion3_2Core),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFADepthSize), 32,
            0
        ]
        
        // Création & activation du contexte (de travail) OpenGL
        let mon_format = NSOpenGLPixelFormat(attributes: attribs)
        self.openGLContext = NSOpenGLContext(format: mon_format!, share: nil)
        self.openGLContext?.makeCurrentContext()
        
        // création de l'objet shader
        monProgShad = ShaderProgObj()
        // activation du programme de gestion de tracé des objets : shader
        monProgShad.utilise()

        locUniformMat = monProgShad.monGetUniformLocation("mvpMatrice")
        locUniformNormaleMat = monProgShad.monGetUniformLocation("normaleMatrice")

        locUniformDiffuseCoul = monProgShad.monGetUniformLocation("diffuse")
        locUniformSpeculaireCoul = monProgShad.monGetUniformLocation("speculaire")
        locUniformBrillance = monProgShad.monGetUniformLocation("brillance")
        
        locUniformVectLumiere = monProgShad.monGetUniformLocation("vectLumiere")

        // défintion de la propriété leOwner pour la communication avec l'objet de la classe Document
        leOwner = self.window?.delegate as! Document
        
        // MARK: --- sphère et cylindre de base utilisés pour les tracés
        uneSphere = Sphere(prog: monProgShad, rayon: 1.0, nbLatitudes: 10, nbLongitudes: 10)
        // attributs de couleur avec les set méthodes
        uneSphere.setCoulDiffuseR(1.0, G: 1.0, B: 1.0)
        uneSphere.setCoulSpeculaireR(1.0, G: 1.0, B: 1.0)
        uneSphere.setBrillance(10.0)
        
        unCylindre = Cylindre(prog: monProgShad, rayon: 1.3, hauteur: 2.0 , nbLongitudes: 10)
        unCylindre.setCoulDiffuseR(1.0, G: 1.0, B: 1.0)
        unCylindre.setCoulSpeculaireR(1.0, G: 1.0, B: 1.0)
        unCylindre.setBrillance(10.0)
        
        // direction du vecteur lumière (vers -z)
        glUniform3f(locUniformVectLumiere, 0.0, 0.0, -1.0)
    }
    
    override func prepareOpenGL() {
    
        NSLog("%@", #function)
        
        glClearColor(0.99, 0.99, 0.99, 0.0) // couleur de fond de l'openGLView
        
        glClearDepth(1.0)
        glEnable(GLenum(GL_BLEND))
        // activation du test de profondeur (gestion masquage des objets semlon profondeur)
        glEnable(GLenum(GL_DEPTH_TEST))
        glDepthFunc(GLenum(GL_LEQUAL))
        
        // à activer si les surfaces sont fermées (Culling)
        /* glEnable(GLenum(GL_CULL_FACE))
        glFrontFace(GLenum(GL_CW))
        glCullFace(GLenum(GL_BACK))
        */
        
        //glPolygonMode(GLenum(GL_FRONT_AND_BACK), GLenum(GL_LINE)) // pour tracé en mode fil de fer

        // création de la matrice de visualisation pour le passage dans le repère de la caméra/oeil
        // 1er triplet : position de l'oeil/de la caméra
        // 2eme triplet : point observé (typiquement l'origine
        // 3eme triplet : vers d'orientation pour définir le haut (+y typiquement)
        viewMat = GLKMatrix4MakeLookAt(0.0,0.0,15.0,  0.0,0.0,0.0,  0.0,1.0,0.0)
        
    }
    
    override func update() {
    #if Affiche_infos
        NSLog("%@", #function)
    #endif
        
        super.update()
    }
  
    override func reshape() {
    #if Affiche_infos
        NSLog("%@", #function)
    #endif
        
        let bornes = self.frame
        
        // définition des dimensions de la fenêtre OpenGL
        glViewport(0, 0, GLsizei(bornes.size.width), GLsizei(bornes.size.height))
        
        // création de la matrice de projection pour définir la façon de projeter (perspective, droite) sur l'écran
        // 1ere valeur angle de vue : 60°
        // 2eme valeur format d'affichage de la fenêtre de visualisation 
        // deux dernières valeurs : distance des plans de "clipping" proche et lointain.
        // En deça et au-delà des distances associées à ces plans, les objets ne sont pas dessinés
        projMat = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0), GLfloat(bornes.size.width)/GLfloat(bornes.size.height), 0.1, 200.0)
    }
    
    override func draw(_ dirtyRect: NSRect) {

        NSLog("%@", #function)
        
        self.openGLContext?.makeCurrentContext()
        
        // effacement de la fenêtre de tracé openGL avec la couleur courante
        // + nettoyage du buffer de test de profondeur
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        
        // Choix des attributs de couleur de la sphère
        uneSphere.setCoulDiffuseR(1.0, G: 0.5, B: 0.0)
        uneSphere.setCoulSpeculaireR(0.5, G: 0.5, B: 0.5)

        // récupération d'une valeur de rayon par interrogation du propriétaire de l'openGLView (ici il s'agit de la classe Document), pour illustrer l'échange de données entre le document qui contient les informations et la vue qui les représentent.

        let rayon : Float = leOwner.getUneDonnée(Numéro: 1)!
        let (x,y,z) = (3.0,0.0, 0.0) // valeurs arbitraires à titre d'exemple
        
        // initialisation des matrice de scaling, translation et rotation
        let scalingMat = GLKMatrix4MakeScale(rayon, rayon, rayon)
        let transMat = GLKMatrix4MakeTranslation( Float(x), Float(y), Float(z))
        var rotationMat = GLKMatrix4MakeYRotation(rotation)
        
        // création de la matrice totale de modélisation.
        // ordre choisi : scaling -> translation -> rotation
        var modelMat = GLKMatrix4Multiply(transMat, scalingMat)
        modelMat = GLKMatrix4Multiply(rotationMat, modelMat)
    
        // appel de la méthode qui finalise la matrice "modélisation-visualisation-projection" et se charge de la transmettre à la carte graphique
        self.prépareMVP_transmetAuGPU(matriceModélisation: modelMat)
        
        uneSphere.setBrillance(10.0)
        uneSphere.setModeCouleur(0)
        uneSphere.dessine() // demande à l'objet sphère de se dessiner
        
        unCylindre.setBrillance(10.0)
        unCylindre.setModeCouleur(0)
        unCylindre.dessine() // idem pour un cylindre qui subira les mêmes transformations que la sphère, car pas de transmission au GPU d'une nouvelle modelMat

        // --- création d'un nouvelle matrice de transformation qui s'appliquera à tous les objets qui suivent (ligne, image bicolore, triangle ...)
        // --- la modelMat se réduit à une rotation ---
        rotationMat = GLKMatrix4MakeZRotation(rotation)
        
        self.prépareMVP_transmetAuGPU(matriceModélisation: rotationMat)
        
        // Pour dessiner une autre sphère il n'est pas nécessaire de recréer un objet sphère
        // Modification des attributs de couleur de la sphère à dessiner
        uneSphere.setCoulDiffuseR(0.0, G: 0.5, B: 0.5)
        uneSphere.setCoulSpeculaireR(0.5, G: 0.5, B: 0.5)

        uneSphere.setBrillance(10.0)
        uneSphere.setModeCouleur(0)
        uneSphere.dessine() // demande à l'objet sphère de se dessiner

        // création de l'objet ligne et de ses propriétés de couleur
        uneLigne = Ligne(prog: monProgShad, x1: -4.0, y1: -1.0, z1: 3.0, x2: 4.0, y2: +1.0, z2: 3.0)
        uneLigne.setCoulDiffuseR(0.0, G: 0.0, B: 1.0)
        uneLigne.setCoulSpeculaireR(0.0, G: 0.0, B: 0.0)
        uneLigne.setBrillance(10.0)
        
        uneLigne.dessine()

        let hauteur = GLsizei(8)
        let largeur = GLsizei(16)

        // création d'une image fictive
        let imgR = Array(repeating: Array(repeating: 128 , count: Int(largeur)), count: Int(hauteur))
        
        var imgG = Array(repeating: Array(repeating: 128 , count: Int(largeur)), count: Int(hauteur)/2 )
        imgG += Array(repeating: Array(repeating: 0 , count: Int(largeur) ), count: Int(hauteur)/2 )
        
        let imgB = Array(repeating: Array(repeating: 128 , count: Int(largeur)), count: Int(hauteur) )
        
        if largeur > 0 {
            uneImage = Image(prog: monProgShad, imgTabR: imgR, imgTabG: imgG, imgTabB: imgB, width: largeur, height: hauteur)

            uneImage.setBrillance(-33.0) //  n'utilise pas les uniform diffuse et speculaire
            uneImage.setCoulDiffuseR(0.0, G: 0.5, B: 1.0) // nécessaire mais ignorée
            uneImage.setCoulSpeculaireR(1.0, G: 0.0, B: 0.0) // nécessaire mais ignorée
            uneImage.setModeCouleur(0) // nécessaire mais ignoré
            uneImage.dessine()
        }
        
        let tabXYZTriangle = [Float(-2.0), 1.0, 0.0, 0.0, 3.0, 0.0, 2.0, 1.0, 0.0]
        let normalesTab = [Float(0.0), 0.0, 1.0,
                           0.0, 0.0, 1.0,
                           0.0, 0.0, 1.0]

        unTriangle = Triangle(prog: monProgShad, coordsPts: tabXYZTriangle, coordsNormale: normalesTab, coulPts: [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0])
        
        unTriangle.setModeCouleur(-1) // mode : utilisation du tableau de couleurs fourni lors de la création du triangle
        unTriangle.setBrillance(-1.0) // , n'utilise pas les uniform diffuse et speculaire
        unTriangle.setCoulDiffuseR(0.0, G: 0.5, B: 1.0) // nécessaire mais ignorée
        unTriangle.setCoulSpeculaireR(1.0, G: 0.0, B: 0.0) // nécessaire mais ignorée
        unTriangle.dessine()

        self.openGLContext?.flushBuffer() // Toujours nécessaire. Demande la réalisation des ordres de tracés à OpenGL. En double buffer (animations), copie le back-buffer vers le front buffer pour éviter le scintillement
    }

    // gestion des touches du clavier
    override func keyDown(with unEvent: NSEvent) {
        // MARK: func keyDown -- à remplir selon besoin
        NSLog("%@ ", #function)
        
        switch unEvent.characters! { // gestion des touches du clavier
        case "a","A":
            rotation += Float(Double.pi)*0.05 // incrémentation de la variable de rotation
        case "e","E":
            rotation -= Float(Double.pi)*0.05 // décrémentation
        default:
            return // rien à faire... retour anticipé
        }

        NSLog("%10.3f rads", rotation)
        
        self.draw(self.frame) // demande à l'OpenGLView (self) de se redessiner
    }
    
    //20200322 : bloc de transmission d'infos au GPU. Dbraeképorté pour alléger la func draw
    func prépareMVP_transmetAuGPU(matriceModélisation : GLKMatrix4) {
        
        // crée la matrice de modélisation-visualisation
        // utilise la viewMat, variable globale
        let modelViewMat = GLKMatrix4Multiply(viewMat, matriceModélisation)
        
        // regénération de matrices pour le tracé de la ligne
        _normaleMatrice = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMat), nil)
        _mvpMatrice = GLKMatrix4Multiply(projMat, modelViewMat)
        
        withUnsafePointer(to: &_mvpMatrice.m, { // transmet la matrice modèle-view-projection au shader
            glUniformMatrix4fv(locUniformMat, 1, 0, UnsafeRawPointer($0).assumingMemoryBound(to: GLfloat.self));
        })
        
        withUnsafePointer(to: &_normaleMatrice.m, { // transmet la normaleMatrice au shader
            glUniformMatrix3fv(locUniformNormaleMat, 1, 0, UnsafeRawPointer($0).assumingMemoryBound(to: GLfloat.self));
        })
    }

    override func mouseDown(with unEvent: NSEvent) {
        // MARK: func mouseDown -- à remplir selon besoin
        NSLog("%@ ", #function)
        if unEvent.modifierFlags.contains(.command) {  // Mouse Click + Cmd Key
            Swift.print(" -- Appui sur Cmd key lors d'un mouse Down")
        }
    }
        
}
