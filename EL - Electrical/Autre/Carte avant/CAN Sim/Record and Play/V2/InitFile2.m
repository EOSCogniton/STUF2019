% CAN Config
CANCh = canChannel('PEAK-System','PCAN_USBBUS1');
configBusSpeed(CANCh,1000000)

% Read de Data File
FileName = fullfile('C:','Users','arthu','OneDrive','1_Documents','1_DIY Sim Dash','CAN','Ttl','DataFile2.txt');
DataTable = readtable(FileName);
Data = table2array(DataTable)
S=size(Data)
N=S(1)

start(CANCh)

for i=1:N
    message = canMessage(8192,true,8);
    message.Data = ([hex2dec(string(floor(Data(i,1)/256))) hex2dec(string(mod(Data(i,1),256))) hex2dec(string(floor(Data(i,2)/256))) hex2dec(string(mod(Data(i,2),256))) hex2dec(string(floor(Data(i,3)/256))) hex2dec(string(mod(Data(i,3),256))) hex2dec(string(floor(Data(i,4)/256))) hex2dec(string(mod(Data(i,4),256)))]);
    message.Remote = false;
    
    transmit(CANCh,message)
    pause(0.02)
end

stop(CANCh)