function xem = des_setup()

% Copyright (c) 2005 Opal Kelly Incorporated
% $Rev: 113 $ $Date: 2006-05-26 09:27:05 -0700 (Fri, 26 May 2006) $

%
% Setup the XEM and PLL configuration.
%
xem = okusbxem3001v2();
openbyserial(xem);
pll = okpll22150();
setvcoparameters(pll, 400, 48);
setdiv1(pll, 'DivSrc_VCO', 8);
setoutputsource(pll, 0, 'ClkSrc_Div1ByN');
setoutputenable(pll, 0, 1);
setpllconfiguration(xem, pll);
configurefpga(xem, 'destop.bit');

%-------------------------------------------------------------------------
% Reset the DES engine
setwireinvalue(xem, 16, 65535, 1);
updatewireins(xem);
setwireinvalue(xem, 16, 0, 1);
updatewireins(xem);
