Autodoc
*******

.. function:: Field2Polyshape(Longitude,Latitude,Altitude,Compass_Bearing,TaskState,GPSState,AlgorithmParameters [,BoundaryShrinkag+e)

   obtain the polyshape of field from trajectory data.

   :param Longitude, Latitude, Altitude: vehicle geographical coordinates of trajectory data [degrees, degrees, m] [necessary]
   :param Compass_Bearing: vehicle heading angle [degrees] 
   :param TaskState: Task state index [no units]
   :param GPSState: GPS state index [no units]
   :param AlgorithmParameters: AlgorithmParameters object [units none]
   :type AlgorithmParameters: struct
   :param BoundaryShrinkage: ([1x1]) shirinking factor of boundary function [units none]
   :return: FieldBoundary: polyshape object, \n
      AreaBoundary [1x1]: polyshape area [m^2], \n
      PerimeterBoundary [1x1]: polyshape permiter [m], \n
      largh_pass [scalar]: pass width [m], \n
      num_pass [scalar]: number of passes [-], \n
      Cluster: [1x]: cluster assignment of each data point, \n
      AngleComb

