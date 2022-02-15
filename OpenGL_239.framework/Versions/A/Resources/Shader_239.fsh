#version 330

out vec4 couleur;

in vec3 lacouleur; //vient du vertex shader */
in vec3 normaleDansRepereOeil;
//uniform mat3 normaleMatrice;
in vec3 fragPosition;

in vec2 TexCoord; // pour la texture // 28-09-2017

uniform vec3 diffuse;
uniform vec3 speculaire;
uniform float brillance;

uniform int mode_couleur;

uniform vec3 vectLumiere;

uniform sampler2D ourTexture; // pour la texture 2D // 28-09-2017

/*struct MateriauStruct {
    vec3 diffuse1;
    vec3 speculaire1;
    float brillance1;
}
uniform MateriauStruct Mater;*/


// 21-09-2017 ajout d'une variable pour le choix entre tableau de couleurs par sommets ou par variable uniforme
void main()
{
    /*vec3 normaleDansRepereOeil = normalize(normaleMatrice * lanormale); // passe la normale du vertex dans le repere de l'oeil */
    vec3 posCamera = vec3(0.0, 0.0, 0.0); // a priori apres l'application de la matrice mvp
    
    if (brillance == -1.0 ) { // pour offScreen
        if (mode_couleur == -1 ) { // par sommet
            couleur = vec4(lacouleur, 1.0f);
        } else {
            couleur = vec4(diffuse, 1.0f); // pour offScreen
        }
    } else {
        //if (mode_couleur == -1 ) { //
        //    couleur = vec4(lacouleur, 1.0f); // coloration par sommets
        //} else {
            vec3 vLumiere = normalize(vectLumiere);
            vec3 normale = normalize(normaleDansRepereOeil);
        
            // partie composante diffuse
            float prodscal = max(0.0, dot(normale , -vLumiere)); // calcul vect_Normale.vect_Lum
        
            // partie composante speculaire
            vec3 vectVue = normalize(posCamera - fragPosition);
            vec3 vectReflection = reflect(-vLumiere , normale);
        
            float spec = pow(max(0.0, dot(vectVue , vectReflection)), brillance);
        
            if (mode_couleur == -1 ) { // par sommet en tenant compte des carac. spéculaire
                couleur = vec4( lacouleur * prodscal + spec * speculaire , 1.0f);
            } else {
                couleur = vec4( diffuse * prodscal + spec * speculaire , 1.0f);
            }
        //}
    }
    
    if (brillance == -33.0) { couleur = texture(ourTexture, TexCoord); } // pour le sampling de la texture // 28-09-2017
    
    
    //couleur = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}

