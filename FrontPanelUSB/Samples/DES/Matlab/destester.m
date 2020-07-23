% Copyright (c) 2005 Opal Kelly Incorporated
% $Rev: 113 $ $Date: 2006-05-26 09:27:05 -0700 (Fri, 26 May 2006) $

clear all;

xem = des_setup()
key = hex2dec(['1234'; '5678'; '1234'; '5678']);

len = 10000;
x = uint8(round(rand(len, 1) * 255));
y = des_crypt(xem, key, x, 'encrypt');
xx = des_crypt(xem, key, y, 'decrypt');
plot((1:len), x(1:len), 'bo', ...
     (1:len), y(1:len), 'gx', ...
     (1:len), xx(1:len), 'rs')

