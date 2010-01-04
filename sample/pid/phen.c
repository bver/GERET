
{

  size_t r;
  double e = 0.0;
  double y, v1, v2, v3, v4, v5;
  y = v1 = v2 = v3 = v4 = v5 = 0.0;

  for( r=0; r<rows; r++ ) {
    const double *x = &(data[r*cols]);
    
    PHENOTYPE
    
    if( ! isfinite(y) || y>1e100 || y<-1e100 ) {
      printf( "%lg\n", 1e100 ); //1.79769e+308 );
      break;
    }

    e += (x[0]-y) * (x[0]-y);
  }

  if( r == rows )
    printf( "%lg\n", sqrt(e) );
}

fflush(stdout);

