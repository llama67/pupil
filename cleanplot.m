%%%% Hello world! Little tiny plotting function. 
function cleanplot(filename)
load('filename')

leftmat = repmat({NaN},665,3);
rightmat = repmat({NaN},665,3);

for i = 1:3
    
    data(i).lefteye(data(i).lefteye(:,13)~=0,12) = NaN;
    data(i).righteye(data(i).righteye(:,13)~=0,12) = NaN;
    
    leftmat(:,i)=data(i).lefteye(:,12)
    rightmat(:,i)=data(i).righteye(:,12)

end



combin=horzcat(data.lefteye(:,12), data.righteye(:,12));
plot(combin);

