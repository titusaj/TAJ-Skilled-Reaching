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


 function [fullMask] = identfyPawBlobfromMirrorCentroid(binaryImage,fundMatDirect,cur_mir_points2d,boxRegions,pawPref,rgbMask)

    %have to feed a direct matrix problem
    switch pawPref
        case 'left',
            fundMat = fundMatDirect.F(:,:,2);
            fundMatOpp = fundMatDirect.F(:,:,1);
        case 'right',
            fundMat = fundMatDirect.F(:,:,1);
            fundMatOpp = fundMatDirect.F(:,:,2);
    end



    %Clean the image up first by isolating the biggest blobs
    [binaryImageBiggestBlobs,oneBlobCheck] = ExtractNLargestBlobs(binaryImage, 3);
    
    %Draw the epipolar line based on the center of the mirror
    centroidMirror = [mean(cur_mir_points2d(:,1)),mean(cur_mir_points2d(:,2))];
    lines = epipolarLine(fundMat,centroidMirror);
    points = lineToBorderPoints(lines, size(binaryImageBiggestBlobs));

    %x and y 
    x = [1:2040];
    y= (-lines(1).*x-lines(3))/lines(2);
%     
% %     %Check epipolar line is being plotted correctly
            figure(8)
            imshow(binaryImageBiggestBlobs)
            hold on
            line(points(:, [1,3])', points(:, [2,4])');
            hold on
            scatter(mean(cur_mir_points2d(:,1)),mean(cur_mir_points2d(:,2)),'r')

    
    
    %Get the profile of the image using the epipolar line
    profile  = improfile(binaryImageBiggestBlobs,points(:, [1,3]),points(:, [2,4]));

    % Find intersection points.
	dif = diff(profile);
	
	% Find where it goes from 0 to 1, and dif == 1;
	nonZeroElements = find(dif > 0);

	% Find where it goes from 1 to 0, and dif == -1;
	nonZeroElements2 = find(dif < 0);
    
     %if the line dosent instresct anything when drawn (ie. no non-zeror
    %element) then switch over to the other side to find the other sade
    %Go this if it cant th mask using the current and use oppisite view
    if isempty(nonZeroElements)
         [y, nonZeroElements,nonZeroElements2] = identifyVentralSideofPawInMirror(rgbMask,boxRegions,fundMatOpp',pawPref,binaryImageBiggestBlobs)
   %      keyboard
    end
    
    foundBlob = 0; %Blob check blob and the centroid of intrest

    %This will find the biggest blob below the epipolar line if the line
    %does still not intersect a blob when trying to find the intersections
        if isempty(nonZeroElements)

                   %Extract the three biggest blobs
                   [bigestBlobImage,oneBlobCheck] = ExtractNLargestBlobs(binaryImageBiggestBlobs, 3);

                   %Label the images that need to be 
                   [labeledImage, numberOfBlobs] = bwlabel(bigestBlobImage);
                   
                   for i = 1: 2040 %scan the x
                       for j = 1: 1024 %scan the y
                         if labeledImage(j,i) > 0
                            if j > y(i)
                               closestBlobId = labeledImage(j,i) ; 
                            end  
                         end
                       end
                   end 
                   
                   
                   if exist('closestBlobId')
                        %Set the full Mask label
                       fullMask = (labeledImage == closestBlobId);
                       foundBlob = 1; %Got the blob and the centroid of intrest
                   else
                       keyboard
                   end          
        end
    
        
        
        
        if foundBlob == 0
            %Find the centroid of the two points
            for i = 1:length(nonZeroElements)
                centroidDirect{i} = [(x(nonZeroElements2(i))+x(nonZeroElements(i)))/2,(y(nonZeroElements2(i))+y(nonZeroElements(i)))/2];

            end


            %Pick the first centroid direct found
            centroidDirect = centroidDirect{1};



            %Extract the three biggest blobs
            [bigestBlobImage,oneBlobCheck] = ExtractNLargestBlobs(binaryImageBiggestBlobs, 3);

            %Label the images that need to be 
            [labeledImage, numberOfBlobs] = bwlabel(bigestBlobImage);

            %Identify blob of intrest based on the labeled image
            blobLabel = labeledImage(round(centroidDirect(2)),round(centroidDirect(1)))


            %Set the full Mask label
            fullMask = (labeledImage == blobLabel);
        end
   
    
    
end
    
    
    
    