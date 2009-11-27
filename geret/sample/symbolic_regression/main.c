
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main( int argc, char *argv[] ) 
{
  if( argc != 4 ) {
    fprintf( stderr, "usage:\n  tcc -lm -run %s data.bin rows cols < data.bin\n", argv[0] );
    exit(1);
  }

  size_t rows = (size_t)atoi( argv[2] ); 
  size_t cols = (size_t)atoi( argv[3] ); 

  size_t datasize = rows * cols; 
  double *data = malloc( sizeof(double) * datasize );

  if( NULL == data ) {
    fprintf( stderr, "cannot alloc memory for data\n" );
    exit(2);
  }

  FILE * f;
  if( NULL == (f = fopen( argv[1], "rb" ) ) ) {
    fprintf( stderr, "cannot freopen %s to binary mode\n", argv[1] );
    exit(3);
  }

  if( datasize != fread( data, sizeof(double), datasize, f ) ) {
    fprintf( stderr, "cannot read data from file\n" );
    exit(4);
  }

  fclose(f);

/*  
  size_t r, c;
  for( r=0; r<rows; r++ ) {
    for( c=0; c<cols; c++ ) {   
      printf( "%lf ", data[r*cols+c] );
    }
    printf("\n");
  }
*/

PHENOTYPES

  free(data);
}

