function esrbattle

board_size = 10;

% this function is based on Eric Raymond's battleships algorithm
srchstep = 3;
huntoffset = 0; % floor(rand*srchstep);
rowinc = [0 -1 1 0]; % direction additions 
colinc = [-1 0 0 1];
reversedir = [4 3 2 1];
nextstate = 'random_fire';

shipsremain = 1;
onboard = @(row, col) row >= 1 & row <= board_size & col >= 1 & col <= board_size;

open = ones(board_size);

while shipsremain
    possible = @(row, col) onboard(row, col) && open(row, col);
    switch nextstate
        case 'random_fire'
            [row, col, srchstep] = randomfire(open, srchstep, huntoffset);
            [result, value] = battle(row, col);
            open(row, col) = 0;
            switch result
                case 1
                    ts.row = row;
                    ts.col = col;
                    ts.hits = 1;
                    nextstate = 'random_hit';
                case 2
                    shipsremain = 0;
                otherwise
                    nextstate = 'random_fire';
            end
        case 'random_hit' % last shot was random, but hit
            used = zeros(1, 4); 
            nextstate = 'hunt_direct';
        case 'hunt_direct' % last shot hit, we're looking for ship
            for i = 1:length(rowinc)
                available(i) = onboard(ts.row+rowinc(i), ts.col+colinc(i)) ...
                    && open(ts.row + rowinc(i), ts.col + colinc(i));
            end
            candidate = find(~used & available, 1, 'first');
            if isempty(candidate)
                nextstate = 'random_fire';
            else
                row = ts.row + rowinc(candidate);
                col = ts.col + colinc(candidate);
                used(candidate) = 1;
                [result, value] = battle(row, col);
                open(row, col) = 0;
                if result > 0 % hit
                    ts.row = row;
                    ts.col = col;
                    ts.dir = candidate;
                    ts.hits = ts.hits+1;
                    if result == 2
                        nextstate = 'random_fire';
                    else
                        nextstate = 'first_pass';
                    end
                end
            end
                
        case 'first_pass' % we have a start and a direction
            row = ts.row + rowinc(ts.dir);
            col = ts.col + colinc(ts.dir);            
            result = 0;
            if possible(row, col)
                [result, value] = battle(row, col);
                open(row, col) = 0;
                if result > 0
                    ts.row = row; ts.col = col; ts.hits = ts.hits + 1;
                    if result == 2
                        nextstate = 'random_fire';
                    end
                end
            end
            if result == 0
                nextstate = 'reverse_jump';
            end
            
        case 'reverse_jump' %nail down the ship's other end
            d = reversedir(ts.dir);
            row = ts.row + ts.hits*rowinc(d);
            col = ts.col + ts.hits*colinc(d);
            result = 0;
            if possible(row, col)
                [result, value] = battle(row, col);
                open(row, col) = 0;
                if result > 0
                    ts.row = row; ts.col = col; ts.dir = d; ts.hits = ts.hits + 1;
                    if result == 2
                        nextstate = 'random_fire';
                    else
                        nextstate = 'second_pass';
                    end
                end
            end
            if result == 0
                nextstate = 'random_fire';
            end
        case 'second_pass'
            row = ts.row + rowinc(ts.dir);
            col = ts.col + colinc(ts.dir);
            result = 0;
            if possible(row, col)
                [result, value] = battle(row, col);
                open(row, col) = 0;
                if result > 0
                    ts.row = row; ts.col = col; ts.hits = ts.hits + 1;
                    if result == 2
                        nextstate = 'random_fire';
                    else
                        nextstate = 'second_pass';
                    end
                end
            end
            if result == 0
                nextstate = 'random_fire';
            end
    end     
end

function [row, col, srchstep] = randomfire(open, srchstep, huntoffset)
board_size = max(size(open)); 
[roww, coll] = meshgrid(1:length(open));
preferred = find(open & mod(roww+huntoffset, srchstep) == mod(coll, srchstep));
open = find(open);
if ~isempty(preferred)
    [row, col] = ind2sub(board_size, min(preferred));
elseif ~isempty(open)
    [row, col] = ind2sub(board_size, min(open));
    if srchstep > 1
        srchstep = srchstep - 1;
    end
else
    error('No open positions!')
end
