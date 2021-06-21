%  creating video object
vid=VideoReader("slomo.mp4");
image=read(vid,1); %  reading frame 1 of vid object
figure,imshow(image);


%  no. of frames (approx) = vid rate * vid duration
rate=vid.FrameRate;fprintf("rate = %d \n",rate);
dur=vid.Duration;
n_frames = ceil(rate*dur);fprintf("number of frames = %d \n",n_frames);


%working on face
detector=vision.CascadeObjectDetector('FrontalFaceLBP','MergeThreshold',40); % w/o merge the output wasn't a vector but a 2D object for some frames
%The multiple detections are merged into one bounding box per target object. You can use the MergeThreshold property to control the number of detections required before combining or rejecting the detections.
bbox=step(detector,image); %forming a bounding box for face detection
face=imcrop(image,bbox);
size1 = size(face,1); %rows(vertical len)
size2 = size(face,2); %columns(horizontal len)
figure,imshow(face);

%working on eyes
i = int64(.23*size1); % eyes position vertically, 23% from the top of face
j = int64(.15*size2);  % eyes position horizontally, 15% from the left of face
len = int64(.68*size2); % length of box
ht = int64(.25*size1); % height of box
eyes = imcrop(face,[j,i,len,ht]);
figure,imshow(eyes);

%working on mouth
i = int64(.67*size1);
j = int64(.27*size2);
len = int64(.45*size2);
ht = int64(.20*size1);
mouth = imcrop(face,[j,i,len,ht]);
figure,imshow(mouth);



% directly binarising the rgb image gives blank ans
% nnz=no. of black pixels, numel = total no.of pixels


% eyes binarisation
eyes=rgb2gray(eyes);
eyes=imbinarize(eyes);
figure,imshow(eyes);

% finding black pixels in eyes
eyespercentage=nnz(~eyes)*100 / numel(eyes); 



% mouth binarisation
mouth=rgb2gray(mouth);
mouth=imbinarize(mouth);
figure,imshow(mouth);

% finding black pixels in mouth
mouthpercentage=nnz(~mouth)*100 / numel(mouth);


%finding mouth and eyes for next frames of the video
threshold_frames=2*rate; % if more than this number of frames then generate warning
threshold_percentage=4; % diff in black pixels should be more than this 
counter = 0; % to count frames in which driver was caught dozing
ar=zeros(n_frames); % array which will store bit level of each frame
for t=186 : n_frames-1
    im=read(vid,t);
    bb=step(detector,im);
    eyesclosed=1; % boolean 0->open , 1-> closed , defalt: eyes closed
    mouthopen=1; % boolean 0->closed , 1-> open , default: mouth open
    bitlevel=0; % driver not drowsy
    if size(bb,1)~=0 && size(bb,2)~=0
        face=imcrop(im,bb);
        %working on eyes
        i = int64(.23*size1);
        j = int64(.15*size2); 
        len = int64(.68*size2);
        ht = int64(.25*size1);
        e = imcrop(face,[j,i,len,ht]);
        e=imbinarize(rgb2gray(e));
        ep=nnz(~e) *100/ numel(e); % black percentage in eyes 
        
        %working on mouth
        i = int64(.67*size1);
        j = int64(.27*size2);
        len = int64(.45*size2);
        ht = int64(.20*size1);
        m = imcrop(face,[j,i,len,ht]);        
        m=imbinarize(rgb2gray(m));
        mp=nnz(~m)*100 / numel(m); % black percentage in mouth
        
        
        if ep > eyespercentage-threshold_percentage && ep < eyespercentage+threshold_percentage
            eyesclosed=0; %eyes open
        end
        if mp > mouthpercentage-threshold_percentage && mp < mouthpercentage+threshold_percentage
            mouthopen=0; %eyes open
        end
        
        if eyesclosed==0 && mouthopen==0
            bitlevel=0; % driver is good to go
        else
            bitlevel=1; % driver is drowsy
            ar(t)=bitlevel;
            if ar(t-1)==0 
                counter=0; %if the bitlevel is 0 then re initialise counter 
            end
            counter = counter + 1;
            
        end   
             
        if counter>=threshold_frames
            disp('warning');
            fprintf("frame at which warning was given = %d \n",t);
            break;
        end
        
    end
    
end





