clc


%-------video input------
obj = VideoReader('head_lowered.mp4');
I = read(obj,1);
rate = obj.FrameRate; %---no. of frames/second---%
disp(rate);


%-----working on 1st frame------%
%---skin color detection---%
figure, imshow(I)
I = imresize( I, [360 640]);
figure, imshow(I)
I = double(I);  % convert image to double precision%
[hue,s,v] = rgb2hsv(I);    %RGB to hue, saturation, value%
%%%----threshold to find skin color for YCbCr color space(color space conversion technique)----%%%
cb = 0.148* I(:,:,1) - 0.291* I(:,:,2) + 0.439 * I(:,:,3) + 128;  %blue difference%
cr = 0.439 * I(:,:,1) - 0.368 * I(:,:,2) -0.071 * I(:,:,3) + 128;  %red difference%
[len, ht] = size(I(:,:,1)); 

count = 0;
segment(1,1)=1;
%condition for skin color detection%
for i=1:len
    for j=1:ht
        if 135<=cr(i,j) && cr(i,j)<=180 && 120<=cb(i,j) && cb(i,j)<=200 && 0.01<=hue(i,j) && hue(i,j)<=0.1 
            segment(i,j)=1;
            count = count + 1;
        else
            segment(i,j)=0;
        end
    end
end

%imshow(segments); %--'skin segmentation' to find exposed face--%
im(:,:,1)= I(:,:,1).*segment;
im(:,:,2)= I(:,:,2).*segment;
im(:,:,3)= I(:,:,3).*segment;
figure,imshow(uint8(im)); %---convert into 8 unsigned integer to reduce memorysize---%


%--------Calculating the percentage of skin using defined skin color range--------%
count;
pixel_count = (count*5)/100;


%--------Working on rest frames------%
num = 0; %keeps track of no. of frames in which head was lowered
nFrames = obj.NumFrames;

for t = 2:2:nFrames-1  %---rest of the frames---%
    %--same skin color detection as above--%
    count1 = 0;
    I = read(obj,t);
    I = imresize( I, [360 640]);
    I = double(I);
    [hue,s,v] = rgb2hsv(I);
    cb = 0.148* I(:,:,1) - 0.291* I(:,:,2) + 0.439 * I(:,:,3) + 128;
    cr = 0.439 * I(:,:,1) - 0.368 * I(:,:,2) -0.071 * I(:,:,3) + 128;
    [w, h] = size(I(:,:,1));
    segment1(1,1)=1;
    for i=1:w
        for j=1:h
            if 135<=cr(i,j) && cr(i,j)<=180&& 120<=cb(i,j) && cb(i,j)<=200 && 0.01<=hue(i,j) && hue(i,j)<=0.1
                segment1(i,j)=1;
                count1 = count1 + 1;
            else
                segment1(i,j)=0;
            end
        end
    end 
    
    
    im(:,:,1)=I(:,:,1).*segment1;
    im(:,:,2)=I(:,:,2).*segment1;
    im(:,:,3)=I(:,:,3).*segment1;
    
    
    if count - count1 > pixel_count %--on the basis of skin exposed detecting the condtion of head--%
        num = num+1; 
    end
    %--more than 15 frames: warning--%
    if num > 15
        'generate Warning';
        t;
        num = 0;
    end
    
end





