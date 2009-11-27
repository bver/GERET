
{

  size_t r;
  double e = 0.0;
  for( r=0; r<rows; r++ ) {
    const double *x = &(data[r*cols]);
    
    double y = PHENOTYPE;
    
    if( isnan(y) || isinf(y) ) {
      printf( "%lg\n", 1.79769e+308 );
      break;
    }

    e += (x[0]-y) * (x[0]-y);
  }

  if( r == rows )
    printf( "%lg\n", sqrt(e) );
}

