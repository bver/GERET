/*
 * This is the Ant library written in the C language
 */

#include <stdio.h>

/*
 * Constants
 */

const int TRUE=1;
const int FALSE=0;
typedef int BOOL;

const char Food = '*';
const char Empty = '.';
const int MaxSteps = 615;

enum Dir {
  North = 0,
  West,
  South,
  East
};

const char Left[4] = { West, South, East, North };
const char Right[4] = { East, North, West, South };
const int DirX[4] = { 0, -1, 0, 1 };
const int DirY[4] = { -1, 0, 1, 0 };
const char Avatar[4] = { '^', '<', 'v', '>' };

/*
 * Playing Field
 */

char * grid[] = {
  ".***............................",
  "...*............................",
  "...*.....................***....",
  "...*....................*....*..",
  "...*....................*....*..",
  "...****.*****........**.........",
  "............*................*..",
  "............*.......*...........",
  "............*.......*...........",
  "............*.......*........*..",
  "....................*...........",
  "............*...................",
  "............*................*..",
  "............*.......*...........",
  "............*.......*.....***...",
  ".................*.....*........",
  "................................",
  "............*...................",
  "............*...*.......*.......",
  "............*...*..........*....",
  "............*...*...............",
  "............*...*...............",
  "............*.............*.....",
  "............*..........*........",
  "...**..*****....*...............",
  ".*..............*...............",
  ".*..............*...............",
  ".*......*******.................",
  ".*.....*........................",
  ".......*........................",
  "..****..........................",
  "................................"
};
const int GridHeight = 32;
const int GridWidth = 32;

/* 
 * Ant State
 */

enum Dir dir = East;
int x = 0;
int y = 0;
int consumed_food = 0;
int steps = 0;

/*
 * Ant Methods
 */

void move()
{
  if( steps >= MaxSteps )
    return;
  x = ahead_x();
  y = ahead_y();
  steps++;
  if( grid[y][x] == Food ) {
    consumed_food++;
    grid[y][x] = Empty;
  }
}

void right()
{
  if( steps >= MaxSteps )
    return;
  dir = Right[ dir ];
  steps++;
}

void left()
{
  if( steps >= MaxSteps )
    return;
  dir = Left[ dir ];
  steps++;
}

BOOL food_ahead()
{
  return Food == grid[ ahead_y() ][ ahead_x() ] ? TRUE : FALSE;
}

void show_scene()
{
  int sx, sy;
  for( sy=0; sy<GridHeight; sy++ ) {
    for( sx=0; sx<GridWidth; sx++ ) {
      printf( "%c", ( x == sx && y == sy ) ? Avatar[dir] : grid[sy][sx] );
    }
    printf("\n");
  }
}

int ahead_x()
{
  return ( x + DirX[dir] ) % GridWidth;
}

int ahead_y()
{
  return ( y + DirY[dir] ) % GridHeight; 
}


