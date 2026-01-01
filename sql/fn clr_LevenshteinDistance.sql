USE tm
GO
/****** Object:  UserDefinedFunction [dbo].[clr_LevenshteinDistance]    Script Date: 1/1/2026 1:02:35 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
create or ALTER FUNCTION [dbo].[clr_LevenshteinDistance](@s1 [nvarchar](250), @s2 [nvarchar](250))
RETURNS [int] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [MSCNameMatching].[MSCNameMatching.LevenshteinDistance].[Calculate]