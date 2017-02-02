function[obj,flag] = setupSerial(comPort,RxDataBuffer)
% It accept as the entry value, the index of the serial port
% Arduino is connected to, and as output values it returns the serial 
% element obj and a flag value used to check if when the script is compiled
% the serial element exists yet.
flag = 1;
% Initialize Serial object
obj = serial(comPort);
set(obj,'DataBits',8);
set(obj,'StopBits',1);
set(obj,'BaudRate',115200);
set(obj,'Parity','none');
set(obj,'Terminator',13);
%set(obj,'ByteOrder','bigEndian');
set(obj,'ByteOrder','littleEndian');
set(obj,'TimeOut',1);
set(obj,'InputBufferSize',3000*4);


% set(obj,'BytesAvailableFcnCount',1)
% set(obj,'BytesAvailableFcnMode','Terminator')
% set(obj,'BytesAvailableFcn',{@parseData,RxDataBuffer})

fopen(obj);
% a = 'b';
% while (a~='a') 
%     a=fread(obj,1,'uchar');
% end
% if (a=='a')
%     disp('Serial read');
% end
% fprintf(obj,'%c','a');
% mbox = msgbox('Serial Communication setup'); uiwait(mbox);
% fscanf(obj,'%u');
% end
