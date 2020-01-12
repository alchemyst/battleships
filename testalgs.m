%% Test different algorithms

N = 1000;

shots = [];
seeds = [];

algorithms = {'carlbattle', 'carlbattle2'};%, 'randbattle', 'esrbattle'};

for i = 1:length(algorithms)
    disp(['Testing ' algorithms{i}]);
    [shots(i, :), seeds(i, :)] = runbattle(algorithms{i}, N);
end

%%
hist(shots');
legend(algorithms);