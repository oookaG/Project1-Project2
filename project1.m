
clc
clear all
close all


f = fred
startdate = '01/01/2003';
enddate = '01/01/2022';

%%
ID = fetch(f,'NGDPRSAXDCIDQ',startdate,enddate)      %Real Gross Domestic Product for Indonesia(NGDPRSAXDCIDQ)
JP = fetch(f,'JPNRGDPEXP',startdate,enddate)      %Real Gross Domestic Product for Japan(JPNRGDPEXP)
id = log(ID.Data(:,2));
jp = log(JP.Data(:,2));
q = ID.Data(:,1);
T = size(id,1);

% Hodrick-Prescott filter
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

idGDP = A\id;
jpPCE = A\jp;

% detrended GDP
idtilde = id-idGDP;
jptilde = jp-jpPCE;

% plot detrended GDP
dates = 2003:1/4:2022.1/4; zerovec = zeros(size(id));
figure
title('Detrended log(real GDP) 2003Q1-2022Q1'); hold on
plot(q, idtilde,'r', q, jptilde,'b')
datetick('x', 'yyyy-qq')
legend({'JAPAN','INDONESIA'},'Location','southwest')

% compute sd(y), sd(c), rho(y), rho(c), corr(y,c) (from detrended series)
ysd_id = std(idtilde)*100;
ysd_jp = std(jptilde)*100;
corryc = corrcoef(idtilde(1:T),jptilde(1:T)); corryc = corryc(1,2);

disp(['Percent standard deviation of detrended log real GDP for japan: ', num2str(ysd_id),'.']); disp(' ')
disp(['Percent standard deviation of detrended log real GDP for Indonesia: ', num2str(ysd_jp),'.']); disp(' ')
disp(['Contemporaneous correlation between detrended log real GDP and PCE: ', num2str(corryc),'.']);



