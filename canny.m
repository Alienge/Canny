 I = imread('rice.png');  
I = double(I);  
[height,width] = size(I);  
J = I;  
  
conv = zeros(5,5);%��˹�����  
sigma = 1;%����  
sigma_2 = sigma * sigma;%��ʱ����  
sum = 0;  
for i = 1:5  
    for j = 1:5  
        conv(i,j) = exp((-(i - 3) * (i - 3) - (j - 3) * (j - 3)) / (2 * sigma_2)) / (2 * 3.14 * sigma_2);%��˹��ʽ  
        sum = sum + conv(i,j);  
    end  
end  
conv = conv./sum;%��׼��  
  
%��ͼ��ʵʩ��˹�˲�  
for i = 1:height  
    for j = 1:width  
        sum = 0;%��ʱ����  
        for k = 1:5  
            for m = 1:5  
                if (i - 3 + k) > 0 && (i - 3 + k) <= height && (j - 3 + m) > 0 && (j - 3 + m) < width  
                    sum = sum + conv(k,m) * I(i - 3 + k,j - 3 + m);  
                end  
            end  
        end  
        J(i,j) = sum;  
    end  
end  
figure,imshow(J,[])  
title('��˹�˲���Ľ��')  
%���ݶ�  
dx = zeros(height,width);%x�����ݶ�  
dy = zeros(height,width);%y�����ݶ�  
d = zeros(height,width);  
for i = 1:height - 1  
    for j = 1:width - 1  
        dx(i,j) = J(i,j + 1) - J(i,j);  
        dy(i,j) = J(i + 1,j) - J(i,j);  
        d(i,j) = sqrt(dx(i,j) * dx(i,j) + dy(i,j) * dy(i,j));  
    end  
end  
figure,imshow(d,[])  
title('���ݶȺ�Ľ��')  
  
%�ֲ��Ǽ���ֵ����  
K = d;%��¼���зǼ���ֵ���ƺ���ݶ�  
%����ͼ���ԵΪ�����ܵı�Ե��  
for j = 1:width  
    K(1,j) = 0;  
end  
for j = 1:width  
    K(height,j) = 0;  
end  
for i = 2:width - 1  
    K(i,1) = 0;  
end  
for i = 2:width - 1  
    K(i,width) = 0;  
end  
  
for i = 2:height - 1  
    for j = 2:width - 1  
        %��ǰ���ص���ݶ�ֵΪ0����һ�����Ǳ�Ե��  
        if d(i,j) == 0  
            K(i,j) = 0;  
        else  
            gradX = dx(i,j);%��ǰ��x������  
            gradY = dy(i,j);%��ǰ��y������  
            gradTemp = d(i,j);%��ǰ���ݶ�  
            %���Y�������ֵ�ϴ�  
            if abs(gradY) > abs(gradX)  
                weight = abs(gradX) / abs(gradY);%Ȩ��  
                grad2 = d(i - 1,j);  
                grad4 = d(i + 1,j);  
                %���x��y������������ͬ  
                %���ص�λ�ù�ϵ  
                %g1 g2  
                %   C  
                %   g4 g3  
                if gradX * gradY > 0  
                    grad1 = d(i - 1,j - 1);  
                    grad3 = d(i + 1,j + 1);  
                else  
                    %���x��y���������ŷ�  
                    %���ص�λ�ù�ϵ  
                    %   g2 g1  
                    %   C  
                    %g3 g4  
                    grad1 = d(i - 1,j + 1);  
                    grad3 = d(i + 1,j - 1);  
                end  
            %���X�������ֵ�ϴ�  
            else  
                weight = abs(gradY) / abs(gradX);%Ȩ��  
                grad2 = d(i,j - 1);  
                grad4 = d(i,j + 1);  
                %���x��y������������ͬ  
                %���ص�λ�ù�ϵ  
                %g3  
                %g4 C g2  
                %     g1  
                if gradX * gradY > 0  
                    grad1 = d(i + 1,j + 1);  
                    grad3 = d(i - 1,j - 1);  
                else  
                    %���x��y���������ŷ�  
                    %���ص�λ�ù�ϵ  
                    %     g1  
                    %g4 C g2  
                    %g3  
                    grad1 = d(i - 1,j + 1);  
                    grad3 = d(i + 1,j - 1);  
                end  
            end  
            %����grad1-grad4���ݶȽ��в�ֵ  
            gradTemp1 = weight * grad1 + (1 - weight) * grad2;  
            gradTemp2 = weight * grad3 + (1 - weight) * grad4;  
            %��ǰ���ص��ݶ��Ǿֲ������ֵ�������Ǳ�Ե��  
            if gradTemp >= gradTemp1 && gradTemp >= gradTemp2  
                K(i,j) = gradTemp;  
            else  
                %�������Ǳ�Ե��  
                K(i,j) = 0;  
            end  
        end  
    end  
end  
figure,imshow(K,[])  
title('�Ǽ���ֵ���ƺ�Ľ��')  
  
%����˫��ֵ��EP_MIN��EP_MAX����EP_MAX = 2 * EP_MIN  
EP_MIN = 12;  
EP_MAX = EP_MIN * 2;  
EdgeLarge = zeros(height,width);%��¼���Ե  
EdgeBetween = zeros(height,width);%��¼���ܵı�Ե��  
for i = 1:height  
    for j = 1:width  
        if K(i,j) >= EP_MAX%С��С��ֵ��������Ϊ��Ե��  
            EdgeLarge(i,j) = K(i,j);  
        else if K(i,j) >= EP_MIN  
                EdgeBetween(i,j) = K(i,j);  
            end  
        end  
    end  
end  
%��EdgeLarge�ı�Ե��������������  
MAXSIZE = 999999;  
Queue = zeros(MAXSIZE,2);%������ģ�����  
front = 1;%��ͷ  
rear = 1;%��β  
edge = zeros(height,width);  
for i = 1:height  
    for j = 1:width  
        if EdgeLarge(i,j) > 0  
            %ǿ�����  
            Queue(rear,1) = i;  
            Queue(rear,2) = j;  
            rear = rear + 1;  
            edge(i,j) = EdgeLarge(i,j);  
            EdgeLarge(i,j) = 0;%�����ظ�����  
        end  
        while front ~= rear%�Ӳ���  
            %��ͷ����  
            temp_i = Queue(front,1);  
            temp_j = Queue(front,2);  
            front = front + 1;  
            %8-��ͨ��Ѱ�ҿ��ܵı�Ե��  
            %���Ϸ�  
            if EdgeBetween(temp_i - 1,temp_j - 1) > 0%����ǿ����Χ�������Ϊǿ��  
                EdgeLarge(temp_i - 1,temp_j - 1) = K(temp_i - 1,temp_j - 1);  
                EdgeBetween(temp_i - 1,temp_j - 1) = 0;%�����ظ�����  
                %���  
                Queue(rear,1) = temp_i - 1;  
                Queue(rear,2) = temp_j - 1;  
                rear = rear + 1;  
            end  
            %���Ϸ�  
            if EdgeBetween(temp_i - 1,temp_j) > 0%����ǿ����Χ�������Ϊǿ��  
                EdgeLarge(temp_i - 1,temp_j) = K(temp_i - 1,temp_j);  
                EdgeBetween(temp_i - 1,temp_j) = 0;  
                %���  
                Queue(rear,1) = temp_i - 1;  
                Queue(rear,2) = temp_j;  
                rear = rear + 1;  
            end  
            %���Ϸ�  
            if EdgeBetween(temp_i - 1,temp_j + 1) > 0%����ǿ����Χ�������Ϊǿ��  
                EdgeLarge(temp_i - 1,temp_j + 1) = K(temp_i - 1,temp_j + 1);  
                EdgeBetween(temp_i - 1,temp_j + 1) = 0;  
                %���  
                Queue(rear,1) = temp_i - 1;  
                Queue(rear,2) = temp_j + 1;  
                rear = rear + 1;  
            end  
            %����  
            if EdgeBetween(temp_i,temp_j - 1) > 0%����ǿ����Χ�������Ϊǿ��  
                EdgeLarge(temp_i,temp_j - 1) = K(temp_i,temp_j - 1);  
                EdgeBetween(temp_i,temp_j - 1) = 0;  
                %���  
                Queue(rear,1) = temp_i;  
                Queue(rear,2) = temp_j - 1;  
                rear = rear + 1;  
            end  
            %���ҷ�  
            if EdgeBetween(temp_i,temp_j + 1) > 0%����ǿ����Χ�������Ϊǿ��  
                EdgeLarge(temp_i,temp_j + 1) = K(temp_i,temp_j + 1);  
                EdgeBetween(temp_i,temp_j + 1) = 0;  
                %���  
                Queue(rear,1) = temp_i;  
                Queue(rear,2) = temp_j + 1;  
                rear = rear + 1;  
            end  
            %���·�  
            if EdgeBetween(temp_i + 1,temp_j - 1) > 0%����ǿ����Χ�������Ϊǿ��  
                EdgeLarge(temp_i + 1,temp_j - 1) = K(temp_i + 1,temp_j - 1);  
                EdgeBetween(temp_i + 1,temp_j - 1) = 0;  
                %���  
                Queue(rear,1) = temp_i + 1;  
                Queue(rear,2) = temp_j - 1;  
                rear = rear + 1;  
            end  
            %���·�  
            if EdgeBetween(temp_i + 1,temp_j) > 0%����ǿ����Χ�������Ϊǿ��  
                EdgeLarge(temp_i + 1,temp_j) = K(temp_i + 1,temp_j);  
                EdgeBetween(temp_i + 1,temp_j) = 0;  
                %���  
                Queue(rear,1) = temp_i + 1;  
                Queue(rear,2) = temp_j;  
                rear = rear + 1;  
            end  
            %���·�  
            if EdgeBetween(temp_i + 1,temp_j + 1) > 0%����ǿ����Χ�������Ϊǿ��  
                EdgeLarge(temp_i + 1,temp_j + 1) = K(temp_i + 1,temp_j + 1);  
                EdgeBetween(temp_i + 1,temp_j + 1) = 0;  
                %���  
                Queue(rear,1) = temp_i + 1;  
                Queue(rear,2) = temp_j + 1;  
                rear = rear + 1;  
            end  
        end  
        %����2�����ڹ۲�������е�״��  
        i  
        j  
    end  
end  
  
figure,imshow(edge,[])  
title('˫��ֵ��Ľ��')

