% Read the Data File
FileName = fullfile('C:','Users','arthu','OneDrive','1_Documents','1_DIY Sim Dash','CAN','Ttl','DataFile.txt');
DataTable = readtable(FileName);
Data=DataTable{:,'Value'};

% Extract the values
while 1>0;
    RPM=Data(1);
    Throttle=Data(2);
    W_Temp=Data(3);
    A_Temp=Data(4);
    KPH=Data(5);
    O_Press=Data(6);
    F_Press=Data(7);
    O_Temp=Data(8);
    Volts=Data(9);
    Gear=Data(10);
    sim('CAN');
end
