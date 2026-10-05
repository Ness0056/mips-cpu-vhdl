/*
Das Array wird vom Linker Script an die Addresse 0x0800 (=2048) gesetzt.
In der MIF Datei und in der Waveform ist es jedoch die Stelle 512,
da wir ja Wort-Adressierung verwenden.
In der Waveform findet ihr es als top/mipscpu_mc_tb/uut/ramelements_debug/[512].
Das Array hat eine Länge von 10 und geht somit von [512] bis [521].
*/
int my_array[] = {6, 3, 9, 5, 2, 8, 10, 4, 1, 7};

// Wir müssen den Code der Funktionen weiter unten schreiben, da sie sonst an der falschen Stelle erscheinen.
void swap(int array[], int a, int b);
void bubblesort(int array[], int size);

int main()
{
    bubblesort(my_array, sizeof(my_array)/sizeof(*my_array));

    // Durch das setzen von $k0 wird der Testbench signalisiert, dass das Programm beendet ist.
    __asm__ __volatile__("addiu $k0, $zero, 1");
    __builtin_unreachable(); // Hiermit teilen wir dies auch dem Compiler mit.
}

void swap(int array[], int a, int b)
{
    int temp = array[a];
    array[a] = array[b];
    array[b] = temp;
}

void bubblesort(int array[], int size)
{
    for(int step=0; step<size-1; step++)
    {
        for(int i=0; i<size-step-1; i++)
        {
            if(array[i] > array[i+1])
            {
                swap(array, i, i+1);
            }
        }
    }
}
