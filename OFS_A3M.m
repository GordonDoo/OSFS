function [ selectedFeatures,time ] = OFS_A3M( X, Y)
% Adapated Neighgborhood rough set 
% Max-dependency Max-relevance Max-significance
%
% Output:  selectedFeatures  ѡ���������ż���
%                time   �㷨����ʱ��
% Input:  X     �����������ݾ���
%            Y     ������ǩ����
%            N     �б��������ڽ�����
%   

%��������ʱ��
start=tic;
[~,p]=size(X);

mode=zeros(1,p);                                             %���ѡ�е������±�
dep_Mean=0;                                                    %Ŀǰ��ѡ�������������������dep��ֵ
dep_Set=0;                                                        %Ŀǰ��ѡ�������ϵ�depֵ
depArray=zeros(1,p);                                        %��������������


for i=1:p
     col=X(:,i);
     dep_single=dep_an(col,Y);                          %��������������������㵥�����Ե�������
     depArray(1,i)=dep_single;
     
    if dep_single>dep_Mean                               % Max-relevance ��������������>dep_mean ���Ϊ��ѡ����
            mode(1,i)=1;             
            cols=X(:,mode==1);                               %�������Ϲ��׶�    
            dep_New=dep_an(cols,Y);
            if dep_New>dep_Set                             %Map-dependency
                   dep_Set=dep_New;
                   dep_Mean=dep_Set/sum(mode);
            elseif dep_New==dep_Set                                                         %Max-significance

                   [index_del] = non_signf(X,Y,mode,i);
                   mode(1,index_del)=0;

                   dep_Mean=dep_Set/sum(mode);
           else
                    mode(1,i)=0;   
           end
    
     end
    
end

selectedFeatures=find(mode==1);

time=toc(start);    
end

function [index_del] = non_signf(X,Y,mode,i)
%�ڱ�ѡ�����в��Ҳ��Ƴ�significant==0������
B=zeros(1,length(mode));
R=mode;
T=mode;
T(1,i)=0;

indexs=find(T==1);
Num=length(indexs);
A=randperm(Num);

for i=1:Num
    rnd=A(i);
    ind=indexs(rnd);
    if sig(X,Y,R,ind)==0
        B(1,ind)=1;
        R(1,ind)=0;
    end
end
index_del=B==1;
end

function [s]= sig(X,Y,mode,f_i)
%����������Ҫ��
[d_B]=dep_an(X(:,mode==1),Y);
mode(1,f_i)=0;
[d_F]=dep_an(X(:,mode==1),Y);

s=(d_B-d_F)/d_B;
end


function [ dep ] = dep_an(data,Y)
%������������data�Ա�ǩY��������

[n,~]=size(data);
card_U=length(Y);
card_ND=0;
D = pdist(data,'seuclidean');
DArray=squareform(D,'tomatrix');
for i=1:n
     d=DArray(:,i);
     class=Y(i,1);
     card_ND=card_ND+card(d,Y,class,n);
end
dep=card_ND/card_U;
end


%����Ҫ����N����cardֵ
%N����Ϊ����ڵ�����ʹ��������-��С���룬Ȼ��ֳ�N�ȷݣ�����ɽ���Զ��ĳһ�ȷ����޵㣬ȡǰx�ȷ��е���
%               [max{d}-min{d}]/N+x*min{d}    
%������ͬ�̶ȼ���cardֵ
function [c]=card(sets,Y,label,N)
        [D,I]=sort(sets);        
        
        min_d=D(2,1);
        max_d=D(N,1);
        mean_d=1.5*(max_d-min_d)/(N-2);
        
        cNum=0;
        cTotal=1;
        ind2=I(2,1);
        if Y(ind2,1)==label
               cNum=cNum+1;
        end
        
         for j=3:N
             if D(j,1)-D(j-1,1)<mean_d
                 ind=I(j,1);
                 cTotal=cTotal+1;
                 if Y(ind,1)==label
                     cNum=cNum+1;
                 end
             else
                  break;
             end
         end  
        
         c=cNum/cTotal;

end

