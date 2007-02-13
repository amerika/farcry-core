<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/dynamic/export.cfm,v 1.6.2.1 2006/03/21 04:43:09 jason Exp $
$Author: jason $
$Date: 2006/03/21 04:43:09 $
$Name: milestone_3-0-1 $
$Revision: 1.6.2.1 $

|| DESCRIPTION || 
$Description: Export Edit Handler $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
--->
<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iExportTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ContentExportTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iExportTab eq 1>
	<cfoutput><span class="Formtitle">#application.adminBundle[session.dmProfile.locale].xmlExport#</span><p></p></cfoutput>

	<cfset bShowForm=1>
	
	<!--- check valid email address --->
	<cfif isdefined("form.submit")>		
		<cfif (NOT REFindNoCase('^[A-Za-z0-9_\.\-]+@([A-Za-z0-9_\.\-]+\.)+[A-Za-z]{2,4}$', trim(form.sendTo)))>
			<cfset subS=listToArray('#application.path.project#,#application.config.general.exportPath#')>
			<cfset message = "#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].exportDirNotExists,subS)#">
			<cfset bShowForm=1>
		<cfelse>
			<cfset bShowForm = 0>		
		</cfif>
	</cfif>
	
	<!--- if no error than show form --->
	<cfif not bShowForm>
		<cfobject component="#evaluate("application.types.#form.contentType#.typePath")#" name="oContentType">
		
		<!--- get all objects --->
		<cfset stObjects = oContentType.getMultiple(dsn=application.dsn,dbowner=application.dbowner)>
		
		<!--- work out which export type to generate --->
		<cfswitch expression="#form.exportType#">
			<cfcase value="xml">
			
				<!--- loop over and generate xml --->
				<cfsavecontent variable="stExport">
					<cfoutput><?xml version="1.0" encoding="utf-8"?>
					<objects></cfoutput>
					<cfloop collection="#stObjects#" item="obj">
						<cfoutput><item></cfoutput>
							<!--- loop through these types and look at each field --->
							<cfloop collection="#application.types[form.contentType].stProps#" item="Field">
								<cfif application.types[form.contentType].stProps[field].metadata.type neq "array"><cfoutput><#field#>#xmlFormat(stObjects[obj][field])#</#field#></cfoutput></cfif>
							</cfloop>
						<cfoutput></item></cfoutput>
					</cfloop>
					<cfoutput></objects></cfoutput>
				</cfsavecontent>
				
				<!--- set file path --->
				<cfset filePath ="#application.path.project#/#application.config.general.exportPath#/#form.contentType#.xml">
				
				<!--- check directory exists --->
				<cfif not directoryExists("#application.path.project#/#application.config.general.exportPath#")>
					<cfdirectory action="CREATE" directory="#application.path.project#/#application.config.general.exportPath#">
				</cfif>	

				<cftry>
					<!--- generate file --->
					<cffile action="write" file="#filePath#" output="#toString(stExport)#" addnewline="no" nameconflict="OVERWRITE">
					<cfcatch>
					<cfset subS=listToArray('#application.path.project#,#application.config.general.exportPath#')>			
					<cfoutput>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].exportDirNotExists,subS)#</cfoutput>
					</cfcatch>
				</cftry>

			</cfcase>
		</cfswitch>

		<!--- send export file --->
		<cfmail from="#form.sendTo#" to="#form.sendTo#" subject="#form.contentType# export" mimeattach="#filePath#">
#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].exportAttached,"#form.contentType#")#		
		</cfmail>
		
		<!--- success message --->
		<cfoutput>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].exportFileSent,"#form.sendTo#")#</cfoutput>
		
	</cfif>
	
	<!--- show form --->
	<cfif bShowForm>
		<!--- check for error message --->
		<cfif isdefined("message")>
			<cfoutput><div class="error" style="margin-left:30px;">#message#</div><p></p></cfoutput>
		</cfif>
		
		<cfoutput>
		<!--- show form --->
		<form action="" method="post">
			<div class="FormTable">	
				<table class="BorderTable" width="400" align="center">
				<!--- contentType --->
				<tr>
					<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].contentType# </span></td>
					<td width="100%">
						<!--- sort structure by Key name --->
						<cfset listofKeys = structKeyList(application.types)>
						<cfset listofKeys = listsort(listofkeys,"textnocase")>	
						<select name="contentType">
							<!--- loop over types structure in memory -- populated on application init --->
							<cfloop list="#listOfKeys#" index="i">
								<option value="#i#">#i#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<!--- send xml file details --->
				<tr>
					<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].sendTo#</span></td>
					<td width="100%"><input type="text" name="sendTo" class="formtextbox" maxlength="255" size="45"></td>
				</tr>
				<!--- export type --->
				<tr>
					<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].exportAs#</span></td>
					<td width="100%">
						<select name="exportType">
							<option value="xml">XML
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				</table>
			</div>
			<input type="submit" name="submit" value="#application.adminBundle[session.dmProfile.locale].export#" class="normalbttnstyle" style="margin-left:30px;">
		</form>	
		</cfoutput>
	</cfif>
<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="no">