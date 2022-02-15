#version 330

// le location est choisi automatiquement par le shader
/*layout (location = 0)*/ in vec3 vPosition;
/*layout (location = 1)*/ in vec3 normale; // normale du vertex
/*layout (location = 2)*/ in vec3 macouleur; // récupère la couleur du tableau des vertices

layout (location = 4) in vec2 aTexCoord; // pour la texture // 28-09-2017

uniform mat4 mvpMatrice;
uniform mat3 normaleMatrice;

out vec3 lacouleur; // la transmet au frag shader

out vec3 normaleDansRepereOeil;
out vec3 fragPosition;

out vec2 TexCoord; // pour la texture // 28-09-2017

void main()
{
    normaleDansRepereOeil = normaleMatrice * normale; // passe la normale du vertex dans le repere de l'oeil, puis au fshader
    
    gl_Position = mvpMatrice * vec4(vPosition, 1.0);
    
    fragPosition = vec3(gl_Position);
    
    lacouleur = macouleur;
    
    TexCoord = aTexCoord; // pour la texture // 28-09-2017
}
