function carlbattle(visuals)
if ~exist('visuals', 'var')
    visuals = false;
end

% Game-specific parameters
board_size = 10;
ships = [5 4 3 3 2]; % we will remove the ships from this list as they are shot

load boardprob;
deeplimit = 2; % how many ships remain when we start to deep search?
deepshotlimit = inf;

hw = 200;
bpfun = @(board) board + 0.9;

% close_packing = true;
[cols, rows] = meshgrid(1:board_size);
everywhere = true(board_size);
startsize = length(ships);
shiphorz = 0; % no ships are horizontal so far

% We will encode as follows: 0 for  miss, 1 for hit, -1 for sunk ship, nan
% for unknown 
board = nan(board_size); % start off with all positions 'unknown'
open = everywhere; % where have we shot before?
ph = zeros(board_size);
pv = zeros(board_size);
% calculate initial probability with no ships sunk
[ph(open), pv(open)] = updateprobabilities(ships, 0, board, everywhere);
maxval = max(ph(:) + pv(:));
horzweight = nways(startsize, shiphorz+1);
vertweight = nways(startsize, startsize - length(ships) - shiphorz + 1);
shots = 0;
deepmap = 0;
while ~isempty(ships) % keep going until all ships are sunk
    if length(ships) > deeplimit && shots < deepshotlimit
        p = ((horzweight + hw)*ph + (vertweight + hw)*pv)/(horzweight+vertweight+hw).*bpfun(boardprob);
    elseif ~deepmap
        if visuals; disp('Generating map'); end;
        [p, allfleets] = bprob([], board, ships);
        if visuals; disp(['Identified ' num2str(length(allfleets)) ' possible fleets']); end;
        deepmap = 1;
    end
    if visuals; imagesc(flipud(p)); set(gca, 'YDir', 'normal'); end;
    maxprob = max(max(p(open)));
    [row, col] = find(p==maxprob & open, 1);
    block = abs(rows - row) <= max(ships) & abs(cols - col) <= max(ships);
    cross = (rows == row | cols == col)  & block;
    [result, value] = battle(row, col); open(row, col) = false;
    shots = shots + 1;
    %    pause
    switch result
        case -1
            error('Duplicate shot -- this shouldn''t happen!')
        case 0
            board(row, col) = 0;
            if deepmap
                [p, allfleets] = processblock(p, allfleets, row, col, 'remove');
            else
                updatearea = cross;
            end
        case 1
            if isempty(value) % no ship sunk
                board(row, col) = 1;
                if deepmap
                    [p, allfleets] = processblock(p, allfleets, row, col, 'keep');
                else
                    updatearea = cross;
                end
            else              
                board(value(:, 1), value(:, 2)) = -1;
                % remove this ship from the candidates
                theship = size(value, 1);
                ships(find(ships == theship, 1, 'first')) = [];
                if deepmap
                    [p, allfleets] = processblock(p, allfleets, row, col, 'keep');
                else
                    if all(value(:, 1) == value(1, 1)) % ship was horizontal
                        shiphorz = shiphorz + 1;
                    end
                    updatearea = everywhere;
                    horzweight = nways(startsize, shiphorz+1);
                    vertweight = nways(startsize, startsize - length(ships) - shiphorz + 1);
                end
            end
        case 2
            ships = [];
    end
    if result < 2
        if ~deepmap
            [ph(updatearea), pv(updatearea)] = updateprobabilities(ships, maxval, board, updatearea);
        end
    end
end

function k = nways(N, m)
% The sum of the number of ways that at least m ships out of N could be
% horizontal
if m == 0
    k = 1;
    m = 1;
else
    k = 0;
end
for i = m:N
    k = k + nchoosek(N, i);
end

function [ph, pv] = updateprobabilities(ships, maxval, board, updatearea)
N = max(ships);
[row, col] = find(updatearea);
ph = zeros(size(row));
pv = ph;
for i = 1:length(row)
    hregion = nregion(N, board, row(i), col(i), 1);
    vregion = nregion(N, board, row(i), col(i), 0);
    ph(i) = ncombs(ships, hregion, maxval, N);
    pv(i) = ncombs(ships, vregion, maxval, N);
end

function r = nregion(n, board, row, col, horizontal)
if horizontal 
    r = zeros(1, 2*n-1);
    rpos = (-(n-1):(n-1)) + col;
    goodpos = rpos>=1 & rpos<=size(board, 2);
    r(goodpos) = board(row, rpos(goodpos));
else
    r = nregion(n, board', col, row, 1);
end

function n = ncombs(ships, region, maxval, position)
% Determine in how many ways a ship may be placed on position in region
% Note: region must have at least 2*max(ships)-1 elements.
%
%     a   b   c
% |---+---+---+---|
%
% ships can't cross 'obstacles' -- known misses and known ships
Nships = length(ships);
Nregion = length(region);
rpos = 1:Nregion;

% startpos and endpos are the positions of the open spots left and right of
% the position
startpos = find(region(1:position) <= 0, 1, 'last') + 1;
if isempty(startpos); startpos = 1; end;
endpos = find(region(position:end) <= 0, 1, 'first') + position - 2;
if isempty(endpos); endpos = Nregion; end;
hits = region == 1 & startpos <= rpos & rpos <= endpos;
sides = [position - startpos; endpos - position] + 1;
freedom = [ships; sides(:, ones(Nships, 1)); endpos - startpos - ships + 2];
n = sum(max(0, min(freedom)));

% Determine hit pattern and add scores for each tipe of ship
shipss = ships(ones(length(region), 1), :);  
distance = abs(rpos' - position);
rposs = distance(:, ones(1, Nships));
hitpattern = max(0, shipss - rposs);
hitpoints = sum(hits * hitpattern);
hitscore = ceil(hitpoints*maxval/sum(ships));

n = n + hitscore;

function [combs, allfleets] = bprob(givenfleet, board, remainingships)
Nships = length(remainingships);
combs = zeros(10);
allfleets = {};
if Nships > 0 
    for i = 1:Nships % place each of the ships
        ship = remainingships(i);
        for vert = [0 1] % horizontally and vertically
            for r = 1:(10-~vert*(ship-1)) % on every row
                for c = 1:(10-vert*(ship-1)) % and every column
                    if isnan(board(r, c)) || board(r, c) == 1 
                        thisship = makeship(ship, r, c, vert);
                        
                        if fits([givenfleet thisship], board) % if it can fit
                            [rcombs, rallfleets] = bprob([givenfleet thisship], board, remainingships([1:i-1 i+1:end]));
                            combs = combs + rcombs;
                            if ~isempty(rallfleets)
                                allfleets = {allfleets{:} rallfleets{:}};
                            end
                        end
                    end
                end
            end
        end
    end
else % no ships to place, just return the fleet positions
    if matches(givenfleet, board)
        combs = shipboard(givenfleet);
        allfleets = {givenfleet};
    end
end

function r = shipboard(fleet)
r = zeros(10);
for ship = fleet
    r(ship.rows, ship.cols) = r(ship.rows, ship.cols) + 1;
end

function ship = makeship(len, row, col, vert)
ship = struct('length', len, 'row', row, 'col', col, 'vertical', vert);
[ship.rows, ship.cols] = ship_index(ship);

function f = fits(fleet, board)
theships = shipboard(fleet);
if max(max(theships)) <= 1; 
    badplacement = theships(board == 0 | board == -1);
    f = ~any(badplacement(:));
else
    f = false;
end;

function m = matches(fleet, board) % check if this fleet matches the information given
% This means that all known ship positions must be covered by a ship
theships = shipboard(fleet);
goodplacement = theships(board == 1);
m = all(goodplacement);

function [rows, cols] = ship_index(ship)
if ship.vertical
    rows = ones(1, ship.length)*ship.row;
    cols = ship.col + (1:ship.length) - 1;
else
    cols = ones(1, ship.length)*ship.col;
    rows = ship.row + (1:ship.length) - 1;
end

function [p, rallfleets] = processblock(p, allfleets, row, col, action)
remove = false(size(allfleets));
if length(allfleets) > 1
    for i = 1:length(allfleets)
        fleet = allfleets{i};
        anycrosses = false;
        for ship = fleet
            crosses = any(ship.rows == row & ship.cols == col);
            anycrosses = anycrosses | crosses;
            if strcmp(action, 'remove') && crosses
                remove(i) = true;
            end
        end
        if strcmp(action, 'keep') && ~anycrosses
            remove(i) = true;
        end
        if remove(i)
            for ship = fleet
                p(ship.rows, ship.cols) = p(ship.rows, ship.cols) - 1;
            end
        end
    end
end

rallfleets = allfleets(~remove);

%disp(['Before ' action ': ' num2str(length(allfleets)) ', after ' action ': ' num2str(length(rallfleets))])
