#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void classify_chars_in_string(char* string, char** vowels_and_cons) {
    int i=0;
    int j=0;
    int k=0;
    while (string[i]!='\0'){
        if (string[i]=='a'||string[i]=='e'||string[i]=='i'||string[i]=='u'||string[i]=='o'){
            vowels_and_cons[0][j]=string[i];
            j++;
        }else{
            vowels_and_cons[1][k]=string[i];
            k++;
        }
        i++;
    }

    // RECORDAR QUE HAY QUE PEDIR MEMORIA PARA LOS CLASSIFY 
}

void classify_chars(classifier_t* array, uint64_t size_of_array) {
    for(int i=0;i<size_of_array;i++){
        classify_chars_in_string(array[i].string,array[i].vowels_and_consonants);
    }
}
