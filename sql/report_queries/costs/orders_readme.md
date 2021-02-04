Order Cluster query


The purpose of this report is to provide details about each purchase order. 
It allows filtering by date, subscription range, order type, tags, and workflow status. 
The data are aggregated by purchase order line number, acquisition method, acquistion unit name, and material type.

For date ranges, it is important to specify a half-open interval. For instance, to retrieve data "x" using a "subscription from" start date of 1/1/2013 
and a "subscription to" end date of 1/1/2014, you would use 1/1/2013 <= x < 1/1/2014. The end date parameter is not the last day of the interval; 
it is the day after (half open interval). This ensures including all times up to midnight in the date range.



