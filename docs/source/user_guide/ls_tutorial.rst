LIVE SCRIPT MARDOWN
===================


```matlab
S = load('/Users/andreafrasson/Desktop/DatasetTEST.mat');
data = S.CanData;

lat = []
lon = []
time = []
id = []

for i = 1:size(data,2)
    disp(i)
    lat = [lat, data(i).Latitude']
    lon = [lon, data(i).Longitude']
    time = [time, data(i).TimeHHMMSS']
    new_id = repmat(i, 1, size(data(i).Latitude, 1))
    id = [id, new_id]
end

% Combine into a table (easier to handle with headers)
T = table(id', lat', lon', time', 'VariableNames', {'id', 'Lat', 'Lon', 'Time'});

% Specify file name
filename = '/users/andreafrasson/Desktop/output_data.csv';

% Write table to CSV file
writetable(T, filename);

disp(['Data written to ', filename]);
```
