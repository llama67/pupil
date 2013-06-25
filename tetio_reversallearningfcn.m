function reversallearningfcn(varargin)


%% Set up data files
global Partnum numtrial Partfile trialvec
%% Unify Key Names
%KbCheck('UnifyKeyNames') 
%KbName('UnifyKeyNames') %keynames will match those on Mac OS-X operating sys
stopkey=KbName('escape');
Rkey=KbName('rightarrow');
Lkey=KbName('leftarrow');
  
datadoc = strcat(Partnum,'revlearn',numtrial);
default_data = strcat(datadoc,'_data');
default_events = strcat(datadoc,'_events');
datafile = strcat('/data/pupil/',Partfile);

    try
        cd(datafile)
    catch
        mkdir(datafile)
        cd(datafile)
    end
    addpath('/matlab/pupil/code/TESTER')
    
%%PTB Settings (it tends to complain on PCs)
%%%%%%%% PTB preliminaries %%%%%%%%%%%%%
%check for open windows
openwins=Screen('Windows');
if isempty(openwins)
    warning('off','MATLAB:dispatcher:InexactMatch');
    Screen('Preference', 'SkipSyncTests',2); %disables all testing -- use only if ms timing is not at all an issue
    Screen('Preference','VisualDebugLevel', 0);
    Screen('Preference', 'SuppressAllWarnings', 1);
    Screen('CloseAll')
    %HideCursor; % turn off mouse cursor
    
    %which screen do we display to?
    which_screen=1;
    
    %open window, blank screen
    [window, screenRect] = Screen('OpenWindow',which_screen,[0, 0, 0],[],32);
else
    %blank the already open window
    window=openwins(1);
    Screen('FillRect',window,[255, 255, 255]); 
    Screen('Flip',window);
    which_screen = 1;
    [window, screenRect] = Screen('OpenWindow',which_screen,[0, 0, 0],[],32);
end
horz = screenRect(3);
vert = screenRect(4);
    
% InitializeMatlabOpenGL([],[],1);
%ListenChar(2); %keeps keyboard input from going to Matlab window


%%%%%%%%%%%%%% Sound Parameters %%%%%%%%%%%%%
setup_audio
[popsnd,popF]=wavread('pop.wav');
[cashsnd,cashF]=wavread('cash.wav');
% cash = audioplayer(cashsnd, cashF);
% pops = audioplayer(popsnd, popF);

% %setup geometry
% setup_geometry

%create task vectors
reversallearning

%%%%%%%% communicate with Tobii %%%%%%%%%

%% CHECK FOR TOBII CONNECTION
tetio_CONNECT;

%%%%%%%% countdown to start task %%%%%%%%
for (i = 1:4);
    
    when = GetSecs + 1;
    
    % PRESENT STARTING Screen
    BlankScreen = Screen('OpenOffScreenwindow', window,[0 0 0]);
    if i == 4
       txt = ''; 
    else
        txt = num2str(4-i);
    end
    Screen('TextSize', BlankScreen, 20);
    Screen('DrawText', BlankScreen, txt, floor(horz/2), floor(vert/2), [255 255 255], [0 0 0], 1);
    Screen('CopyWindow', BlankScreen, window);
    flipTime = Screen('Flip', window, when);
end

%%%%%%%% Start the Task %%%%%%%%%%%%%%%%%%%%%

WaitSecs(0.5);

pressvec = zeros(1, length(trialvec));
for ind = 1:length(trialvec)
 
    timertrialstart(ind) = GetSecs;
    
    % paint on screen stimulus
    Screen('FillOval',window,[0 0 255], [horz*.25, vert*.25, horz*.75, vert*.75]) %balloon
    Screen('Flip', window);
    
    
    % Wait for response
    press = 0;
    while press == 0
        [secs, KeyCode] = KbWait([], 3);
    if (find(KeyCode)==79)  %they chose right
        pressvec(ind) = 0;
        press = 1;
    elseif (find(KeyCode)==80) %they chose left
	    pressvec(ind) = 1;
        press =2;
    elseif find(KeyCode)==41 %they chose esc to bail out
	    pressvec(ind) = 2;
        press = 3;
	    %Screen('Closeall')
	    return
    end
    end
    
    
    if pressvec(ind) == trialvec(ind)
        PsychPortAudio('DeleteBuffer')
        PsychPortAudio('FillBuffer',pahandle,cashsnd');
        PsychPortAudio('SetLoop',pahandle);
        PsychPortAudio('Start',pahandle);
    %tell that cashsound happened
        sndplay(ind) = 1;
    elseif pressvec(ind) ~= trialvec(ind)
        PsychPortAudio('DeleteBuffer')
        PsychPortAudio('FillBuffer',pahandle,popsnd');
        PsychPortAudio('SetLoop',pahandle);
        PsychPortAudio('Start',pahandle);
      % tell that pop happened
        sndplay(ind) = 2;
    end
end 
    %savedata

Screen('CloseAll')

try 
catch q
    ShowCursor
    sca
    keyboard
end

%% Chose where to end up

%cd(startdir) % Directory we started in
cd(datafile) % Directory in which we save light test data