#include "contar_espacios.h"
#include <stdio.h>

uint32_t longitud_de_string(char* string) {
    int i=0;
    int32_t counter=0;
    if (string==NULL){
        return 0;
    }

    while (string[i] != '\0'){
        i++;
        counter++;
    }
    return counter;    
}

uint32_t contar_espacios(char* string) {
    int i=0;
    int32_t counter=0;
    if (longitud_de_string(string)==0) // no hace falta, si un string es de long 0 es equivalente a que sea igual a \0 [corrección]
    {
        return 0;
    }
    while (string[i] != '\0'){
        if (string[i]== ' ')
        {
           counter++;
        }
        i++;
    }
    return counter;
}

// Pueden probar acá su código (recuerden comentarlo antes de ejecutar los tests!)
/*
int main() {

    printf("1. %d\n", contar_espacios("hola como andas?"));

    printf("2. %d\n", contar_espacios("holaaaa orga2"));
    printf("nuestro. %d\n", contar_espacios(""));
    
} 
*/
