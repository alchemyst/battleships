% BATTLE host battleships game
%   BATTLE('init') initialises a game, setting up not to show the 
%   results
%
%   BATTLE('init', SHOWBOARD) does the same, but uses SHOWBOARD to
%   determine wheter or not to show the board (if SHOWBOARD is nonzero, the
%   board is shown and a short delay is added between shots)
%
%   BATTLE('init', SHOWBOARD, RANDSEED) does the same as the above, but
%   uses RANDSEED as the random seed value for the generation of the board.
%   This is useful when debugging, as the same board can be used
%   repeatedly.
%
%   [RESULT, VALUE] = BATTLE(ROW, COL) fires a shot in a game of battleships
%   RESULT can be any of the following
%     RESULT                   VALUE
%     -1: Duplicate shot       []
%      0: No hit               []
%      1: Hit                  Matrix containing the rows and columns of the
%                              ship sunk in the firs and second column, or
%                              an empty matrix if no ship sunk.
%      2: All ships sunk       Number of shots fired
%
%   [FINISHED, SHOTS] = BATTLE('finish') returns 1 in FINISHED if all ships
%   have been sunk and the number of shots fired in SHOTS.

% Author: Carl Sandrock

function [result, value, f] = battle(row, col, randseed)

persistent fleet shot mustshow

value = [];
        
board_size = 10;
ship_lengths = [5 4 3 3 2];

switch row
    case 'init' % Initialise board
        if exist('randseed', 'var')
            rand('seed', randseed);
        end
        if nargout > 0
            result = rand('seed');
        end
        fleet = new_fleet(board_size, ship_lengths);
        shot = zeros(board_size);
% FIXME: This is a debugging measure ->
        value = zeros(board_size);
        rows = [fleet.rows];
        cols = [fleet.cols];
        for i = 1:length(cols)
            value(rows(i), cols(i)) = 1;
        end
        f = fleet;
        % <- end debugging measure
        if exist('col', 'var')
            mustshow = col;
        else
            mustshow = 0;
        end
    case 'finish'
        result = all([fleet.health] == 0);
        value = sum(sum(shot));
    otherwise
        if row > board_size || col > board_size || row < 1 || col < 1
            error('You shot out of range!')
        end
        
        % Register the shot
        result = 0;
        if shot(row, col) % already shot here
            %warning('You have already shot at (%i,%i)', row, col);
            result = -1;
        else
            ship_shot = find_ship(fleet, row, col);
            if ship_shot
                result = 1;
                
                fleet(ship_shot).health = fleet(ship_shot).health - 1;
                if fleet(ship_shot).health == 0 % The ship is sunk
                    value = [fleet(ship_shot).rows' fleet(ship_shot).cols'];
                end
            end
        end
        
        shot(row, col) = shot(row, col) + 1;
        
        if all([fleet.health]==0)
            result = 2;
            value = sum(sum(shot));
        end
        
        if mustshow
            showbattle(board_size, fleet, shot);
            pause(0.5);
        end
end

function index = find_ship(fleet, row, col)
vec = [];
for i = 1:length(fleet);
    ship = fleet(i);
    vec(end+1) = any(row == ship.rows & col == ship.cols);
end
index = find(vec);

function [rows, cols] = ship_index(ship)
if ship.vertical
    rows = ones(1, ship.length)*ship.row;
    cols = ship.col + (1:ship.length) - 1;
else
    cols = ones(1, ship.length)*ship.col;
    rows = ship.row + (1:ship.length) - 1;
end

function ship = randship(board_size, shiplength)
grey = 0; % Should we generate a nice grey board or a skew board?
ship.vertical = rand < 0.5; % should be 50% chance...
ship.length = shiplength;
if grey
    ship.row = ceil(rand*(board_size));
    ship.col = ceil(rand*(board_size));
else
    ship.row = ceil(rand*(board_size - ship.vertical*ship.length + 1));
    ship.col = ceil(rand*(board_size - ~ship.vertical*ship.length + 1));
end
ship.health = shiplength;
[ship.rows, ship.cols] = ship_index(ship);

function fleet = randfleet(board_size, shiplength)
for i = 1:length(shiplength)
   fleet(i) = randship(board_size, shiplength(i));
end

function fit = fits(board_size, fleet)
fleetrows = [fleet.rows];
fleetcols = [fleet.cols];

% TODO: can ships be next to one another? if not, add checking
% FIXME: Unique is very slow -- can we check for collisions faster?
fit = max(fleetrows) <= board_size && max(fleetcols) <= board_size && ...
    size(unique([fleetrows; fleetcols]', 'rows'), 1) == length(fleetrows);

function fleet = new_fleet(board_size, shiplengths)
unplaced = 1;
while unplaced
    fleet = randfleet(board_size, shiplengths);
    unplaced = ~fits(board_size, fleet);
end

function showbattle(board_size, fleet, shot)

[xx, yy] = meshgrid(1:board_size, board_size:-1:1);

% Plot entire fleet with circles
hold('on')
plot([fleet.cols], board_size - [fleet.rows] + 1, 'wo');

% blue background
set(gca, 'color', [0 0 0.5], ...
    'xtick', 1:10, 'ytick', 1:10, ...
    'yticklabel', 10:-1:1, ...
    'xlim', [0 11], 'ylim', [0 11]);
% White 'pegs' for shots
shotindex = find(shot>0);
plot(xx(shotindex), yy(shotindex), 'wo', 'MarkerFaceColor', 'white');

% Red 'pegs' for hits
fleetrows = [fleet.rows];
fleetcols = [fleet.cols];
shipindex = sub2ind([board_size board_size], fleetrows, fleetcols);
hitindex = intersect(shotindex, shipindex);
plot(xx(hitindex), yy(hitindex), 'ro', 'MarkerFaceColor', 'red');

% Outline of ship for ships that have been hit.
sunkships = find([fleet.health] == 0);
for ship = fleet(sunkships)
    plot([ship.cols], board_size - ship.rows + 1, 'r', 'LineWidth', 3)
end
hold('off')
    
drawnow()

function rarray = arrayfun(fun, array)
rarray = [];
for element = array
  rarray(end+1) = fun(element);
end;

function rarray = unique(array, mode);
rarray = array(1, :);
N = size(array, 1);
for i = 2:N
    row = array(i, :);
    if ~findrow(rarray, row)
        rarray(end+1, :) = row;
    end
end

function f = findrow(array, row)
f = false;
i = 1;
while ~f && i <= size(array, 1)
     f = f | all(array(i, :) == row);
     i = i + 1;
end