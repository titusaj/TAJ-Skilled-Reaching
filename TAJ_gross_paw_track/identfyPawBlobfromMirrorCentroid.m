%Titus John
%Leventhal Lab, University of Michigan
%5/5/16
%%%%%%%%%%%%%%%%%%%%%%%%


%input
%centroid of the mirrior
%Fund matrifof 
%Binary image of the 
%pawPref


%output
%mask of the biggest blob that 


 function [fullMask] = identfyPawBlobfromMirrorCentroid(binaryImage,fundMat,cur_mir_points2d)



    %Clean the image up first by isolating the biggest blobs
    [binaryImage,oneBlobCheck] = ExtractNLargestBlobs(binaryImage, 3);
    
    %Draw the epipolar line based on the center of the mirror
    centroidMirror = [mean(cur_mir_points2d(:,1)),mean(cur_mir_points2d(:,2))];
    lines = epipolarLine(fundMat,centroidMirror);
    points = lineToBorderPoints(lines, size(binaryImage));

    %x and y 
    x = [1:2040];
    y= (-lines(1).*x-lines(3))/lines(2);
%     
% %     %Check epipolar line is being plotted correctly
            figure(8)
            imshow(binaryImage)
            hold on
            line(points(:, [1,3])', points(:, [2,4])');

    
    
    %Get the profile of the image using the epipolar line
    profile  = improfile(binaryImage,points(:, [1,3]),points(:, [2,4]));

    % Find intersection points.
	dif = diff(profile);
	
	% Find where it goes from 0 to 1, and dif == 1;
	nonZeroElements = find(dif > 0);

	% Find where it goes from 1 to 0, and dif == -1;
	nonZeroElements2 = find(dif < 0);
    
    
    
    %if the line dosent instresct anything when drawn (ie. no non-zeror
    %element) then swith over to the other side to find the other sade

        %Find the centroid of the two points
        for i = 1:length(nonZeroElements)
            centroidDirect{i} = [(x(nonZeroElements2(i))+x(nonZeroElements(i)))/2,(y(nonZeroElements2(i))+y(nonZeroElements(i)))/2];
        end


        %error occurs here because tha paw is not being found 
        keyboard

        %Pick the first centroid direct found
        centroidDirect = centroidDirect{1};



        %Extract the three biggest blobs
        [bigestBlobImage,oneBlobCheck] = ExtractNLargestBlobs(binaryImage, 3);

        %Label the images that need to be 
        [labeledImage, numberOfBlobs] = bwlabel(bigestBlobImage);

        %Identify blob of intrest based on the labeled image
        blobLabel = labeledImage(round(centroidDirect(2)),round(centroidDirect(1)))

        %Set the full Mask label
        fullMask = (labeledImage == blobLabel);
    
   
    
    
end
    
    
    
    