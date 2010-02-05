<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_verity/verityUpdate.cfm,v 1.8.2.4 2006/04/19 00:45:51 geoff Exp $
$Author: geoff $
$Date: 2006/04/19 00:45:51 $
$Name: p300_b113 $
$Revision: 1.8.2.4 $

|| DESCRIPTION || 
$Description: updates verity collection$

$todo: looks like someone commented out the where clauses for limiting 
updates to only those objects recently updated.. no reason given in the 
commit comments. GB 20060405 $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->
<cfset key = replaceNoCase(arguments.collection,"#application.applicationName#_","")>

<!--- check for existing collections with no app data --->
<cfif not structKeyExists(application.config.verity.contenttype,"#key#") and not structKeyExists(application.config.verity.contenttype[key],"lastUpdated")>
	<cfoutput>#application.rb.getResource("resetVerity")#</cfoutput>
<cfelse>			
	<!--- work out collection type --->
	<cfif isArray(application.config.verity.contenttype[key].aprops)>
		<cfset collectionType = "type">
	<cfelse>
		<cfset collectionType = "file">
	</cfif>

	<!--- get all content items under trash --->
	<cfset qList = application.factory.oTree.getDescendants(objectid=application.navid.rubbish,bIncludeSelf=true)>
	<cfset lNodeIDS = valueList(qList.objectid)>
	<cfset aExcludeObjectID = application.factory.oTree.getLeaves(lNodeIDS)>
	<cfset lExcludeObjectID = "">
	<cfloop index="i" from="1" to="#ArrayLen(aExcludeObjectID)#">
		<cfset lExcludeObjectID = ListAppend(lExcludeObjectID, aExcludeObjectID[i].objectid)>
	</cfloop>
	<cfset lExcludeObjectID = ListQualify(lExcludeObjectID,"'")>

	<!--- check collection type --->
	<cfif collectionType eq "type">
		<!--- update type collection: backward compatability --->
		<cfset stTypeResult=updateTypeCollection(key, lExcludeObjectID)>
		<cfoutput>#stTypeResult.report#</cfoutput>
		<cfflush />
			
	<cfelse>
		<!--- update file collection: backward compatability --->
		<cfset stFileResult=updateFileCollection(key)>
		<cfoutput>#stFileResult.report#</cfoutput>
		<cfflush />
	</cfif>
	
	<!--- reset lastupdated timestamp --->
	<cfset setLastupdated(arguments.collection, now())>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> <strong></strong> #application.rb.formatRBString("updated","#arguments.collection#")#<p></p></cfoutput>
</cfif>
