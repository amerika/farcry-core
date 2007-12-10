<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/navajo/delete.cfm,v 1.20 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.20 $

|| DESCRIPTION || 
$Description: DELETE OBJECTS FROM TREE $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: <separate entry for each variable>$
$out: <separate entry for each variable>$
--->
<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec">

<cfif isDefined("URL.objectID")>

	<!--- Get the object --->
	
	<q4:contentobjectget objectid="#url.ObjectId#" r_stobject="stObj">
	
	<!--- This gets the parent object -- need this to clean up its reference to the object we are deleting --->
	<cfset oType = createObject("component", application.types[stObj.typename].typePath)>
	<cfset oNav = createObject("component", application.types.dmNavigation.typePath)>
	<cfif stObj.typename EQ "dmNavigation">
		<cfset qGetParent = application.factory.oTree.getParentID(objectID = stObj.objectID)>
		<cfset parentObjectID = qGetParent.parentID>
	<cfelse> <!--- likely to be a parent object with aObjects property (eg. dmHTML, dmNews) --->
		<cfset qGetParent = oNav.getParent(objectid=stObj.objectID)>
		<cfset parentObjectID = qGetParent.parentid>
	</cfif>
	
	<!--- get the parentID --->
	<q4:contentobjectget objectid="#parentObjectId#" r_stobject="srcObjParent">
	
	<sec:CheckPermission error="true" permission="edit" type="#srcObjParent.typename#" objectid="#parentobjectid#">
							
		<cfif NOT stObj.typename IS "dmNavigation">
			<cfset key = 'aobjectids'>
			<cfloop index="i" from="#ArrayLen(srcObjParent[key])#" to="1" step="-1">
				<cfif srcObjParent[key][i] eq stObj.objectId>
					<cfset ArrayDeleteAt( srcObjParent[key], i )>
				</cfif>
			</cfloop>
			<cfscript>
				// $TODO: may want to check if this is necessary, implies that date value has been changed on get. GB$
				srcObjParent.datetimecreated = createODBCDate("#datepart('yyyy',srcObjParent.datetimecreated)#-#datepart('m',srcObjParent.datetimecreated)#-#datepart('d',srcObjparent.datetimecreated)#");
				srcObjParent.datetimelastupdated = createODBCDate(now());
				
				// update the parent object instance
				oParentType = createobject("component", application.types[srcObjParent.typename].typePath);
				oParentType.setData(stProperties=srcObjParent,auditNote="Child Deleted");
			</cfscript>
			<!--- $TODO: may need to remove typename attribute and force a lookup -- what if it's a custom type? GB$ --->
		</cfif>
	
		<!--- type specific delete options --->
		<cfset oType.delete(stObj.objectId)>
	
		<!--- Update the tree view --->
		<!--- <nj:updateTree objectId="#parentObjectID#"> --->
		
		<!--- update overview page --->
		<cfoutput><script type="text/javascript">
		// check if edited from Content or Site (via sidetree)
		if(parent['sidebar'].frames['sideTree'])
			parent['sidebar'].frames['sideTree'].location= parent['sidebar'].frames['sideTree'].location;
		</script></cfoutput>
		
	</sec:CheckPermission>
	
<cfelse>
	<cfthrow detail="URL.objectID not passed">
</cfif>

<cfsetting enablecfoutputonly="No">