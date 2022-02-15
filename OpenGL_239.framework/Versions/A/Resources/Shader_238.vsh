#version 330

in vec3 vPosition;
in vec3 normale; // normale du vertex

uniform mat4 mvpMatrice;
uniform mat3 normaleMatrice;

out vec3 normaleDansRepereOeil;
out vec3 fragPosition;

void main()
{
    normaleDansRepereOeil = normaleMatrice * normale; 
    
    gl_Position = mvpMatrice * vec4(vPosition, 1.0);
    
    fragPosition = vec3(gl_Position);
}
