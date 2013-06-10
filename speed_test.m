
N = 1000000;

gem = [1 2; 3 4; 5 6 ; 7 8; 9 10];

tstart = tic;
for i = 1:N
    d = sum(gem,1)/5;
end

fprintf('current method: %0.3fs\n', toc(tstart));
d

tstart = tic;
for i = 1:N
%     d = sqrt(o_centroid'*s_centroid);
    d = mean(gem,1);
end
d

fprintf('new method: %0.3fs\n', toc(tstart));