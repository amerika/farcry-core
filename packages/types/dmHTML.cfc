<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/dmHTML.cfc,v 1.23.2.1 2005/12/02 05:13:46 guy Exp $
$Author: guy $
$Date: 2005/12/02 05:13:46 $
$Name: milestone_3-0-1 $
$Revision: 1.23.2.1 $

|| DESCRIPTION || 
$Description: dmHTML Content Type. Forms the basis of the content framework of the site.  HTML objects include containers and static information. $
$TODO: <whatever todo's needed -- can be inline also>$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->

<cfcomponent extends="types" displayname="HTML Page" hint="Forms the basis of the content framework of the site.  HTML objects include containers and static information." bObjectBroker="1" bSchedule="1" bUseInTree="1" bFriendly="1">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty ftSeq="1" ftWizzardStep="Start" ftFieldset="General Details" name="Title" type="nstring" hint="Title of object.  *perhaps this should be deprecated for object label*" required="no" default="" ftValidation="required">
<cfproperty ftSeq="2" ftWizzardStep="Start" ftFieldset="General Details" name="reviewDate" type="date" hint="The date for which the object will be reviewed" required="no" default="" ftType="datetime" ftToggleOffDateTime="true" ftLabel="Review Date">
<cfproperty ftSeq="3" ftWizzardStep="Start" ftFieldset="General Details" name="ownedby" displayname="Owned by" type="nstring" hint="Username for owner." required="No" default="" ftLabel="Owned By" ftType="list" ftRenderType="dropdown" ftListData="getOwners">
<cfproperty ftSeq="4" ftWizzardStep="Start" ftFieldset="General Details" name="displayMethod" type="string" hint="Display method to render this HTML object with." required="yes" default="display" ftLabel="Display Method" ftType="webskin" ftPrefix="displayPage">

<cfproperty ftSeq="5" ftWizzardStep="Start" ftFieldset="Metadata" name="metaKeywords" type="nstring" hint="HTML head section metakeywords." required="no" default="" ftLabel="Meta Keywords">
<cfproperty ftSeq="6" ftWizzardStep="Start" ftFieldset="Metadata" name="extendedmetadata" type="longchar" hint="HTML head section for extended keywords." required="no" default="" ftlabel="Extended Metadata" ftToggle="true">


<cfproperty ftSeq="12" ftWizzardStep="Body" ftFieldset="Body" name="Body" type="longchar" hint="Main body of content." required="no" default="" ftType="richtext" ftLabel="Body" 
	ftImageArrayField="aObjectIDs" ftImageTypename="dmImage" ftImageField="StandardImage"
	ftTemplateTypeList="dmImage,dmFile,dmFlash,dmNavigation,dmHTML" ftTemplateWebskinPrefixList="insertHTML"
	ftTemplateSnippetWebskinPrefix="insertSnippet">

<cfproperty ftSeq="13" ftWizzardStep="Body" ftFieldset="Relationships" name="aObjectIDs" type="array" hint="Holds objects to be displayed at this particular node.  Can be of mixed types." required="no" default="" ftLabel="Associated Media" ftJoin="dmImage,dmFile,dmFlash">
<cfproperty ftSeq="14" ftWizzardStep="Body" ftFieldset="Relationships" name="aRelatedIDs" type="array" hint="Holds object pointers to related objects.  Can be of mixed types." required="no" default="" ftJoin="dmNavigation,dmHTML" ftLabel="Associated Content">

<cfproperty ftSeq="10" ftWizzardStep="Body" ftFieldset="Teaser" name="Teaser" type="longchar" hint="Teaser text." required="no" default="">
<cfproperty ftSeq="11" ftWizzardStep="Body" ftFieldset="Teaser" name="teaserImage" type="uuid" hint="UUID of image to display in teaser" required="no" default="" ftJoin="dmImage" ftLibraryData="getTeaserImageLibraryData" ftLibraryDataTypename="dmHTML">

<cfproperty ftSeq="20" ftWizzardStep="Categorisation" name="catHTML" type="nstring" hint="Topic." required="no" default="" ftType="Category" ftAlias="root" ftLabel="Categories" />

<cfproperty name="status" type="string" hint="Status of the node (draft, pending, approved)." required="yes" default="draft">
<cfproperty name="versionID" type="uuid" hint="objectID of live object - used for versioning" required="no" default="">
<cfproperty name="commentlog" type="longchar" hint="Workflow comment log." required="no" default="">



<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	
<!--- <cffunction name="edit" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfinclude template="_dmhtml/edit.cfm">
</cffunction> --->


<cffunction name="getOwners" access="public" output="false" returntype="string">
	
	<cfset var errormessage = "" />
	<cfset var name = "" />
	<cfset var q = queryNew("value,name") />
	<cfset var lResult =  "" />
	
	<cfset objProfile = CreateObject("component",application.types.dmprofile.packagepath)>
	<cfset returnstruct = objProfile.fListProfileByPermission("Admin")>
	<cfif returnstruct.bSuccess>
		<cfset q = returnstruct.queryObject>

		<cfloop query="q">
			<cfif Trim(q.lastName) EQ "" AND Trim(q.firstName) EQ "">
				<cfset name = q.username />
			<cfelse>
				<cfset name = "#q.lastName# #q.firstName#" />
			</cfif>
			<cfset lResult = listAppend(lResult, HTMLEditFormat("#q.objectid#:#name#")) />
		</cfloop>
	
	</cfif>
	
	<cfreturn lResult />


</cffunction>


<cffunction name="display" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfinclude template="_dmhtml/display.cfm">
</cffunction>

<cffunction name="deleteRelatedIds" hint="Deletes references to a given uuid in the dmHTML_relatedIds table">
	<cfargument name="objectid" required="yes" type="uuid">
	<cfargument name="dsn" required="no" default="#application.dsn#">
	<cfargument name="dbowner" required="no" default="#application.dbowner#">
	
	<cfset var q = ''>
	<cfquery name="q" datasource="#arguments.dsn#">
		DELETE FROM #application.dbowner#dmHTML_aRelatedIDs
		WHERE parentid = '#arguments.objectid#'
	</cfquery>
	
</cffunction>

<cffunction name="getTeaserImageLibraryData" access="public" output="false" returntype="query" hint="Return a query for all images already associated to this object.">
	<cfargument name="primaryID" type="uuid" required="true" hint="ObjectID of the object that we are attaching to" />
	<cfargument name="qFilter" type="query" required="true" hint="If a library verity search has been run, this is the qResultset of that search" />
	
	<cfset var q = queryNew("blah") />
		
	<!--- 
	Run the entire query and return in to the library. Let the library handle the pagination.
	 --->
	<cfquery datasource="#application.dsn#" name="q">
	SELECT data as objectid, dmImage.label, dmImage.thumbnailimage, dmImage.title, dmImage.alt
	FROM dmHTML_aObjectIDs 
	INNER JOIN 
		 dmImage ON dmHTML_aObjectIDs.data = dmImage.objectid
	WHERE parentid = '#arguments.primaryID#'
	<cfif qFilter.RecordCount>
		AND data IN (#ListQualify(ValueList(qFilter.key),"'")#)
	</cfif>
	ORDER BY seq
	</cfquery>
	
	<cfreturn q />
	
</cffunction>



</cfcomponent>

