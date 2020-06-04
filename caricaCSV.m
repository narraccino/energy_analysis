%*************************************************************************
%*This function will load a Tektronix encoded CSV File                   *
%*************************************************************************
function [ output,header] = caricaCSV(filename)

% Open the File
fileID = fopen(filename);

% Create a storage elements to hold channel information
output=[];
% Create a storage element to hold scope information
header={};

% Get the first line
csvline = fgetl(fileID);

% a storage element to keep track of the current line within the file
linenumber=1;

% a constant value that determines when to stop processing header 
% information
constant_header_stops_after=16;
% define constant delimiter locations
constant_line_index_header_name=1;
constant_line_index_header_value=2;
constant_line_index_time=4;
constant_line_index_value=5;

% if the line has a character process the line
while ischar(csvline)
    % Segment the line into a array based upon the comma delimiter
    data=strread(csvline,'%s','delimiter',',');

    % see if we are working within the header
    if linenumber <= constant_header_stops_after 
        % buffer the header item
        parameter=data(constant_line_index_header_name);

        % check and see if the header is good
        if strcmp(parameter,'')~=1
            % Attempt to Convert value to a number
            value=str2double(data(constant_line_index_header_value));
            % check and see if the conversion worked
            if isnan(value)
                % if the conversion did not work, revert back to a string
                value=data(constant_line_index_header_value);
            end
            
            % see if this is the first time executing
            if linenumber==1
                % if it is then overwrite header
                header=[{parameter value}];    
            else
                % else augment header
                header=[header; {parameter value}];
            end
        end
    end
    
    % Take the good extracted Data and turn it into a numerical value 
    time=str2double(data(constant_line_index_time));
    value=str2double(data(constant_line_index_value));
    
    % see if this is the first time executing
    if linenumber==1
        % if it is then overwrite output
        output=[time value];
    else
        % else augment output
        output=[output; time value];
        
    end
        
    % Get the next line
    csvline = fgetl(fileID);
    
    % increment the line number
    linenumber=linenumber+1;
end

% Close the File
fclose(fileID);


end

