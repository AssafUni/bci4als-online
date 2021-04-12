
%function MI_OnlineClassification_Scaffolding2(prediction)
    %%trying to plot dynamic graphh

    x2 = [50 50];
    y2 = [0 0];
    figure
    p = plot(x2,y2);
    numIter = 100;
    xlim([0 numIter])
    ylim([0 numIter])
    axes('pos',[.01 .9 0.5 0.1])
    image = imread('left.gif');
    imshow(image)
    
   
    xlabel('X')
    ylabel('Y')
    title('	\leftarrow LEFT or RIGHT \rightarrow ');

    p.XDataSource = 'x2';
    p.YDataSource = 'y2';
    
%     plot((1:10).^2)
    

    denom = 1;
    k = -10;
    for t = 1:100
        denom = denom + 2;
        y2(t) = t;
        if (t == 1)
            x2(t) = 50 +k;
            image = imread('right.gif');
        else
            x2(t) = 50+k; %supposed to be x2(t-1) +k
            image = imread('left.gif');
            if (k> 0)
                image = imread('right.gif');
            end
        end
        
        
        imshow(image)
        refreshdata
        drawnow
        %hold on
        k = -k;
    end
