function test_script()
% m_atmos/test_script.m  (package function)
disp('Hello from MATLAB in VS Code!')

% Some basic math
a = 5; b = 7; c = a + b;
fprintf('The sum of %d and %d is %d\n', a, b, c);

% Plot something
x = 0:0.1:2*pi;
y = sin(x);
figure;
plot(x, y, 'r-', 'LineWidth', 2);
title('Simple Sine Wave');
xlabel('x'); ylabel('sin(x)'); grid on;
end
