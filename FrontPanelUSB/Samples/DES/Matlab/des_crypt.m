function y = des_decrypt(xem, key, x, op)
% Copyright (c) 2005 Opal Kelly Incorporated
% $Rev: 113 $ $Date: 2006-05-26 09:27:05 -0700 (Fri, 26 May 2006) $

% Set the DES key
setwireinvalue(xem, [11:-1:8]', key, [65535 65535 65535 65535]')
updatewireins(xem);

% Configure for ENCRYPT or DECRYPT
if op == 'decrypt'
	setwireinvalue(xem, 16, 65535, 16);
else
	setwireinvalue(xem, 16, 0, 16);
end
updatewireins(xem);

% Start decrypt/encrypt operation
activatetriggerin(xem, hex2dec('41'), 0);

nblk = ceil(size(x,1) / 2048);
xx = zeros(nblk*2048, 1);
y = zeros(nblk*2048, 1);
xx(1:size(x,1)) = x;
for j=1:nblk
	activatetriggerin(xem, hex2dec('41'), 0);
	writetopipein(xem, hex2dec('80'), xx(j*2048-2047:j*2048));

	activatetriggerin(xem, hex2dec('40'), 0);

	for k=1:10
		updatetriggerouts(xem);
		if (1==istriggered(xem, hex2dec('60'), 1))
			break;
		end
	end
	
	y(j*2048-2047:j*2048) = readfrompipeout(xem, hex2dec('a0'), 2048);
end
