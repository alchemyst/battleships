function carlbattle2(visuals)
if ~exist('visuals', 'var')
    visuals = false;
end

% Game-specific parameters
board_size = 10;
ships = [5 4 3 3 2]; % we will remove the ships from this list as they are shot
nvert = 0; % how many ships have been vertical?

load boardprob;
% start mesh off with offset of 3
mesh = makemesh(4);
%mesh(1:4, 7:end) = fliplr(mesh(1:4, 1:4));
%mesh(7:end, 1:4) = flipud(mesh(1:4, 1:4));

board = nan(board_size);

% calculate initial probability with no ships sunk
[roww, coll] = meshgrid(1:10);
%p = 1./(1 + (roww - 5).^2 + (coll - 5).^2);%boardprob;
p = boardprob;

startrow = 0;
startcol = 0;

shipsremain = 1;
%domains = zeros(2); % [inner rough; inner smooth; outer rough; outer smooth]
outershot = 0;
while shipsremain
    b = board;
    b(isnan(board)) = 2;
    p = boardprob.*estimateprobs(b, ships).*isnan(board);
    if any(board(:)==1) % if there are ships, kill them
        [row, col, startrow, startcol] = headshot(board, ships, nvert, startrow, startcol);
    else
        maxprob = max(max(p(isnan(board) & mesh)));
        [row, col] = find(p==maxprob & isnan(board) & mesh, 1);
        r = ((row - 5)^2 + (col - 5)^2)^(0.5);
        if r > 5
            outershot = 1;
        end
    end
    %imagesc(flipud(p)); set(gca, 'YDir', 'normal');
    [result, value] = battle(row, col);
    switch result
        case 0 % no ship
            board(row, col) = 0;
            boardprob(row, col) = 0;
        case 1
            if isempty(value) % ship, not sunk
                board(row, col) = 1;
                shiploc(row, col) = 1;
            else % ship sunk
                rows = value(:, 1);
                cols = value(:, 2);
                shiplength = size(value, 1);
                ships(find(ships==shiplength, 1)) = []; % remove ship from list
                nvert = nvert + all(cols==cols(1));
                board(rows, cols) = -1;
                if max(ships) < 4 | outershot
                    mesh = makemesh(2);
                end
            end
        case 2
            shipsremain = 0;
    end
    board = closegaps(board, min(ships));
end

function s = star(N)
s = zeros(N*2-1);
s(N, :) = 1;
s(:, N) = 1;
s(N,N) = 0;

function e = estimateprobs(b, ships)
e = zeros(10);
for ship = ships
    k = star(ship);
    e = e + conv2(b, k, 'same');
end

function board = closegaps(board, size);
size = 2; % FIXME: only debugging
kernel = [0 1 0; 1 0 1; 0 1 0];
bigboard = ones(12);
bigboard(2:end-1, 2:end-1) = board == 0;
closedgaps = conv2(bigboard, kernel, 'valid') == 4;
board(closedgaps) = 0;

function [row, col, startrow, startcol] = headshot(board, ships, nvert, startrow, startcol);
dirs = eye(2);
indir = [1 1 -1; 1 1 -1];
if startrow == 0 || board(startrow, startcol) ~= 1 % This is not a continuation
    % locate 1st ship
    [startrow, startcol] = find(board==1, 1);
end
row = startrow;
col = startcol;
% guess orientation of this ship
vert = nvert > (5 - length(ships))/2;
%start moving out if inside, inside if outside toward middle 
dist = ((row-4)^2 + (col-4)^2)^0.5;
dir = indir(vert + 1, sign(dist - 2.5) + 2);
if dist > 2.5; dir = -dir; end

nchanges = 0;
while ~isnan(board(row, col))
    row = row + dirs(vert + 1, 1)*dir;
    col = col + dirs(vert + 1, 2)*dir;
    % if we hit an obstacle or the side, change direction
    if any([row col] <= 0 | [row col] > 10) || any(board(row, col) <= 0)
        dir = -dir;
        % Step away from the problem
        row = row + dirs(vert + 1, 1)*dir;
        col = col + dirs(vert + 1, 2)*dir;
        nchanges = nchanges + 1;
        if nchanges == 2 % second time around
            % change direction
            vert = ~vert;
            nchanges = 0;
        end
    end
end

function mesh = makemesh(N);
[roww, coll] = meshgrid(1:10);
mesh = mod(roww, N) == mod(coll, N);
