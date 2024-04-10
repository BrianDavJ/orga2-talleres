#include "vector.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


vector_t* nuevo_vector(void) {
    //pedimos memmoria para el vector
    vector_t* vector_nuevo = (vector_t*) malloc(sizeof(vector_t));

    // rellenamos sus campos
    vector_nuevo->size  = 0;
    vector_nuevo->capacity = 2;
    //pedimos memoria para el array
    uint32_t* arr = (uint32_t*) malloc(sizeof(uint32_t)*vector_nuevo->capacity);
    vector_nuevo->array = arr;

    return vector_nuevo;
} 

uint64_t get_size(vector_t* vector) {
    return vector->size;
}

void push_back(vector_t* vector, uint32_t elemento) {

    if(vector->size < vector->capacity){
        uint64_t ult_pos = vector->size;
        vector->array[ult_pos] = elemento;
        vector->size +=1;
    } else {
        uint64_t nueva_cap = vector->capacity+2;
        uint32_t* nuevo_arr = (uint32_t*) realloc(vector->array, sizeof(uint32_t)*nueva_cap); 
        uint64_t ult_pos = vector->size;
        vector->array=nuevo_arr;
        vector->array[ult_pos]=elemento;
        vector->size +=1;
        vector->capacity = nueva_cap;

    }
}

int son_iguales(vector_t* v1, vector_t* v2) {

     if(v1->size != v2->size){
        return 0;
    } else {
        uint32_t* arr1 = v1->array;
        uint32_t* arr2 = v2->array;
        for(int i = 0; i < v1->size; i++){
            if(arr1[i] != arr2[i]){
                return 0;
            }
        }
        return 1;
    }
}

uint32_t iesimo(vector_t* vector, size_t index) {
       if(index > vector->size){
        return 0;
    } else {
        uint32_t* arr1 = vector->array;
        return arr1[index];
    }
}

void copiar_iesimo(vector_t* vector, size_t index, uint32_t* out)
{
    uint32_t value = iesimo(vector,index);
    *out=value;

}



// Dado un array de vectores, devuelve un puntero a aquel con mayor longitud.
vector_t* vector_mas_grande(vector_t** array_de_vectores, size_t longitud_del_array) {
    uint32_t max = array_de_vectores[0]->size;
    vector_t* res = *array_de_vectores;
    for(uint32_t i = 1; i < longitud_del_array; i++){
        if(array_de_vectores[i]->size > max){
            max = array_de_vectores[i]->size;
            res = array_de_vectores[i];
        }
    }

    return res; 
}
