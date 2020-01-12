% RANDELEMENT return a random element
% ELEM = RANDELEMENT(VECTOR) returns a random element from VECTOR in ELEM.

% Author Carl Sandrock

function el = randelement(vec)
el = vec(ceil(rand*length(vec)));