<cfcomponent extends="field" name="reversearray" displayname="reversearray" hint="Field component to liase with all list field types"> 

	<!--- import tag libraries --->
	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
	
	<cffunction name="init" access="public" returntype="permissions" output="false" hint="Returns a copy of this initialised object">
		
		<cfreturn this>
	</cffunction>

	<cffunction name="edit" access="public" output="false" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var thispermission = "" />
		<cfset var thisrole = "" />
		<cfset var supportedpermissions = application.security.factory.permission.getAllPermissions(arguments.typename) />
		
		<cfparam name="arguments.stMetadata.ftPermissions" />
		<cfparam name="arguments.stMetadata.ftIncludePermissionLabel" default="#listlen(arguments.stMetadata.ftPermissions) neq 1#" />
		
		<cfsavecontent variable="html">
			
			<cfoutput>
				<table style="border:0 none;">
					<tr style="border:0 none;">
			</cfoutput>
			
			<cfloop list="#supportedpermissions#" index="thispermission">
				
				<cfif listcontainsnocase(arguments.stMetadata.ftPermissions,application.security.factory.permission.getLabel(thispermission))>
					
					<cfoutput><td style="border:0 none;"></cfoutput>
					
					<cfif arguments.stMetadata.ftIncludePermissionLabel>
						<cfoutput><strong>#application.security.factory.permission.getLabel(thispermission)#</strong><br /></cfoutput>
					</cfif>
					
					<cfoutput>
						<select name="#arguments.fieldname##replace(thispermission,'-','','ALL')#" multiple="true">
					</cfoutput>
					
					<cfloop list="#application.security.factory.role.getAllRoles()#" index="thisrole">
					
						<cfoutput><option value="#thisrole#"<cfif application.security.factory.barnacle.getRight(role=thisrole,permission=thispermission,object=arguments.stObject.objectid) eq 1> selected</cfif>>#application.security.factory.role.getLabel(thisrole)#</option></cfoutput>
					
					</cfloop>
					
					<cfoutput>
							</select>
							<input type="hidden" name="#arguments.fieldname#" value=" " />
						</td>
					</cfoutput>
					
				</cfif>
				
			</cfloop>
			
			<cfoutput>
					</tr>
				</table>
			</cfoutput>
			
		</cfsavecontent>

		<cfreturn html />
	</cffunction>
	
	<cffunction name="display" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var thispermission = "" />
		<cfset var thisrole = "" />
		<cfset var supportedpermissions = application.security.factory.permission.getAllPermissions(arguments.typename) />
		
		<cfparam name="arguments.stMetadata.ftPermissions" />
		<cfparam name="arguments.stMetadata.ftIncludePermissionLabel" default="#listlen(arguments.stMetadata.ftPermissions) neq 1#" />
		
		<cfsavecontent variable="html">
			
			<cfoutput>
				<table>
					<tr>
						<th>Role</th>
			</cfoutput>
			
			<cfloop list="#supportedpermissions#" index="thispermission">
				<cfif listcontainsnocase(arguments.stMetadata.ftPermissions,application.security.factory.permission.getLabel(thispermission))>
					<cfoutput>
						<th>#application.security.factory.permission.getLabel(thispermission)#</th>
					</cfoutput>
				</cfif>
			</cfloop>
			
			<cfoutput>
					</tr>
			</cfoutput>
			
			<cfloop list="#application.security.factory.role.getAllRoles()#" index="thisrole">
				
				<cfoutput>
					<tr>
						<th>#application.security.factory.role.getLabel(thisrole)#</th>
				</cfoutput>
				
				<cfloop list="#supportedpermissions#" index="thispermission">
					
					<cfif listcontainsnocase(arguments.stMetadata.ftPermissions,application.security.factory.permission.getLabel(thispermission))>
					
						<cfif application.security.factory.barnacle.getRight(role=thisrole,permission=thispermission,object=arguments.stObject.objectid) eq 1>
							<cfoutput><td>Yes</td></cfoutput>
						<cfelse>
							<cfoutput><td>No</td></cfoutput>
						</cfif>
						
					</cfif>
					
				</cfloop>
			
			</cfloop>
			
			<cfoutput>
				</table>
			</cfoutput>
			
		</cfsavecontent>

		<cfreturn html />
	</cffunction>
	
	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="ObjectID" required="true" type="UUID" hint="The objectid of the object that this field is part of.">
		<cfargument name="Typename" required="true" type="string" hint="the typename of the objectid.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var thispermission = "" />
		<cfset var thisrole = "" />
		<cfset var supportedpermissions = application.security.factory.permission.getAllPermissions(arguments.typename) />
		<cfset var stResult = structnew() />
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.value = "#arguments.stFieldPost.Value#" />
		<cfset stResult.stError = StructNew() />
		
		<cfparam name="arguments.stMetadata.ftPermissions" />
		<cfparam name="arguments.stMetadata.ftIncludePermissionLabel" default="#listlen(arguments.stMetadata.ftPermissions) neq 1#" />
		
		<cfloop list="#application.security.factory.permission.getAllPermissions(arguments.typename)#" index="thispermission">
			<cfif structkeyexists(arguments.stFieldPost.stSupporting,replace(thispermission,'-','','ALL'))>
				<cfloop list="#application.security.factory.role.getAllRoles()#" index="thisrole">
					<cfif not listcontains(arguments.stFieldPost.stSupporting[replace(thispermission,'-','','ALL')],thisrole)>
						<cfset application.security.factory.barnacle.updateRight(role=thisrole,permission=thispermission,object=arguments.objectid,right=0) />
					<cfelse>
						<cfset application.security.factory.barnacle.updateRight(role=thisrole,permission=thispermission,object=arguments.objectid,right=1) />
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfreturn stResult />
	</cffunction>
	
</cfcomponent>