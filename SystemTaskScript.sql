USE [ExtraPOSDemo]
GO
/****** Object:  Table [dbo].[t_SystemTask]    Script Date: 03/01/2022 13:53:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_SystemTask](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ParentId] [nvarchar](max) NULL,
	[Name] [nvarchar](max) NULL,
	[Order] [int] NULL,
	[IsLastChild] [bit] NULL,
 CONSTRAINT [PK_SystemTask] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[t_SystemTask] ON 

INSERT [dbo].[t_SystemTask] ([Id], [ParentId], [Name], [Order], [IsLastChild]) VALUES (5, N'NULL', N'Customers Module', 1, 0)
INSERT [dbo].[t_SystemTask] ([Id], [ParentId], [Name], [Order], [IsLastChild]) VALUES (6, N'NULL', N'Sales Module', 2, 0)
INSERT [dbo].[t_SystemTask] ([Id], [ParentId], [Name], [Order], [IsLastChild]) VALUES (7, N'NULL', N'Inventory Module', 3, 0)
INSERT [dbo].[t_SystemTask] ([Id], [ParentId], [Name], [Order], [IsLastChild]) VALUES (8, N'NULL', N'Expenses Module', 4, 0)
INSERT [dbo].[t_SystemTask] ([Id], [ParentId], [Name], [Order], [IsLastChild]) VALUES (9, N'NULL', N'Admin Settings Module', 1, 0)
INSERT [dbo].[t_SystemTask] ([Id], [ParentId], [Name], [Order], [IsLastChild]) VALUES (10, N'NULL', N'Reports Module', 2, 0)
INSERT [dbo].[t_SystemTask] ([Id], [ParentId], [Name], [Order], [IsLastChild]) VALUES (11, N'NULL', N'Transactions Module', 3, 0)
SET IDENTITY_INSERT [dbo].[t_SystemTask] OFF
/****** Object:  StoredProcedure [dbo].[p_AddEditSystemTask]    Script Date: 03/01/2022 13:53:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_AddEditSystemTask]
(
	@ID						int,
	@ParentId				bigint,
	@Name					nvarchar(200),
	@Order					bigint,
	@IsLastChild			bit
)
AS
BEGIN
	BEGIN TRY
		IF EXISTS(Select Id from t_SystemTask where Id=@ID)
			BEGIN
				Update t_SystemTask set ParentId=@ParentId,Name=@Name,[Order]=@Order,IsLastChild=@IsLastChild
					 WHERE ID=@ID
				RETURN
			END
		ELSE
			BEGIN
				Insert Into t_SystemTask(ParentId,Name,[Order],IsLastChild)
				values(@ParentId,@Name,@Order,@IsLastChild)
			END
	END TRY
BEGIN CATCH 
	IF (@@TRANCOUNT > 0)
	BEGIN
		ROLLBACK TRANSACTION INSERTRECORD
	END 

	EXEC dbo.p_GetErrorInfo

	DECLARE @MessageID varchar(MAX) = Error_Message(),
		@Severity int = ERROR_SEVERITY(),
		@State smallint = ERROR_STATE() 
			 	 
	RAISERROR(@MessageID, @Severity, @State)

END CATCH
END

--exec p_AddEditSystemTask
GO
/****** Object:  StoredProcedure [dbo].[p_GetUserRole]    Script Date: 03/01/2022 13:53:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[p_GetUserRole]
(
	@Email			nvarchar(50)
)
AS 
BEGIN
	BEGIN TRY 
	Declare @RoleID nvarchar(10),@Role nvarchar(100)
		Select top 1 @Role = Role from t_Users 
				WHERE Email = @Email

		Select @RoleID=SubCodeID from t_SystemCodes where ID='RoleID' and Description=@Role

		Select Name from t_RoleProfiles RP inner Join t_SystemTask ST on RP.TaskID=ST.Id
		where RP.RoleId=@RoleID
		--IF()
		--	BEGIN
		--		SELECT UserID FROM t_Users 
		--	END
		--ELSE
		--	BEGIN
		--		SELECT * FROM t_Users 
		--		WHERE Email = @Email
		--	END
	
	END TRY
	BEGIN CATCH 
		IF (@@TRANCOUNT > 0)
		BEGIN
			ROLLBACK TRANSACTION INSERTRECORD
		END 

		EXEC dbo.p_GetErrorInfo

		DECLARE @MessageID varchar(MAX) = Error_Message(),
			@Severity int = ERROR_SEVERITY(),
			@State smallint = ERROR_STATE() 
			 	 
		RAISERROR(@MessageID, @Severity, @State)

	END CATCH
END

GO
