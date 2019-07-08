function [prcc,studentT]=TimeVariedPRCC(M,N,K,Simdata,t)

R=zeros(N,M+1); % initializing the rank matrix

prcc=zeros(M+1,length(t)); % initializing matrix to hold PRCC statistic for each parameter at each time
studentT=zeros(M+1,length(t)); % will hold the studentT statistic


for steps=1:length(t)  % loop through time (or space) - TO DO: would like to be able to do both and get surfaces..

    for n=1:N %loop through each of the N samples
%             output=Simdata(n).r(steps,space)/(Simdata(n).r(steps,space)+Simdata(n).c(steps,space));%output variable of interest (can be a ratio of outputs)
        output=Simdata(n).y(steps);
        K(n,M+1)=output; %Output results go in the last column, the M+1st column.
    end

    for m=1:M+1 %for each parameter rank the data, including the output data
        for n=1:N
%          select parameter column m
        [s,i]=sort(K(:,m));  %sort according to the rank of column m 
        r(i,1)=[1:N]'; 
        R(n,m)=r(n,1); %store the ranking of the parameter at it's position in K
        end
    end

    C=corrcoef(R);
    if det(C)<=10^-16 %If the determinant is singular or very nearly singular
        B=pinv(C);    %must use pseudo inverse (as inv will not be accurate).
        ST=num2str(steps); %Report the timestep of the singularity (since space is fixed).
        fprintf(['C is singular at timestep ', ST,'. \n'])
    else
        B=inv(C); %The dterminant is not singular, so the inverse is valid.
    end


        for w=1:M %iterate thru the M parameters to calculate PRCCs for each with ratio
            prcc(w,steps)=(-B(w,M+1))/sqrt(B(w,w)*B(M+1,M+1)); % the PRCC between the wth parameter and the ratio
            studentT(w,steps)=prcc(w,steps)*sqrt((N-2)/(1-prcc(w,steps))); % the studentT statistic corresponding to the PRCC
        end
        %Each studentT is the distribution (showing the significance of) the
        %corresponding gamma/PRCC. 