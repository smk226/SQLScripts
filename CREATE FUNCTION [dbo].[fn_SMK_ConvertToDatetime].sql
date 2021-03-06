CREATE FUNCTION [dbo].[fn_SMK_ConvertToDatetime]
(
    @Date Varchar(50)
)
RETURNS DATETIME
AS
BEGIN

/********************************************************************************
*  Written by Subhash Manikanta Kumar Mogili (SMK)
*  Created: 01 August 2019

*  --- PURPOSE ---
*  This function will convert the anytype date input (Varchar) to Datetime
********************************************************************************/


--SELECT  @Date = UPPER(REPLACE(REPLACE(LTRIM(RTRIM(NULLIF(@Date,''))),':',''),' ','-'))
IF (LEN(@Date) - LEN(REPLACE(@Date, ' ', '')) = 1) AND (LEN(@Date) > 10)
BEGIN
	SELECT  @Date = LTRIM(RTRIM(CASE WHEN SUBSTRING(@Date,1,CHARINDEX(' ',@Date)) <> '' THEN SUBSTRING(@Date,1,CHARINDEX(' ',@Date)) ELSE @Date END))
END

SELECT  @Date = UPPER(LTRIM(RTRIM(NULLIF(REPLACE(@Date,'  ',''),''))))

--IF IT'S  VALID DATE AND DO THE BELOW CHECKS TO CONVERT TO DATE
IF ISDATE(@Date) = 1
BEGIN
	IF (@Date LIKE '%[^a-zA-Z0-9]%' AND @Date NOT LIKE '%[a-zA-Z]%') 
	BEGIN  
		--## LEADING ZERO FOR THE DATE EX: '8-5-8' TO '08-05-08'
		SET @Date = CASE WHEN LEN(SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)) = 1 THEN '0'+ @Date ELSE @Date END --DAY 
		
		SET @Date =	CASE WHEN LEN(SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,(LEN(@Date) - (PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date))) + PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date)))))))) = 1
						 THEN SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)
						 + '-' +'0'+ SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,(LEN(@Date) - (PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date))) + PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date)))))))
						 + '-' + REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1)) ELSE @Date END --Month
						 
		SET @Date =	CASE WHEN LEN(REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1))) = 1 
						 THEN SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)
						  + '-'  + SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,(LEN(@Date) - (PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date))) + PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date)))))))
						  + '-' + RIGHT('0'+REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1)),2) ELSE @Date END --YEAR
		
		--IF THE INPUT DATE FORMAT IS DD-MM-YYYY AND DD OR MM ARE LESS THAN 12 THEN DO THE BELOW CHECKS
		IF (CASE WHEN LEN(SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)) = 2 THEN SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1) END) <= 12  
			AND (SELECT SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,LEN(PATINDEX('%[^a-zA-Z0-9]%', @Date))+1)) <= 12  
		BEGIN
			SET @Date =  CASE WHEN LEN(REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1))) = 4 
						      THEN REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1))
					     WHEN LEN(REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1))) = 2 
						      AND LEN(SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)) <> 2
							  THEN SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)
						 WHEN LEN(REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1))) = 2 
						      AND LEN(SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)) = 2
						 	  THEN LEFT(DATEPART(YY,GETDATE()),2)+REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1)) END ---YEAR
			+ '-' + SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,LEN(PATINDEX('%[^a-zA-Z0-9]%', @Date))+1) ---MONTH
			+ '-' + CASE WHEN LEN(SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)) = 2 
							  THEN SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1) 
			             WHEN LEN(SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)) = 4 
							  THEN REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1)) END ---DAY

			SET @Date = CASE WHEN ISDATE(@Date) = 1 THEN REPLACE(CONVERT(VARCHAR(10),CAST(@Date AS DATETIME),102),'.','-' ) ELSE NULL END
		END
	END
	ELSE
	SET @Date = REPLACE(CONVERT(VARCHAR(10),CAST(@Date AS DATETIME),102),'.','-' )
END

ELSE IF ISDATE(@Date) = 0 --IF IT'S NOT VALID DATE AND DO THE BELOW CHECKS TO CONVERT TO DATE
BEGIN 
	IF (@Date LIKE '%[a-zA-Z]%' AND @Date LIKE '%[0-9]%' AND @Date LIKE '%[^a-zA-Z0-9]%')
	BEGIN 
		--## LEADING ZEROS FOR THE DATE EX: '8-AUG-8' TO '08-AUG-08'
		SELECT @Date =  CASE WHEN LEN(SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)) = 1 THEN '0'+ @Date  ---Leading Zero for the date ex: '8-MAY-8' to '08-MAY-08'
							  WHEN LEN(REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1))) = 1 
							  THEN SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)
								  + '-' + SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date))))
								  + '-' + RIGHT('0'+REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1)),2) ELSE @Date END
	
		SET @Date = CASE WHEN LEN(SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)) = 1 
							  THEN '0'+SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1) 
						 WHEN LEN(SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)) = 2 
							  THEN SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1) 
				         WHEN LEN(SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)) = 4 
							  THEN REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1)) END ---DAY
		    + '-' + CASE WHEN SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))) LIKE '%JAN%' THEN '01' 
		 		         WHEN SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))) LIKE '%FEB%' THEN '02'
		 		         WHEN SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))) LIKE '%MAR%' THEN '03'
		 		         WHEN SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))) LIKE '%APR%' THEN '04'
		 		         WHEN SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))) LIKE '%MAY%' THEN '05'
		 		         WHEN SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))) LIKE '%JUN%' THEN '06'
		 		         WHEN SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))) LIKE '%JUL%' THEN '07'
		 		         WHEN SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))) LIKE '%AUG%' THEN '08'
		 		         WHEN SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))) LIKE '%SEP%' THEN '09'
		 		         WHEN SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))) LIKE '%OCT%' THEN '10'
		 		         WHEN SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))) LIKE '%NOV%' THEN '11'
		 		         WHEN SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))) LIKE '%DEC%' THEN '12' END ---MONTH
		    + '-' + CASE WHEN LEN(REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1))) = 4 
							  THEN REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1))
						 WHEN LEN(REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1))) = 2 
							  AND LEN(SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1) ) <> 2
							  THEN SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)
						 WHEN LEN(REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1))) = 2 --IF First and two char are same length considering the last two as a year
							   AND LEN(SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1) ) = 2
							  THEN LEFT(DATEPART(YY,GETDATE()),2)+REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1))   
						 WHEN LEN(REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1))) = 1
						      THEN '0'+SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)		   END ---YEAR
	END
	
	--Example: @Date  = DDMMYYYY or YYYYMMDD
	ELSE IF (@Date NOT LIKE '%[^a-zA-Z0-9]%')
	BEGIN 
			SET @Date = CASE WHEN LEN(@Date) > 6 AND SUBSTRING(@Date,5,4) BETWEEN '1900' AND '3000'  --YEAR CHECK 
								   THEN SUBSTRING(LTRIM(RTRIM(@Date)),1,2) + '-' + SUBSTRING(LTRIM(RTRIM(@Date)),3,2) + '-' + SUBSTRING(LTRIM(RTRIM(@Date)),5,4)
							 WHEN LEN(@Date) > 6 AND SUBSTRING(@Date,1,4) BETWEEN '1900' AND '3000'  --YEAR CHECK  
								   THEN SUBSTRING(LTRIM(RTRIM(@Date)),7,2) + '-' + SUBSTRING(LTRIM(RTRIM(@Date)),5,2) + '-' + SUBSTRING(LTRIM(RTRIM(@Date)),1,4)
							 WHEN LEN(@Date) <= 6 
								   THEN SUBSTRING(LTRIM(RTRIM(@Date)),1,2) + '-' + SUBSTRING(LTRIM(RTRIM(@Date)),3,2) + '-' + LEFT(DATEPART(YY,GETDATE()),2)+SUBSTRING(LTRIM(RTRIM(@Date)),5,2)  END
			
	END
	
	--Example: @Date  = DD-MM-YYYY or YYYY-MM-DD
	ELSE IF (@Date LIKE '%[^a-zA-Z0-9]%') 
		 BEGIN  
			--## CHECK SPECIAL CHARACTERS IN STRING AND COUNT ##-- 
			DECLARE @strSpcChar VARCHAR(256)
			SET @strSpcChar = @Date
			
			DECLARE @intAlpha INT
			SET @intAlpha = PATINDEX('%[a-zA-Z0-9]%', @strSpcChar)
			BEGIN
				WHILE @intAlpha > 0
				BEGIN
					SET @strSpcChar = STUFF(@strSpcChar, @intAlpha, 1, '')
					SET @intAlpha = PATINDEX('%[a-zA-Z0-9]%', @strSpcChar)
				END
			END

			DECLARE @SpclCharCount INT
			SET @SpclCharCount = LEN(@Date) - LEN(REPLACE(@Date, ISNULL(LEFT(@strSpcChar,1),0), '')) 
			
			IF @SpclCharCount = 2
			BEGIN
				--## LEADING ZERO FOR THE DATE EX: '8-5-8' TO '08-05-08'
				SET @Date = CASE WHEN LEN(SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)) = 1 THEN '0'+ @Date ELSE @Date END --DAY 
				
				SET @Date =	CASE WHEN LEN(SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,(LEN(@Date) - (PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date))) + PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date)))))))) = 1
								 THEN SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)
								 + '-' +'0'+ SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,(LEN(@Date) - (PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date))) + PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date)))))))
								 + '-' + REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1)) ELSE @Date END --Month
								 
				SET @Date =	CASE WHEN LEN(REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1))) = 1 
								 THEN SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)
								  + '-'  + SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,(LEN(@Date) - (PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date))) + PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date)))))))
								  + '-' + RIGHT('0'+REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1)),2) ELSE @Date END --YEAR
	
				SET @Date = CASE WHEN LEN(SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)) = 2 
									  THEN SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1) 
					             WHEN LEN(SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)) = 4 
									  THEN REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1)) END ---DAY
				    + '-' + SUBSTRING(@Date,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))+1,LEN(PATINDEX('%[^a-zA-Z0-9]%', @Date))+1) ---MONTH
					+ '-' + CASE WHEN LEN(REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1))) = 4 
								      THEN REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1))
							     WHEN LEN(REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1))) = 2 
								      AND LEN(SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)) <> 2
									  THEN SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)
								 WHEN LEN(REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1))) = 2 
								       AND LEN(SUBSTRING(LTRIM(RTRIM(@Date)),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(@Date)))-1)) = 2
								 	   THEN LEFT(DATEPART(YY,GETDATE()),2)+REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(@Date))),1,PATINDEX('%[^a-zA-Z0-9]%',LTRIM(RTRIM(REVERSE(@Date))))-1)) END ---YEAR
			END
			ELSE SELECT @Date =  NULL
		END
	
	SELECT @Date = SUBSTRING(LTRIM(RTRIM(@Date)),7,4) + '-' + SUBSTRING(LTRIM(RTRIM(@Date)),4,2) + '-' + SUBSTRING(LTRIM(RTRIM(@Date)),1,2)
	
	IF ISDATE(@Date) = 1
	BEGIN
	
		DECLARE @dtDate DATETIME
		SELECT @dtDate = SUBSTRING(LTRIM(RTRIM(@Date)), 1, 8) + '01'
		SELECT @dtDate = DATEADD(MM, DATEDIFF(MM, 0, @dtDate), 0)

		--## IF INPUT DATE YEAR IS GREATER THAN THE CURRENT YEAR THEN RETURN NULL ##--
		IF SUBSTRING(LTRIM(RTRIM(@Date)), 1, 4) > '9000'
		BEGIN
			SET @Date = NULL
		END
		ELSE 
		--## IF INPUT DATE DAY IS GREATER THAN THE DATE FROM THE MONTH THEN RETURN NULL ##--
		IF SUBSTRING(LTRIM(RTRIM(@Date)), 9, 2) > DATEDIFF(DD, @dtDate, DATEADD(MM, 1, @dtDate))
		BEGIN
			SET @Date = NULL
		END
	
		SELECT @Date = ISNULL(NULLIF(@Date, ''), NULL)
	END
	ELSE
		SELECT @Date = NULL
END 

 RETURN  @Date     

END
