function test_quad_tree()

q = mcodekit.tree.quad_tree([0 0 10 10], 4, 8);
n = 500;
x = 10.*rand(n,1);
y = 10.*rand(n,1);


for i=1:n
    q.insert_point([x(i) y(i)]);
    drawnow;
end

j = randi(n);

q.find_fixed_radius_neighbors([x(j) y(j)], 2);
