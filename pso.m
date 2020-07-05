function pso(app)
    tic
    %clc;
    %clear;
    %close all;

    %% Problem Definition

    model=CreateModel(app); % initialize graph

    CostFunction=@(xhat) MyCost(xhat,model);        % Cost Function

    nVar=model.n*(model.n-1)/2;             % Number of Decision Variables

    VarSize=[1 nVar];   % Decision Variables Matrix Size

    VarMin=0;         % Lower Bound of Variables
    VarMax=1;         % Upper Bound of Variables


    %% PSO Parameters

    MaxIt=app.MaxIter.Value;      % Maximum Number of Iterations

    nPop=app.SwarmPop.Value;       % Population Size (Swarm Size)

    w=app.InertiaW.Value;              % Inertia Weight
    wdamp=app.InertiaWD.Value;            % Inertia Weight Damping Ratio
    c1=app.PCoefficient.Value;             % Personal Learning Coefficient
    c2=app.GCoefficient.Value;             % Global Learning Coefficient

    % Velocity Limits
    VelMax=0.1*(VarMax-VarMin);
    VelMin=-VelMax;

    mu = 0.1;      % Mutation Rate

    %% Initialization

    empty_particle.Position=[];
    empty_particle.Cost=[];
    empty_particle.Sol=[];
    empty_particle.Velocity=[];
    empty_particle.Best.Position=[];
    empty_particle.Best.Cost=[];
    empty_particle.Best.Sol=[];

    particle=repmat(empty_particle,nPop,1);

    BestSol.Cost=inf;

    for i=1:nPop

        % Initialize Position
        particle(i).Position=unifrnd(VarMin,VarMax,VarSize);

        % Initialize Velocity
        particle(i).Velocity=zeros(VarSize);

        % Evaluation
        [particle(i).Cost, particle(i).Sol]=CostFunction(particle(i).Position);

        % Update Personal Best
        particle(i).Best.Position=particle(i).Position;
        particle(i).Best.Cost=particle(i).Cost;
        particle(i).Best.Sol=particle(i).Sol;

        % Update Global Best
        if particle(i).Best.Cost<BestSol.Cost

            BestSol=particle(i).Best;

        end

    end

    BestCost=zeros(MaxIt,1);
    LastUpdate=0;
    LastToc=toc;

    %% PSO Main Loop

    for it=1:MaxIt

        for i=1:nPop

            % Update Velocity
            particle(i).Velocity = w*particle(i).Velocity ...
                +c1*rand(VarSize).*(particle(i).Best.Position-particle(i).Position) ...
                +c2*rand(VarSize).*(BestSol.Position-particle(i).Position);

            % Apply Velocity Limits
            particle(i).Velocity = max(particle(i).Velocity,VelMin);
            particle(i).Velocity = min(particle(i).Velocity,VelMax);

            % Update Position
            particle(i).Position = particle(i).Position + particle(i).Velocity;

            % Velocity Mirror Effect
            IsOutside=(particle(i).Position<VarMin | particle(i).Position>VarMax);
            particle(i).Velocity(IsOutside)=-particle(i).Velocity(IsOutside);

            % Apply Position Limits
            particle(i).Position = max(particle(i).Position,VarMin);
            particle(i).Position = min(particle(i).Position,VarMax);

            % Evaluation
            [particle(i).Cost, particle(i).Sol] = CostFunction(particle(i).Position);

            % Mutation
            for k=1:2
                NewParticle=particle(i);
                NewParticle.Position=Mutate(particle(i).Position, mu);
                [NewParticle.Cost, NewParticle.Sol]=CostFunction(NewParticle.Position);
                if NewParticle.Cost<=particle(i).Cost || rand < 0.1
                    particle(i)=NewParticle;
                end
            end

            % Update Personal Best
            if particle(i).Cost<particle(i).Best.Cost

                particle(i).Best.Position=particle(i).Position;
                particle(i).Best.Cost=particle(i).Cost;
                particle(i).Best.Sol=particle(i).Sol;

                % Update Global Best
                if particle(i).Best.Cost<BestSol.Cost
                    LastToc=toc;
                    BestSol=particle(i).Best;
                    LastUpdate=it;
                end

            end

        end

        % Local Search based on Mutation
        for k=1:5
            NewParticle=BestSol;
            NewParticle.Position=Mutate(BestSol.Position, mu);
            [NewParticle.Cost, NewParticle.Sol]=CostFunction(NewParticle.Position);
            if NewParticle.Cost<=BestSol.Cost
                BestSol=NewParticle;
            end
        end    

        BestCost(it)=BestSol.Cost;
        
        app.OutputTextArea.Value = ['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it)); app.OutputTextArea.Value];
        %disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);

        w=w*wdamp;

        % Plot Best Solution
        %figure(1);
        PlotSolution(BestSol.Sol,model,app);
        app.LastIterBestCost.Value = [num2str(LastUpdate), ' Iteration'];
        app.LastIterBestTime.Value = [num2str(LastToc), ' seconds'];
        pause(0.01);

    end

    %% Results
    
    
    %disp(['Last Best Cost Update: ' num2str(LastUpdate) ', Last Best Cost Elapse Time: ' num2str(LastToc) ' seconds' ])
    app.TotalElapseTime.Text = ['Total Elapse Time: ', num2str(toc), ' seconds'];
    %figure;
    plot(app.BestCostLine,BestCost,'LineWidth',2);
    %xlabel('Iteration');
    %ylabel('Best Cost');
end
