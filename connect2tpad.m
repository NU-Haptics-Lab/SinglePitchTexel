%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function opens a port connection to the PIC32 inside the TPad, 
% and tests communication to make sure connection worked
%
% Inputs:  You  can input the name of the port to connect to (as a string).
%          If you input nothing, function will prompt you to select a port.
%
% Outputs: port = name & info of open port, needed for PIC communication
%          dimensions = [positionLength, micronsPerCount] 
%                     = [19200,5.3] for 2016 TPad version 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [port,dimensions] = connect2tpad(varargin)

%% find port name

%if no port name provided, ask which available port to use
if nargin < 1
    serialInfo = instrhwinfo('serial');
    disp('select port number (enter number to left of port name)')
    for i = 1:length(serialInfo.SerialPorts)
        disp(['  ',num2str(i),':  ',char(serialInfo.SerialPorts(i))])
    end
    p_idx = input('port number:');
    pname = char(serialInfo.SerialPorts(p_idx));
%if port name provided, use that one
elseif nargin == 1
    pname = varargin;
%if more than one input provided, throw an error
else
    error('input must be port name (as string) or no input at all')
end

%% connect

BAUD = 921600;  

%close port
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end
%open port
if strcmp(pname,'1') %allow for debugging by writing data to console
    port.port = '1';
else
    port = serial(pname, 'BaudRate', BAUD, 'FlowControl', 'hardware');
    fopen(port);
end

%% test communication

%Write to TPaD. Send 'I' so it knows to write back info. 
fprintf(port,'%s\n','I');

%read info. TPaD sends 2 numbers: positionLength, micronsPerCount
s = fscanf(port);
dimensions = sscanf(s,'%f,%f\n');

%make sure we successfully read some data back. If not, throw an error. 
if isempty(dimensions)
    error('connection failed, try a different port or check TPad')
end

end

