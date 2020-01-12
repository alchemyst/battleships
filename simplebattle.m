function findships

shipsremain = true;
% start in the top left corner
row = 1; 
col = 1;

while shipsremain
    result = battle(row, col);
    if result == 2 % 2 indicates all ships sunk
        shipsremain = false; % so no ships remain
    else
        if col < 10 % Move one column to the right if we have not reached the end
            col = col + 1;
        else % We have reached the end of the column, move to the next row
            col = 1;
            row = row + 1;
        end
    end
end