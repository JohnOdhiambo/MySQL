USE [FieldForceDemo]
GO
/****** Object:  Trigger [dbo].[tr_DeleteSites]    Script Date: 10/09/2021 08:55:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER  TRIGGER [dbo].[tr_DeleteSites] ON [dbo].[RSMSites]
FOR DELETE
AS
BEGIN
	DECLARE @SiteID					nvarchar(20),
			@SiteName				nvarchar(510),
			@Longitude				nvarchar(250),
			@Latitude				nvarchar(250),
			@Status					nvarchar(150),
			@ProjectID				nvarchar(20),
			@ContactNumber			nvarchar(150),
			@County					nvarchar(510),
			@MappingUserID			nvarchar(20),
			@DateMapped				smalldatetime,
			@Address				nvarchar(510),
			@Area					nvarchar(510),
			@UserDefinedCounty		nvarchar(510),
			@ContactNumber2			nvarchar(510),
			@Region					nvarchar(510),
			@IsDeleted				bit,
			@ModifiedOn				smalldatetime,
			@Error_Message			nvarchar(100)

			SELECT TOP 1 
				@SiteID=SiteID,
				@SiteName=SiteName,
				@Longitude=Longitude,
				@Latitude=Latitude,
				@Status=Status,
				@ProjectID=ProjectID,
				@ContactNumber=ContactNumber,
				@County=County,
				@MappingUserID=MappingUserID,
				@DateMapped=DateMapped,
				@Address=Address,
				@Area=Area,
				@UserDefinedCounty=UserDefinedCounty,
				@ContactNumber2=ContactNumber2,
				@Region=Region,@IsDeleted=1,
				@ModifiedOn=GETDATE()
			FROM Deleted 

    IF NOT EXISTS(SELECT TOP 1 1 FROM RSMSites(NOLOCK) WHERE SiteID=@SiteID) 
	BEGIN
		INSERT INTO RSMSitesArchive
			(SiteID,SiteName,Longitude,Latitude,Status,ProjectID,ContactNumber,County,MappingUserID,
			 DateMapped,Address,Area,UserDefinedCounty,ContactNumber2,Region,IsDeleted,ModifiedOn)
		SELECT @SiteID,@SiteName,@Longitude,@Latitude,@Status,@ProjectID,@ContactNumber,@County,@MappingUserID,
			   @DateMapped,@Address,@Area,@UserDefinedCounty,@ContactNumber2,@Region,@IsDeleted,@ModifiedOn
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM RSMSitesArchive(NOLOCK) WHERE SiteID=@SiteID)
	BEGIN
		SET @Error_Message='Deletion disabled for RSMSites ('+@SiteID+')'

		RAISERROR(@Error_Message,16,1)

		ROLLBACK TRAN
	END
END
