function PlotSolution(sol,model,app)

    X=model.X;
    Y=model.Y;
    n=model.n;
    
    A=sol.A;
    
    for i=1:n
        for j=i+1:n
            if A(i,j)~=0
                plot(app.GraphView,[X(i) X(j)],[Y(i) Y(j)],'b','LineWidth',2);
                hold(app.GraphView, 'on');
            end
        end
    end
    plot(app.GraphView,X,Y,'ko','MarkerSize',12,'MarkerFaceColor',[1 1 0]);
    hold(app.GraphView, 'off');

end