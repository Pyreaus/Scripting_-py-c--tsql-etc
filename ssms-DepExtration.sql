USE [BOOKIN]
GO
/****** Object:  StoredProcedure [dbo].[sp_DepAttendance]    Script Date: 22/10/2021 14:24:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Noel A. Rhima /p1
-- Create date: 2021-18
-- =============================================
ALTER PROCEDURE [dbo].[sp_DepAttendance] 
@dateStart date, 
@dateStop date  --variables for data range
AS
BEGIN                          
	SET NOCOUNT ON;                                                         /*storing department active personnel count into temp table*/
    SELECT      [DepartmentID], SUM(CASE WHEN ActiveUser=1 AND Human=1 THEN 1 ELSE 0 END) AS [DepartmentSize] INTO [#Departments] FROM [PEOPLEFINDER_2].[dbo].[people] GROUP BY [DepartmentID]                                                                                            
	SELECT		[eventdate]  --no prefix, within scope of BOOKIN                         
				, DATEPART(WEEKDAY, [eventdate]) AS [DayNum] 
				, DATEPART(WEEK, [eventdate]) AS [WeekNum]
				, DATENAME(weekday, [eventdate]) AS [DayNm]
				            --returning corresponding floor & department data returned
                , SUM(CASE WHEN r.[Desk] IS NULL THEN 1 ELSE 0 END) AS [CountFloorNull]
				, SUM(CASE WHEN LEFT([Desk], 1) = 1 THEN 1 ELSE 0 END) AS [CountFloor01]
				, SUM(CASE WHEN LEFT([Desk], 1) = 2 THEN 1 ELSE 0 END) AS [CountFloor02]
				, [DepartmentID]
	INTO        [#BaseRefTable]
	FROM		[BOOKIN].[dbo].[AttendanceLogEntry] [logs]
				LEFT JOIN [PEOPLEFINDER_2].[dbo].[People] [P]
					ON [logs].[PeopleFinderID] = [P].[PFID]
				LEFT JOIN [PEOPLEFINDER_2].[dbo].[Rooms] [R]
					ON [P].[RoomID] = [R].[ID]
	WHERE		DATEPART(WEEKDAY, [eventdate]) NOT IN (7, 1)
				AND [EventDate] >= @dateStart AND [EventDate] <= @dateStop
				AND [AttendanceOrigin] = 1   --segmenting returned data and grouping fields
	GROUP BY	[eventdate], DATEPART(WEEKDAY, [eventdate]), DATENAME(weekday, [eventdate]), DATEPART(WEEK, [eventdate]), [DepartmentID] 
	ORDER BY    [EventDate];
	SELECT      [EventDate],[DayNm],[B].[DepartmentID],[P].[Name],[CountFloorNull],[CountFloor01],[CountFloor02]
	            ,[TotalIn]=([CountFloor02]+[CountFloor01]+[CountFloorNull]),[DailyPercentage%] =(ROUND((([CountFloor02]+[CountFloor01]+[CountFloorNull])/cast([D].[DepartmentSize] AS float))*100,1)) 
	FROM [#BaseRefTable] [B]
	LEFT JOIN [#Departments] [D]
	    ON [B].[DepartmentID] = [D].[DepartmentID]
	LEFT JOIN [PEOPLEFINDER_2].[dbo].[Departments] [P]
	    ON [B].[DepartmentID] = [P].[ID]
END
