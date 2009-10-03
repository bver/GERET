int main() {

  while( steps < MaxSteps ) {

    /* phenotype will be placed here: */
    PHENOTYPE

    printf( "food items consumed: %d\n", consumed_food );
    printf( "steps elapsed: %d\n", steps );

    show_scene();
    getchar();    
  }
}

