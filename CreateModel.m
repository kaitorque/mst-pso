function model=CreateModel(app)

    %X = [80 0 60 0 100 20 60 20 0 40 80 40 20 80 60 0 40 20 80 20];
    %Y = [20 60 0 40 60 80 80 0 80 80 100 100 20 40 20 100 20 40 80 100];
    
    if(strcmp(app.RandomSwitch.Value, 'On'))
        %random matrix
        X = randi([app.RangeFrom.Value app.RangeTo.Value],1,app.numNode.Value);
        Y = randi([app.RangeFrom.Value app.RangeTo.Value],1,app.numNode.Value);
    else
        X = app.input.xvalue;
        Y = app.input.xvalue;
    end
    
    
    n=numel(X);
    
    d=zeros(n,n);
    
    for i=1:n
        for j=i+1:n
            d(i,j)=sqrt((X(i)-X(j))^2+(Y(i)-Y(j))^2);
            d(j,i)=d(i,j);
        end
    end
    
    model.n=n;
    model.X=X;
    model.Y=Y;
    model.d=d;

end