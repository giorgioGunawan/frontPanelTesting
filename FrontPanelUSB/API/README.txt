FrontPanel API - Directory Structure
====================================
The API files are setup as follows:

okFP_ROOT is the install path for FrontPanel. Typically, this is:
    C:\Program Files\Opal Kelly\FrontPanelUSB

ARCH is the architecture (Win32 or x64)


C / C++ / DLL Files
  + $(okFP_ROOT)/include/okFrontPanel.h
  + $(okFP_ROOT)/lib/$(ARCH)/okFrontPanel.lib
  + $(okFP_ROOT)/lib/$(ARCH)/okFrontPanel.dll

C#
  + $(okFP_ROOT)/$(ARCH)/libFrontPanel-csharp.dll
  + $(okFP_ROOT)/$(ARCH)/libFrontPanel-pinv.dll
  
Python
  + $(okFP_ROOT)/Python/$(PY_VERSION)/$(ARCH)/_ok.py
  + $(okFP_ROOT)/Python/$(PY_VERSION)/$(ARCH)/ok.py

  (where PY_VERSION could be "2.7" or "3.4").

Java
  + $(okFP_ROOT)/Java/$(ARCH)/okjFrontPanel.dll
  + $(okFP_ROOT)/Java/$(ARCH)/okjFrontPanel.jar

Matlab (for reference only, not supported)
  + $(okFP_ROOT)/...
  + Note that Matlab also requires the DLL from the C/C++/DLL above.
