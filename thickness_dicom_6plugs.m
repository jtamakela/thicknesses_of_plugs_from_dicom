function thicknesses = Read_thicknesses_JM()
% Calculates thicknesses for cartilage plugs semiautomatically, (c) Janne Mäkelä
% Takes an average from 9 points around chosen point
% For Seniors February, 2017
% Latest Version: https://github.com/jtamakela/thicknesses_of_plugs_from_dicom


% Assumes 36 um slice thickness (e.g. Controlfile 65 at ChaCha)

% 1. Run
% 2. Select folder, where the DICOMs are
% 3. Pick center 6 times
% 4. Enjoy results

clear all, close all,% clc 

%window = 20; %For rectangles
r = 10; %Radius of the mask
% Tresholds that define the cartilage
lowtres = 1000;
hitres = 9000;



% %% %% %% %% %%
thicknesses = Read_dicoms(r,lowtres,hitres); %Actual function for the calculations

% %% %% %% %% %% 

% % %%%%%%%%%%%%%%%%%%
% % Uncomment all the following before 'function thickness_mean' 
% % if you want to run through multiple measurements/folders
% 
% list = dir;
% k=1;
% for i = 3:length(list);
%     if list(i).isdir == 1;
%         folders(k) = list(i);
%         k = k+1;
%     end
% end
% 
% % %%%%%%%%%%%%%%%%%%%%%
% % Waitbars to keep track of progress
% % Not much need in normal measurements
% 
% %h = waitbar(0,'Please wait...');
% for folder_i = 1:length(folders);
%     
%     display(['Processing folder #', num2str(folders(folder_i).name)])
%     
%     %waitbar(folder_i/(i+1));
% 
%     
%     %Go into a folder
%     cd(folders(folder_i).name)
%     
%     
%     
%     
%     
%     cd .. %come out of the folder
% %     if i==2;
% %         keyboard;
% %     end
% end
% 
% %close(h);

%% Actual Measurement and figures
function thickness_mean = Read_dicoms(r,lowtres,hitres)
% Dicoms = uint16([]);
% dicoms_mean=uint16([]);
%Read all the dicoms

path = uigetdir; %Choose the folder

dicomnames = dir([num2str(path) '/*.DCM*']); %Read dicoms
disp(['Folder: ', dicomnames(1).folder]);

for i = 1:length(dicomnames);
    Dicoms(:,:,i)= dicomread([num2str(path) '/' dicomnames(i).name]);
    %X = dicomread(dicoms(i).name);
    %waitbar(i/length(dicoms));
end

dicoms_mean = median(cat(3, Dicoms(:,:,round(end/2)), Dicoms(:,:,end)),3 );
figure(99); 
imshow(imadjust(dicoms_mean));
title(['Click the centers of plugs']);

% % % % Uncomment the following if you need to browse through slides before picking points
% % slider_question = menu('Do you need to use slider:','1) No','2) Yes');

% % if slider_question == 2;
% %     close(figure(99))
% %     dicom_slider(Dicoms)
% %     pause;
% % end


% The usual centres of plugs
%xcoord = [508 707 644 356 135];
%ycoord = [161 350 641 713 504];

% Pick points using mouse
[xcoord ycoord] = ginput(6);
xcoord = round(xcoord);
ycoord = round(ycoord);

% close(figure(100));
close(figure(99))
dicom_slider(Dicoms)


% %% Just for one point
% 
% for k = 1:5;
% dicoms = dir('*.DCM*');
% for i = 1:length(dicoms);
%     test= Dicoms(:,:,i);
%     %test(test<-15000) = NaN; %Filters
%     %test(test>30000) = NaN;
%     
%     % If there aren't values other than cartilage 
%     %Circular
%     [xgrid, ygrid] = meshgrid(1:size(test,2), 1:size(test,1));
%     mask(:,:,k) = ((xgrid-xcoord(k)).^2 + (ygrid-ycoord(k)).^2) <= r.^2;
%     values(:,k) = test(mask(:,:,k));
% 
%     
%     if isempty(find(values(:,k) < lowtres)) && isempty(find(values(:,k) > hitres)) %Find if there's numbers above treshold
%         light(i,k) = mean(values(:,k));
%         %stdev(i,k) = std(values(:,k));
%     else 
%         light(i,k) = 0;
%         
%         if i>1 && light(i-1,k) ~= 0 ; %This stops measurement of bone
%             break;
%         end
%     end
% 
%     keke(:,:,i) = test; %For figures
%     
%     %Rectangle
% %     if isempty(find(test(xcoord(k)-window:xcoord(k)+window,ycoord(k)-window:ycoord(k)+window) < 1000)) && isempty(find(test(xcoord(k)-window:xcoord(k)+window,ycoord(k)-window:ycoord(k)+window) > 10000))
% %         light(i,k) = mean(mean(test(xcoord(k)-40:xcoord(k)+40,ycoord(k)-40:ycoord(k)+40))); %Pixel values for each plug
% %         stdev(i,k) = std(mean(test(xcoord(k)-40:xcoord(k)+40,ycoord(k)-40:ycoord(k)+40))); %Standard deviation
% %     end %if
% end
% 
% thickness(k) = length(light(light(:,k)~=0,k))*0.036;
% 
% end

%% Here also surrounding locations are calculated

%Clockwise from noon:
window2 = 50;

%Measurement locations
xcoord_alt = [xcoord xcoord xcoord+window2 xcoord+window2 xcoord+window2 xcoord xcoord-window2 xcoord-window2 xcoord-window2];
ycoord_alt = [ycoord ycoord+window2 ycoord+window2 ycoord ycoord-window2 ycoord-window2 ycoord-window2 ycoord ycoord+window2];


iii = 1;
for ka = 1:9;
for kb = 1:6;


for i = 1:length(dicomnames);
    test= Dicoms(:,:,i);
    
    % If there aren't values other than cartilage 
    %Circular
    [xgrid, ygrid] = meshgrid(1:size(test,2), 1:size(test,1));
    mask_alt(:,:,iii) = ((xgrid-xcoord_alt(kb,ka)).^2 + (ygrid-ycoord_alt(kb,ka)).^2) <= r.^2;
    values(:,iii) = test(mask_alt(:,:,iii));

    
    if isempty(find(values(:,iii) < lowtres)) && isempty(find(values(:,iii) > hitres)) %Find if there's numbers above treshold
        light_alt(i,kb,ka) = mean(values(:,iii));
        %stdev(i,k) = std(values(:,k));
    else 
        light_alt(i,kb,ka) = 0;
        
        if i>1 && light_alt(i-1,kb,ka) ~= 0 ; %This stops measurement of bone
            break;
        end
    end

    % keke(:,:,i) = test; %For figures 
    
end

thickness_alt(kb,ka) = length(light_alt(light_alt(:,iii)~=0,iii))*0.036;

iii = iii+1;

end
end


% %% This shows Index values %%%%
figure;
plot(mean(light_alt,3));
legend('1', '2', '3', '4', '5', '6', 'Location', 'NW'); 
title('Plug Profiles');
ylabel('Pixel value');
xlabel('Depth (px)');


thickness_mean = mean(thickness_alt,2);


% Displaying measured locations

Mask_alt = logical(sum(mask_alt,3)); %Combining all mask layers
dicoms_mean(Mask_alt) = dicoms_mean(Mask_alt)+5000;

figure;
imshow(imadjust(dicoms_mean))
for i = 1:6;
    text(xcoord(i),ycoord(i),num2str(i),'HorizontalAlignment','center');
end

%%


% 
% %Showing where the measurements are taken %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Mask = logical(sum(mask_alt(:,:,1:6),3)); %Combining all mask layers

%Find, the first slice, where cartilage surfaces start and end
for k = 1:45;
    sliceind(:,k) = [min(find(light_alt(:,k)>0)) max(find(light_alt(:,k)>0))];
end

figure;
ii = 1;
for i = 1:12;
    Slice = Dicoms(:,:,sliceind(i));
    Slice(Mask) = Slice(Mask)+5000;
    
    subplot(6,2,i)
    imshow(imadjust(Slice(ycoord(round(i/2))-100:ycoord(round(i/2))+100, xcoord(round(i/2))-100:xcoord(round(i/2))+100)));
    
    if mod(i,2) %If even
        title(['Beginning of Plug ' , num2str(round(i/2))]);
        %ii = ii+1;
    else
        title(['End of Plug ' , num2str(round(i/2))]);
%         ii = 1;
%         if i ~= 10 
%             figure;
%         end
    end
end

pause(1);

%% Function to use slider for image
% 
function dicom_slider(Dicoms)
%B=rand(576,576,150);
Stack = Dicoms;

koko = size(Stack,3);

fig=figure(100);
set(fig,'Name','Image','Toolbar','figure',...
    'NumberTitle','off')
% Create an axes to plot in
axes('Position',[.15 .05 .7 .9]);
% sliders for epsilon and lambda
slider1_handle=uicontrol(fig,'Style','slider','Max',koko,'Min',1,...
    'Value',2,'SliderStep',[1/(koko-1) 10/(koko-1)],...
    'Units','normalized','Position',[.02 .02 .14 .05]);
uicontrol(fig,'Style','text','Units','normalized','Position',[.02 .07 .14 .04],...
    'String','Choose frame');
% Set up callbacks
vars=struct('slider1_handle',slider1_handle,'Stack',Stack);
set(slider1_handle,'Callback',{@slider1_callback,vars});
plotterfcn(vars)
% End of main file

% Callback subfunctions to support UI actions
function slider1_callback(~,~,vars)
    % Run slider1 which controls value of epsilon
    plotterfcn(vars)
end

function plotterfcn(vars)
    % Plots the image
    imshow(vars.Stack(:,:,round(get(vars.slider1_handle,'Value'))));
    title(num2str(get(vars.slider1_handle,'Value')));
    
end
end 

end %Read_dicoms

end %Read_thicknesses_JM







