addpath('./EVM_Matlab/matlabPyrTools');
addpath('./EVM_Matlab/matlabPyrTools/MEX');


dataDir = './Videos';
ampDir = 'AmplifiedVideos';
resultsDir = 'FinalVideos';

mkdir(ampDir);

mkdir(resultsDir);

inFile = fullfile(dataDir,app.filename);
fprintf('Processing %s\n', inFile);
amplify_spatial_lpyr_temporal_iir(inFile, ampDir, 10, 16, 0.4, 0.05, 0.1);


% Sticker Detection
[~,name,~] = fileparts(app.filename);

inName = fullfile(ampDir,[name '-amp.mp4']);
outName = fullfile(resultsDir,[name '-ampfinal.mp4']);

fprintf('Processing %s\n', inName);

videoFileReader = vision.VideoFileReader(inName);
fr = videoFileReader.info.VideoFrameRate;
writer = vision.VideoFileWriter(outName, 'FileFormat', 'MPEG4','FrameRate',fr);

objectFrame = videoFileReader();

hblob = vision.BlobAnalysis('AreaOutputPort', true,...
        'CentroidOutputPort', true,...
        'BoundingBoxOutputPort', true,...
        'MinimumBlobArea', 4e3, ...
        'MaximumBlobArea', 3e4,...
        'MajorAxisLengthOutputPort', true,...
        'MinorAxisLengthOutputPort', true);
thresh = 0.25;

diffFrame = imsubtract(objectFrame(:,:,1), rgb2gray(objectFrame)); % Get one color component of the image
diffFrame = medfilt2(diffFrame, [3 3]); % Filter out the noise by using median filter
binFrame = im2bw(diffFrame, thresh); % Convert the image into binary image with the stickers as white

[areas, centroids, boxes, majoraxis, minoraxis] = hblob(binFrame);

% Sort connected components in descending order by area
[~, idx] = sort(areas, 'Descend');

% Get the two largest components.
boxes = double(boxes(idx(1:3), :));
centroids = double(centroids(idx(1:3), :));
majoraxis = double(majoraxis(idx(1:3), :));
minoraxis = double(minoraxis(idx(1:3), :));

point1 = centroids(1,:);
point2 = centroids(2,:);
point3 = centroids(3,:);

dist1 = pdist([point1;point2],'euclidean');
dist2 = pdist([point1;point3],'euclidean');
dist3 = pdist([point2;point3],'euclidean');


estdiameter = max(majoraxis);


realdiameter = 1.9;

estlength1 = (realdiameter*dist1)/estdiameter;
estlength2 = (realdiameter*dist2)/estdiameter;
estlength3 = (realdiameter*dist3)/estdiameter;

txt1 = [num2str(estlength1) 'cm'];
txt2 = [num2str(estlength2) 'cm'];
txt3 = [num2str(estlength3) 'cm'];



while ~isDone(videoFileReader)
      frame = videoFileReader();

      out = insertObjectAnnotation(frame, 'rectangle', boxes, 'Sticker');
      out = insertShape(out,'circle',[point1,10],'LineWidth',5);
      out = insertShape(out,'circle',[point2,10],'LineWidth',5);
      out = insertShape(out,'circle',[point3,10],'LineWidth',5);
      out = insertText(out,(point1(:) + point2(:)).'/2,txt1);
      out = insertShape(out,'Line',[point1 point2],'LineWidth',2);
      out = insertText(out,(point1(:) + point3(:)).'/2,txt2);
      out = insertShape(out,'Line',[point1 point3],'LineWidth',2);
      out = insertText(out,(point2(:) + point3(:)).'/2,txt3);
      out = insertShape(out,'Line',[point2 point3],'LineWidth',2);

      writer(out);
end

release(videoFileReader);
release(writer);