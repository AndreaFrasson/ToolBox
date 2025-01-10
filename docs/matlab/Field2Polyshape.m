% FUNCTION NAME:Field2Polyshape
%
% DESCRIPTION:
%   obtain the polyshape of field from trajectory data
%
% INPUT:
%   Longitude, Latitude, Altitude: ([1xn], [1xn], [1xn]) vehicle geographical coordinates of trajectory data [degrees, degrees, m] [necessary]
%   Compass_Bearing: ([1xn]) vehicle heading angle [degrees] [necessary]
%   TaskState: ([1xn]) Task state index [no units] [necessary]
%   GPSState: ([1xn]) GPS state index [no units] [necessary]
%   AlgorithmParameters: (struct) AlgorithmParameters object [units none] [necessary]
%   BoundaryShrinkage: ([1x1]) shirinking factor of boundary function [units none] [unnecessary]
%
% OUTPUT:
%   FieldBoundary: polyshape object
%   AreaBoundary [1x1]: polyshape area [m^2]
%   PerimeterBoundary [1x1]: polyshape permiter [m]
%   largh_pass [scalar]: pass width [m]
%   num_pass [scalar]: number of passes [-]
%   Cluster: [1x]: cluster assignment of each data point
%   AngleComb
%
% ASSUMPTIONS AND LIMITATIONS:
%   The Longitude, Latitude, Altitude are intedended to be data related to
%   a single job
%
% EXAMPLE:
%
% [FieldBoundary,AreaBoundary,PerimeterBoundary,largh_pass,num_pass,Cluster,AngleComb]=Field2Polyshape(Longitude,Latitude,Altitude,Compass_Bearing,TaskState,GPSState,AlgorithmParameters,BoundaryShrinkage)
%
%
% REVISION HISTORY:
%   2024/02/26 - Michele Mattetti
%   2024/05/20 - Gianvito Annesi
%   2024/06/13 - Michele Mattetti
%   2024/07/03 - Gianvito Annesi
%   2024/07/26 - Gianvito Annesi
%   2024/07/27 - Bug fix
%   2024/xx/xx - modifica quasi completa al codice, segue nuova idea

function [FieldBoundary,AreaBoundary,PerimeterBoundary,largh_pass,num_pass,Cluster,AngleComb]=Field2Polyshape(Longitude,Latitude,Altitude,Compass_Bearing,TaskState,GPSState,FieldLabel,AlgorithmParameters,BoundaryShrinkage)
    %% Parameter
    MinPts4Cluster=fix(3*60/AlgorithmParameters.TS); % Number of points for each cluster    
    AngleShiftTol=15; %shift angle
           
    Altitude=egm96geoid(Latitude,Longitude); %da valutare se lasciare
    
    % BoundaryShrinkage is not available, the default value is set
    if isempty(BoundaryShrinkage)==1
        BoundaryShrinkage=0.3;
    end

    nbins=10; %number of bins for histcounts function

    if isempty(Latitude)
        FieldBoundary=NaN;
        AreaBoundary=NaN;
        PerimeterBoundary=NaN;
        largh_pass=NaN;
        num_pass=NaN;
        Cluster=NaN;
        AngleComb=NaN;
        return;
    end
        
    [largh_pass,num_pass,CompassPassesMedian]=pass_width(double(Longitude),double(Latitude),Compass_Bearing,TaskState,FieldLabel,AlgorithmParameters);
    if isnan(largh_pass) %gestiscono con valore di recovery
        largh_pass=3;
    end
    
    % removal of duplicates points which may lead to potential issues
    [~,ia]=unique([Latitude,Longitude,Altitude],'rows','stable');
    UniqueLatitude=double(Latitude(ia));
    UniqueLongitude=double(Longitude(ia));
    UniqueAltitude=double(Altitude(ia));
    UniqueCompass_Bearing=CompassPassesMedian(ia);
    UniqueTaskState=TaskState(ia);

    Angle=unique(CompassPassesMedian(~isnan(CompassPassesMedian)));
    
    % extraction of the main directions by looking for peaks in the ksdensity
    % output. Peaks should be placed at 15° each other
   
    if isempty(Angle)
        FieldBoundary=NaN;
        AreaBoundary=NaN;
        PerimeterBoundary=NaN;
        largh_pass=NaN;
        num_pass=NaN;
        Cluster=NaN;
        AngleComb=NaN;
        return;
    end
        
    [N,Edge]=histcounts(Angle,nbins);
    x=(Edge(1:end-1)+Edge(2:end))/2;
    loc=x(N~=0);
    
    % extraction of all combinations among peaks
    b = nchoosek(1:length(loc),2);
    AngleCombAll=loc(b);
    % calculation of the absolute difference among peaks
    AngleDiff=abs(diff(AngleCombAll,[],2));
    
    % mains directions phased of 180° must be clustered together. For data variability, AngleShiftTol is adopted
    DirCluster=double(abs(AngleDiff-180)<AngleShiftTol);   

    if sum(DirCluster~=0)==0
        warning('There are no directions shifted of 180°. Probably the parameter AngleShiftTol must be increased')
        FieldBoundary=NaN;
        AreaBoundary=NaN;
        PerimeterBoundary=NaN;
        largh_pass=NaN;
        num_pass=NaN;
        Cluster=NaN;
        AngleComb=NaN;
        return 
    end
    % Selection of the peaks phased of 180°
    AngleComb=AngleCombAll(DirCluster==1,:);  
    % Label assignment for each main direction
    DirCluster(DirCluster==1)=[1:sum(DirCluster)];
    Angle=Angle';
    
    % Clustering of points in function of the main direction label
    Cluster=zeros(size(UniqueLatitude));  
    Dir4Cluster=loc(all(loc~=AngleComb(:,1),1));

    for i=1:size(Dir4Cluster,2)
        Logic(i,:,1)=ismember(UniqueTaskState,[AlgorithmParameters.Mapping.TaskState('PassWPTO') AlgorithmParameters.Mapping.TaskState('PassWOPTO') AlgorithmParameters.Mapping.TaskState('HT')]);        
        Logic(i,:,2)=abs(UniqueCompass_Bearing-Dir4Cluster(i))<20 | abs(UniqueCompass_Bearing-Dir4Cluster(i)-180)<20 | abs(UniqueCompass_Bearing-Dir4Cluster(i)+180)<20;        
        Cluster(all(squeeze(Logic(i,:,:)),2))=i;
    end
        
    % identification of subclusters (i.e., clusters with the same direction label but
    % distant each other
    
    
    
    % creation of subclusters on the basis of points distance.
    
    % calculation of cartesian coordinate for distance based clustering 
    spheroid = referenceEllipsoid('WGS84','m');
    [x,y,z] = geodetic2ecef(spheroid,UniqueLatitude,UniqueLongitude,UniqueAltitude);
    
    
    SubCluster=zeros(size(Cluster));
    SubClusterLabel=0;
    for iCluster=1:max(unique(Cluster))
        ptCloud=pointCloud([x(Cluster==iCluster), y(Cluster==iCluster),z(Cluster==iCluster)]);
        labels=pcsegdist(ptCloud,20,'NumClusterPoints',MinPts4Cluster);

        %removal of points belonging to no clusters (label=0)        
        Cluster((Cluster==iCluster) & ismember([x y z],ptCloud.Location(labels==0,:),'rows'))=0;
        for ilabel=1:max(unique(labels))
            SubClusterLabel=SubClusterLabel+1;         
            SubCluster((Cluster==iCluster) & ismember([x,y,z],ptCloud.Location(labels==ilabel,:),'row'))=SubClusterLabel;
        end
    end
    ClusterTop=SubCluster;    
    
    %%
    Theta=linspace(0,2*pi,10);Theta(end)=[];
    xTheta=[];
    yTheta=[];
    zTheta=[];
    ClusterTopTheta=[];
    for idxTheta=1:size(Theta,2)
        xTheta=vertcat(xTheta,(x+largh_pass.*cos(Theta(idxTheta))));
        yTheta=vertcat(yTheta,(y+largh_pass.*sin(Theta(idxTheta))));
        zTheta=vertcat(zTheta,z);
        ClusterTopTheta=vertcat(ClusterTopTheta,ClusterTop);
    end
    [UniqueLatitudeTheta,UniqueLongitudeTheta,UniqueAltitudeTheta] = ecef2geodetic(spheroid,xTheta,yTheta,zTheta);
    %scatter(UniqueLatitudeTheta,UniqueLongitudeTheta,[],ClusterTopTheta)
    
    %%
    if unique(ClusterTop)==0
        warning('Unable to cluster trajectories')
        FieldBoundary=NaN;
        AreaBoundary=NaN;
        PerimeterBoundary=NaN;
        largh_pass=NaN;
        num_pass=NaN;
        Cluster=NaN;
        AngleComb=NaN;
        return
    else
        for iCluster=1:length(unique(ClusterTopTheta))
            if sum((ClusterTopTheta==iCluster))>1
                % boundary identification for each cluster
                iBoundary{iCluster}=boundary(double(xTheta(ClusterTopTheta==iCluster)),double(yTheta(ClusterTopTheta==iCluster)),BoundaryShrinkage);

                Longitude1=UniqueLongitudeTheta(ClusterTopTheta==iCluster);
                Latitude1=UniqueLatitudeTheta(ClusterTopTheta==iCluster);
                x1=xTheta(ClusterTopTheta==iCluster);
                y1=yTheta(ClusterTopTheta==iCluster);

                p{iCluster}=polyshape(Longitude1(iBoundary{iCluster}),Latitude1(iBoundary{iCluster}));
                pXYZ{iCluster}=polyshape(x1(iBoundary{iCluster}),y1(iBoundary{iCluster}));
                
                %plot(pXYZ{iCluster})

		        % polyshape union will be applied only from the second cluster
                if iCluster==1
                    FieldBoundary=p{iCluster};
                    FieldBoundaryXYZ=pXYZ{iCluster};
                else
                    FieldBoundary=union(FieldBoundary,p{iCluster});
                    FieldBoundaryXYZ=union(FieldBoundaryXYZ,pXYZ{iCluster});
                end
            end
        end
        AreaBoundary=area(FieldBoundaryXYZ);
        PerimeterBoundary=perimeter(FieldBoundaryXYZ);
    end
end

