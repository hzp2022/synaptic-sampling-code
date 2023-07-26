% 一个交互式的图形界面，可以用来交互式地调整矩阵 V 的可视化表示
figure;

%I = data.I;
%V = data.net.V;

N = size(V,1);

while true;
   imagesc( V(I,I) );
   [x,y,b] = ginput(1);
   
   idx = floor(x)+1;
   
   if (b==1) && (idx>1)
       tmp = I(idx);
       I(idx) = I(idx-1);
       I(idx-1) = tmp;
   end
   
   if (b==2) && (idx<=N)
       %[x,y,b] = ginput(1);       
       %idx2 = floor(x)+1;
       %tmp = I(idx);
       %I(idx) = I(idx2);
       %I(idx2) = tmp;
       
       I = [I(1:(idx-1)),I((idx+1):end)];
   end
   
   if (b==3) && (idx<N)
       tmp = I(idx);
       I(idx) = I(idx+1);
       I(idx+1) = tmp;
   end
   
   fprintf('%f, %f, %f\n', idx,y,b );
end
