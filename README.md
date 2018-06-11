# Lua-based ZX Spectrum ROM

The aim of the project is to create a 16 kilobyte ROM that can be used either 
as a replacement for the 16K and 48K ZX Spectrum ROM with Sinclair BASIC or
as a replacement for ROM0 in 128K ZX Spectrum retaining the BASIC ROM as ROM1.

Compatibility with the original 16K ROM is retained whenever reasonable.

The first milestone is a user-space LUA interpreter relying on ZX ROM for OS 
functions. It is loaded from address $8000 with RAMTOP set to $5FFFF (24575).
Unlike the final product, it won't work on 16K Spectrums.

