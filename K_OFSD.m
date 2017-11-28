function [ selectedFeatures,time ] = K_OFSD( X, Y,N)
% ʹ��K���ھӵ����ǩ������Ϣ�����ôֲڼ����۽�������ѡ��
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
dep_last=0;                                                       %Ŀǰ��ѡ������������

depArray=zeros(1,p);                                       %��������������
% W=length(find(Y==0))/length(Y);
% disp(W);

alpha=0.5;

for i=1:p
    col=X(:,i);
    dep_single=dep_n1(col,Y,N);                  %��������������������㵥�����Ե�������
    depArray(1,i)=dep_single;
    
    if dep_single>alpha                                      %��������������>��ֵ ���Ϊ��ѡ����
        
        if dep_single>dep_last
%             disp(dep_single);
%             disp(i);
            mode((mode==1))=0;
            mode(1,i)=1;
            dep_last=dep_single;                                 %�������幱�׶�  
        else 
           mode(1,i)=1;             
           cols=X(:,mode==1);                               %�������Ϲ��׶�    
           dep_all=dep_n1(cols,Y,N);
           if dep_all>dep_last                                 %������幱�׶�
                dep_last=dep_all;
%                 disp([dep_single,dep_last]);
           else
                 mode(1,i)=0;
           end
           
        end

    end
    
end

% disp(dep_last);
selectedFeatures=find(mode==1);

N=int16(sqrt(p));
if isempty(selectedFeatures)
    disp('sorted features');
    [~,I]=sort(depArray,'descend');
   selectedFeatures =I(1:N);
end

time=toc(start);    
end

function [ dep ] = dep_n1(data,Y,N)
%������������data�Ա�ǩY��������
%����ÿ���ڵ�����������N���ڵ�ı�ǩ��ͬ������weight
%������������������ڸ���������card+1

[n,~]=size(data);
card_U=length(Y);
card_ND=0;
D = pdist(data,'seuclidean');
DArray=squareform(D,'tomatrix');
for i=1:n
     d=DArray(:,i);
     class=Y(i,1);
     card_ND=card_ND+card(d,Y,class,N);
end
dep=card_ND/card_U;
end

%���������N����ѡ������index��ȷ��index��Ӧ��¼��label�Ƿ���ͬ
%������ͬ�̶ȼ���cardֵ
function [c]=card(sets,Y,label,N)
         [~,I]=sort(sets);
         cNum=0;
         for j=2:N+1
             ind=I(j,1);
             if Y(ind,1)==label
                 cNum=cNum+1;
             end
         end  
         if label==0
             if cNum==N
                 c=1;
             else
                 c=0;
             end
         else
             c=cNum/N;
         end
end
