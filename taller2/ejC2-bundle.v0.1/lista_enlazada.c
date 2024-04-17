#include "lista_enlazada.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


lista_t* nueva_lista(void) {
    lista_t *head =  (lista_t*) calloc (sizeof(lista_t),1); // calloc para poder inicializarla, porque malloc me lo da con basura
    return head;

}

uint32_t longitud(lista_t* lista) {
    if (lista==NULL){return 0;
    }
    uint32_t cont=0;
    nodo_t* act=lista->head;
    
    while(act!=NULL){
        nodo_t* temp=act;
        cont++;
        act= temp->next; // porque no puedo hacer diecto act=act.next????
    }
    return cont;
}

void agregar_al_final(lista_t* lista, uint32_t* arreglo, uint64_t longitud) {
    nodo_t* act=lista->head;
    nodo_t* nuevo_nodo =  (nodo_t*) malloc (sizeof(nodo_t)); // hace falta el (nodo_t*) antes del malloc? 
    nuevo_nodo->longitud=longitud;
    nuevo_nodo->next=NULL;

    uint32_t* copy_arr=calloc(sizeof(uint32_t), nuevo_nodo->longitud);
    nuevo_nodo->arreglo=copy_arr;
    for(int i = 0; i < longitud ;i++){
        copy_arr[i] = arreglo[i];
    }

    if(act !=NULL) {
        while (act->next!=NULL){
        nodo_t* temp=act;
        act= temp->next; // porque no puedo hacer diecto act=act.next????
        }
        act->next=nuevo_nodo;
    }else {lista->head=nuevo_nodo;}   
    
}

nodo_t* iesimo(lista_t* lista, uint32_t i) {
    nodo_t* act=lista->head;
    uint32_t temp=0;
    while (temp!=i){
        nodo_t* temp2=act;
        act= temp2->next; // porque no puedo hacer diecto act=act.next????
        temp++;
    }
    return act;
}

uint64_t cantidad_total_de_elementos(lista_t* lista) {
    nodo_t* act=lista->head;
    uint64_t contador=0;
    while (act!=NULL){
        nodo_t* temp=act;
        contador=contador+(temp->longitud);
        act= temp->next; // porque no puedo hacer diecto act=act.next????
    }
    return contador;
}

void imprimir_lista(lista_t* lista) {
}

// Función auxiliar para lista_contiene_elemento
int array_contiene_elemento(uint32_t* array, uint64_t size_of_array, uint32_t elemento_a_buscar) {
    for (uint32_t i=0; i<size_of_array;i++){
        if (array[i]==elemento_a_buscar){
            return 1;
        }
    }
    return 0;
}

int lista_contiene_elemento(lista_t* lista, uint32_t elemento_a_buscar) {
    nodo_t* act=lista->head;
    uint32_t contador=0;
    while (act!=NULL){
        if (array_contiene_elemento(act->arreglo,act->longitud, elemento_a_buscar)==1)
        {
            return 1;
        }
        nodo_t* temp=act;
        act= temp->next; // porque no puedo hacer diecto act=act.next????

    }
    return 0;
}


// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
// Tener en cuenta que ademas, se debe liberar la memoria correspondiente a cada array de cada elemento de la lista.
void destruir_lista(lista_t* lista) {    
    nodo_t* temp=lista->head;
    while (temp->next!=NULL)
    {   nodo_t* nodo_act=temp->next;
        free(temp->arreglo);
        free(temp);

        temp=nodo_act;
    }
    free(temp->arreglo);
    free(temp);
    
    free(lista);
}
