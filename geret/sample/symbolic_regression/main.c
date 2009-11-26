
#include <stdio.h>
#include <stdlib.h>

int main( int argc, char *argv[] ) 
{
  if( argc != 3 ) {
    fprintf( stderr, "usage:\n  tcc -run %s rows cols < data.bin\n", argv[0] );
    exit(1);
  }

  size_t rows = (size_t)atoi( argv[1] ); 
  size_t cols = (size_t)atoi( argv[2] ); 

  size_t datasize = rows * cols; 
  double *data = malloc( sizeof(double) * datasize );

  if( NULL == data ) {
    fprintf( stderr, "cannot alloc memory for data" );
    exit(2);
  }

  if( NULL == freopen( NULL, "rb", stdin ) ) {
    fprintf( stderr, "cannot freopen stdin to binary mode" );
    exit(3);
  }

  if( datasize != fread( data, sizeof(double), datasize, stdin ) ) {
    fprintf( stderr, "cannot read data from stdin" );
    exit(4);
  }

  size_t r, c;
  for( r=0; r<rows; r++ ) {
    for( c=0; c<cols; c++ ) {   
      printf( "%lf ", data[r*rows+c] );
    }
    printf("\n");
  }

}

