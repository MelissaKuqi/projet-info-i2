#version 330

out vec4 couleur;

in vec3 normaleDansRepereOeil;
in vec3 fragPosition;

uniform vec3 diffuse;
uniform vec3 speculaire;
uniform float brillance;

uniform vec3 vectLumiere;

void main()
{
    vec3 posCamera = vec3(0.0, 0.0, 0.0); // a priori apres l'application de la matrice mvp
    
    if (brillance == -1.0 ) {
        couleur = vec4( diffuse, 1.0f); // coloration Flat pour offScreen
    } else {
        vec3 vLumiere = normalize(vectLumiere);
        vec3 normale = normalize(normaleDansRepereOeil);
        
        // partie composante diffuse
        float prodscal = max(0.0, dot(normale , -vLumiere)); // calcul vect_Normale.vect_Lum
        
        // partie composante speculaire
        vec3 vectVue = normalize(posCamera - fragPosition);
        vec3 vectReflection = reflect(-vLumiere , normale);
        
        float spec = pow(max(0.0, dot(vectVue , vectReflection)), brillance);
        
        couleur = vec4( diffuse * prodscal + spec * speculaire , 1.0f);
    }
}

