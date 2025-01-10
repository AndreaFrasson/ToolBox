Autodoc
*******


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
%   2024/xx/xx - modifica quasi completa al codice, segue nuova ide
