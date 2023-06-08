%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function reads in position and friction data continuously for a
% requested number of seconds
%
% Inputs:  port = name & info of open port, needed for PIC communication
%          seconds = how long, in seconds, you'd like to stream in data
%
% Outputs: data = [positionData,frictionData]
%          time = time vector, in seconds
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data,time] = getData(port,seconds)

flushinput(port);

fs = 125; %sampling frequency, in Hz
finaltime = datenum(clock + [0,0,0,0,0,seconds]);

%ask tpad for data
fwrite(port,'R');

%read in data. 
i=1;
while datenum(clock) < finaltime
    s = fscanf(port);
    data(i,:) = sscanf(s,'%f,%f\n'); 
    i=i+1;
end

%tell tpad to stop sending data
fwrite(port,'X');

%read remainder of data in buffer
while port.BytesAvailable > 0
    s = fscanf(port);
    data(i,:) = sscanf(s,'%f,%f\n');
    i=i+1;   
end

%create time vector
time = (0:length(data(:,1))-1)*(1/fs);

end