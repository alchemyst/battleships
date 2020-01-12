function randbattle
% This function is a strategy to play battleships. The strategy is purely 
% relies on randomly shooting in a 10 X 10 grid until all ships have been sunked. 
% The strategy uses none of the information or feedback from any shots
% fired. The only logic is that it remembers where it has previously fired
% shots.

% Defines the square grid size in this assignment 10 X 10 grid.
N = 10;

% Initialize variable result to ensure that the while loop is entered 
result = 999;
% Creates matrix Remember_shot that will store the positions where shots
% have been fired. All are zeros (false) since no shots have been fired.
Remember_shot = zeros(N,N);

% Continue until all ships have been sunked i.e. continue while result 
% that is updated in the loop using function battle is not equal to 2.
while result ~= 2  
% Generate a random row position between 1 and 10
  random_row = min(max(round(9*randn(1,1)) + 1, 1), 10);
% Generate a random column position between 1 and 10    
  random_column = min(max(round(9*randn(1,1)) + 1, 1), 10);

% Checks if a shot has been fired at the randomly generated coordinate.
  if Remember_shot(random_row,random_column) == 0
% Fire a shot at the coordinate given by random_row and random_column
    [result, value] = battle(random_row, random_column);    
% Store the value 1 (true) in this coordinate of Remember_shot to inidicate
% a shot has been fired in this coordinate.
    Remember_shot(random_row,random_column) = 1;
  end  
end