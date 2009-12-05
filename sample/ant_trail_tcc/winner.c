move();
left();
if( food_ahead() ) {
  right();
} else {
  left();
}
if( food_ahead() ) {
  left();
} else {
  left();
}
if( food_ahead() ) {
  move();
} else {
  left();
}

