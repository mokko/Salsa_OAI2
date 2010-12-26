<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://www.mpx.org/mpx File://C:/Documents and Settings/Mengel/My Documents/workspace/filesystem/mpx-lvl2.v2.xsd"
	xmlns:mpx="http://www.mpx.org/mpx" xmlns="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

	<!-- 
		script to produce "filesystem" by splitting one big xml file in many 
		little ones named according to id
		
		a future version of this script might require to put multimedia-objects 
		which belong to sammlungsobject in the same file to give XSLT 1.0
		transformation access to this information. Would also reduce no of
		files and make each transformation longer. Not sure about 
		performance hit in which this would result.
	
	-->

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:strip-space elements="*"/>

	<xsl:template match="/mpx:museumPlusExport/mpx:multimediaobjekt">
		<xsl:variable name="mulId" select="@mulId"/>
		<!-- 
		<xsl:message terminate="no"> mulId<xsl:value-of select="$mulId"/>
		</xsl:message>
		-->
		<!-- xsl:variable name="outFile" select="concat(string(position()),'.xml')" / -->
		<xsl:variable name="outFile" select="concat('fs/mulId-',$mulId,'.mpx')"/>
		<xsl:result-document href="{$outFile}">
			<museumPlusExport>
				<xsl:copy-of select="."/>
			</museumPlusExport>
		</xsl:result-document>
	</xsl:template>

	<xsl:template match="/mpx:museumPlusExport/mpx:personKörperschaft">
		<xsl:variable name="kueId" select="@kueId"/>
		<!-- 
		<xsl:message terminate="no"> kueId<xsl:value-of select="$kueId"/>
		</xsl:message>
		-->
		<!-- xsl:variable name="outFile" select="concat(string(position()),'.xml')" / -->
		<xsl:variable name="outFile" select="concat('fs/kueId-',$kueId,'.mpx')"/>
		<xsl:result-document href="{$outFile}">
			<museumPlusExport>
				<xsl:copy-of select="."/>
			</museumPlusExport>
		</xsl:result-document>
	</xsl:template>

	<xsl:template match="/mpx:museumPlusExport/mpx:sammlungsobjekt">
		<xsl:variable name="objId" select="@objId"/>
<!-- 
		<xsl:message terminate="no"> objId<xsl:value-of select="$objId"/>
		</xsl:message>
-->
		<!-- xsl:variable name="outFile" select="concat(string(position()),'.xml')" / -->
		<xsl:variable name="outFile" select="concat('fs/objId-',$objId,'.mpx')"/>
		<xsl:result-document href="{$outFile}">
			<museumPlusExport>
				<!--  <xsl:copy-of select="/mpx:museumPlusExport/mpx:multimediaobjekt[mpx:verknüpftesObjekt eq $objId"/>-->
				<xsl:copy-of select="."/>
			</museumPlusExport>
		</xsl:result-document>
	</xsl:template>
</xsl:stylesheet>
