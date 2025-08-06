copy /y ice40_nano_Code.mem ..\..\..\tb 
python mem2bin.py ice40_nano_Code.mem ice40_nano_Code.bin -be
python mem2bin.py ice40_nano_Data.mem ice40_nano_Data.bin -be

