% Generates all the results for the SIGGRAPH paper at:
% http://people.csail.mit.edu/mrub/vidmag
%
% Copyright (c) 2011-2012 Massachusetts Institute of Technology, 
% Quanta Research Cambridge, Inc.
%
% Authors: Hao-yu Wu, Michael Rubinstein, Eugene Shih
% License: Please refer to the LICENCE file
% Date: June 2012
%

clear;

dataDir = './Videos';
ampDir = 'AmplifiedVideos';

mkdir(ampDir);


%% baby
inFile = fullfile(dataDir,'l3.mp4');
fprintf('Processing %s\n', inFile);
amplify_spatial_lpyr_temporal_iir(inFile, ampDir, 10, 16, 0.4, 0.05, 0.1);

% Alternative processing using butterworth filter
% amplify_spatial_lpyr_temporal_butter(inFile, ampDir, 30, 16, 0.4, 3, 30, 0.1);

%% baby2
inFile = fullfile(dataDir,'baby2.mp4');
fprintf('Processing %s\n', inFile);
amplify_spatial_Gdown_temporal_ideal(inFile,ampDir,150,6, 140/60,160/60,30, 1);

%% camera
inFile = fullfile(dataDir,'camera.mp4');
fprintf('Processing %s\n', inFile);
amplify_spatial_lpyr_temporal_butter(inFile, ampDir, 150, 20, 45, 100, 300, 0);


%% subway
inFile = fullfile(dataDir,'subway.mp4');
fprintf('Processing %s\n', inFile);
amplify_spatial_lpyr_temporal_butter(inFile, ampDir, 60, 90, 3.6, 6.2, 30, 0.3);

%% wrist
%% No mask is used here to generate the output video.
inFile = fullfile(dataDir,'2020-02-21 10_54_52.mp4');
fprintf('Processing %s\n', inFile);
amplify_spatial_lpyr_temporal_iir(inFile, ampDir, 10, 16, 0.4, 0.05, 0.1);

% Alternative processing using butterworth filter
% amplify_spatial_lpyr_temporal_butter(inFile, ampDir, 30, 16, 0.4, 3, 30, 0.1);

%% shadow
inFile = fullfile(dataDir,'shadow.mp4');
fprintf('Processing %s\n', inFile);
amplify_spatial_lpyr_temporal_butter(inFile, ampDir, 5, 48, 0.5, 10, 30, 0);

%% guitar
inFile = fullfile(dataDir,'IMG_0489.mov');
fprintf('Processing %s\n', inFile);
% amplify E
amplify_spatial_lpyr_temporal_ideal(inFile, ampDir, 50, 10, 72, 92, 600, 0);
% amplify A
amplify_spatial_lpyr_temporal_ideal(inFile, ampDir, 100, 10, 100, 120, 600, 0);


%% face
inFile = fullfile(dataDir,'IMG_0491.mov');
fprintf('Processing %s\n', inFile);
amplify_spatial_Gdown_temporal_ideal(inFile,ampDir,50,4, ...
                     50/60,60/60,30, 1);


%% face2
inFile = fullfile(dataDir,'face2.mp4');
fprintf('Processing %s\n', inFile);

% Motion
amplify_spatial_lpyr_temporal_butter(inFile,ampDir,20,80, ...
                                     0.5,10,30, 0);
% Color
amplify_spatial_Gdown_temporal_ideal(inFile,ampDir,50,6, ...
                                     50/60,60/60,30, 1);
