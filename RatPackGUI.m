function varargout = RatPackGUI(varargin)
% RATPACKGUI MATLAB code for RatPackGUI.fig
%      RATPACKGUI, by itself, creates a new RATPACKGUI or raises the existing
%      singleton*.
%
%      H = RATPACKGUI returns the handle to a new RATPACKGUI or the handle to
%      the existing singleton*.
%
%      RATPACKGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RATPACKGUI.M with the given input arguments.
%
%      RATPACKGUI('Property','Value',...) creates a new RATPACKGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RatPackGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RatPackGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RatPackGUI

% Last Modified by GUIDE v2.5 03-Feb-2017 16:04:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RatPackGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @RatPackGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before RatPackGUI is made visible.
function RatPackGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RatPackGUI (see VARARGIN)

% Choose default command line output for RatPackGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%connection flag
connected = 0;
setappdata(0,'connected',connected);

%Bluetooth flag
BT = 0;
setappdata(0,'BT',BT);

%Set a backround image
% % create an axes that spans the whole gui
% ah = axes('unit', 'normalized', 'position', [0 0 1 1]); 
% % import the background image and show it on the axes
% bg = imread('neuron.jpg'); imagesc(bg);
% % prevent plotting over the background and turn the axis off
% set(ah,'handlevisibility','off','visible','off')
% % making sure the background is behind all the other uicontrols
% uistack(ah, 'bottom');

% Turn the handlevisibility off so that we don't inadvertently plot into the axes again

% UIWAIT makes RatPackGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RatPackGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% Save the serial port name in comPort variable.



% --- Executes on button press in ClearSerialButton.
% Function will clear the serial port
function ClearSerialButton_Callback(hObject, eventdata, handles)
% hObject    handle to ClearSerialButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Find out if serial port is connected
mySerial = getappdata(0,'mySerial');
connected = getappdata(0,'connected');

%if there is a connection, close it
if(connected)
    % Reset mode
    mode = 3;
    % Put device in reset
    fwrite(mySerial,uint32(mode),'uint32');
    % Set mode
    setappdata(0,'mode',mode);
    
    % Close Serial Connection
    mySerial = getappdata(0,'mySerial');
    onCloseSerial(mySerial);
    disp('mySerial Existed and was Closed');
else
    delete(instrfindall) % delete all instruments
end

% Save device no longer connected
connected = 0;
setappdata(0,'connected',connected);

% Set string to disconnected
set(handles.connectedText, 'string','Disconnected');
    
% Reset the data buffer
save = 0;
setappdata(0,'save',save);


% --- Executes on button press in ConnectButton.
% Connects serial port of bluetooth port
function ConnectButton_Callback(hObject, eventdata, handles)
% hObject    handle to ConnectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   

    
    %Set mode to ilde
    mode = 5;
    setappdata(0,'mode',mode);
    
    if exist('mySerial')
        mySerial = getappdata(0,'mySerial');
        onCloseSerial(mySerial);
    else
        delete(instrfindall) % delete all instruments
    end

    %Set com port
    comPort = '/dev/tty.usbserial-FT99JGHS';
    %comPort = '/dev/tty.usbserial-FTG45715';
    %comPort = '/dev/cu.usbmodem14121';

    % Connect to bluetooth or serial port based on BT
    BT = getappdata(0,'BT');
    if(~BT)
        disp('Serial');
        if(~exist('serialFlag','var'))
         [mySerial,serialFlag] = setupSerial(comPort);
        end
    else
        disp('Bluetooth');
        if(~exist('b'))
            b = Bluetooth('HC-06',1);
            fopen(b);
        end
        mySerial = b;
    end

    setappdata(0,'mySerial',mySerial);
    
    % Get all variables to be set
    pulse_frequency = uint32(str2num(get(handles.InputFrequencyInput, 'string')));
    num_pulse = uint32(str2num(get(handles.nPulsesInput, 'string')));
    tx_en_delay = uint32(str2num(get(handles.TxEnDelayInput, 'string')));
    reset_delay = uint32(str2num(get(handles.ResetDelayInput, 'string')));
    pMode = uint32(str2num(get(handles.pModeInput, 'string')));
    
    % Send all variables to device
    [nSamples, connected] = SerialDataSetup(mySerial,pulse_frequency,num_pulse,tx_en_delay,reset_delay,pMode);
    
    setappdata(0,'nSamples',nSamples);
    setappdata(0,'connected',connected);
    
    % Make sure device is connected and didn't time out
    if(connected) 
        set(handles.connectedText, 'string','Connected');
    else
        set(handles.connectedText, 'string','Timed Out!!!');
        mySerial = getappdata(0,'mySerial');
        onCloseSerial(mySerial);
    end
    
    save = 0;
    setappdata(0,'save',save);
    
    %Arduino
    if exist('arduinoMoteControl')
    clear arduinoMoteControl
    end


    % Setup Arduino 
    ARDUINO_MOTES = 1;  %   set to 1 to use the arduino to control motes
    pulseCount = 1;

    moteControlNumber = 1;          % number of motes
    moteControlProbability = 0.20;  % initiate a given mote 5% of pulses
    moteControlDuration = 3;        % once a mote modulates, keep it modulated for 3 total pulses
    moteControlLockout = 5;         % number of pulses after mote done firing that it won't re-modulate

    %=========================================================================
    % create data to send vector
    numPulsesPerSymbol = 8;
    numberPrependedZeroSymbols = 16;
    dataToEncode = 1 - [0 1 1 0 1 0 0 0 0 1 1 0 0 1 0 1 0 1 1 0 1 1 0 0 0 1 1 0 1 1 0 0 0 1 1 0 1 1 1 1 0 0 1 0 0 0 0 0 0 1 1 1 0 1 1 1 0 1 1 0 1 1 1 1 0 1 1 1 0 0 1 0 0 1 1 0 1 1 0 0 0 1 1 0 0 1 0 0];
    dataToEncodeWithPrependedZeros = [zeros(1, numberPrependedZeroSymbols), dataToEncode, zeros(1, numberPrependedZeroSymbols)];
    dataToEncodeExpanded = ones(numPulsesPerSymbol, 1) * dataToEncodeWithPrependedZeros;
    dataToArduino = dataToEncodeExpanded(:);




    %=========================================================================
    % prep arduino mote control
    if ARDUINO_MOTES
        arduinoMoteControl = arduino();
        moteControlHistory = (moteControlDuration + moteControlLockout + 1).*ones(moteControlNumber, 1);  % pulses since the last time a mote started to modulate; equal to 1 on the first modulated pulse
        moteControlLUT = {'D52', 'D53';
                          'D48', 'D49';
                          'D44', 'D45';
                          'D40', 'D41'};   % the arduino pins for each mote (first column is switch, second column is led)
        isMoteModulated = zeros(moteControlNumber, 1);
    end
    
    setappdata(0,'isMoteModulated',isMoteModulated);
    setappdata(0,'moteControlLUT',moteControlLUT);
    setappdata(0,'dataToArduino',dataToArduino);
    setappdata(0,'arduinoMoteControl',arduinoMoteControl);
    



function InputFrequencyInput_Callback(hObject, eventdata, handles)
% hObject    handle to InputFrequencyInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InputFrequencyInput as text
%        str2double(get(hObject,'String')) returns contents of InputFrequencyInput as a double


% --- Executes during object creation, after setting all properties.
function InputFrequencyInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InputFrequencyInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nPulsesInput_Callback(hObject, eventdata, handles)
% hObject    handle to nPulsesInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nPulsesInput as text
%        str2double(get(hObject,'String')) returns contents of nPulsesInput as a double


% --- Executes during object creation, after setting all properties.
function nPulsesInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nPulsesInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TxEnDelayInput_Callback(hObject, eventdata, handles)
% hObject    handle to TxEnDelayInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TxEnDelayInput as text
%        str2double(get(hObject,'String')) returns contents of TxEnDelayInput as a double


% --- Executes during object creation, after setting all properties.
function TxEnDelayInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TxEnDelayInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ResetDelayInput_Callback(hObject, eventdata, handles)
% hObject    handle to ResetDelayInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ResetDelayInput as text
%        str2double(get(hObject,'String')) returns contents of ResetDelayInput as a double


% --- Executes during object creation, after setting all properties.
function ResetDelayInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ResetDelayInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in StopButton.
function StopButton_Callback(hObject, eventdata, handles)
% hObject    handle to StopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    % Sends the stop command to device
    mySerial = getappdata(0,'mySerial');
    mode = 4;
    fwrite(mySerial,uint32(mode),'uint32');
    setappdata(0,'mode',mode);



% --- Executes on button press in GetDataProcessedButton.
function GetDataProcessedButton_Callback(hObject, eventdata, handles)
% hObject    handle to GetDataProcessedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    

    mySerial = getappdata(0,'mySerial');
    mode = 1;
    setappdata(0,'mode',mode);
    fwrite(mySerial,uint32(mode),'uint32');
    saveFileName = get(handles.saveDataFileText, 'string');
    
    flushinput(mySerial); % flush serial port
    pMode = uint32(str2num(get(handles.pModeInput, 'string')));
    nSamples = getappdata(0,'nSamples');
    nSamples = double(nSamples);
    
    %arduino info
    moteControlNumber = 1;  
    isMoteModulated = getappdata(0,'isMoteModulated');
    moteControlLUT = getappdata(0,'moteControlLUT');
    dataToArduino = getappdata(0,'dataToArduino');
    arduinoMoteControl = getappdata(0,'arduinoMoteControl');
    pulseCount = 1;
    
    %Collect and plot data
    
    neuralData = 0;
    moteData = 0;
    
    % Keep collecting data until told to reset or stop
    while(mode == 1)
    mode = getappdata(0,'mode');
    save = getappdata(0,'save');
   
    
        % Check if this is processed data
        % Processed data will be plotted one uint32 at a time
        % data will be appended and plotted as a "live stream"
        if(pMode == 0)
            %Check if data is received
            if(mySerial.bytesAvailable() > 0)
   
                for g = 1:moteControlNumber
                
                    if(pulseCount > length(dataToArduino))
                        pulseCount = 1;
                    end
                
                    isMoteModulated = dataToArduino(pulseCount);
                    writeDigitalPin(arduinoMoteControl, moteControlLUT{g, 1}, isMoteModulated) % the mote switch
                    writeDigitalPin(arduinoMoteControl, moteControlLUT{g, 2}, isMoteModulated) % LED
                end

                pulseCount = pulseCount + 1;
                moteData = [moteData, isMoteModulated];
                
                % Get incoming data 
                incoming = uint32(fread(mySerial,1,'uint32'));
                x = incoming;
                
                %Append data
                neuralData = [neuralData, x];
                
                % Plot neural data and mote state
                axes(handles.axes1);
                yyaxis left
                plot(neuralData(2:end));
                ylabel('Neural Data');
                
                yyaxis right 
                plot(moteData(2:end));
                ylabel('Mote State');
                xlabel('Number of Samples');
                %axis([-inf,inf,10e6,10e8])
                grid
                drawnow;

            end
        elseif(pMode == 2)
                % This is for filtered backscatter data (entire waveform)
                if(mySerial.bytesAvailable() > 0)
                    
                    
                    % do mote control
                    for g = 1:moteControlNumber
                        %isMoteModulated = (moteControlHistory(g) >= 1) && (moteControlHistory(g) <= moteControlDuration);  % determine if the mote is modulated during this pulse
                        if(pulseCount > length(dataToArduino))
                            pulseCount = 1;
                        end
                        isMoteModulated = dataToArduino(pulseCount);
                        writeDigitalPin(arduinoMoteControl, moteControlLUT{g, 1}, isMoteModulated) % the mote switch
                        writeDigitalPin(arduinoMoteControl, moteControlLUT{g, 2}, isMoteModulated) % LED
                    end
              

                    pulseCount = pulseCount + 1;   
           
                    samples = int16(fread(mySerial,nSamples,'int16'));
                    neuralData = (((double(samples)./2048)*400) + 500)./1000;
                
                
                    plot(neuralData) ;
                    axis([0 nSamples -1 1]);
                    xlabel('Number of Samples');
                    ylabel('Voltage [V]');
                    grid
                    drawnow;
                        if(save)
                            savefast(['data/raw/',saveFileName,'-',datestr(now, 'dd-mmm-yyyy-HH-MM-SS.FFF'),'.mat'],'neuralData','isMoteModulated'); 
                        end
                end
         end
        pause(0.001);
    end
    
    if(pMode == 0)
        savefast(['data/processed/',saveFileName,'-',datestr(now, 'dd-mmm-yyyy-HH-MM-SS.FFF'),'.mat'],'neuralData','moteData'); 
    end



% --- Executes on button press in GetDataRawButton.
% Collects and plots raw, unfiltered data
function GetDataRawButton_Callback(hObject, eventdata, handles)
% hObject    handle to GetDataRawButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   

    mySerial = getappdata(0,'mySerial');
    mode = 0;
    setappdata(0,'mode',mode);
    fwrite(mySerial,uint32(mode),'uint32');
    nSamples = getappdata(0,'nSamples');
    nSamples = double(nSamples);
    
    saveFileName = get(handles.saveDataFileText, 'string');
    
    
    %arduino info
    moteControlNumber = 1; 
    pulseCount = 1;
    isMoteModulated = getappdata(0,'isMoteModulated');
    moteControlLUT = getappdata(0,'moteControlLUT');
    dataToArduino = getappdata(0,'dataToArduino');
    arduinoMoteControl = getappdata(0,'arduinoMoteControl');
    disp(['nSamples ',num2str(nSamples)]);
    axes(handles.axes1);
   
   % CREATE FILTER
   signalFreq = 1.8e6;
   samplingFreq = 34e6;
   firNumTaps = 256;
   relFreqWindow = [1.2 3.8];
   firCoefs = fir1(firNumTaps, [(relFreqWindow(1).*signalFreq./samplingFreq) (relFreqWindow(2).*signalFreq./samplingFreq)], 'bandpass');

   % Keep collecting data while in raw data mode
   while(mode == 0)
        mode = getappdata(0,'mode');
        save = getappdata(0,'save');
        
        %Check if data is received
        if(mySerial.bytesAvailable() > 0)
           
                for g = 1:moteControlNumber
                    %isMoteModulated = (moteControlHistory(g) >= 1) && (moteControlHistory(g) <= moteControlDuration);  % determine if the mote is modulated during this pulse
                    if(pulseCount > length(dataToArduino))
                        pulseCount = 1;
                    end
                    isMoteModulated = dataToArduino(pulseCount);
                    writeDigitalPin(arduinoMoteControl, moteControlLUT{g, 1}, isMoteModulated) % the mote switch
                    writeDigitalPin(arduinoMoteControl, moteControlLUT{g, 2}, isMoteModulated) % LED
                end
                
            pulseCount = pulseCount + 1;
           
            samples = uint16(fread(mySerial,nSamples,'uint16'));
            neuralData = (((double(samples)./2048)*400) + 500)./1000;
                
            %FIlter
            dataFiltered = filtfilt(firCoefs,1,neuralData);
            dataFiltered = squeeze(dataFiltered);
                
                % Display data
                %plot(dataFiltered) ;
                plot(neuralData);
                axis([0 nSamples 0 1.8]);
                xlabel('Number of Samples');
                ylabel('Voltage [V]');
                grid
                drawnow;
                if(save)
                   savefast(['data/raw/',saveFileName,'-',datestr(now, 'dd-mmm-yyyy-HH-MM-SS.FFF'),'.mat'],'neuralData','isMoteModulated'); 
                end
        end
       pause(0.001);
   end

    
    


% --- Executes on button press in ResetButton.
function ResetButton_Callback(hObject, eventdata, handles)
% hObject    handle to ResetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   
    mySerial = getappdata(0,'mySerial');
    mode = 3;
    fwrite(mySerial,uint32(mode),'uint32');
    setappdata(0,'mode',mode);




function nSamplesInput_Callback(hObject, eventdata, handles)
% hObject    handle to nSamplesInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nSamplesInput as text
%        str2double(get(hObject,'String')) returns contents of nSamplesInput as a double


% --- Executes during object creation, after setting all properties.
function nSamplesInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nSamplesInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
mySerial = getappdata(0,'mySerial');
connected = getappdata(0,'connected');
if(connected)
    mode = 3;
    fwrite(mySerial,uint32(mode),'uint32');
    setappdata(0,'mode',mode);
     mySerial = getappdata(0,'mySerial');
    onCloseSerial(mySerial);
    disp('Closed!!! At end');
else
    delete(instrfindall) % delete all instruments
end


connected = 0;
setappdata(0,'connected',connected);
%set(handles.connectedText, 'string','Disconnected');

delete(instrfindall) % delete all instruments
delete(hObject);


% --- Executes on button press in saveDataButton.
function saveDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveButton = get(hObject,'Value');
if saveButton == get(hObject,'Max')
	save = 1;
    disp('Will Save');
elseif saveButton == get(hObject,'Min')
	save = 0;
    disp('Will NOT Save');
end
setappdata(0,'save',save);



function saveDataFileText_Callback(hObject, eventdata, handles)
% hObject    handle to saveDataFileText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: get(hObject,'String') returns contents of saveDataFileText as text
%        str2double(get(hObject,'String')) returns contents of saveDataFileText as a double


% --- Executes during object creation, after setting all properties.
function saveDataFileText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saveDataFileText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BTButton.
function BTButton_Callback(hObject, eventdata, handles)
% hObject    handle to BTButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
BTButton = get(hObject,'Value');
if BTButton == get(hObject,'Max')
	BT = 0;
elseif BTButton == get(hObject,'Min')
	BT = 1;
end
setappdata(0,'BT',BT);

% %Fake GUI
% load('data/processed/BT_BAT_ex1-02-Feb-2017-17-41-37.163.mat')   
% 
% 
% yyaxis left
% plot(neuralData(2+128:800));
% ylabel('Backscatter Modulation Extraction');
% yyaxis right 
% plot(moteData(2+128:800));
% axis([-inf inf -0.5 1.5]);
% ylabel('Neural Dust Mote State');
% xlabel('Bit Number');
% 
% set(handles.connectedText, 'string','Connected');

% Hint: get(hObject,'Value') returns toggle state of BTButton



function pModeInput_Callback(hObject, eventdata, handles)
% hObject    handle to pModeInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pModeInput as text
%        str2double(get(hObject,'String')) returns contents of pModeInput as a double


% --- Executes during object creation, after setting all properties.
function pModeInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pModeInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
