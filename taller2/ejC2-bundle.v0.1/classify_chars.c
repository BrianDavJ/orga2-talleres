#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void classify_chars_in_string(char* string, char** vowels_and_cons) {
    int i=0;
    int j=0;
    int k=0;
    char* vowels=calloc(64,1);
    char* cons=calloc(64,1);
    while (string[i]!='\0'){
        if (string[i]=='a'||string[i]=='e'||string[i]=='i'||string[i]=='u'||string[i]=='o'){
            vowels[j]=string[i];
            j++;
        }else{
            cons[k]=string[i];
            k++;
        }
        i++;
    }
    vowels_and_cons[0]=vowels;
    vowels_and_cons[1]=cons;

    // RECORDAR QUE HAY QUE PEDIR MEMORIA PARA LOS CLASSIFY 
}

void classify_chars(classifier_t* array, uint64_t size_of_array) {
    for(int i=0;i<size_of_array;i++){
        array[i].vowels_and_consonants=calloc(2,sizeof(char**));
        classify_chars_in_string(array[i].string,array[i].vowels_and_consonants);
    }
}
