%% Test greyness of board generation

boards = zeros(10);
vert = 0;
%% 
N = 1000;
for i = 1:N
    [seed, board, f] = battle('init');
    boards = boards + board;
    vert = vert + sum([f.vertical]);
end

%% Plot
imagesc(boards)
vert/(N*5)