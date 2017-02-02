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

% Last Modified by GUIDE v2.5 31-Jan-2017 13:43:23

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
function ClearSerialButton_Callback(hObject, eventdata, handles)
% hObject    handle to ClearSerialButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    mode = 5;
    setappdata(0,'mode',mode);

if exist('mySerial')
    mySerial = getappdata(0,'mySerial');
    onCloseSerial(mySerial);
end
delete(instrfindall) % delete all instruments
connected = 0;
if exist('connected')
    setappdata(0,'connected',connected);
end
 set(handles.connectedText, 'string','Disconnected');
    
RxDataBuffer = getappdata(0,'RxDataBuffer');
RxDataBuffer.clear();
setappdata(0,'RxDataBuffer',RxDataBuffer);
save = 0;
setappdata(0,'save',save);


% --- Executes on button press in ConnectButton.
function ConnectButton_Callback(hObject, eventdata, handles)
% hObject    handle to ConnectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    import java.util.LinkedList
    RxDataBuffer = LinkedList();
    RxDataBuffer.clear();
    mode = 5;
    setappdata(0,'mode',mode);
    if exist('mySerial')
        mySerial = getappdata(0,'mySerial');
        onCloseSerial(mySerial);
    else
        delete(instrfindall) % delete all instruments
    end

    comPort = '/dev/tty.usbserial-FT99JGHS';
    %comPort = '/dev/tty.usbserial-FTG45715';
    %comPort = '/dev/cu.usbmodem14121';
    % It creates a serial element calling the function "setupSerial"

    if(~exist('serialFlag','var'))
        [mySerial,serialFlag] = setupSerial(comPort,RxDataBuffer);
    end

    setappdata(0,'mySerial',mySerial);
    setappdata(0,'RxDataBuffer',RxDataBuffer);
    
    pulse_frequency = uint32(str2num(get(handles.InputFrequencyInput, 'string')));
    num_pulse = uint32(str2num(get(handles.nPulsesInput, 'string')));
    tx_en_delay = uint32(str2num(get(handles.TxEnDelayInput, 'string')));
    reset_delay = uint32(str2num(get(handles.ResetDelayInput, 'string')));
    
    
    [nSamples, connected] = SerialDataSetup(mySerial,RxDataBuffer,pulse_frequency,num_pulse,tx_en_delay,reset_delay);
    
    setappdata(0,'nSamples',nSamples);
    setappdata(0,'connected',connected);
    if(connected) 
        set(handles.connectedText, 'string','Connected');
    else
        set(handles.connectedText, 'string','Timed Out!!!');
        mySerial = getappdata(0,'mySerial');
        onCloseSerial(mySerial);
    end
    
    save = 0;
    setappdata(0,'save',save);
    



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
    mySerial = getappdata(0,'mySerial');
    mode = 4;
    fwrite(mySerial,uint32(mode),'uint32');
    setappdata(0,'mode',mode);
        RxDataBuffer = getappdata(0,'RxDataBuffer');
    RxDataBuffer.clear();
    setappdata(0,'RxDataBuffer',RxDataBuffer);
   


% --- Executes on button press in GetDataProcessedButton.
function GetDataProcessedButton_Callback(hObject, eventdata, handles)
% hObject    handle to GetDataProcessedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    RxDataBuffer = getappdata(0,'RxDataBuffer');
    RxDataBuffer.clear();
    setappdata(0,'RxDataBuffer',RxDataBuffer);
    mySerial = getappdata(0,'mySerial');
    mode = 1;
    setappdata(0,'mode',mode);
    fwrite(mySerial,uint32(mode),'uint32');
    saveFileName = get(handles.saveDataFileText, 'string');
    
    flushinput(mySerial); % flush serial port
    
    %Collect and plot data
    x = 0 ;
    neuralData = 0;
    while(mode == 1)
    mode = getappdata(0,'mode');
    save = getappdata(0,'save');
        if(mode == 4)
            break;
        end
        %Check if data is received
        if(mySerial.bytesAvailable() > 0)
            incoming = uint32(fread(mySerial,1,'uint32'));


            %record and plot data as it comes in if 
            % data is not the terminator 
                %disp(['Incoming ',num2str(incoming)]);
                %neuralData = incoming; 
                %x = (((double(incoming)./2048)*400) + 500)./1000;
                x = incoming;
                neuralData = [ neuralData, x];
                axes(handles.axes1);
                plot(neuralData) ;
                axis([-inf,inf,0,1.8])
                xlabel('Number of Samples');
                ylabel('Voltage [V]');
                grid
                drawnow;

        end
        pause(0.001);
    end
    if(save)
        savefast(['data/processed/',saveFileName,'-',datestr(now, 'dd-mmm-yyyy-HH-MM-SS.FFF'),'.mat'],'neuralData'); 
    end



% --- Executes on button press in GetDataRawButton.
function GetDataRawButton_Callback(hObject, eventdata, handles)
% hObject    handle to GetDataRawButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   
    RxDataBuffer = getappdata(0,'RxDataBuffer');
    RxDataBuffer.clear();
    setappdata(0,'RxDataBuffer',RxDataBuffer);
    mySerial = getappdata(0,'mySerial');
    mode = 0;
    setappdata(0,'mode',mode);
    fwrite(mySerial,uint32(mode),'uint32');
    nSamples = getappdata(0,'nSamples');
    nSamples = double(nSamples);
    
    saveFileName = get(handles.saveDataFileText, 'string');
    %Collect and plot data
    %terminator = 13;
    %x = 0 ;
    %n = 0;
   disp(['nSamples ',num2str(nSamples)]);
   axes(handles.axes1);
   
   % CREATE FILTER
   signalFreq = 1.8e6;
   samplingFreq = 34e6;
   firNumTaps = 256;
   relFreqWindow = [1.2 3.8];
   firCoefs = fir1(firNumTaps, [(relFreqWindow(1).*signalFreq./samplingFreq) (relFreqWindow(2).*signalFreq./samplingFreq)], 'bandpass');

   
   while(mode == 0)
        mode = getappdata(0,'mode');
        save = getappdata(0,'save');
        if(mode == 4)
            break;
        end
        %Check if data is received
        if(mySerial.bytesAvailable() > 0)
            %disp('Got Something');
            %incoming = RxDataBuffer.remove();

            %disp(['Incoming ',num2str(incoming)]);
            %record and plot data as it comes in if 
            % data is not the terminator 
           
                %disp(['Incoming ',num2str(incoming)]);
                samples = uint32(fread(mySerial,nSamples,'uint32'));
                neuralData = (((double(samples)./2048)*400) + 500)./1000;
                
                %FIlter
                dataFiltered = filtfilt(firCoefs,1,neuralData);
                dataFiltered = squeeze(dataFiltered);
                
                
                %fprintf('NeuralData\n');
                %fprintf('%i\n',neuralData);
                plot(dataFiltered) ;
                axis([0 nSamples -1 1]);
                xlabel('Number of Samples');
                ylabel('Voltage [V]');
                grid
                drawnow;
                if(save)
                    %disp(['data/raw/',saveFileName,'-',datestr(now, 'dd-mmm-yyyy-HH-MM'),'.mat']);
                    %save_neuralData = neuralData;
                   
                   savefast(['data/raw/',saveFileName,'-',datestr(now, 'dd-mmm-yyyy-HH-MM-SS.FFF'),'.mat'],'neuralData'); 
                   %clear('neuralData');
                end
        end
       pause(0.001);
   end
   RxDataBuffer = getappdata(0,'RxDataBuffer');
   RxDataBuffer.clear();
   setappdata(0,'RxDataBuffer',RxDataBuffer);
    
    


% --- Executes on button press in ResetButton.
function ResetButton_Callback(hObject, eventdata, handles)
% hObject    handle to ResetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   
    mySerial = getappdata(0,'mySerial');
    mode = 3;
    fwrite(mySerial,uint32(mode),'uint32');
    setappdata(0,'mode',mode);
    RxDataBuffer = getappdata(0,'RxDataBuffer');
    RxDataBuffer.clear();
    setappdata(0,'RxDataBuffer',RxDataBuffer);



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
    mode = 5;
    setappdata(0,'mode',mode);
if exist('mySerial')
     mySerial = getappdata(0,'mySerial');
    onCloseSerial(mySerial);
end
if exist('RxDataBuffer')
    RxDataBuffer = getappdata(0,'RxDataBuffer');
    RxDataBuffer.clear();
    setappdata(0,'RxDataBuffer',RxDataBuffer);
end
if exist('connected')
    conencted = 0;
    setappdata(0,'connected',connected);
    if(connected) 
        set(handles.connectedText, 'string','Connected');
    else
        set(handles.connectedText, 'string','Disconnected');
    end
end
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
elseif saveButton == get(hObject,'Min')
	save = 0;
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
