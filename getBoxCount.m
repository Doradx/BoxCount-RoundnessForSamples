function blockInfo=getBoxCount(bwImage,minSize)
if(nargin<2)
    minSize=50;
end
% 循环遍历每一块
blockInfo=regionprops(bwImage,'Centroid','PixelList','Area','Perimeter','BoundingBox');
delList=zeros(length(blockInfo),1);
for i=1:length(blockInfo)
   if(blockInfo(i).Area<minSize)
       delList(i)=1;
   end
end
blockInfo(find(delList>0))=[];
for i=1:length(blockInfo)
    image=imcrop(bwImage,blockInfo(i).BoundingBox);
    [x,y]=boxcount(image);
    blockInfo(i).boxCount=polyfit(log(y),log(x),1);
end
end